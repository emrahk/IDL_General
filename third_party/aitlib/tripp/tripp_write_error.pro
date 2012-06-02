PRO TRIPP_WRITE_ERROR, logName, silent=silent, closest=closest
;+
; NAME:
;	TRIPP_WRITE_ERROR
;
; PURPOSE:   
;   
;	Compute error of lightcurve by interpolating reference star deviations.
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_WRITE_ERROR, LOGNAME = logName
;   
; INPUTS:
;	
;       - IDL SAVE file *.RMS (created by tripp_calc_relflux,
;                              contains time/fneu)
;       - IDL SAVE file *.FIN (created by tripp_write_final,
;                              contains modified tclear/fclear)
;
;
; OUTPUTS:
;   
;	ASCII file '*.err' containing error values for all data points.
;	               The file contains the time/flux information
;	               also for convenience but are copied only from
;	               the *.fin file.
;	               Columns are:
;	               TIME | FLUX | ERROR
;	               
;	IDL file '*_idl.err' - Contains the error column stored in an
;                              IDL save file. The only variable saved
;                              is "error". 
;
;
; OPTIONAL KEYWORDS:
;       silent - Do not ask wether to reject a reference star. Do also
;                not plot intermediate results.
;
;       closest - Look for closest error data point for all fluxes.
;	               
;
;	
; RESTRICTIONS:
;   
;       file type:      RMS as produced by TRIPP_CALC_RELFLUX (or ccd_rms
;                       or ccd_rms_multi, in principle) 
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;       $Log: tripp_write_error.pro,v $
;       Revision 1.9  2003/03/13 10:32:42  goehler
;       added CLOSEST option to look for closest error instead of using inter/extrapolation.
;       In cases of low source fluxes it is prudent to overestimate the error with this option.
;
;       Revision 1.8  2003/02/20 16:50:27  goehler
;       now also cleaned data may be selected to be used as reference (this is also a good test
;       whether tripp_write_final was used properly)
;
;       Revision 1.7  2003/02/20 16:48:57  goehler
;
;       Revision 1.6  2002/11/12 13:26:14  goehler
;       made more error-prone (ranges fixed, check ref-star existence)
;
;       Revision 1.5  2002/09/18 08:42:44  schuh
;
;        Modified Files:
;        	tripp_write_error.pro  inf file -> fin file
;
;       Revision 1.4  2002/09/18 08:01:11  goehler
;       Change: use *.fin results instead *.dat thus adding the error
;       to the final product.
;
;       Revision 1.3  2002/09/17 14:35:49  goehler
;       fix of silent logic
;
;       Revision 1.2  2002/09/17 14:06:09  goehler
;       cosmetics
;
;       Revision 1.1  2002/09/17 13:44:15  goehler
;       Initial version.
;       Derived from S. Dreizlers tripp_measure_sigma.pro.
;

;-


;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

; on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_ERROR:   No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_ERROR:   The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_WRITE_ERROR:   Using Logfile ', logname 
    ENDIF
  ENDELSE


;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log


;; ---------------------------------------------------------
;; --- READ RMS FILE ---
;;
rmsFile         = log.out_path + '/' + log.relflx
errFile         = log.out_path + '/' + log.block + ".err"
idlFile         = log.out_path + '/' + log.block + "_idl.err" 


RESTORE, rmsFile

if n_elements(fneu[*,0]) le 2 then $
	Message, "Could not process error for single reference star. Exit."


;; ---------------------------------------------------------
;; --- READ DATA FILE CONTAINING CLEANED FLUX ---
;;
finFile         = log.out_path + '/' + log.block + "_idl.fin" 

RESTORE, finFile



PRINT, " "
PRINT, "% TRIPP_WRITE_ERROR: Input rms  file      : " + rmsFile
PRINT, "% TRIPP_WRITE_ERROR: Input fin  file      : " + finFile
PRINT, "% TRIPP_WRITE_ERROR: Output data files    : " + errFile
PRINT, "% TRIPP_WRITE_ERROR:                        " + idlFile
PRINT, " "


;; ---------------------------------------------------------
;; --- MAKE SHURE THE DATA ARE TIME SORTED               ---
;;
index = sort(time)
time = time[index]
fneu = fneu[*,index]


;; ---------------------------------------------------------
;; --- DEFINE INDEX OF CLEANED DATA POINTS VIA TIME COMPARISON
;; --- (UGLY!)

;; get the time shift applied in tripp_write_final:
IF strpos(strtrim(logName,2),'.dat') NE -1 THEN BEGIN 
    extr_tshft = log.extr_tshft
ENDIF ELSE BEGIN
    extr_tshft = 0.
ENDELSE 

print,extr_tshft

tshift  = extr_tshft/86400.d

;; get index of data 
tmin = dblarr(n_elements(time))

;; look for closest time in respect of tclear:
FOR i = 0,n_elements(time)-1 DO BEGIN 
    tmin[i] = min(abs(time[i] + tshift - tclear))
ENDFOR 


;; index of data also contained in tclean
clean_index = where(tmin LT 1.D/86400.D0)



;; ---------------------------------------------------------
;; --- COMPUTE STANDARD DEVIATIONS FOR ALL REFERENCE STARS
;; --- AND PLOT THEM


;; sdev_mean - the error dependecy:
;; column 0: mean of lightcurves for all reference stars
;; column 1: standard deviation of lightcurves for all reference stars
sdev_mean = dblarr(n_elements(fneu[*,1])-1,2)

FOR i=1,n_elements(fneu[*,1])-1 DO BEGIN 


    input = ""
    index = indgen(n_elements(time))

    REPEAT BEGIN 

        ;; plot reference star lightcuves:
        IF NOT keyword_set(silent) THEN $
          plot,time[index]-time(0), fneu[i,index],  xtitle="Time", $
          ytitle="Relative flux of reference star "+strtrim(string(i))

        moment = moment(fneu[i,index],/double)
        mean  = moment[0]    
        sdev  = sqrt(moment[1])


        ;; ---------------------------------------------------------
        ;; --- COMPUTE STANDARD DEVIATION FROM FLUX VARIATIONS
    
        print,'TRIPP_WRITE_ERROR: Mean:', mean
        print,'TRIPP_WRITE_ERROR: Sdev:', sdev



        ;; options for rejection/selection:
        IF NOT keyword_set(silent) THEN BEGIN     
            print,'TRIPP_WRITE_ERROR: press return to continue'
            print,'TRIPP_WRITE_ERROR: or "r" to reject'
            print,'TRIPP_WRITE_ERROR: or "c" to use cleaned data'
            
            read,">", input
        ENDIF 

        ;; look for keyword:
        ;; 1.) use cleaned data:
        IF strupcase(input) EQ "C" THEN $
          index = clean_index

    ENDREP UNTIL strupcase(input) EQ  "R" OR strupcase(input) EQ ""
        
    IF strupcase(input) NE "R" THEN BEGIN 
        sdev_mean[i-1,0]=mean
        sdev_mean[i-1,1]=sdev
    ENDIF 
        
ENDFOR 


;; --------------------------------------------------------- ---
;; SORT MEAN/STDEV RELATION:
index = sort(sdev_mean[*,0])
sdev_mean=sdev_mean[index,*]


;; --------------------------------------------------------- ---
;; PLOT MEAN/STDEV RELATION:

IF NOT keyword_set(silent) THEN $
  plot,sdev_mean[*,0],sdev_mean[*,1],xrange=[0,1],psym=-4, $
  xtitle="Relative flux", ytitle="relative error"


;; --------------------------------------------------------- ---
;; INTERPOLATE ERROR:


;; perform fit:
fitpar = linfit(sdev_mean[*,0],sdev_mean[*,1],/double)

;; compute error from light curve for all data points:
error = fclear*fitpar[1] + fitpar[0]

IF keyword_set(closest) THEN BEGIN 
    FOR i = 0,n_elements(fclear)-1 DO BEGIN 
         dummy = min(sdev_mean[*,0] - fclear[i],minind)
         error[i] = sdev_mean[minind,1]
    ENDFOR  
ENDIF 

;; show also: source lightcurve values:
index = sort(tclear)

IF NOT keyword_set(silent) THEN $
  oplot,fclear[index], error[index], color=200


;; --------------------------------------------------------- ---
;; WRITE LIGHTCURVE+ERROR TO ASCII FILE:

  
  GET_LUN, unit
  OPENW, unit, errFile
  FOR  k = 0L, n_elements(tclear) -1  DO BEGIN
    PRINTF, unit, tclear[k], fclear[k],error[k],format='(f14.6,f14.6, F14.6)'
  ENDFOR
  
  FREE_LUN, unit

;; --------------------------------------------------------- ---
;; WRITE LIGHTCURVE+ERROR TO IDL FILE:

  SAVE, error, filename=idlFile


END 
