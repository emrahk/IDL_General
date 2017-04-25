function ssw_required_path, _extra=_extra, loud=loud, missing=missing
;
;+
;   Name: ssw_required_path
;
;   Purpose: check if a required path/instrument is defined in session
;
;   Input Parameters:
;      NONE
;
;   Keyword Parameters:
;      /XXX - instrument to check
;
;   Calling Sequence:
;      truth=ssw_required_path(/XXX)  ; where XXX = instrument/mission
;
;   Calling Example:
;      if ssw_required_path(/sxt,/trace) then begin  ; true if SXT&TRACE in !path
;         ....
;
;   History:
;      25-October-1998 - S.L.Freeland
;-

retval=1
loud=keyword_set(loud)
if not data_chk(_extra,/struct) then begin
   box_message,['No instruments specified...', $
		'IDL> truth=ssw_required_path(/xxx [,/yyy,/zzz] )']
   return,0
endif

instr=tag_names(_extra)    
ninstr=n_elements(instr)
ss=where(strpos(instr,'SSW_') ne 0,sscnt)
if sscnt gt 0 then instr(ss)='SSW_'+instr(ss)       ; relative to $SSW_XXX

itruth=lonarr(n_elements(instr))
for i=0,ninstr-1 do begin
  if loud then print,'Checking > $' + instr(i)
  itruth(i)=strpos(!path,get_logenv(instr(i))) ne -1
endfor  

retval=total(itruth) eq ninstr
missing=''                             ; initialize output
imiss=where(itruth eq 0,mcount)
if mcount gt 0 then missing=strmid(instr(imiss),4,20)

if loud then begin
   if retval then box_message,'All required branches in !path' else $
       box_message,['You need to add branches...',missing],/center
endif

return,retval
end
