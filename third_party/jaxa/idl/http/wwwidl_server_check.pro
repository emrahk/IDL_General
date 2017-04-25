function wwwidl_server_check, serverip, host, loud=loud, debug=debug, $
				restart=restart, force_restart=force_restart, $
			        server_start=server_start
;+
;   Name: wwwidl_server_check
;
;   Purpose: perform watchdog check an idlwww server - restart on error
;
;   Input Parameters:
;      server ip - IP of rpc server (default is current host)
;      host - hostname (def=current host)
;      loud - if set, be verbose
;      restart - if set, restart server on watchdog failure
;      force_restart - restart independent of watchdog status
;      server_start - optional server start script (CSH assumed) 
;                     [default uses ssw "standard" scripts]
;  
;   History:
;      7-May-1999 - S.L.Freeland - from trace_wwwidl_watchdog - "generic"
;
;   Calls:
;        wwwidl_watchdog, ssw_bin, RPC client(idlRpcClient)
;        rd_tfile, concat_dir, get_host, file_append, box_message
;
;   Method:
;      perform a watchdog test on RPC server (write/readback) via RPC client
;      Optionally restart the server
;  
;-
loud=keyword_set(loud)
force_restart=keyword_set(force_restart)                ; restart even if "ok"
debug=keyword_set(debug)

if n_elements(rpcid) eq 0 then rpcid='0X2010CAFE'       ; default RSI name
if n_elements(serverip) eq 0 then serverip=get_host()     
if n_elements(host) eq 0 then host=get_host(/short)

rpcclient=ssw_bin('idlRpcClient',found=found)           ; RPC commander online?

if not found then begin
  box_message,'Cannot find IDL RPC client in SSW tree, returning...'
  return, 0
endif  

info=wwwidl_watchdog(file, value)       ; get   "expected" values
count_file=file+'.counter'

if not file_exist(count_file) then $
    file_append,count_file,long(str2arr('0,0')),/new

; ------ the UPDATED command is via RPC -> WWWIDL SERVER ----
rpccmd='status=wwwidl_watchdog(/update,"'+file+'","'+ value+'")'
cmd=[rpcclient,rpcid,serverip,rpccmd]
box_message,['Spawing command...',cmd(0:2),'status=wwwidl_watchdog(/update)']
spawn,cmd,/noshell,output
if output(0) ne '' then box_message,['Output from spawn',output]
; --------------------------------------------------

; ------- check locally to see if the server did the correct thing
retval=wwwidl_watchdog(file,value,/check)
counter=long(rd_tfile(count_file,nocomment=';'))

status=(['FAILED','PASSED'])(retval)
counter(retval)=counter(retval)+1
mess=['Watchdog Test ' + status + ' by Sever ' + host, value]  

mess=[mess,'Failures: '   + strtrim(counter(0),2) + '  ' + $
            'Successes: ' + strtrim(counter(1),2)]

if loud then box_message,mess
                          
file_append,count_file,['; ' + mess,strtrim(counter,2)],/new

if (keyword_set(restart) and (1-retval)) or force_restart then begin
   box_message,'Failure  - Initiating restart...'
   cmd=[rpcclient,rpcid,serverip,'retall']
   mess0=['Spawing command...',cmd]
   box_message,mess0
   spawn,cmd,/noshell,output
   if not wwwidl_server_check(/loud) then begin
      mess1='RETALL recovery did not work, restarting server...'
      box_message,mess1
      if not data_chk(server_start,/string) then begin
         sswscript='start_idlserver_5'
	 server_start=[concat_dir('$SSW_SITE_SETUP',sswscript + '_' + host), $
                    concat_dir('$SSW_SITE_SETUP',sswscript),                $
		    concat_dir('$SSW_GEN_SETUP',sswscript) ]
      endif
      ss=where(file_exist(server_start),sscnt)
      if sscnt gt 0 then begin      
         cmd=['csh','-f',server_start(ss(0))]
         spawn,cmd,/noshell                 
         mess1=[mess1,'Restart command issued: ' + arr2str(cmd,' ')]
      endif else mess1=[mess1,'Could not find start command(s):',server_start]
   endif else mess1='RETALL recovery worked'
   mail,[mess0,mess1],user='freeland@penumbra.nascom.nasa.gov', $
	 subj='wwwidl_server_check', /no_defsub
endif

if debug then stop

return, retval
end
