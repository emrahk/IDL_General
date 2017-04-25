;+
; Project     : HESSI
;                  
; Name        : HAVE_NETWORK
;               
; Purpose     : check if network connection is available
;                             
; Category    : system utility sockets
;               
; Syntax      : IDL> a=have_network()
;
; Optional    : URL = URL to test [def eq 'www.google.com']
; Inputs      :
;                                        
; Outputs     : 1/0 if yes/no
;
; Keywords    : INTERVAL = seconds between rechecking
;                          (otherwise use result of last check) 
;               RESET = set to force check without waiting INTERVAL
;               (same as INTERVAL=0)
;               USE_NETWORK = set to use IDL network object
;                   
; History     : 8 Mar 2002, Zarro (L-3Com/GSFC)
;               22 Apr 2005, Zarro (L-3Com/GSFC) - return error message
;               when network is down.
;               1 Dec 2005, Zarro (L-3Com/GSFC) - removed http object
;               from common because of unwanted side effects.
;               13 Jan 2007, Zarro (ADNET/GSFC) - added support for
;               checking multiple urls
;               18 Feb 2012, Zarro (ADNET/GSFC) 
;               - passed connect_timeout=15 to HTTP object to return
;                 if host is down
;               20 Feb 2012, Zarro (ADNET) 
;               -use sock_response for proxy URL's
;               25 Mar 2012, Zarro (ADNET)
;               - added check for URL redirects
;               25-Dec-2012, Zarro (ADNET)
;               - added USE_NETWORK
;               12-Nov-2013, Zarro (ADNET)
;               - made USE_NETWORK the default
;               1-Jan-2014, Zarro (ADNET)
;               - added support for arbitrary ports
;               13-Oct-14, Zarro (ADNET)
;               - check for more error codes
;               3-Nov-14, Zarro (ADNET)
;               - relaxed error code checks
;
; Contact     : dzarro@solar.stanford.edu
;-    

function have_network,url,verbose=verbose,err=err,_extra=extra,$
         interval=interval,reset=reset,use_network=use_network,code=code

common have_network,urls

err=''
reset=keyword_set(reset)
verbose=keyword_set(verbose)

if reset then delvarx,urls
if is_string(url) then test_url=strtrim(url,2) else test_url='www.google.com'
purl=url_parse(test_url)
test_host=purl.host
test_port=purl.port
if is_blank(test_port) then test_port='80'
test_url=test_host+':'+test_port

if ~is_number(interval) then interval=30.
now=systime(/seconds)

;-- check if this url was checked recently

count=0
if is_struct(urls) then begin
 chk=where(test_url eq urls.url,count)
 j=chk[0]
 if count eq 1 then begin
  state=urls[j].state
  time=urls[j].time
  err=urls[j].err
  code=urls[j].code

;-- return last state if last time less than interval

  if (now-time) lt interval then begin
   if ~state then begin
    if verbose and is_string(err) then message,err,/info
   endif
   return,state
  endif
 endif
endif

;-- try to connect to url

state=0b
hfunct='sock_response'

if since_version('6.4') then begin
 if have_proxy() or keyword_set(use_network) then hfunct='sock_head'
endif

chk=call_function(hfunct,test_url,_extra=extra,err=err,/host_only,code=code,location=location)
state=code ne 404

;-- if location is returned in header, then most likely a redirect

if is_string(location) then state=1b

;-- update this url

if count eq 1 then begin
 urls[j].state=state
 urls[j].time=systime(/seconds)
 urls[j].err=err
 urls[j].code=code
endif else begin
 now=systime(/seconds)
 new_url={url:test_url,state:state,time:now,err:err,code:code}
 urls=merge_struct(urls,new_url)
endelse

return,state

end
