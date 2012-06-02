;;
;; Read PHA file
;; J.W., 1996
;; 
PRO readpha,count,counterr,rate,back,phafile,response=response, $
            telescope=telescope,instrument=instrument,object=object, $
            ra=ra,dec=dec,equinox=equinox,radecsys=radecsys,$
            date_obs=date_obs,time_obs=time_obs,date_end=date_end, $
            time_end=time_end,filter=filter,exposure=exposure, $
            backfile=backfile,backscale=backscale,corrfile=corrfile, $ 
            corrscale=corrscale,effarea=effarea,staterr=staterr, $
            origin=origin,arf=arf,verbose=verbose,poisson=poisson, $
            tstart=tstart,tstop=tstop,mjd=mjd
;+
; NAME:
;       readpha
;
;
; PURPOSE:
;       Read PHA-spectrum from a OGIP-conformant PHA-file. The file
;       format has been defined in OGIP memo CAL-GEN 92-002 and 002a.
;
;
; CATEGORY:
;       High energy astrophysics
;
;
; CALLING SEQUENCE:
;       readpha,count,counterr,rate,back,phafile
; 
; INPUTS:
;       phafile - name of the file to read
;
;
; OPTIONAL INPUTS:
;       none
;
;
; KEYWORD PARAMETERS:
;       see the list under optional outputs
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
;       back      : 0 if count is total spectrum,
;                   1 if count is background spectrum,
;                   2 if conut is background-subtracted
;
;
; OPTIONAL OUTPUTS:
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
;       * the routine seems to work, but is a little bit too complex for
;         my feeling so that a proper functioning cannot be guaranteed
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
;       written in 1995 and 1996 by Joern Wilms,
;               wilms@astro.uni-tuebingen.de
;       Version 1.0: 1997/02/14  "Official" release
;       Version 1.1: 1997/06/25, JW
;           Corrected typo in HDUCLAS2 statement
;       Version 1.2: 1999/08/04, JW
;           Keywords now work correctly,
;           tstart and tstop keyword added (computed from
;           date-obs and date-end, NOT taken from header)
;       Version 1.3: 1999/11/10, JW
;           Typo in reading the coordinates
;       Version 1.4: 2000/06/15, JW
;           cosmetic change in documentation
; $Log: readpha.pro,v $
; Revision 1.4  2002/07/27 13:54:29  wilms
; added test whether DATE-OBS defined in SPECTRUM extension
; (XMM evselect spectra do not have this, unfortunately...)
;
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
   getpar,header,'TELESCOP',aa & telescope=aa
   getpar,header,'INSTRUME',aa & instrument=aa
   getpar,header,'FILTER', aa  & filter=aa
   getpar,header,'EXPOSURE',aa & exposure=aa
   getpar,header,'AREASCALE',aa& effarea=aa
   getpar,header,'BACKFILE',aa & backfile=aa
   getpar,header,'BACKSCAL',aa & backscale=aa
   getpar,header,'CORRFILE',aa & corrfile=aa
   getpar,header,'CORRSCAL',aa & corrscale=aa
   getpar,header,'RESPFILE',aa & response=aa
   getpar,header,'ANCRFILE',aa & arf=aa
   getpar,header,'HDUCLAS2',aa
   aa=strtrim(aa,2)
   back=-1
   IF (aa EQ 'TOTAL') THEN back=0
   IF (aa EQ 'BKG') THEN back=1
   IF (aa EQ 'NET') THEN back=2
   IF (back EQ -1 AND keyword_set(verbose)) THEN BEGIN 
       print, 'Warning, HDUCLAS2 entry scrambled or missing'
       print, '...assuming total spectrum'
       back=0
   ENDIF 
   getpar,header,'HDUCLAS3',aa
   aa=strtrim(aa,2)
   rate=-1
   IF (aa EQ 'RATE') THEN rate=0
   IF (aa EQ 'COUNT') THEN rate=1
   IF (rate EQ -1 AND keyword_set(verbose)) THEN BEGIN 
       print, 'Warning, HDUCLAS3 not RATE or COUNT, assuming COUNT'
       rate=1
   ENDIF 
   getpar,header,'PHAVERSN',aa
   aa=strtrim(aa,2)
   IF (aa NE '1992a' AND keyword_set(verbose)) THEN BEGIN 
       print,'Warning, OGIP version number is '+aa+',not 1992a'
   ENDIF 
   getpar,header,'RA_OBJ',aa & ra=aa
   getpar,header,'DEC_OBJ',aa & dec=aa
   getpar,header,'EQUINOX',aa & equinox=aa
   getpar,header,'RADECSYS',aa & radecsys=aa
   getpar,header,'DATE-OBS',aa
   ;; only read the other TIME-Keywords if DATE-OBS is a string
   ;; (avoids problems with non-OGIP complying evselect spectra)
   IF ((size(aa))[1] EQ 7) THEN BEGIN 
       date_obs=aa
       getpar,header,'time-obs',aa & time_obs=aa
       getpar,header,'date-end',aa & date_end=aa
       getpar,header,'time-end',aa & time_end=aa
       ;; compute tstart and tstop from these keywords
       if (n_elements(date_obs) ne 0) then begin 
           ;; determine style of date entry
           if (strpos(date_obs,'/') ne -1) then begin 
               da=fix(strmid(date_obs,0,2))
               mo=fix(strmid(date_obs,3,2))
               yr=1900.+strmid(date_obs,6,2)
           end else begin 
               yr=fix(strmid(date_obs,0,4))
               mo=fix(strmid(date_obs,5,2))
               da=fix(strmid(date_obs,8,2))
           endelse 
           hr=fix(strmid(time_obs,0,2))
           mi=fix(strmid(time_obs,3,2))
           se=float(strmid(time_obs,6,2))
       
           jdcnv,yr,mo,da,hms2deg(hr,mi,se)*24./360.,tstart
           
           if (strpos(date_end,'/') ne -1) then begin 
               da=fix(strmid(date_end,0,2))
               mo=fix(strmid(date_end,3,2))
               yr=1900.+strmid(date_end,6,2)
           end else begin 
               yr=fix(strmid(date_end,0,4))
               mo=fix(strmid(date_end,5,2))
               da=fix(strmid(date_end,8,2))
           endelse 
           hr=fix(strmid(time_end,0,2))
           mi=fix(strmid(time_end,3,2))
           se=float(strmid(time_end,6,2))
           jdcnv,yr,mo,da,hms2deg(hr,mi,se)*24./360.,tstop
       
           if (keyword_set(mjd)) then begin 
               tstart=tstart-2400000.5d0
               tstop=tstop-2400000.5d0
           endif 
       endif 
   endif 
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
   getpar,header,'STAT_ERR',staterr
   ;;
   ;; Read Data
   ;;
   fxbread,unit,channel,'CHANNEL'

   IF (rate EQ 0) THEN BEGIN 
       fxbread,unit,count,'RATE'
   END ELSE BEGIN 
       fxbread,unit,count,'COUNTS'
   END 
   IF (poisson NE 1) THEN BEGIN 
       fxbread,unit,counterr,'STAT_ERR'
   END ELSE BEGIN 
       counterr=-1
   END
   ;;
   ;; ... done
   ;;
   fxbclose,unit
END 
