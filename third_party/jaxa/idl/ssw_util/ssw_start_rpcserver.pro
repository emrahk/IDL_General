pro ssw_start_rpcserver, cgidir=cgidir, serverid, _extra=_extra, $
   interactive=interactive, idl_dir=idl_dir, save_script=save_script, $
   wait_server=wait_server, no_execute=no_execute, $
   path_http=path_http, top_http=top_http, $
   new_idlstartup=new_idlstartup, idl_version=idl_version, idl_highest=idl_highest
;
;+
;   Name: ssw_start_rpcserver
;
;   Purpose: start an ssw-idl rpc server with desired ssw environment
;
;   Input Parameters:
;      serverid - desired rpc server id - default = 2010CAFE
;                 if supplied via string of length 4, then '2010'SERVERID is assumed
;
;   Keyword Parameters:
;      cgidir - path to desired cgi
;      interactive - if set, ask user for some parameters 
;      idl_dir - desired IDL_DIR for server (def=$IDL_DIR or /usr/local/rsi/idl)
;      idl_version - optionally supplied IDL V to use
;      idl_highest - switch - if set, use latest available idl version
;      save_script - if set, save the startup as a script in $SSW/site/setup/
;      _EXTRA - optional list of ssw instruments/packages to include in server environment
;               (default from current $SSW_INSTR list)
;     no_execute=no_execute - do not actually start the created script
;     save_script - if set, save the CSH script to $SSW/site/setup/
;                   filename='setup.<host>_server_<serverid>'
;     path_http - path (local NFS name) to top of desired WWW tree (default=$path_http)
;     top_http  - associated URL pointing to PATH_HTTP
;                 (note path_http and top_http are local vs remote WWW synonyms)
;     wait_server - time to wait between server startup/background and 1st client call (initialization) ; def=30
;
;   Calling Examples:
;      ssw_start_rpcserver, 'CAFA', idl_dir='/usr/local/rsi/idl80'
;      ssw_start_rpcserver,/interactive 
;      
;   Restrictions:
;      if cgidir is supplied (string or switch), user must have cgi-bin write access.
;      assumes idlRPC client exists for this OS/ARCH (in $SSW_PACKAGES/...)
;
;   History:
;      23-March-2005 - S.L.Freeland - simplify user setup of ssw/cosec servers
;       6-Apr-2005 - S.L.Freeland - inherit environement from caller process
;                    (via get_logenv/set_logenv in IDL_STARTUP)
;      14-Apr-2005 - S.L.Freeland - more control/options for server $IDL_DIR (version..)
;                    made the generated IDL init file run properly 
;      4-may-2005 - S.L.Freeland - add $SSW/gen/idl_libs to boot libraries
;     10-jan-2005 - S.L.Freeland - trap and define null environmentals expicitly->""
;      31-jan-2012 - S.L.Freeland - add WAIT_SERVER keyword & function 
;
;   Method:
;      Create implied startup script and launchit - also creates IDL startup
;      and environment script so server can inherit kickoff sswidl session env.
;
;-
runnit=1-keyword_set(no_execute)
if not data_chk(serverid,/string) then serverid='2010CAFE'  ; rsi/ssw default

server=(['','2010'])(strlen(serverid) eq 4)+serverid

user=get_user()
host=get_host(/short)

rpcclient=ssw_bin('idlRpcClient',found=found)

if not found then begin 
   box_message,'Sorry, only works for OS/ARCH with existing rpc client in SSW/packages/binaries..'
   return
endif
rpccl=ssw_strsplit(rpcclient,'/',/tail,/last,head=binpath)

; 
pr_status,status 
header=['#!/bin/csh -f','# ' + status]
scmds=header

osarch=get_infox(!version,'os,arch',del='_')
; make the script
;
; 1. search for existing and corresponding server and kill if present
case 1 of
   is_member(osarch,'darwin_ppc'): begin
      pscmd="ps -uww "+user+ " | grep idlrpc | grep "+serverid
      pidloc=2   ; unix CSH location of PID
   endcase
   else: begin ; need equivilent ps commands for other os/arch for auto-kill 
   endcase
endcase

if n_elements(pscmd) gt 0 then begin 
   scmds=[header,'set psrpc=`'+pscmd+'`',$
      'if ("$psrpc" != "") then', '   kill -9 $psrpc['+strtrim(pidloc,2)+']','endif' ] 
endif else box_message,'Do not yet know ps command for this OS yet for auto-kill (continuing..)


; setup server $SSW_INSTR
ssw=get_logenv('SSW')   ; local top of $SSW tree

if data_chk(_extra,/struct) then begin 
   box_message,'Assuming inherited keywords defined desired $SSW_INSTR list for server
   sint=strlowcase(arr2str(_extra,' '))
endif else sint=get_logenv('SSW_INSTR')  ; current user values
sint=strtrim(sint,2)
sswsetup=['setenv SSW ' + get_logenv('SSW'), $
          'setenv SSW_INSTR "' + sint + '"',        $
          'source '+ concat_dir(ssw,'gen/setup/setup.ssw') ]

;scmds=[scmds,sswsetup] 

eidldir=get_logenv('IDL_DIR')
rsiparent=['/usr/local/rsi','/Applications/rsi',str_replace(eidldir,'/idl','')]
rsiparent=rsiparent(uniq(rsiparent,sort(rsiparent)))
pexist=where(file_exist(rsiparent),ecnt)
if ecnt gt 0 then rsiparent=rsiparent(pexist)
allidldirs=file_list(rsiparent,['idl','idl_*'])

; allow a ridiculous level of user options/control re: which $IDL_DIR to use... 
case 1 of 
   data_chk(idl_dir,/string): idldir=idl_dir  ; explicit user supplied
   keyword_set(idl_highest): idldir=last_nelem(allidldirs) ; newest available
   data_chk(idl_version,/string): idldir=concat_dir(rsiparent(0),'idl_'+idl_version) 
   keyword_set(idl_version): idldir=concat_dir(rsiparent(0), $
      'idl_'+string(idl_version,format='(f3.1)'))
   eidldir ne '': idldir=eidldir ; else, use this sessions $IDL_DIR
   else:
endcase
if not file_exist(idldir) then begin 
   box_message,['Cannot find idl directory via:', $
                '$IDL_DIR, idldir keyword or usual rsi locations... exiting']
   return
endif else box_message,'Using IDL_DIR = ' + idldir

servid4=strmids(serverid,strlen(serverid)-4,4)
logfile=concat_dir('$SSW_SITE_LOGS',host+'_server_'+servid4+'.log')

idlrpc=concat_dir(idldir,'bin/idlrpc')  ; IDL RPC Server Executable

if not file_exist(idlrpc) then begin 
   box_message,['Cannot find IDLRPC server which matches desired IDL Version..', $
                'ie, cannot find: ' + idlrpc +  ' ..., returning']
   return
endif  
idlrpc=idlrpc+ ' -server='+server + ' > ' +logfile + ' &'

startname=strlowcase('ssw_server_init_'+host+'_'+servid4)
idlstart=(concat_dir('$SSW_SITE_SETUP',startname))(0) + '.pro'
unixenv=(concat_dir('$SSW_SITE_SETUP',startname))(0)  + '.env'


scmds=[scmds,'setenv IDL_DIR '+idldir(0)]
;scmds=[scmds,'setenv IDL_STARTUP ' + idlstart(0)]
scmds=[scmds,'setenv IDL_PATH ' + $                  ; set sswidl server
          '+'  + concat_dir('$SSW','site/idl') + $   ; bootup path
          ':+' + concat_dir('$SSW','gen/idl')  + $
          ':+' + concat_dir('$SSW','gen/idl_libs') + $
          ':'  + get_logenv('SSW_SITE_SETUP')  + $
          ':+' + concat_dir(idldir(0),'pro')   + $
          ':+' + concat_dir(idldir(0),'lib')     ]           
scmds=[scmds,idlrpc]

; generate IDL STARTUP for This server...
newstart=not file_exist(idlstart) or keyword_set(new_idlstartup)

if newstart then begin 
   envdef=get_logenv('*',env=env)
   ssnull=where(strtrim(envdef,2) eq '',ncnt)
   if ncnt gt 0 then envdef(ssnull) = '""' 
   file_append,unixenv,'setenv '+env+' ' + envdef,/new
   file_append,unixenv,['setenv ssw_nomore 1', $    ; inhibit tty&X communications
                        'setenv ssw_nox 1',    $    ; ( ssw_batch-like environ )
                        'setenv ssw_batch 1',  $    ; 
                        'setenv IDL_DIR ' + idldir] ; assure $IDL_DIR for server matches

   if data_chk(path_http,/string) then phttp=path_http else $
      phttp=get_logenv('path_http')
   if data_chk(top_http,/string) then thttp=top_http(0) else $
      thttp=get_logenv('top_http')
   pr_status,status,/idldoc,/caller
   status=[status,';','; IDLRPC Server Startup',$
           '; HOST: ' + host + ' SERVERID: ' + server]
   file_append,idlstart,'pro ' + startname,/new
   sswpath='ssw_path'+ arr2str(str2arr(' '+sint,' '),',/')
   file_append,idlstart,[status,sswpath]
   file_append,idlstart,"set_plot,'z'"
   file_append,idlstart,"set_logenv,file='"+unixenv+"'"
   file_append,idlstart,'set_logenv,"path_http","'+phttp+'"'
   file_append,idlstart,'set_logenv,"top_http","'+thttp+'"'
   file_append,idlstart,'end'

endif else box_message,'Not regenerating IDL startup for this server'

if data_chk(cgidir,/string) then cmddir=cgidir else cmddir=binpath
rpccmd='./idlRpcClient 0x'+server+' '+ host+ ' '
if n_elements(wait_server) eq 0 then wait_server=30
sleepsec='sleep ' + strtrim(wait_server)
scmds=[scmds,sleepsec,'cd ' + cmddir,rpccmd+startname]
cshscript=concat_dir('$SSW_SITE_SETUP','setup.'+host+'_'+server+'_' + servid4)
save_script=keyword_set(save_script) or (1-file_exist(cshscript))
if save_script then file_append,cshscript,scmds,/new
if runnit then spawn,'csh -f '+cshscript+ ' &',out
box_message,out
 

end;
