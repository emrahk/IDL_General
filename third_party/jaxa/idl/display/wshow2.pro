;+
; Project     : HESSI
;                  
; Name        : WSHOW2
;               
; Purpose     : windows friendly version of WSHOW
;                             
; Category    : display
;               
; Syntax      : IDL> wshow2
;
; Inputs      : INDEX = windows index
;                                   
; History     : Written, 4-Oct-2002, Zarro (LAC/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro wshow2,index,_extra=extra,err=err

;-- catch unplanned errors

err=''
error=0
catch,error
if error ne 0 then begin
 err=!err_string
 catch,/cancel
 return
endif

wshow,index,icon=0,_extra=extra

return & end
