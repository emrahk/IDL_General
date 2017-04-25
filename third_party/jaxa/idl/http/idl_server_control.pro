function idl_server_control, pid=pid, running=running, kill=kill, $
     restart=restart, start_command=start_command, $
     testing=testing, debug=debug, commands=commands
;+
;   Name: idl_server_control
;
;   Purpose: operate on an IDL server (kill, restart, commmand..)
;
;   Input Parameters:
;      NONE:
;
;   Output:
;      function returns success status
;
;   Keyword Parameters:
;      pid (OUTPUT) - process IDS of server jobs (-1 if none running)
;      running (switch) - if set, return run status (true if server running)
;      kill (switch) - if set, kill server jobs
;      restart (switch) - if set, restart server (implies KILL first)
;      start_command - optional server start script -
;          default uses SSW priority order = [machine->site->gen]
;      testing - (switch) - if set, show what would happen (but dont do it)
;      commands - optional command(s) to send to server.
;                 if switch, use $SSW/site/setup/start_server.command (file)
;
;   Calling Sequence:
;      IDL> status=idl_server_control( [/kill] [/restart] [pid=pid] , $
;                                      [commands=commands]
;-
;
kill = keyword_set(kill) or keyword_set(restart)
restart = keyword_set(restart) or keyword_set(start_command)
debug = keyword_set(debug)
testing=keyword_set(testing)

; ----------------- find the idl/www server job info ----------
pid=-1

case 1 of 
   is_member(!version.os,'OSF,IRIX',/ignore_case): begin 
      spawn,['ps','-u',get_user()],psout,/noshell      
      sserv=where( (strpos(psout,'ssw_idl_server') ne -1) or $
                   (strpos(psout,'idlrpc') ne -1)         or $
                   (strpos(psout,'CAF') ne -1),     sscnt)
      if debug then stop,'psout check'  
      if sscnt gt 0 then begin 
         cols=str2cols(psout(sserv),/un,/trim)
         strtab2vect,cols,pid
         user=replicate(get_user(),n_elements(pid))
      endif
   endcase
   else: begin
      box_message,'This OS/Arch not yet handled...'
      return,-1
   endcase   
endcase   

; --------------------------------------------------------
status=pid(0) ne -1

; -------------- handle killing ---------------------------
if kill then begin 
   if pid(0) eq -1 then box_message,'No idl/www server running' else begin 
      for i=0,n_elements(pid)-1 do begin 
         box_message,['Killing Process ' , psout(sserv(i))]
         killcmd='kill -9 ' + pid(i)
         if testing then box_message,'TEST KILLCMD> ' + killcmd else begin
            box_message,'Issuing kill command ' + killcmd
            spawn,str2arr(killcmd,' '),/noshell         
            wait,1
         endelse
      endfor
   endelse
endif

; -----------------------------------------------------------

; -------- handle start/restart ----------------------------
if not data_chk(start_command,/string) then start_command=''
defstart='start_idlserver_'+strtrim(fix(!version.release),2)
sitestart=concat_dir('$SSW_SITE_SETUP',defstart)
genstart=concat_dir('$SSW_BIN',defstart)
perstart=sitestart+'_'+get_host(/short)

sorder=[start_command,perstart,sitestart,genstart] 
sexist=(where(file_exist(sorder),ecnt))(0)         ; first existing

if restart then begin 
   if ecnt eq 0 then begin
       box_message,'No valid start command' 
       status=0
   endif else begin 
      rstcmd='csh '+sorder(sexist)
      if testing then begin 
         box_message,['TEST Restart Command: ' ,rstcmd ]
      endif else begin 
         box_message,['Issuing Restart Command: ' , rstcmd]
         spawn,str2arr(rstcmd,' '),/noshell
         box_message,'Waiting 20 seconds for startup...'
         wait,20
      endelse
   endelse 
endif
; ----------------------------------------------------------


; ------------- optionally send command(s) to the server ----------
if keyword_set(commands)then begin 
   if idl_server_control() then begin 
      case 1 of 
         data_chk(commands,/string): scommands=commands
         else: begin 
            startcommand=concat_dir('$SSW_SITE_SETUP','start_server.command')
            if file_exist(startcommand) then $
               scommands=rd_tfile(startcommand,nocom=';') else $
                  box_message,['Cannnot find server command file: ',startcommand]
         endcase
      endcase
      for i=0,n_elements(scommands)-1 do begin
         cmd=scommands(i)
         if testing then box_message,'TEST command: ' + cmd else begin
            box_message,['Sending IDL command to server:',cmd] 
            idl_server_command,cmd
         endelse
      endfor
   endif else box_message,'Bad server status, cannot command'
   status=n_elements(scommands) gt 0
endif
; -------------------------------------------------------------------

return, status
end



