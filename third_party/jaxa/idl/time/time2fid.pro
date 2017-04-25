;+
; Project     : HESSI
;
; Name        : TIME2FID
;
; Purpose     : create YYMMDD_HHMM fid name based on date/time 
;
; Category    : utility io 
;
; Syntax      : fid=time2fid(date)
;
; Inputs      : DATE/TIME
;
; Outputs     : FID = matching ID (e.g., 10-may-99 -> 990510)
;
; Keywords    : NO_DAY = exclude day from output
;               FULL_YEAR= include full year in output
;               TIME = include _HHMM in output 
;               YEAR_ONLY = include year only
;               DELIM = delimiter between year, month, & day
;
; History     : Written 6 Jan 1999, D. Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;----------------------------------------------------------------------------

pro y2k_patch,iyear,oyear,full_year=full_year

if ~exist(iyear) then return
oyear=iyear
if keyword_set(full_year) then return

temp=strmid(trim2(iyear),2,2)
temp2=fix(temp)

oyear=temp
chk=where(temp gt 99,count)
if count gt 0 then oyear[chk]=trim2(temp2[chk]-100) 

return & end

;----------------------------------------------------------------------------

function time2fid,date,err=err,no_day=no_day,full_year=full_year,time=time,$
                  year_only=year_only,delim=delim,seconds=seconds,$
                  milliseconds=milliseconds

err=''
tdate=anytim2utc(date,/ext,err=err)
if err ne '' then begin
 message,err,/cont
 return,''
endif

include_day=1-keyword_set(no_day)
include_month=1b
if keyword_set(year_only) then begin
 include_day=0b & include_month=0b
endif

form='(i2.2)'
yform=form
if keyword_set(full_year) then yform='(i4)'
if keyword_set(milliseconds) then mform='(i3.3)'

syear=trim2(tdate.year)
y2k_patch,syear,oyear,full_year=full_year

fid=str_format(oyear,yform)
if ~is_string(delim) then delim=''
if include_month then fid=fid+delim+str_format(tdate.month,form)
if include_day then fid=fid+delim+str_format(tdate.day,form)
ext='_'+str_format(tdate.hour,form)+delim+str_format(tdate.minute,form)
if keyword_set(time) then begin
 fid=fid+ext
 if keyword_set(seconds) or keyword_set(milliseconds) then begin
  fid=fid+str_format(tdate.second,form)
  if keyword_set(milliseconds) then fid=fid+str_format(tdate.millisecond,mform)
 endif
endif

return,fid

end

