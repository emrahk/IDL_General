;+
; Project     : VSO
;
; Name        : SOCK_SERVER
;
; Purpose     : Start a socket server to receive data and execute IDL
;               commands. Data are copied into an IDL-IDL bridge thread.
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_server
;
; Inputs      : None
;
; Outputs     : None
;
; Keywords    : STOP_SERVER = stop server.
;               PORT = socket port to use (def = 21068).
;               MAX_CONNECTIONS = max number of allowable client
;               connections (def=5).
;               HTTP_MODE = run as HTTP server
;
; History     : 28 December 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_Server_Callback, ID, userdata

if getenv('DEBUG1') ne '' then begin
 mprint,'here'
 help,userdata
endif

tset=.01
clientlun=userdata.clientlun
port=userdata.port
server=userdata.server

if ~is_socket(clientlun) then begin
 if obj_valid(userdata.bridge) then obj_destroy,userdata.bridge
 return
endif

;-- create IDL bridge to hold data

if ~obj_valid(userdata.bridge) then userdata.bridge=obj_new('idl_bridge')

error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 goto,keep_listening
endif

;-- copy received variables to IDL-IDL bridge where they can be
;   executed upon

status=File_Poll_Input(clientlun, Timeout = .01)
if status then begin

 sock_recvar,clientlun,name,value,err=err,verbose=verbose,format=format,session=session,$
  disconnected=disconnected,nowait=nowait,main_level=main_level
  
 if is_blank(err) then begin

 ;-- client requested IDL bridge status
 
  if verbose then help,port,clientlun,name,value,session,format

  if format eq 'status' then begin
   bstatus=userdata.bridge->status(err=berror)
   luns=sock_luns(userdata.port,count=lcount,/server)
   result={status:bstatus,error:berror,connections:lcount,$
    max_connections:userdata.max_connections}
   if verbose then help,result
   sock_sendvar,clientlun,'status',result,session=session,verbose=verbose
  endif

  if (n_elements(value) ne 0) then begin
   
;-- client requested data

   if (format eq 'get') && is_string(name) then begin
    bvalue=userdata.bridge->getvar(name,err=err)
    if is_blank(err) then sock_sendvar,clientlun,name,bvalue,session=session,verbose=verbose else $
     sock_sendvar,clientlun,'err',err,session=session,verbose=verbose
   endif

;-- client sent data

   if (format eq 'data') && is_string(name) then begin
    if main_level then (SCOPE_VARFETCH(name, /enter, LEVEL=1)) = value
    type=size(value,/type)
    no_copy= (type ne 10) && (type ne 11)
    userdata.bridge->setvar,name,value,no_copy=no_copy
   endif

;-- client requested execution

   if format eq 'command' then begin
    userdata.bridge->execute,value,nowait=nowait
   endif

;-- client sent a file
  
   if format eq 'file' then begin
    temp_dir=concat_dir(get_temp_dir(),session)
    file_mkdir,temp_dir
    write_stream,name,value,/uncompress,out_dir=temp_dir
   endif

   if (format eq 'help') && is_string(name) then begin
    bvalue=userdata.bridge->getvar(name)
    help,bvalue
   endif

   if (format eq 'print') && is_string(name) then begin
    bvalue=userdata.bridge->getvar(name)
    print,bvalue
   endif

  endif
 endif else begin
  if disconnected then begin
   mprint,'Client disconnected on port '+trim(port)+' and unit '+trim(clientlun)
   close_lun,clientlun
   userdata.clientlun=-1
   if obj_valid(userdata.bridge) then obj_destroy,userdata.bridge
   return
  endif
 endelse 
endif

keep_listening: 
!null = Timer.Set(tset, 'sock_Server_Callback', userdata)

return & end

;--------------------------------------------------------------------------
;-- callback function for HTTP mode

pro sock_http_callback,ID,userdata

tset=.01
clientlun=userdata.clientlun
if ~is_socket(clientlun) then return
port=userdata.port
server=userdata.server

error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 goto,keep_listening
endif

status=File_Poll_Input(clientlun, Timeout = .01)
if status then begin
 sock_http,clientlun,server=server,port=port
 close_lun,clientlun
 userdata.clientlun=-1
endif

keep_listening:
!null = Timer.Set(tset, 'sock_http_callback', userdata)

return & end

;---------------------------------------------------------------------------

pro sock_Listener_Callback, ID, userdata

if getenv('DEBUG2') ne '' then begin
 mprint,'here'
 help,userdata
endif

listenerlun=userdata.listenerlun
if ~is_socket(listenerlun) then return
port=userdata.port
rawio=~userdata.http_mode
max_connections=userdata.max_connections
luns=sock_luns(port,count=count,/server)
server_callback=userdata.callback

if count le max_connections then begin
 status = File_Poll_Input(ListenerLUN, Timeout = .1)
 if status then Begin
  socket,ClientLUN, Accept = ListenerLUN, /Get_LUN, rawio=rawio, $
   Connect_Timeout = 30., Read_Timeout = 30., Write_Timeout = 30.,$
   /Swap_if_Big_Endian,error=error
  if error eq 0 then begin
   mprint,'Client connection request received on port '+trim(port)+' via unit '+trim(clientlun)
   userdata.clientlun=clientlun
   luns=sock_luns(port,count=count,/server)
   if count gt userdata.max_connections then begin 
    dmess='Maximum number of client connections exceeded on '+trim(port)
    mprint,dmess
    sock_sendvar,clientlun,'Exceeded',dmess
    close_lun,clientlun
    userdata.clientlun=-1
   endif else !null = Timer.Set (.1, server_callback,userdata)
  endif else mprint,err_state() 
 endif
endif
!null = Timer.Set(.1, 'sock_Listener_Callback',userdata)

return & end

;----------------------------------------------------------------

pro sock_server,id,userdata,port=port,stop_server=stop_server,$
          _extra=extra,http_mode=http_mode,server=server,$
           max_connections=max_connections

if ~since_version('8.4') then begin
 mprint,'Needs IDL version 8.4 or better.'
 return
endif

;!null=heap_refcount(/enable)

if keyword_set(stop_server) then begin
 if ~is_number(port) then begin
  ports=sock_ports(count=count)
  if count eq 0 then begin
   mprint,'Not running.'
   return
  endif
 endif
 port=ports[0]
 listenerlun=sock_luns(port,/listener)
 if listenerlun eq -1 then begin
  mprint,'Not running on port '+trim(port)
  return
 endif
 serverlun=sock_luns(port,/server)
 close_lun,[listenerlun,serverlun]
 mprint,'Stopping on port '+trim(port)
 return
endif

if is_struct(userdata) then begin
 port=userdata.port
 listenerlun=userdata.listenerlun
 clientlun=userdata.clientlun
 http_mode=userdata.http_mode
 server=userdata.server
endif else begin
 sock_def_server,server,port
 if ~is_number(max_connections) then max_connections=5
 http_mode=keyword_set(http_mode)
 if http_mode then server_callback='sock_http_callback' else server_callback='sock_server_callback'
 listenerlun=sock_luns(port,/listener)
 clientlun=sock_luns(port,/server,count=count)
 mprint,'Currently connected to '+trim(count)+' client(s) on port '+trim(port)
 userdata={listenerlun:listenerlun,clientlun:clientlun[0],port:port,bridge:obj_new(),$
           max_connections:max_connections,server:server,http_mode:http_mode,$
           callback:server_callback}
endelse

if is_socket(listenerlun) then begin
 mprint,'Listening on port '+trim(port)
 return
endif

rawio=~userdata.http_mode
socket,listenerlun,port,/listen, /Get_LUN,/Swap_if_Big_Endian, $
 Read_Timeout = 60., Write_Timeout = 60.,rawio=rawio, error=error
if error ne 0 then begin
 mprint,err_state()
 mprint,'Waiting to connect on port '+trim(port)
 !null=timer.set(5,'sock_server',userdata)
 return
endif
mprint,'Listening on port '+trim(port)+' via unit '+trim(listenerlun)
userdata.listenerlun=listenerlun
userdata.clientlun=clientlun

luns=sock_luns(port,count=count,/server)
if count eq 0 then !null = Timer.Set (.1, 'Sock_Listener_Callback',userdata)

return & end
