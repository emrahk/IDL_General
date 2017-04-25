;+
; Project     : VSO
;
; Name        : SOCK_CLIENT
;
; Purpose     : Start a socket client to connect to a socket_server
;               started by SOCK_SERVER
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_client,lun=lun,/start     
;               IDL> sock_sendvar,lun,'data',findgen(100) ;-- send data
;               IDL> data2=sock_getvar(lun,'data')        ;-- get data
;               IDL> sock_sendcmd,lun,'plot,data'         ;-- execute command
;               IDL> sock_client,/stop
;
; Inputs      : None
;
; Outputs     : None
;
; Keywords    : START_CLIENT = restart client (if stopped with /STOP_CLIENT).
;               STOP_CLIENT = stop client.
;               PORT = socket port to use (def = 21068).
;               VERBOSE = set for verbose output.
;               SERVER = remote server to connect to (def = localhost).
;               LUN = socket unit number opened by client
;               WAIT_TIME = time to wait for connection (def = 60)
;
; History     : 28 December 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_client_callback,id,userdata

tset=1
serverlun=userdata.serverlun
if ~is_socket(serverlun) then return

error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 goto,keep_listening
endif

status=File_Poll_Input(serverlun, Timeout = .01)
if status then begin
 sock_recvar,serverlun,name,value,err=err,session=session,disconnected=disconnected

 if stregex(name,'Exceeded|HTTP',/bool,/fold) then begin
  mprint,value
  sock_client,/stop
  return
 endif

 if is_blank(err) && exist(value) && is_string(name) then begin
;  help,err,name,value,session
  (SCOPE_VARFETCH(name, /enter, LEVEL=1)) = value
 endif
 if is_string(session) then (SCOPE_VARFETCH('session', /enter, LEVEL=1)) = session
endif

if is_string(err) && disconnected then begin
 mprint,'Server disconnected.'
 if is_string(value) then mprint,value
 close_lun,serverlun
 userdata.start_time=systim(/sec)
 !null=timer.set(tset,'sock_client',userdata)
 return
endif 

keep_listening: !null = Timer.Set(tset, 'sock_client_callback',userdata)
return & end

;---------------------------------------------------------------------------
pro sock_client,ID,userdata,server=server,port=port,verbose=verbose,$
                  stop_client=stop_client,start_client=start_client,lun=lun,$
                  wait_time=wait_time


lun=-1
if ~since_version('8.4') then begin
 mprint,'Needs IDL version 8.4 or better.'
 return
endif

!null=heap_refcount(/enable)

common sock_client,stop_listening

if keyword_set(start_client) then stop_listening=0b
if ~exist(stop_listening) then stop_listening=0b
if stop_listening then begin
 mprint,'Stopped. To restart type: IDL> sock_client,/start'
 return
endif

if keyword_set(stop_client) then begin
 stop_listening=1b
 if ~is_number(port) then begin
  ports=sock_ports(count=count)
  if count eq 0 then begin
   mprint,'Not running.'
   return
  endif
  port=ports[0]
 endif
 luns=sock_luns(port,count=count)
 if count eq 0 then begin
  mprint,'Not running on port '+trim(port)
  return
 endif
 close_lun,luns
 mprint,'Disconnecting on port '+trim(port)
 stop_listening=1b
 return
endif

if is_struct(userdata) then begin
 verbose=userdata.verbose
 port=userdata.port
 serverlun=userdata.serverlun
 server=userdata.server
 wait_time=userdata.wait_time
 start_time=userdata.start_time
endif else begin
 sock_def_server,server,port
 serverlun=(sock_luns(port))[0]
 lun=serverlun
 verbose=keyword_set(verbose)
 if ~is_number(wait_time) then wait_time=60.
 start_time=systim(/sec)
 userdata={serverlun:serverlun,server:server,port:port,verbose:verbose,$
           wait_time:wait_time,start_time:start_time}
endelse

plun=sock_luns(port,count=count,/listener)
if count gt 0 then begin
 mprint,'A server is already running on port '+trim(port)+'. Start client in different IDL session.'
 return
endif

if is_socket(serverlun) then begin
 mprint,'Connected on port '+trim(port)+' via unit '+trim(serverlun)
 return
endif

error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
; !null=timer.set(1,'sock_client',userdata)
 return
endif

socket, serverlun, server, port, /Get_LUN, $
 Connect_Timeout = 10., $
 Read_Timeout = 10., Write_Timeout = 10., /RawIO, $
    /Swap_If_Big_Endian,error=error

if error ne 0 then begin
 current_time=systim(/sec)
 if (wait_time gt 0) && (current_time-start_time gt wait_time) then begin
  mprint,'Server not connecting. Try again later.'
  sock_client,/stop
  return
 endif
 if verbose then mprint,'Waiting for server connection on port '+trim(port)
 !null=timer.set(1,'sock_client',userdata)
 return
endif else begin
 userdata.serverlun=serverlun
endelse

lun=serverlun
mprint,'Server accepted connection on port '+trim(port)+' via unit '+trim(serverlun)

!null = Timer.Set (.1, 'sock_client_callback',userdata)

return & end

