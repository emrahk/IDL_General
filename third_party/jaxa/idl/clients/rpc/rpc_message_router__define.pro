; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::is_router

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::get_call_data_obj, prog, vers, func

ind = self->get_router_index (prog, vers, func)

IF ind EQ 0 THEN RETURN, OBJ_NEW ()

val = (*self.call_value) [ind]

IF val EQ PTR_NEW () THEN RETURN, OBJ_NEW ('RPC_DATA', data_type = self.IDL_NULL)

RETURN, OBJ_NEW ('RPC_DATA', DATA_VALUE = *val)

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::get_reply_data_obj, prog, vers, func

ind = self->get_router_index (prog, vers, func)

IF ind EQ 0 THEN RETURN, OBJ_NEW ()

val = (*self.reply_value) [ind]

IF val EQ PTR_NEW () THEN RETURN, OBJ_NEW ('RPC_DATA', DATA_TYPE = self.IDL_NULL)

RETURN, OBJ_NEW ('RPC_DATA', DATA_VALUE = *val)

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::get_router_index, prog, vers, func

IF NOT KEYWORD_SET (prog) THEN RETURN, 0

IF NOT KEYWORD_SET (vers) THEN vers = 0

IF NOT KEYWORD_SET (func) THEN func = 0

FOR i = 0, self.tblsize - 1 DO BEGIN

   IF prog EQ (*self.router) [0, i] AND                      $
      vers EQ (*self.router) [1, i] AND                      $
      func EQ (*self.router) [2, i] THEN RETURN, i

ENDFOR

RETURN, 0

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::get_router_triple, index

triple = {RT_PROG: 0L, RT_VERS: 0L, RT_FUNC: 0L}

IF index GT self.tblsize - 1 THEN RETURN, triple

triple.rt_prog = (*self.router) [0, index]
triple.rt_vers = (*self.router) [1, index]
triple.rt_func = (*self.router) [2, index]

RETURN, triple

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::call_value_from_index_changed, index

IF index GT self.tblsize - 1 THEN RETURN, "VOID"

val = (*self.call_value) [index]

IF val EQ PTR_NEW () THEN RETURN, "NULL" ELSE RETURN, *val

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::reply_value_from_index_changed, index

IF index GT self.tblsize - 1 THEN RETURN, "VOID"

val = (*self.reply_value) [index]

IF val EQ PTR_NEW () THEN RETURN, "NULL" ELSE RETURN, *val

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::get_call_value, prog, vers, func

val = self->call_value_from_index (self->get_router_index (prog, vers, func))

RETURN, val

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::get_reply_value, prog, vers, func

val = self->reply_value_from_index (self->get_router_index (prog, vers, func))

RETURN, val

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::xdr_data, xdr, RT_PROG = prog, RT_VERS = vers, RT_FUNC = func

; Set the reset flag.  The reset flag should be set if any of the keywords were passed to
; us as parameters.

reset = (N_ELEMENTS (prog) + N_ELEMENTS (vers) + N_ELEMENTS (func)) GT 0

IF reset THEN BEGIN

; Find the table index that corresponds to the program, version and function that was passed to
; us as a parameter.

   ind = get_router_index (prog, vers, func)

; Check for a zero return.  this indicates that we could not find a table index that corresponds
; to the values that were passed to us.

   IF ind EQ 0 THEN RETURN, 0

; Get the call value from the call value table.

   val = (*self.call_value) [ind]

; Check for a null ptr.  If it is then set the data object to a null value.

   IF *val EQ PTR_NEW () THEN BEGIN

      self->rpc_data::set_data, DATA_TYPE = self.IDL_NULL

   ENDIF ELSE BEGIN

; Otherwise, set the data object to whater value was returned from the call table

      IF SIZE (*val, /TYPE) EQ self.IDL_STRUCT THEN BEGIN

         self->rpc_data::set_data, DATA_VALUE = *val

      ENDIF ELSE BEGIN

         self->rpc_data::set_data, DATA_TYPE = SIZE (*val, /TYPE)

      ENDELSE

   ENDELSE

ENDIF

; Return the result of the xdr_data method from the data object.

RETURN, self->rpc_data::xdr_data (xdr)

END

; ------------------------------------------------------------------------------------------------

PRO rpc_message_router::set_data, RT_PROG = prog,        $
                                  RT_VERS = vers,        $
                                  RT_FUNC = func,        $
                                  REPLY = reply,         $
                                  _EXTRA = ex

; Set the set_data flag.  The set_data flag should be set if any of the keywords were passed to
; us as parameters.


set_data = (N_ELEMENTS (prog) + N_ELEMENTS (vers) + N_ELEMENTS (func)) GT 0

; Call set_data method of the data object that we superclass.  If the set_data flag is set, then
; we will set a specific data_value.

IF set_data THEN BEGIN

; Find the table index that corresponds to the program, version and function that was passed to
; us as a parameter.

   ind = self->get_router_index (prog, vers, func)

; Process a reply data object.

   IF KEYWORD_SET (reply) THEN BEGIN

; Get the reply value from the reply value table.

      val = (*self.reply_value) [ind]

   ENDIF ELSE BEGIN

; Otherwise we are processing a call data object.  This is the default.
; Get the call value from the call value table.

      val = (*self.call_value) [ind]

   ENDELSE

; Check for a NULL data value.  Otherwise pass the datavalue directly to the data object.

   IF val EQ PTR_NEW () THEN BEGIN

      self->rpc_data::set_data, DATA_TYPE = self.IDL_NULL

   ENDIF ELSE BEGIN

      IF SIZE (*val, /TYPE) EQ self.IDL_STRUCT THEN BEGIN

         self->rpc_data::set_data, DATA_VALUE = *val, _EXTRA = ex

      ENDIF ELSE BEGIN

         self->rpc_data::set_data, DATA_TYPE = SIZE (*val, /TYPE), _EXTRA = ex

      ENDELSE

   ENDELSE

ENDIF ELSE BEGIN

; Just pass any unused parameters to the data object that we superclassed.

   self->rpc_data::set_data, _EXTRA = ex

ENDELSE

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_message_router::init,  RT_PROG = prog,                 $
                                    RT_VERS = vers,                 $
                                    RT_FUNC = func,                 $
                                    REPLY = reply,                  $
                                    IDL_RPC_ID = idl_rpc_id,        $
                                    _EXTRA = ex

; Set the table size to 100

self.tblsize = 100

IF NOT KEYWORD_SET (idl_rpc_id) THEN idl_rpc_id = '2010CAFE'X

; Create the tables

self.router      = PTR_NEW (LONARR (3, self.tblsize))
self.call_value  = PTR_NEW (PTRARR (self.tblsize))
self.reply_value = PTR_NEW (PTRARR (self.tblsize))

; Set up the rounter table

(*self.router) [*, 0]  = [0, 0, 0]
(*self.router) [*, 1]  = [100000, 2, 0]
(*self.router) [*, 2]  = [100000, 2, 3]
(*self.router) [*, 3]  = [idl_rpc_id, 1, 0]
(*self.router) [*, 4]  = [idl_rpc_id, 1, '10'X]
(*self.router) [*, 5]  = [idl_rpc_id, 1, '20'X]
(*self.router) [*, 6]  = [idl_rpc_id, 1, '30'X]
(*self.router) [*, 7]  = [idl_rpc_id, 1, '40'X]
(*self.router) [*, 8]  = [idl_rpc_id, 1, '50'X]
(*self.router) [*, 9]  = [idl_rpc_id, 1, '60'X]
(*self.router) [*, 10]  = [idl_rpc_id, 1, '70'X]
(*self.router) [*, 11] = [idl_rpc_id, 1, '90'X]

; Set up the call handle table

(*self.call_value) [0]  = PTR_NEW ()
(*self.call_value) [1]  = PTR_NEW ()
(*self.call_value) [2]  = PTR_NEW ({prog: 0L, vers: 0L, prot: 0L, port: 0L})
(*self.call_value) [3]  = PTR_NEW ()
(*self.call_value) [4]  = PTR_NEW ()
(*self.call_value) [5]  = PTR_NEW ('STRING')
(*self.call_value) [6]  = PTR_NEW ()
(*self.call_value) [7]  = PTR_NEW ()
(*self.call_value) [8]  = PTR_NEW ('STRING')
(*self.call_value) [9]  = PTR_NEW (0S)
(*self.call_value) [10] = PTR_NEW (0S)
(*self.call_value) [11] = PTR_NEW ()

; Set up the reply handle table

(*self.reply_value) [0]  = PTR_NEW ()
(*self.reply_value) [1]  = PTR_NEW ()
(*self.reply_value) [2]  = PTR_NEW (0L)
(*self.reply_value) [3]  = PTR_NEW ()
(*self.reply_value) [4]  = PTR_NEW ()
(*self.reply_value) [5]  = PTR_NEW (0B)
(*self.reply_value) [6]  = PTR_NEW ()
(*self.reply_value) [7]  = PTR_NEW ()
(*self.reply_value) [8]  = PTR_NEW (0S)
(*self.reply_value) [9]  = PTR_NEW (0S)
(*self.reply_value) [10] = PTR_NEW ({flags: 0L, buf: 'STRING'})
(*self.reply_value) [11] = PTR_NEW ()

; Set the init_data flag.  The init_data flag should be set if any of the keywords were passed to
; us as parameters.

init_data = (N_ELEMENTS (prog) + N_ELEMENTS (vers) + N_ELEMENTS (func)) GT 0

; Initialize the data object that we superclass.  If the init_data flag is set, then we will
; initialize the object with an actual value.

IF init_data THEN BEGIN

; Find the table index that corresponds to the program, version and function that was passed to
; us as a parameter.

   ind = self->get_router_index (prog, vers, func)

; Check for a zero return.  this indicates that we could not find a table index that corresponds
; to the values that were passed to us.

   IF ind EQ 0 THEN RETURN, 0

; Process a reply data object.

   IF KEYWORD_SET (reply) THEN BEGIN

; Get the reply value from the reply value table.

      val = (*self.reply_value) [ind]

   ENDIF ELSE BEGIN

; Otherwise we are processing a call data object.  This is the default.
; Get the call value from the call value table.

      val = (*self.call_value) [ind]

   ENDELSE

; Check for a NULL data value.  Otherwise pass the datavalue directly to the data object and return
; the result of its initialization.

   IF val EQ PTR_NEW () THEN BEGIN

      RETURN, self->rpc_data::init (DATA_TYPE = self.IDL_NULL)

   ENDIF ELSE BEGIN

      IF SIZE (*val, /TYPE) EQ self.IDL_STRUCT THEN BEGIN

         RETURN, self->rpc_data::init ( DATA_VALUE = *val, _EXTRA = ex )

      ENDIF ELSE BEGIN

         RETURN, self->rpc_data::init ( DATA_TYPE = SIZE (*val, /TYPE), _EXTRA = ex )

      ENDELSE

   ENDELSE

ENDIF ELSE BEGIN

; Just initialize the data object with no parameters, since we were not passed any parameters.

   RETURN, self->rpc_data::init (_EXTRA = ex)

ENDELSE

END

; ------------------------------------------------------------------------------------------------

PRO rpc_message_router::cleanup

self->rpc_data::cleanup

IF PTR_VALID (self.router)      THEN PTR_FREE, self.router
IF PTR_VALID (self.call_value)  THEN PTR_FREE, self.call_value
IF PTR_VALID (self.reply_value) THEN PTR_FREE, self.reply_value

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_message_router__define

struct = {RPC_MESSAGE_ROUTER,           $
          router:         PTR_NEW (),   $
          call_value:     PTR_NEW (),   $
          reply_value:    PTR_NEW (),   $
          tblsize:        0,            $
          INHERITS        RPC_DATA      $
          }

RETURN

END