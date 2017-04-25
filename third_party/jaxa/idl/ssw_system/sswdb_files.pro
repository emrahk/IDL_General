function sswdb_files, time0, time1, _extra=_extra, pattern=pattern
;
;+
;   Name: sswdb_files
;
;   Purpose: return various $SSWDB file lists
;
;   Input Parameters:
;      time0, time1 - optional time range for dbsets which are time-centric
;
;   Keyword Parameters:
;      pattern - optional file pattern to match
;      _extra - instrument, environmental and/or dbset 
;               (for string match
;
;   Calling Example:
;      files=sswdb_files(/hessi,/test)
;   
;   Calls:
;      sswdb_info, sel_filetimes, and ssw
;
;   History:
;      14-Feb-2002 - S.L.Freeland - exploit $SSWDB org. and sswdb_info.pro
;      18-Mar-2003 - S.L.Freeland - add /BETWEEN to sel_timrange
;
;   Restrictions:
;      if time/time range specified, dbfile names assume UT time [yy]yymmdd[...]
;
;-
if data_chk(_extra,/struct) then ipat=tag_names(_extra) else ipat='/'

sswdb_info, xx, pattern=ipat, dbenv=dbenv, dbsize=dbsize, relpath=relpath

if not data_chk(pattern,/string) then pattern='*' else $
   pattern='*'+pattern+'*'
pattern=str_replace(pattern,'**','*')

topdir=concat_dir('$SSWDB',dbenv)

files=file_list(topdir,pattern)


if files(0) eq '' then begin 
   box_message,'No files found...'
   return,''
endif

retval=temporary(files)
if n_params() gt 0 then begin   ; optional time range filter
   ftimes=file2time(retval,out='int')
   case n_params() of 
      1: ss=tim2dset(ftimes,anytim(time0,/int))
      else:ss=sel_timrange(ftimes,anytim(time0,/int), anytim(time1,/int),/between)
   endcase
   if ss(0) eq -1 then begin
      retval=''
      box_message,'No files matching input time(s)' 
   endif else retval=retval(ss) 
endif
return,retval

end
