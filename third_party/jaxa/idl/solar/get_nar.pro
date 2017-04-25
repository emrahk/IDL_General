;+
; Project     : SOHO - CDS
;
; Name        : GET_NAR
;
; Purpose     : Wrapper around RD_NAR
;
; Category    : planning
;
; Explanation : Get NOAA AR pointing from $DIR_GEN_NAR files
;
; Syntax      : IDL>nar=get_nar(tstart)
;
; Inputs      : TSTART = start time 
;
; Opt. Inputs : TEND = end time
;
; Outputs     : NAR = structure array with NOAA info
;
; Opt. Outputs: None
;
; Keywords    : COUNT = # or entries found
;               ERR = error messages
;               QUIET = turn off messages
;               NO_HELIO = don't do heliographic conversion
;               LIMIT=limiting no of days in time range
;               UNIQUE = return unique NOAA names
;
; History     : 20-Jun-1998, Zarro (EITI/GSFC) - written
;               20-Nov-2001, Zarro - added extra checks for DB's
;               24-Nov-2004, Zarro - fixed sort problem
;                3-May-2007, Zarro - added _extra to pass keywords to hel2arcmin
;               22-Aug-2013, Zarro - filtered entries from outside
;                                    requested period
;               31-Mar-2015, Zarro - added check for valid NAR directory
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_nar,tstart,tend,count=count,err=err,quiet=quiet,_extra=extra,$
                 no_helio=no_helio,limit=limit,unique=unique

err=''
delvarx,nar
count=0

;-- start with error checks

if ~have_proc('rd_nar') then begin
 sxt_dir='$SSW/yohkoh/gen/idl'
 if is_dir(sxt_dir,out=sdir) then add_path,sdir,/append,/expand
 if ~have_proc('rd_nar') then begin
  err='Cannot find RD_NAR in IDL !path.'
  mprint,err
  return,''
 endif
endif

;-- check if NOAA active region files are loaded

ok=is_dir(chklog('DIR_GEN_NAR'))
if ~ok then begin
 sdb=chklog('SSWDB')
 if sdb ne '' then begin
  dir_gen_nar=concat_dir(sdb,'yohkoh/ys_dbase/nar')
  if is_dir(dir_gen_nar) then mklog,'DIR_GEN_NAR',dir_gen_nar
 endif
 if chklog('DIR_GEN_NAR') eq '' then begin
  err='Cannot locate NOAA files in $DIR_GEN_NAR.'
  mprint,err
  return,''
 endif
endif

err=''
t1=anytim2utc(tstart,err=err)
if err ne '' then get_utc,t1
t1.time=0

;-- default to start of next day

use_def=0b
t2=anytim2utc(tend,err=err)
if err ne '' then begin
 t2=t1
 t2.time=0
 t2.mjd=t2.mjd+1
 use_def=1b
endif

err=''

loud=~keyword_set(quiet)
if (t2.mjd lt t1.mjd) then begin
 err='Start time must be before end time.'
 if loud then mprint,err
 return,''
endif

if is_number(limit) then begin
 if (abs(t2.mjd-t1.mjd) gt limit) then begin
  err='Time range exceeds current limit of '+num2str(limit)+' days.'
  if loud then mprint,err
  return,''
 endif
endif

;-- call RD_NAR

if loud then begin
 mprint,'Retrieving NAR data between '+anytim2utc(t1,/vms)+' and '+anytim2utc(t2,/vms)
endif

rd_nar,anytim2utc(t1,/vms),anytim2utc(t2,/vms),nar,_extra=extra

if ~is_struct(nar) then begin
 err='NOAA data not found for specified times.'
 return,''
endif

;-- strip off times that spill over into next day
          
if use_def then begin
 times=anytim(nar,/tai)
 chk=where( (times ge anytim2tai(t1)) and (times lt anytim2tai(t2)),count)
 if count gt 0 then nar=nar[chk]
endif
         
;-- determine unique AR pointings

count=n_elements(nar)

if ~keyword_set(no_helio) then begin
 if keyword_set(unique) then begin
  sorder = uniq([nar.noaa], sort([nar.noaa]))
  nar=nar[sorder]
 endif
 count=n_elements(nar)
 for i=0,count-1 do begin
  temp=nar[i]
  helio=temp.location
  xy=hel2arcmin(helio[1],helio[0],_extra=extra,date=anytim(temp,/utc_int))*60.
  temp=add_tag(temp,xy[0],'x')
  temp=add_tag(temp,xy[1],'y',index='x')
  new_nar=merge_struct(new_nar,temp) 
 endfor
 return,new_nar
endif else return,nar

end


