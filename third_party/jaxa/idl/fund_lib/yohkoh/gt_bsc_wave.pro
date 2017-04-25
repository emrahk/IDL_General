;+
; NAME:
;       GT_BSC_WAVE
; PURPOSE:
;       return nominal wavelength arrays for BSC spectra
; CALLING SEQUENCE:
;       WAVE=GT_BSC_WAVE(BSC_INDEX,BSC_DATA)
; INPUTS:
;       BSC_INDEX    - BSC index structure or channel array 
;       BSC_DATA     - BSC data
; KEYWORDS:
;       SMM - set for SMM-BCS wavelengths
;       NOZERO - extract nonzero wavelengths
; OUTPUTS:
;       WAVE         - wavelength array (A)
; HISTORY:
;       Written Aug'93 by D. Zarro (ARC)
;       Modified Mar'94, D. Zarro, added SMM keyword
;       Modified Jan'95, D. Zarro, added NOZERO keyword
;-


function gt_bsc_wave,bsc_index,bsc_data,smm=smm,nozero=nozero

on_error,1


if (n_params() eq 0) then begin
 message,'invalid index or data entered',/contin
 message,'usage ---> WAVE=GT_BSC_WAVE(BSC_INDEX,[BSC_DATA])
endif

;-- check inputs

yes_data=bsc_check(bsc_index,bsc_data) and (n_params() eq 2)

;-- data input?

if yes_data then begin
 tags=tag_names(bsc_data)
 chk=where('WAVE' eq tags,count)
 if count ne 0 then return, bsc_data.wave
endif

;-- index input?

dtype=datatype(bsc_index,2)
yes_chan=(dtype ge 1) and (dtype le 5)  and (n_params() eq 1)
if not yes_chan then begin
 yes_index = bsc_check(bsc_index)
 if not yes_index then message,'Invalid Channel Structure'
 chan = gt_bsc_chan(bsc_index)
 smm=string(bsc_index(0).bsc.st$spacecraft) eq 'SMM'
endif else begin
 chan = bsc_index
 smm=keyword_set(smm)
endelse

;-- channel input

if smm then max_chan=8 else max_chan=4
ok=where((chan ge 1) and (chan le max_chan),count)
if count eq 0 then message,'invalid channel number(s) entered'
if count ne n_elements(chan) then $
 message,'skipping invalid BCS channel numbers',/contin

chan=chan(ok) 
chan_uniq = gt_bsc_chan(chan,/uniq,smm=smm)   ; Get uniq channel numbers
ndset= n_elements(chan)
maxb = 256
wave = fltarr(maxb,ndset)

for i=0,n_elements(chan_uniq)-1 do begin
 jj = where(chan eq chan_uniq(i),count)
 if smm then wave_temp=bda_wave(chan_uniq(i)) else begin
  bincal = gt_bsc_bincal(chan_uniq(i))		; Use default modeid
  wave_temp = bincal.wave
 endelse
 for j=0,n_elements(jj)-1 do wave(0,jj(j)) = wave_temp
endfor

;-- remove zero values in single channel case

if (n_elements(chan_uniq) eq 1) and (ndset eq 1) and $
   (keyword_set(nozero)) then begin
 ok=where(wave gt 0,cnt)
 if cnt gt 0 then wave=wave(where(wave gt 0))
endif

return,wave

end
