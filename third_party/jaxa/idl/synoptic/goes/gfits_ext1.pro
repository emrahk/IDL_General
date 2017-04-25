;+
; GFITS_EXT1
; GFITS_EXT1 composes the FITS header for the energy edges extension
;    for GOES FITS files.
;
; Kim Tolbert 6/18/93
;-
function gfits_ext1, utstart, utend, nedges, sat

s = strarr(36)

utdate = fix(utstart / 86400.d0) * 86400.d0
; Get year, month, day of start time of data in file 
parse_atime, atime(utdate), year=syear, month=smonth, day=sday, /string

; Get current year, month, day
parse_atime, atime(sys2ut()), year=pyear, month=pmonth, day=pday, /string

; Construct header for extension for band edges 

s(0) = ["XTENSION= 'BINTABLE'", $

 "EXTNAME = 'EDGES'              / name of this binary extension", $

 "BITPIX  =                  -32 / IEEE single precision floating point", $

 "NAXIS   =                    2 / no. of dimensions in array", $

 "NAXIS1  = " + string(format = '(i20)', nedges) + $
          " / no. of bands ", $

 "NAXIS2  =                    2 / low edge, high edge ", $

 "DATE-OBS= '" + sday + "/" + smonth + "/" + syear + " '         " + $
          " / UT date of first observation (DD/MM/YY)", $

 "TELESCOP= 'GOES " + strtrim(fix(sat),2) + $
        "   '          / spacecraft", $

 "INSTRUME= 'X-ray Detector' ", $

 "OBJECT  = 'Sun'", $

 ' ', $

 "ORIGIN  = 'SDAC/GSFC '         / written by Solar DAC at GSFC", $


 "DATE    = '" + pday + "/" + pmonth + "/" + $
           pyear + "'          " + " / file creation date (DD/MM/YY)", $

 ' ', $

 "CTYPE1  = 'Angstroms'          / low band edges", $

 "CTYPE2  = 'Angstroms'          / high band edges", $

 "END"]

for i_line = 0, 35 do begin
   while strlen(s(i_line)) lt 80 do s(i_line) = s(i_line) + ' '
endfor
;
return, s & end
