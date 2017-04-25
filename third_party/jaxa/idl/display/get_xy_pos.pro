;+
;Name: get_xy_pos
; 
;Purpose: Return x,y coordinates of left-clicks in a draw window.  User left-clicks one or multiple
; locations, and right-clicks to indicate done.
; 
;Calling argument:
; widget_id - widget id of the draw widget
; 
;Output keywords:
; count - number of points clicked and returned
; 
;Output: After right-click, returns a 2xn array of n x,y coordinates
;
;Written: 28-Jul-2014, Kim Tolbert
;Modifications:
;
;-
function get_xy_pos_event, event

  return,event
  
end


function get_xy_pos, widget_id, count=count

count = 0

; Save whatever procedure or function the draw widget normally calls so we can replace the function
; with get_xy_pos_event (which does nothing), but then we can get the event using widget_event.

sav_event_pro = widget_info(widget_id,/event_pro)
sav_event_func = widget_info(widget_id,/event_func)

widget_control, widget_id, event_pro=''
widget_control, widget_id, event_func='get_xy_pos_event'
 
if keyword_set(event) then help,event,/st

while 1 do begin
  ev = widget_event(widget_id)
;  help,ev,/st
  if ev.type eq 1 then begin            ; type = 1 mean button was released (we're ignoring presses)
    if ev.release eq 4 then goto, done  ; 4 means user right-clicked
    if ev.release eq 1 then begin       ; 1 means user left-clicked
      xy = convert_coord (ev.x, ev.y, /device, /to_data)
      print,xy
      plots, xy[0], xy[1], psym=1
      ret_x = append_arr(ret_x, xy[0])
      ret_y = append_arr(ret_y, xy[1])
      count = count + 1  
    endif
  endif
  
endwhile

done:
; Restore draw widget's original procedure or function
if sav_event_pro ne '' then widget_control, widget_id, event_pro=sav_event_pro
if sav_event_func ne '' then widget_control, widget_id, event_func=sav_event_func

return, count eq 0 ? -1 : transpose([[ret_x], [ret_y]])  ; 2xn 
end