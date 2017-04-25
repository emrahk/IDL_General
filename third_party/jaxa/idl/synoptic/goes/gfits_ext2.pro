;+
; GFITS_EXT2
; GFITS_EXT2 composes the FITS header for the status word extension
;    for GOES FITS files.
;
; Kim Tolbert 6/18/93
;-

function gfits_ext2, utstart, utend, nstat, sat

s = strarr(36)

utdate = fix(utstart / 86400.d0) * 86400.d0
; Get year, month, day of start time of data in file 
parse_atime, atime(utdate), year=syear, month=smonth, day=sday, /string

; Get current year, month, day
parse_atime, atime(sys2ut()), year=pyear, month=pmonth, day=pday, /string

; Construct header for extension for status words

s(0) = ["XTENSION= 'BINTABLE'", $

 "EXTNAME = 'STATUS'             / name of this binary extension", $

 "BITPIX  =                  -32 / IEEE single precision floating point", $

 "NAXIS   =                    2 / no. of dimensions in array", $

 "NAXIS1  = " + string(format = '(i20)', nstat) + $
          " / no. of status word time intervals", $

 "NAXIS2  =                    3 / time, status1, status2 ", $

 "DATE-OBS= '" + sday + "/" + smonth + "/" + syear + " '         " + $
          " / UT date of first observation (DD/MM/YY)", $

 "TIME-OBS= '" + strmid(atime(utstart),10,7) + " '         " + $
        "  / time of first observation (HHMM:SS)", $

 "TIMEZERO= " + string(format='(f20.1)', utdate) + $
        " / DATE-OBS in seconds from 79/1/1,0", $

 "TELESCOP= 'GOES " + strtrim(fix(sat),2) + $
        "   '          / spacecraft", $

 "INSTRUME= 'X-ray Detector' ", $

 "OBJECT  = 'Sun'", $

 ' ', $

 "ORIGIN  = 'SDAC/GSFC '         / written by Solar DAC at GSFC", $


 "DATE    = '" + pday + "/" + pmonth + "/" + $
           pyear + "'          " + " / file creation date (DD/MM/YY)", $

 ' ', $

 "CTYPE1  = 'seconds'            / seconds into DATE-OBS of 3s " + $
         "interval", $

 "CTYPE2  = 'status1'            / see comments", $

 "CTYPE3  = 'status2'            / see comments", $

 "COMMENT = 'Convert status words to long integer then examine bits. ", $

 "COMMENT = 'Status 1 - octal mask, description (incomplete list): ", $

 "COMMENT = '                 1000, Sun eclipsed by Moon'", $

 "COMMENT = 'Status 2 - octal mask, description (incomplete list): ", $

 "COMMENT = '                    1, X-Ray detector off", $

 "COMMENT = '                    2, X-Ray detector being calibrated", $

 "COMMENT = '                    4, X-Ray Transient", $

 "COMMENT = '                   10, X-Ray short channel saturation", $

 "COMMENT = '                   20, X-Ray long channel range change", $

 "COMMENT = '                   40, X-Ray short channel range change", $

 "COMMENT = '                  200, X-Ray long channel saturation", $

 "END"]

for i_line = 0, 35 do begin
   while strlen(s(i_line)) lt 80 do s(i_line) = s(i_line) + ' '
endfor
;
return, s & end
