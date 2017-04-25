;+
;
; NAME: 
; 	XMENU_GEN_I_EV
;
; PURPOSE:
;       The event handler for XMENU_GEN_INPUT
;
;
; RESTRICTIONS:
;	none
;
; HISTORY:
;	Written 30-Jan-95 by M.Morrison 
;-


pro xmenu_gen_i_ev, event
;
;
;
common xmenu_gen_i_blk, all	;to pass results back and forth from event driver

widget_control, event.top, get_uvalue=all

qrefresh = 1
qreset = 0
case (strtrim(event_name(event),2)) of
    "BUTTON" : begin
       case strupcase(get_wvalue(event.id)) of
	'QUIT': begin
		qkill = 1
		qrefresh = 1
            endcase
	'RESET ALL': begin
		qreset = 1
	    endcase
	else: print, 'Dont recognize button ', strupcase(get_wvalue(event.id))
      endcase
     end
			;;for i = frst, secnd do widget_control, butt(i), /set_button 
   "TEXT_CH": begin
	   	qrefresh = 1
	   end

   else: print, 'Dont regognize', (strtrim(event_name(event),2))
endcase

if (qrefresh) then begin
    n = n_elements(all.list)
    for i=0,n-1 do begin
	for j=0,all.ninputs-1 do begin
	    id = all.id_text(j,i)			;widget ID of the block
	    if (qreset) then newv = '' else $
			newv = get_wvalue(id)		;current value in the block
	    all.out(j,i) = newv				;save it away in the output structure
	    widget_control, id, set_value=newv		;update the value on the screen
	end
    end
end
;
if (keyword_set(qkill)) then widget_control, event.top,/destroy
widget_control, event.top, set_uvalue=all, bad_id=destroyed      ;update structure holding all of the info
;
end
;=======================================================================
;+
;
; NAME: 
;	XMENU_GEN_INPUT
;
; PURPOSE:
;     	Allow user to pass an array of labels and to allow users to 
;	modify 1 to 5 fields
;
; CALLING SEQUENCE:
;	xmenu_gen_input, array, out1, out2, out3, nchar=nchar, group=group, tit=tit
;	xmenu_gen_input, mnem, ymin, ymax, labels=['YMIN: ','YMAX: ']
;
; INPUTS:
;       ARRAY       A string or string array of values to be displayed for
;		    selection
; OPTIONAL KEYWORD INPUT:
;	TIT	    The title of the widget
;	GROUP	    The parent widget id (so that if the parent widget exits,
;		    this widget is destroyed too)
;
; INPUT/OUTPUT:
;	out1	    The default input and the output for what the user entered
;	out2	    The default input and the output for what the user entered
;	out3	    The default input and the output for what the user entered
;
; RESTRICTIONS:
;	Must have widgets available.
;
; HISTORY:
;	Written 30-Jan-95 by M.Morrison 
;-
;
pro xmenu_gen_input, array, out1, out2, out3, out4, out5, out6, $
			nchar=nchar, instructions=instructions, labels=labels, tit=tit, group=group
;
;
;
common xmenu_gen_i_blk, all	;to pass results back and forth from event driver


n  = n_elements(array)
if n eq 0 then return

ninputs = n_params()-1
if (n_elements(labels) eq 0) then labels = strarr(ninputs)
if (n_elements(nchar) eq 0)  then nchar = intarr(ninputs)+10
if (n_elements(tit) eq 0)    then tit = ''
if (n_elements(group) eq 0)  then group = 0	;needed to avoid crash in widget_base call

all = { list: string(array), $
	out:  strarr(ninputs, n), $
	id_text: lonarr(ninputs,n), $
	ninputs: ninputs, $
	base: 0L}


base = widget_base(title='XMENU_GEN_INPUT'+tit, /column, group=group)
 
xmenu, ['QUIT', 'Reset All'], $
        base, /row

instruc = widget_base(base, /row, space=10)
labs = widget_base(instruc, /column)
for i=0,n_elements(instructions)-1 do lab = widget_label(labs, value=instructions(i))
lab = widget_label(labs, value='Click on QUIT to exit')

;--------------

for i=0,n-1 do begin
    oneline  = widget_base(base, /row)
    for j=0,ninputs-1 do begin
	if (j eq 0) then str = array(i) + '   ' else str = ''
	str = str + labels(j)
	xx = widget_label(oneline, value = str)
	id = widget_text(oneline, /editable, xsize=nchar(j), ysize=1)
	all.id_text(j,i) = id
	;
	;---- initialize the value
	;
	cmd = 'nnn = n_elements(out' + strtrim(j+1,2) + ')'
	stat = execute(cmd)
	if (nnn ne 0) then begin
	    cmd = 'val = out' + strtrim(j+1,2) + '(' + strtrim(i,2) + ')'
	    stat = execute(cmd)
	    widget_control, id, set_value=val
	end
    end
end

all.base    = base

widget_control,set_uvalue=all, base
widget_control, base, /realize
xmanager, 'xmenu_gen_input', base, event_handler='xmenu_gen_i_ev', modal=(group ne 0), just_reg=(group ne 0)

for i=0,ninputs-1 do begin
    if (n gt 1) then cmd = 'out' + strtrim(i+1,2) + ' = reform(all.out(i,*))' $
		else cmd = 'out' + strtrim(i+1,2) + ' = all.out(i,*)'
    stat = execute(cmd)
end

end
