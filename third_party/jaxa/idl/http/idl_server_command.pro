pro idl_server_command, command, serverip, rpcid=rpcid, snapshot=snapshot
;+
;   Name: idl_server_command
;
;   Purpose: spawn an rpc command to an idl/www server
;
;   Input Parameters:
;      command - the IDL command to send to the server (default='help')
;      servip - IP of server (default is current machine)

;   Keyword Parameters:
;      rpcid - id of server (default '0X2010CAFE' per RSI default)
;      snapshot - if set, default command saves binary image of current 
;                 server routines
;                 in $SSW/site/seutp/data/idlwww.!version.release
;                 [used for binary server startups]
;
;   Calling Sequence:
;      IDL> idl_server_command,command [,serverIP] [,/snapshot] [rpcid=rpcid]
;
;   Calling Example:
;      IDL> idl_server_command,'retall'            ; send retall to this 
;      IDL> idl_server_command,'help','penumbra.nascom.nasa.gov' ; server on
;                                                                ; diff IP
;
;   History:
;      Circa Jan 1, 1999 - S.L.Freeland
;      3-August-2000 - S.L.Freeland - document, use 'ssw_bin' client if needbe
;-
case 1 of 
   data_chk(command,/string):
   keyword_set(snapshot): begin
     command="save,/routines,file='" + $
concat_dir(concat_dir('SSW_SITE_SETUP','data'),'idlwww.'+!version.release)+"'"      
   endcase
   else: command='help'       ; good and safe as any default...
endcase

client='idlRpcClient'                                     ; standard name
sswbin=ssw_bin(client,found=found)                        ; ssw version
if n_elements(rpcid) eq 0 then rpcid='0X2010CAFE'
if n_elements(cgidir) eq 0 then cgidir='/var/www/cgi-bin/'
if n_elements(serverip) eq 0 then serverip=get_host()     ; local
cgibin=concat_dir(cgidir,client)                   
case 1 of 
   file_exist(cgibin): rpccmd=cgibin               ; local cgi version
   found:              rpccmd=sswbin               ; sssw distributed version
   else: begin 
      box_message,'rpc client not found'
      return
   endcase
endcase   

cmd=[rpccmd, rpcid, serverip, command]
box_message,['Spawing command...',cmd]
spawn,cmd,/noshell,output
if output(0) ne '' then box_message,['Output from spawn',output]
return
end
