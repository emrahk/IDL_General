;+
; Name:
;
;      DROT_COORD
;
; Purpose:
;
;      Differentially rotate coordinates of a solar raster map
;
; Category:
;
;      Maps
;
; Calling sequence:
;
;      new_coord=DROT_COORD(map,t_ref)
;
; Inputs:
;
;      map : input map (size of data _array: [Nx,Ny])
;      t_ref : reference time for rotation
;
; Keyword parameters:
;
;      XYP = non-rotated coordinates (OUT)
;      VERBOSE = issue messages warning about off-limb pixels
;      OFFLIMB = indexes of off-limb pixels in each spectrum (OUT)
;      N_OFFLIMB = number of off limb pixels in each spectrum (array, OUT)
;      SPHERE = keyword passed to ARCMIN2HEL throuth ROT_XY (IN, default: 1; 
;               note that the default in ROT_XY is 0)
;      KEEP = keep same same P,B0,R values when rotating: use TIME tag as 
;             reference epoch for computing these values
;
; Outputs:
;
;      new_coord : new coordinates: array[Nx,Ny,2]
;
; Common blocks:
;
;      None
;
; Calls:
;
;      VALID_MAP,GET_MAP_XP,GET_MAP_YP,ROT_XY,PB0R
;
; Description:
;
;        A map is considered to represent a raster if it contains a tag, 
;      named START, giving the start times of each exposure (column) of the 
;      raster. The coordinates of each column are then differentially rotated 
;      to the reference time. 
;        If the START tag does not exist, or its size does not match the first 
;      dimension of the data array, an 'ordinary' solar image is assumed, and 
;      the solar rotation is evaluated at the same time for all the pixels 
;      (as in DROT_MAP).
;        Pixels that are no longer visible after the rotation interval are 
;      swept under the rug, i.e. are put at the limb, at their original 
;      position angle. Otherwise, the coordinates of off-limb pixels are 
;      left unaltered. The indexes of all off-limb pixels can however be 
;      retrieved via keywords OFFLIMB and N_OFFLIMB.
;        Tags ROLL_ANGLE and ROLL_CENTER are recognized and used to compute 
;      the heliographic coordinates of the map. 
;
; Side effects:
;
;      None
;
; Restrictions:
;
;      - It is assumed that raster exposures are stored in the data array 
;      columns (when ROLL=0, that means that rastering is done parallel 
;      the E/W direction). 
;      - Does not accept array of maps.
;
; Notes:
;
;      Since it requires multiple calls to ROT_XY, rotating rasters can be 
;      much slower than rotating images of the same dimensions. 
;
; Modification history:
;
;      V. Andretta,   26/Jan/1999 - Written; derived from older DROT_NISMAP. 
;      V. Andretta,   28/Feb/1999 - Use ROLL and ROLL_CENTER from map structure;
;        added SPHERE and OFFLIMB keywords; tried to fix off-limb pixels; 
;        speeded-up rotation of 'ordinary' maps (images, not rasters).
;      V. Andretta,   11/Apr/1999 - Added KEEP keyword.
;      V. Andretta,   16/Jan/2001 - Improved treatment of points rolled over 
;        behind the disk.
;      V. Andretta,    5/Dec/2001 - Taken into account changes in UNPACK_MAP 
;        regarding tag and keyword names specifying roll properties 
;        (ROLL -> ROLL_ANGLE, RCENTER -> ROLL_CENTER).
;
; Contact:
;
;      andretta@na.astro.it
;-
;===============================================================================
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function DROT_COORD,map,t_ref,VERBOSE=verbose,XYP=xyp $
                     ,OFFLIMB=off_disk,N_OFFLIMB=N_off,BACKDISK=back_disk $
                     ,SPHERE=sphere,KEEP=keep

  ON_ERROR,2

;%%%
;%%% Check input and some definitions
;%%%

  xyr=[0,0]

  if N_PARAMS() lt 2 then begin
    PRINT,'%E> DROT_COORD: Usage: DROT_COORD,map,t_ref'
    RETURN,xyr
  endif

  if VALID_MAP(map) eq 0 then begin
    PRINT,'%E> DROT_COORD: Input structure not a map'
    RETURN,xyr
  endif

  if N_ELEMENTS(map) gt 1 then begin
    PRINT,'%E> DROT_COORD: Cannot handle arrays of maps'
    RETURN,xyr
  endif

  errmsg=''
  t0=ANYTIM2TAI(t_ref,ERRMSG=errmsg)
  if errmsg ne '' then begin
    PRINT,'%E> DROT_COORD: '+errmsg
    RETURN,xyr
  endif

  verb=KEYWORD_SET(verbose)

  if N_ELEMENTS(sphere) eq 0 then sphere=1

  using_soho_view=SOHO_VIEW()
  if TAG_EXIST(map,'SOHO') then earth_view=map.soho eq 0 else earth_view=1

  keep_angles=KEYWORD_SET(keep)

  cr=string("15B)

;%%%
;%%% Rotate coordinates
;%%%

;% Map and grid parameters, and other definitions

  UNPACK_MAP,map,NX=Nx,NY=Ny,ROLL_ANGLE=roll,ROLL_CENTER=rcenter
  roll=FLOAT(roll) mod 360.
  xp=GET_MAP_XP(map)
  yp=GET_MAP_YP(map)
;% Default values for start times
  if TAG_EXIST(map,'TIME') then map_time=map.time else GET_UTC,map_time
  if TAG_EXIST(map,'DUR') then map_dur=map.dur else map_dur=0.0
  tp=REPLICATE(ANYTIM2TAI(map_time)+0.5*map_dur,Nx)
;% Actual values associated with the map
  if TAG_EXIST(map,'START') then begin
    if N_ELEMENTS(map.start) ne Nx then $
      PRINT,'%W> DROT_COORD: ' $
           +'Number of START times inconsistent with DATA 1st dimension' $
    else $
      tp=ANYTIM2TAI(map.start)
  endif
  if MIN(tp) ne MAX(tp) then multi_time=1 else multi_time=0

  if verb then PRINT $
    ,'%I> DROT_COORD: Differentally rotating coordinates to '+ANYTIM2CAL(t0)
;% Set SOHO or EARTH view, according to the type of map
  if earth_view then USE_EARTH_VIEW else USE_SOHO_VIEW
;% If KEEP keyword is set, compute here P,B0,R values; these values will be 
;% passed to ROT_XY later
  if keep_angles then begin
    angles=PB0R(map_time,SOHO=SOHO_VIEW())
    P_sun=angles(0)
    B0_sun=angles(1)
  ;% convert solar radius to observer's distance, in units of solar radii
    D_sun=1./ATAN(angles(2)/(60.*!RADEG))
  endif
;% Roll back coordinates
  if roll ne 0 then ROLL_XY,xp,yp,-roll,CENTER=rcenter,xp,yp
  xpr=xp
  ypr=yp
  N_off=REPLICATE(Ny,Nx)
  off_disk=REPLICATE(1B,Nx,Ny)
  back_disk=REPLICATE(0B,Nx,Ny)
  if multi_time then begin
;% Raster: rotate each column independently
    for ix=0,Nx-1 do begin
      if verb then PRINT $
        ,'%I> DROT_COORD: Rotating spectrum '+STRTRIM(ix,2)+cr,FORM='($,a)'
      xy=ROT_XY(xp(ix,*),yp(ix,*),TSTART=tp(ix),TEND=t0 $
        ,OFFLIMB=offlimb,INDEX=disk_index,RADIUS=radius $
        ,P=P_sun,B0=B0_sun,R0=D_sun,KEEP=keep_angles,BACK=behind $
        ,SPHERE=KEYWORD_SET(sphere))
      if disk_index(0) ge 0 then begin
        xpr(ix,disk_index)=xy(disk_index,0)
        ypr(ix,disk_index)=xy(disk_index,1)
        off_disk(ix,disk_index)=0
        N_off(ix)=Ny-N_ELEMENTS(disk_index)
      endif
      if behind(0) ge 0 then back_disk(ix,behind)=1B
    endfor
    if verb then PRINT,FORM='($,/)'
    behind=WHERE(back_disk)
  endif else begin
;% Image: rotate the entire image simultaneously
    if verb then PRINT,'%I> DROT_COORD: Rotating all pixels...'
    xp1=REFORM(xp,Nx*Ny)
    yp1=REFORM(yp,Nx*Ny)
    xy=ROT_XY(xp1,yp1,TSTART=tp(0),TEND=t0 $
      ,OFFLIMB=offlimb,INDEX=disk_index,RADIUS=radius $
      ,P=P_sun,B0=B0_sun,R0=D_sun,KEEP=keep_angles,BACK=behind $
      ,SPHERE=KEYWORD_SET(sphere))
    if disk_index(0) ge 0 then begin
      xpr(disk_index)=xy(disk_index,0)
      ypr(disk_index)=xy(disk_index,1)
      off_disk(disk_index)=0
      for ix=0,Nx-1 do begin
        off_ix=WHERE(off_disk(ix,*),N_off_ix)
        N_off(ix)=N_off_ix
      endfor
    endif
    if behind(0) ge 0 then back_disk(behind)=1B
  endelse
;% Coordinates which were rotated to the back of the visible disk, are then 
;% placed at the limb, at the same latitude. 
  if behind(0) ge 0 then begin
   ;% Compute latitude of points behind the visible disk
    lat=ARCMIN2HEL(xpr(behind)/60,ypr(behind)/60,DATE=t0 $
                  ,P=P_sun,B0=B0_sun,R0=D_sun,SPHERE=KEYWORD_SET(sphere))
    lat=lat(0,*)
  ;% If not done already, compute solar B0
    if keep_angles eq 0 then begin
      angles=PB0R(t0,SOHO=SOHO_VIEW())
      B0_curr=angles(1)
    endif else $
      B0_curr=B0_sun
  ;% Longitude of the limb at each latitude (would be 180 degrees if B0=0)
    lon_limb=-TAN(B0_curr/180.*!DPI)*TAN(lat/180.*!DPI)
    good_val=WHERE(ABS(lon_limb) le 1,Ngood_val)
    if Ngood_val gt 0 then begin
      lon_limb(good_val)=ACOS(lon_limb(good_val))/!DPI*180.
  ;% Transform new coordinates back to cartesian
      arc=HEL2ARCMIN(lat(good_val),lon_limb(good_val),DATE=t0,SOHO=SOHO_VIEW() $
                    ,P=P_sun,B0=B0_sun,R0=D_sun)*60
      xpr(behind(good_val))=arc(0,*)
      ypr(behind(good_val))=arc(1,*)
    endif
  endif
;% Re-apply roll angle
  if roll ne 0 then ROLL_XY,xpr,ypr,+roll,CENTER=rcenter,xpr,ypr
;% Restore type of view
  if using_soho_view eq 0 then USE_EARTH_VIEW else USE_SOHO_VIEW


;%%%
;%%% End
;%%%


  xyp=[[[TEMPORARY(xp)]],[[TEMPORARY(yp)]]]
  off_disk=WHERE(off_disk)
  back_disk=WHERE(back_disk)
  RETURN,[[[xpr]],[[ypr]]]
  END
