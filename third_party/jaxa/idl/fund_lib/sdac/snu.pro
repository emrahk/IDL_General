;
;  FILE SNU.PRO
;
pro snu_event, event                         ;SNU event handler
common snu_widgets, wtext, d, snumb, maxsiz, snu_number, cerror

;-- get event type

widget_control, event.id, get_uvalue = uservalue
if (n_elements(uservalue) eq 0) then uservalue = ''
wtype = strmid(tag_names(event,/structure_name),7,1000)

case wtype of 
  'BUTTON' : begin
	   if uservalue eq 'DONE' then cerror=0 else cerror = 1
	   widget_control,event.top,/destroy		; either READY or
							; CANCEL results in
							; a /destroy
  end

  'LIST'   : begin
	digits = n_elements(d)-1 
	for i = 0, digits do $				; insert new value
	  if event.id eq d(i) then snumb(i) = event.index

	snu_number = strtrim(snumb(0),2)	; construct the number 
	for i = 1, digits do snu_number = snu_number + strtrim(snumb(i),2)

	widget_control,wtext,set_value = 'New selected value ' + snu_number

  end

  else :   

endcase
return & end

;------------------------------------------------------------------------------

function snu, digits, message=message, error=error, group_leader=group, initial=initial
common snu_widgets, wtext, d, snumb, maxsiz, snu_number, cerror
;+
; PROJECT:
;	SDAC
; NAME:
;	SNU
; PURPOSE:
;	This function returns a number selected from a widget interface.
; CATEGORY:
;	WIDGET, UTILITY
; ROUTINES CALLED: 
;	HAVE_WINDOWS, XDEVICE
; EXAMPLE:
;	Result = SNU( DIGITS, [MESSASGE=MESSAGE, ERROR=ERROR, GROUP_LEADER=GROUP])
;
; var = snu(digits)
;
; EXPLANATION:
;	Creates a widget for the user to click on value to construct a number
;	of length DIGITS. Previous value is saved and number of digits
;	may vary
;
; INPUTS :
;	DIGITS : the number of digits in the number to be contructed
; KEYWORDS : 
;	MESSAGE      : string or string array which will appear in widget
;	GROUP_LEADER : optional widget id of calling widget
;	INITIAL      : initial string of number, sets common and overrides digits if 
;		       it is too large
; OUTPUT :
;	ERROR      :  0 for successful completion
;		      1 for user cancelled
;	Function returns a string value constructed from the widget entries
;
; COMMON :
;       SNU_WIDGET :  remembers last number and interacts with event handler
;
; MODIFICATION HISTORY
;	NOV 1992 - Elaine Einfalt (HSTX)
;       Jul 1994 - richard.schwartz@gsfc.nasa.gov,  added initial keyword
;       27-may-1998 - richard.schwartz@gsfc.nasa.gov,  support all windowing os.
;-

on_error,2
cerror = 1					; assume it will fail

if n_elements(initial) eq 1 then begin
	maxsiz = fix(alog10(fcheck(long(initial),1))) + 1
	snumb = strtrim(reverse( initial / 10^indgen(maxsiz) mod 10),2)
endif

if n_elements(digits) eq 0 then return, snu_number

if n_elements(initial) eq 1 then digits = digits > fcheck(maxsiz,1)

if have_windows() eq 0 then message,'widgets are unavailable'
set_plot,xdevice()

if n_elements(group) eq 0 then widget_control,/reset else $
 if (xregistered('snu')) then return, snu_number            ;-register once

digits = 1 > digits

if n_elements(snumb) eq 0 then begin	; construct array in 1st pass
   snumb = strarr(digits)+'0'
   maxsiz = digits
endif

;ADD EXTRA DIGIT ON THE LEFT, NOT THE RIGHT, RAS, 27-JUL-1994
;if digits gt maxsiz then snumb = [snumb, strarr(digits-maxsiz)+'0'] ;old version
if digits gt maxsiz then snumb = [strarr(digits-maxsiz)+'0',snumb]
  
base = widget_base(TITLE = 'SELECT A NUMBER', XPAD = 20, YPAD = 20,$
                   SPACE = 10, /column )

loop = n_elements(message)-1
if loop ne -1 then begin
  inst_base = widget_base(base, /column)
  for i=0,loop do instr=widget_label(inst_base, value=message(i))
endif

snu_number = strtrim(snumb(0),2)	; construct the number 
for i = 1, digits-1 do snu_number = snu_number + strtrim(snumb(i),2)

wtext = widget_text(base,value = 'Last selected Value: ' + snu_number)

;-- 2nd row of buttons

row2 = widget_base(base,/row,space=10,xpad=20)   

places = widget_base(row2, /row, space=10, xpad=20, ypad=20)

d = lonarr(digits)
dig = string(indgen(10)) + '     '

for i = 0, digits-1 do d(i) = widget_list(places, value=dig, ysize=10)

;-- done button

contrls = widget_base(base, /column, space=15)
 done = widget_button(contrls, value='READY',uvalue='DONE',/no_release)
 cancel = widget_button(contrls, value='CANCEL',uvalue='CANCEL',/no_release)

;-- realize main widget

widget_control, base, /realize
xmanager, 'snu', base, group_leader=group, /modal

error = cerror					; assign error condition

return,snu_number
end
