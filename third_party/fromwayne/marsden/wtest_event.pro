pro wtest_event,ev
print,'EV = ',ev
type = tag_names(ev,/structure)
print,'TYPE = ',type
if (type eq 'WIDGET_BUTTON') then begin
widget_control,ev.id,get_value = value
print,'VALUE = ',value
if (value eq 'DONE') then widget_control,/destroy,ev.top
endif
end
