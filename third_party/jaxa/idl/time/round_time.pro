;+
; Project     : HESSI
;
; Name        : ROUND_TIME
;
; Purpose     : round time to start of hour, day, month, or year
;
; Category    : HESSI, GBO, utility, time
;               
; Syntax      : IDL> rtime=round_time(time,err=err)
;
; Inputs      : TIME = input time (e.g. 1-may-00 12:13)
;
; Outputs     : RTIME = rounded time (e.g. 1-may-00) [def is day in TAI]
;
; Keywords    : /HOUR, /MONTH, /YEAR
;               /NEXT = round to start of next hour, day, month, or year
;               RES= 0,1,2,3 (for hour, day, month,year)
;
; History     : 11-Apr-2000,  D.M. Zarro (SM&A/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function round_time,time,hour=hour,month=month,year=year,err=err,$
               next=next,res=res,_extra=extra,minute=minute

err=''

dtime=anytim2utc(time,err=err,/ext)
if err ne '' then begin
 pr_syntax,'rtime=round_time(time,[/hour,/month,/year])
 return,''
endif
      
next=keyword_set(next)

;-- RES keyword value precedes individual keywords

if exist(res) then begin
 day=1
 hour=res eq 0
 day=res eq 1
 month=res eq 2
 year=res eq 3
endif

;-- start by zeroing out min/sec/msec

dtime.minute=0 & dtime.second=0 & dtime.millisecond=0
      
case 1 of

 keyword_set(hour): begin
  if next then dtime.hour=dtime.hour+1
 end

 keyword_set(month): begin
  dtime.hour=0 & dtime.day=1
  if next then dtime.month=dtime.month+1
 end

 keyword_set(year): begin
  dtime.month=1 & dtime.day=1 & dtime.hour=0
  if next then dtime.year=dtime.year+1
 end

 else: begin
  dtime.hour=0
  if next then dtime.day=dtime.day+1
 end
endcase

if datatype(extra) eq 'STC' then $
 rtime=anytim2utc(dtime,_extra=extra) else $
  rtime=anytim2tai(dtime)

if datatype(rtime) eq 'STR' then begin
 if keyword_set(hour) then rtime=str_replace(rtime,':00.000','') else $
  rtime=str_replace(rtime,'00:00:00.000','')
 rtime=trim(rtime)
endif

return,rtime
end
