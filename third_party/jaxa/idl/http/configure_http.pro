pro configure_http, path_http, top_http, $
		    _extra = _extra, reset=reset, local=local
;+
;   Name: configure_http
;
;   Purpose: configure an HTTP server within the SSW environment
;
;   Input Parameters:
;     path_http  - pathname for 'top  HTTP' (prompted if not supplied)
;     top_http  -  URL for 'top  HTTP'      (prompted if not supplied)
;   
;   Keyword_parameters:
;     imply relative to http parent 
;
;   Calling Sequence:
;       configure_http [path_http, top_http]
;  -OR- configure_http,/XXX   ; set path and url http => parent_http/XXX   
;  -OR- configure_http,/LOCAL ; use current directory 
;      
;   History:
;     2-jun-1997 -   S.L.Freeland (sxt/ypop/eit/trace...)
;     4-April-1998 - S.L.Freeland slightly more general (cdaw prep)
;    14-April-1998 - S.L.Freeland - add /LOCAL switch and function
;     
;   Motivation:
;      http utilities available under SSW use the enviromentals
;      $path_http and $top_http to generate WWW documents, etc.
;      For sites with only ONE parent http, those environmentals may
;      be set in $SSW/site/setup/setup.ssw_env  - this routine allows
;      multiple 'tops' at a site, interactive or batch job re-definitions   
;  
;-
common configure_http1, current_http
common configure_http2, top_http_orig, path_http_orig

; -------------- get current status ---------------------
top_http_cur=get_logenv('top_http')
path_http_cur=get_logenv('path_http')
; --------------------------------------------------------

; -------- store the original first time ------------
if n_elements(top_http_orig) eq 0 then begin 
   top_http_orig=path_http_cur
   path_http_orig=path_http_cur
endif 
; --------------------------------------------------------

if keyword_set(local) then begin
  box_message,'using current directory (use /RESET to restore original config)
  top_http='.'
  path_http=curdir()
endif  

if n_elements(path_http) eq 0 then path_http=path_http_cur
if n_elements(top_http) eq 0 then top_http=top_http_cur

if n_params() ge 2 then $
   top_http='http://'+ str_replace(top_http,'http://','')  ; allow with/without

; ------- restore originals on request ------------
reset=keyword_set(reset)
if reset then begin 
   top_http=top_http_orig
   path_http=path_http_orig
endif 
; --------------------------------------------------------

; --------- user may pass subdir as keyword ----------------
if data_chk(_extra,/struct) then begin
  rep=(tag_names(_extra))(0)
  testpaths=[concat_dir(path_http,rep), $
             concat_dir(path_http,strlowcase(rep) ), $
             str_replace(path_http,'/'+ path_http_cur,'/'+rep)]
  testtop=[concat_dir(top_http,rep), $
           concat_dir(top_http,strlowcase(rep)), $
           str_replace(top_http,'/'+ top_http,'/'+rep)]
  test=where(file_exist(testpaths),tcnt)
  if tcnt eq 0 then begin 
    box_message,'Could not locate requested path for http area'
    return
  endif else begin
    path_http=testpaths(test(0))
    top_http=testtop(test(0))    
  endelse
endif  
; --------------------------------------------------------

if path_http eq '' then read,"Enter parent PATHNAME for HTTP: ",path_http
if top_http  eq '' then read,"Enter URL of HTTP:    http://",top_http

set_logenv,'path_http',path_http
set_logenv,'top_http',top_http

return
end
