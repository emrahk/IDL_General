;+
; Name: oplot_xmarkers
;
; Purpose: Overplot interval markers.  Different line style used for start/end lines.
;
; Category: display
;
; Input:
; intervals = [2,n] array of [start,end] values to mark If ut, then intervals should either
;   be fully qualified times, or seconds relative to 1-Jan-1979. (If ut is set, then the base 
;   time of the current plot will be subtracted from intervals to get the x plot values.)
; ut - if set, intervals should be treated as times
;
; Written: Kim Tolbert, January 2009
; Modifications:
;
;------------------------------------------------------------------------------------------

pro oplot_xmarkers, intervals=intervals, ut=ut

if intervals[0] eq -1 then return

if keyword_set(ut) then intervals = anytim(intervals) - getutbase()

for ir = 0,n_elements(intervals)/2. -1 do begin
  oplot, [intervals[0,ir],intervals[0,ir]], crange('y'), psym=0, linestyle=1
  oplot, [intervals[1,ir],intervals[1,ir]], crange('y'), psym=0, linestyle=2
  empty ; empty plot buffer.  On linux, last line wasn't getting drawn.
endfor

end
      