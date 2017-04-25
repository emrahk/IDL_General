;+
; Project     : VSO
;
; Name        : SOCK_PROXY
;
; Purpose     : Parse $http_proxy for proxy keywords and return them
;               in a structure that can be passed to IDLnetURL objects.
;               NB: keywords passed will override $http_proxy. 
;
; Category    : utility system sockets
;
; Syntax      : IDL> keywords=sock_proxy(url)
;
; Inputs      : URL (optional) = URL, if entered will be checked against $no_proxy
;
; Outputs     : keywords={proxy_hostname:proxy hostname,
;                         proxy_port:proxy_port,
;                         proxy_username = proxy username,
;                         proxy_password =proxy password}
;
; Keywords    : proxy_hostname= proxy hostname
;               proxy_port = proxy_port
;               proxy_username = proxy username
;               proxy_password =proxy password
;               no_proxy= bypass proxy
;
; History     : 20-August-2011, Zarro (ADNET) - Written
;               28-September-2011, Zarro (ADNET) - Added /NO_PROXY
;
;-

function sock_proxy,url,proxy_hostname=proxy_hostname,proxy_port=proxy_port,$
               proxy_username=proxy_username,proxy_password=proxy_password,$
               verbose=verbose,_extra=extra,no_proxy=no_proxy

verbose=keyword_set(verbose)

;-- create output structure keyword

dummy={dummy:0}

if keyword_set(no_proxy) then return,is_struct(extra)? extra:dummy
if is_struct(extra) then keywords=extra
if is_string(proxy_hostname) then keywords=add_tag(keywords,proxy_hostname,'proxy_hostname')
if is_number(proxy_port) then keywords=add_tag(keywords,trim(proxy_port),'proxy_port')
if is_string(proxy_username) then keywords=add_tag(keywords,proxy_username,'proxy_username')
if is_string(proxy_password) then keywords=add_tag(keywords,proxy_password,'proxy_password')

if is_blank(proxy_hostname) then begin 

;-- check if $http_proxy environment variable defined

 proxy1=getenv('http_proxy')
 proxy2=getenv('HTTP_PROXY')
 if is_string(proxy2) then proxy=proxy2 else if is_string(proxy1) then proxy=proxy1

;-- bail if not defined
 
 if is_blank(proxy) then return,is_struct(extra)? extra:dummy

 ptc=url_parse(proxy)
 if is_string(ptc.host) then begin
  proxy_hostname=ptc.host
  if is_string(ptc.username) then proxy_username=ptc.username
  if is_string(ptc.password) then proxy_password=ptc.password
  if is_string(ptc.port) then proxy_port=ptc.port
 endif
endif 

;-- check if $no_proxy matches URL

no_proxy=getenv('no_proxy')
if is_string(no_proxy) and is_string(url) then begin
 if strpos(url,no_proxy) gt -1 then return,is_struct(extra)? extra:dummy
endif

if is_string(proxy_hostname) then begin
 if ~exist(proxy_port) then proxy_port='80'
 proxy_port=strtrim(proxy_port,2)
 if verbose then message,'Using proxy server '+proxy_hostname+':'+proxy_port,/info
 keywords=rep_tag_value(keywords,proxy_hostname,'proxy_hostname')
 if is_number(proxy_port) then keywords=rep_tag_value(keywords,trim(proxy_port),'proxy_port')
 if is_string(proxy_username) then keywords=rep_tag_value(keywords,proxy_username,'proxy_username')
 if is_string(proxy_password) then keywords=rep_tag_value(keywords,proxy_password,'proxy_password')
endif else keywords=is_struct(extra)? extra:dummy

return,keywords & end
