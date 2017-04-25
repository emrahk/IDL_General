;+
; Project 	: SDAC
;
; Name		: get_goes
;
; Purpose	: Recursively retrieve GOES daily realtime files from NOAA
;
; Explanation	: Accepts todays date from command line, subtracts one,
;		  checks our GOES_REAL directory to see if we already 
;		  have those files.  If not, goes to get them and write FITS file in
;                 in GOES_FITS, then copies FITS file to GOES_FITS_FINAL.  Gets definition
;                 of those env. vars. by running goes_write_env file.
;
; Use		: IDL> get_goes,date [,/test, ncheck=ncheck, force=force]
;
; Input Keywords: 
;   date - date to get/write file for in anytim format. If no date passed in,
;                   default is yesterday.
;   test - if set, then don't call goes_write_env to set up the correct env
;                   variables for directories to write in (will use curdir())
;   ncheck - number of days backward from date to check that we have files (default=5)
;   force - get and process date even if we already have the file
;
; Example:     get_goes, date='7-Nov-2010'
;
; Outputs	: None
;
; Calls		: DATE2MJD, MJD2DATE
;
; Common	: None
;
; Written	: Amy Skowronek, GSFC, 7 October 2004
;		 22 Feb 2005 - cp finished files to archive and moved 
;			do_fitsfiles call
;		 23 Jun 2005 - changed to fids-out-01
;		 13 Oct 2005 - changed naming convention for 3hr files
;		 22 Aug 2008 - changed to fids-out-01.swpc.noaa.gov
;		 07 Oct 2008 - cleaned up commented out code
;    15 Oct 2008 - Kim.  Add year to directory specifications for copy to archive
;    06-Jan-2009 - Kim.  Comment out copy of file to top directory
;		 05 Mar 2010 Amy - use passive mode
;		 13-Apr-2010 - Kim. Switched to use ngdc site = changed ftp site, goesday filename,
;		   directory to cd to.  (Note these new files are daily, not 3-hour).  And then changed to
;		   use sock_dir and sock_copy instead of ftp.
;    08-Nov-2010 - Kim. Changed dir at ngdc from 14 to 15. GOES 14 retired 4-Nov-2010. GOES15 is primary.
;                  And added !quiet=1 so don't have to sift through all the compile statements.
;    09-Nov-2010 - Kim. Run this from my account now.  Changed to run goes_write_env when not
;                  testing to define dirs to write in.  Rewrote to use anytim and time2file, input
;                  keyword is date instead of yy,mm,dd, and added test keyword.
;    23-May-2011 - Kim. Added ncheck and force keywords. Made it loop back through ncheck days to make
;                  sure we have them all.  Look for output file as well as input file to check if day is
;                  done.
;    14-May-2012, Kim. Call sock_dir with /use_net, and strip off any characters after .csv - problem is
;                  chunked encoding, which can insert extra characters anywhere.  Maybe /use_net fixes that.
;    25-Jun-2012, Kim. Added sat keyword, so we can remake old GOES14 files with corrected times
;    29-Nov-2012, Kim. Added bad_sats and bad_dates_goes15 arrays for data to NOT process. Also, this NO
;                 LONGER calls do_fitsfiles_ascii.  Now for each date, look for what satellite files are 
;                 available for each day, and do all of them.  i.e. now sat loop is inside day loop. 
;                 Previously Amy was calling do_fitsfiles_ascii for a day only if didn't have any files
;                 for that day, but then it missed a second sat if available.  Also, gfits_w_ascii now returns
;                 the file it wrote, and we copy it explicitly to GOES_FITS_FINAL (before constructed
;                 directory, and used date with *s for file name).
;    13-Apr-2015, Kim. GOES 13 has XRS data starting Jan 13 2015. Removed it from bad_sats list (now that's just
;                 a blank), and added first_date_goes13 to check for GOES 13 data.
;                 
;
;-


pro get_goes, date=in_date, test=test, ncheck=ncheck, force=force, sat=sat
!quiet=1

checkvar, ncheck, 5  ; default to check 5 days back from requested day
checkvar, force, 0
checkvar, sat, 15  ; default satellite is 15 as of 4-Nov-2010
sat = trim(sat)

;if test keyword passed in then don't call goes_write_env to set up the environment variables
; that are used when really writing the GOES files.  If the env. vars. aren't defined, they
; default to the current directory.
if ~keyword_set(test) then set_logenv,file='goes_write_env'

dir_real = chklog('GOES_REAL')
if ~file_test(dir_real, /dir, /write) then dir_real = curdir()
dir_fits = chklog('GOES_FITS')
if ~file_test(dir_fits, /dir, /write) then dir_fits = curdir()
dir_fits_final = chklog('GOES_FITS_FINAL')
if ~file_test(dir_fits_final, /dir, /write) then dir_fits_final = curdir()

ngdc_site = 'http://satdat.ngdc.noaa.gov/sem/goes/data/new_full/'

bad_sats = ' '
bad_dates_goes15 = ['25-oct-2012', ' 1-nov-2012', ' 2-nov-2012', ' 3-nov-2012',' 4-nov-2012', '8-nov-2012', $
   '14-nov-2012', '15-nov-2012']
first_date_goes13 = '13-jan-2015'

; Use user's date passed in as in_date, or if none, then default to yesterday as start date
checkvar, in_date, anytim(!stime,/date_only) - 86400.

date = anytim(in_date)

nf=0	;number of files 

for i=0,ncheck-1 do begin

  message, 'Working on ' + anytim(date,/vms,/date), /cont

  y2md = time2file(date, /date_only, /year2digit)
  y4md = time2file(date, /date_only) 

  yy = strmid(y4md,0,4)  
  mm = strmid(y4md,4,2)
  
  url = ngdc_site + yy + '/' + mm + '/'
  sock_dir, url, list, /use_network
  goes_dirs = file_basename(list)
  q = where(stregex(goes_dirs,'^goes[0-9][0-9]',/boolean, /fold_case), count)
  if count gt 0 then goes_dirs = goes_dirs[q] else goto, nextday
  sats = strmid(goes_dirs,4,2)
  message, 'Satellites found for this date: ' + arr2str(sats,','), /cont

  xrs_file_common = '_xrs_2s_' + y4md + '_' + y4md + '.csv' 
  
  for isat = 0,n_elements(sats)-1 do begin
    sat = sats[isat]
    if is_member(sat,bad_sats) then goto, nextsat
    if sat eq '15' and is_member(strlowcase(anytim(date,/vms,/date_only)), bad_dates_goes15) then goto, nextsat
    if sat eq '13' and date lt anytim(first_date_goes13) then goto, nextsat
    
    message, 'Working on sat = ' + sat, /cont

    xrs_file = 'g' + trim(sat,'(i2.2)') + xrs_file_common
    sock_dir, url + goes_dirs[isat] + '/csv', list, /use_network
    q = where (strpos(list, xrs_file) ne -1, n)

    if n gt 0 then begin
      file = list[q]
      infile=''  &  outfile=''
      sock_copy, file, out_dir=dir_real, local_file=infile
      if infile ne '' then gfits_w_ascii, atime(date), fix(sat), infile=infile, outfile=outfile, /y2k
      if outfile ne '' then begin
        cmd = 'cp ' + outfile + ' ' + dir_fits_final + '/' + yy
        print,'Spawning: ' + cmd
        spawn, cmd
      endif
    endif
  nextsat:
  endfor
    
;  goesday_out='go*' + y2md + '*'
;  goesday = 'g*_xrs_2s_' + y4md + '_' + y4md + '.csv'
;
;  numsats_int=2
;  files=file_search(dir_real, goesday, count=nf)
;
;  ; if there are already files for this day, are there enough?
;  ; check for number of satellites, then multiply by nfilesperday.
;  ;nfilesperday = 8
;  nfilesperday = 1
;
;  if nf gt 0 then begin
;    satnames=strmid(files,25,4)
;    numsats=satnames(uniq(satnames))
;    if n_elements(numsats) ge 0 then numsats_int=n_elements(numsats)
;  endif
;  
;  yy = strmid(y4md,0,4)
;  mm = strmid(y4md,4,2)
;    
;  files_final = file_search(dir_fits_final + '/' + yy, goesday_out, count=nfinal)
;  
;  ; Get the files and process them if we any of these are true: 
;  ; 1. don't have all of the original files per day for all sats for this date, or 
;  ; 2. don't have the final FITS file for this date, or
;  ; 3. force is set
;  if nf lt (numsats_int*nfilesperday) or (nfinal lt 1) or force then begin
;    ;Replace the ftp commmands with the following sock_dir, sock_copy commands  Kim, 13-Apr-2010
;    url = ngdc_site + yy + '/' + mm + '/goes'+sat+'/csv'
;    sock_dir, url, list, /use_net
;    q = where (strpos(list, strmid(goesday,2,99)) ne -1, n)
;    if n gt 0 then begin
;      file = list[q]
;      z=ssw_strsplit(file, '.csv', /head)
;      file = z + '.csv'
;      sock_copy, file, out_dir=dir_real
;    endif
;    adate = anytim(date, /vms)
;    print,'Running do_fitsfiles_ascii for ' + adate
;    do_fitsfiles_ascii, adate, adate
;  
;    ; add year directory to input and output directory specification.  Kim 15-oct-2008
;    cmd = 'cp ' + dir_fits + '/' + yy + '/' + goesday_out +'* ' + dir_fits_final + '/' + yy 
;    print,'Spawning:  ' + cmd
;    spawn, cmd
;  
;  endif else print,'Already have input and output files for ' + y4md
  
  nextday:
  date = date - 86400.

endfor

message,'Finished. ',/cont
return
end
