PRO LC_OM, path, time,rate,error, exposures=exposures, $
           mjd=mjd, binning=binning, header=header
;+
; NAME:
;       LC_OM
;
;
; PURPOSE:
;      Get all OM lightcurves
;
;
; CATEGORY:
;      XMM
;
;
; CALLING SEQUENCE:
;         LC_OM, PATH, TIME,RATE,ERROR, EXPOSURES=EXPOSURES, back=back
;
;
; INPUTS:
;     - path : where to look for OM lightcurves
;
;
; OPTIONAL INPUTS:
;     - exposures : which exposure ID's to use
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;    - time: contains time in MJD [TBD]
;    - rate: background corrected rate [counts]
;
; OPTIONAL OUTPUTS:
;    - error: error of exposure
;    - header: fits header information of first HDU.
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;          
;
;		
;
;-

;path="../om/ODF/"

; are exposures given?
; yes -> select:
if n_elements(exposures) gt 0 then begin
    ; look for given exposures in path:
    files=""
    for i=0,n_elements(exposures)-1 do begin
        file=FINDFILE(path+"*"+exposures[i]+ $
                          "TIMESR*.FIT",         $
                          count=file_count)
        if file_count eq 0 then $
          message,  "File for exposure "+exposures[i]+ " not found"
        files=[files,file]; append file found
    endfor
    files=files[1:n_elements(files)-1]

endif else begin ; -> no exposures given: take all:
    ;; look for exposures in path:
    files=FINDFILE(path+"*TIMESR*.FIT", count=file_count)
    if (file_count eq 0) then message, "Error: Files not found"
endelse                         ;



; first entry for array concatenation
time=0
rate=0
base_rate=0
error=0

 FOR i = 0, n_elements(files)-1 DO BEGIN 
         print, "Reading: "+files[i]
         readlc,t,r,e,files[i]         

         ;; rebin data if desired
         if n_elements(binning) ne 0 then begin
             ;; rebin data:
             ;; skip data at end of read set not fitting into binning:
             r=r[0:n_elements(r)-1-n_elements(r) MOD BINNING]
             t=t[0:n_elements(t)-1-n_elements(t) MOD BINNING]
             e=e[0:n_elements(t)-1-n_elements(t) MOD BINNING]

             ;; use binned elements of t
             t=t[where(indgen(n_elements(t)) MOD BINNING EQ 0)]
             r=rebin(r,n_elements(r) / BINNING)
             e=rebin(e,n_elements(e) / BINNING)
         endif

         ;; compute error:
         ;; root of input rate, divided by binning:
         if n_elements(binning) ne 0 then $
           error=[error,e/sqrt(BINNING)] else $
           error=[error,e]


         rate=[rate,r]

         if keyword_set(mjd) then begin
             ;; convert to MJD:
             CCD_FHRD,files[i],'MJDREF',reftime,extension=1
             t=t/86400.D0+reftime
         endif

         time=[time,t]
 ENDFOR 

 ;; read header
 dummy=readfits(files[0],header,/silent)

 ; delete first dummy element:
 time=time[1:*]
 rate=rate[1:*]

 ;; resort input:
 sort_index=sort(time)
 time=time[sort_index]
 rate=rate[sort_index]
 error=error[sort_index]

END


