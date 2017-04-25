
;/*
; * xdr.c, Generic XDR routines implementation.
; *
; * Copyright (C) 1986, Sun Microsystems, Inc.
; *
; * These are the "generic" xdr routines used to serialize and de-serialize
; * most common data items.  See xdr.h for more info on the interface to
; * xdr.
; */

; ------------------------------------------------------------------------------------------------
FUNCTION xdr::xdr_nothing

;/*
; * XDR nothing
; */
;bool_t xdr_void( /* xdrs, addr */ )
;    /* XDR *xdrs; */
;    /* char* addr; */
;
;
;    return (TRUE);
;}

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_int, v

;/*
; * XDR integers
; */
;bool_t xdr_int(XDR* xdrs, int* ip)
;{
;    if (sizeof(int) == sizeof(long)) {
;       return (xdr_long(xdrs, (long *) ip));
;    } else if (sizeof(int) < sizeof(long)) {
;      long l;
;      switch (xdrs->x_op) {
;      case XDR_ENCODE:
;       l = (long) *ip;
;       return XDR_PUTLONG(xdrs, &l);
;      case XDR_DECODE:
;       if (!XDR_GETLONG(xdrs, &l))
;         return FALSE;
;       *ip = (int) l;
;      case XDR_FREE:
;       return TRUE;
;      }
;      return FALSE;
;    } else {
;       return (xdr_short(xdrs, (short *) ip));
;    }
;}


IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   val = FIX (val)

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_u_int, v

;/*
; * XDR unsigned integers
; */
;bool_t xdr_u_int(XDR* xdrs, unsigned int* up)
;{
;    if (sizeof(unsigned int) == sizeof(unsigned long)) {
;       return (xdr_u_long(xdrs, (unsigned long *) up));
;    } else if (sizeof(unsigned int) < sizeof(unsigned long)) {
;      unsigned long l;
;      switch (xdrs->x_op) {
;      case XDR_ENCODE:
;       l = (unsigned long) *up;
;       return XDR_PUTLONG(xdrs, &l);
;      case XDR_DECODE:
;       if (!XDR_GETLONG(xdrs, &l))
;         return FALSE;
;       *up = (unsigned int) l;
;      case XDR_FREE:
;       return TRUE;
;      }
;      return FALSE;
;    } else {
;       return (xdr_short(xdrs, (short *) up));
;    }
;}


IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   val = UINT (val)

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END


; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_long, v

;/*
; * XDR long integers
; * same as xdr_u_long - open coded to save a proc call!
; */
;bool_t xdr_long(XDR* xdrs, long* lp)
;{
;
;    if (xdrs->x_op == XDR_ENCODE
;       && (sizeof(int32_t) == sizeof(long)
;         || (int32_t) *lp == *lp))
;       return (XDR_PUTLONG(xdrs, lp));
;
;    if (xdrs->x_op == XDR_DECODE)
;       return (XDR_GETLONG(xdrs, lp));
;
;    if (xdrs->x_op == XDR_FREE)
;       return (TRUE);
;
;    return (FALSE);
;}

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_u_long, v

;/*
; * XDR unsigned long integers
; * same as xdr_long - open coded to save a proc call!
; */
;bool_t xdr_u_long(XDR* xdrs, unsigned long* ulp)
;{
;
;  if (xdrs->x_op == XDR_DECODE) {
;    long l;
;    if (XDR_GETLONG(xdrs, &l) == FALSE)
;      return FALSE;
;    *ulp = (uint32_t) l;
;    return TRUE;
;  }
;
;  if (xdrs->x_op == XDR_ENCODE) {
;    if (sizeof(uint32_t) != sizeof(unsigned long)
;       && (uint32_t) *ulp != *ulp)
;      return FALSE;
;
;       return (XDR_PUTLONG(xdrs, (long *) ulp));
;  }
;
;    if (xdrs->x_op == XDR_FREE)
;       return (TRUE);
;
;    return (FALSE);
;}


IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_short, v

;/*
; * XDR short integers
; */
;bool_t xdr_short(XDR* xdrs, short* sp)
;{
;    long l;
;
;    switch (xdrs->x_op) {
;
;    case XDR_ENCODE:
;       l = (long) *sp;
;       return (XDR_PUTLONG(xdrs, &l));
;
;    case XDR_DECODE:
;       if (!XDR_GETLONG(xdrs, &l)) {
;         return (FALSE);
;       }
;       *sp = (short) l;
;       return (TRUE);
;
;    case XDR_FREE:
;       return (TRUE);
;    }
;    return (FALSE);
;}

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   val = FIX (val)

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_u_short, v

;/*
; * XDR unsigned short integers
; */
;bool_t xdr_u_short(XDR* xdrs, unsigned short* usp)
;{
;    unsigned long l;
;
;    switch (xdrs->x_op) {
;
;    case XDR_ENCODE:
;       l = (unsigned long) * usp;
;       return (XDR_PUTLONG(xdrs, &l));
;
;    case XDR_DECODE:
;       if (!XDR_GETLONG(xdrs, &l)) {
;         return (FALSE);
;       }
;       *usp = (unsigned short) l;
;       return (TRUE);
;
;    case XDR_FREE:
;       return (TRUE);
;    }
;    return (FALSE);
;}

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   val = UINT (val)

; Convert the result back to a pointer (if needed)

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_char, v

;/*
; * XDR a char
; */
;bool_t xdr_char(XDR* xdrs, char* cp)
;{
;    int i;
;
;    i = (*cp);
;    if (!xdr_int(xdrs, &i)) {
;       return (FALSE);
;    }
;    *cp = i;
;    return (TRUE);
;}

IF self.op EQ 1 THEN BEGIN

; Convert parameters to values (if needed)

   IF SIZE (v, /TYPE) EQ 10 THEN val = *v ELSE val = v

; Check to make sure we were passed a string as a parameter

   IF SIZE (val, /TYPE) NE 7 THEN RETURN, 0

   RETURN, self.xdr_stream->putlong (LONG ((BYTE (val)) [0]))

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   val = STRING (BYTE (val))

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_u_char, v

;/*
; * XDR an unsigned char
; */
;bool_t xdr_u_char(XDR* xdrs, unsigned char* cp)
;{
;    unsigned int u;
;
;    u = (*cp);
;    if (!xdr_u_int(xdrs, &u)) {
;       return (FALSE);
;    }
;    *cp = u;
;    return (TRUE);
;}

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   RETURN, self.xdr_stream->putlong (LONG ((BYTE (val)) [0]))

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   val = STRING (BYTE (val))

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_bool, v

;/*
; * XDR booleans
; */
;bool_t xdr_bool(xdrs, bp)
;register XDR *xdrs;
;bool_t *bp;
;{
;    long lb;
;
;    switch (xdrs->x_op) {
;
;    case XDR_ENCODE:
;       lb = *bp ? XDR_TRUE : XDR_FALSE;
;       return (XDR_PUTLONG(xdrs, &lb));
;
;    case XDR_DECODE:
;       if (!XDR_GETLONG(xdrs, &lb)) {
;         return (FALSE);
;       }
;       *bp = (lb == XDR_FALSE) ? FALSE : TRUE;
;       return (TRUE);
;
;    case XDR_FREE:
;       return (TRUE);
;    }
;    return (FALSE);
;}


IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   IF val THEN val = 1 ELSE val = 0

   RETURN, self.xdr_stream->putlong (LONG (val))

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

; Convert the result back to a pointer (if needed)

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_float, v

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   byte_array = BYTE (val, 0, 4)

   RETURN, self.xdr_stream->putlong (LONG (byte_array, 0))

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

   byte_array = BYTE (val, 0, 4)

   val = FLOAT (byte_array, 0)

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_double, v

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   byte_array = BYTE (val, 0, 8)

   IF self.xdr_stream->little_endian () THEN BYTEORDER, byte_array, /L64SWAP

   RETURN, self.xdr_stream->putbytes (byte_array, 8)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getbytes (byte_array, 8) THEN RETURN, 0

   IF self.xdr_stream->little_endian () THEN BYTEORDER, byte_array, /L64SWAP

   val = DOUBLE (byte_array, 0)

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_enum, v

;/*
; * XDR enumerations
; */
;bool_t xdr_enum(xdrs, ep)
;XDR *xdrs;
;enum_t *ep;
;{
;    enum sizecheck { SIZEVAL };    /* used to find the size of an enum */
;
;    /*
;     * enums are treated as ints
;     */
;    if (sizeof(enum sizecheck) == sizeof(long)) {
;       return (xdr_long(xdrs, (long *) ep));
;    } else if (sizeof(enum sizecheck) == sizeof(int)) {
;      long l;
;      switch (xdrs->x_op) {
;      case XDR_ENCODE:
;       l = *ep;
;       return XDR_PUTLONG(xdrs, &l);
;      case XDR_DECODE:
;       if (!XDR_GETLONG(xdrs, &l))
;         return FALSE;
;       *ep = l;
;      case XDR_FREE:
;       return TRUE;
;      }
;      return FALSE;
;    } else if (sizeof(enum sizecheck) == sizeof(short)) {
;       return (xdr_short(xdrs, (short *) ep));
;    } else {
;       return (FALSE);
;    }
;}

ON_IOERROR, HANDLE_ERROR

IF self.op EQ 1 THEN BEGIN

; Convert parameters from pointers to values (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   val = LONG (val)

   RETURN, self.xdr_stream->putlong (val)

ENDIF ELSE BEGIN

   IF NOT self.xdr_stream->getlong (val) THEN RETURN, 0

; Convert the result back to a pointer (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

HANDLE_ERROR:

RETURN, 0

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_opaque, v, c

; Convert the parameter c from a pointer to a value (if needed).

IF SIZE (c, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

   IF NOT PTR_VALID (c) THEN RETURN, 0

   cnt = *c

ENDIF ELSE cnt = c


;/*
; * XDR opaque data
; * Allows the specification of a fixed size sequence of opaque bytes.
; * cp points to the opaque object and cnt gives the byte length.
; */
;bool_t xdr_opaque(xdrs, cp, cnt)
;register XDR *xdrs;
;char* cp;
;register unsigned int cnt;
;{
;    register unsigned int rndup;
;    static char crud[BYTES_PER_XDR_UNIT];
;
;    /*
;     * if no data we are done
;     */
;    if (cnt == 0)
;       return (TRUE);
;

IF cnt EQ 0 THEN RETURN, 1

;    /*
;     * round byte count to full xdr units
;     */
;    rndup = cnt % BYTES_PER_XDR_UNIT;
;    if (rndup > 0)
;       rndup = BYTES_PER_XDR_UNIT - rndup;
;

rndup = cnt MOD 4

IF rndup GT 0 THEN rndup = 4 - rndup

;    if (xdrs->x_op == XDR_DECODE) {
;       if (!XDR_GETBYTES(xdrs, cp, cnt)) {
;         return (FALSE);
;       }
;       if (rndup == 0)
;         return (TRUE);
;       return (XDR_GETBYTES(xdrs, crud, rndup));
;    }
;
;    if (xdrs->x_op == XDR_ENCODE) {
;       if (!XDR_PUTBYTES(xdrs, cp, cnt)) {
;         return (FALSE);
;       }
;       if (rndup == 0)
;         return (TRUE);
;       return (XDR_PUTBYTES(xdrs, xdr_zero, rndup));
;    }
;
;    if (xdrs->x_op == XDR_FREE) {
;       return (TRUE);
;    }
;
;    return (FALSE);
;}

crud = BYTARR (4)

IF self.op EQ 1 THEN BEGIN

; Convert the parameter v from a pointer to a value (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v

   IF NOT self.xdr_stream->putbytes (val, cnt) THEN RETURN, 0

   IF rndup NE 0 THEN BEGIN

      IF NOT self.xdr_stream->putbytes (crud, rndup) THEN RETURN, 0

   ENDIF

   RETURN, 1

ENDIF ELSE BEGIN

   val = 0

   IF NOT self.xdr_stream->getbytes (val, cnt) THEN RETURN, 0

   IF rndup NE 0 THEN BEGIN

      IF NOT self.xdr_stream->getbytes (crud, rndup) THEN RETURN, 0

   ENDIF

; Convert the result back to a pointer (if needed)

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END


; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_bytes, v, l, ml

;/*
; * XDR counted bytes
; * *cpp is a pointer to the bytes, *sizep is the count.
; * If *cpp is NULL maxsize bytes are allocated
; */
;bool_t xdr_bytes(xdrs, cpp, sizep, maxsize)
;register XDR *xdrs;
;char **cpp;
;register unsigned int *sizep;
;unsigned int maxsize;
;{
;    register char *sp = *cpp;  /* sp is the actual string pointer */
;    register unsigned int nodesize;
;
;    /*
;     * first deal with the length since xdr bytes are counted
;     */
;    if (!xdr_u_int(xdrs, sizep)) {
;       return (FALSE);
;    }
;    nodesize = *sizep;
;    if ((nodesize > maxsize) && (xdrs->x_op != XDR_FREE)) {
;       return (FALSE);
;    }
;
;    /*
;     * now deal with the actual bytes
;     */
;    switch (xdrs->x_op) {
;
;    case XDR_DECODE:
;       if (nodesize == 0) {
;         return (TRUE);
;       }
;       if (sp == NULL) {
;         *cpp = sp = (char *) mem_alloc(nodesize);
;       }
;       if (sp == NULL) {
;         (void) fprintf(stderr, "xdr_bytes: out of memory\n");
;         return (FALSE);
;       }
;       /* fall into ... */
;
;    case XDR_ENCODE:
;       return (xdr_opaque(xdrs, sp, nodesize));
;
;    case XDR_FREE:
;       if (sp != NULL) {
;         mem_free(sp, nodesize);
;         *cpp = NULL;
;       }
;       return (TRUE);
;    }
;    return (FALSE);
;}

IF self.op EQ 1 THEN BEGIN

; Convert the parameter l from a pointer to a value (if needed).

   IF SIZE (l, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (l) THEN RETURN, 0

      len = *l

   ENDIF ELSE len = l

; XDR the byte array length.

   IF NOT self->xdr_u_int (len) THEN RETURN, 0

; Convert the parameter ml from a pointer to a value (if needed).

   IF SIZE (ml, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (ml) THEN RETURN, 0

      maxlen = *ml

   ENDIF ELSE maxlen = ml

; Check to make sure the length doesn't exceed the maximum array length.

   IF ULONG (len) GT maxlen THEN RETURN, 0

   RETURN, self->xdr_opaque (v, len)

ENDIF ELSE BEGIN

; XDR the byte array length.

   IF NOT self->xdr_u_int (len) THEN RETURN, 0

; Check for a zero length array.  We won't try and read any data for this case.

   IF len NE 0 THEN BEGIN

      IF NOT self->xdr_opaque (v, len) THEN RETURN, 0

   ENDIF ELSE BEGIN

      IF PTR_VALID (v) THEN *v = 0 ELSE v = 0

   ENDELSE

; Convert the result back to a pointer (if needed)

   IF SIZE (l, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (l) THEN *l = len

   ENDIF ELSE l = len

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::xdr_net_record, r, l

;/*
; * Implemented here due to commonality of the object.
; */
;bool_t xdr_netobj(xdrs, np)
;XDR *xdrs;
;struct netobj *np;
;{
;
;    return (xdr_bytes(xdrs, &np->n_bytes, &np->n_len, MAX_NETOBJ_SZ));
;}


IF self.op EQ 1 THEN BEGIN

; Convert the parameter r from a pointer to a value (if needed).

   IF SIZE (r, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (r) THEN RETURN, 0

      rec = *r

   ENDIF ELSE rec = r

; Convert the parameter l from a pointer to a value (if needed).

   IF SIZE (l, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (l) THEN RETURN, 0

      len = *l

   ENDIF ELSE len = l

   rec = BYTE (rec)

   len = len < N_ELEMENTS (rec)

   snd_buff_size = self.xdr_stream->get_snd_buff_size ()

   pos = 0

   buffer_space = snd_buff_size - self.xdr_stream->getbufsize ()

   WHILE pos LT len DO BEGIN

     nbytes = (len - pos) < buffer_space

     end_of_rec = (len - pos) LE buffer_space

     result = self.xdr_stream->put_rec_fragment (rec [pos:pos+nbytes-1], END_OF_RECORD = end_of_rec)

     IF NOT result THEN RETURN, 0

     pos = pos + nbytes

     buffer_space = snd_buff_size - self.xdr_stream->getbufsize ()

   ENDWHILE

   RETURN, 1

ENDIF ELSE BEGIN

   virgin = 1

   WHILE NOT self.xdr_stream->end_of_record () DO BEGIN

      IF NOT self.xdr_stream->get_rec_fragment (rec) THEN RETURN, 0

      IF virgin THEN BEGIN

         t      = rec
         virgin = 0

      ENDIF ELSE BEGIN

         t      = [t, rec]

      ENDELSE

   ENDWHILE

   len = N_ELEMENTS (t)

   IF NOT virgin THEN rec = t ELSE rec = 0

; Convert the result back to a pointer (if needed).

   IF SIZE (r, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (r) THEN *r = rec

   ENDIF ELSE r = rec

   IF SIZE (l, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (l) THEN *l = len

   ENDIF ELSE l = len

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_union, d, unp, choices, dfault


; Convert the parameter d from a pointer to a value (if needed).

IF SIZE (d, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

   IF NOT PTR_VALID (d) THEN RETURN, 0

   dscm = *d

ENDIF ELSE dscm = d


;/*
; * XDR a descriminated union
; * Support routine for discriminated unions.

; * You create an array of xdrdiscrim structures, terminated with
; * an entry with a null procedure pointer.  The routine gets
; * the discriminant value and then searches the array of xdrdiscrims
; * looking for that value.  It calls the procedure given in the xdrdiscrim
; * to handle the discriminant.  If there is no specific routine a default
; * routine may be called.
; * If there is no specific or default routine an error is returned.
; */
;bool_t xdr_union(XDR* xdrs, enum_t* dscmp, char* unp, const struct xdr_discrim* choices, xdrproc_t dfault)
;{
;    register enum_t dscm;
;
;    /*
;     * we deal with the discriminator;  it's an enum
;     */
;    if (!xdr_enum(xdrs, dscmp)) {
;       return (FALSE);
;    }

IF NOT self->xdr_enum (dscm) THEN RETURN, 0

;    dscm = *dscmp;
;
;    /*
;     * search choices for a value that matches the discriminator.
;     * if we find one, execute the xdr routine for that value.
;     */
;    for (; choices->proc != NULL_xdrproc_t; choices++) {
;       if (choices->value == dscm)
;         return ((*(choices->proc)) (xdrs, unp, LASTUNSIGNED));
;    }
;

i = 0

WHILE (choices[i].proc NE 0) DO BEGIN

   IF choices [i].value EQ dscm THEN BEGIN

      status = CALL_FUNCTION (choices[i].proc, unp, self.lastunsigned)

      IF status THEN BEGIN

; Convert the result back to a pointer (if needed).  Also make sure
; that we deallocate the old pointer.

         IF SIZE (d, /TYPE) EQ 10 THEN BEGIN

            PTR_FREE, d
            d = PTR_NEW (dscm)

         ENDIF ELSE d = dscm

      ENDIF

      RETURN, status

   ENDIF

   i = i + 1

ENDWHILE


;    /*
;     * no match - execute the default xdr routine if there is one
;     */
;    return ((dfault == NULL_xdrproc_t) ? FALSE :
;         (*dfault) (xdrs, unp, LASTUNSIGNED));
;}

IF dfault EQ 0 THEN RETURN, 0

status = CALL_FUNCTION (dfault, unp, LASTUNSIGNED)

IF status THEN BEGIN

; Convert the result back to a pointer (if needed).

   IF SIZE (d, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (d) THEN *d = dscm

   ENDIF ELSE d = dscm

ENDIF

RETURN, status

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_string, v, m

; Convert the parameter m from a pointer to a value (if needed).

IF SIZE (m, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

   IF NOT PTR_VALID (m) THEN RETURN, 0

   maxsize = *m

ENDIF ELSE maxsize = m

;/*
; * XDR null terminated ASCII strings
; * xdr_string deals with "C strings" - arrays of bytes that are
; * terminated by a NULL character.  The parameter cpp references a
; * pointer to storage; If the pointer is null, then the necessary
; * storage is allocated.  The last parameter is the max allowed length
; * of the string as specified by a protocol.
; */
;bool_t xdr_string(xdrs, cpp, maxsize)
;register XDR *xdrs;
;char **cpp;
;unsigned int maxsize;
;{
;    register char *sp = *cpp;  /* sp is the actual string pointer */
;    unsigned int size;
;    unsigned int nodesize;
;
;    /*
;     * first deal with the length since xdr strings are counted-strings
;     */
;    switch (xdrs->x_op) {
;    case XDR_FREE:
;       if (sp == NULL) {
;         return (TRUE);     /* already free */
;       }
;       /* fall through... */
;    case XDR_ENCODE:
;       size = strlen(sp);
;       break;
;    }


IF self.op EQ 1 THEN BEGIN

; Convert the parameter v from a pointer to a value (if needed).

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

; Check to make sure that the pointer is valid.  If not, give up.

      IF NOT PTR_VALID (v) THEN RETURN, 0

      val = *v

   ENDIF ELSE val = v


   IF SIZE (val, /TYPE) EQ 7 THEN len = STRLEN (val) ELSE len = N_ELEMENTS (val)

ENDIF

;    if (!xdr_u_int(xdrs, &size)) {
;       return (FALSE);
;    }

IF NOT self->xdr_u_int (len) THEN RETURN, 0


;    if (size > maxsize) {
;       return (FALSE);
;

IF ULONG (len) GT maxsize THEN RETURN, 0

;    nodesize = size + 1;


;
;    /*
;     * now deal with the actual bytes
;     */
;    switch (xdrs->x_op) {
;
;    case XDR_DECODE:
;       if (nodesize == 0) {
;         return (TRUE);
;       }
;       if (sp == NULL)
;         *cpp = sp = (char *) mem_alloc(nodesize);
;       if (sp == NULL) {
;         (void) fprintf(stderr, "xdr_string: out of memory\n");
;         return (FALSE);
;       }
;       sp[size] = 0;
;       /* fall into ... */
;
;    case XDR_ENCODE:
;       return (xdr_opaque(xdrs, sp, size));
;    case XDR_FREE:
;       mem_free(sp, nodesize);
;       *cpp = NULL;
;       return (TRUE);
;    }
;    return (FALSE);
;}


IF self.op EQ 1 THEN BEGIN

   RETURN, self->xdr_opaque (val, len)

ENDIF ELSE BEGIN

; Check for a NULL string.  This will be handled as a seperate case

   IF len EQ 0 THEN BEGIN

      val = ""

   ENDIF ELSE BEGIN

      IF NOT self->xdr_opaque (val, len) THEN RETURN, 0

      val = STRING (val)

   ENDELSE

; Convert the result back to a pointer (if needed).  Also make sure
; that we deallocate the old pointer.

   IF SIZE (v, /TYPE) EQ 10 THEN BEGIN

      IF PTR_VALID (v) THEN *v = val

   ENDIF ELSE v = val

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::xdr_wrapstring, v

;/*
; * Wrapper for xdr_string that can be called directly from
; * routines like clnt_call
; */
;bool_t xdr_wrapstring(xdrs, cpp)
;XDR *xdrs;
;char **cpp;
;{
;    if (xdr_string(xdrs, cpp, LASTUNSIGNED)) {
;       return (TRUE);
;    }
;    return (FALSE);
;}

; Convert parameters to values (if needed)

RETURN, self->xdr_string (v, self.lastunsigned)

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::get_xdr_stream_obj

RETURN, self.xdr_stream

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr::getpos

RETURN, self.xdr_stream->getpos ()

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::getbufsize

RETURN, self.xdr_stream->getbufsize ()

END

; ------------------------------------------------------------------------------------------------

PRO xdr::setpos, pos

self.xdr_stream->setpos, pos

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr::reset

self.xdr_stream->reset

RETURN

END

; ------------------------------------------------------------------------------------------------


PRO xdr::write, len, LL = ll

self.xdr_stream->write, len, LL = ll

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr::flush_buffer

self.xdr_stream->flush_buffer

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr::send_record

self.xdr_stream->send_record

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr::skip_record

self.xdr_stream->skip_record

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::end_of_record

RETURN, self.xdr_stream->end_of_record ()

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::end_of_record_flag

RETURN, self.xdr_stream->end_of_record_flag ()

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr::end_of_buffer

RETURN, self.xdr_stream->end_of_buffer ()

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::buffer_full

RETURN, self.xdr_stream->buffer_full ()

END

; ------------------------------------------------------------------------------------------------

FUNCTION getdirection

RETURN, self.op

END

; ------------------------------------------------------------------------------------------------


PRO xdr::setdirection, d

d = TRIM (STRING (d))

CASE d OF

'ENCODE'     : self.op = 1
'DECODE'     : self.op = 0
'1'          : self.op = 1

ELSE         : self.op = 0

ENDCASE

; self.xdr_stream->reset

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::init, TYPE = type,              $
                    DIRECTION = d,            $
                    LUN  = lun,               $
                    MAX_BUFF_SIZE = max_buff_size


; Check if the user specified the type of XDR stream to output or input to.  If they did not
; then we will assume a memory buffer.

IF NOT KEYWORD_SET (type) THEN type = "MEM"
IF NOT KEYWORD_SET (d) THEN d = 0


type = STRUPCASE (type)

CASE type OF

"STDIO" :  BEGIN

             self.type       = "STDIO"
             self.xdr_stream = OBJ_NEW ("xdr_stdio", LUN = lun, MAX_BUFF_SIZE = max_buff_size)

             IF NOT OBJ_VALID (self.xdr_stream) THEN RETURN,0

           END

"REC"   :  BEGIN

             self.type       = "REC"
             self.xdr_stream = OBJ_NEW ("xdr_rec", SND_BUFF_SIZE = max_buff_size, LUN = lun)

             IF NOT OBJ_VALID (self.xdr_stream) THEN RETURN,0

           END

"MEM"   :  BEGIN

             self.type       = "MEM"
             self.xdr_stream = OBJ_NEW ("xdr_mem", MAX_BUFF_SIZE = max_buff_size)

             IF NOT OBJ_VALID (self.xdr_stream) THEN RETURN,0

           END


ELSE     : BEGIN

             PRINT, "Can not create XDR stream of type: ", type
             RETURN, 0

           END


ENDCASE

self->setdirection, d
self.lastunsigned = 0UL - 1

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO xdr::cleanup

IF OBJ_VALID (self.xdr_stream) THEN OBJ_DESTROY, self.xdr_stream

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr__define

struct = {XDR, xdr_stream:    obj_new (),     $
               op:            0,              $
               lastunsigned:  0UL,            $
               type:          ""              $

         }

END

