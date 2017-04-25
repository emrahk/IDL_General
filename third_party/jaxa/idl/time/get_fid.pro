;+
; Project     : HESSI
;
; Name        : GET_FID
;
; Purpose     : determine YYMMDD names based on date/time 
;
; Category    : utility io 
;
; Syntax      : rdir=get_fid(tstart,tend)
;
; Inputs      : TSTART/TEND = start/end times to base search
;               e.g. TSTART = 10-may-99 -> 990510
;                    TEND   = 20-dec-99 -> 991220
;
; Outputs     : Array directory names 
;
; Keywords    : NO_DAY = exclude day from output
;               FULL= include full year in output
;               YEAR_ONLY = include year only
;               DELIM = delimiter between year, month, & day
;               ORGANIZATION = DOY, YEAR, MONTH, or DAY (def) for directory organization 
;
; History     : Written 6 Jan 1999, D. Zarro (SM&A/GSFC)
;               9-Feb-2010, Zarro (ADNET) 
;                - add ORG keyword
;               28-Sep-2010, Zarro (ADNET)
;                - added DOY for ORG
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_fid,tstart,tend,_extra=extra,no_day=no_day,organization=organization,$
                 year_only=year_only,dstart=dstart,dend=dend,$
                 delim=delim,full=full

dstart=get_def_times(tstart,tend,dend=dend,_extra=extra)

doy=0b
if is_string(organization) then begin
 if organization eq 'year' then year_only=1b
 if organization eq 'month' then no_day=1b
 if organization eq 'doy' then begin 
  year_only=0b & no_day=0b & doy=1b & full=1b & delim='/'
 endif
endif

sdir=time2fid(dstart,no_day=no_day,year_only=year_only,delim=delim,full=full,_extra=extra)
edir=time2fid(dend,no_day=no_day,year_only=year_only,delim=delim,full=full,_extra=extra)

jdate=dstart
mstart=anytim2utc(dstart)
i=0
while ((where(edir eq sdir))[0] eq -1) do begin
 mdate=anytim2utc(jdate)
 i=i+1
 mdate.mjd=mstart.mjd+i
 jdate=anytim2utc(mdate,/ext)
 dir=time2fid(jdate,no_day=no_day,year_only=year_only,_extra=extra,delim=delim,full=full)
 skip=0
 if keyword_set(no_day) or keyword_set(year_only) then begin
  np=n_elements(sdir)
  skip=dir eq sdir[np-1] 
 endif
 if ~skip then sdir=append_arr(sdir,dir,/no_copy)
endwhile

if doy then begin
 utc=anytim2utc(sdir,/ext)
 year=utc.year
 day=string(utc2doy(utc),format='(i3.3)')
 sdir=trim(year)+'/'+trim(day)
endif

return,sdir & end

