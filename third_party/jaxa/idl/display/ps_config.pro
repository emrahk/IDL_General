pro ps_config,input

save=!d.name
set_plot,'ps'

if datatype(input) eq 'STC' then begin
 input=ps_form(_extra=input)
endif else input=ps_form()
device,_extra=input

set_plot,save
return & end
