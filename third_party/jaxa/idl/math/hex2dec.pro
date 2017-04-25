;+
; Project     : SOHO - CDS     
;                   
; Name        : HEX2DEC
;               
; Purpose     : Convert hexadecimal representation to decimal integer.
;               
; Explanation : A hexadecimal string is converted to a decimal integer and 
;               can be displayed or returned or both or neither.
;               
; Use         : IDL> hex2dec, hex [, decimal, /quiet]
;    
; Inputs      : hex - hexadecimal string
;
; Opt. Inputs : None
;               
; Outputs     : See below
;               
; Opt. Outputs: decimal - the decimal integer equivalent of the input.
;               
; Keywords    : quiet - unless given the decimal number is printed to the
;                       terminal
;
; Calls       : None
;               
; Restrictions: Input must be a string.
;               
; Side effects: None
;               
; Category    : Utils, Numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 7-Oct-93
;               
; Modified    : 
; 9-28-05, N.Rich	Allow H or X in input
;
; Version     : Version 1, 7-Oct-93
;-            

pro hex2dec,inp,out,quiet=quiet

;
;  trap invalid input
;
if datatype(inp) ne 'STR' then begin
   print,'Error: input must be string.'
   return
endif

;  
;  initialise output etc
;
out = 0L
n = strlen(inp)

;
;  convert each character in turn
;
for i=n-1,0,-1 do begin
  c = strupcase(strmid(inp,i,1))
  case c of
   'A': c = 10
   'B': c = 11
   'C': c = 12
   'D': c = 13
   'E': c = 14
   'F': c = 15
   'X': c = 0
   'H': c = 0
  else: begin
         if not valid_num(c,/integer) then begin
           print,'Invalid character **',c,'**'
           out = 0
           return
         endif
        end
  endcase
  out = out + long(c)*16L^long(n-1-i)
endfor

;
;  if not silenced, print result
;
if not keyword_set(quiet) then print,out

end
