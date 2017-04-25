;
; NAME: 
; 	XMENU_SEL_EV
;
; PURPOSE:
;       The event handler for XMENU_SEL
;
; ROUTINES CALLED:
;       event_name
;       get_wvalue
;       tbeep
;       xmenu_sel_lab
;
; RESTRICTIONS:
;	none
;
; HISTORY:
;	Written 30-Jan-95 by M.Morrison using Elaine Einfalt
;	YO_TAPE_WIDG as a starting point


pro xmenu_sel_ev, event
;
;
;
common xmenu_sel_blk, all

widget_control, event.top, get_uvalue=all
n = n_elements(all.status)

qrefresh = 0
case (strtrim(event_name(event),2)) of
    "BUTTON" : begin
       case strupcase(get_wvalue(event.id)) of
	'QUIT': begin
                widget_control, event.top,/destroy
            endcase
	'SELECT ALL': begin
		if (all.qone) then begin
		    tbeep, 3
		    print, 'Sorry... You are only allowed to select a single item'
		end else begin
		    all.status = 1		;set them all as active
		end
		qrefresh = 1
	    endcase
	'RESET ALL': begin
		all.status = 0		;reset them all
		qrefresh = 1
	    endcase
	'ALL BETWEEN LAST 2': begin
		if (min(all.last_two) eq -1) then begin
		    tbeep, 3
		    print, 'You must select two items before pressing "ALL BETWEEN LAST 2"
		end else begin
		    i1 = all.last_two(0)<all.last_two(1)
		    i2 = all.last_two(1)>all.last_two(0)
		    all.status(i1:i2) = 1
		    qrefresh = 1
		end
	    endcase
	else: print, 'Dont recognize button ', strupcase(get_wvalue(event.id))
      endcase
     end
   "LIST": begin
		i1 = event.index
		all.status(i1) = abs(all.status(i1)-1)		;toggle the value
		all.last_two(0) = all.last_two(1)
		all.last_two(1) = i1
		qrefresh = 1
	   end
			;;for i = frst, secnd do widget_control, butt(i), /set_button 
   else: print, 'Dont regognize', (strtrim(event_name(event),2))
endcase

if (qrefresh) then begin
    xmenu_sel_lab, all, lab
    ii = widget_info(all.id_list, /list_top)
    widget_control, all.id_list, set_value=lab, set_list_top=ii
end
;
widget_control, event.top, set_uvalue=all, bad_id=destroyed      ;update structure holding all of the info
;
if (all.qone) and (strtrim(event_name(event),2) eq 'LIST') then begin
    widget_control, event.top,/destroy		;all done - got the single one that was needed
end
;
end
;=======================================================================
pro xmenu_sel_lab, all, lab
;
;
;
n = n_elements(all.status)
ss = where(all.status)
lead = strarr(n) + '   '
if (ss(0) ne -1) then lead(ss) = '* '
;
lab = lead + all.list
end
;=======================================================================
;+
;
; NAME: 
;	XMENU_SEL
;
; PURPOSE:
;     	Allow user to select a set of items from a list.  Widget equivalent
;	of WMENU_SEL
;
; CALLING SEQUENCE:
;       ss = xmenu_sel(array)
;       ss = xmenu_sel(array, /one)
;       ss = xmenu_sel(array, /fixed) - use fixed font (keep column alignement)
;
; INPUTS:
;       ARRAY       A string or string array of values to be displayed for
;		    selection
; OPTIONAL KEYWORD INPUT:
;	ONE	    If set then only one button may be turned on at a time.
;	TIT	    The title of the widget
;	GROUP	    The parent widget id (so that if the parent widget exits,
;		    this widget is destroyed too)
;       FIXED_FONT  If set, use fixed font (keep columns aligned)
;       SIZE_FONT   Size of (fixed) font to use - default=15 (implies /FIXED)
;       NLINES      How many lines to display.  Default is 20
;
; OUTPUTS:
;	The result returns the select indices of the array ARRAY.
;
; ROUTINES CALLED:
;       wmenu_sel
;       get_xfont
;
; RESTRICTIONS:
;	Must have widgets available.
;
; HISTORY:
;	Written 30-Jan-95 by M.Morrison using Elaine Einfalt
;	YO_TAPE_WIDG as a starting point
;	10-Jul-96 (MDM) - Ajustment to make the output scaler if it
;			  is a single item
;       11-nov-96 (SLF) - add FIXED_FONT and SIZE_FONT keywords
;	15-Apr-97 (MDM) - Re-added the 9-Jan-97 (MDM) modification
;			  to merge with 11-Nov-96 version
;			      9-Jan-97 (MDM) - Added NLINES option
;	22-Jul-97 (MDM) - Added call to WMENU_SEL if the device is
;			  not X (so that terminal prompting is
;			  enabled.
;-
;
function xmenu_sel, array, one=one, tit=tit, group=group, $
   fixed_font=fixed_font, size_font=size_font, nlines=nlines
;
;
if (!d.name ne 'X') then begin		;MDM added 22-Jul-97
    out = wmenu_sel(array, one=one)
    return, out
end
;
;
common xmenu_sel_blk, all	;to pass results back and forth from event driver

if (n_elements(nlines) eq 0) then nlines = 20

n_el   = n_elements(array)
if n_el eq 0 then return, -1

all = {status: bytarr(n_el), $
	list: string(array), $
	last_two: intarr(2)-1, $
	qone: 0B, $
	id_list: 0L, $
	base: 0L}

if (n_elements(tit) eq 0) then tit = ''
if (n_elements(group) eq 0) then group = 0	;needed to avoid crash in widget_base call

base = widget_base(title='XMENU_SEL'+tit, /column, xpad=20, ypad=20, group=group)
 
xmenu, ['QUIT', 'Select All', 'Reset All', 'All Between last 2'], $
        base, /row

instruc = widget_base(base, /row, space=10)
labs = widget_base(instruc, /column)
lab = widget_label(labs, value='Selection is made by pointing and ')
lab = widget_label(labs, value='clicking on the desired item.')
if keyword_set(one) then begin
    lab = widget_label(labs, value='You can only select a single item')
end else begin
    lab = widget_label(labs, value='A "*" preceding the item indicates it is selected')
    lab = widget_label(labs, value='Select as many as desired, or none,')
end
lab = widget_label(labs, value='Click on QUIT to exit')
               
xmenu_sel_lab, all, lab
ba_base = widget_base(base, /column)

fixed=keyword_set(fixed_font) or keyword_set(size_font)

if fixed then begin
   if n_elements(size_font) eq 0 then size_font=15
   listit = widget_list(ba_base, value=lab, ysize=nlines<n_el, /frame, $
            font=get_xfont(/only_one,/fixed,closest=size_font))
endif else listit = widget_list(ba_base, value=lab, ysize=nlines<n_el, /frame)

all.id_list = listit
all.qone    = keyword_set(one)
all.base    = base

widget_control,set_uvalue=all, base
widget_control, base, /realize
xmanager, 'xmenu_sel', base, event_handler='xmenu_sel_ev', modal=(group ne 0), just_reg=(group ne 0)

out = where(all.status)
if (n_elements(out) eq 1) then out = out(0)	;make it a scalar
return, out
end
