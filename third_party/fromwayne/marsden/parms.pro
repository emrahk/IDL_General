pro parms,base,a,sigmaa,astring
;***********************************************************************
; Program displays the fitted values.
; Variables are:
;	base..............base for widget
;          a..............parameter values
;     sigmaa..............errors on fitted parms
;    astring..............string of parameter names
; First round values to Hundreds spot. (1000 for chidof)
;***********************************************************************
a = .01*long(a*100. + .5) & sigmaa = .01*long(sigmaa*100. + .5)
;***********************************************************************
; Convert to strings for widget display. Trim 'em
;***********************************************************************
astr = strcompress(a,/remove_all)
sigstr = strcompress(sigmaa,/remove_all)
num_parms = n_elements(a)
for i = 0,num_parms-1 do begin
 temp = astr(i)
 astr(i) = strmid(temp,0,strpos(temp,'.')+3)
 temp = sigstr(i)
 sigstr(i) = strmid(temp,0,strpos(temp,'.')+3)
endfor
;***********************************************************************
; Start widgets
;***********************************************************************
rcol = widget_base(base,/column)
rcol2 = widget_base(rcol,/column,/frame)
;***********************************************************************
; Display parameters and best-fit values
;***********************************************************************
rcol2a = widget_base(rcol2,/column)
for i = 0,num_parms-1 do begin
 w1 = widget_label(rcol2a,value=astring(i))
 rcol2a_ = widget_base(rcol2a,/row)
 w2 = widget_text(rcol2a_,value=astr(i),xsize=10,$
  ysize=1,uvalue=i,/editable)
 w3 = widget_label(rcol2a_,value='+/-')
 w4 = widget_text(rcol2a_,value=sigstr(i),xsize=10,$
  ysize=1,uvalue=i+num_parms)
endfor
;****************************************************************************
; Thats all ffolks
;****************************************************************************
return
end


