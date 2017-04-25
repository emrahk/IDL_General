;+
; Name:  store_intervals
;
; Purpose: Store a set of intervals in a text file
;
; Category: HESSI PLOTMAN
;
; Calling Sequence: store_intervals, intervals, ut=ut
;
;Explanation:  Used in the interval selection feature of PLOTMAN.  Called
;  by xsel_intervals.  Text file will contain intervals in the format
;  used by format_intervals routine.
;
; Inputs:
;	intervals - set of start/end values
;	ut - if set, interpret intervals as times.
;
; Outputs:
;
; History:
; Kim Tolbert, 2001
; 7-Jul-2008, Kim.  Renamed store_intervals from hsi_save_intervals and moved to ssw gen.
;
;-

pro store_intervals, intervals, ut=ut

file = keyword_set(ut) ? 'time_intervals.txt' : 'energy_intervals.txt'

text = format_intervals(intervals, ut=ut, /vms)

outfile = dialog_pickfile (path=curdir(),  $
			file=file, $
			title = 'Select file to save intervals in')

if outfile eq '' then begin
	a = dialog_message('No file name selected to store intervals.  Aborting.')
	return
endif

wrt_ascii, text, outfile, err_msg=err_msg

if err_msg ne '' then a=dialog_message(err_msg) else $
	a = dialog_message ('Intervals stored in file ' + outfile, /info )

end

