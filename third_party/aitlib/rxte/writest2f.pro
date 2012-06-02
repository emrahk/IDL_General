PRO writest2f,path=path,dirs=dirs,out=out, $
              object=object, $
              noback=noback,faint=faint,q6=q6,$
              earthvle=earthvle,skyvle=skyvle, $
              exclusive=exclusive,top=top, $
              nopcu0=nopcu0,fivepcu=fivepcu, $
              cass=cass,deadcorr=deadcorr,noerror=noerror
;+
; NAME:
;             writest2f
;
;
; PURPOSE:
;             read XTE/PCA standard2f lightcurves from different
;             subobservations and featuring different detector
;             combinations; merge them, with optional background and
;             deadtime correction; write merged lightcurve to FITS
;             file (using MJD and UTC); Poisson errors are included by
;             default  
;
;
; CATEGORY:
;             RXTE timing tools 
;
;
; CALLING SEQUENCE:
;             writest2f,path=path,dirs=dirs,out=out, $
;               object=object, $
;               noback=noback,faint=faint,q6=q6,$
;               earthvle=earthvle,skyvle=skyvle, $
;               exclusive=exclusive,top=top, $
;               nopcu0=nopcu0,fivepcu=fivepcu, $
;               cass=cass,deadcorr=deadcorr,noerror=noerror
;
;
;
; INPUTS:
;             path      : string, path to the directories containing
;                         the lightcurves to be merged and to the
;                         directory containing the merged lightcurve
;             dirs      : string array, directories containing
;                         the lightcurves to be merged  
;             out       : string, directory to contain the merged lightcurve 
;
;
; OPTIONAL INPUTS: 
;             object    : string, name of the source,
;                         default: ''   
;
; KEYWORD PARAMETERS:
;             noback    : if set, the merged lightcurve is not
;                         background corrected,
;                         default: noback=0, skyvle=1 (Cyg X-1!)
;             faint,q6,earthvle,,skyvle :
;                         if set, background subtraction using the
;                         according model background lightcurve is
;                         performed,
;                         default: noback=0, skyvle=1 (Cyg X-1!) 
;             exclusive : if set, only input lightcurve file names including
;                         '_excl' are considered,
;                         default: exclusive=0 
;             top       : if set, only input lightcurve file names including
;                         '_top' are considered, 
;                         default: top=0
;             nopcu0    : if set, only input lightcurve file names including
;                         '_ign0' are considered,
;                         note: deadtime correction algorithm is not
;                         correct for these lightcurves!
;                         default: nopcu0=0
;             fivepcu   : if set, normalize count rates wrt to whole
;                         PCA, i.e, wrt five PCUs
;                         default: fivepcu=0, i.e., give average count
;                         rate per PCU
;             cass      : if set, use CASS paths
;                         default: cass=0, i.e., use Tuebingen paths 
;             deadorr   : if set, the merged lightcurve is deadtime
;                         corrected,
;                         default: deadcorr=0
;             noerror   : if set, the merged lightcurve does not
;                         contain an error array,
;                         default: noerror=0 
; 
;
; OUTPUTS:
;             none, but see side effects
;
;
; OPTIONAL OUTPUTS:
;             none
;
;
; COMMON BLOCKS:
;             none
;
;
; SIDE EFFECTS:
;             writes the lightcurve to a FITS file, path and filename
;             are build using the following inputs: path, out,
;             (noback), (fivepcu), (deadcorr) 
; 
;
; RESTRICTIONS:
;             the lightcurves to be merged have to be named according
;             to the Tuebingen extraction scripts
;
;
; PROCEDURES USED:
;             readxtedata, writelc
;
;
; EXAMPLE:
;        path='/xtearray/xtescratch/katja/cygex/P50110/
;        dirs=['28.00','28.01','28.02','28.03']
;        out='28'
;        object='Cyg X-1'
;        writest2f,path=path,dirs=dirs,out=out,object=object, $
;                 /exclusive,/deadcorr 
;
;
; MODIFICATION HISTORY:
;             Version 1.1, 2001 Mar 22, Katja Pottschmidt 
;                          initial revision 
;             Version 1.2, 2001 Mar 22, Katja Pottschmidt 
;                          removed @ compilations
;             Version 1.3, 2001 Mar 22, Katja Pottschmidt 
;                          minor change in header
;             Version 1.4, 2001 May 09, Eckart Göhler
;                          added propagation of /faint keyword
;                          to readxtedata
;
;
;-

  IF (n_elements(object) EQ 0) THEN object=''

  check = n_elements(noback)+n_elements(faint)+n_elements(q6)
  check = check+n_elements(earthvle)+n_elements(skyvle)
  IF (check GT 1L) THEN message,'background model keywords not set correctly'
  IF (check EQ 0) THEN skyvle=1
   
  IF (n_elements(noback) EQ 0) THEN noback=0
  IF (n_elements(faint) EQ 0) THEN faint=0 
  IF (n_elements(q6) EQ 0) THEN q6=0
  IF (n_elements(earthvle) EQ 0) THEN earthvle=0
  IF (n_elements(skyvle) EQ 0) THEN skyvle=0
  
  IF (n_elements(exclusive) EQ 0) THEN exclusive=0
  IF (n_elements(top) EQ 0) THEN top=0
  IF (n_elements(nopcu0) EQ 0) THEN nopcu0=0
  IF (n_elements(fivepcu) EQ 0) THEN fivepcu=0
  
  IF (n_elements(deadcorr) EQ 0) THEN deadcorr=0 
  IF (n_elements(noerror) EQ 0) THEN noerror=0 
  IF (n_elements(cass) EQ 0) THEN cass=0
  
  readxtedata,t,c,path=path,dirs=dirs,/verbose, $
    noback=noback,q6=q6, $
    earthvle=earthvle,skyvle=skyvle, $
    exclusive=exclusive,top=top, $
    nopcu0=nopcu0,fivepcu=fivepcu, $
    cass=cass,deadcorr=deadcorr,faint=faint

;; write merged/deadtime-corrected lightcurve to file in file strucure
  file=out+'_st2f'
  IF (keyword_set(deadcorr)) THEN BEGIN 
       file=file+'_deadcorr'
  ENDIF 
  IF (noback EQ 0) THEN BEGIN 
       file=file+'_backcorr'
       backsub=1
  ENDIF 
  IF (keyword_set(fivepcu)) THEN BEGIN 
       file=file+'_fivenorm'
  ENDIF 
  file=file+'.lc'
  
  IF (NOT keyword_set(noerror)) THEN BEGIN 
       ;; determine Poisson error
       ;; (additionally important because lightcurve consists 
       ;; of different PCU combinations)
       bt=(t[1]-t[0])*2.4D1*3.6D3
       error=sqrt((c*bt))/bt
       writelc,t,c,error,file, $
         telescope='XTE',instrument='PCA',object=object, $
         /sysmjd,/utc, $
         backsub=backsub,deadcorr=deadcorr
  ENDIF ELSE BEGIN 
       writelc,t,c,file, $
         telescope='XTE',instrument='PCA',object=object, $
         /sysmjd,/utc, $
         backsub=backsub,deadcorr=deadcorr
  ENDELSE
  

END 




