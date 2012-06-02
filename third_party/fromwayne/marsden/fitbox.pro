pro fitbox,base,rcol,maxbin
;***********************************************************************
; Program makes the fitting box for the widgets
; Variables are:
;            base..............widget base
;       num_lines..............# of gaussian lines in model
;         strtbin..............start bin of fit
;          stpbin..............stop bin of fit
;          maxbin..............maximum bin possible
; Common block:
;        fitblock..............contains fit variables
; 6/10/94 Current version ;***********************************************************************
common fitblock,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,$
               nfree,rt,idfs,idfe,dt,cp,ltime,opt,det,typ,strtbin,$
               stpbin,fttd,asave,mdlnsave,det_str
if (ks(num_lines) eq 0)then num_lines = 1
if (ks(strtbin) eq 0)then strtbin = 0
if (ks(stpbin) eq 0)then stpbin = 255
if (ks(maxbin))then stpbin = maxbin
rcol = widget_base(base,/column)
rcol1 = widget_base(rcol,/column,/frame)
w1 = widget_label(rcol1,value='ENTER PARAMETERS',/frame)
w1 = widget_label(rcol1,value='# OF LINES N:')
w1 = widget_text(rcol1,value=string(num_lines),uvalue=1,$
 xsize=10,ysize=1,/editable)
w1 = widget_label(rcol1,value='START BIN:')
w1 = widget_text(rcol1,value=string(strtbin),uvalue=2,xsize=10,ysize=1,$
                 /editable)
w1 = widget_label(rcol1,value='STOP BIN:')
w1 = widget_text(rcol1,value=string(stpbin),uvalue=3,xsize=10,ysize=1,$
                 /editable)
xpdmenu,['"MODELS"{','"N GAUSSIAN LINES"','"N LINES + CONST."',$
 '"N LINES + LINEAR"','"N LINES + PWRLAW"','"N LINES + PWRLAW + CONST."','}'],rcol1                                  
;*******************************************************************************
; Thats all ffolks
;*******************************************************************************
return
end
