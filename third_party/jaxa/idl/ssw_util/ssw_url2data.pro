pro ssw_url2data, urls, index, data, outdir=outdir, tempdir=tempdir, $
      noread=noread,  local_names=local_names, nodelete=nodelete
;+
;   Name: ssw_url2data
;
;   Purpose: copy ftp or http files->local; optionally read
;
;   Input Parameters:
;      urls - one or more URLs to collect (http://.., ftp://..., /local...)
;   
;   Output Paramters:
;      index, data - optional 'index,data' outputo;
;   
;   Keyword Parameters"
;      outdir & tempdir (synonyms) - output for local files
;
;   History:
;      24-Sep-2001 - S.L.Freeland - inteface to http/ftp/local gets
;      Circa 1-jan-2003 - replace url_get with DMZarro sock_copy call
;
;-

if n_params() eq 0 then begin 
   box_message,['Need at least one URL input', $
                'IDL> ssw_url2data, urls [,index,data] [,local_files=local_files]']
   return
endif

noread=keyword_set(noread) or n_params() lt 2
loud=1-keyword_set(quiet)

break_url, urls, server, paths, files, ftp=ftp, http=http

; files -> local
case 1 of 
   data_chk(tempdir,/string): tdir=tempdir
   data_chk(outdir,/string):  tdir=outdir
   else: tdir=get_temp_dir()
endcase

chkloc=file_exist(urls)
local_names=concat_dir(tdir,files)

for i=0,n_elements(urls)-1 do begin 
   if loud then box_message,'Getting> ' + urls(i)
   case 1 of
      file_exist(local_names(i)):                                   ; local
      ftp(i): smart_ftp, server(i), files(i), paths(i),out_dir=tdir  ; ftp 
      http(i):  sock_copy,urls(i),out_dir=tdir                            ; http      
      else: local_names(i)=urls(i)                      ; local URL?
   endcase
endfor
fexist=file_exist(local_names)
ssexist=where(fexist,ecnt)
ssnoexist=where(1-fexist,noecnt)

if ecnt gt 0 then begin
   if not noread then ssw_read_xxx,local_names(ssexist), index, data
endif else begin 
   box_message,'None of requrested URLS/FILES was transfered succesfully'
endelse

return
end


