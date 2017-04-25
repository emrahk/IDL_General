;+
; PROJECT:
;	SDAC
;	
; NAME: GFITS_W
;
; PURPOSE:  
;   Write a GOES FITS file for the date and satellite specified.  
;
; CATEGORY:  GOES
;
; CALLING SEQUENCE:
;	GFITS_W, date, satellite
; CALLS:
;	PARSE_ATIME, UTIME, FINDFILE, ANYTIM, GOES_3HOUR, YYDOY_2_UT,
;	ATIME, FLIPDATE, SYS2UT, SPECTRA2FITS
;
; INPUTS:
;	Date:	date to write FITS file for.  Any format accepted by anytim.
;	Satellite:  6, 7, 8, 9, 10
; OPTIONAL KEYWORD INPUTS:
;	Y2K - if set the FITS date keywords are written as dd/mm/yyyy instead
;	of dd/mm/yy.
;
; OUTPUTS:
;	FITS file written to GOES_FITS:GO*.FITS or $GOES_FITS/go*.fits
;
; PROCEDURE:
;       Calls GOES_3HOUR to read the 8 GOES 3-hour files copied from SEL, 
;	and accumulates all the data from the 8 files.  Then calls 
;	SPECTRA2FITS to write binary FITS table where the primary data 
;	unit contains no data, the first extension contains the edges, 
;	fluxes are in the second extension, and status words are in the 
;	third extension. Routine GFITS_R reads these GOES FITS files. 
;
; MODIFICATION HISTORY:
; 	Written by Kim Tolbert
;	Mod. 05/97 by RCJ to write binary FITS table.
;	Version 3, richard.schwartz@gsfc.nasa.gov, platform independent (unix and Vms)
;	and FITS keywords are y2k compliant with y2k switch set.  Filenames are also
;	written with 4 digit strings
;       Version 4, amy.skowronek@gsfc.nasa.gov, implemented y2k changes
;-
;   
pro gfits_w, date, satellite, y2k=y2k

y2k = keyword_set(y2k)
;parse_atime, date, year=year, month=month, day=day, error=error, /string
;if error ne 0 then goto,getout
utdate = anytim(date,/sec)
sat = string(satellite,format='(i2.2)')

data = fltarr(5,28800)
nlast = -1

;files = 'go' + sat + '*' + time2file(date, year2digit=1-y2k, /date_only)+ '.*'
files = 'go' + sat + '*' + time2file(date, year2digit=1, /date_only)+ '.*'
files = loc_file (path='GOES_REAL' , files, count = nfiles)
if nfiles eq 0 then begin
  print,'No GOES files found for GOES ',sat,' for day ',anytim(date,/hxrbs,/date)
endif else begin
   for i=0,nfiles-1 do begin
      goes_3hour, files(i), firstrec, data1
;      utfile = yydoy_2_ut([firstrec(0) mod 100, firstrec(1)]) + data1(0)
      utfile = yydoy_2_ut([firstrec(0), firstrec(1)]) + data1(0)	;yydoy_2_ut accepts 4 digits.
      print,' Start time of file ', files(i), ' is ', atime(utfile)
      if (utfile lt utdate) or (utfile gt utdate+86400.d0) then begin
         print, 'ERROR:  File ',files(i), ' contains wrong times.'
         print, '        Expected day: ',atime(utdate), $
                '  Contains:', atime(utfile)
         goto, getout
      endif
      if firstrec(2) ne fix(sat) then begin
         print, 'ERROR:  File ',files(i), ' contains wrong satellite.'
         print, '        Expected GOES', sat, '  Contains GOES',firstrec(2)
         goto, getout
      endif

      npoints = n_elements(data1(0,*))
      nfirst = nlast + 1
      nlast = nfirst + npoints - 1
      ;print, 'nfirst, nlast, npoints = ', nfirst,nlast,npoints
      data(*,nfirst:nlast) = data1
   endfor

   outfile = form_filename( 'go'+sat+ (time2file(date,$ 
	year2digit=1-y2k, /date_only))(0),'.fits',$
	directory='GOES_FITS')


   rates = ([data(0,0:nlast), data(4,0:nlast), data(3,0:nlast)])
   utstart = yydoy_2_ut([firstrec(0), firstrec(1)]) + rates(0,0) 
   ;utdate = fix(utstart/86400.d0) * 86400.d0 ;wasn't needed, calc. date_obs directly.
   edges = [[1.,8.],[.5,4.]] 
;
; prepare to send arrays, keywords and comments to spectra2fits
;
   numext = 3  ; fits file will have edges, fluxe and status extensions
   date_cur=flipdate(anytim(sys2ut(),hxrbs=1-y2k,ecs=y2k,/date))
   date_obs=flipdate(anytim(utstart,hxrbs=1-y2k,ecs=y2k,/date))
;  These are comments for individual keywords. The number of comments
;  should be the same as the number of keywords.
   comments=['file creation date','no. of extensions in file','spacecraft',$
		'','','written by Solar DAC at GSFC']
   head_key={date:date_cur,numext:numext, $
	telescop:'GOES ',instrume:'X-ray Detector',object:'Sun', $
	origin:'SDAC/GSFC',comments:comments}
   com_head=['Energy band information given in extension 1', $
      'Fluxes information given in extension 2', $
      'Status word information given in extension 3', $
      'Ref.: Solar X-Ray Measurements from SMS-1, SMS-2, and GOES-1;', $
      'Information for Data Users. Donnelly et al,  June 1977.', $
      'NOAA TM ERL SEL-48', $
      'Ref.: SMS GOES Space Environment Monitor Subsystem,', $
      'Grubb, Dec 75, NOAA, Technical Memorandum ERL SEL-42.', $
      'Ref.:Expresions to Determine Temperatures and Emission', $
      'Measures for Solar X-ray events from GOES Measurements.', $
      'Thomas et al, 1985, Solar Physics 95, pp 323-329.']

   comments=['name of this binary extension','file creation date','spacecraft',$
                '','','written by Solar DAC at GSFC']
   ext1_key={extname:'EDGES',date:date_cur,telescop:'GOES ', $
        instrume:'X-ray Detector',object:'Sun',origin:'SDAC/GSFC', $
	comments:comments}

   comments=['name of this binary extension','file creation date','spacecraft',$
                '','','written by Solar DAC at GSFC']
   ext2_key={extname:'FLUXES',date:date_cur,telescop:'GOES ', $
	instrume:'X-ray Detector',object:'Sun',origin:'SDAC/GSFC', $
	comments:comments}
   com_ext2=['Times given are usually 2-3 seconds after start time of interval.', $
	'Can not be more exact due to analog filtering of data with time ', $
	'constant of 6-10 seconds.', $
	'Flux value of -99999.0 means no data.']

   ; Find status words that indicate an abnormal condition (non-zero) and
   ; only write those with their corresponding times.
   qstat = where (data(1,*) ne 0 or data(2,*) ne 0, kstat)
   if kstat gt 0 then begin
      status = (data(0:2,qstat))
      nstat = n_elements(status(0,*))
   endif
   comments=['name of this binary extension','file creation date','spacecraft',$
                '','','written by Solar DAC at GSFC']
   ext3_key={extname:'STATUS',date:date_cur,telescop:'GOES ', $
	instrume:'X-ray Detector',object:'Sun',origin:'SDAC/GSFC', $
	comments:comments}
   com_ext3=['Convert status words to long integer then examine bits.', $
      'Status 1 - octal mask, description (incomplete list):', $
      '                 1000, Sun eclipsed by Moon', $
      'Status 2 - octal mask, description (incomplete list):', $
      '                    1, X-Ray detector off', $
      '                    2, X-Ray detector being calibrated', $
      '                    4, X-Ray Transient', $
      '                   10, X-Ray short channel saturation', $
      '                   20, X-Ray long channel range change', $
      '                   40, X-Ray short channel range change', $
      '                  200, X-Ray long channel saturation']
;                                                                 
time=reform(rates(0,*)) & flux=rates(1:2,*)
spectra2fits,time,flux,flipdate(date_obs),filename=outfile,com_head=com_head, $
	head_key=head_key,ext1_key=ext1_key,edges=edges, $
	edge_unit='angstrom',ext2_key=ext2_key,com_ext2=com_ext2, $
	flux_unit='W /m**2',status=status,com_ext3=com_ext3, $
        ext3_key=ext3_key,/y2k

   print, ' '
   print, 'Wrote GOES FITS file ',outfile, '  Contains ',nlast+1, ' points'
   print, ' '
endelse

getout:
end      
