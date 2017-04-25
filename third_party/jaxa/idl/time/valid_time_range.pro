;+
; Name: valid_time_range
;
; Purpose: Function to determine if time range is a valid absolute time range
;
; Calling sequence:
;	valid = valid_time_range(timerange)
;
; Inputs:
;	timerange - 2 element vector of times
;
; Outputs :
;   valid = 1/0 if valid/invalid
;
; Keywords:
;   None
;
; Restrictions:  Only usable for times after 12 Jan 1979 (checks if time is greater than
;   1.e6 to make sure it's an absolute time)
;
; Written: 2-Nov-2000, Kim Tolbert
;-

;----------------------------------------------------------------------------------------------------------------------------

function valid_time_range, timerange

if n_elements(timerange) ne 2 then begin
	err = 'syntax: valid = valid_time_range(timerange)    timerange is 2-element vector''
	return,0b
endif

test = anytim(timerange, error=error)
if error then return, 0b

if not valid_range(anytim(timerange)) then return, 0b

;if min(anytim(timerange)) lt 1.e6 then return, 0b

return, 1b

end