;+
; Name: plotman_list_int
; Routine to refresh widgets showing current intervals and total number of intervals.
; Gets widget ids out if int_info structure.
;
; Written 30-Jan_2001, Kim.  Previously this was being done by plotman_modify_int every time
;   a new interval was added.  Now add new intervals, and then call this once afterwards (on Unix
;   took forever to update widget list for each new interval).
;-

pro plotman_list_int, int_info

list = plotman_format_int (int_info)

if xalive(int_info.w_list) then widget_control, int_info.w_list, set_value=list
if xalive(int_info.w_total) then widget_control, int_info.w_total, set_value='# intervals = ' + strtrim(int_info.nint,2)

end