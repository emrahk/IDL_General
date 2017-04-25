;+
; GFITS_FILES
; Returns names of GOES FITS files for a specified time interval and satellite(s)
; stime_sec, etime_sec - start, end time of interval
; satellite - single string or string array of satellite numbers (e.g. '12') 
;
; Explanation : The SDAC archive contain monthly files for 1975 through 1980, and
;   daily files after 4-jan-1980.  The monthly files were copied from 
;   http://goes.ngdc.noaa.gov/data/full/xrays/.
;   Monthly files are named Xxx3yymm.FIT, where
;     xx = 91 (SMS-1), 92 (SMS-2), 01 (GOES1), 02 (GOES2), or 03 (GOES3)
;     3 means 3 second data
;     yymm is 2-digit year, 2-digit month
;
;   The daily files are written by the SDAC.  They are named either:
;    goxxyyyymmdd.fits for times >= 19-Jan-1999 (except for 21-Jan-1999)  or
;    goxxyymmdd.fits   for times <= 19-Jan-1999 (and for 21-Jan-1999)
;  where xx is the 2-digit satellite number, and yy, yyyy is a 2- or 4-digit year,
;  mm is the month, and dd is the day of month.
;
;  This routine returns the list of names constructed for each satellite for
;  each day requested.  It's called by rd_goes_sdac (and goes_fits_files) which will 
;  determine which files actually exist.

; Kim Tolbert 6/93
; Modification History:
; Version 2, Amy.Skowronek@gsfc.nasa.gov, modified findfile call
;	to get longer than two digit years for y2k
; 8-Aug-2008, Kim.  Rewritten to use timegrid function and to include the old data
;   from NOAA (1975-1980)
; 9-Oct-2008, Kim. Return year for directory in year_dir keyword arg (for reorganization
;   of SDAC fits file into year directories) (Don't just prepend 'year/' to file name so
;   that we have the option to also search without year dir.)
;-
pro gfits_files, stime_sec, etime_sec, satellite, files, count, year_dir=year_dir

stime = anytim(stime_sec)
etime = anytim(etime_sec)

pre_1980 = stime lt anytim('4-jan-1980 00:00')

; Pre 1980 are monthly files. Force stime to start of month
if pre_1980 then begin
  ex = anytim(stime,/ext)
  ex[4] = 1
  stime = anytim(ex)
endif

sat = string(satellite,format='(i2.2)')

days = pre_1980 eq 0  ; after 1980 want daily dates
month = pre_1980 eq 1  ; before 1980 want monthly dates

; dates will contain all the dates we need the files for
dates = timegrid (anytim(stime,/date_only), anytim(etime, /date_only), $
   days=days, month=month, /quiet, /utime)
   
; Some of SDAC daily files have 2-digit years, some have 4-digit years.
; year2digit will be 1 or 0 for each date, telling us which should have 2-digit years
year2digit = dates le anytim('19-jan-1999') or dates eq anytim('21-jan-1999')

count = n_elements(dates)
nsat = n_elements(sat)
files = strarr(count, nsat)  ; reform is for case when nsat = 1

dates_ext = anytim(/ext, dates)
year_dir = reform(trim(dates_ext[6,*]))

for i = 0,n_elements(dates) - 1 do begin
  ymd = time2file(dates[i], /date_only, year2digit=year2digit[i])
  files[i,*] = pre_1980 ? 'X' + sat + '3' + strmid(ymd,0,4) + '.FIT' : $
     'go' + sat + ymd + '.fits'
endfor

return & end
