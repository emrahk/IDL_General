;+
;
; NAME: 
; 	XMENU_GEN_B_EV
;
; PURPOSE:
;       The event handler for XMENU_GEN_BUT
;
;
; RESTRICTIONS:
;	none
;
; HISTORY:
;	Written 31-Jan-95 by M.Morrison 
;-


pro xmenu_gen_b_ev, event
;
;
;
common xmenu_gen_b_blk, all		;to pass results back and forth from event driver

qrefresh = 1
qreset = 0
case (strtrim(event_name(event),2)) of
    "BUTTON" : begin
		all.result = strupcase(get_wvalue(event.id))
		widget_control, event.top,/destroy
	       end
endcase
;
end
;=======================================================================
;+
;
; NAME: 
;	XMENU_GEN_BUT
;
; PURPOSE:
;     	Allow user to pass an array of labels for buttons and allow user
;	to click on them to select a single option/item
;
; CALLING SEQUENCE:
;	result = xmenu_gen_but(array, group=group, tit=tit)
;	result = xmenu_gen_but(['Continue', 'Abort'])
;
; INPUTS:
;       ARRAY       A string or string array of values to be displayed for
;		    selection
; OPTIONAL KEYWORD INPUT:
;	TIT	    The title of the widget
;	GROUP	    The parent widget id (so that if the parent widget exits,
;		    this widget is destroyed too)
;	LOCATION    the location of the upper left corner relative to the
;		    upper left corner of the screen
; RESTRICTIONS:
;	Must have widgets available.
;
; HISTORY:
;	Written 31-Jan-95 by M.Morrison 
;	12-Jun-95 (MDM) - Added LOCATION keyword
;-
;
function xmenu_gen_but, array, tit=tit, group=group, instructions=instructions, $
		location=location
;
;
;
common xmenu_gen_b_blk, all	;to pass results back and forth from event driver


n  = n_elements(array)
if n eq 0 then return, ''

if (n_elements(tit) eq 0)    then tit = 'XMENU_GEN_BUT'
if (n_elements(group) eq 0)  then group = 0	;needed to avoid crash in widget_base call

all = { result: '', $
	base: 0L}

base = widget_base(title=tit, /column, group=group)
 
if (keyword_set(instructions)) then begin
    instruc = widget_base(base, /row, space=n_elements(instructions))
    labs = widget_base(instruc, /column)
    for i=0,n_elements(instructions)-1 do lab = widget_label(labs, value=instructions(i))
end

xmenu, array, base, /column


all.base    = base

widget_control,set_uvalue=all, base
if (n_elements(location) eq 2) then widget_control, base, tlb_set_xoffset=location(0), $
							  tlb_set_yoffset=location(1)
widget_control, base, /realize
xmanager, 'xmenu_gen_but', base, event_handler='xmenu_gen_b_ev', modal=(group ne 0), just_reg=(group ne 0)

return, all.result
end
