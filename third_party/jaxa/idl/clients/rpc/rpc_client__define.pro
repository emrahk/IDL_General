; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::open_socket, port, hostname

srror_status = 0

; Check if the user supplied a  hostname.  If he didn't then we will use the hostname stored in
; the object.

IF NOT KEYWORD_SET (hostname) THEN hostname = self.hostname


PRINT, "Trying to open host: " + hostname

SOCKET, lun,                                       $
        hostname,                                  $
        port,                                      $
        /GET_LUN,                                  $
        /RAWIO,                                    $
        CONNECT_TIMEOUT = self.connect_timeout,    $
        ERROR =           error_status,            $
        READ_TIMEOUT =    self.read_timeout,       $
        WRITE_TIMEOUT =   self.write_timeout

IF error_status NE 0 THEN BEGIN

   PRINT, "Connection to ", hostname, " Failed."
   PRINT, !ERROR_STATE.msg

   self.open_skt_flag = 0

   RETURN, 0

ENDIF

self.lun = lun

self.open_skt_flag = 1

self.connected_to_host = hostname

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::close_socket

IF OBJ_VALID (self.xdr_stream) THEN OBJ_DESTROY, self.xdr_stream

self.xdr_stream = OBJ_NEW ()

self.open_xdr_flag = 0

status = FSTAT (self.lun)

IF NOT status.open THEN RETURN, 0

FREE_LUN, self.lun

PRINT, "Terminated connection to " + self.connected_to_host

self.open_skt_flag = 0
self.connected_to_host = ''

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::open_xdr_stream

; Make sure that we have a valid a socket.

IF NOT self.open_skt_flag THEN RETURN, 0

self.xdr_stream = OBJ_NEW ('XDR', TYPE = 'REC', LUN = self.lun, MAX_BUFF_SIZE = self.xdr_buff_size)

IF NOT OBJ_VALID (self.xdr_stream) THEN BEGIN

   PRINT, 'Failed to open XDR Stream.'

   self.open_xdr_flag = 0

   RETURN, 0

ENDIF

self.open_xdr_flag = 1

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::close_xdr_stream

IF OBJ_VALID (self.xdr_stream) THEN OBJ_DESTROY, self.xdr_stream

self.xdr_stream = OBJ_NEW ()

self.open_xdr_flag = 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::send_msg_to_srvc, RETURN_RAW_DATA = raw


IF NOT self.open_xdr_flag THEN RETURN, 0

; Set the XDR direction to encode (Send Message)

self.xdr_stream->setdirection, self.XDR_ENCODE

; Set the call message ID

xid = self.msg_call->set_xid ()

; Send the call msg.  If we can not XDR the message for some reason, then we will print
; an error message and exit.

IF NOT self.msg_call->xdr_msg (self.xdr_stream) THEN BEGIN

   PRINT, 'Failed to send RPC call message to service host.'

   RETURN, 0

ENDIF

; Capture some important parameters from the call message.

s = self.msg_call->get_data ()

; Set the XDR direction to decode (Receive Message)

self.xdr_stream->setdirection, self.XDR_DECODE

; Reset the reply message

self.msg_reply->reset


; Receive the reply msg.  If we can not XDR the message for some reason, then we will print
; an error message and exit.

IF NOT self.msg_reply->xdr_msg (self.xdr_stream) THEN BEGIN

   PRINT, 'Failed to receive RPC reply message from service host.'

   RETURN, 0

ENDIF

; Check the ID of the reply message against the ID of the call message.  If they do not
; match then we have received an out-of-order reply.  We can not currently handle this
; situation, although this may change in future versions.

IF xid NE self.msg_reply->get_xid () THEN BEGIN

   PRINT, 'ID of message received from host does not match ID of message sent to host.'
   PRINT, 'ID of message sent to host: ', xid, FORMAT = '(A, Z0)'
   PRINT, 'ID of message received from host: ', self.msg_reply->get_xid (), FORMAT = '(A, Z0)'

   RETURN, 0

ENDIF

; Get all the values from the reply message.

r = self.msg_reply->get_data ()

; Extract the reply status from the recieved message.  If the reply status is MESSAGE REJECTED,
; then print an appropiate error message.

IF r.reply_stat EQ self.MSG_DENIED THEN BEGIN

   PRINT, 'RPC message was reject by service host."

; Give the user some more detail based on the reject stat.

   CASE r.reject_stat OF

      self.RPC_MISMATCH:   BEGIN

         PRINT, 'RPC Version Mismatch'

         END

      self.AUTH_ERROR:     BEGIN

         PRINT, 'Insuficient Authority or Authority Check Failed.'

         END

      ELSE:     PRINT, 'Not able to interpret reason for message rejection.'

   ENDCASE

   RETURN, 0

ENDIF

; Extract the accept status from the recieved message.  If the accept status anything but
; SUCCESS then print an appropiate error message.

IF r.accept_stat NE self.SUCCESS THEN BEGIN

   PRINT, 'RPC message accepted, but detected the following error condition.'

   CASE r.accept_stat OF

      self.PROG_MISMATCH: BEGIN

         PRINT, 'Program Mismatch'

         END

      self.PROG_UNAVAIL:  BEGIN

         PRINT, 'Program Unavailable'

         END

      self.PROC_UNAVAIL:  BEGIN

         PRINT, 'Procedure Unavailable'

         END

      self.GARBAGE_ARGS:  BEGIN

         PRINT, 'Garbage Argument'

         END

      ELSE:     PRINT, 'Not able to interpret reason for message acceptance status.'

  ENDCASE

  RETURN, 0

ENDIF

IF KEYWORD_SET (raw) THEN BEGIN

   *self.reply_data = r.data_value

ENDIF ELSE IF r.data_type EQ self.RPC_RECORD THEN BEGIN

; Make sure that record will fit in the data buffer.  If it won't then we can not use this
; section of code.

   IF N_ELEMENTS (r.data_value) GT self.format_buff_sz THEN BEGIN

      PRINT, 'Can not reformat raw data received from RPC server.'
      PRINT, 'Raw data segment must be less then: ', self.format_buff_sz, ' bytes.

      RETURN, 0

   ENDIF


; Set the msg_router to create a data structure appropriate to value returned by
; reply message


   self.msg_router->set_data, RT_PROG = s.cb_prog,                           $
                              RT_VERS = s.cb_vers,                           $
                              RT_FUNC = s.cb_proc,                           $
                              /REPLY

; Set the XDR direction to encode

   self.xdr_buffer->setdirection, self.XDR_ENCODE

; Reset the XDR Memory Buffer

   self.xdr_buffer->reset

; Copy the data segment from the reply message into the XDR Memory Buffer

   IF NOT self.xdr_buffer->xdr_opaque (r.data_value, N_ELEMENTS (r.data_value)) THEN RETURN, 0

; Set the XDR direction to decode

   self.xdr_buffer->setdirection, self.XDR_DECODE

; Reformat the data segment acording the type of value returned by the reply
; message

   IF NOT self.msg_router->xdr_data (self.xdr_buffer) THEN RETURN, 0

; Replace the value pointed to by reply_data with result of the reformatted data segment.

   *self.reply_data = self.msg_router->get_data ()

   tagname = TAG_NAMES (*self.reply_data)

   tag = WHERE (tagname EQ 'DATA_VALUE')

   IF tag [0] NE -1 THEN *self.reply_data = (*self.reply_data).data_value

ENDIF ELSE BEGIN

   *self.reply_data = self.IDL_NULL

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::get_reply_data

RETURN, *self.reply_data

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::getport_from_pm, PM_ADDRESS = pm_address, PM_HOSTNAME = pm_hostname

; Reset the server port address to 0 (Not Found).

self.server_address = 0

; Close any open sockets or XDR channels

IF self.open_skt_flag THEN BEGIN

   IF NOT self->close_socket () THEN BEGIN

      PRINT, 'Failed to properly close socket.'

      RETURN, 0

    ENDIF

ENDIF

; Check if the keyword PM_ADDRESS was passed to us.  If it was not, then we will use the
; default port mapper address that is store with this object.

IF NOT KEYWORD_SET (pm_address) THEN pm_address = self.pm_address

; Check if the keyword PM_HOSTNAME was passed to us.  If it was not, then we will use the
; default hostname that is store with this object.

IF NOT KEYWORD_SET (pm_hostname) THEN pm_hostname = self.pm_hostname

; Attempt to open a socket to the port mapper on the host machine

IF NOT self->open_socket ( pm_address, pm_hostname ) THEN RETURN, 0

; Attept to create XDR stream on top of the socket.

IF NOT self->open_xdr_stream () THEN RETURN, 0

; Create the call and reply messages

self.msg_call  = OBJ_NEW ('RPC_MESSAGE', RM_DIRECTION = self.CALL)
self.msg_reply = OBJ_NEW ('RPC_MESSAGE', RM_DIRECTION = self.REPLY)

; Copy the correct parameters into the call message to request a port number
; from the port mapper on the host machine.

self.msg_call->set_data,  CB_PROG      = self.PMAP_PROG,         $
                          CB_VERS      = self.PMAP_VERS,         $
                          CB_PROC      = self.PMAPPROC_GETPORT,  $
                          AUTH_TYPE = "NULL",                    $
                          /SET_RPC_VERS,                         $
                          /STATIC,                               $
                          PROG         = self.svr_prog,          $
                          VERS         = self.svr_prog_vers,     $
                          PROT         = self.IPPROTO_TCP,       $
                          PORT         = 0


; Use the snd_msg_to_srv() function to querry the port mapper on the host machine

msg_status = self->send_msg_to_srvc ()

; Get rid of the message blocks

IF OBJ_VALID (self.msg_call)  THEN OBJ_DESTROY, self.msg_call
IF OBJ_VALID (self.msg_reply) THEN OBJ_DESTROY, self.msg_call

; Close out the socket and the XDR stream that we opened on top of it.

IF NOT self->close_socket () THEN BEGIN

   PRINT, 'Failed to properly close socket.'

   RETURN, 0

ENDIF

; Check if the call to send_msg_to_srvc succeeded.  If it did not, then return 0.

IF NOT msg_status THEN RETURN, 0

; Check if the Port Mapper was able to find the program that we requested.

IF *self.reply_data EQ 0 THEN BEGIN

   PRINT, 'Program: ',                                           $
          self.svr_prog,                                         $
          ' has not been registered on host: ',                  $
          self.hostname,                                         $
          FORMAT = '(A, Z0, A, A)'

    RETURN, 0

ENDIF

self.server_address = *self.reply_data

RETURN, 1

END


; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::call_service, SVR_PROC = svr_proc, _EXTRA = extra

IF NOT self.connect_flag THEN BEGIN

   PRINT, 'Service must be opened before it can be used.'

   RETURN, 0

ENDIF

; Make sure that a server procedure is specified.  If none is specified, then we will use
; procedure 0 (universally defined as a NULL procedure)

IF NOT KEYWORD_SET (svr_proc) THEN svr_proc = 0

; Create the message to send to send to the service.

self.msg_call->set_data, CB_PROC = svr_proc, _EXTRA = extra

; Use the snd_msg_to_srv() to talk to the service

IF NOT self->send_msg_to_srvc (_EXTRA = extra) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::open_service, PROG = prog,                  $
                                   VERS = vers,                  $
                                   IDL_RPC_ID = idl_rpc_id,      $
                                   HOSTNAME = hostname,          $
                                   PM_ADDRESS = pm_address,      $
                                   PM_HOSTNAME = pm_hostname

IF self.connect_flag THEN BEGIN

   PRINT, 'Service on host: ', self.hostname, ' must be closed before new service can be opened.'

   RETURN, 0

ENDIF

IF NOT KEYWORD_SET (prog) THEN RETURN, 0
IF NOT KEYWORD_SET (vers) THEN RETURN, 0

IF KEYWORD_SET (hostname) THEN self->set_hostname, hostname

IF NOT KEYWORD_SET (self.hostname) THEN BEGIN

   PRINT, 'A host must be specified before service can opened.'

   RETURN, 0

ENDIF

self.svr_prog      = prog
self.svr_prog_vers = vers
self.msg_router    = OBJ_NEW ('RPC_MESSAGE_ROUTER', IDL_RPC_ID = idl_rpc_id)

IF NOT self->getport_from_pm (PM_ADDRESS = pm_address, PM_HOSTNAME = pm_hostname) THEN RETURN, 0

IF NOT self->open_socket ( self.server_address ) THEN RETURN, 0

; Attept to create XDR stream on top of the socket.

IF NOT self->open_xdr_stream () THEN RETURN, 0

; Set up the call and reply message blockes

self.msg_call   = OBJ_NEW ('RPC_MESSAGE',                         $
                           RM_DIRECTION = self.CALL,              $
                           /SET_RPC_VERS,                         $
                           CB_PROG      = self.svr_prog,          $
                           CB_VERS      = self.svr_prog_vers,     $
                           CB_PROC      = 0,                      $
                           AUTH_TYPE = "NULL",                    $
                           IDL_RPC_ID   = idl_rpc_id              $
                           )


self.msg_reply  = OBJ_NEW ('RPC_MESSAGE', RM_DIRECTION = self.REPLY)


self.connect_flag = 1

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::close_service

IF NOT self.connect_flag THEN RETURN, 0

IF NOT self->close_socket () THEN RETURN, 0

; Get rid of the message blocks

IF OBJ_VALID (self.msg_call)   THEN OBJ_DESTROY, self.msg_call
IF OBJ_VALID (self.msg_reply)  THEN OBJ_DESTROY, self.msg_reply
IF OBJ_VALID (self.msg_router) THEN OBJ_DESTROY, self.msg_router

self.svr_prog      = 0
self.svr_prog_vers = 0
self.connect_flag  = 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_client::set_hostname, hostname

IF self.connect_flag THEN BEGIN

   IF NOT self->close_service () THEN RETURN

ENDIF

IF KEYWORD_SET (hostname) THEN self.hostname = hostname

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_client::init, READ_TIMEOUT    = read_timeout,                               $
                           WRITE_TIMEOUT   = write_timeout,                              $
                           CONNECT_TIMEOUT = connect_timeout,                            $
                           XDR_BUFF_SIZE   = xdr_buff_size,                              $
                           HOSTNAME        = hostname,                                   $
                           PM_ADDRESS      = pm_address,                                 $
                           PM_HOSTNAME     = pm_hostname

IF NOT self->rpc_constants::init () THEN RETURN, 0

IF NOT KEYWORD_SET (read_timeout)    THEN read_timeout =  30
IF NOT KEYWORD_SET (write_timeout)   THEN write_timeout = 30
IF NOT KEYWORD_SET (connect_timeout) THEN connect_timeout = 5
IF NOT KEYWORD_SET (xdr_buff_size)   THEN xdr_buff_size = 4096
IF NOT KEYWORD_SET (hostname)        THEN hostname = ''
IF NOT KEYWORD_SET (pm_address)      THEN pm_address = 111
IF NOT KEYWORD_SET (pm_hostname)     THEN pm_hostname = hostname

self.read_timeout    = read_timeout
self.write_timeout   = write_timeout
self.connect_timeout = connect_timeout
self.xdr_buff_size = xdr_buff_size
self.hostname = hostname
self.pm_address = pm_address
self.pm_hostname = pm_hostname

self.svr_prog       = 0
self.svr_prog_vers  = 0
self.server_address = 0
self.open_skt_flag  = 0
self.open_xdr_flag  = 0
self.format_buff_sz = 4098

self.xdr_buffer = OBJ_NEW ('XDR', TYPE = 'MEM', MAX_BUFF_SIZE = self.format_buff_sz)

self.reply_data = PTR_NEW (0)

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_client::cleanup

IF self.open_xdr_flag THEN status = self->close_xdr_stream ()

IF self.open_skt_flag THEN status = self->close_socket ()

IF OBJ_VALID (self.msg_call)   THEN OBJ_DESTROY, self.msg_call
IF OBJ_VALID (self.msg_reply)  THEN OBJ_DESTROY, self.msg_reply
IF OBJ_VALID (self.xdr_stream) THEN OBJ_DESTROY, self.xdr_stream
IF OBJ_VALID (self.msg_router) THEN OBJ_DESTROY, self.msg_router
IF OBJ_VALID (self.xdr_buffer) THEN OBJ_DESTROY, self.xdr_buffer

IF PTR_VALID (self.reply_data) THEN PTR_FREE, self.reply_data

self->rpc_constants::cleanup

RETURN

END
; ------------------------------------------------------------------------------------------------

PRO rpc_client__define

struct = {RPC_CLIENT,                        $
          hostname:              '',         $
          connected_to_host:     '',         $
          svr_prog:              0L,         $
          svr_prog_vers:         0L,         $
          lun:                   0L,         $
          server_address:        0L,         $
          pm_address:            0L,         $
          pm_hostname:           '',         $
          read_timeout:          0L,         $
          write_timeout:         0L,         $
          connect_timeout:       0L,         $
          xdr_buff_size:         0L,         $
          format_buff_sz:        0L,         $
          open_skt_flag:         0L,         $
          open_xdr_flag:         0L,         $
          connect_flag:          0L,         $
          msg_call:              OBJ_NEW (), $
          msg_reply:             OBJ_NEW (), $
          msg_router:            OBJ_NEW (), $
          xdr_stream:            OBJ_NEW (), $
          xdr_buffer:            OBJ_NEW (), $
          reply_data:            PTR_NEW (), $
          INHERITS RPC_CONSTANTS             $
          }


END
