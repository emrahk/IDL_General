
;+
; PROJECT:
;   SSW
; NAME:
;   RECALLBUFFER2FILE
;
; PURPOSE:
;   Writes the current recall buffer (help,/recall) to a file in
;   order of original creation
;
; CATEGORY:
;   UTIL
;
; CALLING SEQUENCE:
;   RecallBuffer2File [, Filename] [, Out]
;
; CALLS:
;   reverse, prstr
;
; INPUTS:
;       Filename - defaults to 'recallbuffer.txt'

; OPTIONAL INPUTS:
;   none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;   Out - contents of written file
;
; KEYWORDS:
;   none
; COMMON BLOCKS:
;   none
;
; SIDE EFFECTS:
;   Writes file specified by filename.
;
; RESTRICTIONS:
;   Version 5.0 and greater only
;
; PROCEDURE:
;   Uses recall_commands function
;
; MODIFICATION HISTORY:
;   26-may-2004, Version 1, richard.schwartz@gsfc.nasa.gov
;
;-

pro recallbuffer2file, filename, out, lines=lines

default, filename, 'recallbuffer.txt'

out = recall_commands()

notnull = where( out ne '')
out = reverse(out[notnull])
nout = n_elements(out)
default, lines, nout
out = out[nout-lines:nout-1]
prstr, out, file=filename

end

