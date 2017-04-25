;+
; Name:
;
;      DROT_RASTER
;
; Purpose:
;
;      Differentially rotate solar raster maps
;
; Category:
;
;      Maps
;
; Calling sequence:
;
;      map_drot=DROT_RASTER(map [ , t_ref ] [ , REF_MAP=map_ref ] 
;                           [ , ROLL=roll_angle , RCENTER=roll_center ]
;                           [ , /ADD_RDUR , /VERBOSE , SPHERE=0 , /KEEP ] )
;
; Inputs:
;
;      map : input map (size of data array: [Nx,Ny])
;      t_ref : reference time for rotation (def.: current time)
;
; Keyword parameters:
;
;      REF_MAP = reference map for rotation and gridding. Its TIME, ROLL 
;                ROLL_CENTER values supersede those specified by t_ref, 
;                ROLL and RCENTER. Values of FULL_SIZE, SAME_GRID and MEMSAVE 
;                (see below) are also ignored. 
;      ROLL = final roll angle of the image
;      RCENTER = center of rotation (if rolling)
;      ADD_RDUR = add to the output map a tag (RDUR) containing an array that 
;                 estimates the duration of the rotation interval on a 
;                 pixel-by-pixel basis.
;      VERBOSE = issue messages warning about off-limb pixels
;      SPHERE = keyword passed to ARCMIN2HEL throuth ROT_XY (IN, default: 1; 
;               note that the default in ROT_XY is 0)
;      KEEP = passed to DROT_COORD: keeps same same P,B0,R values when 
;             rotating: use TIME tag as reference epoch for computing these 
;             values
;      FULL_SIZE = expand image size to fit the entire rotated FOV.
;      SAME_GRID = retains old grid (ignored when dealing with an array of maps)
;      MEMSAVE = for arrays of maps, do not store the rotated coordinates 
;                in a sigle array, but rather regrid images based on estimates 
;                of the new positions of the FOV corners. 
;      all keywords accepted by INTERP2D, except /REGULAR
;
; Outputs:
;
;      map_drot : new map (differentially rotated)
;
; Common blocks:
;
;      None
;
; Calls:
;
;      VALID_MAP,GET_UTC,ANYTIM2TAI,UNPACK_MAP,SOHO_VIEW,USE_SOHO_VIEW,
;      USE_EARTH_VIEW,GET_MAP_XRANGE,GET_MAP_YRANGE,GET_ARR_CENTER,ROT_XY,
;      REP_TAG_VALUE,ADD_PROP,ROLL_XY,DROT_COORD,PB0R
;
; Description:
;
;        A map is considered to represent a raster if it contains a tag,
;      named START, giving the start times of each exposure (column) of the
;      raster. 
;        The coordinates of each column (exposure) are differentially rotated
;      to the reference time (t_ref). The data array is then interpolated on 
;      a regular grid. If an array of maps is given, the new grid is the 
;      same for all the maps, and covers the largest rectangular FOV included 
;      in (or including, if FULL_SIZE is set) the rotated FOV's of all maps. 
;      For a single map, the original grid can be also used (keyword SAME_GRID, 
;      useful for small time intervals).
;        When ROLL and/or RCENTER, are specified, the resulting maps are 
;      also rotated to the new roll angle.
;        When a reference map is provided, its TIME, ROLL, ROLL_CENTER, and   
;      grid parameters override all other input values. 
;
; Side effects:
;
;      None
;
; Restrictions:
;
;      - Assumes that rasters are built in the E-W direction or viceversa, 
;      not N-S (see DROT_COORD).
;      - Mixing maps (including MAP_REF) with both SOHO and EARTH coordinates 
;      is not allowed.
;
; Notes:
;
;      The algorithm employed here (for zero roll angles) is the following:
;
;        1) Differentially rotate coordinates (-> ROT_XY)
;        2) Interpolate data on the new (irregular) grid (-> INTERP2D,REGULAR=0)
;
;      On the other hand, the algorithm employed by DROT_MAP (current version 
;      as of January 2001) is the following:
;
;        1) Differentially rotate coordinates (-> ROT_XY)
;        2) Regrid on a regular grid
;        3) Rotate back to initial time (-> ROT_XY)
;        4) Interpolate over old grid (-> INTERP2D,REGULAR=1)
;
;      In the latter case, the advantage is the ability of interpolating over 
;      a regular grid (faster algorithm); the disadvantage is that two 
;      differential rotations are required. Moreover, here Pass 3 cannot be 
;      coded in one step, since for rasters there is no unique reference time 
;      to rotate back to, and, more important, Pass 2 mixes together pixels 
;      taken at different times. 
;
; Modification history:
;
;      V. Andretta,   26/Jan/1999 - Written
;      V. Andretta,   28/Feb/1999 - Added ROLL, RCENTER, REF_MAP, SPHERE 
;        keywords
;      V. Andretta,   11/Apr/1999 - Added KEEP keyword
;      V. Andretta,   20/Apr/1999 - Specified ambiguous keyword "R" in ROT_XY; 
;        fixed erroneous definition of ROLL/ROLL_CENTER kwds for arrays of maps
;      V. Andretta,   19/Jan/2001 - Informs INTERP2D that after rotation, grid 
;        is no longer uniformly spaced (REGULAR=0 was the default in an 
;        earlier version of that routine).
;        - Fixed a problem with center of grid in the presence of a roll angle.
;        - Added SAME_GRID, FULL_SIZE, and MEMSAVE keywords.
;        - Set KEEP to 1 by default.
;        - Attempts to take round-off errors into account when computing 
;          grid parameters.
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

  function DROT_RASTER,map,t_ref,REF_MAP=map_ref $
                      ,ROLL=roll_angle,RCENTER=roll_center,ADD_RDUR=add_rdur $
                      ,VERBOSE=verbose,_EXTRA=_extra,SPHERE=sphere,KEEP=keep $
                      ,FULL_SIZE=full_size,SAME_GRID=same_grid,MEMSAVE=memsave

  ON_ERROR,2


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Check input and some definitions
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  map_drot=0

  if N_PARAMS() lt 1 then begin
    PRINT,'%E> DROT_RASTER: Usage: map_drot=DROT_RASTER,map,t_ref'
    PRINT,'                    or: map_drot=DROT_RASTER,map,REF_MAP=ref_map'
    RETURN,map_drot
  endif

  if VALID_MAP(map) eq 0 then begin
    PRINT,'%E> DROT_RASTER: Input structure not a map'
    RETURN,map_drot
  endif

  Nmaps=N_ELEMENTS(map)

  verb=KEYWORD_SET(verbose)

  if N_ELEMENTS(sphere) eq 0 then sphere=1

  do_add_rdur=KEYWORD_SET(add_rdur)

  using_soho_view=SOHO_VIEW()

;% Set keyword KEEP to 1 by default
  if N_ELEMENTS(keep) eq 0 then keep=1
  keep_angles=KEYWORD_SET(keep)

;% Get reference time and roll properties from input parameters/keywords

;% Get roll values for all the maps

  map_roll=FLTARR(Nmaps)
  map_rcenter=FLTARR(2,Nmaps)

  for i=0,Nmaps-1 do begin
    UNPACK_MAP,map(i),ROLL_ANGLE=curr_roll,ROLL_CENTER=curr_rcenter
    curr_roll=FLOAT(curr_roll) mod 360
    map_roll(i)=curr_roll
    map_rcenter(*,i)=curr_rcenter
  endfor

;% Initial estimate of reference time

  GET_UTC,t0 & t0=ANYTIM2TAI(t0)

  if not VALID_MAP(map_ref) then begin

;% Estimate (or use input) reference time for rotation...

    if N_ELEMENTS(t_ref) ne 0 then begin
      errmsg=''
      t0=ANYTIM2TAI(t_ref(0),ERRMSG=errmsg)
      if errmsg ne '' then PRINT,'%W> DROT_RASTER: '+errmsg
    endif

;% ...and final roll angle and center of rotated map(s)

    if N_ELEMENTS(roll_angle) ne 0 then $
      roll=REPLICATE(FLOAT(roll_angle(0)) mod 360,Nmaps) $
    else $
      roll=map_roll

    if N_ELEMENTS(roll_center) eq 2 then $
      rcenter=TRANSPOSE([[REPLICATE(FLOAT(roll_center(0)),Nmaps)] $
                        ,[REPLICATE(FLOAT(roll_center(1)),Nmaps)]]) $
    else $
      rcenter=map_rcenter

  endif

;% Check if map represents a raster

  sz=SIZE(map(0).data)
  Nx=sz(1)
  Ny=sz(2)
  multi_time=0
  if TAG_EXIST(map(0),'START') then begin
    if N_ELEMENTS(map(0).start) ne Nx then $
      PRINT,'%W> DROT_RASTER: ' $
           +'Number of START times inconsistent with DATA 1st dimension' $
    else $
      multi_time=1
  endif


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Create new grid
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;%%%%%

  if VALID_MAP(map_ref) then begin

;% Get grid parameters from reference map; also get reference time and 
;% roll parameters

    UNPACK_MAP,map_ref(0),t0,TAG='TIME' $
              ,NX=Nxg,NY=Nyg,XC=xcg0,YC=ycg0,DX=dxg,DY=dyg $
              ,ROLL_ANGLE=roll,ROLL_CENTER=rcenter
    roll=FLOAT(roll) mod 360
    xpg0=GET_MAP_XP(map_ref(0))
    ypg0=GET_MAP_YP(map_ref(0))

;% Final roll angle for all maps

    roll=REPLICATE(roll,Nmaps)
    rcenter=TRANSPOSE([[REPLICATE(FLOAT(rcenter(0)),Nmaps)] $
                      ,[REPLICATE(FLOAT(rcenter(1)),Nmaps)]])

;%%%%%

  endif else begin

    if Nmaps gt 1 or KEYWORD_SET(same_grid) eq 0 then begin

;% Define a common grid for all the maps to be rotated

      if KEYWORD_SET(memsave) then begin

;% Define new field of view

;%%% Define current field of view

        xr=FLTARR(2,2,Nmaps) ; => first coordinate: E-W, second coordinate: N-S
        yr=FLTARR(2,2,Nmaps)
        tr=DBLARR(2,Nmaps)
;% Times of the first and last column
        if multi_time eq 1 then begin
          tr(0,*)=map.start(0)
          tr(1,*)=map.start(Nx-1)
        endif else begin
          tr(0,*)=ANYTIM2TAI(map.time)
          tr(1,*)=ANYTIM2TAI(map.time)
        endelse
;% Times and coordinates of the FOV corners
        for i=0,Nmaps-1 do begin
          xr(*,0,i)=GET_MAP_XRANGE(map(i))
          xr(*,1,i)=xr(*,0,i)
          yr(0,*,i)=GET_MAP_YRANGE(map(i))
          yr(1,*,i)=yr(0,*,i)
        endfor

;%%% Differentially rotate current field of view

        xr_drot=xr
        yr_drot=yr
        view_type=GET_MAP_PROP(map(0),/SOHO)>0
        if view_type then USE_SOHO_VIEW else USE_EARTH_VIEW
        for i=0,Nmaps-1 do begin
      ;%%% Roll back boundaries of field of view
          curr_roll=map_roll(i)
          curr_rcenter=map_rcenter(*,i)
          xr_i=xr(*,*,i)
          yr_i=yr(*,*,i)
          if curr_roll ne 0 then ROLL_XY,xr(*,*,i),yr(*,*,i) $
            ,-curr_roll,CENTER=curr_rcenter,xr_i,yr_i
          xr_drot_i=xr_i
          yr_drot_i=yr_i
      ;%%% If KEEP keyword is set, compute here P,B0,R values; these 
      ;%%% values will be passed to ROT_XY
          if keep_angles then begin
            angles=PB0R(map(i).time,SOHO=SOHO_VIEW())
            P_sun=angles(0)
            B0_sun=angles(1)
          ;% Convert solar radius to observer's distance, in units of 
          ;% solar radii
            D_sun=1./ATAN(angles(2)/(60.*!RADEG))
          endif
      ;%%% Differentially rotate field of view
          for iix=0,1 do begin
            crd=ROT_XY(xr_i(iix,*),yr_i(iix,*),TSTART=tr(iix,i),TEND=t0 $
               ,OFFLIMB=offlimb,INDEX=disk_index $
               ,BACK_INDEX=back_index $
               ,P=P_sun,B0=B0_sun,R0=D_sun,KEEP=keep_angles $
               ,SPHERE=KEYWORD_SET(sphere))
          ;% Points still on disk:
            if disk_index(0) ge 0 then begin
              xr_drot_i(iix,disk_index)=crd(disk_index,0)
              yr_drot_i(iix,disk_index)=crd(disk_index,1)
            endif
          ;% Points which have rolled over behind the limb: leave them where 
          ;% they crossed the limb
            if back_index(0) ge 0 then begin
            ;% Compute latitude of points behind the visible disk
              lat=ARCMIN2HEL(xr_i(iix,back_index)/60,yr_i(iix,back_index)/60 $
                            ,DATE=tr(iix,i),SOHO=SOHO_VIEW() $
                            ,P=P_sun,B0=B0_sun,R0=D_sun $
                            ,SPHERE=KEYWORD_SET(sphere))
              lat=lat(0,*)
            ;% If not done already, compute solar B0
              if keep_angles eq 0 then begin
                angles=PB0R(tr(iix,i),SOHO=SOHO_VIEW())
                B0_curr=angles(1)
              endif else $
                B0_curr=B0_sun
            ;% Longitude of the limb at each latitude (would be 180 degrees 
            ;% if B0=0)
              lon_limb=-TAN(B0_curr/180.*!DPI)*TAN(lat/180.*!DPI)
              good_val=WHERE(ABS(lon_limb) le 1,Ngood_val)
              if Ngood_val gt 0 then begin
                lon_limb(good_val)=ACOS(lon_limb(good_val))/!DPI*180.
              ;% Transform new coordinates back to cartesian
                arc=HEL2ARCMIN(lat(good_val),lon_limb(good_val) $
                            ,DATE=tr(iix,i),SOHO=SOHO_VIEW() $
                            ,P=P_sun,B0=B0_sun,R0=D_sun)*60
                xr_drot_i(iix,back_index(good_val))=arc(0,*)
                yr_drot_i(iix,back_index(good_val))=arc(1,*)
              endif
            endif
          endfor
      ;%%% Return FOV coordinates to original roll angle
          if curr_roll ne 0 then ROLL_XY,xr_drot_i,yr_drot_i $
            ,+curr_roll,CENTER=curr_rcenter,xr_drot_i,yr_drot_i
          xr_drot(*,*,i)=xr_drot_i
          yr_drot(*,*,i)=yr_drot_i
        endfor
        if using_soho_view then USE_SOHO_VIEW else USE_EARTH_VIEW

;%%% New field of view

        if KEYWORD_SET(full_size) then begin
          x1=MIN(xr_drot(0,*,*))
          x2=MAX(xr_drot(1,*,*))
          y1=MIN(yr_drot(*,0,*))
          y2=MAX(yr_drot(*,1,*))
        endif else begin
          x1=MAX(xr_drot(0,*,*))
          x2=MIN(xr_drot(1,*,*))
          y1=MAX(yr_drot(*,0,*))
          y2=MIN(yr_drot(*,1,*))
        endelse

      endif else begin

;%%% Define array of rotated coordinates

        xp_drot=MAKE_ARRAY(Nx,Ny,Nmaps,TYPE=SIZE(GET_MAP_XP(map(0)),/TYPE))
        yp_drot=xp_drot

;%%% Rotate coordinates for all the rasters in the array

        for i=0,Nmaps-1 do begin
          xyr=DROT_COORD(map(i),t0,VERBOSE=verb,SPHERE=KEYWORD_SET(sphere) $
                        ,KEEP=keep_angles)
          xp_drot(*,*,i)=xyr(*,*,0)
          yp_drot(*,*,i)=xyr(*,*,1)
          xyr=0
        endfor

;%%% New field of view

        if KEYWORD_SET(full_size) then begin
          x1=MIN(xp_drot(  0 ,  * ,*))
          x2=MAX(xp_drot(Nx-1,  * ,*))
          y1=MIN(yp_drot(  * ,  0 ,*))
          y2=MAX(yp_drot(  * ,Ny-1,*))
        endif else begin
          x1=MAX(xp_drot(  0 ,  * ,*))
          x2=MIN(xp_drot(Nx-1,  * ,*))
          y1=MAX(yp_drot(  * ,  0 ,*))
          y2=MIN(yp_drot(  * ,Ny-1,*))
        endelse

      endelse

;% Define new grid

    ;% Machine-specific "Floating-point precision"

      eps=(MACHAR(DOUBLE=SIZE(x1,/TYPE) eq 5)).eps

    ;% New pixel size

      dxg=MIN(map.dx)
      dyg=MIN(map.dy)

    ;% New image size

      if KEYWORD_SET(full_size) then begin
        Nxg=CEIL(((x2-x1)/dxg+1)*(1-2*eps))>1
        Nyg=CEIL(((y2-y1)/dyg+1)*(1-2*eps))>1
      endif else begin
        Nxg=FLOOR(((x2-x1)/dxg+1)*(1+2*eps))>1
        Nyg=FLOOR(((y2-y1)/dyg+1)*(1+2*eps))>1
      endelse

    ;% New center

      xc=0.5*(x1+x2)
      x0=xc-0.5*(Nxg-1)*dxg
      yc=0.5*(y1+y2)
      y0=yc-0.5*(Nyg-1)*dyg

    ;% New grid

      xpg0=(x0+dxg*FINDGEN(Nxg))#REPLICATE(1,Nyg)
      ypg0=REPLICATE(1,Nxg)#(y0+dyg*FINDGEN(Nyg))

      xcg0=GET_ARR_CENTER(xpg0)
      ycg0=GET_ARR_CENTER(ypg0)

    endif else begin

;% Just use current grid

      UNPACK_MAP,map(0),NX=Nxg,NY=Nyg,XC=xcg0,YC=ycg0,DX=dxg,DY=dyg

      xpg0=GET_MAP_XP(map(0))
      ypg0=GET_MAP_YP(map(0))

    endelse

  endelse

;%%% New START times

  tpg=REPLICATE(t0,Nxg)


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Define new map(s)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;% Create template map
  map_drot0=map(0)
  data_drot=MAKE_ARRAY(DIM=[Nxg,Nyg],VALUE=map(0).data(0))
  map_drot0=REP_TAG_VALUE(map_drot0,data_drot,'DATA')         ; DATA
  map_drot0.xc=xcg0                                           ; XC
  map_drot0.yc=ycg0                                           ; YC
  map_drot0.dx=dxg                                            ; DX
  map_drot0.dy=dyg                                            ; DY
  map_drot0=REP_TAG_VALUE(map_drot0,tpg,'START')              ; START
  rtime=ANYTIM2CAL(t0,FORM=9)                                 ; RTIME
  if TAG_EXIST(map_drot0,'RTIME') then $
    map_drot0=REP_TAG_VALUE(map_drot0,rtime,'RTIME') $
  else $
    ADD_PROP,map_drot0,RTIME=rtime
  if do_add_rdur then begin                                   ; RDUR 
    rdur=DOUBLE(data_drot)
    if TAG_EXIST(map_drot0,'RDUR') then $
      map_drot0=REP_TAG_VALUE(map_drot0,TEMPORARY(rdur),'RDUR') $
    else $
      ADD_PROP,map_drot0,RDUR=TEMPORARY(rdur)
  endif
  if TAG_EXIST(map_drot0,'ROLL') then $                       ; ROLL
    map_drot0=REP_TAG_VALUE(map_drot0,roll(0),'ROLL') $
  else $
    ADD_PROP,map_drot0,ROLL=roll(0)
  if TAG_EXIST(map_drot0,'ROLL_CENTER') then $                ; ROLL_CENTER
    map_drot0=REP_TAG_VALUE(map_drot0,rcenter(*,0),'ROLL_CENTER') $
  else $
    ADD_PROP,map_drot0,ROLL_CENTER=rcenter(*,0)
;% Replicate template map to create the output map(s)
  map_drot=REPLICATE(map_drot0,Nmaps)
  map_drot0=0
  map_drot.roll=roll
  map_drot.roll_center=rcenter
;% Copy all other tags into the new map(s)
  name=TAG_NAMES(map)
  if do_add_rdur then begin
    others=WHERE(name ne 'DATA'        $
             and name ne 'XC'          $
             and name ne 'YC'          $
             and name ne 'DX'          $
             and name ne 'DY'          $
             and name ne 'START'       $
             and name ne 'RTIME'       $
             and name ne 'RDUR'        $
             and name ne 'ROLL'        $
             and name ne 'ROLL_CENTER' $
                ,N_others)
  endif else begin
    others=WHERE(name ne 'DATA'        $
             and name ne 'XC'          $
             and name ne 'YC'          $
             and name ne 'DX'          $
             and name ne 'DY'          $
             and name ne 'START'       $
             and name ne 'RTIME'       $
             and name ne 'ROLL'        $
             and name ne 'ROLL_CENTER' $
                ,N_others)
  endelse
  for itag=0,N_others-1 do map_drot.(others(itag))=map.(others(itag))


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% Differentially rotating map data
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for i=0,Nmaps-1 do begin

;% Rotate coordinates

    if VALID_MAP(map_ref) eq 0 $
       and (Nmaps gt 1 or KEYWORD_SET(same_grid) eq 0) $
       and KEYWORD_SET(memsave) eq 0 then begin
      xpr=xp_drot(*,*,i)
      ypr=yp_drot(*,*,i)
    endif else begin
      xyr=DROT_COORD(map(i),t0,VERBOSE=verb,SPHERE=KEYWORD_SET(sphere) $
                    ,KEEP=keep_angles)
      xpr=xyr(*,*,0)
      ypr=xyr(*,*,1)
      xyr=0
    endelse

;% Roll back coordinates to zero roll angle

    if map_roll(i) ne 0 then $
      ROLL_XY,xpr,ypr,-map_roll(i),CENTER=map_rcenter(*,i),xpr,ypr

;% Roll new coordinates to the final angle

    xpg=xpg0
    ypg=ypg0
    if roll(i) ne 0 then $
      ROLL_XY,xpg,ypg,-roll(i),CENTER=rcenter(*,i),xpg,ypg

;% Resample data

    if verb then PRINT,'%I> DROT_RASTER: Resampling data array...'
    map_drot(i).data=INTERP2D(map(i).data,xpr,ypr,xpg,ypg,[Nx,Ny] $
                             ,REGULAR=0,_EXTRA=_extra)

;% Estimate rotation interval on a pixel-by-pixel basis;
;% N.B.: no fancy interpolation keywords used here (_extra keywords); only 
;% using here keyword EXTRAPOLATE.
    if do_add_rdur then begin
      if multi_time then $
        dt=t0-map(i).start $
      else $
        dt=REPLICATE(t0-ANYTIM2TAI(map(i).time),Nx)
      dt=dt#REPLICATE(1,Ny)
      map_drot(i).rdur=INTERP2D(dt,xpr,ypr,xpg,ypg,[Nx,Ny] $
                               ,REGULAR=0,/EXTRAP)
    endif

  endfor


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%% End
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  RETURN,map_drot
  END



