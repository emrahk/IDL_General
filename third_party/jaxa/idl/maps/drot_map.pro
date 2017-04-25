;+
; Project     : SOHO-CDS
;
; Name        : DROT_MAP
;
; Purpose     : Differentially rotate image contained within structure created by MAKE_MAP
;               Can also project image to different orbital angles
; Category    : imaging
;
; Syntax      : rmap=drot_map(map,duration)
;
; Inputs      : MAP = map structure
;               DURATION = hours to rotate by
;
; Outputs     : RMAP = map with projected coordinates
;
; Keywords    : SECONDS = duration units in seconds
;               TIME = time to rotate image to (can be a MAP or INDEX stc)
;               NO_REMAP = don't remap image data (just compute
;               project coords)
;               NO_DATA = same as NO_REMAP, but just return without DATA
;               DAYS = specify duration units in days
;               TAG_ID = tag name or index to project
;               RCENTER = [rxc,ryc] = new rotation center of output
;               image (if rolling)
;               PROJ_RCENTER = project roll center 
;               (used mainly for partial images rolled about center) 
;               TRANS = [xs,ys] = translation of output image [+N, +W]
;               RESOLUTION = [dx,dy] = spacing of output image
;               OUTSIZE  = [nx,ny] = size of output image. Resolution
;               is adjusted proportionally (unless /PRESERVE_AREA is set)
;               ROLL  = new roll of output image. 
;               KEEP_LIMB = keep limb points when projecting [def is
;               not keep)
;               MISSING = values to set unrotatable (e.g. off limb) points
;               CENTER = [xc,yc] = new center of output image coords
;               REF_MAP = reference image to map to. 
;                         If entered, then TIME, SPACING, ROLL are inherited
;               FAST = set when one wants to solely shift the entire FOV 
;                      without correcting for the latitudinal dependence of 
;                      the solar differential rotation function.
;                      USE WITH CARE! - results are only meaningful for small
;                      rotation intervals of a few hours for images within
;                      10-20 degrees of the equator.
;               UNROTATED = indicies of unprojected pixels
;               SAME_CENTER = keep center of output image same as input
;                             [def is to shift to new center]
;               NO_DROTATE = skip diff. rotation part
;               NO_PROJECT = skip angle projection part
;               RIGID = rotate as rigid body
;               DEGREES = duration is in units of degrees
;               TRACK_CENTER = set to track center of the output image to where the 
;                         center of the input image is rotated to. 
;                         The default is to center the output image on the 
;                         center of the rotated field of view.
;                         This makes a non-subtle difference for full and 
;                         partial FOV images.
;               PRESERVE_AREA = set to increase (or decrease) number of 
;                         output image pixels to preserve input image 
;                         area. Default is to keep original input number
;                         of pixels.
;               ADJUST_RESOLUTION = set to increase (or decrease) resolution of 
;                         output image pixels to preserve input image dimensions.
;                         Default is to keep original input resolution.
;               B0, L0, RSUN = solar B angle (deg), 
;                         heliographic angle (deg) offset, and
;                         solar radius (arcsecs) of output image
;               NO_ROLL_CORRECT = inhibit correcting for roll
;
; History     : Written 22 November 1997, D. Zarro, SAC/GSFC
;               Modified 27 Sept 1999, Zarro (SM&A/GSFC) -- removed
;               SOHO view correction (now handled by MAP2SOHO)
;               9-Feb-2000, Zarro (SM&A/GSFC) -- added correction
;               for solar rotation of roll center when in fov
;               9 Jan 2001, Kim Tolbert - made onx and ony longwords so onx*ony 
;                 won't overflow
;               20 Aug 2001, Zarro (EITI/GSFC) - added /keep_center and optimized
;               memory
;               21 Aug 2001, Zarro (EITI/GSFC) - added ability to retain 
;               limb pixels for good buddy GLS
;               22 Feb 2003, Zarro (EER/GSFC) - added /RIGID
;               11 Mar 2003, Zarro (EER/GSFC) - added /DEGREES
;               23 Nov 2003, Zarro (L-3/GSFC) - added check for roll values
;                less than 1 degree. Treat these as effectively 0 degree roll.
;               18 May 2004, Zarro (L-3Com/GSFC) - added /TRACK_CENTER, /PRESERVE_AREA
;                8 Jun 2004, Zarro (L-3Com/GSFC) - added XRANGE/YRANGE
;                8 Jan 2005, Zarro (L-3Com/GSFC) - added B0
;                9 Mar 2005, Zarro (L-3Com/GSFC) - added check for integer data
;               10 Oct 2007, Zarro (ADNET) 
;                - added B0, L0, and RSUN to support STEREO
;               20 Nov 2007, Zarro (ADNET)
;                - added PROJ_RCENTER and made /KEEP_CENTER not the default
;               8  Feb 2008, Zarro (ADNET)
;                - added /KEEP_LIMB to keep limb points
;               22 August 2008, Zarro (ADNET) 
;                - added /NO_ROLL_CORRECT
;               16 September 2008, Zarro (ADNET)
;                - added call to GET_MAP_ANGLES
;                - fixed bug in OUTSIZE in which output pixel resolution was not
;                  set correctly
;               30 September 2008, Zarro (ADNET)
;                - improved memory management
;               18 Jan 2009, Zarro (ADNET)
;                - call MERGE_STRUCT to error-proof combining maps
;                  with different data types.
;               18 Mar 2009, Zarro (ADNET)
;                - added /ADJUST_RESOLUTION
;               23 March 2009, Zarro (ADNET)
;                - added checks for NaN's
;               31 May 2010, Zarro (ADNET)
;                - changed /KEEP_CENTER to /SAME_CENTER
;                - fixed correction for off-limb scaling when
;                  projecting
;               12 June 2012, Zarro (ADNET)
;                - preserved input data type
;               13 May 2014, Zarro (ADNET)
;                - minor fix to use correct B0 and RSUN for projected
;                  time
;               11 June 2014, Zarro (ADNET)
;                - skipped using orbital parameters if not
;                  reprojecting.
;               22 October 2014, Zarro (ADNET)
;                - use double-precison arithmetic
;                1 December 2014, Zarro (ADNET)
;                - added logic for rescaling different RSUN
;               10 December 2014, Zarro (ADNET)
;                - restored adding RTIME even if not drotating
;               2 March 2014, Zarro (ADNET)
;                - added /DOUBLE to INTERP2D
;               23 March 2014, Zarro (ADNET)
;                - added check for rolling about different centers
;               24 November 2015, Zarro (ADNET)
;               - changed CENTER to RCENTER to avoid clash with image center
;
; Contact     : dzarro@solar.stanford.edu
;-

function drot_map,map,duration,_extra=extra,proj_rcenter=proj_rcenter,$
                  time=time,no_remap=no_remap,err=err,ilimb=ilimb,$
                  verbose=verbose,trans=trans,resolution=resolution,$
                  tag_id=tag_id,roll=roll,fast=fast,$
                  rcenter=rcenter,center=center,keep_limb=keep_limb,$
                  unrotated=unrotated,no_drotate=no_drotate,$
                  ref_map=ref_map,outsize=outsize,same_center=same_center,$
                  degrees=degrees,track_center=track_center,$
                  preserve_area=preserve_area,adjust_resolution=adjust_resolution,xrange=xrange,yrange=yrange,$
                  b0=b0,l0=l0,rsun=rsun,xp=xp,yp=yp,no_project=no_project,$
                  no_data=no_data,olimb=olimb,no_roll_correct=no_roll_correct

if ~valid_map(map) then begin
 pr_syntax,'rmap=drot_map(map,duration,[time=time])'
 return,-1
endif

deg_per_day=diff_rot(1,0,/synod,_extra=extra)
sec_per_day=24.*3600.
sec_per_deg=sec_per_day/deg_per_day

if keyword_set(degrees) then begin
 if ~exist(duration) then begin
  message,'Enter amount of rotation in degrees',/cont
  dur='' & read,'-> ',dur
  duration=float(dur)
 endif
 tdur=24.*duration/deg_per_day
endif else begin
 if exist(duration) then tdur=duration
endelse

;-- FAST option

if keyword_set(fast) then $
 return,drot_map_fast(map,tdur,_extra=extra)

;-- check keywords

verbose=keyword_set(verbose)
proj_rcenter=keyword_set(proj_rcenter)
same_center=keyword_set(same_center)
no_drotate=keyword_set(no_drotate)
preserve_area=keyword_set(preserve_area)
adjust_resolution=keyword_set(adjust_resolution)
track_center=keyword_set(track_center)
if preserve_area || adjust_resolution then track_center=0b
remap=~keyword_set(no_remap)
no_data=keyword_set(no_data)
keep_limb=keyword_set(keep_limb)

;-- if REF_MAP entered then use it's TIME, SPACING, CENTER, ROLL, and
;    DIMENSIONS

case 1 of
 valid_map(ref_map): begin
  etime=get_map_time(ref_map[0],/tai)
  unpack_map,ref_map[0],xc=xc,yc=yc,dx=dx,dy=dy,$
   nx=nx,ny=ny,roll_center=droll_center,roll_angle=droll,/no_data
  dspace=[dx,dy]
  dcenter=[xc,yc]
  dsize=[nx,ny]
 end
 valid_time(time): etime=anytim2tai(time)
 valid_map(time): etime=get_map_time(time,/tai)
 else:continue=1
endcase

;-- get solar rotation duration

dtime=get_drot_dur(map,tdur,time=etime,_extra=extra)
cur_time=get_map_time(map,/tai)
 
;-- translate after rotation?

xs=0.d0 & ys=0.d0
do_trans=n_elements(trans) eq 2
if do_trans then begin
 xs=trans[0] & ys=trans[1]
 do_trans=(xs ne 0.) || (ys ne 0.)
endif

tags=tag_names(map) & ntags=n_elements(tags) & nmp=n_elements(map)
have_roll_center=have_tag(map,'roll_center')
ntime=n_elements(dtime)

sub_range=valid_range(xrange) && valid_range(yrange)

;-- input data type is less than float, then make it float for better
;   precision

for i=0,nmp-1 do begin
 pmap=map[i]

;-- check if differentially rotating

 cdur=dtime[i < (ntime-1)]
 if no_drotate then cdur=0.
 dprint,'% duration (sec): ',cdur
 new_time=cur_time[i]+cdur
 do_drot=(new_time ne cur_time[i])

 if do_drot && (cdur gt 180*sec_per_deg) then begin
  message,'Warning, most of Sun will rotate over limb',/cont
 endif

;-- get start and end projection angles
;-- override with b0, l0, or rsun entered as keywords

 pstart=get_map_angles(pmap,verbose=verbose)
 pend=pstart
 if do_drot then pend=get_map_angles(pmap.id,new_time)
 if valid_map(ref_map) then pend=get_map_angles(ref_map)
 if is_number(b0) then pend.b0=b0
 if is_number(l0) then pend.l0=l0
 if is_number(rsun) then pend.rsun=rsun
 do_proj=~match_struct(pstart,pend) && ~keyword_set(no_project) 

;--- if not projecting, ensure that different RSUN perspectives match

 do_rad=0b
 if ~do_proj && have_tag(pmap,'rsun') then begin
  rat=pend.rsun/pstart.rsun
  if rat ne 1. then begin
   dprint,'% rat: ',rat
   dprint,'% adjusting for different distance perspectives'
   pmap.dx=pmap.dx*rat
   pmap.dy=pmap.dy*rat
   pmap.xc=pmap.xc*rat
   pmap.yc=pmap.yc*rat
   pmap.roll_center=pmap.roll_center*rat
   pmap.rsun=pend.rsun 
   do_rad=1b
  endif
 endif

;-- extract the map data

 if sub_range then begin
  err=''
  sub_map,pmap,pmap,xrange=xrange,yrange=yrange,err=err
  if is_string(err) then continue
 endif 

 unpack_map,pmap,pdata,xp,yp,err=err,dx=dx,dy=dy,$
          nx=nx,ny=ny,roll_angle=curr_roll,xc=xc,yc=yc,roll_center=curr_rcenter,$
          xrange=pxrange,yrange=pyrange,/no_data
 
;-- check if rolling

 have_roll=((curr_roll mod 360.0) ne 0.) 
 new_roll=curr_roll

 if exist(droll) then new_roll=droll
 if exist(roll) then new_roll=double(roll)
 roll_diff=new_roll-curr_roll

 do_roll=~keyword_set(no_roll_correct) && ( (roll_diff mod 360.) ne 0.)
 new_roll=curr_roll+roll_diff
; if verbose && (i eq 0) then begin
;  if have_roll then $
;   message,'correcting old '+trim(string(curr_roll))+' degree roll',/cont
;  if do_roll then $
;   message,'applying new '+trim(string(new_roll))+' degree roll',/cont
; endif

;-- check if new roll center

 new_rcenter=curr_rcenter
 if n_elements(droll_center) eq 2 then new_rcenter=double(droll_center)
 if n_elements(rcenter) eq 2 then new_rcenter=double(rcenter)
 do_rcenter=0b
 if (do_roll && have_roll) then begin
  do_rcenter=((new_rcenter[0] ne curr_rcenter[0]) || $
              (new_rcenter[1] ne curr_rcenter[1]))
 endif

;-- check if recentering 
;  (if an array of images, then track relative to first)

 do_center=0
 if (i eq 0) && (nmp gt 1) then new_center=double([xc,yc])
 if n_elements(dcenter) eq 2 then new_center=double(dcenter)
 if n_elements(center) eq 2 then new_center=double(center)
 if exist(new_center) then $
  do_center=(new_center[0] ne xc) || (new_center[1] ne yc)

;-- check if resizing

 if i eq 0 then new_size=double([nx,ny])
 if n_elements(dsize) eq 2 then new_size=dsize
 if n_elements(outsize) eq 2 then new_size=double(outsize)
 do_resize=(new_size[0] ne nx) || (new_size[1] ne ny) || preserve_area
  
;-- check if rebinning

 if i eq 0 then new_space=[dx,dy]
 if do_resize then begin
  new_space[0]=dx*double(nx)/double(new_size[0])
  new_space[1]=dy*double(ny)/double(new_size[1])
 endif
 if n_elements(dspace) eq 2 then new_space=double(dspace)
 if n_elements(resolution) eq 1 then new_space=double([resolution,resolution])
 if n_elements(resolution) eq 2 then new_space=double(resolution)

 do_rebin=(new_space[0] ne dx) || (new_space[1] ne dy) || adjust_resolution

 dprint,'%do_drot: ', do_drot
 dprint,'%do_proj: ', do_proj
 dprint,'%do_rebin: ', do_rebin
 dprint,'%do_roll: ', do_roll
 dprint,'%do_center: ', do_center
 dprint,'%do_trans: ', do_trans
 dprint,'%do_rcenter ',do_rcenter
 dprint,'%do_resize: ',do_resize
 dprint,'%do_rad: ',do_rad

 onx=long(new_size[0]) & ony=long(new_size[1])
 if ~have_tag(pmap,'roll_angle') then pmap=add_tag(pmap,0.,'roll_angle',index='id',/no_copy)
 if ~have_roll_center then pmap=add_tag(pmap,[xc,yc],'roll_center',index='roll_angle',/no_copy)

 if verbose then begin
  help,/st,anytim2utc(cur_time[i],/vms),pstart
  help,/st,anytim2utc(new_time,/vms),pend
  help,curr_roll,new_roll
  print,'CURR_RCENTER',curr_rcenter
  print,'NEW_RCENTER',new_rcenter
 endif

 if ~do_proj && ~do_drot && $
    ~do_rcenter && ~do_trans && $
    ~do_rebin && ~do_roll && $
    ~do_center && ~do_resize && ~do_rad then begin
  if no_data then return,-1
  message,'Nothing to do!',/cont
  goto,done
 endif

;-- get the before and after solar radii since we will need these to
;   flag offlimb points when rotating or projecting.

 if do_proj || do_drot then begin
  sol_rad1=pstart.rsun
  sol_rad2=pend.rsun
  sol_rat=sol_rad1/sol_rad2
 endif

 if do_roll then begin
  pmap.roll_angle=new_roll
  pmap.roll_center=new_rcenter
 endif else begin
  if have_roll then begin
   pmap.roll_angle=curr_roll

;-- if image is rolled and roll-center is within image, then
;   project roll-center if /proj_rcenter

   roll_in_image= ((curr_rcenter[0] le max(pxrange)) && $
                   (curr_rcenter[0] ge min(pxrange))) || $
                  ((curr_rcenter[1] le max(pyrange)) && $
                   (curr_rcenter[1] ge min(pyrange)))
   if roll_in_image && (do_proj || do_drot) && proj_rcenter then begin
    if verbose && (i eq 0)  then message,'projecting roll center',/cont
    temp=rot_xy(curr_rcenter[0],curr_rcenter[1],tstart=cur_time[i],$
         tend=new_time,_extra=extra,/sphere,$
         vstart=pstart,vend=pend)
    drot_rcenter=reform(temp)
   endif else drot_rcenter=curr_rcenter
   pmap.roll_center=drot_rcenter
  endif
 endelse

;-- correct current roll before projecting

 xr=xp & yr=yp
 if have_roll then roll_xy,xr,yr,-curr_roll,xr,yr,rcenter=curr_rcenter
 
;-- flag offlimb pixels

 icount=0 & ocount=0 & olimb=-1 & fsize=long(nx)*long(ny) & fcount=fsize
 ilimb=-1
 if do_proj || do_drot then begin
  rad1=sqrt(xr^2+yr^2)
  ilimb=where(rad1 gt sol_rad1,icount)
  if icount eq fcount then begin
   err='All points off limb, cannot project'
   mprint,err
   if no_data then return,-1 
   goto,done
  endif
 
;-- apply solar rotation/projection

  xr=reform(temporary(xr),fsize)
  yr=reform(temporary(yr),fsize)
  rcor=rot_xy(xr,yr,tstart=cur_time[i],tend=new_time,$
              _extra=extra,/sphere,vstart=pstart,vend=pend,err=err)
  if is_string(err) then begin
   mprint,err
   if no_data then return,-1 
   goto,done
  endif
  sz=size(rcor)
  if sz[2] eq 2 then rcor=transpose(temporary(rcor))
 
  xr=reform(rcor[0,*],nx,ny)
  yr=reform(rcor[1,*],nx,ny)

;-- flag pixels that projected over limb

  rad2=sqrt(xr^2+yr^2)
  olimb=where(rad2 gt sol_rad2,ocount)
  if ocount eq fsize then begin
   err='All points projected off limb'
   mprint,err
   if no_data then return,-1 
   goto,done
  endif

;-- determine valid pixels still on disk

  fov=where( ((rad1 le sol_rad1) and (rad2 le sol_rad2)),fcount)
   
  if fcount eq 0 then begin
   err='All points projected outside original FOV'
   mprint,err
   if no_data then return,-1 
   goto,done
  endif

 endif

;-- apply translation

 xr=temporary(xr)+xs
 yr=temporary(yr)+ys

;-- apply roll
  
 if do_roll then roll_xy,xr,yr,new_roll,xr,yr,rcenter=new_rcenter else $
  if have_roll then roll_xy,xr,yr,curr_roll,xr,yr,rcenter=drot_rcenter

;-- return if just need coordinates
 
 if no_data then begin
  xp=temporary(xr)
  yp=temporary(yr)
  return,-1
 endif

;-- update map properties 
;   (if not remapping pixels, save in old format to preserve irregular 
;    coordinates)

 if ~remap then pmap=mk_map_old(pmap)
 pmap=repack_map(pmap,xr,yr,/no_copy)
  
;-- remap image

 if remap then begin

;-- first make a regularized grid using only pixels that are still in fov
;   (i.e. limb pixels and disk pixels that haven't projected over limb)

  if same_center then new_center=get_map_prop(map[i],/center)

;-- track FOV center 

  if track_center && (do_proj || do_drot) then begin
   xcen=xc  & ycen=yc
   if have_roll then roll_xy,xcen,ycen,-curr_roll,xcen,ycen,rcenter=curr_rcenter
   ncenter=rot_xy(xcen,ycen,tstart=cur_time[i],tend=new_time,$
           _extra=extra,/sphere,$
           vstart=pstart,vend=pend)
   ncenter=reform(ncenter)
   xcen=ncenter[0] & ycen=ncenter[1]
   if do_roll then roll_xy,xcen,ycen,new_roll,xcen,ycen,rcenter=new_rcenter else $
    if have_roll then roll_xy,xcen,ycen,curr_roll,xcen,ycen,rcenter=drot_rcenter
   new_center=[xcen,ycen]
  endif

  if (fcount lt fsize) && exist(fov) then begin
   xr=xr[fov] & yr=yr[fov]
  endif
  grid_xy,xr,yr,gx,gy,space=new_space,center=new_center,size=new_size,$
                      preserve_area=preserve_area,adjust_resolution=adjust_resolution

  onx=new_size[0] & ony=new_size[1]
  do_resize=(onx ne nx) || (ony ne ny)

;-- project grid points back to find where each point came from

  pmap=repack_map(pmap,gx,gy,/no_copy)
  xr=temporary(gx)
  yr=temporary(gy)

;-- roll back 

  if do_roll then roll_xy,xr,yr,-new_roll,xr,yr,rcenter=new_rcenter else $
   if have_roll then roll_xy,xr,yr,-curr_roll,xr,yr,rcenter=drot_rcenter

;-- shift back

  xr=temporary(xr)-xs
  yr=temporary(yr)-ys

;-- project backwards

  icount2=0 & ocount2=0

  if do_proj || do_drot then begin

;-- flag projected limb pixels 

   rad2=sqrt(xr^2+yr^2)
   olimb2=where(rad2 gt sol_rad2,ocount2)
   if keep_limb && (ocount2 gt 0) then begin
    xlimb=xr[olimb2]
    ylimb=yr[olimb2]
   endif

   xr=reform(temporary(xr),onx*ony)
   yr=reform(temporary(yr),onx*ony)
   rcor=rot_xy(xr,yr,tstart=new_time,tend=cur_time[i],$
               _extra=extra,/sphere,vstart=pend,vend=pstart,err=err)
   if is_string(err) then begin
    mprint,err
    goto,done
   endif
   sz=size(rcor)
   if sz[2] eq 2 then rcor=transpose(temporary(rcor))
   xr=reform(rcor[0,*],onx,ony)
   yr=reform(rcor[1,*],onx,ony)

   if keep_limb && (ocount2 gt 0) then begin
    xr[olimb2]=xlimb*sol_rat
    yr[olimb2]=ylimb*sol_rat
   endif
 
  endif

;-- roll back to initial roll

  if have_roll then roll_xy,xr,yr,curr_roll,xr,yr,rcenter=curr_rcenter

;-- remap here

  find=where(finite(pmap.data,/nan),ncount)
  if ncount gt 0 then begin
   if verbose then message,'Setting NaNs to zero',/cont
   pmap.data[find]=0.
;   xp[find]=-999999.
;   yp[find]=-999999.
  endif

  temp=interp2d(pmap.data,xp,yp,xr,yr,_extra=extra,missing=0,/double)  
  chk=array_equal(size(temp),size(pmap.data))
  if chk then pmap.data=temporary(temp) else $
   pmap=rep_tag_value(pmap,temp,'data',/no_copy) 

  if do_proj || do_drot then begin
   dmin=min(pmap.data,max=dmax)
   if (dmin eq dmax) && (dmin eq 0.) then begin
    err='Image projected out of field of view'
    mprint,err
   endif
  endif
 endif

done:

;-- make sure all map tags are ok

 rtime=get_map_time(pmap)
 if do_drot then rtime=strtrim(anytim2utc(new_time,/vms),2)
 if is_struct(pend) && do_proj then begin
  if have_tag(pmap,'b0') then pmap.b0=pend.b0 else pmap=add_tag(pmap,pend.b0,'b0',/no_copy) 
  if have_tag(pmap,'l0') then pmap.l0=pend.l0 else pmap=add_tag(pmap,pend.l0,'l0',/no_copy) 
  if have_tag(pmap,'rsun') then pmap.rsun=pend.rsun else pmap=add_tag(pmap,pend.rsun,'rsun',index='b0',/no_copy) 
 endif
 if have_tag(pmap,'rtime') then pmap.rtime=rtime else pmap=add_tag(pmap,rtime,'rtime',/no_copy)
 rmap=merge_struct(rmap,pmap,/no_copy)
endfor

if exist(olimb2) then olimb=temporary(olimb2)
delvarx,xp,yp,xr,yr,gx,gy,rad2,rad1
delvarx,ilimb2,pmap

if ~valid_map(rmap) then rmap=-1

return,rmap & end
