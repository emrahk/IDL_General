;+
; PROJECT:
;	SDAC
; NAME:
;	GOES_Y_AVERAGE
;
; PURPOSE:
;       Get the average value of an array of displayed y values during a selected
;	interval.
;
; CATEGORY:
;       UTILITY, GEN, GRAPHICS
;
; CALLING SEQUENCE:
;       GOES_Y_AVERAGE, Tarray, Yarray, Average
;
; CALLS:
;       MARK_REGION, ATIME, GETUTBASE
;
; INPUTS:
;   Tarray:		X-axis array
;	Yarray:		Y-axis array
;
; OUTPUTS:
;   Average:	Average of y values in specified interval.
;	More outputs in keyword format.
;
; KEYWORDS:
;       STIME_STR:      Interval starting time string: 'dd-Mon-yy hh:mm:ss.xxx' (output).
;	ETIME_STR:	Interval ending time string: 'dd-Mon-yy hh:mm:ss.xxx' (output).
;	WMESSAGE:       If set, instructions on marking using mouse with
;			non-X device will be displayed.	(input)
;	ERROR:          0 if no error, 1 if error (output).
;
; PROCEDURE:
;	goes_y_average gets the average value of an array of y values during a
;	specified interval.  Assumes that a time plot has been drawn.
;	mark_region is called to bring up cursor to allow user to specify
;	start and end time of region. Result is returned in average.
;
; MODIFICATION HISTORY:
;       Written by ??
;	Mod. 08/13/96 by RCJ. Added documentation.
;	ras, 3-3-2003, change variable average to yaverage
;   Sandhia Bansal - 07/07/2005, added kind as a counter to the where clause in the
;                                   for loop where we are searching for tarray inside
;                                   the bck_interval array.
;   Kim, 14-nov-2005.  Got rid of kind counter - only reflected most recent where count
;     Instead, start with ind=-1, append indices within times, then sort and get rid of -1.
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-
pro goes_y_average, tarray, yarray, yaverage,  $
   bck_intervals=bck_intervals, $
   wmessage=wmessage, error=error

error = 0

sizey = size(yarray)
if sizey(0) eq 0 then begin
   print,'Second argument must be an array'
   error = 1
   return
endif

nchan = 1
if sizey(0) eq 2 then nchan = sizey(2)
yaverage = fltarr(nchan)

nelem = n_elements(bck_intervals) / 2
;ind = where ((tarray ge bck_intervals[0,0]) and (tarray le bck_intervals[1,0]), kind)
ind = -1
for i=0, nelem-1 do $
   ind = [ind, where ((tarray ge bck_intervals[0,i]) and (tarray le bck_intervals[1,i]))]

ind = get_uniq(ind)
if n_elements(ind) gt 1 then begin
   ind = ind[1:*]   ; get rid of leading -1
   yvals = yarray(ind,*)
   for ich=0,nchan-1 do yaverage(ich) = $
      total(yvals(*,ich)) / n_elements(yvals(*,ich))
endif else print,'No data in selected interval.  Average set to 0.'

if nchan eq 1 then yaverage = yaverage(0)


getout:
end
