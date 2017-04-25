;+
;
; NAME: goes_day_ascii
;
; PURPOSE: Read daily goes ascii file copied from ngdc
;
; CATEGORY:  GOES
;
; CALLING SEQUENCE: goes_day_ascii, file, header, data
;
; INPUT ARGUMENTS:
; file - file name to read
; 
; OUTPUT ARGUMENTS:
; header - structure containing start time of data and satellite number
; data - array of data with time, qual, qual, low-energy flux, high-energy flux
;   time is seconds relative to first time in array, which is in header structure
; time - array of double precision seconds since 79/1/1 of each data point (this is
;   the correct time, don't use time in data array)
;
; WRITTEN: Kim Tolbert 13-Apr-2010
;
; MODIFICATION HISTORY:
; 25-Jun-2012, Kim.  Return time array as doubles separately from data array.  Previously, 
; put time into data array which is float - caused error in msec portion toward end of day.  
; Leave 5 columns in the data array, but don't use time from that, use time array. Also,
; take care of incomplete file, by excluding lines with blanks in flux column.
;
;-

pro goes_day_ascii, files, file_sat, data, time

a = rd_ascii(files[0])

; Find satellite id
q = where(stregex(a,'satellite_id', /bool, /fold), n)
if n eq 0 then begin
 print,'ERROR - could not find satellite id field in file ' + filesl[0]
 return
endif
sat = (strsplit(a[q[0]], '"', /extract))[1]
sat = stregex(sat, '[0-9]+',/extract)

; Find line with data.  Data start 2 lines after that.
q = where (stregex(a, '^data',/bool, /fold))
cols = str2cols( a[q[0]+2:*],',', /unalign )

; Had case with an incomplete file, some columns missing from last line, don't use those lines
q = where (cols[6,*] ne '')  
cols = cols[*,q]

time = anytim(reform(cols[0,q]))
utstart = anytim(time[0,0],/date)

file_sat = fix(sat)

;Put 0's in for flags for now, until we determine if the flags have the same 
; meanings as they used to for earlier satellites
data = fltarr(5,n_elements(time))
data[0,*] = time - utstart  ; times rel to start of day (but in float, so not very accurate!)
data[1,*] = 0. ; fix(cols[1,*]) ; a_qual
data[2,*] = 0. ; fix(cols[4,*]) ; b_qual
data[3,*] = float(cols[6,*])  ; b_flux  low-energy flux
data[4,*] = float(cols[3,*])  ; a_flux  high-energy flux

return&end