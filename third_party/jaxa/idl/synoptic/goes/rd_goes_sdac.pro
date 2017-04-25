;+
; Project     : HESSI
;
; Name        : RD_GOES_SDAC
;
; Purpose     : read GOES SDAC FITS data (a socket wrapper around GFITS_R)
;
; Category    : synoptic gbo
;
; Syntax      : IDL> rd_goes_sdac
;
; Inputs      : See GFITS_R keywords
;
; Outputs     : See GFITS_R keywords
;
; Keywords    : See GFITS_R keywords
;               STIME, ETIME = start/end times to search
;               REMOTE = force a network search
;               NO_CYCLE = don't search all satellites
;
; History     : Written 15 June 2005, D. Zarro, (L-3Com/GSFC)
;               Modified 24 Nov 2005, Zarro (L-3Com/GSFC)
;                - preserve currently defined $GOES_FITS
;               Modified 26 Dec 2005, Zarro (L-3Com/GSFC)
;                - support varied input time formats with anytim
;               Modified 30 Dec 2005, Zarro (L-3Com/GSFC)
;                - improved by only downloading required files
;               Modified Election Night 7 Nov 2006, Zarro (ADNET/GSFC)
;                - check that $GOES_FITS is a valid archive
;               Modified 22 Jan 2007, Zarro (ADNET/GSFC)
;                - corrected returned satellite number
;               Modified 5 May 2007, Zarro (ADNET/GSFC)
;                - added /NO_CYCLE
;               Modified 6-Mar-2008, Kim.
;                - Cycle through sats even when not reading remotely (so we can
;                  skip bad files)
;                - Added error and err_msg as explicit keywords so can use them here
;               Modified 10-Aug-2008, Kim.
;                - Added 'X*' files (pre-1980 files) to cleanup of temp dir at end
;               Modified 9-Oct-2008, Kim. Init found_sat=0, and set
;               err_msg in catch
;               19-Jan-2012, Zarro (ADNET) 
;               - replaced http->copy by sock_copy for better control
;                 thru proxy servers
;               - saved $GOES_FITS in common so that it is only checked
;                 once
;               - ensured that err_msg and error are compatible
;                 (error=0 => err_msg='')
;               - replaced "not" with "~"
;               - added more descriptive /VERBOSE output
;               - added GOES_SAT_LIST to control search list
;               29-Jan-2012, Zarro (ADNET)
;               - removed common and pass download directory via
;                 GOES_DIR
;               19-Feb-2012, Zarro (ADNET)
;                - changed message,/cont to message,/info because
;                  /cont was setting !error_state
;               26-Dec-2012, Zarro (ADNET)
;                - moved network-related messages into GOES_SERVER
;               12-Apr-2013, Zarro (ADNET)
;                - attempt remote search if not found locally 
;                - added check for start time greater than current time
;               24-Oct-2013, Kim.
;                - Added /a_write to mk_dir for temp dir, so anyone can write in it
;
; Contact     : dzarro@solar.stanford.edu
;-

pro rd_goes_sdac,stime=stime,etime=etime,_ref_extra=extra,remote=remote,error=error,$
                 sat=sat,no_cycle=no_cycle,err_msg=err_msg,verbose=verbose

goes_fits_sav=chklog('$GOES_FITS')

verbose=keyword_set(verbose)
cycle=~keyword_set(no_cycle)
remote=keyword_set(remote)

err_msg='' & error=0

if ~valid_time(stime) or ~valid_time(etime) then begin
 err_msg='Invalid or missing input times.'
 error=1
 message,err_msg,/info
 return
endif

get_utc,utc
ctime=anytim(utc)
tstart=anytim(stime)

if tstart gt ctime then begin
 err_msg='No SDAC/GOES data available for specified times.'
 error=1
 message,err_msg,/info
 return
endif

tend=anytim(etime) < ctime

;-- generate satellite search list

search_sats=goes_sat_list(sat,count=count,no_cycle=no_cycle,err=err_msg)
if count eq 0 then begin
 error=1
 return
endif

;-- cycle thru each available GOES satellite until we get a match
;   unless /no_cycle set

sat_name='GOES'+trim(sat)
no_data_error='No '+ (cycle?'SDAC/GOES':sat_name) +' data available for specified times.'

;-- if not forcing a remote, check if GOES_FITS defined

if ~remote and is_string(goes_fits_sav) then begin
 for i=0,n_elements(search_sats)-1 do begin
  tsat=search_sats[i]
  sat_name='GOES'+trim(tsat)
  if verbose then message,'Searching for '+sat_name+'...',/info
  message,/reset
  gfits_r,stime=tstart,etime=tend,sat=tsat,_extra=extra,error=error,err_msg=err_msg,/sdac,/no_cycle,verbose=verbose
  if error eq 0 then begin
   sat = tsat
   err_msg=''
   if verbose then message,'Found GOES'+trim(sat)+' data.',/info
   return
  endif
 endfor
 message,no_data_error,/info
 message,'Attempting remote search...',/info
endif

;-- determine remote location of files

server=goes_server(network=network,_extra=extra,err=err_msg,/sdac,path=path,verbose=verbose)
error=0 & err_msg=''

;-- Create a temporary directory for remote downloading.

goes_dir=goes_temp_dir()
mk_dir,goes_dir,/a_write

goes_url=server+path
for i=0,n_elements(search_sats)-1 do begin
 found_sat=0b
 tsat=search_sats[i]
 sat_name='GOES'+trim(tsat)
 if verbose then message,'Searching for '+sat_name+'...',/info

;-- determine which file names to copy

 files=goes_fits_files(tstart,tend,_extra=extra,sat=tsat,/no_comp)
 if is_blank(files) then continue
 goes_files=goes_url+'/'+files

;-- check if they exist at the server, and download
;-- if server is down, check last downloaded files and hope there is
;   at least one.

 if network then begin
  sock_copy,goes_files,out_dir=goes_dir,local_file=local,_extra=extra,$
                       /use_network,/no_check
  chk=where(file_test(local),count)
  found_sat=count gt 0
 endif else found_sat=1b

;-- if found, then read downloaded files

 if found_sat then begin
  message,/reset
  gfits_r,stime=tstart,etime=tend,sat=tsat,_extra=extra,error=error,/sdac,/no_cycle,$
  err_msg=err_msg,verbose=verbose,goes_dir=goes_dir

;-- if everything is ok then bail out, otherwise try another satellite
;   (unless /no_cycle is set)

  if error eq 0 then break
 endif
endfor

if ~found_sat then error=1
if error eq 0 then begin
 sat=tsat & err_msg=''
 if verbose then message,'Found GOES'+trim(sat)+' data.',/info
endif else err_msg=no_data_error

if (error eq 1) then message,err_msg,/info

;-- clean up old files

old_files=file_since(older=10,patt='go*',count=count,path=goes_dir)
if count gt 0 then file_delete,old_files,/quiet
old_files=file_since(older=10,patt='X*',count=count,path=goes_dir)
if count gt 0 then file_delete,old_files,/quiet

return & end
