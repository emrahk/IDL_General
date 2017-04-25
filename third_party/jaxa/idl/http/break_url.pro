pro break_url, urls, servers, paths, files, ftp=ftp, http=http
;
; Name: break_url
;
; Purpose: break url(s) into informational components
;
; Input Parameter:
;   url (ftp://.. , http://...) - vector OK
;
; Output Parameters:
;   servers - ip of server / www host (null if local file name)
;   paths   -  path 
;   files   - file name
;
; Keyword Parameters:
;   ftp - true if its an ftp url
;   http - true if its an http:///
;
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;-
service=ssw_strsplit(urls,'://',/head,tail=tail)
ftp=service eq 'ftp'
http=service eq 'http'

servers=ssw_strsplit(tail,'/',/head,tail=path)
break_file,path,ll,paths,files,exts,vers

files=files+exts+vers

if n_elements(ftp) eq 1 then begin 
   ftp=ftp(0)
   http=http(0)
   paths=paths(0)
   files=files(0)
   servers=servers(0)

endif

return
end
 
