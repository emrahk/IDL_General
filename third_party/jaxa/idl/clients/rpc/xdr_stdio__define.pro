; ------------------------------------------------------------------------------------------------

FUNCTION xdr_stdio::getlong, val

self.direction = self.decode

IF self.bufsize - self.pos LT 4 THEN BEGIN

; Check if there is anything in the buffer. If there is, then we need to reset it
; so that unread portion is at the beginning and the rest is empty.

  IF self.bufsize - self.pos GT 0 THEN BEGIN

; Recreate the buffer so that beginning of the buffer is at pos 0.

     ptr = PTR_NEW (BYTARR (self.maxbufsize))

     *ptr [0:self.bufsize - self.pos - 1] = (*self.buffer) [self.pos:self.bufsize]

      PTR_FREE, self.buffer

      self.buffer = ptr

      self.bufsize = self.bufsize - self.pos

   ENDIF ELSE BEGIN

      self.bufsize = 0

   ENDELSE

; Reset pos pointer to the beginning of the buffer

   self.pos = 0

; Try to fill up buffer

; Create a temporary array to received that new data

   tmp = BYTARR (self.maxbufsize - self.bufsize)

; Trap IO errors that occur during the READ (specifically, EOF)

   ON_IOERROR, Catch_EOF

; Get the data

   READU, self.lun, tmp, TRANSFER_COUNT = cnt

;  EOF

Catch_EOF:

; Clear the error trap

   ON_IOERROR, NULL

; Copy the new data into the buffer

   (*(self.buffer)) [self.bufsize:self.maxbufsize - 1] = tmp

; Reset bufsize to the new buffer size

   IF cnt NE 0 THEN self.bufsize = self.bufsize + cnt ELSE self.bufsize = self.maxbufsize

; If we can't fill up the buffer at least enough to read a long, then fail (RETURN, 0)

   IF self.bufsize - self.pos LT 4 THEN RETURN, 0

ENDIF

RETURN, self->xdr_mem::getlong (val)

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_stdio::putlong, val

self.direction = self.encode

IF self.maxbufsize - self.bufsize LT 4 THEN BEGIN

; Try to write out the buffer

   WRITEU, self.lun, (*(self.buffer)) [self.pos:self.bufsize-1], TRANSFER_COUNT = cnt

; Make sure that we were able to copy out the entire buffer.

   IF cnt LT self.bufsize - self.pos THEN BEGIN

      self.pos = self.pos + cnt

      RETURN, 0

   ENDIF

; Reset the buffer and position pointer.

   self.pos = 0
   self.bufsize = 0

ENDIF

RETURN, self->xdr_mem::putlong (val)

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr_stdio::getbytes, val, len, pos

self.direction = self.decode

tlen = len

IF NOT KEYWORD_SET (len) THEN BEGIN

   sval = N_ELEMENTS (val)

   IF sval NE 0 THEN tlen = sval ELSE tlen = 0

ENDIF

IF self.bufsize - self.pos LT tlen THEN BEGIN

; Check if there is anything in the buffer. If there is, then we need to reset it
; so that unread portion is at the beginning and the rest is empty.

  IF self.bufsize - self.pos GT 0 THEN BEGIN

; Recreate the buffer so that beginning of the buffer is at pos 0.

     ptr = PTR_NEW (BYTARR (self.maxbufsize))

     (*ptr) [0:self.bufsize - self.pos - 1] = (*self.buffer) [self.pos:self.bufsize - 1]

      PTR_FREE, self.buffer

      self.buffer = ptr

      self.bufsize = self.bufsize - self.pos

   ENDIF ELSE BEGIN

      self.bufsize = 0

   ENDELSE

; Reset pos pointer to the beginning of the buffer

   self.pos = 0

; Try to fill up buffer
; Create a temporary array to received that new data

   tmp = BYTARR (self.maxbufsize - self.bufsize)

; Trap IO errors that occur during the READ (specifically, EOF)

   ON_IOERROR, Catch_EOF

; Get the data

   READU, self.lun, tmp, TRANSFER_COUNT = cnt

;  EOF

Catch_EOF:

; Clear the error trap

   ON_IOERROR, NULL

; Copy the new data into the buffer

   (*(self.buffer)) [self.bufsize:self.maxbufsize - 1] = tmp

; Reset bufsize to the new buffer size

   IF cnt NE 0 THEN self.bufsize = self.bufsize + cnt ELSE self.bufsize = self.maxbufsize

; If we can't fill up the buffer at least enough to read the requested number
; number of bytes then fail (RETURN, 0)

   IF self.bufsize - self.pos LT tlen THEN RETURN, 0

ENDIF

RETURN, self->xdr_mem::getbytes ( val, len, pos )

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_stdio::putbytes, val, len, pos

self.direction = self.encode

IF NOT KEYWORD_SET (len) THEN len = N_ELEMENTS (val)

IF self.maxbufsize - self.bufsize LT len THEN BEGIN

; Try to write out the buffer

   WRITEU, self.lun, (*(self.buffer)) [self.pos:self.bufsize-1], TRANSFER_COUNT = cnt

; Make sure that we were able to copy out the entire buffer.  If we were not able to
; do this, then fail (RETURN, 0)

   IF cnt LT self.bufsize - self.pos THEN BEGIN

      self.pos = self.pos + cnt

      RETURN, 0

   ENDIF

; Reset the buffer and position pointer.

  self.pos = 0
  self.bufsize = 0

ENDIF

RETURN, self->xdr_mem::putbytes ( val, len, pos)

END

; ------------------------------------------------------------------------------------------------

PRO xdr_stdio::flush_buffer


IF self.direction EQ self.DECODE THEN BEGIN

   self.pos = 0
   self.bufsize = 0

   RETURN

ENDIF

; Try to write out the buffer.  Only do this if there is something in the buffer to write out.

IF self.bufsize GT self.pos + 1 THEN BEGIN

   WRITEU, self.lun, (*(self.buffer)) [self.pos:self.bufsize-1], TRANSFER_COUNT = cnt

ENDIF

; Make the contents are actually written and not sitting in a second buffer somewhere.

FLUSH, self.lun

; Make sure that we were able to copy out the entire buffer.  If we were not able to
; do this, then just pos and not bufsize.  May eventually want throw an error here.

IF cnt LT self.bufsize - self.pos THEN BEGIN

   self.pos = self.pos + cnt

   RETURN

 ENDIF

; Reset the buffer and position pointer.

self.pos = 0
self.bufsize = 0

RETURN

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_stdio::init, MAX_BUFF_SIZE = max_buff_size, LUN = lun


IF N_ELEMENTS (lun) EQ 0           THEN lun = 0
IF N_ELEMENTS (max_buff_size) EQ 0 THEN max_buff_size = 4096

IF NOT self->xdr_mem::init (MAX_BUFF_SIZE = max_buff_size) THEN RETURN, 0

; Probably should add in a check to make sure that lun refers to a valid file.

self.lun = lun
self.direction = self.DECODE

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO xdr_stdio::cleanup

self->flush_buffer

self->xdr_mem::cleanup

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr_stdio__define

struct = {XDR_STDIO,              $
          lun:        0,          $
          direction:  0,          $
          INHERITS    XDR_MEM     $
          }


RETURN

END