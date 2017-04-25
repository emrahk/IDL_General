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
;	Satellite:  6, 7, 8, 9, 10, 11, 12, 14
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
;	Version 5, 00/07/12 amy.skowronek@gsfc.nasa.gov, write fits file locally
;	and then copy to archive.  workaround for writeu/nfs problem.
;	Version 6, 05/10/17 amy.skowrnek@gsfc.nasa.gov, use ascii 3-hour files
; 9-Oct-2008, Kim.  Archive reorganized into year directories because too many files
;   in one dir.  Changed outfile to include 4-digit year in directory name.
; 4-Dec-2009, Kim. Increased max number of points in data array because GOES14 has 2-sec res. Also
;   when there are no status words, doesn't write 3rd extension which causes problems with
;   the reading s/w, so set status to the first time with 2 zeros, just to have a status.
; 7-Jan-2010, Kim. GOES14 input text file has low,high columns in opposite order from earlier satellites. Fixed.
; 13-Apr-2010, Kim. Changed to read the daily files from ngdc.  File names are different, now
;   call goes_day_ascii instead of goes_3hour_ascii, don't loop through files, just one per day. 
;   NOTE: this no longer works for the old 3hour noaa files.
; 19-May-2011, Kim. TELESCOP keyword in all headers had just 'GOES '.  Now has 'GOES 15' (or whatever sat #)
; 26-Mar-2012, Kim. Times returned by goes_day_ascii are relative to the minimum time in array, and that minimum time
;   is returned in firstrec.utstart.  date_obs is the date_only part of firstrec.utstart.  Those times and date_obs 
;   were passed to spectra2fits, and the file was written as though times were relative to the start of the day (date_obs).
;   Now compute offset of firstrec.utstart from date_obs and add it to time array.  So times written in file are
;   really relative to start of day now.  (Only noticed this when Mar 23 2012 data started at ~15:40)
;   Also call date_cur date_cur_flipped (since it's flipped), and don't flip date_obs (previously was flipping it twice)
; 25-Jun-2012. Kim. Change calling args to goes_day_ascii, previously time was returned in data which
;   is a float array (so precision was lost).  Now return dbl time array separately as seconds since 79/1/1.  Changed
;   first_rec structure returned to just return the sat number.
;   R. Vierek at NOAA says times in their files should be end of interval but is 1.024s after end of interval. We
;   want to write midpoint in FITS file, so subtract 2.048s from their times. (Change this if they fix 1.024s error)
;   Also, cleaned up a bit.
; 05-Nov-2012, Kim. Pass in infile so no longer have to construct name again here, and pass out outfile, so no
;   longer have to construct name again in calling routine.
;-
;   
pro gfits_w_ascii, date, satellite, infile=infile, outfile=outfile, y2k=y2k

outfile = ''

y2k = keyword_set(y2k)
parse_atime, date, year=year, month=month, day=day, error=error, /string
;if error ne 0 then goto,getout
utdate = anytim(date,/sec)
adate = anytim(date,/vms,/date)
sat = string(satellite,format='(i2.2)')

data = fltarr(5,43300) ; increased from 28800 for GOES14
nlast = -1
;
;;files = 'go' + sat + '*' + time2file(date, year2digit=1-y2k, /date_only)+ '.*'
;;files = 'go' + sat + '*' + time2file(date, year2digit=1, /date_only)+ '.*'
;;files = 'G' + sat + '-XRS-20' + year + '-' + month + '-' + day +  '*.txt'
;files = 'g' + sat + '_xrs_2s_20' + year + month + day + '_20' + year + month + day + '.csv'
;;
;files = file_search(chklog('$GOES_REAL'), files, count = nfiles)
;if nfiles eq 0 then begin
;  print,'No GOES files found for GOES ',sat,' for day ',adate
;endif else begin
;;   for i=0,nfiles-1 do begin
;;      goes_3hour_ascii, files(i), firstrec, data1
;      i = 0
      ; data has low, high in columns, 3,4.  time has sec since 79/1/1
      goes_day_ascii, infile, file_sat, data, time
      utfile = time[0]
;      print,' Start time of file ', infile, ' is ', anytim(utfile,/vms)
      if (utfile lt utdate) or (utfile gt utdate+86400.d0) then begin
         print, 'ERROR:  File ',files(i), ' contains wrong times.'
         print, '        Expected day: ',adate, $
                '  Contains:', anytim(utfile,/vms)
         goto, getout
      endif
      if file_sat ne fix(sat) then begin
         print, 'ERROR:  File ',files(i), ' contains wrong satellite.'
         print, '        Expected GOES', sat, '  Contains GOES',file_sat
         goto, getout
      endif

;      npoints = n_elements(data1(0,*))
;      nfirst = nlast + 1
;      nlast = nfirst + npoints - 1
;      ;print, 'nfirst, nlast, npoints = ', nfirst,nlast,npoints
;      data(*,nfirst:nlast) = data1
;   endfor

   date_ext = anytim(date,/ext)
   year = trim(date_ext[6])
   outfile = form_filename( 'go'+sat+ (time2file(date,$
      year2digit=1-y2k, /date_only))(0),'.fits',$
      directory=concat_dir(chklog('GOES_FITS'),year))   ; add year directory, kim 9-oct-2008


   ; For GOES14, the order of the columns is reversed.  GOES 14 has low, high in columns 3,4.
   ; Previous satellites had high, low in columns 3,4.
   ; We want rates array to contain time, low channel, high channel

   date_obs=anytim(utfile,hxrbs=1-y2k,ecs=y2k,/date)  ; date-only part of start of data
   time = time - anytim(date_obs) ; now time is relative to start of day
   ; FOR GOES 13,14,15, R. Vierek at NOAA says the time given in their files should be the end
   ; time of the exposure, but currently (6/2012) there is an incorrect offset of 1.024s, i.e.
   ; the data tagged with time t was exposed for the time interval t - 2.048 - 1.024  to   t - 1.024
   ; We want to store the center time of the exposure, so until the NOAA files are fixed,
   ; we'll subtract 2.048/2. + 1.024 to get the mid time.  Once they're fixed, we'll
   ; subtract 2.048/2.
   time = time - 2.048  ; now time is center of exposure interval
   flux = [data[3,*], data[4,*]]  ; low, high channels

   edges = [[1.,8.],[.5,4.]]   ; in Angstroms
;
; prepare to send arrays, keywords and comments to spectra2fits
;
   numext = 3  ; fits file will have edges, fluxe and status extensions
   
   date_cur_flipped=flipdate(anytim(sys2ut(),hxrbs=1-y2k,ecs=y2k,/date))
   
   satname = 'GOES ' + sat
   
;  These are comments for individual keywords. The number of comments
;  should be the same as the number of keywords.
   comments=['file creation date','no. of extensions in file','spacecraft',$
		'','','written by Solar DAC at GSFC']
   head_key={date:date_cur_flipped,numext:numext, $
	telescop:satname, instrume:'X-ray Detector',object:'Sun', $
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
   ext1_key={extname:'EDGES',date:date_cur_flipped,telescop:satname, $
        instrume:'X-ray Detector',object:'Sun',origin:'SDAC/GSFC', $
	comments:comments}

   comments=['name of this binary extension','file creation date','spacecraft',$
                '','','written by Solar DAC at GSFC']
   ext2_key={extname:'FLUXES',date:date_cur_flipped,telescop:satname, $
	instrume:'X-ray Detector',object:'Sun',origin:'SDAC/GSFC', $
	comments:comments}
   com_ext2=['Times given for GOES < 13 are usually 2-3 seconds after start time of.', $
	'interval.  Can not be more exact due to analog filtering of data with time ', $
	'constant of 6-10 seconds.', $
	'GOES 13,14,15 times are the center of the 2.048s exposure interval', $
	'Flux value of -99999.0 means no data.']

   ; Find status words that indicate an abnormal condition (non-zero) and
   ; only write those with their corresponding times.
   qstat = where (data(1,*) ne 0 or data(2,*) ne 0, kstat)
   if kstat gt 0 then begin
      status = (data(0:2,qstat))
      nstat = n_elements(status(0,*))
   endif else status = data[0:2,0]  ; if no status flags set, just use first time
   
   comments=['name of this binary extension','file creation date','spacecraft',$
                '','','written by Solar DAC at GSFC']
   ext3_key={extname:'STATUS',date:date_cur_flipped,telescop:satname, $
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

   spectra2fits,time,flux,date_obs,filename=outfile,com_head=com_head, $
	   head_key=head_key,ext1_key=ext1_key,edges=edges, $
	   edge_unit='angstrom',ext2_key=ext2_key,com_ext2=com_ext2, $
	   flux_unit='W /m**2',status=status,com_ext3=com_ext3, $
     ext3_key=ext3_key,/y2k

;   spawn, 'cp ' + outfile + ' ' + chklog('GOES_FITS')    ; remove this in ~ a week!!! kim 9-oct-2008
      
;   print, ' '
   nlast = n_elements(time)
   print, 'Wrote ',outfile, '  Contains ',nlast, ' points'
   print, ' '
;spawn,'copy '+outfile+' '+outfile_archive
;   print, 'Copied GOES FITS file to ',outfile_archive
;spawn,'del '+outfile+';*'
;   print, 'Deleted ',outfile
;endelse

getout:
end      
