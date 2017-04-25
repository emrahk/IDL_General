; ------------------------------------------------------------------------------------------------

FUNCTION rpc_call_body::xdr_msg_body, xdr

;/*
; * Serializes the "static part" of a call message header.
; * The fields include: rm_xid, rm_direction, rpcvers, prog, and vers.
; * The rm_xid is not really static, but the user can easily munge on the fly.
; */
;bool_t xdr_callhdr(xdrs, cmsg)
;register XDR *xdrs;
;register struct rpc_msg *cmsg;
;{
;
;    cmsg->rm_direction = CALL;
;    cmsg->rm_call.cb_rpcvers = RPC_MSG_VERSION;
;    if (
;       (xdrs->x_op == XDR_ENCODE) &&
;       xdr_u_long(xdrs, &(cmsg->rm_xid)) &&
;       xdr_enum(xdrs, (enum_t *) & (cmsg->rm_direction)) &&
;       xdr_u_long(xdrs, &(cmsg->rm_call.cb_rpcvers)) &&
;       xdr_u_long(xdrs, &(cmsg->rm_call.cb_prog)))
;         return (xdr_u_long(xdrs, &(cmsg->rm_call.cb_vers)));
;    return (FALSE);
;

; Save old program, version, procedure numbers.

old_prog = *self.cb_prog
old_vers = *self.cb_vers
old_proc = *self.cb_proc

; XDR the static portion.

IF NOT xdr->xdr_u_long (self.cb_rpcvers) THEN RETURN, 0
IF NOT xdr->xdr_u_long (self.cb_prog) THEN RETURN, 0
IF NOT xdr->xdr_u_long (self.cb_vers) THEN RETURN, 0
IF NOT xdr->xdr_u_long (self.cb_proc) THEN RETURN, 0

IF NOT self.cb_cred->xdr_opaque_auth (xdr) THEN RETURN, 0
IF NOT self.cb_verf->xdr_opaque_auth (xdr) THEN RETURN, 0

; Check if the args object is router.  If it is, then we should check if the program, version
; or procedure number has changed.  In this case we pass these values as keyword parameters
; when we XDR the data object.

IF self.cb_args->is_router () THEN BEGIN

   IF *self.cb_prog NE old_prog OR                      $
      *self.cb_vers NE old_vers OR                      $
      *self.cb_proc NE old_proc THEN BEGIN

      RETURN, self.cb_args->xdr_data (xdr, RT_PROG = prog, RT_VERS = vers, RT_FUNC = proc)

   ENDIF

ENDIF

; Otherwise, just normally XDR the data object.

RETURN, self.cb_args->xdr_data (xdr)

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_call_body::get_data

; Get the data from the cb_cred opaque authority

cb_cred = self.cb_cred->get_data ()

; Get the data from the cb_verf opaque authority

cb_verf = self.cb_verf->get_data ()

; Get the data from the data object

ds = self.cb_args->get_data ()

RETURN, CREATE_STRUCT   ('cb_rpcvers', *self.cb_rpcvers,         $
                         'cb_prog',    *self.cb_prog,            $
                         'cb_vers',    *self.cb_vers,            $
                         'cb_proc',    *self.cb_proc,            $
                         'cb_cred',    cb_cred,                  $
                         'cb_verf',    cb_verf,                  $
                         ds                                      $
                         )

END

; ------------------------------------------------------------------------------------------------

PRO rpc_call_body::set_data,  CB_PROG = prog,                    $
                              CB_VERS = vers,                    $
                              CB_PROC = proc,                    $
                              CB_CRED = cb_cred,                 $
                              CB_VERF = cb_verf,                 $
                              SET_RPC_VERS = set_rpc_vers,       $
                              AUTH_TYPE = at,                    $
                              _EXTRA = ex


; Check if the set_rpc_vers flag has been passed to us.  If it has, then set
; set rpc version to whatever the current version is.

IF KEYWORD_SET (set_rpc_vers) THEN *self.cb_rpcvers = self.RPC_MSG_VERSION

; Save old program, version, procedure numbers.

old_prog = *self.cb_prog
old_vers = *self.cb_vers
old_proc = *self.cb_proc

; Copy the new program, version and procedure numbers into the message, if they exist.

IF N_ELEMENTS (prog) THEN *self.cb_prog = prog
IF N_ELEMENTS (vers) THEN *self.cb_vers = vers
IF N_ELEMENTS (proc) THEN *self.cb_proc = proc

; Check if the args object is router.  If it is, then we should check if the program, version
; or procedure number has changed.

IF self.cb_args->is_router () THEN BEGIN

   IF *self.cb_prog NE old_prog OR                      $
      *self.cb_vers NE old_vers OR                      $
      *self.cb_proc NE old_proc THEN BEGIN

      self.cb_args->set_data, RT_PROG = *self.cb_prog,  $
                              RT_VERS = *self.cb_vers,  $
                              RT_FUNC = *self.cb_proc

   ENDIF

ENDIF

; Now we just pass any extra arguments to the data object

self.cb_args->set_data, _EXTRA = ex

IF KEYWORD_SET (set_rpc_vers) THEN *self.cb_rpcvers = self.RPC_MSG_VERSION

; Check if the users requested a specific authenication method when call message
; was created if they did, we can help them out by creating the correct credential and
; verificaion objects.

IF N_ELEMENTS (at)  NE 0 THEN BEGIN

   SWITCH at OF

      self.AUTH_NULL  :
      'NULL'          : BEGIN

         self.cb_cred->set_data, FLAVOR = self.AUTH_NULL
         self.cb_verf->set_data, FLAVOR = self.AUTH_NULL

         BREAK

         END

      self.AUTH_UNIX  :
      'UNIX'          : BEGIN

         PRINT, 'Unix athentication is not yet implemented.'

         BREAK

         END

      cnst.AUTH_SHORT :
      'SHORT'         : BEGIN

         PRINT, 'Short athentication is not yet implemented.'

         BREAK

         END

      cnst.AUTH_DES   :
      'DES'           : BEGIN

         PRINT, 'DES athentication is not yet implemented.'

         BREAK

         END

      ELSE            : BEGIN

         PRINT, 'Unknown authentication type requested. Type: ', at

         BREAK

         END

   ENDSWITCH

ENDIF ELSE BEGIN


; If the cb_cred keyword is defined and is a structure, then we pass it to the cb_cred
; opaque authority.

   IF N_ELEMENTS (cb_cred) NE 0 AND SIZE (cb_cred, /TYPE) EQ 8 THEN BEGIN

      self.cb_cred->set_data, _EXTRA = cb_cred

   ENDIF

; If the cb_verf keyword is defined and is a structure, then we pass it to the cb_verf
; opaque authority.

   IF N_ELEMENTS (cb_verf) NE 0 AND SIZE (cb_verf, /TYPE) EQ 8 THEN BEGIN

      self.cb_verf->set_data, _EXTRA = cb_verf

   ENDIF

ENDELSE

RETURN

END


; ------------------------------------------------------------------------------------------------

FUNCTION rpc_call_body::init, CB_PROG = prog,                    $
                              CB_VERS = vers,                    $
                              CB_PROC = proc,                    $
                              CB_CRED = cb_cred,                 $
                              CB_VERF = cb_verf,                 $
                              AUTH_TYPE = at,                    $
                              SET_RPC_VERS = set_rpc_vers,       $
                              STATIC  = static,                  $
                              IDL_RPC_ID = idl_rpc_id,           $
                              _EXTRA = ex

;   /*
;    * Initialize call message
;    */
;   (void) gettimeofday(&now, (struct timezone *) 0);
;   call_msg.rm_xid = getpid() ^ now.tv_sec ^ now.tv_usec;
;   call_msg.rm_direction = CALL;
;   call_msg.rm_call.cb_rpcvers = RPC_MSG_VERSION;
;   call_msg.rm_call.cb_prog = prog;
;   call_msg.rm_call.cb_vers = vers;

cnst = OBJ_NEW ('RPC_CONSTANTS')

self.AUTH_NULL       = cnst.AUTH_NULL
self.AUTH_UNIX       = cnst.AUTH_UNIX
self.AUTH_SHORT      = cnst.AUTH_SHORT
self.AUTH_DES        = cnst.AUTH_DES
self.RPC_MSG_VERSION = cnst.RPC_MSG_VERSION

OBJ_DESTROY, cnst

target_defined = N_ELEMENTS (prog) + N_ELEMENTS (vers) + N_ELEMENTS (proc) GT 0

IF N_ELEMENTS (prog) EQ 0 THEN prog = 0L
IF N_ELEMENTS (vers) EQ 0 THEN vers = 0L
IF N_ELEMENTS (proc) EQ 0 THEN proc = 0L

self.cb_prog      =   PTR_NEW (prog)
self.cb_vers      =   PTR_NEW (vers)
self.cb_proc      =   PTR_NEW (proc)
self.cb_rpcvers   =   PTR_NEW (0)
self.cb_cred      =   OBJ_NEW ()
self.cb_verf      =   OBJ_NEW ()

; Check if the set_rpc_vers flag has been passed to us.  If it has, then set
; set rpc version to whatever the current version is.

IF KEYWORD_SET (set_rpc_vers) THEN *self.cb_rpcvers = self.RPC_MSG_VERSION

; Check if the users requested a specific authenication method when call message
; was created if they did, we can help them out by creating the correct credential and
; verificaion objects.

IF N_ELEMENTS (at)  NE 0 THEN BEGIN

   SWITCH at OF

      self.AUTH_NULL  :
      'NULL'          : BEGIN

         self.cb_cred   = OBJ_NEW ('RPC_OPAQUE_AUTH', FLAVOR = self.AUTH_NULL)
         self.cb_verf   = OBJ_NEW ('RPC_OPAQUE_AUTH', FLAVOR = self.AUTH_NULL)

         BREAK

         END

      self.AUTH_UNIX  :
      'UNIX'          : BEGIN

         PRINT, 'Unix athentication is not yet implemented.'
         RETURN, 0

         BREAK

         END

      cnst.AUTH_SHORT :
      'SHORT'         : BEGIN

         PRINT, 'Short athentication is not yet implemented.'
         RETURN, 0

         BREAK

         END

      cnst.AUTH_DES   :
      'DES'           : BEGIN

         PRINT, 'DES athentication is not yet implemented.'
         RETURN, 0

         BREAK

         END

      ELSE            : BEGIN

         PRINT, 'Unknown authentication type requested. Type: ', at
         RETURN, 0

         BREAK

         END

   ENDSWITCH

ENDIF ELSE BEGIN

; Otherwise, just create two generic opaque authority objects and pass them any
; keywords that were passed to us.

   self.cb_cred = OBJ_NEW ('RPC_OPAQUE_AUTH', _EXTRA = cb_cred)
   self.cb_verf = OBJ_NEW ('RPC_OPAQUE_AUTH', _EXTRA = cb_verf)

ENDELSE

; Make sure the authority objects were created sucessfully.

IF NOT OBJ_VALID (self.cb_cred) THEN RETURN, 0
IF NOT OBJ_VALID (self.cb_verf) THEN RETURN, 0

; Check if we were passed a program, version or function number.  This will affect how
; we handle the initilization of the args block

IF target_defined THEN BEGIN

   ; Check if the static flag is set.  If it is, then use the RPC_MESSAGE_ROUTER to create a
   ; call args block.

   IF KEYWORD_SET (static) THEN BEGIN

      router = OBJ_NEW ('RPC_MESSAGE_ROUTER', IDL_RPC_ID = idl_rpc_id)

      self.cb_args = router->get_call_data_obj (prog, vers, proc)

      self.cb_args->set_data, _EXTRA = ex


   ENDIF ELSE BEGIN

   ; Otherwise use the router as the args block.

      self.cb_args = OBJ_NEW ('RPC_MESSAGE_ROUTER', RT_PROG = prog,               $
                                                    RT_VERS = vers,               $
                                                    RT_FUNC = proc,               $
                                                    IDL_RPC_ID = idl_rpc_id,      $
                                                    _EXTRA = ex)

   ENDELSE

ENDIF ELSE BEGIN

   self.cb_args = OBJ_NEW ('RPC_MESSAGE_ROUTER', IDL_RPC_ID = idl_rpc_id, _EXTRA = ex)

ENDELSE

; Make sure the args block is valid

IF NOT OBJ_VALID (self.cb_args) THEN RETURN, 0

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_call_body::reset

IF OBJ_VALID (self.cb_cred)      THEN self.cb_cred->reset
IF OBJ_VALID (self.cb_verf)      THEN self.cb_verf->reset

IF OBJ_VALID (self.cb_args)      THEN self.cb_args->reset

IF PTR_VALID (self.cb_prog)      THEN *self.cb_prog = 0L
IF PTR_VALID (self.cb_vers)      THEN *self.cb_vers = 0L
IF PTR_VALID (self.cb_proc)      THEN *self.cb_proc = 0L

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_call_body::cleanup

IF OBJ_VALID (self.cb_cred)      THEN OBJ_DESTROY, self.cb_cred
IF OBJ_VALID (self.cb_verf)      THEN OBJ_DESTROY, self.cb_verf
IF OBJ_VALID (self.cb_args)      THEN OBJ_DESTROY, self.cb_args

IF PTR_VALID (self.cb_rpcvers)   THEN PTR_FREE, self.cb_rpcvers
IF PTR_VALID (self.cb_prog)      THEN PTR_FREE, self.cb_prog
IF PTR_VALID (self.cb_vers)      THEN PTR_FREE, self.cb_vers
IF PTR_VALID (self.cb_proc)      THEN PTR_FREE, self.cb_proc

RETURN

END


PRO rpc_call_body::cleanup

IF OBJ_VALID (self.cb_cred)      THEN OBJ_DESTROY, self.cb_cred
IF OBJ_VALID (self.cb_verf)      THEN OBJ_DESTROY, self.cb_verf
IF OBJ_VALID (self.cb_args)      THEN OBJ_DESTROY, self.cb_args

IF PTR_VALID (self.cb_rpcvers)   THEN PTR_FREE, self.cb_rpcvers
IF PTR_VALID (self.cb_prog)      THEN PTR_FREE, self.cb_prog
IF PTR_VALID (self.cb_vers)      THEN PTR_FREE, self.cb_vers
IF PTR_VALID (self.cb_proc)      THEN PTR_FREE, self.cb_proc

RETURN

END

; ------------------------------------------------------------------------------------------------


PRO rpc_call_body__define

;/*
; * Body of an rpc request call.
; */
;struct call_body {
;   u_int cb_rpcvers; /* must be equal to two */
;   u_int cb_prog;
;   u_int cb_vers;
;   u_int cb_proc;
;   struct opaque_auth cb_cred;
;   struct opaque_auth cb_verf; /* protocol specific - provided by client */
;};


struct =  {RPC_CALL_BODY,                     $
           cb_rpcvers:     PTR_NEW (),        $
           cb_prog:        PTR_NEW (),        $
           cb_vers:        PTR_NEW (),        $
           cb_proc:        PTR_NEW (),        $
           cb_cred:        OBJ_NEW (),        $
           cb_verf:        OBJ_NEW (),        $
           cb_args:        OBJ_NEW (),        $
           RPC_MSG_VERSION:0L,                $
           AUTH_NULL:      0L,                $
           AUTH_UNIX:      0L,                $
           AUTH_SHORT:     0L,                $
           AUTH_DES:       0L                 $
          }

RETURN

END
