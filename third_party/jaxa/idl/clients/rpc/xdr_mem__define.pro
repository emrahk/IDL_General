
; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::init, MAX_BUFF_SIZE = max_buff_size

IF NOT KEYWORD_SET (max_buff_size) THEN max_buff_size = 4096

self.buffer = PTR_NEW (BYTARR (max_buff_size))
self.bufsize = 0
self.maxbufsize = max_buff_size
self.pos     = 0
self.little_endian = 0

; Decide if we are running on a little endian machine or not.

; IF !version.arch EQ 'x86' THEN self.little_endian = 1
self.little_endian = 1


; Set some useful constants

self.decode = 0
self.encode = 1

RETURN, 1

END

; ------------------------------------------------------------------------------------------------


PRO xdr_mem::cleanup

IF PTR_VALID (self.buffer) THEN PTR_FREE, self.buffer

IF PTR_VALID (self.private) THEN PTR_FREE, self.private

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::getlong, val

;static bool_t
;xdrmem_getlong (XDR *xdrs, long *lp)
;{
;  if (xdrs->x_handy < 4) return FALSE;
;  xdrs->x_handy -= 4;
;
;  *lp = (int32_t) ntohl((*((int32_t *) (xdrs->x_private))));
;  xdrs->x_private += 4;
;  return TRUE;
;}

IF self.bufsize - self.pos LT 4 THEN RETURN, 0

v = LONARR (4)

IF self.little_endian THEN BEGIN

   v [0] = LONG ((*self.buffer) [self.pos + 3])
   v [1] = LONG ((*self.buffer) [self.pos + 2])
   v [2] = LONG ((*self.buffer) [self.pos + 1])
   v [3] = LONG ((*self.buffer) [self.pos])

ENDIF ELSE BEGIN

   v [0] = LONG ((*self.buffer) [self.pos])
   v [1] = LONG ((*self.buffer) [self.pos + 1])
   v [2] = LONG ((*self.buffer) [self.pos + 2])
   v [3] = LONG ((*self.buffer) [self.pos + 3])

ENDELSE

self.pos = self.pos + 4

val = (ISHFT (v [3], 24)) + ISHFT (v [2], 16) + ISHFT (v [1], 8) + v [0]

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::putlong, val

;static bool_t
;xdrmem_putlong (XDR *xdrs, const long *lp)
;{
;  if (xdrs->x_handy < 4) return FALSE;
;  xdrs->x_handy -= 4;
;
;  *(int32_t *) xdrs->x_private = htonl(*lp);
;  xdrs->x_private += 4;
;  return (TRUE);
;}

ON_IOERROR, HANDLE_ERROR

IF self.maxbufsize - self.bufsize LT 4 THEN RETURN, 0

val = LONG (val)

IF self.little_endian THEN BEGIN

   (*self.buffer) [self.bufsize + 3] = BYTE (val)
   (*self.buffer) [self.bufsize + 2] = BYTE (ISHFT (val, -8))
   (*self.buffer) [self.bufsize + 1] = BYTE (ISHFT (val, -16))
   (*self.buffer) [self.bufsize]     = BYTE (ISHFT (val, -24))

ENDIF ELSE BEGIN

   (*self.buffer) [self.bufsize + 3] = BYTE (ISHFT (val, -24))
   (*self.buffer) [self.bufsize + 2] = BYTE (ISHFT (val, -16))
   (*self.buffer) [self.bufsize + 1] = BYTE (ISHFT (val, -8))
   (*self.buffer) [self.bufsize]     = BYTE (val)


ENDELSE

self.bufsize = self.bufsize + 4

RETURN, 1

HANDLE_ERROR:

RETURN, 0

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr_mem::getbytes, val, len, pos

;static bool_t
;xdrmem_getbytes (XDR *xdrs, char *addr, unsigned int len)
;{
;  if (xdrs->x_handy < len) return FALSE;
;  xdrs->x_handy -= len;
;  memmove(addr, xdrs->x_private, len);
;  xdrs->x_private += len;
;  return TRUE;
;}


IF KEYWORD_SET (val) THEN BEGIN

   IF NOT KEYWORD_SET (len) THEN len = N_ELEMENTS (val)

   IF NOT KEYWORD_SET (pos) THEN pos = 0

   IF pos + len GT N_ELEMENTS (val) THEN RETURN, 0

ENDIF ELSE BEGIN

   IF NOT KEYWORD_SET (len) THEN RETURN, 0

   val = BYTARR (len)

   pos = 0

ENDELSE

IF self.bufsize - self.pos LT len THEN RETURN, 0

val [pos:pos + len - 1] = (*self.buffer) [self.pos:self.pos + len - 1]

self.pos = self.pos + len

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::putbytes, val, len, pos

;static bool_t
;xdrmem_putbytes (XDR *xdrs, const char *addr, unsigned int len)
;{
;  if (xdrs->x_handy < len) return FALSE;
;  xdrs->x_handy -= len;
;  memmove(xdrs->x_private, addr, len);
;  xdrs->x_private += len;
;  return (TRUE);
;}

IF NOT KEYWORD_SET (val) THEN RETURN, 0

IF SIZE (val, /type) EQ 7 THEN val = BYTE (val)

IF SIZE (val, /type) NE 1 THEN RETURN, 0

IF NOT KEYWORD_SET (len) THEN len = N_ELEMENTS (val)

IF NOT KEYWORD_SET (pos) THEN pos = 0

IF pos + len GT N_ELEMENTS (val) THEN RETURN, 0

IF self.maxbufsize - self.bufsize LT len THEN RETURN, 0

(*self.buffer) [self.bufsize:self.bufsize + len - 1] = val [pos:pos + len - 1]

self.bufsize = self.bufsize + len

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::getpos

RETURN, self.pos

END


; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::getbufsize

RETURN, self.bufsize

END

; ------------------------------------------------------------------------------------------------

PRO xdr_mem::write, len, LL = ll

IF NOT KEYWORD_SET (len) THEN len = self.maxbufsize

IF NOT KEYWORD_SET (LL) THEN ll = 4

FOR i = 0, len - 1 DO BEGIN

   IF (i + 1) MOD ll EQ 0 THEN BEGIN

      print, (*self.buffer) [i], FORMAT = '(Z4)'

   ENDIF ELSE BEGIN

      print, (*self.buffer) [i], FORMAT = '(Z4, $)'

   ENDELSE

ENDFOR

PRINT

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr_mem::flush_buffer

RETURN

END


; ------------------------------------------------------------------------------------------------

PRO xdr_mem::setpos, pos


;static bool_t xdrmem_setpos(xdrs, pos)
;register XDR *xdrs;
;unsigned int pos;
;{
;  register char* newaddr = xdrs->x_base + pos;
;  register char* lastaddr = xdrs->x_private + xdrs->x_handy;
;
;  if ((long) newaddr > (long) lastaddr
;      || (UINT_MAX < LONG_MAX
;         && (long) UINT_MAX < (long) lastaddr - (long) newaddr))
;      return (FALSE);
;  xdrs->x_private = newaddr;
;  xdrs->x_handy = (long) lastaddr - (long) newaddr;
;  return (TRUE);
;}

IF pos LT self.bufsize THEN self.pos = pos

RETURN

END


; ------------------------------------------------------------------------------------------------

PRO xdr_mem::reset

self.pos = 0
self.bufsize = 0

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr_mem::send_record

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr_mem::skip_record

RETURN

END
; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::end_of_record

RETURN, 0

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr::end_of_record_flag

RETURN, 1

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr_mem::end_of_buffer

RETURN, self.bufsize - self.pos LE 0

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::buffer_full

RETURN, self.maxbuffsize - self.bufsize LE 0

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_mem::little_endian

RETURN, self.little_endian

END

; ------------------------------------------------------------------------------------------------

PRO xdr_mem__define

struct = {xdr_mem, buffer:        ptr_new (),     $
                   bufsize:       0L,             $
                   maxbufsize:    0L,             $
                   pos:           0L,             $
                   little_endian: 0,              $
                   private:       ptr_new (),     $
                   decode:        0,              $
                   encode:        0               $
         }

END

