PRO TRIPP_GET_GJD, file, gjd, inst,log=log,etime=etime
   
;+
; NAME:
;	TRIPP_GET_GJD
;
; PURPOSE:   
;	Extract date and time from a FITS image header and return
;	GeocenJD of CENTER of exposure.
;       
; CAUTION: Adjust to FITS header structure !
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	TRIPP_GET_GJD, file, gjd, inst,log=log,etime=etime
;
; INPUTS:
;	FILE : Name of FITS file.
;
; OUTPUTS:
;	GJD : GeocenJD of center of exposure.
;
; REVISION HISTORY:
;       Version 1.0, 1996      , Ralf Geckeler -- CCD_TFITS
;       Version 2.0, 1999/02/06, Jochen Deetjen
;       Version 2.0, 1999/08/10, Stefan Dreizler
;       Version 2.1, 2000/06/26, Patrick Risse, Weitere Option fuer
;                                               FITS Header zugefuegt (ST7_E)
;       Version 2.2  2000/11/01, Sonja L.-Schuh, weitere Option fuer CA
;                                               2.2m Site#15
;       Version 2.3  2001/01/15, Sonja L.-Schuh, weitere Option fuer
;                                               MSSSO12 (Australia data)   
;       Version 2.4  2001/01/26, Sonja L.-Schuh, added option 'filetime':
;                                               uses time mark when
;                                               original fits was
;                                               created, independent
;                                               of FITS header
;       Version 2.5  2001/02,    Sonja L.-Schuh, added log and etime
;       Version 2.6  2001/05,    Sonja L.-Schuh, weitere Option fuer CA
;                                               2.2m: BUSCA
;       Version 2.6  2001/05,    Sonja L.-Schuh, weitere Option: MJD        
;                                Sonja L.-Schuh, weitere Option: HJD
;       Version 2.6  2001/07,    Sonja L.-Schuh, weitere Option:
;                                CAN1.2 for new (2001) CA 1.2 fits header
;       Version 2.6  2002/08,    Sonja L.-Schuh, new options: SAAO,
;                                                JD, GUNMA SARA,
;                                                Bohyunsan, WISE
;       Version 2.6  2002/12,    Eckart Goehler, new option: CA1.2-SHIFT
;                                                for CAHA 1.23 m telescope
;                                                including
;                                                start/shutter delay. 
;       Version 2.6  2002/12,    Sonja L. Schuh, new option:PISZEKESTETOE
;                                                careful: year is 2001!
;                                                and repaired timing
;                                                error in SARA and
;                                                PISZEKESTETOE
;
;-
  
 on_error,2                      ;Return to caller if an error occurs
 

   ;; ---------------------------------------------------------
   ;; --- READ FITS FILE HEADER ---
   ;;
   
   CASE 1 OF 
       
       ;; *************************************************************
       inst EQ 'WENDELSTEIN': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT',ut_start
           
           CCD_FHRD,file,'EXPTIME',itime
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '/')
           day   = LONG( date[0] )
           month = LONG( date[1] )
           year  = LONG( date[2] ) + 2000
           hour  = LONG( 0 )
           min   = LONG( 0 )
           
           JULDATE, [year,month,day,hour,min], gjd
           
           ut_time = STR_SEP( STRTRIM( ut_start,2 ), ':')
           time = itime/2. + LONG( ut_time[0])*3600. $
             + LONG( ut_time[1])*60.   $
             + LONG( ut_time[2])
           
           gjd   = gjd + time/86400.0d0

           ;; Get exposure time
           etime=itime

       END
       
       ;; *************************************************************
       inst EQ 'SA_CCD': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT',ut_start
           
           CCD_FHRD,file,'ITIME',itime
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '/')
           day   = LONG( date[0] )
           month = LONG( date[1] )
           year  = LONG( date[2] ) + 1900
           hour  = LONG( 0 )
           min   = LONG( 0 )
           
           JULDATE, [year,month,day,hour,min], gjd
           
           ut_time = STR_SEP( STRTRIM( ut_start,2 ), ':')
           time = itime/2. + LONG( ut_time[0])*3600. $
             + LONG( ut_time[1])*60.   $
             + LONG( ut_time[2])
           
           gjd   = gjd + time/86400.0d0

           ;; Get exposure time
           etime=itime

       END
       
       ;; *************************************************************
       inst EQ 'SAAO': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT',ut_start
           
           CCD_FHRD,file,'ITIME',itime
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = LONG( date[2] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           hour  = LONG( 0 )
           min   = LONG( 0 )
           
           JULDATE, [year,month,day,hour,min], gjd
           
           ut_time = STR_SEP( STRTRIM( ut_start,2 ), ':')
           time = itime/2. + LONG( ut_time[0])*3600. $
             + LONG( ut_time[1])*60.   $
             + LONG( ut_time[2])
           
           gjd   = gjd + time/86400.0d0

           ;; Get exposure time
           etime=itime

       END
       
       ;; *************************************************************
       inst EQ 'SARA': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'TIME-OBS',ut_start
           
           CCD_FHRD,file,'EXPTIME',itime
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = LONG( date[2] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           time  = STR_SEP( STRTRIM( ut_start,2 ), ':')
           hour  = LONG( time[0] )
           min   = LONG( time[1] )
           sec   = LONG( time[2] )
           
           JULDATE, [year,month,day,hour,min,sec], gjd
           
           gjd   = gjd + (itime/2.)/86400.0d0

           ;; Get exposure time
           etime=itime

       END
       
       ;; *************************************************************
       inst EQ 'PISZEKESTETOE': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'TIME-BEG',ut_start
           
           CCD_FHRD,file,'EXPTIME',itime
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '/')
           day   = LONG( date[0] )
           month = LONG( date[1] )
           year  = LONG( 2001)     ;LONG( date[2] )
           time  = STR_SEP( STRTRIM( ut_start,2 ), ':')
           hour  = LONG( time[0] )
           min   = LONG( time[1] )
           sec   = DOUBLE( time[2] )
           
           JULDATE, [year,month,day,hour,min,sec], gjd
           
           gjd   = gjd + (itime/2.)/86400.0d0

           ;; Get exposure time
           etime=itime

       END
       
       ;; *************************************************************
       inst EQ 'CAN1.2': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT_START',time_start
           
           CCD_FHRD,file,'UT_END',time_end
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = STR_SEP( STRTRIM( date[2] ), 'T')
           day   = LONG( day [0] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           
           ;; is the following really reasonable?
           ;; or would time_start + etime/2. be better?
           ;; i.e. does time_end correspond to 
           ;; time_start + etime or to
           ;; time_start + etime + darktime (readout) ?

           IF (time_start LT time_end) THEN BEGIN
               time  = (time_start+time_end)/2.0d0
             ENDIF ELSE BEGIN
               time_end = time_end +86400
               time  = (time_start+time_end)/2.0d0
                      day = day - 1.
                    ENDELSE
           hour  = LONG( 0 )
           min   = LONG( 0 )
           
           JULDATE, [year,month,day,hour,min], gjd
           
           gjd   = gjd + time/86400.0d0
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

         END

       ;; *************************************************************
       inst EQ 'CA1.2': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT_START',time_start
           
           CCD_FHRD,file,'UT_END',time_end
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '/')
           day   = LONG( date[0] )
           month = LONG( date[1] )
           year  = LONG( date[2] ) + 1900
           
           ;; is the following really reasonable?
           ;; or would time_start + etime/2. be better?
           ;; i.e. does time_end correspond to 
           ;; time_start + etime or to
           ;; time_start + etime + darktime (readout) ?

           IF (time_start LT time_end) THEN BEGIN
               time  = (time_start+time_end)/2.0d0
           ENDIF ELSE BEGIN
               time_end = time_end +86400
               time  = (time_start+time_end)/2.0d0
           ENDELSE
           hour  = LONG( 0 )
           min   = LONG( 0 )
           
           JULDATE, [year,month,day,hour,min], gjd
           
           gjd   = gjd + time/86400.0d0
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

       END

       
       ;; *************************************************************
       ;;  CA1.2-SHIFT - USE FOR CAHA 1.23m TELESCOPE, DERIVED FROM CAN1.2
       ;;                TAKING INTO ACCOUNT TIME SHIFT BETWEEN START
       ;;                AND SHUTTER OPEN/CLOSE TIME OF EMPIRICALLY
       ;;                MEASURED 3.8sec.
       ;; *************************************************************

       inst EQ 'CA1.2-SHIFT': BEGIN

           ;; time shift - in sec
           SHIFT_CONST = 3.8D0
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT_START',time_start
           
           CCD_FHRD,file,'UT_END',time_end

           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

                     
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = STR_SEP( STRTRIM( date[2] ), 'T')
           day   = LONG( day [0] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           
           ;; is the following really reasonable?
           ;; or would time_start + etime/2. be better?
           ;; i.e. does time_end correspond to 
           ;; time_start + etime or to
           ;; time_start + etime + darktime (readout) ?

           IF (time_start LT time_end) THEN BEGIN
               time  = time_start + etime / 2.0d0
           ENDIF ELSE BEGIN
               time_end = time_end +86400
               time  = time_start + etime / 2.0d0
               day = day - 1.
           ENDELSE
           hour  = LONG( 0 )
           min   = LONG( 0 )

           ;; shift of mean time:
           time=time+SHIFT_CONST
           
           JULDATE, [year,month,day,hour,min], gjd
           
           gjd   = gjd + time/86400.0d0           

         END
       
       ;; *************************************************************
       inst EQ 'CA2.2': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT_START',time_start
           
           CCD_FHRD,file,'UT_END',time_end
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = STR_SEP( STRTRIM( date[2] ), 'T')
           day   = LONG( day [0] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           
           ;; is the following really reasonable?
           ;; or would time_start + etime/2. be better?
           ;; i.e. does time_end correspond to 
           ;; time_start + etime or to
           ;; time_start + etime + darktime (readout) ?

           IF (time_start LT time_end) THEN BEGIN
               time  = (time_start+time_end)/2.0d0
           ENDIF ELSE BEGIN
               time_end = time_end +86400
               time  = (time_start+time_end)/2.0d0
           ENDELSE
           hour  = LONG( 0 )
           min   = LONG( 0 )
           
           JULDATE, [year,month,day,hour,min], gjd
           
           gjd   = gjd + time/86400.0d0
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

       END
       ;; *************************************************************
       inst EQ 'BUSCA': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'OBS-BEG',time_start
           
           CCD_FHRD,file,'OBS-END',time_end

          CCD_FHRD,file,'SHUTTERO',shutterauf
           
          CCD_FHRD,file,'SHUTTERC',shutterzu
           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '/')
           day   = LONG( date[1] )
           month = LONG( date[0] )
           year  = LONG( date[2] )
           
                                ; --- old version
           
           time_start= STR_SEP( STRTRIM(time_start ,2 ), ':')
           time_end  = STR_SEP( STRTRIM(time_end   ,2 ), ':')

           hour  = LONG( time_start[0] )
           min   = LONG( time_start[1] )
           sec   = LONG( time_start[2] )

           time_start = hour*3600.d + min*60.d + sec

           hour  = LONG( time_end[0] )
           min   = LONG( time_end[1] )
           sec   = LONG( time_end[2] )

           time_end   = hour*3600 + min*60 + sec

           IF (time_start LT time_end) THEN BEGIN
               time  = (time_start+time_end)/2.0d0
           ENDIF ELSE BEGIN
               time_end = time_end +86400
               time  = (time_start+time_end)/2.0d0
           ENDELSE
           hour = LONG(0)
           min  = LONG(0)

                                ; --- overwrite

           time_start = shutterauf
           time_end   = shutterzu

           IF (time_start LT time_end) THEN BEGIN
               time  = (time_start+time_end)/2.0d0
           ENDIF ELSE BEGIN
               time_end = time_end +86400
               time  = (time_start+time_end)/2.0d0
           ENDELSE
           hour  = LONG( 0 )
           min   = LONG( 0 )
 

           JULDATE, [year,month,day,hour,min], gjd
           
           gjd   = gjd + time/86400.0d0
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

       END
       
       ;; *************************************************************
       inst EQ 'EFOSC': BEGIN

           CCD_FHRD,file,'MJD-OBS',gjd  ; read mjd from header, exact enough here
           
           ;; Get exposure time
           head  = headfits(file)
           atime = fxpar(head,'EXPTIME')
           btime = fxpar(head,'ITIME')
           ;CCD_FHRD,file,'EXPTIME',atime
           ;CCD_FHRD,file,'ITIME',btime
           etime   = max(atime,btime)

       END
       
       ;; *************************************************************
       inst EQ 'Bohyunsan': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UT',time_start
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = LONG( date[2] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           
           time  = STR_SEP( STRTRIM( time_start,2 ), ':')
           hour  = LONG(  time[0] )
           min   = LONG(  time[1] )
           sec   = LONG(  time[2] )
           
           JULDATE, [year,month,day,hour,min,sec], gjd
           
           gjd   = gjd + etime/2.d0/86400.d0
           

       END

       ;; *************************************************************
       inst EQ 'WISE': BEGIN
           
           CCD_FHRD,file,'DATE-OBS',date
           
           CCD_FHRD,file,'UTMIDDLE',time_middle
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime
;           CCD_FHRD,file,'HJD',hjd

           
           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           date  = STR_SEP( STRTRIM( date,2 ), '-')
           day   = LONG( date[2] )
           month = LONG( date[1] )
           year  = LONG( date[0] )
           
           time  = STR_SEP( STRTRIM( time_middle,2 ), ':')
           hour  = LONG(  time[0] )
           min   = LONG(  time[1] )
           sec   = LONG(  time[2] )
           
           JULDATE, [year,month,day,hour,min,sec], gjd
           
;           print,hjd-2452000.,HELIO_JD( gjd, ten(5,16,28.81)*15., ten(26,7,38.8))-52000.,gjd-52000.

       END

       ;; *************************************************************
       inst EQ 'MJD': BEGIN

           CCD_FHRD,file,'MJD',gjd  ; read mjd from header, exact enough here
           
           ;; Get exposure time
           head  = headfits(file)
           etime = fxpar(head,'EXPTIME')

           gjd = gjd + etime/43200.d

       END
       ;; *************************************************************
       inst EQ 'HJD': BEGIN

           CCD_FHRD,file,'HJD',gjd  ; read hjd from header, exact enough here
           
           ;; Get exposure time
           head  = headfits(file)
           etime = fxpar(head,'EXPTIME')

           print,"           WARNING:  Getting *H*JD"
       END
       
       ;; *************************************************************
       inst EQ 'JD': BEGIN

           CCD_FHRD,file,'JD',gjd  ; read jd from header, exact enough here
           
           ;; Get exposure time
           head  = headfits(file)
           etime = fxpar(head,'EXPTIME')
           gjd   = gjd - 2400000.d

       END
       
       ;; *************************************************************
       inst EQ 'ST7_E': BEGIN   ;FITS-Header fuer das AIT (40 cm Teleskop)
           
           CCD_FHRD,file,'INSTRUME',instrument
           
           CASE 1 OF 
               instrument EQ 'SBIG ST-7': BEGIN
           
                   CCD_FHRD,file,'DATE-OBS',date
                   
                   CCD_FHRD,file,'TIME-OBS',ut_start
                   
                   CCD_FHRD,file,'EXPTIME',itime
                   
                   ;; ---------------------------------------------------------
                   ;; --- CONVERT STRING ---
                   ;;
                   date  = STR_SEP( STRTRIM( date,2 ), '-')
                   year  = LONG( date[0] ) 
                   month = LONG( date[1] )
                   day   = LONG( date[2] )
                   hour  = LONG( 0 )
                   min   = LONG( 0 )
                   
                   JULDATE, [year,month,day,hour,min], gjd
                   ut_time = STR_SEP( STRTRIM( ut_start,2 ), ':')
                   time = itime/2. + LONG( ut_time(0))*3600. $
                     + LONG( ut_time[1])*60.   $
                     + LONG( ut_time[2])
                   
                   gjd   = gjd + time/86400.0d0
                   
                   ;; Get exposure time
                   etime=itime

               END 
               instrument EQ 'ST7': BEGIN
                   
                   CCD_FHRD,file,'DATE-OBS',date
                   
                   CCD_FHRD,file,'TIME-OBS',ut_start
                   
                   CCD_FHRD,file,'EXPOSURE',itime
                   
                   ;; ---------------------------------------------------------
                   ;; --- CONVERT STRING ---
                   ;;
                   date  = STR_SEP( STRTRIM( date,2 ), '/')
                   day   = LONG( date[0] )
                   month = LONG( date[1] )
                   year  = LONG( date[2] ) + 1900
                   hour  = LONG( 0 )
                   min   = LONG( 0 )
                   
                   JULDATE, [year,month,day,hour,min], gjd
                   ut_time = STR_SEP( STRTRIM( ut_start,2 ), ':')
                   time = itime/2. + LONG( ut_time[0])*3600. $
                     + LONG( ut_time[1])*60.   $
                     + LONG( ut_time[2])
                   
                   gjd   = gjd + time/86400.0d0

                   ;; Get exposure time
                   etime=itime
                   
               END 
               ELSE:   PRINT,"% TRIPP_GET_GJD: instrument ',instrument,' not allowed"   
           ENDCASE 
       END
       
       ;; *************************************************************
       inst EQ 'filetime': BEGIN
           
           file_sep=STR_SEP( STRTRIM( STRCOMPRESS( file ),2),'_reduced')
           ifile=file_sep[0]+file_sep[1]+file_sep[2]
           spawn,' rm -f time'+strtrim(log.block,2)
           spawn,' ls -l --full-time '+ifile+'> time'+strtrim(log.block,2)
           datum=''
           get_lun,unit
           openr,unit,'time'+strtrim(log.block,2)
           readf,unit,datum
           free_lun,unit
           spawn,' rm -f time'+strtrim(log.block,2)

           ;; ---------------------------------------------------------
           ;; --- CONVERT STRING ---
           ;;
           line_sep=STR_SEP( STRTRIM( STRCOMPRESS( datum ),2),' ')
           
           IF line_sep[6] EQ 'Jan' THEN month=1 
           IF line_sep[6] EQ 'Feb' THEN month=2 
           IF line_sep[6] EQ 'Mar' THEN month=3 
           IF line_sep[6] EQ 'Apr' THEN month=4 
           IF line_sep[6] EQ 'May' THEN month=5 
           IF line_sep[6] EQ 'Jun' THEN month=6 
           IF line_sep[6] EQ 'Jul' THEN month=7 
           IF line_sep[6] EQ 'Aug' THEN month=8 
           IF line_sep[6] EQ 'Sep' THEN month=9 
           IF line_sep[6] EQ 'Oct' THEN month=10 
           IF line_sep[6] EQ 'Nov' THEN month=11 
           IF line_sep[6] EQ 'Dec' THEN month=12 
           IF n_elements(month) EQ 0 THEN BEGIN
             print,"% TRIPP_GET_GJD: Please add new month conversion for", line_sep[6]
             return
           ENDIF
           
           time_sep=STR_SEP( STRTRIM( STRCOMPRESS( line_sep[8] ),2),':')
           
           day   = LONG( line_sep[7] )
           month = LONG( month )
           year  = LONG( line_sep[9] )
           hour  = LONG( time_sep[0] )
           min   = DOUBLE( time_sep[1] )
           sec   = DOUBLE( time_sep[2] )
           
           
           JULDATE, [year,month,day,hour,min,sec], gjd

           ;; Get exposure time
           etime=1. ;;!!!!!!! EDIT ?????? How ???? 
           ;; assuming *nothing* is known about the FITS header, 
           ;; maybe better leave it that way ... 

       END 
       
       
       ;; *************************************************************
       inst EQ 'MSSSO12': BEGIN
           
;                CCD_FHRD,file,'DATE-OBS',date
           
;                CCD_FHRD,file,'UT',ut_start
           
;                CCD_FHRD,file,'EXPTIME',itime
           
           result = findfile('ttt',count=count)
           $touch ttt  
             IF (count eq 0) THEN begin
               get_lun,unit
               openw,unit,'ttt'
               printf,unit,0
               free_lun,unit
           ENDIF
           get_lun,unit
           openr,unit,'ttt'
           readf,unit,i
           free_lun,unit
           
           i=i+1
           
           get_lun,unit
           openw,unit,'ttt'
           printf,unit,i
           free_lun,unit
           
           gjd   = i/86400.0d0*30.
           
           ;; Get exposure time
           CCD_FHRD,file,'EXPTIME',etime

       END 
       
       ;; *************************************************************
       inst EQ 'GUNMA': BEGIN
         
         short_file=STR_SEP( STRTRIM( file,2 ), "/")
         last      =n_elements(short_file)-1
         noreduced =STR_SEP( STRTRIM( short_file[last],2 ), "_")
         noreduced =noreduced[0]+".fits"                   ;opt A
;         noreduced =noreduced[0]                           ;opt B
;         noreduced =STR_SEP( STRTRIM( noreduced,2 ), "wd") ;opt B
;         noreduced =noreduced[1]                           ;opt B
         wdfile = [""]
         line   =  ""
         get_lun,unit
         openr,unit,"../gunma_Dec18_reduced/Time1218.dat"
         WHILE wdfile[0] NE noreduced DO BEGIN
           readf,unit,line
           wdfile=STR_SEP( STRTRIM( line,2 ), " ")
         ENDWHILE
         close,unit
         free_lun,unit
         print,"% TRIPP_GET_GJD: Kontrolle:",wdfile[0]
         
         ;; ---------------------------------------------------------
         ;; --- CONVERT STRING ---
         ;;
         day   = LONG( wdfile[7] ) ;opt A
         month = LONG( wdfile[6] ) ;opt A
         year  = LONG( wdfile[5] ) ;opt A
;          day   = LONG( wdfile[14] ) ;opt B
;          month = LONG( wdfile[13] ) ;opt B
;          year  = LONG( wdfile[12] ) ;opt B
         
          time  = STR_SEP( STRTRIM( wdfile[8],2 ), ':') ;opt A
;         time  = STR_SEP( STRTRIM( wdfile[15],2 ), ':') ;opt B

         hour  = LONG( time[0] )
         min   = LONG( time[1] )
         sec   = LONG( time[2] )
         
         JULDATE, [year,month,day,hour,min,sec], gjd
         
         ;; Get exposure time
         etime=1.

       END
       
       ;; *************************************************************
       ELSE: PRINT,"% TRIPP_GET_GJD: instrument ',inst,' not allowed"
       
   ENDCASE 
   
   ;; ---------------------------------------------------------
   ;; --- END ---
   
END
;; ----------------------------------------
   





