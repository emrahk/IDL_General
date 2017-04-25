pro win2gif, outname
;
; Reads the contents of current window (TVRD) and
; writes to a gif file.  Accounts for color depth
; of display.
;
; INPUTS:
;  outname	STRING	Name of output gif file
;
; KEYWORDS:
;  INDEX	Set to index of window to read from; default is current window.
;
; LIMITATIONS:
;  Must be using IDL 5.2 - 5.3.
;
; WRITTEN:
;  N. Rich, NRL/Interferometrics - 9/5/01
;
;-

device, get_visual_depth=dep

IF dep GT 8 THEN BEGIN
   ss = TVRD(True=1) 
   im = Color_quan(ss,1,r,g,b)
   write_gif,outname,im,r,g,b

ENDIF ELSE BEGIN
   ss= TVRD()
   write_gif,outname,ss
ENDELSE

end
