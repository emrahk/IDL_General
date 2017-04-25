function http_names, names, file2link=file2link, link2file=link2file, $
		     relative=relative
;+
;   Name: http_names
;
;   Purpose: convert filename to WWW link
;
;   Input Parameters:
;      names - filename or wwwlink name
;
;   Keyword Paramters:
;      file2link - input filename changed to WWW link
;      link2file - input WWW link changed to file name
;      relative - if set, URLs are relative, not absolute 
;  
;   Calling Sequence:
;      pathname=http_names(linkname [/link2file] )
;      linkname=http_names(pathname [/file2link] )
;
;   Restrictions:
;      environmentals 'path_http' and 'top_http' are defined
;
;   History:
;      18-Jun-1996 S.L.Freeland
;-
;

top=(get_logenv('top_http'))(0)
path=(get_logenv('path_http'))(0)

retval=''					; default

if keyword_set(relative) and data_chk(names,/string) then begin
   break_file,names,ll,pp,ff,ee,vv
   return,ff+ee+vv
endif  

if top eq '' or path eq '' then begin
   message,/info,"Need to define environmental/logicals " + $
                  "'top_http' and 'path_http'"
   return,retval
endif

if not data_chk(names,/string) then $
   message,/info,"IDL> httplink=htt_f2l(filename)" else begin
      inames=str_replace(names,'$path_http',path)		; log->string
      inames=str_replace(inames,'$top_http',top)		; log->string
      link2file=keyword_set(link2file) or strpos(inames(0),top) ne -1
      file2link=keyword_set(file2link) or (1-link2file)   
      reporder=(['top,path','path,top'])(file2link)		     ; selection
      exestr=execute('retval=str_replace(inames,' + reporder + ')')  ; execute
   endelse

return,retval
end

