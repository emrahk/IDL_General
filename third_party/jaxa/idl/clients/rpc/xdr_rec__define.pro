; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::putheader

; Create a four byte array to hold the header

header = BYTARR (4)

; Encode the current bufsize as an XDR Unsigned Long

val = LONG (self.bufsize)

IF self.little_endian THEN BEGIN

   header [3] = BYTE (val)
   header [2] = BYTE (ISHFT (val, -8))
   header [1] = BYTE (ISHFT (val, -16))
   header [0] = BYTE (ISHFT (val, -24))

ENDIF ELSE BEGIN

   header [3] = BYTE (ISHFT (val, -24))
   header [2] = BYTE (ISHFT (val, -16))
   header [1] = BYTE (ISHFT (val, -8))
   header [0] = BYTE (val)

ENDELSE

; Encode the value of the end of record flag

IF self.end_of_rec EQ 1 THEN header [0] = header [0] OR '80'XB

; Trap IO errors that occur during the READ (specifically, EOF)

ON_IOERROR, Catch_EOF

; Send the data

WRITEU, self.lun, header, TRANSFER_COUNT = cnt

;  EOF

Catch_EOF:

; Clear the error trap

ON_IOERROR, NULL

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::getheader

; First Create an array of bytes to hold the header.

   header = BYTARR (4)

; Set cnt = 0

   cnt = 0

; Trap IO errors that occur during the READ (specifically, EOF)

   ON_IOERROR, Catch_EOF

; Get the data

   READU, self.lun, header, TRANSFER_COUNT = cnt

;  EOF

Catch_EOF:

; Clear the error trap

   ON_IOERROR, NULL

; Check for a bad read

IF cnt NE 4 THEN RETURN, 0

; Extract the header information from the sender.  Start with the flag that
; indicates that whether this is the last fragment in the record

IF (header [0] AND '80'XB) EQ '80'XB THEN self.end_of_rec = 1 ELSE self.end_of_rec = 0

; Clear the high order bit

header [0] = header [0] AND '7F'XB

v = LONARR (4)

IF self.little_endian THEN BEGIN

   v [0] = LONG (header [3])
   v [1] = LONG (header [2])
   v [2] = LONG (header [1])
   v [3] = LONG (header [0])

ENDIF ELSE BEGIN

   v [0] = LONG (header [0])
   v [1] = LONG (header [1])
   v [2] = LONG (header [2])
   v [3] = LONG (header [3])

ENDELSE

val = (ISHFT (v [3], 24)) + ISHFT (v [2], 16) + ISHFT (v [1], 8) + v [0]

self.rcv_buff_size = val

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::get_fragment, TRANSFER_CNT = cnt

; Create a temporary array to received the new data

tmp = BYTARR (self.rcv_buff_size)

; Trap IO errors that occur during the READ (specifically, EOF)

ON_IOERROR, Catch_EOF

; Get the data

READU, self.lun, tmp, TRANSFER_COUNT = cnt

;  EOF

Catch_EOF:

; Clear the error trap

ON_IOERROR, NULL

; Increment the fragment count

self.frag_cnt = self.frag_cnt + 1

RETURN, tmp

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::put_fragment, TRANSFER_CNT = cnt

; Write out the data in the buffer.

WRITEU, self.lun, (*(self.buffer)) [self.pos:self.bufsize-1], TRANSFER_COUNT = cnt

; Make sure that we were able to copy out the entire buffer.

IF cnt LT self.bufsize - self.pos THEN BEGIN

   self.pos = self.pos + cnt

   RETURN, 0

ENDIF

; Increment the fragment count

self.frag_cnt = self.frag_cnt + 1

RETURN, 1

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr_rec::getlong, val

self.direction = self.decode

IF self.bufsize - self.pos LT 4 THEN BEGIN

; Read the next fragment header from the sender.

IF NOT self->getheader () THEN RETURN, 0

; Check if there is anything in the buffer. If there is, then we need to reset it
; so that unread portion is at the beginning and the rest is empty.

   IF self.bufsize - self.pos GT 0 THEN BEGIN

; Recreate the buffer so that beginning of the buffer is at pos 0.

      tmp = BYTARR (self.bufsize - self.pos)

      tmp = (*self.buffer) [self.pos:self.bufsize]

      (*self.buffer) [0:self.bufsize - self.pos - 1] = tmp

      self.bufsize = self.bufsize - self.pos

   ENDIF ELSE BEGIN

      self.bufsize = 0

   ENDELSE

; Reset pos pointer to the beginning of the buffer

   self.pos = 0

; Try to fill up buffer

   tmp = self->get_fragment (TRANSFER_CNT = cnt)

; Copy the new data into the buffer

   (*(self.buffer)) [self.bufsize:self.rcv_buff_size - 1] = tmp

; Reset bufsize to the new buffer size

   IF cnt NE 0 THEN self.bufsize = self.bufsize + cnt ELSE self.bufsize = self.rcv_buff_size

; If we can't fill up the buffer at least enough to read a long, then fail (RETURN, 0)

   IF self.bufsize - self.pos LT 4 THEN RETURN, 0

ENDIF

RETURN, self->xdr_mem::getlong (val)

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::putlong, val

self.direction = self.encode

self.end_of_rec = 0

IF self.snd_buff_size - self.bufsize LT 4 THEN BEGIN

; Write a header word

  IF NOT self->putheader () THEN RETURN, 0

; Try to write out the buffer

  IF NOT self->put_fragment (TRANSFER_CNT = cnt) THEN RETURN, 0

; Reset the buffer and position pointer.

   self.pos = 0
   self.bufsize = 0

ENDIF

RETURN, self->xdr_mem::putlong (val)

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr_rec::getbytes, val, len, pos

self.direction = self.decode

tlen = len

IF NOT KEYWORD_SET (len) THEN BEGIN

   sval = N_ELEMENTS (val)

   IF sval NE 0 THEN tlen = sval ELSE tlen = 0

ENDIF

IF self.bufsize - self.pos LT tlen THEN BEGIN

; Read the next fragment header from the sender.

IF NOT self->getheader () THEN RETURN, 0

; Check if there is anything in the buffer. If there is, then we need to reset it
; so that unread portion is at the beginning and the rest is empty.

   IF self.bufsize - self.pos GT 0 THEN BEGIN

; Recreate the buffer so that beginning of the buffer is at pos 0.

      tmp = BYTARR (self.bufsize - self.pos)

      tmp = (*self.buffer) [self.pos:self.bufsize]

      (*self.buffer) [0:self.bufsize - self.pos - 1] = tmp

      self.bufsize = self.bufsize - self.pos

   ENDIF ELSE BEGIN

      self.bufsize = 0

   ENDELSE

; Reset pos pointer to the beginning of the buffer

   self.pos = 0

; Try to fill up buffer

   tmp = self->get_fragment (TRANSFER_CNT = cnt)

; Copy the new data into the buffer

   (*(self.buffer)) [self.bufsize:self.rcv_buff_size - 1] = tmp

; Reset bufsize to the new buffer size

   IF cnt NE 0 THEN self.bufsize = self.bufsize + cnt ELSE self.bufsize = self.rcv_buff_size

; If we can't fill up the buffer at least enough to read the requested number
; number of bytes then fail (RETURN, 0)

   IF self.bufsize - self.pos LT tlen THEN RETURN, 0

ENDIF

RETURN, self->xdr_mem::getbytes ( val, len, pos )

END

; ------------------------------------------------------------------------------------------------


FUNCTION xdr_rec::get_rec_fragment, val

self.direction = self.decode

IF self.bufsize - self.pos GT 0 THEN BEGIN

  len = self.bufsize - self.pos

  val = BYTARR (len)

  RETURN, self->xdr_mem::getbytes ( val, len, 0 )

ENDIF ELSE BEGIN

; Read the next fragment header from the sender.

  IF NOT self->getheader () THEN RETURN, 0

;  IF PTR_VALID (self.buffer) THEN PTR_FREE, self.buffer

; Get a fragment from the sender.  Copy the result of the get_fragment() function into
; val parameter.

  val = self->get_fragment (TRANSFER_CNT = cnt)

; Set the len to the length of the data array received from the get_fragment() function.

  len = N_ELEMENTS (val)

; Reset pos pointer and bufsize to indicate an empty bufffer

   self.pos = 0
   self.bufsize = 0

   RETURN, 1

ENDELSE

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::putbytes, val, len, pos

self.direction = self.encode

self.end_of_rec = 0

IF NOT KEYWORD_SET (len) THEN len = N_ELEMENTS (val)

IF self.snd_buff_size - self.bufsize LT len THEN BEGIN

; Write a header word

  IF NOT self->putheader () THEN RETURN, 0

; Try to write out the buffer

  IF NOT self->put_fragment (TRANSFER_CNT = cnt) THEN RETURN, 0

; Reset the buffer and position pointer.

  self.pos = 0
  self.bufsize = 0

ENDIF

RETURN, self->xdr_mem::putbytes ( val, len, pos)

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::put_rec_fragment, val, END_OF_RECORD = eor

self.direction = self.encode

len = N_ELEMENTS (val)

; Check if the END_OR_RECORD keyword is set.  IF it is then set the end of record
; marker to TRUE (1)

IF KEYWORD_SET (eor) THEN self.end_of_rec = 1 ELSE self.end_of_rec = 0

; Make sure that data will fit in the send buffer.

IF self.bufsize + len GT self.snd_buff_size THEN RETURN, 0

; Copy the data into the send buffer.

IF NOT self->xdr_mem::putbytes (val, len, 0) THEN RETURN, 0

; Check if the end of record flag is set.  If it is not sent (more to follow) then
; send the contents of the buffer.

IF self.end_of_rec EQ 0 THEN BEGIN

; Write a header word

   IF NOT self->putheader () THEN RETURN, 0

; Try to write out the buffer

  IF NOT self->put_fragment (TRANSFER_CNT = cnt) THEN RETURN, 0

; Make the contents are actually written and not sitting in a second buffer somewhere.

  FLUSH, self.lun

; Reset the buffer and position pointer.

  self.pos = 0
  self.bufsize = 0

ENDIF

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::init, SND_BUFF_SIZE = snd_buff_size, LUN = lun


IF N_ELEMENTS (lun) EQ 0           THEN lun = 0
IF N_ELEMENTS (snd_buff_size) EQ 0 THEN snd_buff_size = 4096

IF NOT self->xdr_mem::init (MAX_BUFF_SIZE = snd_buff_size) THEN RETURN, 0

; Probably should add in a check to make sure that lun refers to a valid file.

self.lun = lun
self.direction = self.DECODE
self.snd_buff_size = snd_buff_size
self.rcv_buff_size = 0L
self.frag_cnt = 0
self.end_of_rec = 1

RETURN, 1

END


; ------------------------------------------------------------------------------------------------

PRO xdr_rec::send_record

IF self.direction NE self.ENCODE THEN RETURN

; Set the end of record marker to TRUE (1)

self.end_of_rec = 1

; Write a header word

IF NOT self->putheader () THEN RETURN

; Try to write out the buffer

IF NOT self->put_fragment (TRANSFER_CNT = cnt) THEN RETURN

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

FUNCTION xdr_rec::get_end_of_rec_flag

RETURN, self.end_of_rec

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::get_rcv_buff_size

RETURN, self.rcv_buff_size

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::get_snd_buff_size

RETURN, self.snd_buff_size

END

; ------------------------------------------------------------------------------------------------

FUNCTION xdr_rec::end_of_record

IF self.bufsize - self.pos LE 0 AND self.end_of_rec EQ 1 THEN RETURN, 1

RETURN, 0

END

; ------------------------------------------------------------------------------------------------

PRO xdr_rec::skip_record

IF self.direction NE self.DECODE THEN RETURN

WHILE self.end_of_rec EQ 0 DO BEGIN

; Read the next fragment header from the sender.

   IF NOT self->getheader () THEN RETURN

; Get the next fragment

   tmp = self->get_fragment (TRANSFER_CNT = cnt)

ENDWHILE

; Reset the buffer and position pointer.

self.pos = 0
self.bufsize = 0

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr_rec::flush_buffer

IF self.direction EQ self.DECODE THEN BEGIN

   self->skip_record

ENDIF ELSE BEGIN

   self->send_record

ENDELSE

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO xdr_rec::reset

self.pos = 0
self.bufsize = 0
self.end_of_rec = 1

RETURN

END


; ------------------------------------------------------------------------------------------------

PRO xdr_rec::cleanup

self->flush_buffer

self->xdr_mem::cleanup

RETURN

END


; ------------------------------------------------------------------------------------------------

PRO xdr_rec__define

struct = {XDR_REC,                   $
          rcv_buff_size: 0L,         $
          frag_cnt:      0L,         $
          end_of_rec:    0,          $
          lun:           0,          $
          direction:     0,          $
          snd_buff_size: 0L,         $
          INHERITS       XDR_MEM     $
          }

RETURN

END