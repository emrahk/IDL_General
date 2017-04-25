pro ssw_colors, table, r, g, b, _extra=_extra
;+
;   Name: ssw_colors
;
;   Purpose: load SSW color tables, optionally return RGB
;
;   Input Parameters:
;
;   Keyword Parameters:
;      Instrument - instrument prefix (eit, sxt, sumer) 
;
;   History:
;      18-Feb-1996 S.L.Freeland
;      13-Nov-2000 S.L.Freeland - include trace CT.
;      21-Feb-2007 Zarro (ADNET) - pass _extra to loadct
;-

if not data_chk(_extra,/struct) then begin
   instrument='EIT'
   offset=41
endif else begin
   names=tag_names(_extra)
   instrument=names(0)
   offset=([0,41])( (tag_names(_extra))(0) eq 'EIT')
endelse

if n_elements(table) eq 0 then table=0
if table ge offset then offset=0

table_file=concat_dir(get_logenv('SSW_GEN_DATA'), $
   'color_table.' + strlowcase(instrument))

if not file_exist(table_file) then begin
   message,/info,"Color Table File: " + table_file + " not found"
   return
endif

tabno=table+offset

dummy='x'		; silly loadct requirement
loadct,file=table_file,get_name=dummy,_extra=_extra

if tabno gt n_elements(dummy) then message,/info,$
   "Specified table number (" + strtrim(tabno,2) + ") does not exist..." else $
   loadct,tabno, file=table_file,_extra=_extra

if n_params() gt 1 then tvlct,r,g,b,/get		; return RGB

return
end
  


