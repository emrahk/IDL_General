@tripp_exist
PRO TRIPP_SIMFAST, vorlage=vorlage, $   ;;file aus dem Zeitmarken kommen
                   nr_datapts=nr_datapts, $
                   multiple=multiple, silent=silent,                          $
                   toffset=toffset, tnoise=tnoise, seed=seed,            $
                   ft_min=ft_min, ft_max=ft_max, p_min=p_min, p_max=p_max,    $
                   nr_per=nr_per , nif = nif,                               $
                   notes=notes, scsmooth=scsmooth,slow=slow
;+
; NAME:          
;                  TRIPP_SIMFAST
;
;
;
; PURPOSE:         
;                  Did what should now be taken over by the /multiple
;                  keyword for SCARGLE: produce multiple white noise
;                  light curves and pre-process them
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:    
;                      program makes sense only when using VORLAGE !
;                    -> Simulations for one  specific data set !!!
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
;                    Version 1.1, 2000/11/22: SLS, new scargle from
;                                             aitlib is used
;                    Version 1.2, 2001/02   : SLS, nr_datapts is not
;                                             mandatory any more
;
;-

;; ---------------------------------------------------------
;; --- SET DEFAULT PARAMETERS
;;
  
  on_error,2                    ;Return to caller if an error occurs
  
  TRIPP_SETSIMPAR,   multiple=multiple, toffset=toffset, seed=seed, $
    nr_datapts=nr_datapts
  
  ;; --- supply wc if not given: length of data file
  IF EXIST(vorlage) THEN  BEGIN 
    spawn,' wc '+vorlage+' >length'
    get_lun,unit
    openr,unit,'length'
    readf,unit,all
    free_lun,unit
    spawn,' rm -f length'
    all=fix(all)
    IF nr_datapts GT all THEN BEGIN
      nr_datapts = all
    ENDIF 
    PRINT,"% TRIPP_SIMFAST: Using "+strtrim(string(nr_datapts),2)+$
      " out of "+strtrim(string(all),2)+" data points."         
  ENDIF
  
  
;; ---------------------------------------------------------
;; --- READ INPUT FILE (VORLAGE)
;;
   helparray = dblarr(2 , long(nr_datapts))
   get_lun,unit
   openr,unit,vorlage	
   READF,unit,helparray
   free_lun,unit
;; --- determine standard deviation
   result = moment(helparray[1,*])
   noise = sqrt(result[1]) 
   Print, "% TRIPP_SIMFAST: Standard Deviation of the light curve: " + STRTRIM(STRING(noise),2)
   
;; ---------------------------------------------------------
;; --- IMPORTANT VARIABLE: TIME
;;
   tclear = helparray[0,*]
   
;; ---------------------------------------------------------
;; --- MORE DEFAULTS
;;   
;; --- estimate cycletime:
   nr     = n_elements(tclear)-1
   tdiff  = fltarr(nr)
   FOR i=1,nr DO BEGIN
       tdiff[i-1]=(tclear[i]-tclear[i-1])*86400.d0
   ENDFOR
   cycletime = median(tdiff) 
;; ---  want to have sampled the shortest period at least twice and 
;; want to have sampled at least two full cycles of the longest period
   IF NOT EXIST(nr_per)   THEN nr_per = 2.
   IF NOT EXIST(p_max)    THEN  p_max = (tclear[nr]-tclear[0])*86400.d0/nr_per
   IF NOT EXIST(p_min)    THEN  p_min = 2.*cycletime
   IF NOT EXIST(ft_min)   THEN ft_min = 1.e6/p_max
   IF NOT EXIST(ft_max)   THEN ft_max = 1.e6/p_min
   IF NOT EXIST(nif)      THEN BEGIN
       nif = 10.*(tclear[nr]-tclear[0])*86400.d0/cycletime
       PRINT,'% TRIPP_SIMFAST: Of all '+STRTRIM(STRING(nif),2)+' frequency points,'
       ;; dann noch mit p_min,p_max bzw. ft_min, ft_max passend ausschneiden 
       nif = nr_per / (86400.d0*(tclear[nr]-tclear[0])) + $
         findgen(nif)/(nif-1)  * $
           (.5/cycletime - nr_per/(86400.d0*(tclear[nr]-tclear[0]))  ) 
;       freq= ft_min*1.e-6*nr_per + findgen(nif)/(nif-1) * 1.e-6 *
;       (ft_max - ft_min*nr_per) 
       nif  = n_elements(    where(nif GE ft_min*1.e-6 AND nif LE ft_max*1.e-6)     )
   ENDIF
   IF string(nif) NE 'horne' THEN numf=nif
   IF NOT EXIST(scsmooth) THEN scsmooth = 1  
   
; Erzeuge Lichtkurve die nur aus weissem Rauschen besteht
;; ---------------------------------------------------------
;; --- CALL SCARGLE, multiple=multiple:   D  O  SIMULATIONS !
;;   
   simfap=0.1
   SCARGLE,(tclear-tclear[0])*86400.d0,helparray[1,*], om, psd,  $
     psdpeaksort=psdpeaksort, multiple=multiple, noise=noise, $
     numf=numf, fmin=ft_min*1.e-6, fmax=ft_max*1.e-6 ,        $
     fap=simfap, simsigni=simsigni,/debug, slow=slow

;; ---------------------------------------------------------
;; --- save psdpeaksort to idl save file
;;
   saveFile = vorlage + "_smooth"+STRTRIM(STRING(scsmooth),2) + "_many_idl.psd_short"
   
    
   save,psdpeaksort,filename=saveFile
   PRINT, "% TRIPP_SIMFAST: SAVING "+saveFile

;; ---------------------------------------------------------
;; --- END
;;
END










