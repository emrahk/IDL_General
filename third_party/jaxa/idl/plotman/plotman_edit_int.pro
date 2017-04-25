;+
; Name:
;
; Purpose: Edit a list of intervals in plotman.
;
; Category: HESSI PLOTMAN WIDGETS
;
; Calling Sequence:  plotman_edit_int, int_index=int_index, int_info, err_msg=err_msg
;
; Explanation: Called by xsel_intervals and plotman__intervals
;
; Inputs:
;
; Outputs:
;
; Modifications:
;	13-Sep-2001, Kim.  Added correction for end time because just has time, no date
;   31-Jan-2002, Kim.  Don't check if times are > utbase (if use time plot from obssumm, for
;     example, utbase might be after intervals).  And return times rel to utbase, not absolute.
;   15-Jul-2002, Kim.  Call xtextedit with a specific font
;   15-Aug-2003, Kim.  Previously looking for 'Interval' to find good lines.  Now just find lines
;      that aren't blank after being compressed.
;	20-Jun-2005, Kim.  Added explanation of interval formats to xtextedit call
;   6-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont to remove hessi dependencies.
;  27-Sep-2010, William Thompson, use [] indexing
;-

pro plotman_edit_int, int_index=int_index, int_info, err_msg=err_msg

err_msg = ''

utbase = int_info.utbase

list = plotman_format_int (int_index=int_index, int_info)
get_font, font
xtextedit, list, font=font, $
	explanation=["Use 'to' or '-' as separators.  Examples: ", $
		'10. - 20.', $
		'10-20', $
		'20-Feb-2002 11:05:15.629 to 11:05:19.960', $
		'Interval 1,  20-Feb-2002 11:06 - 11:08', $
		"(for times, blanks around '-' separator are required)"]

q = where(strcompress(list,/remove) ne '', count)
;q = where (strpos(list, 'Interval') ne -1, count)
if count eq 0 then remove=1 else remove=0

if not remove then begin
	ut = int_info.plot_type eq 'utplot' or int_info.plot_type eq 'specplot'
	int = unformat_intervals (list[q], ut=ut, err_msg=err_msg)
	if err_msg ne '' then begin
		err_msg = err_msg + ' Not saving edited intervals.'
		a=dialog_message (err_msg, /error)
		return
	endif
	;if ut then if (where(int lt utbase))[0] ne -1 then goto, error_exit
endif

if exist(int_index) then begin
	if remove then begin
		plotman_modify_int, 'delete', int_info, int_index=int_index
	endif else begin
		(*int_info.se)[*,int_index] = int - utbase
	endelse

endif else begin
	if remove then begin
		plotman_modify_int, 'delete', int_info
	endif else begin
		int_info.nint = n_elements(int[0,*])
		*int_info.se =  int - utbase
	endelse

endelse

return

end
