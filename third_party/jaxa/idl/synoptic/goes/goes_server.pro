;+
; Project     : HESSI
;
; Name        : GOES_SERVER
;
; Purpose     : return available Yohkoh or SDAC GOES data server
;
; Category    : synoptic sockets
;
; Inputs      : None
;
; Outputs     : SERVER = Yohkoh GOES data server name
;
; Keywords    : NETWORK = returns 1 if network to that server is up
;               PATH = path to data
;               SDAC = return SDAC server
;
; History     : Written 15-Nov-2006, Zarro (ADNET/GSFC) 
;               Modified 22-Feb-2012, Zarro (ADNET)
;               - made /FULL the default
;               14-Dec-2012, Zarro (ADNET)
;               - removed redundant call to HAVE_NETWORK
;               - switched primary Yohkoh server to faster sohowww
;               - merged Yohkoh and SDAC search logic
;               26-Dec-2012, Zarro (ADNET)
;               - Added NETWORK=0 message 
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function goes_server,_ref_extra=extra, path=path,network=network,sdac=sdac,verbose=verbose

if keyword_set(sdac) then begin
 primary='umbra.nascom.nasa.gov'
 secondary='hesperia.gsfc.nasa.gov'
 primary_path='/goes/fits'
 secondary_path='/goes'
endif else begin
 primary='sohowww.nascom.nasa.gov'
 secondary='umbra.nascom.nasa.gov'
 primary_path='/sdb/yohkoh/ys_dbase'
 secondary_path=primary_path
endelse

;-- primary server

server=primary
path=primary_path
url=server+path
network=have_network(url,_extra=extra,verbose=verbose,/use_network)

 ;-- if primary server is down, try secondary

if ~network then begin
 server2=secondary
 network=have_network(server2,_extra=extra,verbose=verbose,/use_network)
 if network then begin
  server=server2
  path=secondary_path
 endif
endif

if keyword_set(verbose) and ~network then $
 message,'Network connection currently unavailable. Will use latest cached lightcurves.',/info

return,'http://'+server

end
