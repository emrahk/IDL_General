;+
; PROJECT:
;       SDAC
; 	
;
; NAME: F_USE_WIDGET
;
;
; PURPOSE: This function provides global control over allowed use of widget interfaces.
;
; CATEGORY: WIDGETS
;
;
; CALLING SEQUENCE:
;	res =f_use_widget()
;	res =f_use_widget(0, /use)	;enables widgets if possible
;	res =f_use_widget(0, /nouse)    ;disables widgets, f_use_widget will return 0
;	res =f_use_widget(0, /test)     ;returns 1 if widgets available, 0 otherwise
; KEYWORD INPUTS:
;	USE- If set,enables widgets if possible.
;	NOUSE- If set,disables widgets, f_use_widget will return 0.
;	TEST- If set,function returns 1 if widgets available, 0 otherwise.
;	CONTINUE- If set, allow continue on widget use error.
; Outputs:
;	None
;	Function returns 1 if widgets can be used, 0 otherwise.
;
; COMMON BLOCKS:
;	f_use_widg_com
;
; MODIFICATION HISTORY:
;	ras, 10-jun-94
;
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;	Version 2, richard.schwartz@gsfc.nasa.gov, utilize have_windows()
;-
function f_use_widget, x, use=use, nouse=nouse, test=test, continue=continue

common f_use_widg_com, widget, disable

widget = fcheck( use, fcheck(widget,0))
if keyword_set(nouse) then disable=1
if keyword_set(use) then disable=0

test_result = 1-have_windows();(!d.flags and 65536) eq 0 or !d.name ne 'X' 

if widget and  test_result then begin
	widget=0
	message,'Widgets are unavailable on this device.',continue=continue
endif

if keyword_set(test) then result = 1 - test_result else result = widget 
if fcheck(disable,0) then result = 0	;setting disable overrides everything!
return, result
end

