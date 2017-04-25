;/*
; * Define IDL_VARIABLE type values - Note that IDL_TYP_UNDEF is always 0 by
; * definition. It is correct to use the value 0 in place of IDL_TYP_UNDEF.
; * It is not correct to assume the value assigned to any other
; * type - the preprocessor definitions below must be used.
; */
;
;#define IDL_TYP_UNDEF           0
;#define IDL_TYP_BYTE            1
;#define IDL_TYP_INT             2
;#define IDL_TYP_LONG            3
;#define IDL_TYP_FLOAT           4
;#define IDL_TYP_DOUBLE          5
;#define IDL_TYP_COMPLEX         6
;#define IDL_TYP_STRING          7
;#define IDL_TYP_STRUCT          8
;#define IDL_TYP_DCOMPLEX        9
;#define IDL_TYP_PTR            10
;#define IDL_TYP_OBJREF         11
;#define IDL_TYP_UINT           12
;#define IDL_TYP_ULONG          13
;#define IDL_TYP_LONG64         14
;#define IDL_TYP_ULONG64        15
;
;
;#define IDL_MAX_TYPE            15
;#define IDL_NUM_TYPES           16
;
;/*
; * Various machines use different data types for representing memory
; * and file offsets and sizes. We map these to IDL types using the
; * following definitions. Doing it this way lets us easily change
; * the mapping here without having to touch all the code that uses
; * these types.
; */
;
;/*
; * Memory is currently limited to 2^31 on most platforms. If using 64-bit
; * addressing on systems that can do it, we define IDL_MEMINT_64 for the
; * benefit of code that needs to know.
; *
; * MEMINT must always be a signed type.
; */
;#if defined(ALPHA_OSF) || defined(SUN_64) || defined(LINUX_ALPHA) || defined(HPUX_64) || defined(IRIX_64) || defined(AIX_64)
;#define IDL_MEMINT_64
;#define IDL_TYP_MEMINT   IDL_TYP_LONG64
;#define IDL_TYP_UMEMINT  IDL_TYP_ULONG64
;#define IDL_MEMINT   IDL_LONG64
;#define IDL_UMEMINT  IDL_ULONG64
;#else
;#define IDL_TYP_MEMINT   IDL_TYP_LONG
;#define IDL_TYP_UMEMINT  IDL_TYP_ULONG
;#define IDL_MEMINT   IDL_LONG
;#define IDL_UMEMINT  IDL_ULONG
;#endif
;
;#if defined(sun) || defined(ALPHA_OSF) || defined(sgi) || defined(hpux) || defined(WIN32) || defined(linux) || defined(_AIX)
;         /* Files can have 64-bit sizes */
;#define IDL_FILEINT_64
;#define IDL_TYP_FILEINT   IDL_TYP_LONG64
;#define IDL_FILEINT   IDL_LONG64
;#else          /* Stick with 2^31 sized files */
;#define IDL_TYP_FILEINT   IDL_TYP_LONG
;#define IDL_FILEINT   IDL_LONG
;#endif
;
;
;
;
;/*
; * The above type codes each have a bit mask value associated with
; * them. The bit mask value is computed as (2**Type_code), but the
; * following definitions can also be used. Some routines request the
; * bit mask value instead of the type code value.
; *
; * Simple types are everything except TYP_STRUCT, TYP_PTR, and TYP_OBJREF.
;*/
;#define IDL_TYP_B_SIMPLE            62207
;#define IDL_TYP_B_ALL               65535
;
;/* This macro turns it's argument into its bit mask equivalent.
; * The argument type_code should be one of the type codes defined
; * above.
;*/
;#define IDL_TYP_MASK(type_code)      (1 << type_code)
;
;
;
;
;
;
;/**** Basic IDL structures: ****/
;
;typedef struct {
;  float r,i;
;} IDL_COMPLEX;
;
;typedef struct {
;  double r,i;
;} IDL_DCOMPLEX;
;
;/*
; * History of IDL_STRING slen field:
; *
; * Originally, the length field of IDL_STRING was set to short because
; * that allowed IDL and VMS string descriptors to be identical and
; * interoperable, a feature that IDL exploited to simplify string handling.
; * Also, on most 32-bit machines this resulted in sizeof(IDL_STRING) being 8.
; * This was very good, because it avoided causing the sizeof(IDL_VARIABLE)
; * to be increased by the inclusion of an IDL_STRING in the values field
; * (prior to the addition of TYP_DCOMPLEX, the biggest thing in the values
; * field was 8 bytes). IDL's speed is partly gated by the size of a variable,
; * so this is an important factor. Unfortunately, that results in a
; * maximum string length of 64K, long enough for most things, but not
; * really long enough.
; *
; * In IDL 5.4, the first 64-bit version of IDL was released. I realized that
; * we could make the length field be a 32-bit int without space penalty
; * (the extra room comes from wasted "holes" in the struct due to pointers
; * being 8 bytes long). Since there is no issue with VMS (no 64-bit VMS IDL
; * was planned), I did so. 32-bit IDL stayed with the 16-bit length field
; * for backwards compatability and VMS support.
; *
; * With IDL 5.5, the decision was made to drop VMS support. This decision
; * paves the way for 32-bit IDL to also have a 32-bit length field in
; * IDL_STRING. Now, all versions of IDL have the longer string support.
; * This does not increase the size of an IDL_VARIABLE, because the biggest
; * thing in the value field is 16 bytes (DCOMPLEX), and sizeof(IDL_STRING)
; * will be 12 on most systems.
; */
;typedef int IDL_STRING_SLEN_T;
;#define IDL_STRING_MAX_SLEN 2147483647
;
;
;typedef struct {       /* Define string descriptor */
;  IDL_STRING_SLEN_T slen;   /* Length of string, 0 for null */
;  short stype;       /* type of string, static or dynamic */
;  char *s;       /* Addr of string */
;} IDL_STRING;
;
;
;/**** IDL identifiers ****/
;typedef struct _idl_ident {
;  struct _idl_ident *hash;  /* Must be the first field */
;  char *name;                   /* Identifier text (NULL terminated */
;  int len;       /* # of characters in id, not counting NULL
;             termination. */
;} IDL_IDENT;
;
;
;/*
; * Type of the free_cb field of IDL_ARRAY. When IDL deletes a variable and
; * the free_cb field of ARRAY non-NULL, IDL calls the function that field
; * references, passing the value of the data field as it's sole argument.
; * The primary use for this notification is to let programs know when
; * to clean up after calls to IDL_ImportArray(), which is used to create
; * arrays using memory that IDL does not allocate.
; */
;typedef void (* IDL_ARRAY_FREE_CB)(UCHAR *data);
;
;/* Type of the dim field of an IDL_ARRAY. */
;typedef IDL_MEMINT IDL_ARRAY_DIM[IDL_MAX_ARRAY_DIM];
;
;typedef struct {       /* Its important that this block
;             be an integer number of longwords
;             in length to ensure that array
;             data is longword aligned.  */
;  IDL_MEMINT elt_len;     /* Length of element in char units */
;  IDL_MEMINT arr_len;     /* Length of entire array (char) */
;  IDL_MEMINT n_elts;       /* total # of elements */
;  UCHAR *data;       /* ^ to beginning of array data */
;  UCHAR n_dim;       /* # of dimensions used by array */
;  UCHAR flags;       /* Array block flags */
;  short file_unit;   /* # of assoc file if file var */
;  IDL_ARRAY_DIM dim;       /* dimensions */
;  IDL_ARRAY_FREE_CB free_cb;    /* Free callback */
;  IDL_FILEINT offset;     /* Offset to base of data for file var */
;  IDL_MEMINT data_guard;    /* Guard longword */
;} IDL_ARRAY;
;
;typedef struct {       /* Reference to a structure */
;  IDL_ARRAY *arr;     /* ^ to array block containing data */
;  struct _idl_structure *sdef;  /* ^ to structure definition */
;} IDL_SREF;
;
;/* IDL_ALLTYPES can be used to represent all IDL_VARIABLE types */
;typedef union {
;  char sc;       /* A standard char, where "standard" is defined
;             by the compiler. This isn't an IDL data
;             type, but having this field is sometimes
;             useful for internal code */
;  UCHAR c;       /* Byte value */
;  IDL_INT i;         /* 16-bit integer */
;  IDL_UINT ui;       /* 16-bit unsigned integer */
;  IDL_LONG l;      /* 32-bit integer */
;  IDL_ULONG ul;        /* 32-bit unsigned integer */
;  IDL_LONG64 l64;     /* 64-bit integer */
;  IDL_ULONG64 ul64;     /* 64-bit unsigned integer */
;  float f;       /* 32-bit floating point value */
;  double d;        /* 64-bit floating point value */
;  IDL_COMPLEX cmp;   /* Complex value */
;  IDL_DCOMPLEX dcmp;       /* Double complex value */
;  IDL_STRING str;     /* String descriptor */
;  IDL_ARRAY *arr;     /* ^ to array descriptor */
;  IDL_SREF s;      /* Descriptor of structure */
;  IDL_HVID hvid;       /* Heap variable identifier */
;
;  /* The following are mappings to basic types that vary between platforms */
;  IDL_MEMINT memint;       /* Memory size or offset */
;  IDL_FILEINT fileint;   /* File size or offset */
;  IDL_PTRINT ptrint;       /* A pointer size integer */
;} IDL_ALLTYPES;
;
;typedef struct {       /* IDL_VARIABLE definition */
;  UCHAR type;      /* Type byte */
;  UCHAR flags;       /* Flags byte */
;  IDL_ALLTYPES value;
;} IDL_VARIABLE;
;typedef IDL_VARIABLE *IDL_VPTR;

; ------------------------------------------------------------------------------------------------

FUNCTION idl_variable::xdr_vector, xdr, vector, TYPE = type

maxsize = self.max_string_len

; Set a default value for type if needed.

IF N_ELEMENTS (type) EQ 0 THEN type = 2

; Find the length of the vector.  If vector is not defined, then set len to 0.

IF PTR_VALID (vector) THEN len = N_ELEMENTS (*vector) ELSE len = 0

; Store the length of the array.

old_len = len

; XDR the vector length.

IF NOT xdr->xdr_u_int (len) THEN RETURN, 0

; Check if the actual vector length agrees with the length stored in len.  Also make sure
; that the type of array agrees with the type stored in type.  If either is wrong
; then we will have to recreate the vector.

IF old_len NE len OR type NE SIZE (*vector, /TYPE) THEN *vector = MAKE_ARRAY (len, TYPE = type)

; Use a case statement to select correct xdr method to use depending on what type
; of data the array will store..

CASE type OF


     self.IDL_NULL:      RETURN, 1
     self.IDL_BYTE:      m = 'xdr_int'
     self.IDL_INT:       m = 'xdr_int'
     self.IDL_LONG:      m = 'xdr_long'
     self.IDL_FLOAT:     m = 'xdr_float'
     self.IDL_DOUBLE:    m = 'xdr_double'
;     self.IDL_COMPLEX:

     self.IDL_STRING:    BEGIN

                           l = 0

                           FOR i = 0, len - 1 DO BEGIN

                               v = (*vector) [i]

                               l = STRLEN (v)

                               IF NOT xdr->xdr_u_long (l) THEN RETURN, 0

                               IF l NE 0 THEN BEGIN

                                  IF NOT xdr->xdr_string (v, maxsize) THEN RETURN, 0

                                ENDIF ELSE BEGIN

                                  v = ''

                                ENDELSE

                               (*vector) [i] = v

                           ENDFOR

                           RETURN, 1

                         END
;     self.IDL_STRUCT:
;     self.IDL_DCOMPLEX:
;     self.IDL_POINTER:
;     self.IDL_OBJREF:

     self.IDL_UINT:      m = 'xdr_u_int'
     self.IDL_ULONG:     m = 'xdr_u_long'
;     self.IDL_LONG64:
;     self.IDL_ULONG64:

     ELSE:               BEGIN

                            PRINT, 'Unavailable data type requested: ', type

                            RETURN, 0

                         END

ENDCASE

; Loop to xdr the rest of the vector.

FOR i = 0, len - 1 DO BEGIN

   v = (*vector) [i]

   IF NOT CALL_METHOD (m, xdr, v) THEN RETURN, 0

   (*vector) [i] = v

ENDFOR

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_variable::set_value, name, val

; Find the data type of the value that was passed to us.

properties = SIZE (val, /STRUCTURE)

; Check if we can actually store this type:  We can not handle pointers, structures or objects!

type = properties.type

IF type EQ self.IDL_STRUCT OR type EQ self.IDL_POINTER OR type EQ self.IDL_OBJREF THEN BEGIN

   PRINT, 'Complex variables of type STRUCTURE, POINTER and OBJECT REFERENCE can not be '
   PRINT, 'stored transfered using this object.'

   RETURN, 0

ENDIF

; Set name to the varaible name that passed to us as name.

*self.name = name

; Set the type of the variable

*self.type = type

; Check if we are working with an array, if we are then we will have to set some some flags.

IF properties.n_dimensions NE 0 THEN *self.flags = self.IDL_V_ARR ELSE *self.flags = 0

IF properties.n_dimensions NE 0 THEN BEGIN

; Set elt_len to the length of an array element in characters.

   *self.elt_len = self.type2bytes [properties.type]

; Set arr_len to the length of the entire array in characters.

   *self.arr_len = properties.n_elements * *self.elt_len

; Set n_elts to the total number of elements

   *self.n_elts = properties.n_elements

; Set n_dim to the number of dimensions used by the array

   *self.n_dim  = properties.n_dimensions

; Set the array flags to 0.  .

   *self.arr_flags = 0

; Set unknown to 0.

   *self.unknown = 0

; Set arr_dim to the dimensions array which is stored as part of the properties structure.
; We will force every dimension to be at least of size 1, since that is what the RPC Server
; will expect.

   *self.arr_dim = FIX (properties.dimensions) > 1

ENDIF

; Store the actual value in value.

*self.value = val

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_variable::get_value

; Use the flags word to determine if we are processing a scalar, an array, or a
; structure.

IF  *self.flags EQ self.IDL_V_ARR THEN BEGIN

   RETURN, REFORM (*self.value, (*self.arr_dim) [0:(*self.n_dim) - 1])

ENDIF ELSE BEGIN

; Use the case statement to return a scalar of the correct type..

   CASE *self.type OF

       self.IDL_NULL:      RETURN, ''
       self.IDL_BYTE:      RETURN, BYTE   (*self.value)
       self.IDL_INT:       RETURN, FIX    (*self.value)
       self.IDL_LONG:      RETURN, LONG   (*self.value)
       self.IDL_FLOAT:     RETURN, FLOAT  (*self.value)
       self.IDL_DOUBLE:    RETURN, DOUBLE (*self.value)
       self.IDL_COMPLEX:
       self.IDL_STRING:    RETURN, STRING (*self.value)
       self.IDL_STRUCT:
       self.IDL_DCOMPLEX:
       self.IDL_POINTER:
       self.IDL_OBJREF:
       self.IDL_UINT:      RETURN, UINT   (*self.value)
       self.IDL_ULONG:     RETURN, ULONG  (*self.value)
       self.IDL_LONG64:
       self.IDL_ULONG64:

       ELSE:               BEGIN

                              PRINT, 'Unknown data type: ', *self.type

                              RETURN, 0

                           END

   ENDCASE

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_variable::xdr_idl_variable, xdr

; XDR the variable name.

maxsize = self.max_string_len

IF NOT xdr->xdr_string (self.name, maxsize) THEN RETURN, 0

; XDR the variable type.

IF NOT xdr->xdr_enum (self.type) THEN RETURN, 0

; XDR the flags word for the variable (includes whether it is a structure, array, etc.)

IF NOT xdr->xdr_u_long (self.flags) THEN RETURN, 0

; Use the flags word to determine if we are processing a scalar, an array, or a
; structure.

IF  *self.flags EQ self.IDL_V_ARR THEN BEGIN

; XDR the length of each element of the array in characters.

   IF NOT xdr->xdr_int (self.elt_len) THEN RETURN, 0

; XDR the length of the entire array in characters.

   IF NOT xdr->xdr_int (self.arr_len) THEN RETURN, 0

; XDR the total number of elements

   IF NOT xdr->xdr_int (self.n_elts)  THEN RETURN, 0

; XDR the number of dimensions used by the array

   IF NOT xdr->xdr_int (self.n_dim)   THEN RETURN, 0

; XDR the array flags word.  (Note, currently these flags are not interagated and
; it is expected that none of them would be set.

   IF NOT xdr->xdr_int (self.arr_flags) THEN RETURN, 0

; XDR the array offset (or something).  It is not clear how to interpret this word.

   IF NOT xdr->xdr_int (self.unknown) THEN RETURN, 0

; Read the dimensions array

   IF NOT self->xdr_vector (xdr, self.arr_dim) THEN RETURN, 0

; Read the actual array.  Arrays are XDR as a one dimensional vector.

   t = *self.type

   IF NOT self->xdr_vector (xdr, self.value, TYPE = t) THEN RETURN, 0

ENDIF ELSE BEGIN

; Check if we need to recreate the value to conform to the requested type.

   IF *self.type NE SIZE (*self.value, /TYPE) THEN *self.value = FIX (0, TYPE = *self.type)

; Use the case statement to XDR the rest of the variable structure.

   CASE *self.type OF

       self.IDL_NULL:      IF NOT xdr->xdr_nothing () THEN RETURN, 0
       self.IDL_BYTE:      IF NOT xdr->xdr_u_char (self.value) THEN RETURN, 0
       self.IDL_INT:       IF NOT xdr->xdr_int    (self.value) THEN RETURN, 0
       self.IDL_LONG:      IF NOT xdr->xdr_long   (self.value) THEN RETURN, 0
       self.IDL_FLOAT:     IF NOT xdr->xdr_float  (self.value) THEN RETURN, 0
       self.IDL_DOUBLE:    IF NOT xdr->xdr_double (self.value) THEN RETURN, 0
       self.IDL_COMPLEX:
       self.IDL_STRING:    BEGIN

                              string_len = STRLEN (*self.value)

                              IF NOT xdr->xdr_u_long (string_len) THEN RETURN, 0

                              IF string_len NE 0 THEN BEGIN

                                 IF NOT xdr->xdr_string (self.value, maxsize) THEN RETURN, 0

                              ENDIF ELSE BEGIN

                                 *self.value = ''

                              ENDELSE

                           END

       self.IDL_STRUCT:
       self.IDL_DCOMPLEX:
       self.IDL_POINTER:
       self.IDL_OBJREF:
       self.IDL_UINT:      IF NOT xdr->xdr_u_int  (self.value) THEN RETURN, 0
       self.IDL_ULONG:     IF NOT xdr->xdr_u_long (self.value) THEN RETURN, 0
       self.IDL_LONG64:
       self.IDL_ULONG64:

       ELSE:               BEGIN

                              PRINT, 'Unknown message type: Direction: ', self.rm_direction

                              *self.rm_direction = -1

                              RETURN, 0

                           END


   ENDCASE

ENDELSE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION idl_variable::init

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

; Get rid of the constants object

OBJ_DESTROY, cnst

;/***** IDL_VARIABLE flag values ********/
;
;#define IDL_V_CONST         1   /* A variable that does not have a name,
;             and which is treated as a static
;             non-assignable expression by the interpreter.
;             The most common example is a lexical
;             constant. Different from V_TEMP in that
;             V_CONST variables are not part of the
;             temporary variable pool, and because IDL
;             can alter the value of a V_TEMP variable
;             under some circumstances. */

self.IDL_V_CONST = 1

;#define IDL_V_TEMP          2   /* An unnamed variable from the IDL temporary
;            variable pool, used to hold the results
;             of expressionss, and often returned as the
;             result of IDL system functions */

self.IDL_V_TEMP = 2

;#define IDL_V_ARR           4   /* Variable has an array block, accessed via
;             the value.arr field of IDL_VARIABLE, and
;             the data is kept there. If V_ARR is not
;             set, the variable is scalar, and the value
;             is kept directly within the value union. */

self.IDL_V_ARR = 4

;#define IDL_V_FILE          8   /* An ASSOC variable. Note that V_ARR is
;             not set for ASSOC variables, but they
;             still have array blocks. */

self.IDL_V_FILE = 6

;#define IDL_V_DYNAMIC       16   /* Variable contains pointers to other
;              data that must be cleaned up when the
;              variable is destroyed. This happens
;              with scalar strings, or arrays of any
;              type. */

self.IDL_V_DYNAMIC = 16

;#define IDL_V_STRUCT        32   /* Variable is a structure. V_ARR is always
;              set when V_STRUCT is set (there are no
;              scalar structures) */

self.IDL_V_STRUCT = 32



;/**** IDL_ARRAY flag values ****/
;#define IDL_A_FILE          1   /* Array is a FILE variable (ASSOC) */

self.IDL_A_FILE = 1

;#define IDL_A_NO_GUARD      2   /* Indicates no data guards for array */

self.IDL_A_NO_GUARD = 2

;#define IDL_A_FILE_PACKED   4   /* If array is a FILE variable and the data
;             type is IDL_TYP_STRUCT, then I/O to
;             this struct should assume packed data
;             layout compatible with WRITEU instead of
;             being a direct mapping onto the struct
;             including its alignment holes. */

self.IDL_A_FILE_PACKED = 4

;#define IDL_A_FILE_OFFSET   8   /* Only set with IDL_A_FILE. Indicates that
;             variable has a non-zero offset to the base
;            of the data for the file variable, as
;             contained in the IDL_ARRAY offset field.
;             IDL versions prior to IDL 5.5 did not
;             properly SAVE and RESTORE the offset of
;             a file variable. Introducing this bit in
;             IDL 5.5 makes it possible for us to
;             generate files that older IDLs will be
;             able to read as long as that file does
;             not contain any file variables with
;             non-zero file offsets. If not for this
;             minor compatability win, this bit would
;             serve no significant purpose. */

self.IDL_A_FILE_OFFSET = 8

;#define IDL_A_SHM       16     /* This array is a shared memory segment */

self.IDL_A_SHM = 16

; Set the maximum string length that can be transfered.

self.max_string_len = -1UL

; Populate the type2bytes table

self.type2bytes [self.IDL_NULL]    = 0
self.type2bytes [self.IDL_BYTE]    = 1
self.type2bytes [self.IDL_INT]     = 2
self.type2bytes [self.IDL_LONG]    = 4
self.type2bytes [self.IDL_FLOAT]   = 4
self.type2bytes [self.IDL_DOUBLE]  = 8
self.type2bytes [self.IDL_COMPLEX] = 8
self.type2bytes [self.IDL_STRING]  = 16
self.type2bytes [self.IDL_STRUCT]  = 0
self.type2bytes [self.IDL_DCOMPLEX]= 16
self.type2bytes [self.IDL_POINTER] = 0
self.type2bytes [self.IDL_OBJREF]  = 0
self.type2bytes [self.IDL_UINT]    = 2
self.type2bytes [self.IDL_ULONG]   = 4
self.type2bytes [self.IDL_LONG64]  = 8
self.type2bytes [self.IDL_ULONG64] = 8

; Set the data pointers to some default values.

self.name       = PTR_NEW ('')
self.type       = PTR_NEW (0)
self.flags      = PTR_NEW (0)
self.elt_len    = PTR_NEW (0)
self.n_elts     = PTR_NEW (0)
self.arr_len    = PTR_NEW (0)
self.n_dim      = PTR_NEW (0)
self.arr_flags  = PTR_NEW (0)
self.unknown    = PTR_NEW (0)
self.arr_dim    = PTR_NEW (0)
self.value      = PTR_NEW (0)

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO idl_variable::cleanup

IF PTR_VALID (self.name) THEN PTR_FREE, self.name
IF PTR_VALID (self.type) THEN PTR_FREE, self.type
IF PTR_VALID (self.flags) THEN PTR_FREE, self.flags
IF PTR_VALID (self.elt_len) THEN PTR_FREE, self.elt_len
IF PTR_VALID (self.arr_len) THEN PTR_FREE, self.arr_len
IF PTR_VALID (self.n_elts) THEN PTR_FREE, self.n_elts
IF PTR_VALID (self.n_dim) THEN PTR_FREE, self.n_dim
IF PTR_VALID (self.arr_flags) THEN PTR_FREE, self.arr_flags
IF PTR_VALID (self.unknown) THEN PTR_FREE, self.unknown
IF PTR_VALID (self.arr_dim) THEN PTR_FREE, self.arr_dim
IF PTR_VALID (self.value) THEN PTR_FREE, self.value

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO idl_variable__define

struct = {IDL_VARIABLE,                       $
          name:              PTR_NEW (),      $
          type:              PTR_NEW (),      $
          flags:             PTR_NEW (),      $
          elt_len:           PTR_NEW (),      $
          arr_len:           PTR_NEW (),      $
          n_elts:            PTR_NEW (),      $
          n_dim:             PTR_NEW (),      $
          arr_flags:         PTR_NEW (),      $
          unknown:           PTR_NEW (),      $
          arr_dim:           PTR_NEW (),      $
          value:             PTR_NEW (),      $
          max_string_len:    0L,              $
          type2bytes:        INTARR (16),     $
          IDL_NULL:          0L,              $
          IDL_BYTE:          0L,              $
          IDL_INT:           0L,              $
          IDL_LONG:          0L,              $
          IDL_FLOAT:         0L,              $
          IDL_DOUBLE:        0L,              $
          IDL_COMPLEX:       0L,              $
          IDL_STRING:        0L,              $
          IDL_STRUCT:        0L,              $
          IDL_DCOMPLEX:      0L,              $
          IDL_POINTER:       0L,              $
          IDL_OBJREF:        0L,              $
          IDL_UINT:          0L,              $
          IDL_ULONG:         0L,              $
          IDL_LONG64:        0L,              $
          IDL_ULONG64:       0L,              $
          IDL_V_CONST:       0L,              $
          IDL_V_TEMP:        0L,              $
          IDL_V_ARR:         0L,              $
          IDL_V_FILE:        0L,              $
          IDL_V_DYNAMIC:     0L,              $
          IDL_V_STRUCT:      0L,              $
          IDL_A_FILE:        0L,              $
          IDL_A_NO_GUARD:    0L,              $
          IDL_A_FILE_PACKED: 0L,              $
          IDL_A_FILE_OFFSET: 0L,              $
          IDL_A_SHM:         0L               $
          }

RETURN

END