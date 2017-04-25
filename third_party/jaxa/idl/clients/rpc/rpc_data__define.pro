; ------------------------------------------------------------------------------------------------

FUNCTION rpc_data::xdr_data, xdr

SWITCH self.data_type OF

  self.IDL_NULL          :  RETURN, 1
  self.IDL_INT           :  RETURN, xdr->xdr_int    (self.data_ptr)
  self.IDL_LONG          :  RETURN, xdr->xdr_long   (self.data_ptr)
  self.IDL_UINT          :  RETURN, xdr->xdr_u_int  (self.data_ptr)
  self.IDL_ULONG         :  RETURN, xdr->xdr_u_long (self.data_ptr)
  self.IDL_BYTE          :  BEGIN

    len = self.data_size

    IF NOT xdr->xdr_bytes (self.data_size, len, self.data_size) THEN RETURN, 0

    self.data_size = len

    RETURN, 1

  END

  self.IDL_STRING        :  BEGIN

    IF self.data_size EQ 0 THEN len = -1UL ELSE len = self.data_size

    IF NOT xdr->xdr_string (self.data_ptr, len) THEN RETURN, 0

    self.data_size = STRLEN  (*self.data_ptr)

    RETURN, 1

  END

  self.IDL_STRUCT        :  BEGIN

    ntags = N_TAGS (*self.data_ptr)

    FOR i = 0, ntags - 1 DO BEGIN

       d =   (*self.data_ptr).(i)
       l =   N_ELEMENTS (d)

       CASE SIZE ((*self.data_ptr).(i), /TYPE) OF

          self.IDL_INT           :  IF NOT xdr->xdr_int    (d) THEN RETURN, 0
          self.IDL_LONG          :  IF NOT xdr->xdr_long   (d) THEN RETURN, 0
          self.IDL_UINT          :  IF NOT xdr->xdr_u_int  (d) THEN RETURN, 0
          self.IDL_ULONG         :  IF NOT xdr->xdr_u_long (d) THEN RETURN, 0
          self.IDL_BYTE          :  IF NOT xdr->xdr_bytes  (d, l, 0UL - 1) THEN RETURN, 0
          self.IDL_STRING        :  IF NOT xdr->xdr_string (d, 0UL - 1)    THEN RETURN, 0
          self.IDL_FLOAT         :  IF NOT xdr->xdr_float  (d) THEN RETURN, 0
          self.IDL_DOUBLE        :  IF NOT xdr->xdr_double (d) THEN RETURN, 0
          self.IDL_COMPLEX       :  RETURN, 0
          self.IDL_DCOMPLEX      :  RETURN, 0
          self.IDL_LONG64        :  RETURN, 0
          self.IDL_ULONG64       :  RETURN, 0

       ENDCASE

       (*self.data_ptr).(i) = d

    ENDFOR

    RETURN, 1

  END

  self.RPC_RECORD        :  BEGIN

    len = self.data_size

    IF NOT xdr->xdr_net_record (self.data_ptr, len) THEN RETURN, 0

    IF len EQ 0 THEN self.data_type = self.IDL_NULL

    self.data_size = len

    RETURN, 1

  END

  self.IDL_FLOAT         : RETURN, xdr->xdr_float    (self.data_ptr)
  self.IDL_DOUBLE        : RETURN, xdr->xdr_double   (self.data_ptr)
  self.IDL_COMPLEX       :
  self.IDL_DCOMPLEX      :
  self.IDL_LONG64        :
  self.IDL_ULONG64       :  BEGIN

  END

ENDSWITCH

RETURN, 0

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_data::create_data_member, keyword, value

; Check to make sure the current data type is STRUCTURE, otherwise this function can be used.

IF self.data_type NE self.IDL_STRUCT THEN RETURN, 0

; Make sure a keyword and a value were passed.

IF N_PARAMS () NE 2 THEN RETURN, 0

; Make sure that the keyword parameter is a string.

IF SIZE (keyword, /TYPE) NE self.IDL_STRING THEN RETURN, 0

; Check if there is a valid data structure, if there is then we add the keyword value pair
; to that structure.

IF SIZE (*self.data_ptr, /TYPE) EQ self.IDL_STRUCT THEN BEGIN

   tmp = CREATE_STRUCT (keyword, value, *self.data_ptr)

   *self.data_ptr = tmp

ENDIF ELSE BEGIN

; Otherwise, just create an initial structure with the keyword, value pair that was
; passed to us.

   *self.data_ptr = CREATE_STRUCT (keyword, value)

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_data::set_data, DATA_TYPE = data_type, DATA_VALUE = data_value, _EXTRA = data_struct

; Note:  Calling this method with no keywords will NOT result in the object being reset to
; the UNKNOWN DATA type.  This must be done by explicitlty setting the DATA_TYPE keyword -- this
; is different then the init method!

; Check if a value was passed using the data_value keyword.  If it was, then this is value the
; object will contain.  NOTE: This can be anonymous structure!

IF N_ELEMENTS (data_value) NE 0 THEN BEGIN

;  Check for RPC_RECORD, for this type we have to set the size and data type seperately.

   IF N_ELEMENTS (data_type)  NE 0 THEN BEGIN

      IF data_type EQ self.RPC_RECORD THEN BEGIN

;  Set data type to RPC_RECORD

         self.data_type = self.RPC_RECORD

;  Set the data size to the number of bytes in data value.

         self.data_size = N_ELEMENTS (data_value)

;  Create a pointer to the new data value.

         *self.data_ptr = BYTE (data_value)

      ENDIF

   ENDIF ELSE BEGIN

;  Use the SIZE function to set the data type:

      self.data_type = SIZE (data_value, /TYPE)

;  Use the N_ELEMENTS function to set the data size

      self.data_size = N_ELEMENTS (data_value)

;  If an anonymous structure was passed, then we need to do some extra processing

      IF self.data_type EQ self.IDL_STRUCT THEN self.data_size = N_TAGS (data_value)

      IF self.data_type EQ self.IDL_STRING THEN self.data_size = STRLEN (data_value)

;  Create a pointer to the new data value

      *self.data_ptr = data_value

   ENDELSE

ENDIF ELSE BEGIN

   IF N_ELEMENTS (data_type) NE 0 THEN BEGIN

; OK, now were just setting the type of data this object will accept.  This is useful reading
; data from an XDR stream.

   self.data_type = data_type


; Set the new data type using a switch.  The switch will handle the case where
; a stucture type was requested but no structure definition was provided, either
; through _EXTRA keywords or as the DATA_VALUE keyword.  This is an error!

   CASE data_type OF

; Check if the NUL data type was requested. We can handle this by special case

     self.IDL_NULL          :  BEGIN   ;NULL DATA TYPE

       *self.data_ptr  = 0
       self.data_size = 0

     END

     self.RPC_RECORD        :  BEGIN   ;RPC RECORD TYPE
                                       ;Ignore the data_size keyword, since there is no way
                                       ;we can know how big the record is beforehand.

       self.data_size = 0

     END

     self.IDL_BYTE          :  BEGIN   ;BYTE DATA TYPE
                                       ;Unlike INTs or LONGs, this is more likely to use to store
                                       ;an array of bytes, rather then single value :)


; Check if a data length was set.  If no data length was set, then we will set it to 1

       IF NOT KEYWORD_SET (data_size) THEN data_size = 1

; Set the size of the data item.

       self.data_size = data_size

; Create a single byte data item, or an array of bytes, as needed.

       IF data_size EQ 1 THEN BEGIN

          *self.data_ptr = 0B

       ENDIF ELSE BEGIN

          *self.data_ptr = BYTARR (data_size)

       ENDELSE

     END

     self.IDL_INT           :  BEGIN   ;INT DATA TYPE


       *self.data_ptr  = 0S
       self.data_size = 1


     END

     self.IDL_LONG          :  BEGIN   ;LONG DATA TYPE

       *self.data_ptr =  0L
       self.data_size = 1

     END

     self.IDL_FLOAT         :  BEGIN   ;FLOAT DATA TYPE
                                       ;Note, we can not curretly XDR this data type!

       *self.data_ptr =  0.0
       self.data_size = 1

     END

     self.IDL_DOUBLE        :  BEGIN   ;DOUBLE DATA TYPE
                                       ;Note, we can not currently XDR this data type!
       *self.data_ptr =  0.0D
       self.data_size = 1

     END

     self.IDL_COMPLEX       :  BEGIN   ;COMPLEX DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr =  COMPLEX (0., 0.)
       self.data_size = 1

     END

     self.IDL_STRING        :  BEGIN   ;STRING DATA TYPE
                                       ;In order to implement a NULL string, a data size of 0
                                       ;is allowed (and is the default!) for this type.

; Check if a data length was set.  If no data length was set, then we will set it to 0

       IF NOT KEYWORD_SET (data_size) THEN data_size = 0

; Set the size of the data item.

       self.data_size = data_size

; Create a string of the requested length

       IF data_size EQ 0 THEN BEGIN

          *self.data_ptr = ""

       ENDIF ELSE BEGIN

          b = BYTARR (data_size)
          b [*] = '20'XB

          *self.data_ptr = STRING (b)

       ENDELSE

     END

     self.IDL_DCOMPLEX      :  BEGIN   ;DCOMPLEX DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr  = DCOMPLEX (0., 0.)
       self.data_size = 1

     END

     self.IDL_POINTER       :  BEGIN   ;POINTER DATA TYPE
                                       ;I think this just a LONG, but may need to check on it:)


       *self.data_ptr =  PTR_NEW ()
       self.data_size = 1

     END

     self.IDL_OBJREF        :  BEGIN   ;OBJECT DATA TYPE
                                       ;Again, I think this is also a LONG.


       *self.data_ptr =   OBJ_NEW ()
       self.data_size = 1


     END

     self.IDL_UINT          :  BEGIN   ;UNSIGNED INT DATA TYPE

       *self.data_ptr = 0US
       self.data_size = 1

     END

     self.IDL_ULONG         :  BEGIN   ;UNSIGNED LONG DATA TYPE

       *self.data_ptr = 0UL
       self.data_size = 1

     END

     self.IDL_LONG64        :  BEGIN   ;64 BIT LONG DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr = 0LL
       self.data_size = 1

     END

     self.IDL_ULONG64       :  BEGIN   ;UNSIGNED 64 BIT LONG DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr = 0ULL
       self.data_size = 1

     END

     self.IDL_STRUCT        :  BEGIN   ;STRUCTURE DATA TYPE

       *self.data_ptr = 0
       self.data_size = 1

     END


     ELSE:   BEGIN                     ;ERROR Catch All

       PRINT, 'Unknown data type: ', type

     END

   ENDCASE

   ENDIF

ENDELSE

; Check if the data value is set and if it is a structure

IF SIZE (*self.data_ptr, /TYPE) EQ self.IDL_STRUCT THEN BEGIN

; Check if a set of keywords were passed to us representing values to insert into the
; anonymous data structure.  If there were, then add them in now.

   IF N_ELEMENTS (data_struct) NE 0 THEN BEGIN

; Get a list of tag names in the anomous data stucture.

      data_tags = TAG_NAMES (*self.data_ptr)

; Get a list of extra keywords that were passed to the routine

      keywords  = TAG_NAMES (data_struct)

; For every tag name in the anomous data structure, check to see if an equivalent
; keyword was passed to us.  If it was, then copy its value into the data structure.

      FOR i = 0, self.data_size - 1 DO BEGIN

          w = WHERE (keywords EQ data_tags [i])

          j = w [0]

          IF j NE -1 THEN (*self.data_ptr).(i) = data_struct.(j)

      ENDFOR


    ENDIF

ENDIF

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_data::get_data

ret_val = {data_type: self.data_type}

SWITCH self.data_type OF

   self.IDL_NULL          :  RETURN,  CREATE_STRUCT ('data_value', 0, ret_val)
   self.IDL_STRUCT        :  RETURN,  *self.data_ptr
   self.IDL_BYTE          :
   self.IDL_INT           :
   self.IDL_LONG          :
   self.IDL_FLOAT         :
   self.IDL_DOUBLE        :
   self.IDL_COMPLEX       :
   self.IDL_DCOMPLEX      :
   self.IDL_UINT          :
   self.IDL_ULONG         :
   self.RPC_RECORD        :
   self.IDL_LONG64        :
   self.IDL_STRING        :  RETURN,  CREATE_STRUCT ('data_value', *self.data_ptr, ret_val)
   self.IDL_ULONG64       :  BEGIN

     IF self.data_size GE 1 THEN BEGIN

        RETURN,  CREATE_STRUCT ('data_value', *self.data_ptr, ret_val)

     ENDIF ELSE BEGIN

        RETURN, ret_val

     ENDELSE

   END

ENDSWITCH

END

; ------------------------------------------------------------------------------------------------

PRO rpc_data::reset

*self.data_ptr = 0

self.data_type = self.IDL_NULL
self.data_size = 0

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_data::init, DATA_TYPE = data_type,        $
                         DATA_SIZE = data_size,        $
                         DATA_VALUE = data_value,      $
                         _EXTRA = data_struct

; Create the constants object.

cnst = OBJ_NEW ('RPC_CONSTANTS')

; Set local copies of constants used by this object

self.IDL_NULL         = cnst.IDL_NULL
self.IDL_BYTE         = cnst.IDL_BYTE
self.IDL_INT          = cnst.IDL_INT
self.IDL_LONG         = cnst.IDL_LONG
self.IDL_FLOAT        = cnst.IDL_FLOAT
self.IDL_DOUBLE       = cnst.IDL_DOUBLE
self.IDL_COMPLEX      = cnst.IDL_COMPLEX
self.IDL_STRING       = cnst.IDL_STRING
self.IDL_STRUCT       = cnst.IDL_STRUCT
self.IDL_DCOMPLEX     = cnst.IDL_DCOMPLEX
self.IDL_POINTER      = cnst.IDL_POINTER
self.IDL_OBJREF       = cnst.IDL_OBJREF
self.IDL_UINT         = cnst.IDL_UINT
self.IDL_ULONG        = cnst.IDL_ULONG
self.IDL_LONG64       = cnst.IDL_LONG64
self.IDL_ULONG64      = cnst.IDL_ULONG64
self.RPC_RECORD       = cnst.RPC_RECORD


; Get rid of the constants object

OBJ_DESTROY, cnst

self.data_ptr = PTR_NEW (0)

; Check if a value was passed using the data_value keyword.  If it was, then this is value the
; object will contain.  NOTE: This can also be anonymous structure!

IF N_ELEMENTS (data_value) NE 0 THEN BEGIN

;  Check for RPC_RECORD, for this type we have to set the size and data type seperately.

   IF N_ELEMENTS (data_type)  NE 0 THEN BEGIN

      IF data_type EQ self.RPC_RECORD THEN BEGIN

;  Set data type to RPC_RECORD

         self.data_type = self.RPC_RECORD

;  Set the data size to the number of bytes in data value.

         self.data_size = N_ELEMENTS (data_value)

;  Create a pointer to the new data value.

         *self.data_ptr = BYTE (data_value)

      ENDIF

   ENDIF ELSE BEGIN

;  Use the SIZE function to set the data type:

      self.data_type = SIZE (data_value, /TYPE)

;  Use the N_ELEMENTS function to set the data size

      self.data_size = N_ELEMENTS (data_value)

;  If an anonymous structure was passed, then we need to do some extra processing

      IF self.data_type EQ self.IDL_STRUCT THEN self.data_size = N_TAGS (data_value)

      IF self.data_type EQ self.IDL_STRING THEN self.data_size = STRLEN (data_value)

;  Create a pointer to the new data value

      *self.data_ptr = data_value

   ENDELSE

; OK, now were just setting the type of data this object will accept.  This is useful reading
; data from an XDR stream.

ENDIF ELSE IF N_ELEMENTS (data_type) NE 0 THEN BEGIN

; Set the new data type using a switch.  The switch will handle the case where
; a stucture type was requested but no structure definition was provided, either
; through _EXTRA keywords or as the DATA_VALUE keyword.  This is an error!

   self.data_type = data_type

   CASE data_type OF

; Check if the NUL data type was requested. We can handle this by special case

     self.IDL_NULL          :  BEGIN   ;NULL DATA TYPE

       *self.data_ptr = 0
       self.data_size = 0

     END

     self.RPC_RECORD        :  BEGIN   ;RPC RECORD TYPE
                                       ;Ignore the data_size keyword, since there is no way
                                       ;we can know how big the record is beforehand.

       self.data_size = 0

     END

     self.IDL_BYTE          :  BEGIN   ;BYTE DATA TYPE
                                       ;Unlike INTs or LONGs, this is more likely to use to store
                                       ;an array of bytes, rather then single value :)


; Check if a data length was set.  If no data length was set, then we will set it to 1

       IF NOT KEYWORD_SET (data_size) THEN data_size = 1

; Set the size of the data item.

       self.data_size = data_size

; Create a single byte data item, or an array of bytes, as needed.

       IF data_size EQ 1 THEN BEGIN

          *self.data_ptr = 0B

       ENDIF ELSE BEGIN

          *self.data_ptr = BYTARR (data_size)

       ENDELSE

     END

     self.IDL_INT           :  BEGIN   ;INT DATA TYPE


       *self.data_ptr  = 0S
       self.data_size = 1


     END

     self.IDL_LONG          :  BEGIN   ;LONG DATA TYPE

       *self.data_ptr =  0L
       self.data_size = 1

     END

     self.IDL_FLOAT         :  BEGIN   ;FLOAT DATA TYPE
                                       ;Note, we can not curretly XDR this data type!

       *self.data_ptr =  0.0
       self.data_size = 1

     END

     self.IDL_DOUBLE        :  BEGIN   ;DOUBLE DATA TYPE
                                       ;Note, we can not currently XDR this data type!
       *self.data_ptr =  0.0D
       self.data_size = 1

     END

     self.IDL_COMPLEX       :  BEGIN   ;COMPLEX DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr =  COMPLEX (0., 0.)
       self.data_size = 1

     END

     self.IDL_STRING        :  BEGIN   ;STRING DATA TYPE
                                       ;In order to implement a NULL string, a data size of 0
                                       ;is allowed (and is the default!) for this type.

; Check if a data length was set.  If no data length was set, then we will set it to 0

       IF NOT KEYWORD_SET (data_size) THEN data_size = 0

; Set the size of the data item.

       self.data_size = data_size

; Create a string of the requested length

       IF data_size EQ 0 THEN BEGIN

          self.data_ptr = ""

       ENDIF ELSE BEGIN

          b = BYTARR (data_size)
          b [*] = '20'XB

          *self.data_ptr = STRING (b)

       ENDELSE

     END

     self.IDL_DCOMPLEX      :  BEGIN   ;DCOMPLEX DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr  = DCOMPLEX (0., 0.)
       self.data_size = 1

     END

     self.IDL_POINTER       :  BEGIN   ;POINTER DATA TYPE
                                       ;I think this just a LONG, but may need to check on it:)


       *self.data_ptr =  PTR_NEW ()
       self.data_size = 1

     END

     self.IDL_OBJREF        :  BEGIN   ;OBJECT DATA TYPE
                                       ;Again, I think this is also a LONG.


       *self.data_ptr = OBJ_NEW ()
       self.data_size = 1

     END

     self.IDL_UINT          :  BEGIN   ;UNSIGNED INT DATA TYPE

       *self.data_ptr = 0US
       self.data_size = 1

     END

     self.IDL_ULONG         :  BEGIN   ;UNSIGNED LONG DATA TYPE

       *self.data_ptr = 0UL
       self.data_size = 1

     END

     self.IDL_LONG64        :  BEGIN   ;64 BIT LONG DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr = 0LL
       self.data_size = 1

     END

     self.IDL_ULONG64       :  BEGIN   ;UNSIGNED 64 BIT LONG DATA TYPE
                                       ;Note, we can not currently XDR this data type!

       *self.data_ptr = 0ULL
       self.data_size = 1

     END


     self.IDL_STRUCT        :  BEGIN   ;STRUCTURE DATA TYPE

       self.data_size = 0

     END

     ELSE:   BEGIN                     ;ERROR Catch All

       PRINT, 'Unknown data type: ', type
       RETURN, 0

     END

   ENDCASE

   RETURN, 1

ENDIF ELSE BEGIN

; Otherwise, a NULL DATA object

   self.data_type  = self.IDL_NULL
   self.data_size  = 0
   *self.data_ptr  = 0

ENDELSE

; Check if the data value is set and if it is a structure

IF SIZE (*self.data_ptr, /TYPE) EQ self.IDL_STRUCT THEN BEGIN

; Check if a set of keywords were passed to us representing values to insert into the
; anonymous data structure.  If there were, then add them in now.

   IF N_ELEMENTS (data_struct) NE 0 THEN BEGIN

; Get a list of tag names in the anomous data stucture.

      data_tags = TAG_NAMES (*self.data_ptr)

; Get a list of extra keywords that were passed to the routine

      keywords  = TAG_NAMES (data_struct)

; For every tag name in the anomous data structure, check to see if an equivalent
; keyword was passed to us.  If it was, then copy its value into the data structure.

      FOR i = 0, self.data_size - 1 DO BEGIN

          w = WHERE (keywords EQ data_tags [i])

          j = w [0]

          IF j NE -1 THEN (*self.data_ptr).(i) = data_struct.(j)

      ENDFOR


   ENDIF

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_data::cleanup

IF PTR_VALID (self.data_ptr) THEN PTR_FREE, self.data_ptr

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_data__define


struct = {RPC_DATA,                       $
          data_ptr:          PTR_NEW (),  $
          data_type:         0L,          $
          data_size:         0L,          $
          IDL_NULL:          0L,          $
          IDL_BYTE:          0L,          $
          IDL_INT:           0L,          $
          IDL_LONG:          0L,          $
          IDL_FLOAT:         0L,          $
          IDL_DOUBLE:        0L,          $
          IDL_COMPLEX:       0L,          $
          IDL_STRING:        0L,          $
          IDL_STRUCT:        0L,          $
          IDL_DCOMPLEX:      0L,          $
          IDL_POINTER:       0L,          $
          IDL_OBJREF:        0L,          $
          IDL_UINT:          0L,          $
          IDL_ULONG:         0L,          $
          IDL_LONG64:        0L,          $
          IDL_ULONG64:       0L,          $
          RPC_RECORD:        0L,          $
          XDR_ENCODE:        0L,          $
          XDR_DECODE:        0L,          $
          INHERITS           RPC_NULL     $
          }

RETURN

END