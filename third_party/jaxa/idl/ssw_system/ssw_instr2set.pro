
function ssw_instr2set, instr

if not data_chk(instr,/string) then begin
     box_message,'Need input instrument list'
     return,''
endif     

iinstr=instr
if n_elements(iinstr) eq 1 then iinstr=str2arr(iinstr,/nomult)

linstr=strlowcase(strtrim(instr,2))
allinstr=strlowcase(ssw_instruments())
cols=str2cols(allinstr,'/',/unal)
strtab2vect, cols,mission,instruments
missssw=where(mission eq instruments,msswcnt)
if msswcnt gt 0 then mission(missssw)='ssw'

ss=where_arr(instruments,iinstr)
sswsets='ssw_'+mission(ss)+'_'+instruments(ss)

return,sswsets
end
