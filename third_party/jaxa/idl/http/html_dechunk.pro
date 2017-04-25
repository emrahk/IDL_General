;+
; Project     : HESSI
;
; Name        : HTML_DECHUNK
;
; Purpose     : remove chunked encoding from HTML output
;
; Category    : http utility
;
; Inputs      : INPUT - HTML string array
;
; Outputs     : OUTPUT - HTML array with chunked lines rejoined
;
; History     : 15-April-2005,  D.M. Zarro (L-3Com/GSFC).  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function html_dechunk,input

if is_blank(input) then return,input

;-- look for chunked encoding  

check=where(stregex(input,'encoding: *chunked',/bool,/fold),count)
if count eq 0 then return,input

chunk=where(stregex(input,'^[^<> ]+$',/bool),count)
if count eq 0 then return,input
output=input
np=n_elements(input)
for i=0,count-1 do begin
 k=chunk[i]
 if (k gt 0) and (k lt (np-1)) then begin
  l1=input[k-1]
  l2=input[k+1]
  output[k]=l1+l2
  output[k-1]=''
  output[k+1]=''
 endif
endfor
return,output

end