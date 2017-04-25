;+
; PROJECT:
;	SDAC
; NAME:
;	Y_AVERAGE
;
; PURPOSE:
;       Get the average value of an array of displayed y values during a selected
;	interval.
;
; CATEGORY:
;       UTILITY, GEN, GRAPHICS
;
; CALLING SEQUENCE:
;       Y_AVERAGE, Tarray, Yarray, Average
;
; CALLS:
;       MARK_REGION, ATIME, GETUTBASE
;
; INPUTS:
;       Tarray:		X-axis array
;	Yarray:		Y-axis array
;
; OUTPUTS:
;       Average:	Average of y values in specified interval.
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
;	y_average gets the average value of an array of y values during a 
;	specified interval.  Assumes that a time plot has been drawn.  
;	mark_region is called to bring up cursor to allow user to specify 
;	start and end time of region. Result is returned in average.
;
; MODIFICATION HISTORY:
;       Written by ??
;	Mod. 08/13/96 by RCJ. Added documentation.
;	ras, 3-3-2003, change variable average to yaverage
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-
pro y_average, tarray, yarray, yaverage, stime_str=stime_str, $
   etime_str=etime_str, wmessage=wmessage, error=error

error = 0

sizey = size(yarray)
if sizey(0) eq 0 then begin
   print,'Second argument must be an array'
   error = 1
   goto, getout
endif

nchan = 1
if sizey(0) eq 2 then nchan = sizey(2)
yaverage = fltarr(nchan)

mark_region, stime, etime, wmessage=wmessage

ind = where ((tarray ge stime) and (tarray le etime), kind)
if kind gt 0 then begin
   yvals = yarray(ind,*)
   for ich=0,nchan-1 do yaverage(ich) = $
      total(yvals(*,ich)) / n_elements(yvals(*,ich))
endif else print,'No data in selected interval.  Average set to 0.'

if nchan eq 1 then yaverage = yaverage(0)

stime_str = atime(stime+getutbase(0))
etime_str = atime(etime+getutbase(0))

getout:
end
