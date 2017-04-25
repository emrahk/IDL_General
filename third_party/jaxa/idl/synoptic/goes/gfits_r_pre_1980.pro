;+
; Name: gfits_r_pre_1980
;
; Purpose: Read monthly GOES files copied from NOAA for 1975-1980 and return
;   time, data, and bad data arrays.
;
; Notes:
; In secmonth and flagword, 32711000  means bad value. (note there are also 0s sometimes)
; In xs, xl, 32700,32711 mean missing, zero, or bad data.
; xs,xl must be scaled by 10.^(val/1000.)
; Flagword:
;   MOD(FLAGWORD,16)         DATA FLAG                                 
;   MOD(FLAGWORD/16,256)     DATA PROCESSING ERROR FLAG                
;   MOD(FLAGWORD/4096,1000)  SATELLITE COMMAND STATE                   
;   FLAGWORD/4096/1000   ARCHIVE VERSION NUMBER (0-9)                                                                                     
;     IN DATA FLAG: 1 - INDICATES CORRECTED SINGLE POINT ERROR, 2 -   
;     INDICATES CALIBRATION DATA, 4 - INDICATES A SWITCH IN INSTRUMENT   
;     SENSITIVITY, 8 - INDICATES AN ECLIPSE WAS IN PROGRESS. 
; Some of the files had times that went beyond the month the files was named for,
; I decided to cut them off and only take times within the month.
; 
; Input Arguments:
;  stime_sec, etime_sec - start, end time of current accumulation in sec rel to 79/1/1
;  file - fully qualified file name to read
;  index_array - starting index in tarray, yarray to store data from this file (in case
;     we cross a file boundary and need to call this file more than once)
;
; Input and Output Arguments:
;  tarray - time array of points within start,end time selected in sec rel to 79/1/1
;  yarray - (n,2) 2-channel data corresponding to tarray
;  tstat - times of bad points in sec rel to 79/1/1
;  stat - status words (here all contain 2 just to indicate bad) corresponding to tstat
;
; Output Arguments:
;  num_obs_pts - number of new values added to tarray, yarray in this call
;  edges - wavelength edges of two channels
;
; Written: Kim Tolbert 8-Aug-2008
;
;-

pro gfits_r_pre_1980, stime_sec, etime_sec, $
  file, tarray, yarray, index_array, tstat, stat, num_obs_pts, edges

d = mrdfits(file, 1, header)

file_basetime = anytim(dmy2ymd( fxpar(header, 'DATE-OBS') ))
ex = anytim(file_basetime, /ext, /date_only)
ex[4]=1
month_start = anytim(ex) ; first second of month
ex[5] = ex[5]+1
month_end = anytim(ex) -1 ;last second of month
 

;ex = anytim(

; if times are bad, remove those elements from structure completely
bad = where (d.secmonth ge 32711000 or d.secmonth le 0., c, complement=good)
if c gt 0 then d = temporary(d[good])

; find all conditions where data needs to be interpolated
bad = where (  (d.flagword ge 32711000)  or $ ; missing or bad data
               (d.flagword and 2) or $ ; calibration data
               (d.flagword and 4) or $ ; switch in instrument sensitivity
               (d.flagword and 8), c)    ; eclipse in progress               
               
; above are all the conditions we want to flag, but we'll flag them all with
; 2 which is checked in find_fits_bad.  Doesn't matter after this which
; condition it was.              
if c gt 0 then begin
  tstat = [tstat, temporary(d[bad].secmonth)] + month_start
  stat = [stat, fltarr(c,2) + 2 ]
endif
             
; since these files are monthly, find subset that's in requested times here
; even though we don't need to (will be done in gfits_r) just to reduce array sizes.  
; Also, make sure we don't go beyond month boundaries.  Some files go into the next month,
; don't know why, and that causes crash because tarray was dimensioned for the # requested days.               
tfile = temporary(d.secmonth) + month_start
q = where ((tfile gt (stime_sec-3. > month_start)) and (tfile lt (etime_sec < month_end)), num_obs_pts)

if num_obs_pts gt 0 then begin 
  
  tarray[index_array] = tfile[q]   
  yarray[index_array,0] = temporary( 10.^(d[q].xl/1000.) )
  yarray[index_array,1] = temporary( 10.^(d[q].xs/1000.) )
    
  ; set points that are positive (should be ~-7000), or are in 
  ; calibration mode to -99999 so they will be interpolated over.  
  bad0 = where ( (d[q].xl ge 0) or (d[q].flagword and 2), c)
  if c gt 0 then yarray[index_array+q[bad0],0] = -99999.
  bad1 = where ( (d[q].xs ge 0) or (d[q].flagword and 2), c)
  if c gt 0 then yarray[index_array+bad1,1] = -99999.
  
  ; Whenever there's a gain change, set that data point and the next 5 data points
  ; to -99999 so they will be interpolated over.  Changes in gain take ~6 points
  ; to quiet down.  Don't have info about which channel is changing, so do this
  ; for both channels for each gain change in flagwords.
  sw = where(d[q].flagword and 4,c)
  if c gt 0 then begin
    z=[sw, sw+1,sw+2,sw+3,sw+4,sw+5]
    z=get_uniq(z[sort(z)] < n_elements(q))
    yarray[index_array+z,0] = -99999.
    yarray[index_array+z,1] = -99999.
  endif
endif

edges = [ [1.,8.], [.5, 4.] ] ; Angstroms, wavelength bin for each channel
end
