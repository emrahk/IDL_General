;---------------------------------------------------------------------------
; Document name: get_obs_date.pro
; Created by:    Liyun Wang, GSFC/ARC, September 21, 1994
;
; Last Modified: Wed Apr 19 19:05:26 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION leapsec_1972, today
; PURPOSE:
;       Returns the leap seconds to be inserted when converting to TAI
;
; CALLING SEQUENCE:
;       Result = leapsec_1972(today)
;
; INPUTS:
;       TODAY - Modified Julian Day number
;
; RESTRICTIONS:
;       Not valid for dates before 1 January 1972.
;
;       This procedure requires a file containing the dates of all leap
;       second insertions starting with 31 December 1971.  This file
;       must have the name 'leap_seconds.dat', and must be in the
;       directory given by the environment variable TIME_CONV.  It must
;       be properly updated as new leap seconds are announced.
;
; SIDE EFFECTS:
;       If the given MJD is not in the range contained in the file 
;       'leap_seconds.dat', the leap second of the last entry in the file is
;       returned
;
   IF N_ELEMENTS(today) EQ 0 THEN MESSAGE, 'Usage: result=leapsec_1972(mjd)'
   
   filename = find_with_def('leap_seconds.dat','TIME_CONV','')
   IF filename EQ '' THEN BEGIN
      MESSAGE, 'Unable to open "leap_seconds.dat". Check environment ', /cont
      MESSAGE, 'variable TIME_CONV and the existence of the file.' 
   ENDIF
   OPENR,unit,filename,/GET_LUN
   mjd0 = 0l & sec = 0l & sec_sv = 0l
   WHILE NOT EOF(unit) DO BEGIN
      READF,unit, mjd0, sec
      IF mjd0 GT today THEN BEGIN
;---------------------------------------------------------------------------
;        The previous entry is what's needed. Terminate the loop and return
;---------------------------------------------------------------------------
         CLOSE, unit & FREE_LUN, unit
         RETURN, sec_sv
      ENDIF
      sec_sv = sec
   ENDWHILE
   CLOSE, unit & FREE_LUN, unit
;---------------------------------------------------------------------------
;  If this point is reached, the leap second from the last entry is returned
;---------------------------------------------------------------------------
   RETURN, sec_sv
END

FUNCTION sec2tai, second
; PURPOSE:
;       Convert time in seconds since 01/01/70 00:00 into TAI
;
; EXPLANATION:
;       CDS routine TAI2UTC requires that time be represented in seconds
;       from midnight January 1, 1958. Observation times given in FITS headers
;       of many image files are given in seconds since 1970/01/01 00:00. So
;       there is a 12 year (or 378691200 seconds) difference between the two
;       system. Further more, there can be several leap seconds needed to be
;       added to correctly convert time into TAI. This routine calls
;       LEAPSEC_1972 to get the leap second and then returns the correct TAI.
;
; CALLING SEQUENCE:
;       Result = sec2tai(time_in_sec)
;
; INPUTS:
;       time_in_sec - Time in seconds since 01/01/70 00:00
;
; CALLS:
;       LEAPSEC_1972
;
   sec_19700101 = DOUBLE(second)
;---------------------------------------------------------------------------
;  MJD for January 1, 1970 is 40587
;---------------------------------------------------------------------------
   mjd = 40587l+LONG(sec_19700101/86400.d0)
   sec_19580101 = sec_19700101+DOUBLE(378691200)
   sec = leapsec_1972(mjd)
   tai = DOUBLE(sec_19580101+sec)
   RETURN, tai
END

FUNCTION GET_OBS_DATE, header, quiet=quiet
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       GET_OBS_DATE()
;
; PURPOSE:
;       Get date and time of obs. from FTIS header in CCSDS format.
;
; EXPLANATION:
;       Make effort trying to extract date and time of observation from the
;       header of FITS image file. It searches for the following keywords
;       in the FITS header:
;
;          DATE_OBS -- in CCSDS format (a keywork proposed for the SOHO
;                      project)
;          DATE-OBS -- in DD/MM/YY format. If not present, current date will
;                      be returned, and a warning message is issued.
;          TIME-OBS -- in hh:mm:ss format. If not present, current time will
;                      be returned, and a warning message is issued.
;          UTSTOP  -- in seconds from 01/01/70 00:00
;          UTSTART  -- in seconds from 01/01/70 00:00
;          ENDTIME  -- in seconds from 01/01/70 00:00
;          STARTIME -- in seconds from 01/01/70 00:00
;          YEAR     -- Year number
;          MONTH    -- Month of year
;          DAY      -- Day of month
;          HOUR     -- Hour of day
;          MINUTE   -- Minute of hour
;          SECOND   -- Second of minute
;
; CALLING SEQUENCE:
;       GET_OBS_DATE, header, utc
;
; INPUTS:
;       HEADER -- Header of a FITS file
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       UTC -- String of date and time of observation in CCSDS format
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       QUIET -- Suppress any error message if set.
;
; CALLS:
;       DATATYPE, NUM2STR, DMY2YMD, FXPAR, TAI2UTC, GET_UTC, SEC2TAI, REPCHAR
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Science planning
;
; PREVIOUS HISTORY:
;       Written September 21, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;      Liyun Wang, GSFC/ARC, September 27, 1994
;         Added keyword QUIET.
;      Liyun Wang, GSFC/ARC, October 7, 1994
;         Added checkings for image files from Mees SO
;      Version 2, Liyun Wang, GSFC/ARC, December 21, 1994
;         Made it work with data from Mt. Wilson
;      Version 3, Liyun Wang, GSFC/ARC, April 19, 1995
;         Made it capable of dealing with time format of HH.MM.SS    
;
; VERSION:
;       Version 3, April 19, 1995
;-
;
   ON_ERROR, 2
   IF N_PARAMS() NE 1 THEN BEGIN
      PRINT, 'GET_OBS_DATE -- Syntax error.'
      PRINT, '   Usage: Result = GET_OBS_DATE(header)'
      PRINT, ' '
      RETURN, -1
   ENDIF

   IF datatype(header) NE 'STR' THEN BEGIN
      IF NOT KEYWORD_SET(quiet) THEN BEGIN
         PRINT, 'GET_OBS_DATE -- Input parameter has to be of string ' + $
            'type.'
         PRINT, ' '
      ENDIF
      !err = -1
      RETURN, !err
   ENDIF

;---------------------------------------------------------------------------
;  First check the DATE_OBS keyword
;---------------------------------------------------------------------------
   date_obs = fxpar(header,'DATE_OBS')
   IF !err NE -1 THEN RETURN, date_obs

;---------------------------------------------------------------------------
;  Check the ENDTIME and STARTIME keywords (available in KPNO He I 10830 A
;  image data
;
;---------------------------------------------------------------------------
   end_obs = fxpar(header,'ENDTIME')
   IF !err NE -1 THEN BEGIN ; Time is given in sec since 01/01/70 00:00
      untime = sec2tai(end_obs)
      date_obs = tai2utc(untime,/ecs)
      RETURN, date_obs
   ENDIF

   start_obs = fxpar(header,'STARTIME')
   IF !err NE -1 THEN BEGIN ; Time is given in sec since 01/01/70 00:00
      untime = sec2tai(start_obs)
      date_obs = tai2utc(untime,/ecs)
      RETURN, date_obs
   ENDIF

;---------------------------------------------------------------------------
;  Date and time have to be resolved separately. Let's get date first
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
;  Check DATE-OBS keyword (available in LEAR H alpha image data)
;---------------------------------------------------------------------------
   date = fxkvalue(header,['DATE-OBS','DATE','DATEST'])
   IF !err NE -1 THEN BEGIN     ; Found DATE-OBS keyword
;----------------------------------------------------------------------
;     Be careful: Data from Mt. Wilson uses the mm-dd-yy format! We have
;                 to check that
;----------------------------------------------------------------------
      mwo = fxpar(header,'ORIGIN')
      IF !err NE -1 AND STRUPCASE(mwo) EQ "MT. WILSON" THEN BEGIN
         mm = STRMID(date,0,2)
         dd = STRMID(date,3,2)
         yy = STRMID(date,6,2)
         date = dd+'-'+mm+'-'+yy
      ENDIF
      date = dmy2ymd(date)
      IF date NE -1 THEN GOTO, time_str
   ENDIF

;---------------------------------------------------------------------------
;  Image files from Mees Solar Observatory have separate key words for date
;  and time (they all are of integer type)
;---------------------------------------------------------------------------
   year = fxpar(header,'YEAR')
   IF !err NE -1 THEN BEGIN
      IF year LT 100 THEN year = year+1900
      month = fxpar(header,'MONTH')
      day = fxpar(header,'DAY')
      date = num2str(year)+'/'+num2str(month)+'/'+num2str(day)
      GOTO, time_str
   ENDIF

;---------------------------------------------------------------------------
;  Give up. Use the current system date and time
;---------------------------------------------------------------------------
   get_utc, date_obs,/ecs
   PRINT, 'GET_DATE_OBS -- Assume current system date ('+date+').'
   RETURN, date_obs

time_str:
   time = fxkvalue(header,['TIME-OBS','UTSTOP','TIMEST'])
   IF !err NE -1 THEN BEGIN
;---------------------------------------------------------------------------
;     Check if the time is given in HH.MM.SS format (FITS files from MLSO at
;     HAO are of this format)
;---------------------------------------------------------------------------
      tmp = str_sep(time,'.')
      IF N_ELEMENTS(tmp) NE 3 THEN RETURN, date+' '+time
      time = repchar(time,'.',':')
      RETURN, date+' '+time
   ENDIF

;---------------------------------------------------------------------------
;  Wt. Wilson's time is given by TAVG-UT keyword, and is in decimal hours
;---------------------------------------------------------------------------
   hour = fxpar(header,'TAVG-UT')
   IF !err NE -1 THEN BEGIN
      ihour = FIX(hour)
      min = 60.0*(hour-ihour)
      imin = FIX(MIN)
      sec = 60.0*(MIN-imin)
      time = num2str(ihour)+':'+num2str(imin)+':'+num2str(sec,FORMAT='(f6.3)')
      RETURN, date+' '+time
   ENDIF

;---------------------------------------------------------------------------
;  Try Mees SO format
;---------------------------------------------------------------------------
   hour = fxpar(header,'HOUR')
   IF !err NE -1 THEN BEGIN
      minute = fxpar(header,'MINUTE')
      second = fxpar(header,'SECOND')
      IF datatype(second) EQ 'STR' THEN second = 0
      RETURN, date+' '+num2str(hour)+':'+num2str(minute)+':'+num2str(second)
   ENDIF

;---------------------------------------------------------------------------
;  Give up. Use the current system time
;---------------------------------------------------------------------------
   bb = str_sep(systime(),' ')
   time = bb(3)
   PRINT, 'GET_DATE_OBS -- Assume current system time ('+time+').'
   RETURN, date+' '+time
END

;---------------------------------------------------------------------------
; End of 'get_date_obs.pro'.
;---------------------------------------------------------------------------
