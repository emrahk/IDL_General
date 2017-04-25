;+
; Project     : Hinode/EIS
;
; Name        : FITS_CLASS
;
; Purpose     : determine object class associated with FITS file
;
; Category    : objects, i/o
;
; Syntax      : IDL> class=fits_class(file)
;
; Inputs      : FILE = FITS filename to test
;
; Outputs     : CLASS = class name [e.g. 'EIT'] if EIT FITS file
;
; Keywords    : ERR= error string
;
; History     : Written 12 November 2007, D. Zarro (ADNET)

function fits_class,file

class='fits'
mrd_head,file,head,err=err
if is_string(err) then return,class

;-- check for INSTRUMEN then DETECTOR keyword

choices=['instr','dete']
for i=0,n_elements(choices)-1 do begin
 check=choices[i]
 chk=stregex(head,"^"+check+".+= *'? *([^' ]+) *'?",/ext,/sub,/fold)
 ok=where(chk[1,*] ne '',count)
 if count gt 0 then begin
  tclass=chk[1,ok[0]]
  if valid_class(tclass) then return,tclass
 endif
endfor

return,class & end
