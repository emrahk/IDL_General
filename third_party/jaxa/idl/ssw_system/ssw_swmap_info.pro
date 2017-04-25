pro ssw_swmap_info, pattern, matches, nmatch, delimiter=delimiter, $
	mapfile=mapfile, quiet=quiet, refresh=refresh, $
	_extra=_extra, gen=gen, site=site, more=more, instrument=instrument
;+
;
;   Name: ssw_swmap_info
;
;   Purpose: Generate 'enhanced' SSW mapfile to add one liners and categories
;
;   Category: ssw,system
;
;   History:
;       8-sep-1998 - S.L.Freeland 
;      10-sep-1998 - S.L.Freeland - make temporary version till finished
;       6-Oct-1998 - S.L.Freeland - add N.A. to purpose if not defined
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-
gen=1
defmap=concat_dir((['$SSW_SITE_SETUP','SSW_GEN_SETUP'])(keyword_set(gen)),'ssw_map.dat')
omap=str_replace(defmap,'_map','_info_map_temp')
fmap=str_replace(omap,'_temp','')

if not keyword_set(delimiter) then delimiter='::'

sswloc,pattern,files,matches,/instrument,/gen

instr=str_replace(strupcase(strextract(files,'$SSW_','/')),'/','_')
ss=where(instr eq '',ncnt)
if ncnt gt 0 then $ 
   instr(ss)=str_replace(strupcase(strextract(files(ss),'$SSW/','/')),'/','_')
instr=strmids(instr,([0,1])(strpos(instr,'_') eq 0))

box_message,'Writing map file>> ' + omap

pr_status,txt,/idldoc

file_append,omap,txt,/new

for i=0,matches-1 do begin 
   break_doc,files(i),struct=struct
   catdir=str2cols(files(i),'/')
   category=strtrim((catdir)(n_elements(catdir)-2>0),2)
   scat=strtrim(struct.category,2)
   if strpos(scat,'\\\\') ne -1 then scat=strextract(scat,'','\\\\')
   if scat ne '' then category=arr2str([category,scat])
   purpose=strtrim(str_replace(struct.purpose,'\\',' '),2)
   if purpose eq '' then begin
      dat=rd_tfile(files(i))
      pss=wc_where(dat,';*purpose*',/case_ignore,pcnt)
      if pcnt gt 0 then begin
          purpose=strtrim(arr2str(ssw_strsplit(dat(pss),'Purpose:',/tail),' '),2)
          if purpose eq '' then $
             purpose=strtrim(arr2str(ssw_strsplit(dat(pss),'PURPOSE',/tail),' '),2)
      endif else purpose='N.A.'
   endif
   outline=arr2str([files(i),instr(i), purpose, category],delimiter)
   print,outline
   file_append,omap,outline
endfor

box_message,['Finished, renaming:', $
   omap + ' -> ',fmap]

cpcmd=['cp','-f',omap,fmap]
spawn,cpcmd,/noshell


return
end
