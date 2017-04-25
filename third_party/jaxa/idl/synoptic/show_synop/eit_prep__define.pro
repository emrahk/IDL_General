;-- wrapper around eit_prep. Prep selection functions should go in here.

pro eit_prep::prep,file,header,data,_ref_extra=extra

self -> prep::get_prep_opts, _extra=extra, new=new
eit_prep,file,header,data,_extra=new

return & end

;----------------------------------------------------------------------------                

pro eit_prep::set_prep, surround=surround, cosmic=cosmic, no_calibrate=no_calibrate
if exist(surround) then self.surround = surround > 0 < 1
if exist(cosmic) then self.cosmic = cosmic > 0 < 1
if exist(no_calibrate) then self.no_calibrate = no_calibrate > 0 < 1
end

;------------------------------------------------------------------------------

function eit_prep::get_prep,  surround=surround, cosmic=cosmic, no_calibrate=no_calibrate
if keyword_set(surround) then return, self.surround
if keyword_set(cosmic) then return, self.cosmic
if keyword_set(no_calibrate) then return, self.no_calibrate
return, {surround: self.surround, cosmic: self.cosmic, no_calibrate: self.no_calibrate}
end

;------------------------------------------------------------------------------

pro eit_prep::prep_widget

wbase = widget_base(title='EIT Prep Options', /column, ypad=10, space=20, $
  /frame, uvalue={obj:self,orig:self->get_prep()} )
tmp = widget_label (wbase, value='Options for Preparing EIT Level-1 Data')
 
w1 = widget_base (wbase, /nonexclusive, /column)
tmp = widget_button (w1, uvalue='surround', $
  value='Surround - Replace missing block data with the average of surrounding blocks.')
widget_control, tmp, set_button=self.surround
tmp = widget_button (w1, uvalue='cosmic', $
  value='Cosmic - Remove cosmic rays (may remove small real features)')
widget_control, tmp, set_button=self.cosmic
tmp = widget_button (w1, uvalue='no_calibrate', $
  value='No-calibrate - Return "raw" images, i.e. only background subtracted')
widget_control, tmp, set_button=self.no_calibrate

w2 = widget_base (wbase, /row, /align_center)
tmp = widget_button (w2, value='Accept', uvalue='accept')
tmp = widget_button (w2, value='Cancel', uvalue='cancel')
widget_control, wbase, /realize
xmanager, 'eit::prep', wbase, event='eit_prep_event'

end

;----------------------------------------------------------------------------                
;-- object event handler. Since actual methods cannot be event-handlers,                     
;   we shunt events thru this wrapper                                                        
                                                                                             
pro eit_prep_event,event                                                                        
widget_control,event.top,get_uvalue=uvalue                                                  
if obj_valid(uvalue.obj) then uvalue.obj->prep_event,event                                          
end                                                                                          
                                                                                             
;----------------------------------------------------------------------------                
                                                                                             
pro eit_prep::prep_event,event
widget_control, event.id, get_uvalue=uvalue
case uvalue of
  'cosmic': self.cosmic = event.select
  'surround': self.surround = event.select
  'no_calibrate': self.no_calibrate = event.select
  'accept': widget_control, event.top, /destroy
  'cancel': begin
    widget_control, event.top, get_uvalue=uval
    uval.obj -> set_prep, _extra=uval.orig
    widget_control, event.top, /destroy
    end
    
endcase
end 

;----------------------------------------------------------------------------                

pro eit_prep__define, void

void={eit_prep, surround:0, cosmic:0, no_calibrate:0, inherits prep}

return & end