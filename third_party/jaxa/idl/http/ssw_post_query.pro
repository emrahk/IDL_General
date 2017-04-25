pro ssw_post_query, posturl, query_string, $
     status=status, socket_error=socket_error, get=get, lun=lun
;+
;   Name: ssw_post_query
;
;   Purpose: send a POST (or GET) query string to taget URL
;   
;   Input Parameters:
;      posturl - desired URL to recive POST (cgi for example)
;      client_string - desired POST or GET query, assumed URL-encoded
;   
;   Keyword Paramters:
;      status - true (=1) if no errors
;      socket_error -  verbatim output from socket ERR keyword
;      get - if set, use GET query (default=POST) 
;      noclose - if set, don't close connection
;      uselun  - if set and LUN is input and OPEN, use that lun
;      lun (output) - socket LUN used on most 
;
;   History:
;      23-Oct-2001 - S.L.Freeland  - to play with some peer-to-peer
;                                    between SSW servers
;       5-jun-2002 - S.L.Freeland - append 'http 1.0'
;      26-jun-2002 - S.L.Freeland - append proper terminator
;
;   Calling Examples:
;      ssw_post_query,'http://xxx/cgi-bin/ssw_service.sh','p1=1&p2=2'
;      ssw_post_query,'http://xxx/cgi-bin/ssw_service.sh?p1=1&p2=2'   ; same
;
;   Restrictions:
;      Uses RSI 'socket' routine so requires version >=5.4
;      query_string assumed url-encoded; will remove this
;                   when 'url_encode.pro' is written for SSW
;      NOTE: only /GET conforms to HTTP 1.1 standard as of today.
;            POST standard to be added after a few more tests...
;-

status=0
closeit=1-keyword_set(noclose)

if not since_version('5.4') then begin 
   box_message,'Need at least IDL version 5.4'
   return
endif

if not data_chk(posturl,/string) then begin 
   box_message,'Need URL for query target
   return
endif    

if n_params() eq 1 and strpos(posturl,'?') ne -1 then $       ; combined? 
   posturl=ssw_strsplit(posturl,'?',/head,tail=query_string) 

; 
break_url, posturl , servers, paths, files, http=http
if not http(0) then begin 
  servers=ssw_strsplit(posturl,'/',/head,tail=target)
endif else begin 
   target=paths+files
endelse

qtype=(['POST','GET'])(keyword_set(get))

openit=(1-keyword_set(uselun)) and (1-is_open(lun))

socket_err=0
if openit then socket,lun,/get_lun,servers,80, err=socket_err

query=qtype + ' /' + target

if data_chk(query_string,/string) then $
   query=query+ '?' + str_replace(query_string,'?','')

query=query + ' HTTP/1.0 '

terminator=string(byte([13,10,13,10])) 
if socket_err eq 0 then begin 
   printf, lun , query + terminator     ; send query to socket
   if closeit then free_lun,lun         ; close connection  
endif

return
end


