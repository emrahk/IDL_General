;+ FIND_FITS_BAD
; Finds the element numbers in tarray and yarray that have bad points that
; need to be eliminated and interpolated over.  Bad points means any of the
; following are true:
;   1. flux value is -99999.
;   2. the moon is eclipsing the Sun
;   3. the detector is off
;   4. the detector is being calibrated
;   5. the channel is going through a gain change
; The bad elements numbers are returned for channels 0 and 1 in bad0 and bad1.
;
; Kim Tolbert 7/13/93
; Modifications:
; 9-Dec-2005 - stop printing the whoops message if no times match status times. With
;   new goes obj, could have status from a large time interval, but tarray from a subset.
; 19-Apr-2007, Kim.  replaced loop looking for matching times in tarray and tstat by
;   match routine - MUCH faster.  Also don't do status check if no good values found in array.
; 15-Aug-2008, Kim. Move lstat = long(stat) to after numstat check, since we always call this now
;
;-
pro find_fits_bad, tarray, yarray, bad0, bad1, numstat, tstat, stat

;for i=0,n_elements(tstat)-1 do print,atime(tstat(i)),' ',stat(i,0),stat(i,1),$
;   form='(2a,2o10)'

; Set bit patterns for eclipse, detector off, calibration mode, and gain
; change for two channels.
eclipse = '1000'o
detoff = '1'o
calib = '2'o
gainch = ['20'o, '40'o]

for ich = 0,1 do begin
   ; first look for bad values (-99999.)
   bad = where (yarray(*,ich) eq -99999., ncomplement=ngood)

   ; if there were any good values, and if we have the status information, do this
   if ngood gt 0 and numstat gt 0 then begin

     ; Convert status words from float to long words so we can examine bits
     ; using AND operator.
     lstat = long(stat)

	   statbad = where((lstat(*,0) and eclipse) or (lstat(*,1) and detoff) or $
	                (lstat(*,1) and calib) or (lstat(*,1) and gainch(ich)), nstatbad)

	   ; Tarray might just cover a subset of the tstat times (if we did a
	   ; small time interval within a larger interval already accumulated).
	   ; For the tstat times with bad status, find matching times in tarray, elements
	   ;  are returned in newbad.  Merge those with bad array.
	   if nstatbad gt 0 then begin
		   match, tarray, tstat[statbad], newbad, count=count
		   if count gt 0 then bad = get_uniq( [bad, newbad] )
	   endif

	endif

   if ich eq 0 then bad0 = bad else bad1 = bad
   ;print,'in find_fits_bad, chan=',ich,'  bad=',bad
endfor

return&end
