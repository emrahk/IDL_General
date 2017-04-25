;+
; PROJECT:  SDAC
;
; NAME:     GFITS_R
;
; PURPOSE:  This procedure reads GOES three second soft X-ray data from
;   either the SDAC or Yohkoh databases.  Default is to use the SDAC
;   data base found at GOES_FITS.
;
; CATEGORY:     GOES
;
; CALLING SEQUENCE:
;   gfits_r, stime=stime, etime=etime,  sat=sat, nosetbase=nosetbase, $
;      tarray=tarray, yarray=yarray, edges=edges, $
;      base_ascii=base_ascii, base_sec=base_sec, $
;      quiet=quiet, sdac=sdac, yohkoh=yohkoh, $
;      numstat=numstat, tstat=tstat, stat=stat, headers=headers, $
;     error=error, err_msg=err_msg, verbose=verbose
;
;   gfits_r, stim='93/1/1,1200', etim='93/1/1,1400', tarray=t, yarray=y
;
; CALLS:
;   CHECKVAR, ANYTIM, ATIME, SETUTBASE, UTIME, GFITS_FILES, FINDFILE,
;   CONCAT_DIR, CHKLOG, MRDFITS, FXPAR, READFITS, SETUT
;
; INPUTS: None.
;
; KEYWORDS:
;
;  INPUT KEYWORDS:
;   STIME:  Mandatory, start time of requested time interval in ASCII
;     format yy/mm/dd,hhmm:ss.xxx (or any format recognized by anytim.pro)
;   ETIME:  Mandatory, end time of requested time interval in ASCII format
;               yy/mm/dd,hhmm:ss.xxx (or any format recognized by anytim.pro)
;   SAT:    6, 7 or 8, 9  for GOES 6, GOES 7 or GOES 8 or GOES 9 data
;     (default is 7)
;   NOSETBASE:  0/1 means don't/do  set the base time in the UTPLOT package
;               common (default is 1, i.e. set base time)
;   SDAC:   If set search only for data in GOES_FITS location, SDAC style.
;   YOHKOH: If set, search only for data using RD_GXD
;   QUIET:  If set, suppress error messages
;   VERBOSE:    If =0 do not print messages
;
;  OUTPUT KEYWORDS:
;   TARRAY: Array of times in seconds since the base time (which will be
;               returned in BASE_ASCII and/or BASE_SEC if requested.  Base time
;               is normally the beginning of the day that the data is on.)
;   YARRAY: Array of flux values for the two GOES channels, yarray (n,0)
;               is flux for long wavelength channel, yarray(n,1) is for short.
;   EDGES:  Edges of the two channels in Angstroms
;   BASE_ASCII: Base time in ASCII string yy/mm/dd,hhmm:ss.xxx for start of day of start of
;     TARRAY.  Times in tarray are in seconds relative to this time. (Same time
;     as in BASE_SEC.)
;   BASE_SEC:   Time in seconds since 1979/1/1,0.0 of starting day.
;
;   NUMSTAT:    Number of status values returned in tstat and stat arrays.
;   TSTAT:  Times corresponding the status words in stat array.
;   STAT:   Status words for times in TSTAT array.  Only status words that
;               indicate an abnormal condition are returned.  There are two
;     status words.  Explanation of the status codes is returned
;     in the header for the status word extension (HEADERS(3)).
;   HEADERS:    HEADERS(0) is the primary header for the FITS file, HEADERS(1)
;               is the header for the channel edges extension, HEADERS(2) is
;               the header for the flux and HEADERS(3) is the header for the
;     status word extension.  Print these headers
;               to see useful information about these files.
;   ERROR:  0/1 means an error was encountered reading file.  Text of
;               error message in ERR_MSG
;   ERR_MSG:    Text of error message when ERROR = 1.
;
; PROCEDURE :   This procedure merges the GOES find and read functions developed
;   independently at the SDAC and for Yohkoh.  The SDAC routine, GFITS_R,
;   reads the GOES data archive for a selected time interval and
;   selected satellite (6, 7 or 8) and returns an array of times and
;   flux values for the two channels. Also returned are the energy edges
;   of the channels, the status words, and the header strings.
;
; MODIFICATION HISTORY:
;   Kim Tolbert 7/93
;   ras, 13-apr-95, reconciled OVMS and OSF for SDAC,Umbra respectively
;   ras, 19-jun-95, file names are now lowercase
;   ras, 27-jan-1997, incorporate rd_gxd for Yohkoh environments
;   RCJ, 05/06/97, to recognize old and new FITS files, clean up
;     documentation
;   richard.schwartz@gsfc.nasa.gov, 6-May-1998. Fixed times for multiple days by
;   using offset time from TIMEZERO in header instead of terrible, horrible former way based
;   on stime. Also sized arrays initially based on length of observing interval, which is the
;   correct method.
;   richard.schwartz@gsfc.nasa.gov, 15-May-1998. Fixed bug introduced on 6-May-1998, left
;   a line in about setting index_array, now removed.
;   richard.schwartz@gsfc, 10-nov-1999. changed initial file read to readfits from
;   mrdfits.  Otherwise old format of sdac fits fails under windows.
;   Kim, 12-apr-2000, include 10 in sat_list.  If sat not passed in or is
;     0, then start search at 6, not 0.
;   Kim, 18-jun-2000, check that yohkoh software is available before calling routine
;     rd_gxd.  Otherwise, crashes.
;   ras, 4-apr-2001, explicitly use first element of stime and etime for comparisons.
;   Kim, 07-Jul-2003.  If rd_gxd isn't found, set error=1
;   ras, 11-aug-2003.  Switched to loc_file from findfile.
;   Kim, 14-Nov-2005.  Added /silent in call to readfits.
;   Zarro, 23-Nov-2005. Added a few calls to 'temporary' and /NO_RETRY
;   Zarro, 17-Jan-2006. Made VERBOSE=0 the default
;   Kim, 19-Apr-2007.  print a message with filename when reading a file
;   Zarro, 6-May-2007
;     - changed /NO_RETRY to /NO_CYCLE to be consistent with RD_GOES_SDAC
;     - added _EXTRA
;     - set SAT_LIST to GOES_SAT(/NUM)
;   Kim, 19-Feb-2008, Check if data has any good values (> 0.) and if not
;     return error, so can continue to look for another sat.
;   Kim, 20-Feb-2008, Fix change of 19-Feb.  Init err_msg='' when init error=0
;   Kim, 6-Mar-2008, Return error if EOF or # extensions in file doesn't match
;     what's in header (some files aren't complete)
;   Kim, 10-Aug-2008, If time is < 1980, call gfits_r_pre_1980 to read files.
;   Kim. 20-Aug-2008, Don't strlowcase file names for pre 1980 files
;   Kim, 9-Oct-2008, Call gfits_files with year_dir keyword.  Place GOES_FITS/year
;     first in loc_file path, followed by GOES_FITS and curdir. (for reorganization
;     of SDAC fits file into year directories)
;   Kim, 14-Oct-2008, Speed up reading SDAC files over network by factor of ~7 by
;     using unit number instead of filename in call to mrdfits (if use filename, it
;     does a file_search on each call (there are 3), which is slow over network).
;   Kim, 7-Dec-2009, increased max possible # data points/day to 43300 for GOES14 (2-sec data)
;   Kim, 28-May-2010, Fixed bug - was using 0:index_array for tarray & yarray, should 
;     have been 0:index_array-1.  This bug only caused problems randomly - depended on 
;     what value happened to be in that last position - that point usually got filtered out
;     by the subsequent time selection a few lines later, but not always.
;     Also, if quiet is set, don't print 'reading file... ' message
;   Kim, 26-Jun-2012, When reading multiple files, errors for a single file (EOF and wrong
;     # of extensions) caused it to jump out of loop and say 'no data'.  Now just 
;     skip that file. 
;   Kim, 19-Nov-2012. Require at least 3 good points in total accumulation to proceed - otherwise
;     go look for next satellite in list.
;   Kim, 25-Sep-2014, Call openr with /swap_if_little_endian because of changes in mrdfits,fxposit,headfits
;   Kim, 02-Jun-2015, Check if long channel has more than 5% nonzero points before accepting this sat's data.
;     Previously only rejected if all zero. 
;-
;*****************************************************************************
;
pro gfits_r, stime=stime, etime=etime,  sat=sat, nosetbase=nosetbase, $
   tarray=tarray, yarray=yarray, edges=edges, $
   base_ascii=base_ascii, base_sec=base_sec, $
   quiet=quiet, sdac=sdac, yohkoh=yohkoh, $
   numstat=numstat, tstat=tstat, stat=stat, headers=headers, $
   error=error, err_msg=err_msg, verbose=verbose, goes_dir=goes_dir,$
   no_cycle=no_cycle

checkvar, yohkoh, 0
checkvar, sdac, 1
checkvar, sat, 0

cycle=1-keyword_set(no_cycle)

if keyword_set(sdac) then begin
    if sat eq 0 then sat = 12
    sat_list=goes_sat(/num)
    retry_gfits_r:

    call_procedure,'gfits_r', stime=stime, etime=etime,  sat=sat, nosetbase=nosetbase, $
    tarray=tarray, yarray=yarray, edges=edges, $
    base_ascii=base_ascii, base_sec=base_sec, $
    /quiet, sdac=0, yohkoh=0, goes_dir=goes_dir, $
    numstat=numstat, tstat=tstat, stat=stat, headers=headers, $
    error=error, err_msg=err_msg,verbose=verbose

    if cycle and (error ne 0) and (n_elements(sat_list) gt 1) then begin
       err_msg = ''
       sat_list = sat_list(where_arr(/noteq,sat_list, sat))
       sat = sat_list(0)
       goto, retry_gfits_r
    endif

    if error then $
       err='Could not find SDAC data for specified parameters'

    return

endif

error = 0
err_msg = ''

checkvar, sat, 7
checkvar, quiet, 0
checkvar, verbose, 0

if not(keyword_set(stime)) or not(keyword_set(etime)) then begin
   err_msg = 'Error: please pass start & end time in STIME & ETIME keywords'
   if not quiet and verbose then print,err_msg
   error = 1
   goto, getout
endif

stime_sec = (anytim(/sec, stime))(0) & etime_sec = (anytim(/sec, etime))(0)

if stime_sec ge etime_sec then begin
   err_msg = 'Error: start time is greater than or equal to end time.'
   if not quiet and verbose then print,err_msg
   error = 1
   goto, getout
endif

pre_1980 = stime_sec lt anytim('4-jan-1980 00:00')

gfits_files, stime_sec, etime_sec, sat, files, nfile, year_dir=year_dir
if not pre_1980 then files = strlowcase(files)

number_days = (anytim(/mjd,etime_sec)).mjd - (anytim(/mjd,stime_sec)).mjd +1
num_data_pts = number_days * 43300L  ; increased from 28850 for GOES14
tarray = dblarr( num_data_pts,/nozero)
yarray = fltarr(num_data_pts,2,/nozero)
tstat = 0.d0
stat = reform(fltarr(2),1,2)
index_array = 0L ;current index into tarray and yarray

if nfile gt 0 then begin
   for ifile=0,nfile-1 do begin
      ; In path for searching for files, put GOES_FITS/year dir first, but keep plain
      ; GOES_FITS in path for compatibility with user copies of archive that don't have
      ; year directory structure. 
      path = (keyword_set(goes_dir)) ? goes_dir : $
        [ concat_dir('$GOES_FITS',year_dir[ifile]), '$GOES_FITS', curdir()]
      
      file = (loc_file( path = path, '*'+files(ifile), count=count))(0)
      
      num_obs_pts = 0

      if count gt 0 then begin
         ;if verbose then message,'Reading FITS file '+file,/cont
         if not quiet then message,'Reading FITS file '+file,/cont
         
         if pre_1980 then begin
            gfits_r_pre_1980, stime_sec, etime_sec, file, tarray, yarray, index_array, tstat, stat, num_obs_pts, edges
            numext = 2 ; so below, we will look at status words returned in tstat,stat
            goto, next_file
         endif
         
         data= readfits(file, header, exten=0, /silent)
         if !error_state.name eq  'IDL_M_FILE_EOF' then begin
           message, /cont, 'Error reading file ' + file
           goto, next_file
         endif
;         numext=fix(fxpar(header, 'NUMEXT'))
;         if numext ne get_fits_nextend(file) then goto, error_getout
         numext = get_fits_nextend(file)
         res=datatype(fxpar(header,'CTYPE1')) ; is it old fits or new binary table?
          ; ctype1 keyword is not in new bin table
         if res eq 'STR' then begin
         ; if old binary fits file:
            timezero = fxpar(header, 'TIMEZERO')
            num_obs_pts = n_elements(data(*,0))
            tarray(index_array) =  temporary(data(*,0)) + timezero
            yarray(index_array,0) = temporary(data(*,1:2))
            if numext lt 1 then begin
              message,/cont, 'No edge information in file ' + file + '. Skipping file.'
              goto, next_file
            endif
            edges = transpose(readfits(file, head1, ext=1, /silent))
            headers = strarr(50,3)
            headers(0,0)=header  & headers(0,1) = head1
            if numext gt 1 then begin
               stat_words = readfits(file, head2, ext=2, /silent)
               tstat = [temporary(tstat), 1.d0 * stat_words(*,0) + timezero]
               stat = [temporary(stat), stat_words(*,1:2)]
               headers(0,2) = head2
            endif
         ; done reading old binary fits file
         endif else begin
         ; if new binary fits table:
            ; open file directly and use unit number in call to mrdfits.  Note that when use unit,
            ; mrdfits leaves file positioned where it stopped reading, so I changed extension to
            ; read.  Actual extension numbers to read are 1,2,3. 
            openr, unit, file, /get_lun, /swap_if_little_endian, error = error
            e=mrdfits(unit,1,head1,/silent) & edges=e.edges  ; ext 1, since just opened
            data=mrdfits(unit,0,head2,/silent)  ; ext 0, since positioned at ext 2 after reading ext 1
            num_obs_pts = n_elements(data.time)
            timezero = anytim(/mjd,0.0d0)
            timezero.mjd = fxpar(head2, 'TIMEZERO')
            tarray(index_array) =  temporary(data.time) +  anytim(timezero,/sec)
            yarray(index_array,0) = transpose(data.flux)
            headers=strarr(50,4)
            headers(0,0) = header & headers(0,1) = head1
            headers(0,2) = head2
            if numext gt 2 then begin
               data = mrdfits(unit,0,head3,/silent) ; ext 0, since positioned at ext 3 after reading ext 2
               tstat = [temporary(tstat),temporary(data.time) + anytim(timezero,/sec)]
               stat=[stat,transpose(data.status)]
               headers(0,3) = head3
            endif
            free_lun,unit
         endelse
         
         next_file:
         ; done reading new binary fits table
         index_array = index_array + num_obs_pts
      endif else if not quiet and verbose then print,'Error: can''t find file ',files(ifile)
      
   endfor

;   if n_elements(tarray) eq 1 then begin
;      err_msg = 'File for requested time not found.'
;      if not quiet and verbose then print,err_msg
;      error = 1
;      goto, getout
;   endif

   ; if index_array is 0, use 0 to get first element, then will have 1 elements and will exit in next test
   tarray = temporary(tarray(0:(index_array-1)>0))  
   yarray = temporary(yarray(0:(index_array-1)>0,*))
   if n_elements(tstat) gt 1 then begin
      tstat = temporary(tstat(1:*))
      stat = temporary(stat(1:*,*))
   endif

   if n_elements(tarray) eq 1 then begin
      err_msg = 'File for requested time not found.'
      if not quiet and verbose then print,err_msg
      error = 1
      goto, getout
   endif
   
   q = where ((tarray gt stime_sec-3.) and (tarray lt etime_sec), count)
   ; require at least 3 good points. 19-Nov-2012
   if count gt 2 then begin
      tarray = tarray(q)
      yarray = yarray(q,*)
      qgood = where(yarray[*,0] ne 0., ngood)
      if ngood eq 0 || float(ngood) / n_elements(yarray[*,0]) lt .05 then begin
;      if max(yarray) le 0. then begin
      	error = 1
      	err_msg = 'No good data in selected time interval for GOES ' + trim(sat)
      	message,err_msg,/info
      	goto, getout
      endif
      base_sec = anytim( tarray(0),/date,/sec)
      tarray = temporary(tarray) - base_sec
      base_ascii = atime(base_sec)
      if not(keyword_set(nosetbase)) then setut, utbase=base_ascii
      if verbose then begin
         print,'   Start time: ' + atime(tarray(0) + base_sec)
         print,'   End time:   ' + atime(tarray(n_elements(tarray)-1) + base_sec)
         print,'   Number of time intervals:  ',n_elements(tarray)
      endif
   endif else begin
      tarray = [-1.]
      yarray = [-1., -1.]
      err_msg = 'No data in selected time interval for GOES ' + trim(sat)
      print,err_msg
      error = 1
      goto, getout
   endelse

   if numext gt 1 then begin
      q = where ((tstat ge stime_sec) and (tstat lt etime_sec), count)
      if count gt 0 then begin
         tstat = temporary(tstat(q)) - base_sec
         stat = temporary(stat(q,*))
         numstat = count
      endif else begin
         numstat = 0
         stat = 0.
         tstat = 0.
      endelse
   endif else numstat = -1

endif else begin
   err_msg = 'Error: no files found between requested times'
   if not quiet and verbose then print,err_msg
   if not quiet and verbose then print,'       Start: ', stime
   if not quiet and verbose then print,'       End:   ', etime
   error = 1
   goto, getout
endelse

getout:
return

error_getout:
error = 1
err_msg = !error_state.msg
return

end
