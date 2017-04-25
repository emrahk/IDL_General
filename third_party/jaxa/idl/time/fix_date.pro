;+
; Project     : SOHO-CDS
;
; Name        : FIX_DATE
;
; Purpose     : Fix date that uses digit month into one with a string month
;
; Category    : utility
;
; Syntax      : fdate=fix_date(date)
;
; Inputs      : DATE = string date to fix (e.g. '10/02/98')
;                                       
; Outputs     : FDATE = fixed date (e.g. '10-feb-98')
;
; Keywords    : EUROPEAN = interpret middle entry as month
;
; History     : Written 26 August 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function fix_date,date,european=european

if datatype(date) ne 'STR' then return,''
                        
euro=keyword_set(european)
ndate=n_elements(date)
new_date=date
for i=0,ndate-1 do begin
 new=str_replace(new_date(i),'/','-')
 temp=str2arr(trim2(new),delim='-')
 if n_elements(temp) eq 3 then begin
  if not euro then temp([0,1])=temp([1,0])
  mn=trim2(temp(1))
  if is_number(mn) and is_number(temp(0)) and is_number(temp(2)) then begin
   val=fix(mn)
   if (val gt 12) then begin
    if temp(0) eq val then begin
     temp(0)=temp(1) & temp(1)=val
     val=temp(0)
    endif
    if temp(1) eq val then begin
     temp(1)=temp(0) & temp(0)=val
     val=temp(1)
    endif
   endif
   if (val ge 1) and (val le 12) then begin
    mon=get_month(val-1)
    new_temp=temp 
    new_temp(1)=mon
    new_date(i)=arr2str(new_temp,delim='-')
   endif
  endif  
 endif
endfor

if n_elements(date) eq 1 then new_date=new_date(0)
return,new_date & end

