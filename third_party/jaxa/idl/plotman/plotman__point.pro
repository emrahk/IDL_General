;+
; Name: Plotman::plot
; 
; Purpose: Point function method for plotman - returns x,y coords of location user clicks in plotman plot.
; 
; Calling sequence:  xy = plotman_obj -> point()
; 
; Method: Set focus (->select) to the current plot panel which is a draw widget, save the attributes of the draw widget, 
; then set them to what we need here.  Call widget_event to wait for an event.  On release of the click of any button,
; return the coordinates of the point clicked in data, device or normal coordinates.  Data is default.
; 
; Keywords:
;   data - return data coordinates
;   device - return device coordinates
;   normal - return normalized coordinates
;   
; Example:  
;   print, plotman_obj -> point(/normal)
;   (user clicks in plotman plot)
;      911.758      260.210
;      
; Written: Kim Tolbert, 30-Oct-2011
; Modifications:
;-

function plotman_point_event, event
return, event
end

function plotman::point, data=data, device=device, normal=normal

self->select

widgets = self->get(/widgets)
widget_id = widgets.w_draw

sav_draw_motion_events = widget_info(widget_id, /draw_motion_events)
sav_draw_button_events = widget_info(widget_id, /draw_button_events)
sav_event_pro = widget_info(widget_id,/event_pro)
sav_event_func = widget_info(widget_id,/event_func)

widget_control, widget_id, draw_motion_events=0, /draw_button_events
widget_control, widget_id, event_pro=''
widget_control, widget_id, event_func='plotman_point_event'

xy = -1

catch, error
if error ne 0 then begin
    print,!err_string    
    goto, reset
endif

while 1 do begin

  ev = widget_event (widget_id)

  if ev.release gt 0 then begin
  
    ; Plot an X at the spot
    plots, ev.x, ev.y, /device, psym=7, symsize=.9, thick=2, color=0

    ;convert location to coordinate system requested, default is data coords.
    case 1 of 
      keyword_set(device): xy = [ev.x, ev.y]
      keyword_set(normal): xy = convert_coord (ev.x, ev.y, /device, /to_normal)
      else: xy = convert_coord (ev.x, ev.y, /device, /to_data)
    end
    
    xy = xy[0:1]
    goto, reset
  endif

endwhile

reset:
if sav_event_pro ne '' then widget_control, widget_id, event_pro=sav_event_pro
if sav_event_func ne '' then widget_control, widget_id, event_func=sav_event_func
widget_control, widget_id, draw_button_events=sav_draw_button_events, $
  draw_motion_events=sav_draw_motion_events

self -> unselect

return, xy
  
end