;+
; Project     : HESSI
;
; Name        : SYNOP_SERVER
;
; Purpose     : return first available Synoptic data server
;
; Category    : synoptic sockets
;                   
; Inputs      : None
;
; Outputs     : SERVER = Synoptic data server name
;
; Keywords    : NETWORK = 1 if network is up
;               PATH = path to synoptic data
;               NO_CHECK = don't check network status
;               FULL_NAME = prepend 'http://'
;               SOHO = force SOHO server
;
; History     : 29-Dec-2001,  D.M. Zarro (EITI/GSFC) -written
;               20-Jan-2007, Zarro (ADNET/GSFC) - added achilles
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function synop_server,path=path,_ref_extra=extra,network=network,$
                           no_check=no_check,full_name=full_name,soho=soho


check=~keyword_set(no_check)
full_name=keyword_set(full_name)
network=0b

;-- list available servers and data paths

list_synop,servers,paths
index=indgen(n_elements(servers))

if keyword_set(soho) and (n_elements(index) gt 1) then begin
 index[0]=1 & index[1]=0
endif

;-- cycle thru connections

for i=0,n_elements(servers)-1 do begin
 k=index[i]
 path=paths[k]
 server=servers[k]
 if i gt 0 then message,'Trying '+server+'...',/cont
 if check then network=have_network(server,_extra=extra) else network=1b
 if network then break
endfor

if full_name then server='http://'+server
return,server
end
