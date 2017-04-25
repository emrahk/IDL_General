;+
; NAME:   
;      get_utrange
; PURPOSE:
;      get user to enter UT start and end times
; CATEGORY:
;      GEN
; CALLING SEQUENCE:
;      get_utrange,utbase,dstart,dend
; INPUTS:
;      utbase  - UT base time
; OUTPUTS:
;      dstart,dend - requested start and end times
; RESTRICTIONS:
;      input times must be in UT format YY/MM/DD, HHMM:SS.MSEC
;      (date is optional, and defaults to UTBASE)
; HISTORY:
;      written DMZ (ARC Apr'93)
;-


 pro get_utrange,utbase,dstart,dend


 if n_elements(utbase) eq 0 then begin
  repeat begin
   utbase='' & read,'* enter UTBASE of data: ',utbase
  endrep until utbase ne ''
 endif
 utbase=anytim(utbase,/date,/hxrb)

 print
 repeat begin
  tstart=''
  read,'* enter start time to extract [yy/mm/dd, hhmm:ss.msec] ',tstart
 endrep until tstart ne ''
 sdate=anytim(tstart,/date,/hxrb)
 stime=anytim(tstart,/time,/hxrb)
 if sdate eq '79/01/01' then sdate=utbase

 dstart=sdate+','+stime

 print
 repeat begin
  tend=''
  read,'* enter end time to extract [yy/mm/dd, hhmm:ss.msec] ',tend
 endrep until tend ne ''

 edate=anytim(tend,/date,/hxrb)
 etime=anytim(tend,/time,/hxrb)
 if edate eq '79/01/01' then edate=sdate
 dend=edate+','+etime

 return & end

