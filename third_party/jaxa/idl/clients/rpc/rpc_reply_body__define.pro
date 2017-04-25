; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_mismatch::xdr_reject_reason, xdr

IF NOT xdr->xdr_u_long (self.rpc_mismatch_low) THEN RETURN, 0
IF NOT xdr->xdr_u_long (self.rpc_mismatch_high) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_mismatch::get_data

rpc_mismatch_low  = *self.rpc_mismatch_low
rpc_mismatch_high = *self.rpc_mismatch_high

RETURN, {rpc_mismatch_low:  rpc_mismatch_low, rpc_mismatch_high: rpc_mismatch_high}

END

; ------------------------------------------------------------------------------------------------

PRO rpc_mismatch::set_data,  RPC_MISMATCH_LOW  = rpc_mismatch_low,             $
                             RPC_MISMATCH_HIGH = rpc_mismatch_high


IF N_ELEMENTS (rpc_mismatch_low)  NE 0 THEN *self.rpc_mismatch_low  = rpc_mismatch_low
IF N_ELEMENTS (rpc_mismatch_high) NE 0 THEN *self.rpc_mismatch_high = rpc_mismatch_high

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_mismatch::init, RPC_MISMATCH_LOW  = rpc_mismatch_low,             $
                             RPC_MISMATCH_HIGH = rpc_mismatch_high

IF N_ELEMENTS (rpc_mismatch_low)  EQ 0 THEN rpc_mismatch_low  = 0
IF N_ELEMENTS (rpc_mismatch_high) EQ 0 THEN rpc_mismatch_high = 0

self.rpc_mismatch_low  = PTR_NEW (rpc_mismatch_low)
self.rpc_mismatch_high = PTR_NEW (rpc_mismatch_high)

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_mismatch::cleanup

IF PTR_VALID (self.rpc_mismatch_low)  THEN PTR_FREE, self.rpc_mismatch_low
IF PTR_VALID (self.rpc_mismatch_high) THEN PTR_FREE, self.rpc_mismatch_high

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_mismatch__define


struct = {RPC_MISMATCH,                    $
          rpc_mismatch_low:  PTR_NEW (),   $
          rpc_mismatch_high: PTR_NEW ()    $
         }

RETURN

END

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_auth_error::xdr_reject_reason, xdr

IF NOT xdr->xdr_u_long (self.auth_error) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_auth_error::get_data

auth_error = *self.auth_error

RETURN, {auth_error: auth_error}

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_error::set_data, AUTH_ERROR = auth_error

IF N_ELEMENTS (auth_error) NE 0 THEN *self.auth_error = auth_error

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_auth_error::init, AUTH_ERROR = auth_error

IF N_ELEMENTS (auth_error) EQ 0 THEN BEGIN

   self.auth_error = PTR_NEW (0)

ENDIF ELSE BEGIN

   self.auth_error = PTR_NEW (auth_error)

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_error::cleanup

IF PTR_VALID (self.auth_error) THEN PTR_FREE, self.auth_error

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_error__define


struct = {RPC_AUTH_ERROR,                  $
          auth_error:  PTR_NEW ()          $
          }

RETURN

END

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_rejected_reply::xdr_reply_body, xdr

; Save the current value of reject_stat.

old_reject_stat = *self.reject_stat

; Attempt to XDR the reject_stat data item

IF NOT xdr->xdr_u_long (self.reject_stat) THEN RETURN, 0

; Check if the new value of reject_stat matches the previous value of reject.  If it does not,
; then we will have destroy the reject_reason object and then recreate it.

IF old_reject_stat NE *self.reject_stat THEN BEGIN

; Destroy the current reject_reason object if it exists.

   IF OBJECT_VALID (self.reject_reason) THEN BEGIN

      OBJ_DESTROY, self.reject_reason

      self.reject_reason = OBJ_NEW ()

   ENDIF

ENDIF

; Create a reject reason object based on the value of reject stat that we just read if one
; doesn't already exist.

IF NOT OBJ_VALID (self.reject_reason) THEN BEGIN

; Use the case statement to create the appropiate reject reason object.  Note, we are not
; passing it any parameters, just creating it.

   CASE *self.reject_stat OF

     self.RPC_MISMATCH:  self.reject_reason = OBJ_NEW ('RPC_MISMATCH')

     self.AUTH_ERROR:    self.reject_reason = OBJ_NEW ('RPC_AUTH_ERROR')

     ELSE:               BEGIN

                            PRINT, 'Unknown message rejection reason: Reason: ', self.reject_stat

                            *self.reject_stat = -1

                            RETURN, 0

                          END


   ENDCASE

; Check if the object creation succeded.  If it did not, then return 0

   IF NOT OBJ_VALID (self.reject_reason) THEN RETURN, 0

ENDIF

; XDR the reject_reason object.

IF NOT self.reject_reason->xdr_reject_reason (xdr) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_rejected_reply::get_data

reject_stat = *self.reject_stat

; Check if a valid reject reason object has been created.  If it has, get the data from the
; reject reason object and then fold in the data from this object.

IF OBJ_VALID (self.reject_reason) THEN BEGIN

   ds = self.reject_reason->get_data ()

   RETURN, CREATE_STRUCT ('reject_stat', reject_stat, ds)

ENDIF

; Otherwise, if the reject reason object doesn't exist, just return an anonymous structure
; containing the reject_stat data item.

RETURN, {reject_stat: reject_stat}

END

; ------------------------------------------------------------------------------------------------

PRO rpc_rejected_reply::set_data, REJECT_STAT = reject_stat, _EXTRA = ex

IF N_ELEMENTS (reject_stat) NE 0 THEN BEGIN

; Check if the reject status in ds object is the is same as the reject status in the
; current object.  If it is not, then we have go and recreate the reject_reason object

   IF *self.reject_stat NE reject_stat THEN BEGIN

; Check if there is currently a reject_reason object.  If there is, then we must get
; rid of it.

      IF OBJ_VALID (self.reject_reason) THEN BEGIN

         OBJ_DESTROY, self.reject_reason

         self.reject_reason = OBJ_NEW ()

      ENDIF

; Copy the rejected status into the appropiate field.

      *self.reject_stat = reject_stat

; Create an object appropiate the the reject status as the reject reason.

      CASE reject_stat OF

        self.RPC_MISMATCH:  self.reject_reason = OBJ_NEW ('RPC_MISMATCH')

        self.AUTH_ERROR:    self.reject_reason = OBJ_NEW ('RPC_AUTH_ERROR')

        ELSE:               BEGIN

                               PRINT, 'Unknown message rejection reason: Reason: ', reject_stat

                               *self.reject_stat = -1

                               RETURN

                             END


      ENDCASE

   ENDIF

ENDIF

; Try to pass any extra keywords to the reject reason object.

IF OBJ_VALID (self.reject_reason) THEN self.reject_reason->set_data, _EXTRA = ex

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_rejected_reply::init, REJECT_STAT = reject_stat, _EXTRA = ex

; Create the constants object.

cnst = OBJ_NEW ('RPC_CONSTANTS')

; Set local copies of constants used by this object

self.RPC_MISMATCH = cnst.RPC_MISMATCH
self.AUTH_ERROR   = cnst.AUTH_ERROR

; Get rid of the constants object

OBJ_DESTROY, cnst

IF N_ELEMENTS (reject_stat) EQ 0 THEN BEGIN

   self.reject_stat   = PTR_NEW (-1)
   self.reject_reason = OBJ_NEW ()

ENDIF ELSE BEGIN

; Copy the rejected status into the appropiate field.

   self.reject_stat = PTR_NEW (reject_stat)

; Create an object appropiate the the reject status as the reject reason.  Use any extra
; parameters from the call to this method in the creation of the new object.

   CASE reject_stat OF

     self.RPC_MISMATCH:  self.reject_reason = OBJ_NEW ('RPC_MISMATCH', _EXTRA = ex)

     self.AUTH_ERROR:    self.reject_reason = OBJ_NEW ('RPC_AUTH_ERROR', _EXTRA = ex)

     ELSE:               BEGIN

                            PRINT, 'Unknown message rejection reason: Reason: ', reject_stat

                            IF PTR_VALID (self.reject_stat) THEN PTR_FREE, self.reject_stat

                            RETURN, 0

                          END


   ENDCASE

; Make sure the child object creation succeeded.

   IF NOT OBJ_VALID (self.reject_reason) THEN RETURN, 0

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_rejected_reply::reset

IF OBJ_VALID (self.reject_reason) THEN OBJ_DESTROY, self.reject_reason

self.reject_reason = OBJ_NEW ()

*self.reject_stat  = -1

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_rejected_reply::cleanup

IF PTR_VALID (self.reject_stat)   THEN PTR_FREE,    self.reject_stat

IF OBJ_VALID (self.reject_reason) THEN OBJ_DESTROY, self.reject_reason

RETURN

END

; ------------------------------------------------------------------------------------------------

;       /*
;        * Reply to an RPC request that was rejected by the server:
;        * The request can be rejected for two reasons:  either the
;        * server is not running a compatible version of the RPC
;        * protocol (RPC_MISMATCH), or the server refuses to
;        * authenticate the caller (AUTH_ERROR).  In case of an RPC
;        * version mismatch, the server returns the lowest and highest
;        * supported RPC version numbers.  In case of refused
;        * authentication, failure status is returned.
;        */
;       union rejected_reply switch (reject_stat stat) {
;       case RPC_MISMATCH:
;          struct {
;             unsigned int low;
;             unsigned int high;
;
;          } mismatch_info;
;       case AUTH_ERROR:
;          auth_stat stat;
;       };

PRO rpc_rejected_reply__define

struct = {RPC_REJECTED_REPLY,                  $
          reject_stat:           PTR_NEW (),   $
          reject_reason:         OBJ_NEW (),   $
          RPC_MISMATCH:          0,            $
          AUTH_ERROR:            0             $
          }

RETURN

END

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_program_mismatch::xdr_data, xdr

IF NOT xdr->xdr_u_long (self.program_mismatch_low)  THEN RETURN, 0
IF NOT xdr->xdr_u_long (self.program_mismatch_high) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_program_mismatch::get_data

program_mismatch_low  = *self.program_mismatch_low
program_mismatch_high = *self.program_mismatch_high

RETURN, {program_mismatch_low:  program_mismatch_low,   $
         program_mismatch_high: program_mismatch_high   $
         }

END

; ------------------------------------------------------------------------------------------------

PRO rpc_program_mismatch::set_data, PROGRAM_MISMATCH_LOW  = program_mismatch_low,             $
                                    PROGRAM_MISMATCH_HIGH = program_mismatch_high


IF N_ELEMENTS (program_mismatch_low)  NE 0 THEN *self.program_mismatch_low  = program_mismatch_low
IF N_ELEMENTS (program_mismatch_high) NE 0 THEN *self.program_mismatch_high = program_mismatch_high

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_program_mismatch::init, PROGRAM_MISMATCH_LOW  = program_mismatch_low,             $
                                     PROGRAM_MISMATCH_HIGH = program_mismatch_high

IF N_ELEMENTS (program_mismatch_low)  EQ 0 THEN program_mismatch_low  = PTR_NEW (0)
IF N_ELEMENTS (program_mismatch_high) EQ 0 THEN program_mismatch_high = PTR_NEW (0)

self.program_mismatch_low  = PTR_NEW (program_mismatch_low)
self.program_mismatch_high = PTR_NEW (program_mismatch_high)

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_program_mismatch::cleanup

IF PTR_VALID (self.program_mismatch_low)  THEN PTR_FREE, self.program_mismatch_low
IF PTR_VALID (self.program_mismatch_high) THEN PTR_FREE, self.program_mismatch_high

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_program_mismatch__define


struct = {RPC_PROGRAM_MISMATCH,               $
          program_mismatch_low:  PTR_NEW (),  $
          program_mismatch_high: PTR_NEW ()   $
         }

RETURN

END

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_accepted_reply::xdr_reply_body, xdr

; Attempt to XDR the verf object

IF NOT OBJ_VALID (self.verf) THEN RETURN, 0

IF NOT self.verf->xdr_opaque_auth (xdr) THEN RETURN, 0

; Save the current value of reply_stat.

old_accept_stat = *self.accept_stat

; Attempt to XDR the accept_stat data item

IF NOT xdr->xdr_u_long (self.accept_stat) THEN RETURN, 0

; Check if the accept_stat value has changed, this may occur if we decoding
; values instead of encoding them.

IF old_accept_stat NE *self.accept_stat THEN BEGIN

; Check if the accept_data object exists.  If it does, then we have to delete it.

   IF OBJ_VALID (self.accept_data) THEN BEGIN

      OBJ_DESTROY, self.accept_data

      self.accept_data = OBJ_NEW ()

   ENDIF

ENDIF

; Use the case statement to create the appropiate accept_data object (if needed!).
; Note, we are not passing it any parameters, just creating it.

IF NOT OBJ_VALID (self.accept_data) THEN BEGIN

   CASE *self.accept_stat OF

     self.SUCCESS:       self.accept_data = OBJ_NEW ('RPC_DATA', DATA_TYPE = self.RPC_RECORD)

     self.PROG_MISMATCH: self.accept_data = OBJ_NEW ('RPC_PROGRAM_MISMATCH')

     self.PROG_UNAVAIL:  self.accept_data = OBJ_NEW ()
     self.PROC_UNAVAIL:  self.accept_data = OBJ_NEW ()
     self.GARBAGE_ARGS:  self.accept_data = OBJ_NEW ()

     ELSE:               BEGIN

        PRINT, 'Unknown message acceptance status: Status: ', accept_stat

        *self.accept_stat = -1

        RETURN, 0

     END


   ENDCASE

ENDIF

; XDR the accept_data object (if it exists).

IF OBJ_VALID (self.accept_data) THEN BEGIN

   IF NOT self.accept_data->xdr_data (xdr) THEN RETURN, 0

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_accepted_reply::get_data

accept_stat = *self.accept_stat

; Check if a valid verf (opaque authority) object exists.  If it does, then get the
; data from the object and store the structure in ds.

IF OBJ_VALID (self.verf) THEN BEGIN

   ds = self.verf->get_data ()

ENDIF

; Check if a valid accept_data object has been created.  If it has, get the data from the
; accept_data object and then fold it in with the data from the verf object (if needed).

IF OBJ_VALID (self.accept_data) THEN BEGIN

; Check if we got any data from the verf object.  If we did then the SIZE fucntion will
; return a data type other then 0.  In this case add the data from the accept_data object
; to our current data structure.  Otherwise, just start the data structure from scratch
; with the data from the accept_data structure.


   IF SIZE (ds, /TYPE) NE 0 THEN BEGIN

      ds = CREATE_STRUCT (self.accept_data->get_data (), ds)

   ENDIF ELSE BEGIN

      ds = self.accept_data->get_data ()

   ENDELSE

ENDIF

; OK, finishing up.  Check if got any data at all from the verf or accept data objects.  If
; we did, then add in the accept_stat tag and its value.

IF SIZE (ds, /TYPE) NE 0 THEN RETURN, CREATE_STRUCT ('ACCEPT_STAT', accept_stat, ds)

; Otherwise, just return an anonymous data structure contianing the accept_stat tag.  This
; should never happen in practice.

RETURN, {accept_stat: accept_stat}

END

; ------------------------------------------------------------------------------------------------

PRO rpc_accepted_reply::set_data, ACCEPT_STAT = accept_stat, _EXTRA = ex


IF N_ELEMENTS (accept_stat) NE 0 THEN BEGIN

; Check if the accept status passed as the keyword ACCEPT_STAT is the is same as
; the accept status in the  current object.  If it is not, or there is no accept status
; then we have go and recreate the accept data.

   IF *self.accept_stat NE accept_stat THEN BEGIN

; Check if there is currently a accept_data object.  If there is, then we must get
; rid of it.

      IF OBJ_VALID (self.accept_data) THEN BEGIN

         OBJ_DESTROY, self.accept_data
         self.accept_data = OBJ_NEW ()

      ENDIF

; Copy the accept status into the appropiate field.

      *self.accept_stat = accept_stat

; Create an object appropiate the accept status to hold the accept data (NOTE,
; depending on the accept status, this may not be neccessary.

      CASE accept_stat OF

        self.SUCCESS:       BEGIN    ; SUCCESS Reply.

; Get a list of tag names from the extra keywords structure.  These are all the keywords
; that were passed to this method that we did not process.

           tnames = TAG_NAMES (ex)

; Check if any of the extra keywords specify a data type or data value.

           dt = WHERE (tnames EQ "DATA_TYPE" OR tnames EQ "DATA_VALUE")

; If no keywords were passed specifing a data type or data value, then create the data object
; to contain an RPC Record.  This makes the RPC Record the defualt data type instead of the
; objects normal default data type which is NULL data.

           IF dt [0] EQ -1 THEN BEGIN

              self.accept_data = OBJ_NEW ('RPC_DATA', DATA_TYPE = self.RPC_RECORD)

           ENDIF ELSE BEGIN

              self.accept_data = OBJ_NEW ('RPC_DATA')

           ENDELSE

        END

        self.PROG_MISMATCH: BEGIN    ;  PROGRAM MISMATCH reply

           self.accept_data = OBJ_NEW ('RPC_PROGRAM_MISMATCH')

        END

        self.PROG_UNAVAIL:    self.accept_data = OBJ_NEW ()
        self.PROC_UNAVAIL:    self.accept_data = OBJ_NEW ()
        self.GARBAGE_ARGS:    self.accept_data = OBJ_NEW ()

        ELSE:               BEGIN

           PRINT, 'Unknown message acceptance status: Status: ', accept_stat

           *self.accept_stat = -1
           self.accept_data = OBJ_NEW ()

           RETURN

        END

      ENDCASE

   ENDIF

ENDIF

IF OBJ_VALID (self.accept_data) THEN self.accept_data->set_data, _EXTRA = ex

IF OBJ_VALID (self.verf) THEN self.verf->set_data, _EXTRA = ex

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_accepted_reply::init, ACCEPT_STAT = accept_stat,  _EXTRA = ex

; Create the constants object.

cnst = OBJ_NEW ('RPC_CONSTANTS')

; Get a local copy of all the constants.

c    = cnst->get_constants ()

; Get rid of the constants object

OBJ_DESTROY, cnst


; Set local copies of constants used by this object

self.SUCCESS          = c.SUCCESS
self.PROG_MISMATCH    = c.PROG_MISMATCH
self.PROG_UNAVAIL     = c.PROG_UNAVAIL
self.PROC_UNAVAIL     = c.PROC_UNAVAIL
self.GARBAGE_ARGS     = c.GARBAGE_ARGS
self.IDL_BYTE         = c.IDL_BYTE
self.IDL_INT          = c.IDL_INT
self.IDL_LONG         = c.IDL_LONG
self.IDL_FLOAT        = c.IDL_FLOAT
self.IDL_DOUBLE       = c.IDL_DOUBLE
self.IDL_COMPLEX      = c.IDL_COMPLEX
self.IDL_STRING       = c.IDL_STRING
self.IDL_STRUCT       = c.IDL_STRUCT
self.IDL_DCOMPLEX     = c.IDL_DCOMPLEX
self.IDL_POINTER      = c.IDL_POINTER
self.IDL_OBJREF       = c.IDL_OBJREF
self.IDL_UINT         = c.IDL_UINT
self.IDL_ULONG        = c.IDL_ULONG
self.IDL_LONG64       = c.IDL_LONG64
self.IDL_ULONG64      = c.IDL_ULONG64
self.IDL_NULL         = c.IDL_NULL
self.RPC_RECORD       = c.RPC_RECORD

IF N_ELEMENTS (accept_stat) EQ 0 THEN BEGIN

   self.accept_stat = PTR_NEW (-1)
   self.accept_data = OBJ_NEW ()

; Set up the opaque authority object

   self.verf = OBJ_NEW ('RPC_OPAQUE_AUTH', _EXTRA = ex)

   IF NOT OBJ_VALID (self.verf) THEN RETURN, 0

ENDIF ELSE BEGIN

; Set up the opaque authority object

   self.verf = OBJ_NEW ('RPC_OPAQUE_AUTH', _EXTRA = ex)

   IF NOT OBJ_VALID (self.verf) THEN RETURN, 0

; Copy the accept status into the appropiate field.

   self.accept_stat = PTR_NEW (accept_stat)

; Create accept data object if needed.  Creation of the accept data object depends on
; the accept status and any data specific keywords that were passed to this method.
; If the accept data object is created, then pass any additional keywords to it.

   CASE accept_stat OF

     self.SUCCESS:       BEGIN    ; SUCCESS Reply.

; Get a list of tag names from the extra keywords structure.  These are all the keywords
; that were passed to this method that we did not process.

       tnames = TAG_NAMES (ex)

; Check if any of the extra keywords specify a data type or data value.

       dt = WHERE (tnames EQ "DATA_TYPE" OR tnames EQ "DATA_VALUE")

; If no keywords were passed specifing a data type or data value, then create the data object
; to contain an RPC Record.  This makes the RPC Record the default data type instead of the
; objects normal default data type which is NULL data.

       IF dt [0] EQ -1 THEN BEGIN

          self.accept_data = OBJ_NEW ('RPC_DATA', _EXTRA = ex, DATA_TYPE = self.RPC_RECORD)

       ENDIF ELSE BEGIN

          self.accept_data = OBJ_NEW ('RPC_DATA', _EXTRA = ex)

       ENDELSE

     END

     self.PROG_MISMATCH: BEGIN    ;  PROGRAM MISMATCH reply

        self.accept_data = OBJ_NEW ('RPC_PROGRAM_MISMATCH', _EXTRA = ex)

     END

     self.PROG_UNAVAIL:    self.accept_data = OBJ_NEW ()
     self.PROC_UNAVAIL:    self.accept_data = OBJ_NEW ()
     self.GARBAGE_ARGS:    self.accept_data = OBJ_NEW ()

     ELSE:               BEGIN

        PRINT, 'Unknown message acceptance status: Status: ', accept_stat
        RETURN, 0

     END

   ENDCASE

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_accepted_reply::reset

*self.accept_stat = -1

IF OBJ_VALID (self.verf)        THEN self.verf->reset
IF OBJ_VALID (self.accept_data) THEN OBJ_DESTROY, self.accept_data

self.accept_data = OBJ_NEW ()

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_accepted_reply::cleanup


IF PTR_VALID (accept_stat)      THEN PTR_FREE, self.accept_stat


IF OBJ_VALID (self.verf)        THEN OBJ_DESTROY, self.verf
IF OBJ_VALID (self.accept_data) THEN OBJ_DESTROY, self.accept_data

RETURN

END

; ------------------------------------------------------------------------------------------------

;        * Reply to an RPC request that was accepted by the server:
;        * there could be an error even though the request was accepted.
;        * The first field is an authentication verifier that the server
;        * generates in order to validate itself to the caller.  It is
;        * followed by a union whose discriminant is an enum
;        * accept_stat.  The SUCCESS arm of the union is protocol
;        * specific.  The PROG_UNAVAIL, PROC_UNAVAIL, and GARBAGE_ARGS
;        * arms of the union are void.  The PROG_MISMATCH arm specifies
;        * the lowest and highest version numbers of the remote program
;        * supported by the server.
;        */
;       struct accepted_reply {
;          opaque_auth verf;
;          union switch (accept_stat stat) {
;          case SUCCESS:
;             opaque results[0];
;             /*
;              * procedure-specific results start here
;              */
;          case PROG_MISMATCH:
;              struct {
;                 unsigned int low;
;                 unsigned int high;
;              } mismatch_info;
;           default:
;              /*
;               * Void.  Cases include PROG_UNAVAIL, PROC_UNAVAIL,
;               * and GARBAGE_ARGS.
;               */
;              void;
;           } reply_data;
;       };

PRO rpc_accepted_reply__define


struct = {RPC_ACCEPTED_REPLY,               $
          verf:                OBJ_NEW (),  $
          accept_stat:         PTR_NEW (),  $
          accept_data:         OBJ_NEW (),  $
          SUCCESS:             0,           $
          PROG_MISMATCH:       0,           $
          PROG_UNAVAIL:        0,           $
          PROC_UNAVAIL:        0,           $
          GARBAGE_ARGS:        0,           $
          IDL_NULL:            0L,          $
          IDL_BYTE:            0L,          $
          IDL_INT:             0L,          $
          IDL_LONG:            0L,          $
          IDL_FLOAT:           0L,          $
          IDL_DOUBLE:          0L,          $
          IDL_COMPLEX:         0L,          $
          IDL_STRING:          0L,          $
          IDL_STRUCT:          0L,          $
          IDL_DCOMPLEX:        0L,          $
          IDL_POINTER:         0L,          $
          IDL_OBJREF:          0L,          $
          IDL_UINT:            0L,          $
          IDL_ULONG:           0L,          $
          IDL_LONG64:          0L,          $
          IDL_ULONG64:         0L,          $
          RPC_RECORD:          0L           $
          }


RETURN

END

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_reply_body::xdr_msg_body, xdr

; Save the current value of reply_stat.

old_reply_stat = *self.reply_stat

; Attempt to XDR the reply_stat data item

IF NOT xdr->xdr_u_long (self.reply_stat) THEN RETURN, 0

; Delete the current reply object if it exists  and it does not match the current
; value of reply_stat.

IF old_reply_stat NE *self.reply_stat THEN BEGIN

   IF OBJ_VALID (self.reply) THEN BEGIN

      OBJ_DESTROY, self.reply

      self.reply = OBJ_NEW ()

   ENDIF

ENDIF

; Create a reply object based on the value of reply_stat that we just read if one
; doesn't already exist.

IF NOT OBJ_VALID (self.reply) THEN BEGIN

; Use the case statement to create the appropiate reply object.  Note, we are not
; passing it any parameters, just creating it.

   CASE *self.reply_stat OF

     self.MSG_ACCEPTED:  self.reply = OBJ_NEW ('RPC_ACCEPTED_REPLY')

     self.MSG_DENIED:    self.reply = OBJ_NEW ('RPC_REJECTED_REPLY')

     ELSE:               BEGIN

                            PRINT, 'Unknown reply message status: Status: ', *self.reply_stat

                            *self.reply_stat = -1

                            RETURN, 0

                         END

   ENDCASE

; Check if the object creation succeded.  If it did not, then return 0

   IF NOT OBJ_VALID (self.reply) THEN RETURN, 0

ENDIF

; XDR the rest of the reply object object.

IF NOT self.reply->xdr_reply_body (xdr) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_reply_body::get_data

reply_stat = *self.reply_stat

; Check if a valid reply object has been created.  If it has, get the data from the
; reply object and then fold in the data from this object.

IF OBJ_VALID (self.reply) THEN BEGIN

   ds = self.reply->get_data ()

   RETURN, CREATE_STRUCT ('reply_stat', reply_stat, ds)

ENDIF

; Otherwise, if the reply object doesn't exist, just return an anonymous structure
; containing the reply_stat data item.

RETURN, {reply_stat: reply_stat}

END

; ------------------------------------------------------------------------------------------------

PRO rpc_reply_body::set_data, REPLY_STAT = reply_stat, _EXTRA = ex

IF N_ELEMENTS (reply_stat) NE 0 THEN BEGIN

; Check if the reply status in the keyword reply_stat is the is same as the reply status
; in the current object.  If it is not, then we have go and recreate the rest of the reply object.

   IF *self.reply_stat NE reply_stat THEN BEGIN

; Check if there is currently a reply object.  If there is, then we must get
; rid of it.

      IF OBJ_VALID (self.reply) THEN BEGIN

         OBJ_DESTROY, self.reply

         self.reply = OBJ_NEW ()

      ENDIF

; Copy the rejected status into the appropiate field.

      *self.reply_stat = reply_stat

; Create an object appropiate the the reply status as the body of the reply.

      CASE *reply_stat OF

        self.MSG_ACCEPTED:  self.reply = OBJ_NEW ('RPC_ACCEPTED_REPLY')

        self.MSG_DENIED:    self.reply = OBJ_NEW ('RPC_REJECTED_REPLY')

        ELSE:               BEGIN

                               PRINT, 'Unknown reply message status: Status: ', reply_stat

                               *self.reply_stat = -1

                               RETURN

                            END

      ENDCASE

   ENDIF

ENDIF

; Check if a reply object exists.  If it does, then pass any additional keywords to this object.

IF OBJ_VALID (self.reply) THEN self.reply->set_data, _EXTRA = ex

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_reply_body::init, REPLY_STAT = reply_stat, _EXTRA = ex

; Create the constants object.

cnst = OBJ_NEW ('RPC_CONSTANTS')

; Set local copies of constants used by this object

self.MSG_ACCEPTED  = cnst.MSG_ACCEPTED
self.MSG_DENIED    = cnst.MSG_DENIED

; Get rid of the constants object

OBJ_DESTROY, cnst

IF N_ELEMENTS (reply_stat) EQ 0 THEN BEGIN

   self.reply_stat  = PTR_NEW (-1)
   self.reply       = OBJ_NEW ()

ENDIF ELSE BEGIN

; Copy the reply status into the appropiate field.

   self.reply_stat = PTR_NEW (reply_stat)

; Create an object appropiate the the reply status as the rest of the reply..
; Use any extra parameters from the call to this method in the creation of
; the new object.

   CASE reply_stat OF

     self.MSG_ACCEPTED:  self.reply = OBJ_NEW ('RPC_ACCEPTED_REPLY', _EXTRA = ex)

     self.MSG_DENIED:    self.reply = OBJ_NEW ('RPC_REJECTED_REPLY', _EXTRA = ex)

     ELSE:               BEGIN

                            PRINT, 'Unknown reply message status: Status: ', reply_stat
                            RETURN, 0

                          END


   ENDCASE

; Make sure the child object creation succeeded.

   IF NOT OBJ_VALID (self.reply) THEN RETURN, 0

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_reply_body::reset

*self.reply_stat = -1

IF OBJ_VALID (self.reply) THEN OBJ_DESTROY, self.reply

self.reply = OBJ_NEW ()

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_reply_body::cleanup

IF PTR_VALID (self.reply_stat) THEN PTR_FREE, self.reply_stat

IF OBJ_VALID (self.reply) THEN OBJ_DESTROY, self.reply

RETURN

END

; ------------------------------------------------------------------------------------------------

;       /*
;       * Body of a reply to an RPC request:
;       * The call message was either accepted or rejected.
;       */
;      union reply_body switch (reply_stat stat) {
;      case MSG_ACCEPTED:
;         accepted_reply areply;
;      case MSG_DENIED:
;         rejected_reply rreply;
;      } reply;

PRO rpc_reply_body__define

struct = {RPC_REPLY_BODY,              $
          reply_stat:      PTR_NEW (), $
          reply:           OBJ_NEW (), $
          MSG_ACCEPTED:    0,          $
          MSG_DENIED:      0           $
          }

RETURN

END

; ------------------------------------------------------------------------------------------------