;+
; Project     : SOHO - CDS
;
; Name        : GET_GEV
;
; Purpose     : Wrapper around RD_GEV
;
; Category    : planning
;
; Explanation : Get GOES Event listing
;
; Syntax      : IDL>gev=get_gev(tstart)
;
; Inputs      : TSTART = start time 
;
; Opt. Inputs : TEND = end time
;
; Outputs     : GEV = event listing in structure format
;
; Keywords    : COUNT = # or entries found
;               ERR = error messages
;               QUIET = turn off messages
;               LIMIT = limiting # of days for time range
;
; History     : Version 1,  20-June-1999,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
; 23-Jan-2012, Kim Tolbert.  Added ngdc keyword to read older files (<25-aug-1991)
;-

function get_gev,tstart,tend,count=count,err=err,quiet=quiet,nearest=nearest,$
                  limit=limit, ngdc=ngdc

on_error,1
err=''
count=0


;-- start with error checks

if not have_proc('rd_gev') then begin
 sxt_dir='$SSW/yohkoh/gen/idl'
 if is_dir(sxt_dir,out=sdir) then add_path,sdir,/append,/expand
 if not have_proc('rd_gev') then begin
  err='cannot find RD_GEV in IDL !path'
  message,err,/cont
  return,''
 endif
endif

if trim(getenv('DIR_GEN_GEV')) eq '' then begin
 err='DIR_GEN_GEV not defined'
 message,err,/cont
 return,''
end

err=''
t1=anytim2utc(tstart,err=err)
if err ne '' then get_utc,t1
t1.time=0

err=''
t2=anytim2utc(tend,err=err)
if err ne '' then begin
 t2=t1
 t2.mjd=t2.mjd+1
endif

;-- shift to end of 24 hr period

t2.time=0
t2.mjd=t2.mjd+1
loud=1-keyword_set(quiet)

if t2.mjd le t1.mjd then begin
 err='End time must be greater than Start time'
 if loud then message,err,/cont
 return,''
endif

if is_number(limit) then begin
 if (abs(t2.mjd-t1.mjd) gt limit) then begin
  err='Time range exceeds current limit of '+num2str(limit)+' days'
  if loud then message,err,/cont
  return,""
 endif
endif

;-- call RD_GEV

err=''
if loud then begin
 message,'retrieving GEV data for '+ anytim2utc(t1,/vms),/cont
endif

rd_gev,anytim2utc(t1,/vms),anytim2utc(t2,/vms),gev,nearest=nearest, ngdc=ngdc

if datatype(gev) ne 'STC' then begin
 err='GOES event data not found for specified times'
 if loud then message,err,/cont
 count=0
 return,''
endif

count=n_elements(gev)
return,gev

end


