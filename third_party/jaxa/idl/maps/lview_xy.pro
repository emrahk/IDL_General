;+
; Project     : SOHO-CDS
;
; Name        : LVIEW_XY
;
; Purpose     : wrapper around SOHO_XY to adjust for L1 view 
;
; Category    : imaging
;
; Explanation : for rolled images, coordinates have to be corrected
;               before applying solar view correction
;
; Syntax      : lview_xy,xp,yp,date,xr,yr
;
; Inputs      : XP,YP = input coordinates
;               DATE = observation date
;
; Opt. Inputs : None
;
; Outputs     : XR,YR = view-adjusted coordinate arrays
;
; Opt. Outputs: None
;
; Keywords    : EARTH = map to EARTH-view
;               SOHO = map to SOHO-view
;               ERR = error string
;               VERBOSE = print messages
;               NO_COPY= set to not duplicate arrays
;               ROLL,RCENTER = coordinate roll and roll center 
;  
; History     : Written 15 Feb 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro lview_xy,xp,yp,date,xr,yr,earth=earth,soho=soho,err=err,$
                verbose=verbose,no_copy=no_copy,roll=roll,rcenter=rcenter
on_error,1
err=''

if (not exist(xp)) or (not exist(yp)) then begin
 pr_syntax,'view_xy,xp,yp,date,xr,yr [,roll=roll]'
 err='input error'
 return
endif

tdate=anytim2tai(date,err=err)
if err ne '' then begin
 message,err,/cont
 return
endif

;-- check view direction

verbose=keyword_set(verbose)
to_earth=keyword_set(earth)
to_soho=keyword_set(soho)
no_copy=keyword_set(no_copy)

if (to_earth eq to_soho) then begin
 err='use /earth or /soho'
 message,err,/cont
 return
endif
                         
if no_copy then begin
 xr=copy_var(xp) & yr=copy_var(yp)
endif else begin
 xr=xp & yr=yp
endelse

;-- correct for non-zero roll before adjusting

rflag=0
if exist(roll) then begin
 if roll ne 0. then begin
  if verbose then message,'correcting for '+num2str(roll)+' deg roll',/cont
  roll_xy,xr,yr,-roll,xr,yr,rcenter=rcenter
  rflag=1
 endif
endif

;-- now adjust the view
                       
soho_xy,xr,yr,date,xr,yr,err=err,inverse=to_earth,/no_copy

if err ne '' then begin
 if verbose then message,err,/cont
 return
endif
             
;-- roll back to original roll
             
if rflag then roll_xy,xr,yr,roll,xr,yr,rcenter=rcenter

return & end


