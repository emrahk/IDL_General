;+
; GFITS_HEAD
; GFITS_HEAD composes the primary FITS header for GOES FITS files.
; GFITS_EXT1 and GFITS_EXT2 compose the headers for the energy edge and
; status word extensions.
;
; Kim Tolbert 5/28/93
;-

function gfits_head, utstart, utend, ntimes, sat, numext

s = strarr(36)

utdate = fix(utstart / 86400.d0) * 86400.d0
; Get year, month, day of start time of data in file 
parse_atime, atime(utdate), year=syear, month=smonth, day=sday, /string

; Get year, month, day of end time of data in file
parse_atime, atime(utend), year=eyear, month=emonth, day=eday, /string

; Get current year, month, day
parse_atime, atime(sys2ut()), year=pyear, month=pmonth, day=pday, /string

s(0) = ['SIMPLE  =                    T / file conforms to FITS standard', $

 "EXTEND  =                    T / FITS file contains extensions", $

 'NUMEXT  = ' + string(format = '(i20)', numext) + $
          ' / no. of extensions in file', $

 'BITPIX  =                  -32 / IEEE single precision floating point', $

 'NAXIS   =                    2 / no. of dimensions in array', $

 'NAXIS1  = ' + string(format = '(i20)', ntimes) + $
          ' / no. of time intervals', $

 'NAXIS2  =                    3 / time, X-ray long, X-ray short', $
 
 "DATE-OBS= '" + sday + "/" + smonth + "/" + syear + " '         " + $
          " / UT date of first observation (DD/MM/YY)", $

 "TIME-OBS= '" + strmid(atime(utstart),10,7) + " '         " + $
        "  / time of first observation (HHMM:SS)", $

 "TIMEZERO= " + string(format='(f20.1)', utdate) + $
        " / DATE-OBS in seconds from 79/1/1,0", $

 "DATE-END= '" + eday + "/" + emonth + "/" + eyear + " '         " + $
        " / UT date of last observation (DD/MM/YY)", $

 "TIME-OBS= '" + strmid(atime(utend),10,7) + " '         " + $
        "  / time of last observation (HHMM:SS)", $

 "TELESCOP= 'GOES " + strtrim(fix(sat),2) + $
        "   '          / spacecraft", $

 "INSTRUME= 'X-ray Detector' ", $

 "OBJECT  = 'Sun'", $

 "ORIGIN  = 'SDAC/GSFC '         / written by Solar DAC at GSFC", $


 "DATE    = '" + pday + "/" + pmonth + "/" + $
           pyear + "'          " + " / file creation date (DD/MM/YY)", $

 ' ', $

 "CTYPE1  = 'seconds '     / seconds into DATE-OBS of 3s " + $
         "interval (see comments)", $

 "CTYPE2  = 'watts / m^2'  / in 1. - 8. Angstrom band", $

 "CTYPE3  = 'watts / m^2'  / in .5 - 4. Angstrom band", $

 "COMMENT = 'Energy band information given in extension 1'", $

 "COMMENT = 'Status word information given in extension 2'", $

 "COMMENT = 'Times given are usually 2-3 seconds after start time of " + $
        "interval.'", $

 "COMMENT = 'Can't be more exact due to analog filtering of data with " + $
        "time '", $
 
 "COMMENT = 'constant of 6-10 seconds.'", $

 "COMMENT = 'Flux value of -99999.0 means no data.'", $

 "COMMENT = 'Reference: Solar X-Ray Measurements from SMS-1, " + $
        "SMS-2, and GOES-1;'", $

 "COMMENT = 'Information for Data Users.  " + $
        "Donnelly et al,  June 1977.'", $

 "COMMENT = 'NOAA TM ERL SEL-48'", $


 "COMMENT = 'Reference: SMS GOES Space Environment Monitor Subsystem,'", $

 "COMMENT = 'Grubb, Dec 75, NOAA, Technical Memorandum ERL SEL-42.'", $

 "COMMENT = 'Reference: Expresions to Determine Temperatures and Emission'", $

 "COMMENT = 'Measures for Solar X-ray events from GOES Measurements.'", $

 "COMMENT = 'Thomas et al, 1985, Solar Physics 95, pp 323-329.'", $
 
 'END']

for i_line = 0, 35 do begin
   while strlen(s(i_line)) lt 80 do s(i_line) = s(i_line) + ' '
end
;
return, s & end
