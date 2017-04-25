function ssw_dbase_info, tag, mission=mission, instr=instr, $
   units=units, autolog=autolog

if not data_chk(tag,/string) then begin 
   box_message,'Need a tag to match...'
   return,0
endif

dbasefile='ssw_dbase_info.dat'

dbaselocs=concat_dir(['$SSW/site/idl/util','$SSW_GEN_SETUP'], $
   dbasefile)

chkss=where(file_exist(dbaselocs),ecnt)
if ecnt eq 0 then begin
   box_message,'ssw_dbase_info.dat not found..., returning'
   return,0
endif

dbasex=dbaselocs(chkss(0))                  ; take first

dbaseinfo=rd_tfile(dbasex,nocom=';')
dbaseinfo=strarrcompress(dbaseinfo)

info=ssw_strsplit(dbaseinfo,"'",tail=descriptions)
descriptions=str_replace(descriptions,"'","")
cols=str2cols(info,' ',/unalign,/trim)
strtab2vect,cols,mission,instr,dbtag,autolog,source

; now find the desired value
ss=where(strupcase(tag(0)) eq strupcase(dbtag),sscnt)

if sscnt gt 1 then box_message,'Warning: more than one match, returning 1st'

retval=sscnt gt 0
if retval then begin 
   ss=ss(0)
   mission=mission(ss)
   instr=instr(ss)
   units=descriptions(ss)
   autolog=fix(autolog(ss))
endif

return,retval
end

