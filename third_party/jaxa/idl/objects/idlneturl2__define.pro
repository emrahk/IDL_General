;+
; Project     : VSO
;
; Name        : IDLNETURL2__DEFINE
;
; Purpose     : Wrapper around IDLnetURL class to override SETPROPERTY
;               method to permit updating HEADERS. 
;               Also checks for HTTP_PROXY and USER_AGENT environment variables
;
; Category    : Objects, Sockets
;
; Syntax      : IDL> o=obj_new('idlneturl2')
;
; Inputs      : URL = optional URL
;
; Outputs     : O = IDL network object
;
; Keywords    : USER_AGENT = user-agent string passed to SETPROPERTY
;               PASSIVE = set for PASSIVE FTP [currently def]
;               DEBUG = set for debug output 
;               USERNAME/PASSWORD = if server (e.g. FTP) requires it
;               [def=anonymous login]
;
; History     : 14-July-2012, Zarro (ADNET) - Written
;               20-November-2013, Zarro (ADNET) 
;               - Added support for additional header keywords
;               28-September-2014, Zarro (ADNET)
;               - added default IDL User-Agent
;               10-February-2015, Zarro (ADNET)
;               - added PASSIVE and DEBUG keywords
;               20-February-2015, Zarro (ADNET)
;               - added NO_PROXY
;               15-March-2015, Zarro (ADNET)
;               - and NO-CACHE header
;               25-March-2015, Zarro (ADNET)
;               - added KEEP-ALIVE keyword
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function idlneturl2::init,url,_extra=extra,debug=debug,$
                     no_proxy=no_proxy,verbose=verbose


ok=self->idlneturl::init()
if ~ok then return,0

;-- check if URL entered as optional argument
;-- trick to pass URL properties to object so as not to expose
;   passwords

if is_url(url) then begin
 stc=url_parse(url)
 tags='URL_'+tag_names(stc)
 for i=0,n_elements(tags)-1 do begin
  if is_blank(stc.(i)) then continue
  if i eq 0 then stash=create_struct(tags[i],stc.(i)) else $
   stash=create_struct(stash,tags[i],stc.(i))
 endfor
 self->setproperty,_extra=stash
endif


;-- add default USER_AGENT field as some servers require it

chk1=getenv('user_agent') 
chk2=getenv('USER_AGENT')
if is_string(chk1) then user_agent=chk1 else if is_string(chk2) then user_agent=chk2
if is_blank(user_agent) then user_agent=sock_idl_agent()
self->setproperty,user_agent=user_agent

;-- add default HOST field as some servers require it

self->getproperty,url_hostname=server,url_port=port
if is_string(server) && is_number(port) then begin
 header='Host: '+server+':'+port
 self->setproperty,headers=header
endif

;-- check for PROXY

proxy1=getenv('http_proxy')
proxy2=getenv('HTTP_PROXY')
if is_string(proxy2) then proxy=proxy2 else if is_string(proxy1) then proxy=proxy1
if is_string(proxy) then begin
 if ~stregex(proxy,'^http',/bool) then proxy='http://'+proxy
 ptc=url_parse(proxy)
 if is_string(ptc.host) then begin
  proxy_hostname=ptc.host
  if is_string(ptc.username) then proxy_username=ptc.username
  if is_string(ptc.password) then proxy_password=ptc.password
  if is_number(ptc.port) then proxy_port=ptc.port
 endif
 self->setproperty,proxy_hostname=proxy_hostname,proxy_port=proxy_port,$
      proxy_username=proxy_username,proxy_password=proxy_password
;      headers='Pragma: no-cache'
endif

;-- check for NO_PROXY

if ~use_proxy(server,verbose=verbose) || keyword_set(no_proxy) then begin
 self->setproperty,proxy_hostname='',proxy_port='',headers='Cache-Control: no-cache'
endif

;-- check for anonymous FTP and default to passive 

if is_ftp(url) then begin
 self->getproperty,url_username=url_username
 if is_blank(url_username) || url_username eq 'anonymous' then $
  self->setproperty,url_username='anonymous',url_password='nobody@home.com'
 self->setproperty,ftp_connection_mode=0
endif

self->setproperty,headers='Connection: close'

self->setproperty,_extra=extra,verbose=verbose

if keyword_set(debug) then sock_debug,self

return,ok

end

;-------------------------------------------------------------------------------
pro idlneturl2::setproperty,_extra=extra,info=info,$
      user_agent=user_agent,xml=xml,range=range,keep_alive=keep_alive,$
      passive=passive,username=username,password=password,port=port

self->idlneturl::setproperty,_extra=extra

;-- insert extra keywords into HEADERS keyword

;-- avoid duplicate headers

self->getproperty,headers=headers

if is_string(user_agent,/blank) then begin
 chk=where(stregex(headers,'User-Agent',/bool,/fold),count)
 if is_blank(user_agent) then sagent='' else $
  sagent='User-Agent: '+strtrim(user_agent,2)
 if count eq 0 then headers=[headers,sagent] else headers[chk[0]]=sagent
endif

np=n_elements(range)
if (np eq 1) || (np eq 2) then begin
 if is_string(range) then range_request='Range: bytes='+strtrim(range,2) else begin
  if np eq 1 then begin
   if range[0] ge 0 then suffix='-' else suffix=''
   range_request='Range: bytes='+strtrim(range[0],2)+suffix
  endif
  if np eq 2 then range_request='Range: bytes='+strtrim(range[0],2)+'-'+strtrim(range[1],2)
 endelse
 chk=where(stregex(headers,'Range: bytes',/bool,/fold),count)
 if count eq 0 then headers=[headers,range_request] else headers[chk[0]]=range_request
endif

if is_string(info) then headers=[headers,strarrcompress(info)] 

if keyword_set(xml) then begin
 xml_header='Content-type: text/xml'
 chk=where(stregex(headers,xml_header,/bool,/fold),count)
 if count eq 0 then headers=[headers,xml_header] 
endif

if is_number(port) then begin
 self->idlneturl::setproperty,url_port=port
 self->idlneturl::getproperty,url_host=server
 chk=where(stregex(headers,'^Host:',/bool),count)
 if count gt 0 then headers[chk[0]]='Host: '+server+':'+trim(port) 
endif

if keyword_set(keep_alive) then begin
 chk=where(stregex(headers,'Connection: close',/bool,/fold),count)
 persistent='Connection: Keep-Alive'
 if count gt 0 then headers[chk[0]]=persistent else headers=[headers,persistent]
endif

;-- remove duplicate or blank headers

if is_string(headers) then begin
 self->idlneturl::setproperty,headers=''
 for i=0,n_elements(headers)-1 do begin
  if is_string(headers[i]) then begin
   if is_blank(nhead) then nhead=headers[i] else begin
    chk=where(headers[i] eq nhead,count)
    if count eq 0 then nhead=[nhead,headers[i]]
   endelse
  endif
 endfor
 if is_string(nhead) then self->idlneturl::setproperty,headers=nhead
endif

;-- check for user override with keywords

if is_string(username,/blank) then self->idlneturl::setproperty,url_username=username
if is_string(password,/blank) then self->idlneturl::setproperty,url_password=password
if is_number(passive) then self->idlneturl::setproperty,ftp_connection_mode=1-passive

return & end

;-----------------------------------------------
pro idlneturl2__define

temp={idlneturl2, inherits idlneturl}

return & end
