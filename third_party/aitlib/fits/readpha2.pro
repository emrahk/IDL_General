PRO readpha2,count,counterr,rate,back,specnum,phafile,$
             channel=channel,phase=phase,rowid=rowid,$
             response=response,arf=arf, $
             telescope=telescope,instrument=instrument,object=object, $
             ra=ra,dec=dec,equinox=equinox,radecsys=radecsys,$
             date_obs=date_obs,time_obs=time_obs,date_end=date_end, $
             time_end=time_end,filter=filter,exposure=exposure, $
             backfile=backfile,backscale=backscale,corrfile=corrfile, $ 
             corrscale=corrscale,effarea=effarea,staterr=staterr, $
             origin=origin,verbose=verbose,poisson=poisson,$
             tstart=tstart,tstop=tstop,mjd=mjd
;+
; NAME:
;       readpha2
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
;       readpha2,count,counterr,rate,back,specnum,phafile
; 
; INPUTS:
;       specnum - ref. number of the spectrum to read from the PHA-II table
;                 (Note: this is compared to the SPEC_NUM column and not
;                        necessarily equal to the row number)
;       phafile - name of the file to read from
;
;
; OPTIONAL INPUTS:
;       none
;
;
; KEYWORD PARAMETERS:
;       see the list under optional outputs
;       verbose   : be talkative
;
; OUTPUTS:
;       count     : counts in each bin (the PHA channel-number is the
;                   index into count); depending on the value of rate
;                   either as total photons observed in the bin or as
;                   a count-rate
;       counterr  : uncertainty of the countrate or photon-number
;                   (same units as count)
;       rate      : 0 if count is count-rate, 
;                   1 if total counts/bin 
;       back      : 0 if count is total spectrum,  <--- CURRENTLY ALWAYS
;                   1 if count is background spectrum,
;                   2 if count is background-subtracted
;
;
; OPTIONAL OUTPUTS:
;       channel   : channel numbers of spectrum
;       phase     : corresponding phase if spectra were created by fasebin
;       rowid     : Unique identifier of spectrum
;       response  : filename of response-matrix
;       telescope : ID of telescope
;       instrument: ID of instrument
;       object    : name of observed object
;       ra,dec    : position of observed object (degrees!), implies:
;       equinox   :     equinox os coordinate
;       radecsys  :     coordinate-frame used 
;       date_obs  : start-time (dd/mm/yy), UTC, implies
;       time_obs  :     start-time (hh:mm:ss), UTC
;       date_end  :     end-time (dd/mm/yy), UTC
;       time_end  :     end-time (hh:mm:ss), UTC
;       tstart,tstop: the above in JD 
;       mjd       :  ... or in MJD, if this keyword is set
;       filter    : filter used 
;       exposure  : exposure time 
;       backfile  : filename of background-spectrum
;       backscale : scale-factor of background-spectrum
;       corrfile  : filename of correction-file
;       corscale  : scale-factor of corrfile
;       effarea   : Area scaling factor
;       staterr   : systematic statistical error
;       origin    : institution where file originates from
;       arf       : filename of ancillary file (i.e. effective area)
;       poisson   : if 1 assume Poisson-Statistics (and don't use
;                   uncertainty of spectrum); implies that counterr
;                   will NOT be used! 
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
;       * Rather complex tool, based on readpha.pro
;       * Error handling is primitive/non-existent
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
;                    first version, based on readpha.pro V1.2
;       Version 1.1: 1999/11/10, PK
;                    Use "RA-OBJ" and "DEC-OBJ" instead of "*_OBJ"
;                    to be compliant with fasebin output and FITS Standard
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

   ;; Right now, these spectra are always source spectra
   back=0
   IF (keyword_set(verbose)) THEN BEGIN
       print, 'Always assuming source spectra for PHA-II data'
   ENDIF

   ;; see if we have COUNT or RATE spectra
   getpar,header,'HDUCLAS4',aa
   aa=strtrim(aa,2)
   rate=-1
   IF (aa EQ 'RATE') THEN rate=0
   IF (aa EQ 'COUNT') THEN rate=1
   IF (rate EQ -1 AND keyword_set(verbose)) THEN BEGIN 
       print, 'Warning, HDUCLAS3 not RATE or COUNT, assuming COUNT'
       rate=1
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
   getpar,header,'AREASCAL',effarea

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

 
   poisson=0
   getpar,header,'POISSERR',poisson
   detchans=0
   getpar,header,'DETCHANS',detchans
   quality=0
   getpar,header,'QUALITY',quality
   grouping=0
   getpar,header,'GROUPING',grouping
   IF (grouping NE 0 AND keyword_set(verbose)) THEN BEGIN 
       print,'Warning, grouping of PHA data is ignored'
   ENDIF 

   ;; check that we can read in requested spectrum
   nspectra=0
   getpar,header,'NAXIS2',nspectra
   IF (specnum GT nspectra) THEN BEGIN
       print,'Error: Can not read spectrum number   ',specnum
       print,'       PHA-II extension contains only ',nspectra,' spectra
       fxbclose,unit
       return
   ENDIF

   ;; read SPEC_NUM column 
   fxbread,unit,specnums,'SPEC_NUM'
   ;; find spectrum corresponding to specnum, add 1 for fxbread
   spec_index = where(specnums EQ specnum) + 1  
   IF (keyword_set(verbose)) THEN BEGIN
       print,'Reading spectrum with SPEC_NUM = ',specnum,$
             ' at position ',spec_index,' in the table',$
             format='(a,i4,a,i4,a)'
   ENDIF

   ;;
   ;; Read Data that is definitely in columns
   ;;


   fxbread,unit,channel,'CHANNEL',spec_index

   IF (rate EQ 0) THEN BEGIN 
       fxbread,unit,count,'RATE',spec_index
   END ELSE BEGIN 
       fxbread,unit,count,'COUNTS',spec_index
   END 
   IF (poisson NE 1) THEN BEGIN 
       fxbread,unit,counterr,'STAT_ERR',spec_index
   END ELSE BEGIN 
       counterr=-1
   END

   fxbread,unit,exposure,'EXPOSURE',spec_index
   fxbread,unit,phase,'PHASE',spec_index
   fxbread,unit,rowid,'ROWID',spec_index

   ;; Now we read data that could be EITHER in a keyword OR in a column
   ;; => we have to figure out what is the case
   ;; I'm not 100% sure the trick below is the most elegant but it will do

   ;; get all TTYPE keywords (column defs)
   fxbfind,header,'TTYPE',columns,values,n_found
   ;; merge them into a single string
   colstring=''
   FOR i=1,n_found DO colstring=colstring+values(i-1)+' '

   ;; check for each item individually if it is stored as column or
   ;; as header
   IF (strpos(colstring,'BACKFILE') NE -1) THEN BEGIN
       fxbread,unit,backfile,'BACKFILE',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'BACKFILE',backfile
   ENDELSE

   IF (strpos(colstring,'BACKFILE') NE -1) THEN BEGIN
       fxbread,unit,backfile,'BACKFILE',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'BACKFILE',backfile
   ENDELSE

   IF (strpos(colstring,'BACKSCAL') NE -1) THEN BEGIN
       fxbread,unit,backscale,'BACKSCAL',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'BACKSCAL',backscale
   ENDELSE

   IF (strpos(colstring,'CORRFILE') NE -1) THEN BEGIN
       fxbread,unit,corrfile,'CORRFILE',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'CORRFILE',corrfile
   ENDELSE

   IF (strpos(colstring,'CORRSCAL') NE -1) THEN BEGIN
       fxbread,unit,corrscale,'CORRSCALE',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'CORRSCAL',corrscale
   ENDELSE

   IF (strpos(colstring,'RESPFILE') NE -1) THEN BEGIN
       fxbread,unit,response,'RESPFILE',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'RESPFILE',response
   ENDELSE

   IF (strpos(colstring,'ANCRFILE') NE -1) THEN BEGIN
       fxbread,unit,arf,'ANCRFILE',spec_index
   ENDIF ELSE BEGIN
       getpar,header,'ANCRFILE',arf
   ENDELSE


   ;;
   ;; ... done
   ;;
   fxbclose,unit
END 

