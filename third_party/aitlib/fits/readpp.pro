PRO readpp,phase,rate,rateerr,channel,phafile,exposure=exposure,$
           telescope=telescope,instrument=instrument,filter=filter,$
           object=object,ra=ra,dec=dec,equinox=equinox,radecsys=radecsys,$
           date_obs=date_obs,time_obs=time_obs,$
           date_end=date_end,time_end=time_end,$
           tstart=tstart,tstop=tstop,mjd=mjd,$
           origin=origin,verbose=verbose
;+
; NAME:
;       readpp
;
;
; PURPOSE:
;       Read PHA-spectrum from a OGIP-conformant PHA2-file. The file
;       format has been defined in OGIP memo ...
;
;
; CATEGORY:
;       High energy astrophysics
;
;
; CALLING SEQUENCE:
;       readpp,phase,rate,rateerr,channel,phafile
; 
; INPUTS:
;       channel : Channel number(s) to use for the returned count(-err)
;                 Either a single number, or a 2-dim array which is
;                 interpreted as [cmin,cmax].
;                 (Note: this is compared to the SPEC_NUM column and not
;                        necessarily equal to the row number)
;       phafile : Name of the file to read from
;
;
; OPTIONAL INPUTS:
;       none
;
;
; KEYWORD PARAMETERS:
;       see the list under optional outputs
;       verbose   : Be talkative
;       mjd       : Calculate tstart,tstop in MJD instead of JD
;
; OUTPUTS:
;       phase   : array of pulse phase values
;       rate    : count rates in each phasebin
;       rateerr : uncertainty of the countrate per phasebin
;                 
;
; OPTIONAL OUTPUTS:
;       exposure  : exposure time per phasebin
;       telescope : ID of telescope
;       instrument: ID of instrument
;       filter    : filter used 
;       object    : name of observed object
;       ra,dec    : position of observed object (degrees!), implies:
;       equinox   :     equinox os coordinate
;       radecsys  :     coordinate-frame used 
;       date_obs  : start-time (dd/mm/yy), UTC, implies
;       time_obs  :     start-time (hh:mm:ss), UTC
;       date_end  :     end-time (dd/mm/yy), UTC
;       time_end  :     end-time (hh:mm:ss), UTC
;       tstart,tstop: the above in JD (or in MJD if mjd keyword is set)
;       origin    : institution where file originates from
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       none
;
;
; RESTRICTIONS:
;       * All spectra in PHA-II table must have same channels
;       * Rather complex tool
;       * Very limited error handling
;
;
; PROCEDURE:
;       just read it!!!!!!
;
;
; EXAMPLE:
;       not needed
;
;
; MODIFICATION HISTORY:
;       Version 1.0: 1999/11/10, PK
;                    first version, based on readpha2.pro V1.1
;-
   ;;
   ;; Save name
   ;;
   filename= phafile
   ;;
   ;; Read Spectrum Extension
   ;;
   fxbopen,unit,filename,'SPECTRUM',header
   ;;
   ;; READ PHA extension
   ;;
   ;; ... header
   aa=''
   getpar,header,'HDUCLAS1',aa
   IF (aa NE 'SPECTRUM') THEN BEGIN 
       error,'Extension does not contain a spectrum'
   ENDIF 
   getpar,header,'HDUCLASS',aa
   IF (strtrim(aa,2) NE 'OGIP' AND keyword_set(verbose)) THEN BEGIN 
       print,'Warning: Extension HDUCLASS does not contain OGIP'
   ENDIF 
   getpar,header,'HDUVERS1',aa
   IF (strtrim(aa,2) NE '1.1.0' AND keyword_set(verbose)) THEN BEGIN
       print,'Warning, version number of Format is '+aaa+', not 1.1.0'
   ENDIF 
   ;; check if we have a PHA2 spectrum 
   getpar,header,'HDUCLAS3',aa
   aa=strtrim(aa,2)
   IF (aa NE 'TYPE:II' AND keyword_set(verbose)) THEN BEGIN
       print, 'Warning, HDUCLAS3 is '+aa+' and not TYPE:II as expected'
   ENDIF

   ;; see if we have COUNT or RATE spectra
   getpar,header,'HDUCLAS4',aa
   aa=strtrim(aa,2)
   spectype=-1
   IF (aa EQ 'RATE') THEN spectype=0
   IF (aa EQ 'COUNT') THEN spectype=1
   IF (spectype EQ -1 AND keyword_set(verbose)) THEN BEGIN 
       print, 'Warning, HDUCLAS3 not RATE or COUNT, assuming COUNT'
       spectype=1
   ENDIF 
;;   getpar,header,'PHAVERSN',aa
;;   aa=strtrim(aa,2)
;;   IF (aa NE '1992a' AND keyword_set(verbose)) THEN BEGIN 
;;       print,'Warning, OGIP version number is '+aa+',not 1992a'
;;   ENDIF 


   ;; get keyword parameters
   getpar,header,'TELESCOP',telescope
   getpar,header,'INSTRUME',instrument
   getpar,header,'FILTER', filter
   getpar,header,'ORIGIN',origin

   getpar,header,'RA-OBJ',aa & ra=aa
   getpar,header,'DEC-OBJ',aa & dec=aa
   getpar,header,'EQUINOX',aa & equinox=aa
   getpar,header,'RADECSYS',aa & radecsys=aa

   ;; get time keywords
   getpar,header,'DATE-OBS',aa & date_obs=aa
   getpar,header,'TIME-OBS',aa & time_obs=aa
   getpar,header,'DATE-END',aa & date_end=aa
   getpar,header,'TIME-END',aa & time_end=aa
   ;; compute tstart and tstop from these keywords
   IF (datatype(date_obs,2) EQ datatype('STRING',2)) THEN BEGIN 
       ;; determine style of date entry
       IF (strpos(date_obs,'/') NE -1) THEN BEGIN 
           da=fix(strmid(date_obs,0,2))
           mo=fix(strmid(date_obs,3,2))
           yr=1900.+strmid(date_obs,6,2)
       END ELSE BEGIN 
           yr=fix(strmid(date_obs,0,4))
           mo=fix(strmid(date_obs,5,2))
           da=fix(strmid(date_obs,8,2))
       END 
       IF (datatype(time_obs,2) EQ datatype('STRING',2)) THEN BEGIN 
           hr=fix(strmid(time_obs,0,2))
           mi=fix(strmid(time_obs,3,2))
           se=float(strmid(time_obs,6,2))
       ENDIF ELSE IF (keyword_set(verbose)) THEN BEGIN
           print,'Warning: no TIME-OBS keyword found, using zero values'
           hr=0
           mi=0
           se=0.0
       ENDIF
       jdcnv,yr,mo,da,hms2deg(hr,mi,se)*24./360.,tstart
   ENDIF ELSE IF (keyword_set(verbose)) THEN BEGIN
       print,'Warning: no DATE-OBS keyword found'
   ENDIF

   IF (datatype(date_end,2) EQ datatype('STRING',2)) THEN BEGIN 
       IF (strpos(date_end,'/') NE -1) THEN BEGIN 
           da=fix(strmid(date_end,0,2))
           mo=fix(strmid(date_end,3,2))
           yr=1900.+strmid(date_end,6,2)
       END ELSE BEGIN 
           yr=fix(strmid(date_end,0,4))
           mo=fix(strmid(date_end,5,2))
           da=fix(strmid(date_end,8,2))
       END 
       IF (datatype(time_obs,2) EQ datatype('STRING',2)) THEN BEGIN 
           hr=fix(strmid(time_end,0,2))
           mi=fix(strmid(time_end,3,2))
           se=float(strmid(time_end,6,2))
       ENDIF ELSE IF (keyword_set(verbose)) THEN BEGIN
           print,'Warning: no TIME-END keyword found, using zero values'
           hr=0
           mi=0
           se=0.0
       ENDIF

       jdcnv,yr,mo,da,hms2deg(hr,mi,se)*24./360.,tstop
       
   ENDIF ELSE IF (keyword_set(verbose)) THEN BEGIN
       print,'Warning: no DATE-END keyword found'
   ENDIF

   IF (keyword_set(mjd)) THEN BEGIN 
       tstart=tstart-2400000.5D0
       tstop=tstop-2400000.5D0
   END 


   ;; get number of channels per spectrum 
   detchans=0
   getpar,header,'DETCHANS',detchans


   ;; check that we can read in requested channel number or range

   ;;    first set up range
   IF (n_elements(channel) EQ 1) THEN BEGIN
       cmin=channel
       cmax=channel
   ENDIF ELSE IF (n_elements(channel) EQ 2) THEN BEGIN
       cmin=channel(0)
       cmax=channel(1)
   ENDIF ELSE BEGIN
       print,'Error: Channels ill defined! Must be either N or [N,M]'
       return
   ENDELSE
   IF (cmin GT cmax) THEN BEGIN
       print,'Error: Channels ill defined! Cmin > Cmax!'
       return
   ENDIF

   ;;    read channel column from first spectrum
   ;;    NOTE: this assumes all spectra have same channels!
   fxbread,unit,channels,'CHANNEL',1

   ;;    check if cmin,cmax are possible
   cmin_idx=where(channels EQ cmin)
   IF (n_elements(cmin_idx) NE 1) THEN BEGIN
       print,'Error: Strange spectra, multiple occurrence of same channel!'
       return
   ENDIF ELSE cmin_idx=cmin_idx(0)
   IF (cmin_idx EQ -1) THEN BEGIN
       print,'Error: Start channel ',cmin, ' not in spectral channels'
       cmin=min(channels)
       cmin_idx=where(channels EQ cmin) & cmin_idx=cmin_idx(0)
       print,'       Using lowest channel available instead: ',cmin
   ENDIF

   cmax_idx=where(channels EQ cmax)
   IF (n_elements(cmax_idx) NE 1) THEN BEGIN
       print,'Error: Strange spectra, multiple occurrence of same channel!'
       return
   ENDIF ELSE cmax_idx=cmax_idx(0)
   IF (cmax_idx EQ -1) THEN BEGIN
       print,'Error: End channel ',cmax, ' not in spectral channels'
       cmax=max(channels)
       cmax_idx=where(channels EQ cmax) & cmax_idx=cmax_idx(0)
       print,'       Using highest channel available instead: ',cmax
   ENDIF

   ;;
   ;; Read counts or rate, and associated error column
   ;; these will be arrays (detchan,nphasebins)
   ;;
   IF (spectype EQ 0) THEN BEGIN 
       fxbread,unit,counts,'RATE'
   END ELSE BEGIN 
       fxbread,unit,counts,'COUNTS'
   END 
   fxbread,unit,counterr,'STAT_ERR'

   ;;
   ;; Read exposure time per phasebin, and phase values
   ;;
   fxbread,unit,exposure,'EXPOSURE'
   fxbread,unit,phase,'PHASE'


   ;; 
   ;; Set up output arrays
   ;;
   nphasebins=0
   getpar,header,'NAXIS2',nphasebins

   rate=dblarr(nphasebins)
   rateerr=dblarr(nphasebins)

   ;;
   ;; Fill output arrays, looping over channels
   ;;
   FOR ch=cmin_idx,cmax_idx DO BEGIN
       rate    = rate    + reform(counts(ch,*))
       rateerr = rateerr + reform(counterr(ch,*))^2
   ENDFOR
   rateerr=sqrt(rateerr)
   IF (spectype EQ 1) THEN BEGIN 
       rate    = rate/exposure
       rateerr = rateerr/exposure
   ENDIF

   ;;
   ;; ... done
   ;;
   fxbclose,unit
END 

