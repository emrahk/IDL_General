; This is a very unorthodox way to store hessi GUI (or plotman) panels and then restore
; them into a new session of the GUI or plotman.
; After creating a bunch of panels, do the following:
;
;     Click button under File to Stop the GUI, and type:
;
;     panels = state.plotman_obj -> get(/panels)
;     save, filename='GUI_panels_blahblah.sav', panels
;
;     In a new session of IDL, start the GUI, view the kind of data that you know is
;     in the save file (to compile the object methods), then stop the GUI and type:
;
;     state.plotman_obj -> restore_panels, 'GUI_panels_blahblah.sav'
; The reason this isn't made generally available is because of the problem of
; restoring objects - the methods aren't compiled by default, and once the object
; is restored, trying to compile the methods has no effect.
;
; 26-Nov-2003, Kim Tolbert

;---------------------------------------------------------------------------

pro plotman::restore_panels, file

restore, file

for i = 0, panels -> get_count()-1 do begin
	panel = panels -> get_item(i)
	(*panel).w_drawbase = 0L
	(*panel).w_draw = 0L
	(*panel).window_id = -1
endfor

self -> set, panels = panels

end
