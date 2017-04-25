pro ssw_install_explinkages, insets, outsets
;
;+
;   Name: ssw_install_explinkages
;
;   Purpose: expand SSW auto-linkages (PI team defined)
;
;   Input Parameters:
;      insets - list of one or more ssw instrument or branch elements
;
;   Output Parameters:
;      outsets - expanded list implied by insets  
;
;   Calling Examples:
;      IDL> ssw_install_explinkages, ['sxt','bcs','hessi'],outsets
;      IDL> ssw_intsall_explinkages,'sxt,bcs,hess',outsets         ; equiv
;  
;   History:
;      30-November-1999 - S.L.Freeland  
;
;   Method:
;      check INSETS for entries in $SSW/gen/setup/ssw_install.linkages  
;-

if not data_chk(insets,/string) then begin
   box_message,['Need input SSW instruments sets or branches',$
		'IDL> ssw_install_explinkages, insets, outsets']
   return
endif   
  
linkfile=concat_dir('SSW_GEN_SETUP','ssw_install.linkages')

outsets=''

if not file_exist(linkfile) then begin
   box_message,['Cannot find linkage file: ' + linkfile +', returing...']
   outsets=insets
   return
endif

isets=strtrim(strlowcase(insets),2)
if n_elements(isets) eq 1 then isets=str2arr(isets(0),/nomult)

dat=rd_tfile(linkfile,nocom='#',2)
strtab2vect,dat,xxx,links

for i=0,n_elements(isets)-1 do begin
   lsets=isets(i)
   ss=(where(isets(i) eq xxx,sscnt))(0)
   if sscnt gt 0 then lsets=[lsets,str2arr(links(ss),/nomult)]
   outsets=[outsets,lsets]
endfor

outsets=strarrcompress(outsets)
if n_elements(outsets) gt 1 then $
    outsets=outsets(uniq(outsets,sort(outsets)))

return
end
