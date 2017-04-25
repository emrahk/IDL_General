;+
; Project     : SOHO-CDS
;
; Name        : DROT_XY
;
; Purpose     : wrapper around ROT_XY to correct for roll in map
;
; Category    : imaging
;
; Explanation : for rolled images, coordinates have to be corrected
;               before applying solar rotation correction
;
; Syntax      : drot_xy,xp,yp,tstart,tend,xr,yr,roll_angle=roll_angle,soho=soho
;
; Inputs      : XP,YP = input arrays to solar rotate
;               TSTART,TEND = start/end time for rotation
;
; Outputs     : XR,YR = solar rotated coordinate arrays
;
; Keywords    : ERR = error string
;               VERBOSE = print messages
;               ROLL_ANGLE = roll angle [+ degrees clockwise]
;               ROLL_CENTER = roll center
;               VIEW =  set for L1 view
;               NO_COPY = don't create new memory copies of xp,yp
;               NO_ROLL = don't roll correct
;
; History     : Written 15 Feb 1999, D. Zarro, SM&A/GSFC
;               Modified 24 November 2015, Zarro (ADNET)
;               - changed CENTER to RCENTER to avoid clash with image center
;
; Contact     : dzarro@solar.stanford.edu
;-


pro drot_xy,xp,yp,tstart,tend,xr,yr,err=err,no_copy=no_copy,$
                verbose=verbose,roll_angle=roll_angle,roll_center=roll_center,$
                view=view,off_limb=off_limb,no_roll=no_roll

err=''

verbose=keyword_set(verbose)
no_copy=keyword_set(no_copy)

;-- check inputs

if ~exist(xp) or ~exist(yp) then begin
 pr_syntax,'drot_xy,xp,yp,tstart,tend,xr,yr [,roll_angle=roll_angle]'
 err='input error'
 return
endif

dstart=anytim2tai(tstart,err=err)
if err ne '' then begin
 message,err,/cont
 return
endif

dend=anytim2tai(tend,err=err)
if err ne '' then begin
 message,err,/cont
 return
endif

if verbose then begin
 hrs=(dend-dstart)/3600.
 message,'rotating '+num2str(hrs)+' hours',/cont
endif

if no_copy then begin
 xr=copy_var(xp) & yr=copy_var(yp)
endif else begin
 xr=xp & yr=yp
endelse

if dstart eq dend then begin
 message,'zero duration, no need to solar rotate',/cont
 return
endif

;-- correct for non-zero roll in map before solar rotating 

rflag=0
do_roll=~keyword_set(no_roll)
if exist(roll_angle) and do_roll then begin
 if roll_angle ne 0. then begin
  if verbose then message,'correcting for '+num2str(roll_angle)+' deg roll',/cont
  roll_xy,xr,yr,-roll_angle,xr,yr,rcenter=roll_center
  rflag=1
 endif
endif

;-- now do the rotation

nx=data_chk(xr,/nx) > 1
ny=data_chk(yr,/ny) > 1
xr=reform(temporary(xr),nx*ny)
yr=reform(temporary(yr),nx*ny)

rcor=rot_xy(xr,yr,tstart=dstart,tend=dend,soho=view)

sz=size(rcor)
if sz[2] eq 2 then rcor=transpose(temporary(rcor))
 
;-- update pixel arrays  

if ny gt 1 then xr=reform(rcor[0,*],nx,ny) else xr=reform(rcor[0,*],nx)
if nx gt 1 then yr=reform(rcor[1,*],nx,ny) else yr=reform(rcor[1,*],ny)

pr=pb0r(dend,soho=view,/arcsec)
radius=double(pr[2])

if arg_present(off_limb) then begin
 off_limb=where_off_limb(xr,yr,dend,count=count,view=view)
 if count eq nx*ny then begin
  err='All points rotated over limb'
  if verbose then message,err,/cont
  return
 endif
endif

;-- roll back to original roll

if rflag then roll_xy,xr,yr,roll_angle,xr,yr,rcenter=roll_center


return & end


