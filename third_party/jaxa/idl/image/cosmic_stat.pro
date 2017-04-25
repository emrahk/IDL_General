function cosmic_stat, index,  data,  threshold, correct=correct, $
   peak_spectra=peak_spectra, events=events, percent=percent, $
   debug=debug, width=width,  quiet=quiet, subfov=subfov
;+
;   Name: cosmic_stat
;
;   Purpose: return number of cosmic ray 'hits' or %affected area
;
;   Input Parameters:
;      index, data  - ssw standards (eit,sxt,trace,etc)
;
;   Output:
;     function returns number of detections per image or % if /PERCENT set
;
;   Keyword Parameters:
;      threshold - comparison cutoff (see spikes_id.pro) - default=50
;      percent (output) - percent pixels effected
;      percent (switch) - if set, function returns % instead of event counts
;      peak_spectra - 'spectrum' of image with largest event count
;      subfov - optional subfield to consider [x0,y0,nx,ny] 
;               (default=[0, 0, naxis1, naxis2]
;
;   Method:
;      call spikes_id for each image and return statistics
;
;   History:
;      Circa Jan 1997 - S.L.Freeland - EIT Proton counter
;      11-May-1999  - S.L.Freeland - documentation , generalized.
;      15-July-1999 - S.L.Freeland - assure zero events is reported correctly
;                     (incorrectly reported as one in previous versions)
;-  
debug=keyword_set(debug)
loud=1-keyword_set(quiet) or debug
  
nind=n_elements(index)
if n_elements(threshold) eq 0 then threshold=50.

if loud then box_message,'Using median threshold: ' + strtrim(threshold,2)

nevents=lonarr(nind)
peak=0

case 1 of 
   n_elements(subfov) eq 4: 
   else: subfov=[0, 0, data_chk(data,/nx), data_chk(data,/ny)]
endcase

estring='temp=data(subfov(0):subfov(2)-1,subfov(1):subfov(3)-1,i)'
i=0

estat=execute(estring)
npix=n_elements(temp)

for i=0, nind-1 do begin
   estat=execute(estring)
   events=spike_id(temp,threshold, width=width)
   nevents(i)=([n_elements(events),0])(events(0) eq -1)
   peak=max([peak,nevents(i)])                           ; track peak
   if peak eq nevents(i) and events(0) gt -1 then begin        ; save peak spectrum
     if loud then box_message,'Saving Peak Spectrum, Image: '+strtrim(i,2)
     peak_spectra=(data(*,*,i))(events)
   endif   
endfor

affected=float(nevents)/float(npix)*100.           ; % pixels effected
case 1 of
    data_chk(percent,/scalar): retval=affected     ; user wants %
    else: retval=nevents                           ; default is count
endcase
percent=temporary(affected)                        ; output via keyword

return, retval
end
