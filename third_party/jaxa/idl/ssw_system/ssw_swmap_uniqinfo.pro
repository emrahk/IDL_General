pro ssw_swmap_uniqinfo, ucat, uinstr, generate=generate
;+
;
;   Name: ssw_swmap_uniqinfo
;
;   Purpose: Generate or return lists of uniq 'instruments' and uniq categories
;
;   Input Parameters:
;      NONE:
;
;   Output Parameters:
;      ucat -   uniq categories 
;      uinstr - uniq "instruments" (instrument,missions,pacakges...)
;
;   Calling Sequence:
;       ssw_swmap_uniqinfo, ucat, uinstr   - return uniq lists from files
;   -OR-
;       ssw_swmap_uniqinfo, /generate      - make the uniq list files
;                                            (usually part of cron process)
;
;   Category: ssw,system,documentation
;
;   History:
;       6-Oct-1998 - S.L.Freeland - supplement swmap_info 
;       9-Oct-1998 - S.L.Freeland - "flatten" uniq categories (1D)
;                                   via new str2cols call
;-

gen=1
inmap=concat_dir((['$SSW_SITE_SETUP','SSW_GEN_SETUP'])(keyword_set(gen)),'ssw_info_map.dat')
outmap1=concat_dir((['$SSW_SITE_SETUP','SSW_GEN_SETUP'])(keyword_set(gen)),'ssw_map_uniqcat.dat')
outmap2=concat_dir((['$SSW_SITE_SETUP','SSW_GEN_SETUP'])(keyword_set(gen)),'ssw_map_uniqinstr.dat')

if not keyword_set(delimiter) then delimiter='::'

generate=keyword_set(generate) or n_params() eq 0 or (1-file_exist(outmap1))

if generate then begin 
   data=rd_tfile(inmap,delim='::',4)
   cats=reform(data(3,*))
   cats=strmids(cats,strpos(cats,':') eq 0)
;  cats=strmids(cats,0,strlen(cats)-(str_lastpos(cats,'.') eq strlen(cats))-1)
   instrs=reform(data(1,*))
   cats=str2cols(cats,',',/unaligned)
   cats=strtrim(reform(cats,data_chk(cats,/nx)*data_chk(cats,/ny)),2)
   cats=strupcase(strarrcompress(cats))
   ss=where(strpos(cats,'EXPLANATION :') ne 0 and strpos(cats,'PREV. HIST') ne 0)
   cats=cats(ss)
   ucat=all_vals(cats)                     ; uniq subset
   uinstr=all_vals(instrs)                ; uniq instruments
   file_append,outmap1,ucat,/new          ; save for later
   file_append,outmap2,uinstr,/new        ; save for later
endif else begin 
   ucat=rd_tfile(outmap1,nocom=';')
   uinstr=rd_tfile(outmap2,nocom=';')   
endelse

return
end

