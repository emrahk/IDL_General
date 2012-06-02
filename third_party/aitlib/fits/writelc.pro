PRO writelc,time,rate,error,filename, $
            barytime=barytime,        $ 
            origin=origin,telescope=telescope,instrument=instrument,$
            filter=filter,object=object,pos_ra=ra,pos_dec=dec,equinox=equinox, $
            radecsys=radecsys,date_obs=date_obs,time_obs=time_obs, $
            date_end=date_end,time_end=time_end,jdobs=jdobs, $
            jdend=jdend,counts=counts,second=second,day=day, $
            mjdrefi=mjdrefi,mjdreff=mjdreff,mjdref0=mjdref, $
            tstarti=tstarti,tstartf=tstartf,tstart0=tstart, $
            tstopi=tstopi,tstopf=tstopf,tstop0=tstop, $
            sysjd=jd,sysmjd=mjd,systjd=tjd, $
            utc=utc,ontime=ontime,backsub=backsub,deadcorr=deadcorr, $
            timezeri=timezeri,timezerf=timezerf,timezero=timezero
;+
; NAME:
;       writelc
;
;
; PURPOSE:
;       Write an OGIP-compliant FITS lightcurve, conforming
;       (hopefully) to 
;       http://heasarc.gsfc.nasa.gov/docs/heasarc/ofwg/docs/rates/ogip_93_003/ogip_93_003.html
;       with later extensions 
;
;
; CATEGORY:
;       High-energy astrophysics
;
;
; CALLING SEQUENCE:
;       writelc,time,rate,error,lcfile
;    or
;       writelc,time,rate,lcfile
;
; INPUTS:
;          time      : Time (LEADING EDGE OF BIN!!!!)
;          rate      : Countrate (cps) or number of counts (counts/bin) 
;                      (depending on /counts keyword)
;                      measured from time[i]..time[i+1]
;          error     : if given, uncertainty of rate (same units as rate)
;          lcfile    : name of the lightcurve to be written
;
; OPTIONAL INPUTS:
;          barytime  : Write a bary center corrected time column. Also the
;                      TIMEREF keyword is set at 'LOCAL', i.e. the
;                      time column remains untouched.
;                      No BSTART/BSTOP/BZERO parameters are added.
;                      The column type is set at BARYCENTER (not
;                      following the OGIP recomendation but the result
;                      of fxbary).
;
; KEYWORD PARAMETERS:
;          telescope : ID of telescope (default: unknown)
;          instrument: ID of instrument
;          object    : name of observed object
;          pos_ra,pos_dec: position of observed object (degrees!), implies:
;          equinox   :    equinox os coordinate
;          radecsys  :    coordinate-frame used 
;          date_obs  : start-time string (dd/mm/yy), UTC, implies
;          time_obs  :    start-time (hh:mm:ss), UTC
;          date_end  :    end-time (dd/mm/yy), UTC
;          time_end  :    end-time (hh:mm:ss), UTC
;          jdobs     : Julian Date of start of observation, implies
;          jdend     :    JD of end of observation
;          filter    : filter used (default: none)
;          counts    : if set, "rate" contains number of events per time bin
;                      (default: rate is counting rate (events/s))
;          second    : if set, all times are in seconds 
;                      (time col, tstart, tstop)
;          day       : if set, all times are in days (time col, tstart, tstop)
;          mjdrefi/mjdreff: integer and real part of base MJD of lightcurve
;          mjdref0   : base MJD of lightcurve
;          tstarti,tstartf,tstart0: start time of lc
;                      (either integer/real, or total)
;          tstopi,tstopf,tstop0: stop time of lc (either integer/real, or
;                       total)
;          sysjd,sysmjd,systjd: set ONE of these to define the timesystem
;          utc       : if set, time system is UTC
;          ontime    : total time the source was observed, IN SECONDS
;          backsub   : lightcurve is background-subtracted
;          deadcorr  : rates are deadtime-corrected
;
; SIDE EFFECTS:
;          a file gets written
;
;
; RESTRICTIONS:
;    Compared to the OGIP memo, the following restrictions apply:
; note: we always write the time into the file, even for equally
;    spaced lcs
; Information on barycentric correction (TIMEREF keyword and
; associated info), who assigned the time (TASSIGN), and timing
; uncertainty is not yet written.
; lightcurves for multiple energy bands in the same lc cannot be
; written.
; information on vignetting is not written.
; background values are not written (BACKV columns)
; deadtime information is not written in extra column (DEADC column)
; event list info is not written (EVENT extension)
; additionally possible extensions (barycentric correction, gti,...) 
; is not written
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
;       Version 1.1: 2001/03/22 Joern Wilms   
;       ... Version 1.3: 2001/03/22 JW: further improvements and
;           bugfixes
;       ... Version 1.4: 2002/01/14 JW: renamed ra and dec keywords
;           into pos_ra and pos_dec to avoid IDL keyword clash with
;           radecsys keyword
;       $Log: writelc.pro,v $
;       Revision 1.5  2003/04/03 16:14:40  goehler
;        added optional bary input for bary center corrected time columns.
;
;-

    ;;
    ;; Define default-values for mandatory keywords
    ;;
    IF (n_elements(telescope) EQ 0) THEN telescope='unknown'
    IF (n_elements(instrument) EQ 0) THEN instrument='none'
    IF (n_elements(filter) EQ 0) THEN filter='none'

    ;; does lc have error?
    errorset=1
    IF (n_elements(filename) EQ 0) THEN BEGIN 
        filename=error
        errorset=0
    ENDIF 

    fxhmake,header,/initialize,/extend,/date
    fxaddpar,header,'FILENAME',filename,'Name of this file'
    IF (n_elements(origin) NE 0) THEN BEGIN 
        fxaddpar,header,'ORIGIN',origin,'Organization which created this file'
    ENDIF 
    fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
    fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
    fxaddpar,header,'FILTER', filter,'Filter used for observation'
    fxaddpar,header,'AUTHOR','writelc.pro','Program generating this file'
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
        jdstr,jdobs,ddate,ttime
        fxaddpar,header,'DATE-OBS',ddate,'EARLIEST observation date of files'
        fxaddpar,header,'TIME-OBS',ttime,'EARLIEST time of all input files'
        jdstr,jdend,ddate,ttime
        fxaddpar,header,'DATE-END',ddate,'LATEST observation date of files'
        fxaddpar,header,'TIME-END',ttime,'LATEST time of all input files'
    ENDIF 
    fxaddpar,header,'AUTHOR','writelc.pro','Program generating this file'
    fxaddpar,header,'TIMVERSN','OGIP/93-003','OGIP memo defining this file'
    ;;
    fxwrite,filename,header

    ;;
    ;; Create Lightcurve extension
    ;;
    ;; ...header
    fxbhmake,header,n_elements(time),'RATE',/initialize,/date
    ;;jw: HDUCLASS not part of the above standard (stolen from RXTE lcs)
    fxaddpar,header,'HDUCLASS','OGIP    ','conforms to OGIP/GSFC standards'
    fxaddpar,header,'HDUCLAS1','LIGHTCURVE','Extension contains a Light Curve'
    ;;jw: different for bg subtracted???
    fxaddpar,header,'HDUCLAS2','TOTAL   ','Extension contains a Light Curve'
    fxaddpar,header,'HDUCLAS3','RATE    ','Extension contains rate'


    fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
    fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
    fxaddpar,header,'FILTER', filter,'Filter used for observation'
    fxaddpar,header,'AUTHOR','writelc.pro','Program generating this file'
    fxaddpar,header,'TIMVERSN','OGIP/93-003','OGIP memo defining this file'

    IF (n_elements(mjdrefi) NE 0) THEN BEGIN 
        fxaddpar,header,'MJDREFI',mjdrefi,'integer portion of reference time'
        fxaddpar,header,'MJDREFF',mjdreff,'fractional portion of reference time'
    ENDIF ELSE BEGIN 
        IF (n_elements(mjdref) NE 0) THEN BEGIN 
            fxaddpar,header,'MJDREF',mjdref,'reference MJD'
        ENDIF 
    ENDELSE 

    IF (n_elements(timezeri) NE 0) THEN BEGIN 
        fxaddpar,header,'TIMEZERI',timezeri,'integer portion of zero point'
        fxaddpar,header,'TIMEZERF',timezerf,'fractional portion of zero point'
    ENDIF ELSE BEGIN 
        IF (n_elements(timezero) EQ 0) THEN timezero=0D0
        fxaddpar,header,'TIMEZERO',timezero,'zero point of lightcurve'
    ENDELSE 

    IF (n_elements(tstarti) NE 0) THEN BEGIN 
        fxaddpar,header,'TSTARTI',tstarti,'integer portion of start time'
        fxaddpar,header,'TSTARTF',tstartf,'fractional portion of start time'
    ENDIF ELSE BEGIN 
        IF (n_elements(tstart) NE 0) THEN BEGIN 
            fxaddpar,header,'TSTART',tstart,'start time'
        ENDIF 
    ENDELSE 

    IF (n_elements(tstopi) NE 0) THEN BEGIN 
        fxaddpar,header,'TSTOPI',tstopi,'integer portion of stop time'
        fxaddpar,header,'TSTOPF',tstopf,'fractional portion of stop time'
    ENDIF ELSE BEGIN 
        IF (n_elements(tstop) NE 0) THEN BEGIN 
            fxaddpar,header,'TSTOP',tstop,'stop time'
        ENDIF 
    ENDELSE 

    IF (keyword_set(jd)+keyword_set(tjd)+keyword_set(mjd) GT 1) THEN BEGIN 
        message,'Only one of jd, tjd, mjd keywords can be set'
    ENDIF 
    IF (keyword_set(jd)) THEN BEGIN 
        fxaddpar,header,'TIMESYS','JD','Time is measured in JD'
    ENDIF 
    IF (keyword_set(tjd)) THEN BEGIN 
        fxaddpar,header,'TIMESYS','TJD','Time is measured in TJD'
    ENDIF 
    IF (keyword_set(mjd)) THEN BEGIN 
        fxaddpar,header,'TIMESYS','MJD','Time is measured in MJD(=JD-2400000.5)'
    ENDIF 

    IF (keyword_set(second)+keyword_set(day) GT 1) THEN BEGIN 
        message,'Only one of second, day keywords can be set'
    ENDIF 
    tunit=''
    IF (keyword_set(second)) THEN BEGIN 
        fxaddpar,header,'TIMEUNIT','s','Unit for TSTART, TSTOP is seconds'
        tunit='s'
    ENDIF 
    IF (keyword_set(day)) THEN BEGIN 
        fxaddpar,header,'TIMEUNIT','d','Unit for TSTART, TSTOP is days'
        tunit='d'
    ENDIF 
    fxaddpar,header,'TIMEPIXR',0.0,'Timestamps give leading edge of bin'
    IF (keyword_set(utc)) THEN BEGIN 
        fxaddpar,header,'CLOCKCORR','YES','Timesystem is UT'
    ENDIF ELSE BEGIN 
        fxaddpar,header,'CLOCKCORR','NO','Timesystem is NOT corrected to UT'
    ENDELSE 

    IF (n_elements(ontime) NE 0) THEN BEGIN 
        fxaddpar,header,'ONTIME',ontime,'total time on source, in seconds'
    ENDIF 

    IF (keyword_set(backsub)) THEN BEGIN 
        fxaddpar,header,'BACKAPP','T','light curve is background subtracted'
    ENDIF ELSE BEGIN 
        fxaddpar,header,'BACKAPP','F','light curve is not background subtracted'
    ENDELSE 

    IF (keyword_set(backsub)) THEN BEGIN ;;?
        fxaddpar,header,'DEADAPP','T','light curve is deadtime corrected'
    ENDIF ELSE BEGIN 
        fxaddpar,header,'DEADAPP','F','light curve is not deadtime corrected'
    ENDELSE 


    ;;
    ;; ... define columns
    ;;
    fxbaddcol,timcol,header,time[0],'TIME','time',tunit=tunit
    IF (keyword_set(counts)) THEN BEGIN 
        fxbaddcol,ratcol,header,rate[0],'COUNTS',tunit='counts','counts per bin'
    ENDIF ELSE BEGIN 
        fxbaddcol,ratcol,header,rate[0],'RATE',tunit='counts/s','cps'
    ENDELSE 
    IF (errorset EQ 1) THEN BEGIN 
        IF (keyword_set(counts)) THEN BEGIN 
            fxbaddcol,errcol,header,error[0],'ERROR','counts',tunit='counts'
        ENDIF ELSE BEGIN 
            fxbaddcol,errcol,header,error[0],'ERROR','counts/s',tunit='counts/s'
        ENDELSE 
    ENDIF 

    ;; add barycenter column if given:
    IF n_elements(barytime) NE 0 THEN BEGIN 
        fxaddpar,header,'TIMEREF','LOCAL','no pathlength corrections'
        fxbaddcol,barycol,header,barytime[0],'BARYTIME','bary center corrected time', $
          tunit=tunit
        
    ENDIF 
    ;;
    fxbcreate,unit,filename,header
    ;;
    FOR i=0L,n_elements(time)-1 DO BEGIN 
        fxbwrite,unit,time[i],timcol,i+1 ;; time
        fxbwrite,unit,rate[i],ratcol,i+1 ;; rate
        IF (errorset EQ 1) THEN BEGIN 
            fxbwrite,unit,error[i],errcol,i+1 ;; error
        ENDIF 
        IF n_elements(barytime) NE 0 THEN BEGIN 
            fxbwrite,unit,barytime[i],barycol,i+1 ;; bary center corrected time
        ENDIF  
    ENDFOR 
    ;; write file to disk

    fxbfinish,unit

END 
