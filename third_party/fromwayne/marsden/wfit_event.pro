pro wfit_event,ev
;************************************************************************
; Program handles the events in the fit widget
; wfit.pro, and communicates to the manager program
; fitit.pro via common block variables
;           typ..............type data string
; 6/10/94 Current version
; 8/26/94 Annoying print statements eliminated
;************************************************************************
common fitblock,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,$
                nfree,rt,idfs,idfe,dt,cp,ltime,opt,det,typ,strtbin,$
                stpbin,fttd,asave,mdlnsave,det_str
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common parms,start,new,clear
type = tag_names(ev,/structure)
widget_control,ev.id,get_value = value
;***********************************************************************
; Session buttons
;**********************************************************************
str = strcompress('DONE : RETURN TO ' + typ)
if(value(0) eq str) then begin
   fttd = 0
   a(*) = 0
   new = 0 & start = 0
   case typ of
      'HIST'    : hist
      'ARCHIST' : archist
      'CALHIST' : calhist
      'PHAPSA'  : phapsa
   endcase
endif
if (value(0) eq 'SAVE FIT')then save_fit
if (value(0) eq 'FIT PARAMETERS')then begin
   fttd = 1
   new = 0 & start = 0
   fitit
endif
;***********************************************************************
; Load the new parameters
;***********************************************************************
if (type eq 'WIDGET_TEXT' or type eq 'WIDGET_TEXT_CH')then begin
   widget_control,ev.id,get_uvalue = index
   a(fix(index)) = float(value)
endif
;***********************************************************************
; Thats all ffolks
;***********************************************************************
return
end
