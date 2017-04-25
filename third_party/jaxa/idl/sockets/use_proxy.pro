;+
; Project     : VSO
;
; Name        : USE_PROXY
;
; Purpose     : Check if server is in $no_proxy domains
;
; Category    : utility system sockets
;
; Inputs      : SERVER = server to check
;
; Outputs     : 1 = to use proxy, 0 to skip
;
; History     : 30-January-2013, Zarro (ADNET) - Written
;-

function use_proxy,server,verbose=verbose

if ~have_proxy() then return,0b
if is_blank(server) then return,1b

no_proxy1=getenv('no_proxy')
no_proxy2=getenv('NO_PROXY')
if is_string(no_proxy1) then no_proxy=no_proxy1 else $
 if is_string(no_proxy2) then no_proxy=no_proxy2

if is_blank(no_proxy) then return,1b

no_proxy=str_replace(no_proxy,'*','')
domains=str2arr(no_proxy,delim=',')
np=n_elements(domains)
for i=0,np-1 do begin
 domain=str_replace(domains[i],'.','\.')
 if stregex(server,domain,/bool) then begin
  if keyword_set(verbose) then message,'bypassing proxy server for '+server,/info
  return,0b
 endif
endfor
return,1b

end
