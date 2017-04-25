; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCInit, HOSTNAME = hostname,                             $
                                  PM_ADDRESS = pm_address,                         $
                                  PM_HOSTNAME = pm_hostname

IF NOT KEYWORD_SET (hostname) THEN BEGIN

   PRINT, 'A hostname must be specified in order to use this method.'

   RETURN, 0

ENDIF

self.hostname = hostname

status = self.rpc_client_obj->open_service (PROG       = self.idl_rpc_id,          $
                                            VERS       = self.idl_rpc_version,     $
                                            IDL_RPC_ID = self.idl_rpc_id,          $
                                            HOSTNAME   = self.hostname,            $
                                            PM_HOSTNAME= pm_hostname,              $
                                            PM_ADDRESS = pm_address                $
                                            )

IF NOT status THEN BEGIN

   PRINT, 'Failed to connect to IDL server on host: ', self.hostname, '.'

   RETURN, 0

ENDIF

self.connect_flag = 1

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCOutputCapture, capture_lines

IF NOT self.connect_flag EQ 0 THEN BEGIN

   PRINT, 'Client must be connected to IDL Server before using this method.'

   RETURN, 0

ENDIF

status = self.rpc_client_obj->call_service (SVR_PROC   = self.IDL_RPC_OUT_CAPTURE,      $
                                       DATA_VALUE = capture_lines)

IF NOT status THEN BEGIN

   PRINT, 'Attempt to execute procedure IDL_RPC_OUT_CAPTURE failed.'

   RETURN, 0

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCSetVariable, NAME = name, VALUE = val

IF NOT self.connect_flag EQ 0 THEN BEGIN

   PRINT, 'Client must be connected to IDL Server before using this method.'

   RETURN, 0

ENDIF

IF NOT KEYWORD_SET (name) THEN BEGIN

   PRINT, 'The keyword NAME must be passed to this method.'

   RETURN, 0

ENDIF

IF N_ELEMENTS (val) EQ 0 THEN BEGIN

   PRINT, 'The keyword VALUE must be passed to this method.'

   RETURN, 0

ENDIF

; Copy the name and value to the IDL variable object.

IF NOT self.idl_variable->set_value (name, val) THEN RETURN, 0

; Set the XDR direction to encode

self.xdr_buffer->setdirection, self.XDR_ENCODE

; Reset the XDR Memory Buffer

self.xdr_buffer->reset

; Use the IDL variable object to create a data segment representing the variable.

IF NOT self.idl_variable->xdr_idl_variable (self.xdr_buffer) THEN RETURN, 0

; Set the XDR direction to decode

self.xdr_buffer->setdirection, self.XDR_DECODE

; Get the data segment from the XDR Memory Buffer

IF NOT self.xdr_buffer->xdr_opaque (send_data, self.xdr_buffer->getbufsize ()) THEN RETURN, 0

status = self.rpc_client_obj->call_service (SVR_PROC = self.IDL_RPC_SET_VAR,                     $
                                            DATA_VALUE = send_data,                              $
                                            DATA_TYPE  = self.RPC_RECORD)

IF NOT status THEN BEGIN

   PRINT, 'Attempt to execute procedure IDL_RPC_SET_VAR failed.'

   RETURN, 0

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCGetVariable, NAME = name, VALUE = val

IF NOT self.connect_flag EQ 0 THEN BEGIN

   PRINT, 'Client must be connected to IDL Server before using this method.'

   RETURN, 0

ENDIF

IF NOT KEYWORD_SET (name) THEN BEGIN

   PRINT, 'The keyword NAME must be set to the name of variable to retrieve.'

   RETURN, 0

ENDIF

status = self.rpc_client_obj->call_service (SVR_PROC = self.IDL_RPC_GET_VAR,                     $
                                            DATA_VALUE = name,                                   $
                                            /RETURN_RAW_DATA)

IF NOT status THEN BEGIN

   PRINT, 'Attempt to execute procedure IDL_RPC_GET_VAR failed.'

   RETURN, 0

ENDIF

reply_data = self.rpc_client_obj->get_reply_data ()


; Make sure that record will fit in the data buffer.  If it won't then we can not use this
; section of code.

IF N_ELEMENTS (reply_data) GT self.xdr_buffer_size THEN BEGIN

   PRINT, 'Can not reformat raw data received from RPC server.'
   PRINT, 'Raw data segment must be less then: ', self.xdr_buffer_size, ' bytes.

   RETURN, 0

ENDIF

; Set the XDR direction to encode

self.xdr_buffer->setdirection, self.XDR_ENCODE

; Reset the XDR Memory Buffer

self.xdr_buffer->reset

; Copy the data segment from the reply message into the XDR Memory Buffer

IF NOT self.xdr_buffer->xdr_opaque (reply_data, N_ELEMENTS (reply_data)) THEN RETURN, 0

; Set the XDR direction to decode

self.xdr_buffer->setdirection, self.XDR_DECODE

; Reformat the data segment acording the type of value returned by the reply
; message

IF NOT self.idl_variable->xdr_idl_variable (self.xdr_buffer) THEN RETURN, 0

; Get the value of the IDL variable we just received.

val = self.idl_variable->get_value ()

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCOutputGetStr, LINE = line, FIRST = first, FLAGS = flags

IF NOT self.connect_flag EQ 0 THEN BEGIN

   PRINT, 'Client must be connected to IDL Server before using this method.'

   RETURN, 0

ENDIF

IF KEYWORD_SET (first) THEN first = 1 ELSE first = 0

status = self.rpc_client_obj->call_service (SVR_PROC = self.IDL_RPC_OUT_STR, DATA_VALUE = first)


IF NOT status THEN BEGIN

   PRINT, 'Attempt to execute procedure IDL_RPC_OUT_STR failed.'

   RETURN, 0

ENDIF

reply_data = self.rpc_client_obj->get_reply_data ()

line  = reply_data.buf
flags = reply_data.flags

; PRINT, 'flags = ', flags, FORMAT = '(A, Z0)'

IF flags EQ -1 THEN BEGIN

   self.buffer_empty_flag = 1
   self.last_line_flag    = 0

ENDIF ELSE IF flags AND '01'X EQ 0 THEN BEGIN

   self.buffer_empty_flag = 0
   self.last_line_flag    = 1

ENDIF ELSE BEGIN

   self.buffer_empty_flag = 0
   self.last_line_flag    = 0

ENDELSE


RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCExecuteStr, idlcmd, ERROR = error

IF NOT self.connect_flag EQ 0 THEN BEGIN

   PRINT, 'Client must be connected to IDL Server before using this method.'

   RETURN, 0

ENDIF

IF NOT KEYWORD_SET (idlcmd) THEN BEGIN

   PRINT, 'A string must be passed as the input to this method.'

   RETURN, 0

ENDIF

status = self.rpc_client_obj->call_service (SVR_PROC = self.IDL_RPC_EXE_STR, DATA_VALUE = idlcmd)

IF NOT status THEN BEGIN

   PRINT, 'Attempt to execute procedure IDL_RPC_EXE_STR failed.'

   RETURN, 0

ENDIF

retval = self.rpc_client_obj->get_reply_data ()

IF retval NE 0 AND N_ELEMENTS (error) NE 0 THEN error = retval

; IF retval EQ 0 THEN RETURN, 1 ELSE RETURN, 0

; Cludge for now, until I figure out how to interpret the retrun value!

RETURN, status

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::RPCCleanup, KILL_SERVER = kill_server

IF NOT self.connect_flag EQ 0 THEN BEGIN

   PRINT, 'Client must be connected to IDL Server before using this method.'

   RETURN, 0

ENDIF

IF KEYWORD_SET (kill_server) THEN BEGIN

   IF NOT self.rpc_client_obj->call_service (SVR_PROC = self.IDL_RPC_CLEANUP) THEN BEGIN

      PRINT, 'Attempt to execute procedure IDL_RPC_CLEANUP failed.'

   ENDIF

ENDIF


status = self.rpc_client_obj->close_service ()

self.connect_flag = 0

IF NOT status THEN BEGIN

   PRINT, 'Error while closing connection to IDL RPC Server.'

ENDIF

RETURN, status

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::send_struct_to_host, VALUE = val, NAME = name

;IF NOT self.connect_flag EQ 0 THEN BEGIN

;   PRINT, 'Client must be connected to IDL Server before using this method.'

;   RETURN, 0

;ENDIF

IF NOT KEYWORD_SET (name) THEN BEGIN

   PRINT, 'The keyword NAME must be passed to this method.'

   RETURN, 0

ENDIF

IF N_ELEMENTS (val) EQ 0 THEN BEGIN

   PRINT, 'The keyword VALUE must be passed to this method.'

   RETURN, 0

ENDIF

; Make sure that we were passed a structure

IF SIZE (val, /TYPE) NE 8 THEN BEGIN

   PRINT, 'The value passed to this method must be a structure.'

   RETURN, 0

ENDIF

stop

; Create the new structure in the remote IDL session.

;IF NOT self->RPCExecuteStr (cmd) THEN BEGIN

;    PRINT, 'Failed to execute command: ', cmd, ' in remote session.'

;   RETURN, 0

;ENDIF

; Check if we have been passed an array of structures.  If we have, then replicate
; the new structure into an array.

IF N_ELEMENTS (val) GT 1 THEN BEGIN

   cmd = name + ' = REPLICATE (' + name + ', ' + STRTRIM (STRING (N_ELEMENTS (val))) + ')'

;   IF NOT self->RPCExecuteStr (cmd) THEN BEGIN

;      PRINT, 'Failed to execute command: ', cmd, ' in remote session.'

;      RETURN, 0

;   ENDIF

; Copy the structure data to the remote host.  The data for each tag is copied over as an
; array, one tag at a time.

;  FOR i = 0, nitems - 1 DO BEGIN

;     aname = name + STRING

;  ENDFOR

ENDIF


RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_rpc_client::init, IDL_RPC_ID      = idl_rpc_id,             $
                               IDL_RPC_VERSION = idl_rpc_version,        $
                               CONNECT_TIMEOUT = connect_timeout,        $
                               READ_TIMEOUT    = read_timeout,           $
                               WRITE_TIMEOUT   = write_timeout,          $
                               PM_HOSTNAME     = pm_hostname,            $
                               PM_ADDRESS      = pm_address

self.IDL_RPC_MAX_STRLEN      = 512
self.IDL_RPC_DEFAULT_ID      = '2010CAFE'X
self.IDL_RPC_DEFAULT_VERSION = 1
self.IDL_RPC_SET_VAR         = '10'X
self.IDL_RPC_GET_VAR         = '20'X
self.IDL_RPC_SET_MAIN_VAR    = '30'X
self.IDL_RPC_GET_MAIN_VAR    = '40'X
self.IDL_RPC_EXE_STR         = '50'X
self.IDL_RPC_OUT_CAPTURE     = '60'X
self.IDL_RPC_OUT_STR         = '70'X
self.IDL_RPC_CLEANUP         = '90'X

; Create the constants object.

cnst = OBJ_NEW ('RPC_CONSTANTS')

; Get a local copy of all the constants.

c    = cnst->get_constants ()

; Get rid of the constants object

OBJ_DESTROY, cnst

; Set local copies of constants used by this object

self.XDR_ENCODE       = c.XDR_ENCODE
self.XDR_DECODE       = c.XDR_DECODE
self.RPC_RECORD       = c.RPC_RECORD

self.connect_flag = 0
self.buffer_empty_flag = 0
self.last_line_flag = 0

self.xdr_buffer_size         = 1024L * 32L * 1000L * 2L
self.xdr_buffer              = OBJ_NEW ('XDR', TYPE = 'MEM', MAX_BUFF_SIZE = self.xdr_buffer_size)
self.idl_variable            = OBJ_NEW ('RPC_IDL_VARIABLE')

IF NOT KEYWORD_SET (idl_rpc_id)      THEN idl_rpc_id = self.IDL_RPC_DEFAULT_ID
IF NOT KEYWORD_SET (idl_rpc_version) THEN idl_rpc_version = self.IDL_RPC_DEFAULT_VERSION

self.idl_rpc_id      = idl_rpc_id
self.idl_rpc_version = idl_rpc_version

self.rpc_client_obj = OBJ_NEW ('RPC_CLIENT',                         $
                               CONNECT_TIMEOUT = connect_timeout,    $
                               READ_TIMEOUT    = read_timeout,       $
                               WRITE_TIMEOUT   = write_timeout,      $
                               PM_ADDRESS      = pm_address,         $
                               PM_HOSTNAME     = pm_hostname)

IF NOT OBJ_VALID (self.rpc_client_obj) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO idl_rpc_client::cleanup

IF self.connect_flag THEN status = self->RPCCleanup ()

IF OBJ_VALID (self.rpc_client_obj) THEN OBJ_DESTROY, self.rpc_client_obj

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO idl_rpc_client__define

struct = {IDL_RPC_CLIENT,                                  $
          connect_flag:                 0L,                $
          buffer_empty_flag:            0L,                $
          last_line_flag:               0L,                $
          hostname:                     '',                $
          idl_rpc_id:                   0L,                $
          idl_rpc_version:              0L,                $
          xdr_buffer_size:              0L,                $
          xdr_buffer:                   OBJ_NEW (),        $
          rpc_client_obj:               OBJ_NEW (),        $
          idl_variable:                 OBJ_NEW (),        $
          IDL_RPC_MAX_STRLEN:           0L,                $
          IDL_RPC_DEFAULT_ID:           0L,                $
          IDL_RPC_DEFAULT_VERSION:      0L,                $
          IDL_RPC_SET_VAR:              0L,                $
          IDL_RPC_GET_VAR:              0L,                $
          IDL_RPC_SET_MAIN_VAR:         0L,                $
          IDL_RPC_GET_MAIN_VAR:         0L,                $
          IDL_RPC_EXE_STR:              0L,                $
          IDL_RPC_OUT_CAPTURE:          0L,                $
          IDL_RPC_OUT_STR:              0L,                $
          IDL_RPC_CLEANUP:              0L,                $
          XDR_ENCODE:                   0L,                $
          XDR_DECODE:                   0L,                $
          RPC_RECORD:                   0L                 $
         }

RETURN

END
