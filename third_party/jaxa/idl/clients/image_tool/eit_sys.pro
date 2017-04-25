;+
; Project     : SOHO - CDS     
;                   
; Name        : EIT_SYS
;               
; Purpose     : setup special color system variables for EIT wavelengths
;               
; Category    : utility
;               
; Syntax      : IDL> eit_sys
;
; Inputs      : None
;               
; Outputs     : None
;
; Side Effects: !304,!195,!284 & !171 are defined
;               
; History     : 11-Jan-2002,  D. Zarro (EITI/GSFC).  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-     


pro eit_sys,show=show

;-- setup default EIT color system variables 

def={lo:0.,hi:float(!d.table_size-1)}
defsysv,'!304',exists=defined
if not defined then defsysv,'!304',def

defsysv,'!195',exists=defined
if not defined then defsysv,'!195',def

defsysv,'!284',exists=defined
if not defined then defsysv,'!284',def

defsysv,'!171',exists=defined
if not defined then defsysv,'!171',def

;-- customize for EOF

user_id=get_user_id()

if user_id eq 'soc@hazel.nascom.nasa.gov' then begin
 !171.lo=7  &  !171.hi=209
 !195.lo=18 &  !195.hi=224 
 !284.lo=0  &  !284.hi=173 
 !304.lo=0  &  !304.hi=175
endif

if keyword_set(show) then begin
 print,'             lo           hi '
 print,'!304: ',!304.lo,!304.hi
 print,'!284: ',!284.lo,!284.hi
 print,'!195: ',!195.lo,!195.hi
 print,'!171: ',!171.lo,!171.hi
endif

return & end
