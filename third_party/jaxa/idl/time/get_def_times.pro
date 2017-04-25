;+
; Project     : HESSI
;
; Name        : get_def_times
;
; Purpose     : return default times
;
; Category    : HESSI, GBO, utility, time
;
; Explanation : If TSTART/TEND are not specified correctly, then
;               return current time and end of current day
;               as useful defaults
;
; Syntax      : IDL> dstart=get_def_times(tstart,tend,dend=dend)
;
; Opt. Inputs : TSTART = start time
;               TEND   = end time
;
; Outputs     : DSTART = TSTART or current time if invalid TSTART (TAI format)
;
; Keywords    : DEND = TEND or end of current day if invalid TEND
;               Inherits ANYTIM keywords
;               ROUND_TIMES = round start/end to start/end of day
;               NO_NEXT = don't include next day
;               BACK = # of days back to start [def =0]
;               FORWARD = # of days forward [def=0]
;               TAI = return times in TAI format
;               VERBOSE = verbose output
;
; History     : 14-Nov-1999,  D.M. Zarro (SM&A/GSFC),  Written
;               22-Mar-2004, Zarro (L-3Com/GSFC) - added check for tend < tstart
;               7-Apr-2004, Zarro (L-3Com/GSFC) - fixed bug that returned
;                structure time instead of TAI (Sorry, Luis)
;               12-Nov-2005, Zarro (L-3Com/GSFC) - added VSO output:
;                yyyymmddhhmmss
;               23-Feb-2007, Zarro (ADNET) - added BACK
;               23-Apr-2007, Zarro (ADNET) - added FORWARD
;               31-Dec-2009, Zarro (ADNET) - added /TAI
;               4-Oct-2010, Zarro (ADNET) - added /VERBOSE
;               25-Jul-2014, Zarro (ADNET) 
;                - use current time for default end time.
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_def_times,tstart,tend,dend=dend,_extra=extra,vso=vso,back=back,$
                       round_times=round_times,err=err,no_next=no_next,$
                       forward=forward,tai=tai,verbose=verbose

; TSTART = start time [def= start of current day]
; TEND   = end time [def = end of current day]


no_next=keyword_set(no_next) 
round_t=keyword_set(round_times)

err=''
err1=''
dstart=anytim2utc(tstart,err=err1)
secs_day= 86400.d
if err1 ne '' then get_utc,dstart
if round_t then dstart.time=0

err2=''
dend=anytim2utc(tend,err=err2)
if err2 ne '' then begin
 dend=dstart
 dend.time=0
 dend.mjd=dend.mjd+1
endif else begin
 if round_t then begin
  dend.time=0
  dend.mjd=dend.mjd+1
 endif
endelse

;-- ensure start < end

dstart=anytim2tai(dstart)
dend=anytim2tai(dend)

if dend lt dstart then begin
 temp=dend
 dend=dstart & dstart=temp
endif

if no_next and (err2 ne '') then begin
 if (dstart ne dend) then dend=(dend-secs_day) > dstart
endif

if is_number(back) then begin
 if is_string(err2) then dend=dstart
 dstart=dstart-abs(back)*secs_day
endif

if is_number(forward) then dend=dend+abs(forward)*secs_day

if keyword_set(verbose) then begin
 mprint,'DSTART - '+anytim2utc(dstart,/vms),/cont
 mprint,'DEND - '+anytim2utc(dend,/vms),/cont
endif

;-- convert to other requested formats

if keyword_set(vso) then begin
 dstart=vso_format(dstart)
 dend=vso_format(dend)
 return,dstart
endif

if is_struct(extra) then begin
 dstart=anytim2utc(dstart,_extra=extra)
 dend=anytim2utc(dend,_extra=extra) 
endif

if keyword_set(tai) and (size(dstart,/tname) ne 'DOUBLE') then begin
 dstart=anytim2tai(dstart)
 dend=anytim2tai(dend) 
endif

if (err1 ne '') and (err2 ne '') then err=trim(err1)+' '+trim(err2) 

return,dstart & end


