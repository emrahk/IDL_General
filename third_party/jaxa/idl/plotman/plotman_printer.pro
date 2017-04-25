pro plotman_printer_event, event

widget_control, event.id, get_uvalue=uvalue
widget_control, event.top, get_uvalue=info

widget_control, info.parent, get_uvalue=state

exit = 0
case uvalue of
	'printer': info.printer = (*info.printers)[event.index]

	'cancel': begin
		exit = 1
		info.cancel = 1
		end

	'print': begin
		exit = 1
		state.plotman_obj -> set, printer=info.printer
		widget_control, state.widgets.printid, send_event={id:state.widgets.printid, $
        	top:event.top, handler:0l}
        end

    'accept': begin
    	exit = 1
    	state.plotman_obj -> set, printer=info.printer
    	end

	else:
endcase


widget_control, event.top, set_uvalue=info

if exit then widget_control, event.top, /destroy

end



pro plotman_printer, event

widget_control, event.top, get_uvalue=state
parent = event.top

output_control = state.plotman_obj -> get (/output_control)

tlb = widget_base ( group_leader=parent, $
					title='Select Printer', $
					/column, $
					xpad=15, $
					ypad=15, $
					space=10 )

w_printer = widget_droplist ( tlb, $
					title='Select printer: ', $
					value=*output_control.printers, $
					uvalue='printer' )

q = where ( output_control.printer eq *output_control.printers, c)
if c eq 1 then widget_control, w_printer, set_droplist_select = q(0)

w_buttons = widget_base (tlb, $
					/row, $
					space=5, $
					/align_center )

w_cancel = widget_button (w_buttons, $
					value='Cancel', uvalue='cancel' )

w_print = widget_button (w_buttons, $
					value='Print', uvalue='print' )

w_accept = widget_button (w_buttons, $
					value='Accept', uvalue='accept' )

widget_control, tlb, /realize

info= {tlb: tlb, $
	parent: parent, $
	printers: output_control.printers, $
	printer: output_control.printer, $
	orig_printer: output_control.printer, $
	cancel: 0 }

widget_control, tlb, set_uvalue = info

xmanager, 'plotman_printer', tlb


;widget_control, tlb, get_uvalue = info

;if not info.cancel then return, info.printer else return, info.orig_printer

end