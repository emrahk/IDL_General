;+
; Project     : HESSI
;                  
; Name        : Y2KFIX
;               
; Purpose     : apply Y2K correction to date 
;                             
; Category    : utility time
;               
; Explanation : uses pivot method. Dates earlier than pivot
;               will be corrected.
;               
; Syntax      : IDL> fixed_date=y2kfix(date)
;
; Inputs      : DATE = date to fix
;               
; Outputs     : FIXED_DATE = fixed date
;               
; Keywords    : PIVOT = pivot year [def = 1950]
;               (e.g. dates like 1940/01/02 -> 2040/01/02)
;               
; History     : Written, 5-Jan-2000, Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function y2kfix,time,err=err,pivot=pivot,_extra=extra

;-- check pivot
;-- if 2 digits, assume a 19 prefix

pivot_len=strlen(trim2(pivot,/quiet))

if pivot_len lt 2 then pivot='1950' else begin
 pivot=trim2(pivot)
 pivot=strmid(pivot,0,4)
 if pivot_len eq 2 then pivot='19'+pivot 
endelse

dprint,'% pivot ',pivot

;-- check if single year entered

year_in=strlen(trim2(time,/quiet)) eq 4
if not year_in then begin
 err=''
 ftime=anytim2utc(time,/ymd,/ecs,err=err)
 if err ne '' then begin
  message,err,/cont
  pr_syntax,'fixed_time=y2kfix(time, [pivot=pivot])'
  return,''
 endif
endif else ftime=trim2(time)

;-- apply the fix here

date_part=strmid(ftime,0,4)
if fix(date_part) lt fix(pivot) then begin
 yy1=strmid(date_part,0,2)
 yy2=strmid(date_part,2,2)
 new_date_part='20'+yy2
 ftime=str_replace(ftime,date_part,new_date_part)
endif

if (datatype(extra) eq 'STC') and (not year_in) then begin
 if have_tag(extra,'tai') then ftime=anytim2tai(ftime) else $
  ftime=anytim2utc(ftime,_extra=extra) 
endif 

return,ftime & end


    







