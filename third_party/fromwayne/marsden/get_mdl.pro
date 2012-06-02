pro get_mdl,value,mdl
;********************************************************************
; Program gets the model
; Input variable:
;	value..........value of the event
; Output varaible:
;         mdl..........selected model
; 8/26/94 Annoying print statements eliminated 
;********************************************************************
mdl = '-1'
mdl_str = ['N GAUSSIAN LINES','N LINES + CONST.','N LINES + LINEAR',$
 'N LINES + PWRLAW','N LINES + PWRLAW + CONST.']
yes = where(value eq mdl_str)
if (yes(0) ne -1)then begin
   mdl = mdl_str(yes(0))
endif 
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end
