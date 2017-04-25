
pro mk_eit_env

;-- find SSW and SSWDB so that EIT software can run

if os_family(/lower) ne 'unix' then return

ssw=''
ssw=chklog('SSW')
if ssw eq '' then begin
 chk=have_proc('read_eit',dir=dir)
 if chk ne 0 then begin
  pos=strpos(dir,'/eit/idl/util')
  if pos gt -1 then begin
   ssw=strmid(dir,0,pos)
   mklog,'SSW',ssw
   dprint,'% MK_EIT_ENV: setting SSW to '+ssw
  endif
 endif
endif

if ssw eq '' then return

mklog,'SSW_EIT',ssw+'/soho/eit'
mklog,'SSW_EIT_RESPONSE',ssw+'/soho/eit/response'
mklog,'SSW_EIT_DOC',ssw+'/soho/eit/doc'
mklog,'SSW_GEN_SETUP',ssw+'/gen/setup'
mklog,'SSW_GEN_DATA',ssw+'/gen/data'
mklog,'coloreit',ssw+'/gen/data/color_table.eit'
mklog,'SSW_GEN',ssw+'/gen'

if chklog('SSWDB') eq '' then  begin
 sswdb=get_sswdb()
 if sswdb ne '' then begin
  mklog,'SSWDB',sswdb
  dprint,'% MK_EIT_ENV: setting SSWDB to '+sswdb
 endif
endif

return & end
