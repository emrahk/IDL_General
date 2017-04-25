;+
; Project     :	VSO
;
; Name        :	DBASE__DEFINE
;
; Purpose     :	Object wrapper around UIT database software
;
; Category    :	Databases
;
; History     :	3-May-2013, Zarro (ADNET), written.
;
;-

function dbase::init,dbname,_ref_extra=extra

defsysv,'!priv',exists=exists
if exists then !priv=3 else defsysv,'!priv',3

self->set,dbname=dbname,_extra=extra
self.cur_metadata=ptr_new(/all)
self.saved=ptr_new(/all)

return,1

end

;-----------------------------------------------------------

pro dbase::cleanup

ptr_free,self.cur_metadata
ptr_free,self.saved

self->close

return & end

;------------------------------------------------------------
;-- purge database of deleted entries

pro dbase::purge,err=err,verbose=verbose

err=''
if ~self->write_access(err=err) then return
meta=self->getprop(/meta)
if ~have_tag(meta,'deleted') then return
dbname=self->getprop(/dbname)
dbopen,dbname,1
entries = dbfind('deleted=y', /silent,count=count)
if count gt 0 then begin
 if keyword_set(verbose) then mprint,'Purging database of '+trim(count)+' deleted entries...'
 dbdelete, entries 
endif else mprint,'Database already purged.'

self->close
return
end


;---------------------------------------------------------

function dbase::valid_db,err=err,dbf_file=dbf_file

err='' & dbf_file=''

if ~self->have_zdbase(err=err) || ~self->have_dbname(err=err) then return,0b

zdbase=self->getprop(/zdbase)
dbname=self->getprop(/dbname)
dbfile=dbname+'.dbf'

;-- return last successful check

if is_struct(*self.saved) then begin
 chk=where( (zdbase eq (*self.saved).zdbase) and (dbfile eq (*self.saved).dbfile),count)
 if count eq 1 then begin
  dbf_file=(*self.saved)[chk[0]].dbf_file
  dprint,'% VALID_DB: using last checked database...'
  return,1b
 endif
endif 

;-- check locations

valid=0b
if ~is_url(zdbase,/scheme) then begin
 fname=find_with_def(dbfile,'ZDBASE')
 found=is_string(fname)
 if found then valid=file_test(fname,/read,/regular)
endif else begin
 fname=zdbase+'/'+dbfile
 valid=sock_check(fname,response=response)
 if valid then begin
  chk=where(stregex(response,'Accept-Ranges: bytes',/bool),count)
  valid=count ne 0
  if ~valid then mprint,'Warning - byte serving not supported.'
 endif
endelse

if valid then begin
 dbf_file=fname
 stc={zdbase: zdbase,dbfile:dbfile,dbf_file:dbf_file}
 *self.saved=merge_struct(*self.saved,stc)
endif else begin
 err='Database "'+dbname+'" not accessible at '+zdbase
 mprint,err
endelse

return,valid

end
;----------------------------------------------------------

function dbase::have_zdbase,err=err

err=''
if is_blank(self->getprop(/zdbase)) then begin
 err='ZDBASE not defined.'
 mprint,err
 return,0b
endif

return,1b
end

;-----------------------------------------------------------

function dbase::have_dbname,err=err

err=''
if is_blank(self->getprop(/dbname)) then begin
 err='Database name not set.'
 mprint,err
 return,0b
endif

return,1b
end

;------------------------------------------------------------

pro dbase::set,dbname=dbname,zdbase=zdbase,have_deleted=have_deleted,_extra=extra

if is_string(zdbase,/blank) then begin
 setenv,'ZDBASE='+zdbase
 if is_url(zdbase,/scheme) then $
   resolve_routine,'sock_dbopen',/either,/compile else $
    self->recompile
endif

if is_string(dbname,/blank) then self.dbname=trim(dbname)
if keyword_set(have_deleted) then self.have_deleted=1b

return & end

;------------------------------------------------------------

function dbase::getprop,zdbase=zdbase,dbd_file=dbd_file,$
                metadata=metadata,_ref_extra=extra

if keyword_set(zdbase) then return,getenv('ZDBASE')
if keyword_set(metadata) then return,self->get_metadata(_extra=extra)
if keyword_set(dbd_file) then return,self->get_dbd_file(_extra=extra)
return,self->gen::getprop(_extra=extra)

end

;-------------------------------------------------------------

pro dbase::add,def,err=err,replace=replace,verbose=verbose

err=''

verbose=keyword_set(verbose)
if ~self->write_access(err=err) then return
if ~is_struct(def) then begin
 err='Invalid database entry.'
 mprint,err
 return
endif

if n_elements(def) gt 1 then begin
 err='Input must be scalar.'
 mprint,err
 return
endif

if ~self->valid_meta(def) then begin
 err='Invalid metadata input.'
 mprint,err
 return
endif

;-- check if identical entry already in the database
;-- if input ID ge 0 and different entry found in DB then replace it

replace=keyword_set(replace)
found=1b

if def.id ge 0 then begin
 db_def=self->get(def.id,err=err)
 if is_blank(err) then begin
  if match_struct(def,db_def) then begin
   err='Identical entry already in database.'
   mprint,err
   if ~replace then return
  endif
  if ~replace then begin
   mprint,'Entry with same ID already in database. Use /replace to replace'
   return
  endif
 endif else found=0b
endif 

;-- open the database for write access.

self->open,/write,err=err
if is_string(err) then return

;  If adding, find the largest ID currently in the database and
;  increment it.

dbname=self->getprop(/dbname)
n_entries = db_info('entries',dbname)
if n_entries eq 0 then new_id = 0L else begin
 if (def.id lt 0) || ~found then begin
  dbext, -1, 'id', ids
  new_id = max(ids) + 1L
 endif
endelse
if (n_entries eq 0) || (def.id lt 0) || ~found then begin
 if verbose then mprint,'Adding new entry with ID = '+trim(new_id)
 replace=0
endif

;-- if replacing, delete old entry first

if replace then begin
 new_id=def.id 
 if verbose then mprint,'Replacing entry with ID = '+trim(new_id)
 cmd='id='+strtrim(long(new_id),2)
 if self.have_deleted then cmd=cmd+',deleted=n'
 entries = dbfind(cmd,/silent,count=count)
 if count eq 0 then begin
  err='Could not replace old entry.'
  mprint,err
  self->close
  return
 endif
 if self.have_deleted then $
  for i=0,n_elements(entries)-1 do dbupdate, entries[i], 'deleted', 'y' else $
   dbdelete,entries
endif 

;-- add the entry to the database.

tags=tag_names(def)
ntags=n_elements(tags)
cmd="dbbuild,new_id"
for i=1,ntags-2 do cmd=cmd+",def.("+trim(i)+")"
if self.have_deleted then cmd=cmd+",'n'"
cmd=cmd+',status=status'
s=execute(cmd)

;-- update the id number in the structure. Return success.
	
if status ne 0 then def.id = new_id else begin
 err='Write to database was unsuccessful.'
 mprint,err
endelse 

self->close
return
end

;-------------------------------------------------------------------

pro dbase::delete,id,err=err

err=''
if ~self->write_access(err=err) then return
if ~is_number(id) then return
self->close,err=err
if is_string(err) then return
self->open,err=err,/write
if is_string(err) then return

;  Search on ID field.

cmd='id='+strtrim(long(id),2)
if self.have_deleted then cmd=cmd+',deleted=n'
entries = dbfind(cmd,/silent, count=count)

if count eq 0 then begin
 err='Entry ID not found in database.'
 mprint,err
endif else begin
 if self.have_deleted then $
  for i=0,n_elements(entries)-1 do dbupdate, entries[i], 'deleted', 'y' else $
   dbelete,entries
endelse

self->close

return
end


;--------------------------------------------------------------------

function dbase::get,id,err=err,_ref_extra=extra

err=''

if ~is_number(id) then return,-1
self->open,err=err,_extra=extra
if is_string(err) then return,-1

;  Search on ID field.

cmd='id='+strtrim(long(id),2)
if self.have_deleted then cmd=cmd+',deleted=n'
entries = dbfind(cmd,/silent, count=count)

;  If no entries were found, then return immediately.

if count eq 0 then begin
 err='Entry ID not found in database.'
 mprint,err
endif else begin

;  Extract the relevant entry from the database.

 def=self->extract(entries,err=err)
endelse

self->close
if is_string(err) then return,-1 else return,def

return,def
end

;------------------------------------------------------------------------

function dbase::get_dbd_file,err=err

err=''
dbd_file=''
if ~self->valid_db(err=err,dbf_file=dbf_file) then return,''
dbd_file=str_replace(dbf_file,'.dbf','.dbd')

return,dbd_file
end

;-------------------------------------------------------------------------

function dbase::read_metadata,file,_ref_extra=extra

metadata=-1
if is_blank(file) then return,metadata
contents=''
if is_url(file,/scheme) then sock_list,file,contents,_extra=extra else contents=rd_ascii(file)
if is_blank(contents) then return,metadata
contents=detabify(contents)

reg='([^ ]+) +([a-z]+)\*([0-9]+) +(.+)'
meta=stregex(contents,reg,/sub,/ext,/fold)
np=n_elements(meta[0,*])

for i=np-1,0,-1 do begin
 tag=meta[1,i]
 var=meta[2,i]
 mag=fix(meta[3,i])
 if is_string(tag) then begin
  case 1 of
   var eq 'I': val=(mag eq 2)?1:1l
   var eq 'R': val=(mag eq 4)?1.:1.d
   else: val=strpad('',mag)
  endcase
  if is_struct(out) then out=create_struct(tag,val,out) else $
   out=create_struct(tag,val)
endif
endfor
if is_struct(out) then metadata=out

return,metadata & end

;------------------------------------------------------------------------

function dbase::get_metadata,_ref_extra=extra

dbd_file=self->getprop(/dbd_file,_extra=extra)
if is_blank(dbd_file) then return,-1

cur_dbd_file=self->getprop(/cur_dbd_file)

if is_string(cur_dbd_file) && is_string(dbd_file) && is_struct(*self.cur_metadata) then begin
 if cur_dbd_file eq dbd_file then begin
  dprint,'% GET_METADATA: using last read metadata definition..'
  return,*self.cur_metadata
 endif
endif

metadata=self->read_metadata(dbd_file,_extra=extra) 
self.cur_dbd_file=dbd_file
*self.cur_metadata=metadata
self.have_deleted=have_tag(metadata,'deleted')

return,metadata

end
;--------------------------------------------------------------------------

function dbase::extract,entries,err=err

err=''

if ~exist(entries) then return,-1
def=self->getprop(/metadata,err=err)
if is_string(err) then return,-1
tag_list=tag_names(def)
ntags=n_elements(tag_list)
nstart=0 & nend= (ntags-1) < 11
repeat begin
 stags=tag_list[nstart:nend]
 stag_names=arr2str(stags,delim=',')
 s=execute('dbext,entries,"'+stag_names+'",'+stag_names)
 if s eq 0 then begin
  err= 'Failed to read database.'
  mprint,err
  self->close
  return,-1
 endif
 nstart=(nend+1) & nend= (ntags-1) < (nstart+11)
 done= (nstart gt nend)
endrep until done

count=n_elements(entries)
if count gt 1 then def=replicate(def,count)
for i=0,n_elements(tag_list)-1 do begin
 cmd='def.'+tag_list[i]+'='+tag_list[i]
 s=execute(cmd)
endfor

return,def 
end

;-------------------------------------------------------------------
;-- open database

pro dbase::open,update,write=write,err=err,verbose=verbose

err=''
if ~self->valid_db(err=err) then return

update=keyword_set(write)
if ~is_number(update) then update=0
if keyword_set(write) then update=1

if update gt 0 then if ~self->write_access(err=err) then return
dbname=self->getprop(/dbname)
zdbase=self->getprop(/zdbase)

if keyword_set(verbose) then mprint,'Searching "'+dbname+'" database in '+zdbase+'...'

if is_url(zdbase,/scheme) then begin
; resolve_routine,'sock_dbopen',/either,/compile 
 sock_dbopen,dbname,err=err
 if is_string(err) then mprint,err
endif else begin
; self->recompile
 dbopen,dbname,update
endelse

return
end

;-------------------------------------------------------------------

function dbase::write_access,err=err,_ref_extra=extra

err=''
if ~self->valid_db(dbf_file=dbf_file,err=err,_extra=extra) then return,0b
if ~file_test(dbf_file,/write) then begin
 err='No write access to '+dbf_file
 mprint,err
 return,0b
endif

return,1b

end

;----------------------------------------------------------------------
;-- stub method for parent class

function dbase::valid_meta,def,err=err

err=''
return,1b

end

;----------------------------------------------------------------------
;-- stub method for parent class 

pro dbase::list,arg1,output,_ref_extra=extra

if is_blank(arg1) then return

output=dbfind(arg1,-1,_extra=extra)

return
end

;-----------------------------------------------------------
pro dbase::last_update,date

err='' & date=''
if ~self->valid_db(dbf_file=dbf_file,err=err) then begin
 mprint,err
 return
endif

if is_url(dbf_file,/scheme) then date=sock_time(dbf_file) else $ 
 date=file_time(dbf_file)

if n_params() eq 0 then begin
 self->show
 mprint,date
endif

return
end

;----------------------------------------------------------------

pro dbase::show

print,'DBNAME: '+self->getprop(/dbname)
print,'ZDBASE: '+self->getprop(/zdbase)

return
end

;---------------------------------------------------------------
pro dbase::close,_ref_extra=extra

dbclose

return & end

;----------------------------------------------------------------------

pro dbase::recompile

resolve_routine,'dbfind_sort',/either,/compile 
resolve_routine,'dbrd',/either,/compile 
resolve_routine,'dbext_dbf',/either,/compile 
resolve_routine,'dbext_ind',/either,/compile 

return
end

;-----------------------------------------------------------------------

pro dbase__define

struct={dbase,dbname:'',cur_dbd_file:'',cur_metadata:ptr_new(),have_deleted:0b,saved:ptr_new(),inherits gen}

return & end
