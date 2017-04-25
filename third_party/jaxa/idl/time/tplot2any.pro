;+
; PROJECT:
;	HESSI
; NAME:
;	HSI_tplot2any
;
; PURPOSE:
;	This function returns the time in a any format available  
;       using ANYTIM from the tplot time values. What it does is
;       basically moves the refeence time from 1/1/1970 to 1/1/1979
;
;
; CATEGORY:
;	HESSI
;
; CALLING SEQUENCE:
;	any_time = tplot2ANY( tplot_time )
;
; INPUTS:
;       tplot_time: time referenced to 1/1/70
;
; OUTPUTS:
;       any_time: The default is to return the time in seconds, 
;                 but all output formats available to ANYTIM are available.
;
; OPTIONAL KEYWORD INPUTS:
;
;	All keywords available through ANYTIM using keyword inheritance:
;
;       out_style - Output representation, specified by a string:
;               INTS    - structure with [msod, ds79]
;               STC     - same as INTS
;               2XN     - longword array [msod,ds79] X N
;               EX      - 7 element external representation (hh,mm,ss,msec,dd,mm,yy)
;               UTIME   - Utime format, Real*8 seconds since 1-jan-79, DEFAULT!!!!
;               SEC     - same as Utime format
;               SECONDS - same as Utime format
;               TAI     - standard seconds from 1-jan-1958.  Includes leap seconds unlike "SECONDS" output.
;                       NB- The TAI format cannot be used as an input to ANYTIM because it will be interpreted as
;                       number of days (in seconds) from 1-jan-1979.
;               ATIME   - Variable Atime format, Yohkoh
;                         Yohkoh style - 'dd-mon-yy hh:mm:ss.xxx'   or
;                         HXRBS pub style  - 'yy/mm/dd, hh:mm:ss.xxx'
;                         depending on atime_format set by
;                         hxrbs_format or yohkoh_format
;               YOHKOH  - yohkoh style string
;               HXRBS   - HXRBS Atime format /pub, 'yy/mm/dd, hh:mm:ss.xxx'
;               YY/MM/DD- same as HXRBS
;               MJD     - UTC-type structure
;                       = The UTC date/time as a data structure with the
;                         elements:
;
;                               MJD     = The Modified Julian Day number
;                               TIME    = The time of day, in milliseconds
;                                         since the start of the day.
;
;                         Both are long integers.
;               UTC_INT - Same as MJD
;               UTC_EXT - UTC external format, a structure
;                         containing the elements, YEAR, MONTH, DAY, HOUR, MINUTE,
;                         SECOND, and MILLISECOND as shortword integers.
;               CCSDS   - A string variable containing the calendar date in the
;                        format recommended by the Consultative Committee for
;                        Space Data Systems (ISO 8601), e.g.
;
;                               "1988-01-18T17:20:43.123Z"
;
;               ECS     - A variation on the CCSDS format used by the EOF Core
;                        System.  The "T" and "Z" separators are eliminated, and
;                        slashes are used instead of dashes in the date, e.g.
;                               "1988/01/18 17:20:43.123"
;
;               VMS     - Similar to that used by the VMS operating system, this
;                        format uses a three-character abbreviation for the
;                        month, and rearranges the day and the year, e.g.
;
;                               "18-JAN-1988 17:20:43.123"
;
;               STIME   - Based on !STIME in IDL, this format is the same as the
;                        second accuracy, e.g.
;                        VMS format, except that the time is only given to 0.01
;                        second accuracy, e.g.
;
;                               "18-JAN-1988 17:20:43.12"
;
;       or by keywords
;               /ints   -
;               /stc
;               /_2xn
;               /external
;               /utime
;               /seconds
;               /atimes
;               /yohkoh
;               /hxrbs
;               /yymmdd
;               /mjd
;               /utc_int
;               /utc_ext
;               /ccsds
;               /ecs
;               /vms
;               /stime
;               /TAI
;
;       mdy     - If set, use the MM/DD/YY order for converting the string date
;
;       date_only - return only the calendar date portion,
;                       e.g. anytim('93/6/1, 20:00:00',/date_only,/hxrbs) ==> '93/06/01'
;       time_only - return only the time of day portion
;                       e.g. anytim('93/6/1, 20:00:00',/time_only,/hxrbs) ==> '20:00:00.000'
;       truncate - truncate the msec portion of the time displayed in strings.
;
;
; MODIFICATION HISTORY:
;	Version 1, csillag@ssl.berkeley.edu, march 2003
;
;-

function tplot2any, tplot_time, _extra=_extra

IF is_struct( tplot_time ) THEN BEGIN 
    new_time = tplot2any( tplot_time.x, _EXTRA=_extra )
    IF have_tag( tplot_time, 'V') THEN  BEGIN
        return, {x:new_time, y:tplot_time.y, v:tplot_time.v } 
    ENDIF ELSE BEGIN 
        return, {x:new_time, y:tplot_time.y } 
    ENDELSE 
ENDIF 

time = anytim( anytim( tplot_time, /seconds ) -  283996800.d0 , _EXTRA=_extra )

return, time

end
