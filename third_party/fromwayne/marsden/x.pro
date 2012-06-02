pro x,bp
;*****************************************************************************
; Program Widget waits for events from the c socket
; 6/10/94 Current version
;*****************************************************************************
; Modification history:
; 1994 June 22 - P. R. Blanco, CASS/UCSD. Removed CALL_EXTERNAL to linkinit.so,
; since changes to X_EVENT.PRO (q.v.) make this no longer necessary.

common basecom,base,idfold,beep,chc
if (ks(bp))then begin
   beep = 'TOMGASAWAY'
   print,'SETTING BEEP'
endif
device,get_screen_size = scrsiz
; 
; CALL_EXTERNAL to linkinit was originally here
;
base = widget_base(xoffset=.25*scrsiz(0),yoffset=.6*scrsiz(1),$
       title='HEXTE WIDGETS')
widget_control,base,/real
widget_control,base,time=1
xmanager,"x",base,group_leader = base
;******************************************************************************
; Thats all ffolks
;******************************************************************************
end
