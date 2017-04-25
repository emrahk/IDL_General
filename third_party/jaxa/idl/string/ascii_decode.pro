
;+
; Project     : VSO
;
; Name        : ASCII_DECODE
;
; Purpose     : Decode % characters in URL string
;
; Category    : system utility sockets
;
; Syntax      : IDL> out=ascii_decode(in)
;
; Inputs      : IN = encoded string (e.g. %22)
;
; Outputs     : OUT = decoded string (e.g. ")
;
; Keywords    :
;
; History     : 21 March 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

FUNCTION ascii_decode,sd     
 if is_blank(sd) || n_elements(sd) ne 1 then return,''
  
  s=sd
  s = str_replace(s,'+',' ')
  res = ''
  WHILE (i=strpos(s,'%')) GE 0 DO BEGIN
     res = res+strmid(s,0,i)
     hex2dec,strmid(s,i+1,2),byt,/quiet
     res = res+string(byte(byt))
     s = strmid(s,i+3,1e5)
  END
  res = res+s
  return,res
END
