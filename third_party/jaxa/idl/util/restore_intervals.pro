;+
; Name:  restore_intervals
;
; Purpose: Read and return a set of intervals from a text file
;
; Category: HESSI PLOTMAN
;
; Calling Sequence: intervals = restore_intervals ([/ut])
;
;Explanation:  Used in the interval selection feature of PLOTMAN.  Called
;  by xsel_intervals.  Text file must contain intervals in the format
;  used by format_intervals routine.
;
; Inputs: ut - if set, interpret intervals as times.
;
; Outputs: start/end values of intervals are returned
;
; History:
; Kim Tolbert, 2001
; 7-Jul-2008, Kim.  Renamed restore_intervals from hsi_restore_intervals and moved to ssw gen.
;
;-

function restore_intervals, ut=ut


file = keyword_set(ut) ? 'time_intervals.txt' : 'energy_intervals.txt'

infile = dialog_pickfile (path=curdir(),  $
			file=file, $
			title = 'Select file to read intervals from')

if infile eq '' then begin
	a = dialog_message('No file name selected to restore intervals from.  Aborting.')
	return, -1
endif

text = rd_ascii (infile, error=error)

if error then begin
	a=dialog_message('Error reading intervals file ' + infile + '.  Aborting')
	return, -1
endif else begin
	int = unformat_intervals (text, ut=ut, err_msg=err_msg)
	if err_msg ne '' then begin
		a = dialog_message(err_msg)
		return, -1
	endif
	return, int
endelse

end

