; plotman_format_int
; Written:  Kim Tolbert
; Modifications:
;	31-Aug-2001, Kim.  Use format_intervals function
; 9-Jan-2009, Kim.  int was ints+1, so text intervals # started with 1. Now start at 0.


function plotman_format_int, int_info, int_index=int_index

nint = int_info.nint
if nint le 0 then return, 'None'

se = *int_info.se

if exist(int_index) then ints = int_index else ints = indgen(nint)
int = strtrim (string (ints, format='(i4)'), 2)

if int_info.plot_type eq 'utplot' or int_info.plot_type eq 'specplot' then begin
	ut = 1
	utbase = int_info.utbase
endif else begin
	ut = 0
	format = '(f12.3)'
endelse

range = format_intervals (se[*,ints] + int_info.utbase, ut=ut, format=format)

desc = 'Interval ' + int + ',  ' + range
if n_elements (desc) eq 1 then desc = desc(0)
return, desc

end
