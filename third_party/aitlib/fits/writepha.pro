;
; Write PHA file
; J.W., 1996-2001
; 
PRO writepha,count,counterr,phafile,response=response, $
             telescope=telescope,instrument=instrument,object=object, $
             ra=ra,dec=dec,filter=filter,exposure=exposure,poisson=poisson, $
             backfile=backfile,backscale=backscale,corrfile=corrfile, $ 
             corrscale=corrscale,effarea=effarea,cps=cps,staterr=staterr, $
             origin=origin,equinox=equinox,radecsys=radecsys, $
             date_obs=date_obs,time_obs=time_obs,date_end=date_end, $
             time_end=time_end,arf=arf,background=back,net=net,total=total, $
             jdobs=jdobs,jdend=jdend,startchan=startchan, $
             group=group,quality=quality,pi=pi
;+
; NAME:
;           writepha
;
;
; PURPOSE:
;           Write photon-spectrum as an OGIP-compatible FITS-PHA-File in the
;           Format defined in OGIP memo CAL-GEN 92-007 and 92-007a
;
;
; CATEGORY:
;           High-Energy Astrophysics
;
;
; CALLING SEQUENCE:
;           writepha,count,counterr,phafile
;
; 
; INPUTS:
;          count     : counts in bin or countrate (see cps keyword)
;          counterr  : uncertainty of count (ignored when poisson set)
;          phafile   : filename of pha-file
;
;
; OPTIONAL INPUTS:
;          none
;
;	
; KEYWORD PARAMETERS:
;          response  : filename of response-matrix (default: none)
;          telescope : ID of telescope (default: unknown)
;          instrument: ID of instrument
;          object    : name of observed object
;          ra,dec    : position of observed object (degrees!), implies:
;          equinox   :    equinox os coordinate
;          radecsys  :    coordinate-frame used 
;          date_obs  : start-time string (dd/mm/yy), UTC, implies
;          time_obs  :    start-time (hh:mm:ss), UTC
;          date_end  :    end-time (dd/mm/yy), UTC
;          time_end  :    end-time (hh:mm:ss), UTC
;          jdobs     : Julian Date of start of observation, implies
;          jdend     :    JD of end of observation
;          filter    : filter used (default: none)
;          exposure  : exposure time (default: 1.
;          backfile  : filename of background-spectrum (default: none)
;          backscale : scale-factor of background-spectrum (default: 1)
;          corrfile  : filename of correction-file (default: none)
;          corrscale : scale-factor of corrfile (default: 1)
;          effarea   : Area scaling factor (default: 1.)
;          cps       : if set,spectrum is in counts per second
;                      (default: total counts per bin)
;          poisson   : if set, assume Poisson-Statistics (and don't use
;                      uncertainty of spectrum); not possible if cps is
;                      used. Implies that counterr will NOT be used!
;          staterr   : systematic statistical error (default: 0,
;                      i.e. none)
;          pi        : if set, data are pulse invariant data (default
;                      if not set: data are pulse height analyzer data; PHA)
;          arf       : filename of ancillary file (i.e. effect. area)
;          origin    : institution where file originates from
;          total     : if set, spectrum is source+bk (default)
;          background: if set, spectrum is background-spectrum
;          net       : if set, spectrum is background-subtracted
;          startchan : first channel of spectrum (1 by default)
;          group     : array of same size as count and counterr defining
;                      the grouping of the data (see grppha
;                      procedure). a "1" starts a new group, -1 is the
;                      continuation of the rebinned channel
;          quality   : array same size as count, a 0 designates a good
;                      channel, <>0 is bad (2: marked bad by rebinning)
;
; OUTPUTS:
;          none
;
;
; OPTIONAL OUTPUTS:
;          none
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          The PHA-File gets written to disk
;
;
; RESTRICTIONS:
;          * The error-handling really isn't as good as is should be yet.
;          * NOTE THAT MULTIPLE DATA SETS ARE NOT ALLOWED YET
;          * Do not have both, date_obs and jdobs!!!!
;
; PROCEDURE:
;          see code
;
;
; EXAMPLE:
;          STILL MISSING
;
;
; MODIFICATION HISTORY:
;       written in 1995 and 1996 by Joern Wilms,
;               wilms@astro.uni-tuebingen.de
;       Version 1.0: 1997/02/14  "Official" release
;       Version 1.1: 1997/06/25, JW
;           Corrected typo in HDUCLAS2 statement
;       Version 1.2: 1997/10/22, JW
;           allow for non-integer counts even in the non-cps case
;           (e.g. background-models etc.)
;       Version 1.3: 1998/01/28, JW
;           allow case when counterr is not given but Poisson is
;           set (i.e. poisson leads to ignoring counterr)
;       Version 1.4: 1999/03/17, JW
;           added TLMIN and TLMAX keywords to be fully compatible with
;           OGIP memo 92-007a; made compatible with IDL 5.x
;   CVS VERSION 1.2: 2001/03/15, JW
;           added capability to write grouped spectra and to set
;           the quality of channels
;       Version 1.3: 2001/03/21, JW
;           added PI keyword, added docu to group and quality keywords
;       Version 1.4: 2001/03/21, JW
;           stupid bug in CHANTYPE keyword -- remember, always check
;           your trivial code before checking it in...
;-


   IF (NOT keyword_set(poisson)) THEN BEGIN 
       IF (n_elements(count) NE n_elements(counterr)) THEN BEGIN 
           IF (n_elements(counterr) GT 0) THEN BEGIN 
               message, 'n_elements(count) <> n_elements(counterr)'
           END ELSE BEGIN 
               message, 'need a formal uncertainty: counterr not given'
           END 
       END
   ENDIF 
   IF (keyword_set(cps) AND (n_elements(exposure) EQ 0)) THEN BEGIN 
       message, 'need exposure time for countrate-spectra!'
   ENDIF 
   ;; 
   IF (keyword_set(poisson) AND keyword_set(cps)) THEN BEGIN 
       message, 'can not assume poisson-statistics for rate-data'
   ENDIF 
   ;;
   IF ((n_elements(phafile) EQ 0) AND (n_elements(counterr) EQ 1)) THEN BEGIN 
       filename=counterr
   END ELSE BEGIN 
       filename= phafile
   END
   ;;
   ;; Define default-values for mandatory keywords
   ;;
   IF (n_elements(telescope) EQ 0) THEN telescope='unknown'
   IF (n_elements(instrument) EQ 0) THEN instrument='none'
   IF (n_elements(filter) EQ 0) THEN filter='none'
   IF (n_elements(exposure) EQ 0) THEN exposure=1.
   IF (n_elements(effarea) EQ 0) THEN effarea=1.
   IF (n_elements(backfile) EQ 0) THEN backfile='none'
   IF (n_elements(backscale) EQ 0) THEN backscale=1.
   IF (n_elements(corrfile) EQ 0) THEN corrfile='none'
   IF (n_elements(corrscale) EQ 0) THEN corrscale=1.
   IF (n_elements(response) EQ 0) THEN response='none'
   IF (n_elements(arf) eq 0) THEN arf='none'
   IF (n_elements(staterr) EQ 0) THEN staterr=0.
   IF (n_elements(startchan) EQ 0) THEN startchan=1
   ;;
   ;; Create Spectrum Primary Header
   ;;
   fxhmake,header,/initialize,/extend,/date
   fxaddpar,header,'CONTENT','SPECTRUM','File contains spectrum'
   fxaddpar,header,'FILENAME',filename,'Name of this file'
   IF (n_elements(origin) NE 0) THEN BEGIN 
       fxaddpar,header,'ORIGIN',origin,'Organization which created this file'
   ENDIF 
   fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'FILTER', filter,'Filter used for observation'
   IF (n_elements(object) NE 0) THEN BEGIN 
       fxaddpar,header,'OBJECT',object,'Name of observed object'
   ENDIF 
   IF (n_elements(ra) NE 0) THEN BEGIN
       fxaddpar,header,'RA_OBJ',ra,'Right Ascension of target (deci. deg.)'
       fxaddpar,header,'DEC_OBJ',dec,'Declination of target (deci. deg.)'
       fxaddpar,header,'EQUINOX',equinox,'Equinox of position'
       fxaddpar,header,'RADECSYS',radecsys,'Co-ordinate frame used for equinox'
   ENDIF
   IF (n_elements(date_obs) NE 0) THEN BEGIN 
       fxaddpar,header,'DATE-OBS',date_obs,'EARLIEST observation date of files'
       fxaddpar,header,'TIME-OBS',time_obs,'EARLIEST time of all input files'
       fxaddpar,header,'DATE-END',date_end,'LATEST observation date of files'
       fxaddpar,header,'TIME-END',time_end,'LATEST time of all input files'
   ENDIF 
   IF ((n_elements(jdobs) NE 0) AND (n_elements(date_obs) EQ 0)) THEN BEGIN 
       jdstr,jdobs,date,time
       fxaddpar,header,'DATE-OBS',date,'EARLIEST observation date of files'
       fxaddpar,header,'TIME-OBS',time,'EARLIEST time of all input files'
       jdstr,jdend,date,time
       fxaddpar,header,'DATE-END',date,'LATEST observation date of files'
       fxaddpar,header,'TIME-END',time,'LATEST time of all input files'
   ENDIF 
   fxaddpar,header,'PHAVERSN','1992a','OGIP version number of FITS format'
   ;;
   fxwrite,filename,header
   ;;
   ;; Create PHA extension
   ;;
   ;; ... header
   fxbhmake,header,n_elements(count(*)),'SPECTRUM',/initialize,/date
   fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'FILTER', filter,'Filter used for observation'
   fxaddpar,header,'EXPOSURE',exposure,'Integration time in seconds'
   fxaddpar,header,'AREASCALE',effarea,'Area scaling factor'
   fxaddpar,header,'BACKFILE',backfile,'Background file'
   fxaddpar,header,'BACKSCAL',backscale,'Background scaling factor'
   fxaddpar,header,'CORRFILE',corrfile,'Correction file'
   fxaddpar,header,'CORRSCAL',corrscale,'Correction scaling factor'
   fxaddpar,header,'RESPFILE',response,'Redistribution Matrix'
   fxaddpar,header,'ANCRFILE',arf,'Ancilliary Response File'
   fxaddpar,header,'CREATOR','writepha v1.4','IAAT Tuebingen, J. Wilms'
   fxaddpar,header,'HDUCLASS','OGIP','Organization which devised File-Format'
   fxaddpar,header,'HDUCLAS1','SPECTRUM','This file is a spectrum'
   fxaddpar,header,'HDUVERS1','1.1.0','Version-Number of Format' 
   fxaddpar,header,'HDUVERS','1.1.0','Version-Number of Format' 
   IF (keyword_set(back)) THEN BEGIN 
       fxaddpar,header,'HDUCLAS2','BKG','Spectrum is background-spectrum'
   END ELSE BEGIN 
       IF (keyword_set(net)) THEN BEGIN 
           fxaddpar,header,'HDUCLAS2','NET','Spectrum is background-subtracted'
       END ELSE BEGIN 
           fxaddpar,header,'HDUCLAS2','TOTAL','gross PHA spectrum (src+bkg)'
       END
   END 
   IF (keyword_set(cps)) THEN BEGIN 
       fxaddpar,header,'HDUCLAS3','RATE','Spectrum is counts/s'
   END ELSE BEGIN 
       fxaddpar,header,'HDUCLAS3','COUNT','Spectrum is total counts'
   END 
   fxaddpar,header,'PHAVERSN','1992a','OGIP version number of FITS format'
   IF (n_elements(ra) NE 0) THEN BEGIN
       fxaddpar,header,'RA_OBJ',ra,'Right Ascension of target (deci. deg.)'
       fxaddpar,header,'RA_OBJ',dec,'Declination of target (deci. deg.)'
       fxaddpar,header,'EQUINOX',equinox,'Equinox of position'
       fxaddpar,header,'RADECSYS',radecsys,'Co-ordinate frame used for equinox'
   ENDIF
   IF (n_elements(date_obs) NE 0) THEN BEGIN 
       fxaddpar,header,'DATE-OBS',date_obs,'EARLIEST observation date of files'
       fxaddpar,header,'TIME-OBS',time_obs,'EARLIEST time of all input files'
       fxaddpar,header,'DATE-END',date_end,'LATEST observation date of files'
       fxaddpar,header,'TIME-END',time_end,'LATEST time of all input files'
   ENDIF 
   IF (keyword_set(poisson)) THEN BEGIN
       fxaddpar,header,'POISSERR','T','Assume Poissonian error'
   END ELSE BEGIN 
       fxaddpar,header,'POISSERR','F','Use given uncertainties'
   END
   IF (keyword_set(pi)) THEN BEGIN 
       fxaddpar,header,'CHANTYPE','PI','Data are Pulse Invariant Data'
   END ELSE BEGIN 
       fxaddpar,header,'CHANTYPE','PHA','Data are Pulse Height Analyzed'
   END 
   fxaddpar,header,'DETCHANS',n_elements(count(*)),'No of channels available'
   fxaddpar,header,'TLMIN1',startchan,'Starting channel of data'
   fxaddpar,header,'TLMAX1',n_elements(count[*])+startchan-1,'Last channel'
   IF (n_elements(quality) EQ 0) THEN BEGIN 
       fxaddpar,header,'QUALITY',0,'All data are assumed to be good'
   END 
   IF (n_elements(group) EQ 0) THEN BEGIN 
       fxaddpar,header,'GROUPING',0,'No grouping'
   END 
   ;;
   ;; ... define columns
   fxbaddcol,ndx,header,1,'CHANNEL','channel number'
   IF (keyword_set(cps)) THEN BEGIN 
       fxbaddcol,ndx,header,count[0],'RATE','Countrate',tunit='COUNTS/S'
   END ELSE BEGIN 
       fxbaddcol,ndx,header,count[0],'COUNTS',$
         'number of counts observed',tunit='COUNTS'
   END
   IF (NOT keyword_set(poisson)) THEN BEGIN 
       IF (staterr NE 0.) THEN BEGIN 
           fxaddpar,header,'STAT_ERR',staterr, $
             'Stat. error (ignore STAT_ERR column)'
       ENDIF 
       uni='COUNTS'
       IF (keyword_set(cps)) THEN uni='COUNTS/S'
       fxbaddcol,ndx,header,counterr[0],'STAT_ERR','Statistical error',$
         tunit=uni
   ENDIF 
   IF (n_elements(quality) GT 0) THEN BEGIN 
       fxbaddcol,qualcol,header,quality[0],'QUALITY','quality'
   END 
   IF (n_elements(group) GT 0) THEN BEGIN 
       fxbaddcol,grpcol,header,group[0],'GROUPING', $
         'grouping (1: start, -1: cont)'
   END 
   ;;
   fxbcreate,unit,filename,header
   ;;
   ;; ... now write data
   FOR i=0,n_elements(count)-1 DO BEGIN
       i1=i+1
       fxbwrite,unit,i+startchan,1,i1 ;; channel number
       fxbwrite,unit,count[i],2,i1     ;; count (rate)
   ENDFOR 
   IF (NOT keyword_set(poisson)) THEN BEGIN 
       FOR i=0,n_elements(count)-1 DO BEGIN
           i1=i+1
           fxbwrite,unit,counterr[i],3,i1
       ENDFOR 
   ENDIF 
   IF (n_elements(quality) GT 0) THEN BEGIN 
       FOR i=0,n_elements(quality)-1 DO BEGIN 
           i1=i+1
           fxbwrite,unit,quality[i],qualcol,i1
       END 
   END 
   IF (n_elements(group) GT 0) THEN BEGIN 
       FOR i=0,n_elements(group)-1 DO BEGIN 
           i1=i+1
           fxbwrite,unit,group[i],grpcol,i1
       END 
   END 
   ;;
   ;; Write file to disk
   ;;
   fxbfinish,unit
END 

