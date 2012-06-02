pro whv_event,ev
restore,'whv.dat'
type = tag_names(ev,/structure)
if (type eq 'WIDGET_BUTTON') then begin
   widget_control,ev.id,get_value = value
   if (value eq 'DONE') then widget_control,/destroy,ev.top  
endif
if (type eq 'WIDGET_TEXT') then begin
   widget_control,ev.id,get_value = entry
   print,'ENTRY= ',entry
   widget_control,ev.id,get_uvalue = uv
   print,'UVALUE=',uv
   restore,'whv.dat'
   whvd(uv)=entry
   save,file='whv.dat',whvd
endif
end
