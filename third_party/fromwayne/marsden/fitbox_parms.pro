pro fitbox_parms,ev,num_lines_,strtbin_,stpbin_
;********************************************************************
; Program gets the fitbox parameters from the event manager.
; Variables are:
;          ev...................event from the widget
;   num_lines...................# of gaussian lines in model
;     strtbin...................start bin of fit
;      stpbin...................stop bin of fit
; 8/26/94 Annoying print statements removed
;********************************************************************
common fitblock,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,$
               nfree,rt,idfs,idfe,dt,cp,ltime,opt,det,typ,strtbin,$
               stpbin,fttd,asave,mdlnsave,det_str
widget_control,ev.id,get_value = entry
widget_control,ev.id,get_uvalue = ndx
ndx = ndx - 1
if(ndx eq 0) then begin
   num_lines = fix(entry)
   num_lines = num_lines(0)
   num_lines_ = num_lines
endif
if(ndx eq 1) then begin
   strtbin = float(entry)
   strtbin = strtbin(0)
   strtbin_ = strtbin
endif
if(ndx eq 2) then begin
   stpbin = float(entry)
   stpbin = stpbin(0)
   stpbin_ = stpbin
endif
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end
