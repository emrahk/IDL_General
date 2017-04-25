
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message::xdr_msg, xdr

; XDR the message ID

IF NOT xdr->xdr_u_long (self.rm_xid) THEN RETURN, 0

; Save the old message direction.

old_rm_direction = *self.rm_direction

; XDR the message direction (either a CALL message or a REPLY message)

IF NOT xdr->xdr_enum (self.rm_direction) THEN RETURN, 0

; Check if the message direction has changed.  If it has then we will have to delete
; current message body and then recreate it.

IF old_rm_direction NE *self.rm_direction THEN BEGIN

   IF OBJ_VALID (self.rm_msg_body) THEN OBJ_DESTROY, self.rm_msg_body

ENDIF

; Check if the message body object is valid.  If it isn't, then we will create one based
; on the value of rm_direction.

IF NOT OBJ_VALID (self.rm_msg_body) THEN BEGIN

; Use the case statement to create the appropiate message body.  Note, we are not
; passing it any parameters, just creating it.

   CASE *self.rm_direction OF

     self.CALL:     self.rm_msg_body = OBJ_NEW ('RPC_CALL_BODY')

     self.REPLY:    self.rm_msg_body = OBJ_NEW ('RPC_REPLY_BODY')

     ELSE:               BEGIN

                            PRINT, 'Unknown message type: Direction: ', self.rm_direction

                            *self.rm_direction = -1

                            RETURN, 0

                          END


   ENDCASE

; Check if the object creation succeded.  If it did not, then return 0

   IF NOT OBJ_VALID (self.rm_msg_body) THEN RETURN, 0

ENDIF

; XDR the message body

IF NOT self.rm_msg_body->xdr_msg_body (xdr) THEN RETURN, 0

; Flush the buffer.  Send the message if using TCP/IP

xdr->flush_buffer

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message::calculate_xid

; GET the process ID of a child process.  Normally, the XID field is set using the PID of the
; current process, but since there is no easy way to do this, we will use the PID of a child
; process.  All we need is a unique ID here, so this should be OK.

pid = get_rid ()

; Get the current UTC time.

GET_UTC, time_now

; Convert the current UTC time to seconds since the begining of the of the Epoch
; millisecnds

EPOCH_ZERO = UTC2SEC (STR2UTC ('1970-JAN-01T00:00'))

tv_sec = UTC2SEC (time_now) - EPOCH_ZERO

tv_msec = DOUBLE (time_now.time MOD 1000)

; Calculate out an ID

xid = DOUBLE (pid) * tv_msec

RETURN, ULONG (xid)

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message::get_xid

RETURN, *self.rm_xid

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message::set_xid

*self.rm_xid = self->calculate_xid ()

RETURN, *self.rm_xid

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message::get_data

rm_xid       = *self.rm_xid
rm_direction = *self.rm_direction

; Check if a valid message body object has been created.  If it has, get the data from the
; message body object and then fold in the data from this object.

IF OBJ_VALID (self.rm_msg_body) THEN BEGIN

   ds = self.rm_msg_body->get_data ()

   RETURN, CREATE_STRUCT ('rm_xid', rm_xid, 'rm_direction', rm_direction, ds)

ENDIF

; Otherwise, if the message body doesn't exist, just return an anonymous structure
; containing the message id and direction data items.

RETURN, {rm_xid: rm_xid, rm_direction: rm_direction}

END

; ------------------------------------------------------------------------------------------------

PRO rpc_message::set_data, RM_XID = rm_xid, RM_DIRECTION = rm_direction, _EXTRA = ex

IF N_ELEMENTS (rm_xid)       NE 0 THEN *self.rm_xid = rm_xid

IF N_ELEMENTS (rm_direction) NE 0 THEN BEGIN

; Check if the direction specified by the keyword RM_DIRECTIOn is the is same as the
; direction in the current object.  If it is not, then we have go and recreate the
; message body.

   IF *self.rm_direction NE rm_direction THEN BEGIN

; Check if there is currently a message  body object.  If there is, then we must get
; rid of it.

      IF OBJ_VALID (self.rm_msg_body) THEN BEGIN

         OBJ_DESTROY, self.rm_msg_body

         self.rm_msg_body = OBJ_NEW ()

      ENDIF

; Copy the keyword RM_DIRECTION into the appropiate field.

      *self.rm_direction = rm_direction

; Create a message body appropiate to the direction (CALL or REPLY).

      CASE *self.rm_direction OF

         self.CALL:       self.rm_msg_body = OBJ_NEW ('RPC_CALL_BODY')

         self.REPLY:      self.rm_msg_body = OBJ_NEW ('RPC_REPLY_BODY')

         ELSE:            BEGIN

                             PRINT, 'Unknown message type requested. Type: ', rm_direction

                             self.rm_direction = PTR_NEW -1

                             RETURN

                          END

      ENDCASE

   ENDIF

ENDIF

; If a valid message body exists, the use its set_data method to give it any extra parameters
; that were passed to this method.

IF OBJ_VALID (self.rm_msg_body) THEN self.rm_msg_body->set_data, _EXTRA = ex

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_message::reset, SET_XID = set_xid

IF OBJ_VALID (self.rm_msg_body) THEN self.rm_msg_body->reset

*self.rm_xid = -1

IF KEYWORD_SET (set_xid) THEN BEGIN

   *self.rm_xid = self->calculate_xid ()

ENDIF

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_message::msg_reset

*self.rm_xid       = -1
*self.rm_direction = -1

IF OBJ_VALID (self.rm_msg_body) THEN OBJ_DESTROY, self.rm_msg_body

self.rm_msg_body = OBJ_NEW ()

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message::init, RM_DIRECTION = d, SET_XID = set_xid, _EXTRA = ex

; Create the constants object.

cnst = OBJ_NEW ('RPC_CONSTANTS')

; Set local copies of constants used by this object

self.CALL    = cnst.CALL
self.REPLY   = cnst.REPLY

; Get rid of the constants object

OBJ_DESTROY, cnst

self.rm_direction = PTR_NEW (-1)
self.rm_xid       = PTR_NEW (-1)
self.rm_msg_body  = OBJ_NEW ()

IF KEYWORD_SET (set_xid) THEN *self.rm_xid = self->calculate_xid ()

IF N_ELEMENTS (d) NE 0 THEN BEGIN

; Create a message body appropiate to the direction (CALL or REPLY).  Use any extra
; parameters from the call to this method in the creation of the new object.

   CASE d OF

      self.CALL:       BEGIN

                          *self.rm_direction = self.CALL
                          self.rm_msg_body   = OBJ_NEW ('RPC_CALL_BODY', _EXTRA = ex)

                       END

      self.REPLY:      BEGIN

                          *self.rm_direction = self.REPLY
                          self.rm_msg_body   = OBJ_NEW ('RPC_REPLY_BODY', _EXTRA = ex)

                       END

      ELSE:            BEGIN

                          PRINT, 'Unknown message type requested. Type: ', d
                          RETURN, 0

                       END

   ENDCASE

; Make sure the child object creation succeeded.

   IF NOT OBJ_VALID (self.rm_msg_body) THEN RETURN, 0

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------


PRO rpc_message::cleanup

IF PTR_VALID (self.rm_xid)      THEN PTR_FREE, self.rm_xid
IF PTR_VALID (self.rm_direction)THEN PTR_FREE, self.rm_direction

IF OBJ_VALID (self.rm_msg_body) THEN OBJ_DESTROY, self.rm_msg_body

RETURN

END

; ------------------------------------------------------------------------------------------------


PRO rpc_message__define

;/*
; * The rpc message
; */
;struct rpc_msg {
;   u_int        rm_xid;
;   enum msg_type     rm_direction;
;   union {
;     struct call_body RM_cmb;
;     struct reply_body RM_rmb;
;   } ru;


struct = {RPC_MESSAGE,                    $
          rm_xid:        PTR_NEW (),      $
          rm_direction : PTR_NEW (),      $
          rm_msg_body:   OBJ_NEW (),      $
          CALL:          0,               $
          REPLY:         0                $
          }

RETURN

END
