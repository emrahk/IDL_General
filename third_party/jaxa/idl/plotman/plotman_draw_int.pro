pro plotman_draw_int, what, int_index=int_index, state_str, intervals=intervals, type=type, erase=erase

checkvar, erase, 0
checkvar, type, ''

if not obj_valid(state_str.plotman_obj) then begin
	message,'No plot created yet.', /cont
	return
endif

state_str.plotman_obj -> select

color_names = state_str.plotman_obj->get(/color_names)

; crange function takes log axes into account
xrange = crange('x')
yrange = crange('y')

; Determine whether state_str is the int_info structure (which it would be
; be if plotman_draw_int is called from the "define intervals" widget) or
; plotman's main state structure (which it would be if called from the main
; plotman widget).
; changed 11-mar-03 to look at intervals keyword instead
; If intervals keyword was passed in, then use intervals from there, not from state_str.
;if tag_exist (state_str, 'NEW_SE') then begin
if not keyword_set(intervals) then begin
	type = state_str.type

	if what eq 'all' then begin
		nint = state_str.nint
		if nint eq 0 then goto, getout
		se = *state_str.se
	endif else begin
		if exist(int_index) then begin
			x1 = (*state_str.se)[0,int_index] > xrange[0]
			x2 = (*state_str.se)[1,int_index] < xrange[1]
		endif else begin
			x1 = state_str.new_se[0] > xrange[0]
			x2 = state_str.new_se[1] < xrange[1]
		endelse
	endelse

	sav_graphics = state_str.sav_graphics

endif else begin

	; if called from main plotman widget, only valid option is to plot all intervals
	what = 'all'

	se = intervals
	if se[0] eq -1 then nint = 0 else begin
		if total(se(*,0) eq 0.) then nint = 0 else nint = n_elements(intervals[0,*])
	endelse
	if nint gt 0 then se = se - state_str.plotman_obj ->get(/utbase)

	device, get_graphics = sav_graphics

endelse

color = color_names.red
if type eq 'Background' then color = color_names.purple
if type eq 'Pre-bin' then color = color_names.blue

;print,'what, x1,x2 = ', what, ' ', x1,x2
;if erase then print,'erase ' else print,'not erase'

y1 = yrange[0]
y2 = yrange[1]

if erase then device, set_graphics=6 else device, set_graphics=7
catch, error_status
if error_status ne 0 then begin
	print, 'plotman_draw_int error message:  ', !err_string
	goto, reset_device
endif

thick = 1.5
psym = 0

case what of
	'start': begin
		oplot, [x1,x1], yrange, color=color_names.green, thick=thick, psym=psym
		end
	'end': begin
		oplot, [x2,x2], yrange, color=color_names.yellow, thick=thick, psym=psym
		polyfill, [x1,x2,x2,x1], [y1,y1,y2,y2], color=color
		end
	'interval': begin
		oplot, [x1,x1], yrange, color=color_names.green, thick=thick, psym=psym
		oplot, [x2,x2], yrange, color=color_names.yellow, thick=thick, psym=psym
		polyfill, [x1,x2,x2,x1], [y1,y1,y2,y2], color=color
		end
	'all': begin

		if nint gt 0 then begin

			for i = 0,nint-1 do begin
				x1 = se[0,i]  > xrange[0] < xrange[1]
				x2 = se[1,i]  < xrange[1] > xrange[0]
				oplot, [x1,x1], yrange, color=color_names.green, thick=thick, psym=psym
				oplot, [x2,x2], yrange, color=color_names.yellow, thick=thick, psym=psym
				polyfill, [x1,x2,x2,x1], [y1,y1,y2,y2], color=color
			endfor

		endif

		end

endcase

reset_device:
device, set_graphics=sav_graphics

getout:
state_str.plotman_obj -> unselect
end
