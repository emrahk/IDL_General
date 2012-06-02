PRO TRIPP_WRITE_WETSTANDARD, logName
;+
; NAME:
;	TRIPP_WRITE_WETSTANDARD
;
;
; PURPOSE:   
;   
;	Write data from photometrical time series to ascii file in WET
;	standard format:
;       time, object flux, skyflux @ object, comparison stars' fluxes,
;       skyflux @ comparison stars
;
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_WRITE_WETSTANDARD, LOGNAME = logName
;
;   
; INPUTS:
;	
;       IDL SAVE file *.FLX
;
;
; OUTPUTS:
;   
;       ASCII file *.WET
;
;
;	
; RESTRICTIONS:
;   
;       file type:      FLX as produced by TRIPP_EXTRACT_FLUX or CCD_PRED
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 2000/11, Sonja L. Schuh
;       Version 1.0, 2001/05, Sonja L. Schuh, adapted to frame
;                             transfer method (keywords frame*) 
;                    2001/08, SLS, modJD was wrong, has to say redJD!
;                    2001/08, SLS, old format provoqued a linebreak if
;                             "too many" or "too little" (i.e not
;                             exactly 3) reference stars were present;
;                             fixed
;                    2002/10, SLS, complete change of format to get as
;                             close as possible to WET specifications:
;                             omit sky substraction and give sky
;                             values for all stars seperatly
;                             - expect further changes in the time
;                             format depending on not yet specified
;                             WET requirements! 
;
;-

;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_WETSTANDARD:     No logfile or datafile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_WETSTANDARD:     The specified logfile or datafile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0] 
      PRINT, '% TRIPP_WRITE_WETSTANDARD:     Using logfile/datafile ', logname 
    ENDIF
  ENDELSE

;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
   TRIPP_READ_IMAGE_LOG, logName, log
   
;; ---------------------------------------------------------
;; --- DEFINITIONS I ---
;;
IF (NOT EXIST(n_sigma)) THEN n_sigma = 5

rad      = DBLARR( log.extr_nrr )        

;; ---------------------------------------------------------
;; --- READ FLUX FILE ---
;;
   fluxFile = log.out_path + '/' + log.flux 
   
   RESTORE, fluxFile
   
;; fluxFile wurde hergestellt ueber 
;; SAVE, filename=fluxFile, fluxs, fluxb, areas, areab, rad, hside, flag, $
;;                          time, shift, sname, starID, files, $
;;                          framenumbers, frameshift
   
;; ---------------------------------------------------------
;; --- DEFINITIONS II ---
;;
   IF NOT EXIST(framenumbers) THEN framenumbers = 1
   IF NOT EXIST(frameshift)   THEN frameshift   = 0
   flux     = DBLARR( log.mask_nrs,log.nr*framenumbers )
   fluxsky  = DBLARR( log.mask_nrs,log.nr*framenumbers )

   ;; ====================================================
   
   wetFile   = log.out_path + '/' + log.block +'.wet'
   s = where(float(rad[*]) EQ float(log.relflx_sr))       
   sel_rad          = rad[s] 
   
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Input flux file           : " + fluxFile
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Output WET file           : " + wetFile
   
   
;; ---------------------------------------------------------    
;; --- REDUCE SOURCEFLUXES: REDUCEDFLUX =       ---
;; --- SOURCEFLUX - (SKALIERTER BACKGROUNDFLUX) ---
;;
   FOR k = 0,log.mask_nrs -1 DO BEGIN                      ;; ueber alle Quellen
       idx            = WHERE( areab[k,*] NE 0 )    
       flux   [k,idx] = fluxs[k,idx,s] 
       fluxsky[k,idx] = areas[k,idx,s]/areab[k,idx]*fluxb[k,idx]
   ENDFOR
   
   
;; ---------------------------------------------------------
;; --- CLEAN DATA
;;
   idx     = where(flux[0,*] NE 0.)
   tclean  = time      [idx]
   fclean  = flux    [*,idx]
   sclean  = fluxsky [*,idx]

   dim     = size (tclean)
;; ---------------------------------------------------------
;; --- CORRECT FOR TIME SHIFT 
;;
   tshift  = log.extr_tshft/86400.
   tclean  = tclean + tshift
;; ---------------------------------------------------------
;; --- SAVE RESULT
;;
   
   
   telescope=''
   observer=''
   instrument=''
   target=''
   filter=''
   integrationtime=''
   cycletime=''
   UTstart=''
   
   
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter telescope" 
   read,telescope
   telescope=strtrim(telescope,1)
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter observer" 
   read,observer
   observer=strtrim(observer,1)
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter instrument" 
   read,instrument
   instrument=strtrim(instrument,1)
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter target" 
   read,target
   target=strtrim(target,1)
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter filter" 
   read,filter
   filter=strtrim(filter,1)
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter integrationtime" 
   read,integrationtime
   integrationtime=strtrim(integrationtime,1)
   PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter cycletime" 
   read,cycletime
   cycletime=strtrim(cycletime,1)
   CCD_FHRD,STRTRIM(log.in_path,2)+'/'+STRTRIM(log.first,2),'DATE-OBS',date
   UTstart=date
   IF NOT EXIST(UTstart) THEN BEGIN
       PRINT, "% TRIPP_WRITE_WETSTANDARD: Getting UT automatically failed. Please:"
       PRINT, "% TRIPP_WRITE_WETSTANDARD: Enter UTstart" 
       read,UTstart
   ENDIF
   UTstart=strtrim(UTstart,1)
   
   refs=strarr(log.mask_nrs)
   refs_0='* Red.JulianDate'
   refs[0]='* = JD - 2400000  REF1=Target    SKY1        '
   FOR k=1,log.mask_nrs-1 DO refs[k]='   REF'+STRTRIM(string(k+1),2)+$
     '           SKY'+STRTRIM(string(k+1),2)+'        '
   
   GET_LUN, unit
   OPENW, unit, wetFile
   
   PRINTF, unit,'* File ',wetFile
   PRINTF, unit,'* ************************************************************'
   PRINTF, unit,'* Telescope:               ',telescope
   PRINTF, unit,'* Observer:                ',observer
   PRINTF, unit,'* Instrument:              ',instrument
   PRINTF, unit,'* Target:                  ',target
   PRINTF, unit,'* Filter:                  ',filter
   PRINTF, unit,'* Integration time:        ',integrationtime
   PRINTF, unit,'* Cycle time:              ',cycletime
   PRINTF, unit,'* UTstart of 1st exposure: ',UTstart
   PRINTF, unit,'* Extraction radius (pix): ',STRTRIM(string(sel_rad),2)
   PRINTF, unit,'* ************************************************************'
   PRINTF, unit,'* Input flux file (raw counts) was '+ log.flux
   PRINTF, unit,'* "Flux" values are given in counts.'
   PRINTF, unit,'* See '+log.block+'_raw.ps for a graphical representation.' 
   PRINTF, unit,'* Sky value has been scaled to star apertures (REF1 to REF'$
     +STRTRIM(log.mask_nrs,2)+') in the following table.'
   PRINTF, unit,'* See '+log.block+'_mask.ps for identification of REF1 to REF'$
     +STRTRIM(log.mask_nrs,2)+'.'
   PRINTF, unit,'* See '+log.block+'.dat     for REF1-SKY1 / [sum(REFs-SKYs)]' 
   PRINTF, unit,'* See '+log.block+'.fin     for REF1-SKY1 / [sum(REFs-SKYs)] '+$
     '(normalised) with bad data points removed'
   PRINTF, unit,'* See also '+log.block+'_fin.ps'
   PRINTF, unit,'* ************************************************************'
   PRINTF, unit,'* Length of the following table: ',dim[1]
   PRINTF, unit,refs_0
   PRINTF, unit,refs[*],$
     format='(a'+strtrim(string(strlen(refs[0])),2)+','+$
     strtrim(string(n_elements(refs[*])-2),2)+'a'+strtrim(string(strlen(refs[1])),2)+','+$
     'a'+strtrim(string(strlen(refs[n_elements(refs)-1])),2)+')' 
   
   FOR i=0,dim[1]-1 DO BEGIN
       somany=2*n_elements(fclean[*,i])
       line=dblarr(somany)
       FOR m=0,somany-1,2 DO line[m]=[fclean[m/2,i]]
       FOR m=1,somany-1,2 DO line[m]=[sclean[m/2,i]]
       PRINTF,unit,tclean[i],line[*],$
         format='(f15.5,'+strtrim(string(dim[1]-1),2)+'f15.5)'
   ENDFOR
   PRINTF, unit,'EOF'
   FREE_LUN, unit
   
   
   PRINT, " "
   PRINT, "% TRIPP_WRITE_WETSTANDARD: result for selected extraction radius # "$
     + STRTRIM(string(sel_rad),2) + " saved to "+wetFile
   PRINT, "% ==========================================================================================="
   PRINT, " "                  
       
       
   ;;====================================================
   
;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------




























