;/*
; * Authentication info.  Opaque to client.
; */

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_auth_base::xdr_auth_body, xdr


RETURN, xdr->xdr_bytes (self.key_data, self.key_length, self.max_auth_bytes)

END


; ------------------------------------------------------------------------------------------------

FUNCTION rpc_auth_base::get_data

IF *self.key_length GT 0 THEN BEGIN

   RETURN, {key_length: *self.key_length, key_data: *self.key_data}

ENDIF ELSE BEGIN

   RETURN, {key_length: *self.key_length}

ENDELSE

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_base::set_data, KEY_LENGTH = key_length, KEY_DATA = key_data

IF N_ELEMENTS (key_data) NE 0 THEN BEGIN

   key_data = BYTE (key_data)

   key_length = N_ELEMENTS (key_data)

   *self.key_data   = key_data
   *self.key_length = key_length

   RETURN

ENDIF

IF N_ELEMENTS (key_length) NE 0 THEN BEGIN

   IF key_length EQ 0 THEN BEGIN

      *self.key_data   = 0
      *self.key_length = 0

   ENDIF ELSE BEGIN

      *self.key_data   = BYTARR (key_length)
      *self.key_length = key_length

   ENDELSE

   RETURN

ENDIF

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_auth_base::init, KEY_LENGTH = key_length, KEY_DATA = key_data

self.key_length = PTR_NEW (0)
self.key_data   = PTR_NEW (0)

IF N_ELEMENTS (key_length) NE 0 THEN *self.key_length = key_length
IF N_ELEMENTS (key_data)   NE 0 THEN *self.key_data   = key_data

self.max_auth_bytes = 400

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_base::cleanup

IF PTR_VALID (self.key_length) THEN PTR_FREE, self.key_length
IF PTR_VALID (self.key_data)   THEN PTR_FREE, self.key_data

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_base::reset

*self.key_length = 0
*self.key_data   = 0

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_auth_base__define

struct = {RPC_AUTH_BASE,               $
          key_length:     PTR_NEW (),  $
          key_data:       PTR_NEW (),  $
          max_auth_bytes: 0UL          $
          }

RETURN

END

; ------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------

FUNCTION rpc_opaque_auth::xdr_opaque_auth, xdr

;/*
; * XDR an opaque authentication struct
; * (see auth.h)
; */
;bool_t xdr_opaque_auth(xdrs, ap)
;register XDR *xdrs;
;register struct opaque_auth *ap;
;{
;
;    if (xdr_enum(xdrs, &(ap->oa_flavor)))
;       return (xdr_bytes(xdrs, &ap->oa_base,
;                   &ap->oa_length, MAX_AUTH_BYTES));
;    return (FALSE);
;}

; Save the current authority flavor in old_auth_flavor

old_auth_flavor = *self.flavor

; XDR the the flavor.

IF NOT xdr->xdr_enum (*self.flavor) THEN RETURN, 0

; Check if the the authority flavor has changed.  If it has then we may have to create a new
; authority body

IF *self.flavor NE old_auth_flavor THEN BEGIN

; Get rid of the current body object, if it exists.

   IF OBJ_VALID (self.body) THEN BEGIN

      OBJ_DESTROY, self.body

      self.body = OBJ_NEW ()

   ENDIF

ENDIF

; Check if the authority body object exists.  If it does not, then we will have to create it.

IF NOT OBJ_VALID (self.body) THEN BEGIN

   CASE *self.flavor OF

      self.AUTH_NULL  : self.body = OBJ_NEW ('RPC_AUTH_BASE')

      self.AUTH_UNIX  : BEGIN

         PRINT, 'Unix athentication is not yet implemented.'

         *self.flavor = -1

         RETURN, 0

         END

      self.AUTH_SHORT : BEGIN

         PRINT, 'Short athentication is not yet implemented.'

         *self.flavor = -1

         RETURN, 0

         END

      self.AUTH_DES   : BEGIN

         PRINT, 'DES athentication is not yet implemented.'

         *self.flavor = -1

         RETURN, 0

         END

      ELSE            : BEGIN

         PRINT, 'Unknown authentication type requested. Type: ', *self.flavor

         *self.flavor = -1

         RETURN, 0

         END

   ENDCASE

ENDIF

RETURN, self.body->xdr_auth_body (xdr)

END

; ------------------------------------------------------------------------------------------------

PRO rpc_opaque_auth::set_data, FLAVOR = flavor, _EXTRA = ex

;
; This method allows you to set various properties of the object via input keywords.
;

; Check if a message flavor wass passed to us.

IF N_ELEMENTS (flavor) NE 0 THEN BEGIN

; If it was, then check if the new message flavor is different the old message flavor

   IF *self.flavor NE flavor THEN BEGIN

; Get rid of the old authority body, if it exists..

      IF OBJ_VALID (self.body) THEN BEGIN

         OBJ_DESTROY, self.body

         self.body = OBJ_NEW ()

      ENDIF

; Copy the new flavor into the object

      *self.flavor = flavor

; Create an authority body appropiate to the flavor

      CASE  *self.flavor OF

        self.AUTH_NULL  : self.body = OBJ_NEW ('RPC_AUTH_BASE')

        self.AUTH_UNIX  : BEGIN

           PRINT, 'Unix athentication is not yet implemented.'

           *self.flavor = -1

           RETURN

           END

        self.AUTH_SHORT : BEGIN

           PRINT, 'Short athentication is not yet implemented.'

           *self.flavor = -1

           RETURN

           END

        self.AUTH_DES   : BEGIN

           PRINT, 'DES athentication is not yet implemented.'

           *self.flavor = -1

           RETURN

           END

         ELSE            : BEGIN

           PRINT, 'Unknown authentication type requested. Type: ', *self.flavor

           *self.flavor = -1

           RETURN

           END

      ENDCASE

   ENDIF

ENDIF

; Pass any unused parameters to the authority body, if it exists.

IF OBJ_VALID (self.body) THEN self.body->set_data, _EXTRA = ex

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_opaque_auth::get_data

IF OBJ_VALID (self.body) THEN BEGIN

   RETURN, CREATE_STRUCT ('flavor', *self.flavor, self.body->get_data ())

ENDIF ELSE BEGIN

   RETURN, {flavor: *self.flavor}

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_opaque_auth::init, FLAVOR = flavor, _EXTRA = ex

cnst = OBJ_NEW ('RPC_CONSTANTS')

self.AUTH_NULL       = cnst.AUTH_NULL
self.AUTH_UNIX       = cnst.AUTH_UNIX
self.AUTH_SHORT      = cnst.AUTH_SHORT
self.AUTH_DES        = cnst.AUTH_DES

OBJ_DESTROY, cnst

; Set some default values.

self.flavor = PTR_NEW (-1)
self.body   = OBJ_NEW ()

; Check if the authority flavor is defined.   If it is, then create an
; authority body based the flavor that was passed to us.

IF N_ELEMENTS (flavor) NE 0 THEN BEGIN

   SWITCH flavor OF

      self.AUTH_NULL  :
      'NULL'          : BEGIN

         *self.flavor = self.AUTH_NULL
         self.body   = OBJ_NEW ('RPC_AUTH_BASE', _EXTRA = ex)

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

; Make sure that the authority body creation succeeded.

   IF NOT OBJ_VALID (self.body) THEN RETURN, 0

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_opaque_auth::cleanup

IF PTR_VALID (self.flavor) THEN PTR_FREE, self.flavor

IF OBJ_VALID (self.body)   THEN OBJ_DESTROY, self.body

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_opaque_auth::reset

*self.flavor = -1

IF OBJ_VALID (self.body) THEN OBJ_DESTROY, self.body

RETURN

END

; ------------------------------------------------------------------------------------------------

;struct opaque_auth {
;   enum_t    oa_flavor;     /* flavor of auth */
;   char* oa_base;       /* address of more auth stuff */
;   unsigned int  oa_length;     /* not to exceed MAX_AUTH_BYTES */
;};


PRO rpc_opaque_auth__define

struct = {RPC_OPAQUE_AUTH,            $
          flavor:         PTR_NEW (), $
          body:           OBJ_NEW (), $
          AUTH_NULL:      0L,         $
          AUTH_UNIX:      0L,         $
          AUTH_SHORT:     0L,         $
          AUTH_DES:       0L          $
          }


RETURN

END