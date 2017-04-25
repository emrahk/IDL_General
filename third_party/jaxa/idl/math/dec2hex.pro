;+
; Project     : SOHO - CDS     
;                   
; Name        : DEC2HEX
;               
; Purpose     : Convert a non-negative decimal integer to a hex string.
;               
; Explanation : 
;               
; Use         : IDL> dec2hex,decimal [,hex, nchar=nchar, /quiet, /upper]
;    
; Inputs      : decimal - non-negative decimal integer, scalar.  All leading 
;                         blanks are removed.
;               
; Opt. Inputs : None
;               
; Outputs     : See below
;               
; Opt. Outputs: hex - the hexadecimal representation of the number.
;               
; Keywords    : quiet - if not present, the hex form will be output to the
;                       terminal.
;               nchar - number of characters in the output hexadecimal string.
;                       If not supplied, then the hex string will contain no 
;                       leading zeros.
;
;               upper - converts hex letters to uppercase for output
;
; Calls       : None
;               
; Restrictions: Input can only be non-negative integer number.
;               
; Side effects: None
;               
; Category    : Util, numerical
;               
; Prev. Hist. : Written by W. Landsman, November, 1990 
;
; Written     : CDS version by C D Pike, RAL, 7-Oct-93
;               
; Modified    : Added /upper keyword, CDP, 20-Dec-1993
;               Trap negatives, CDP, 19-May-94
;
; Version     : Version 3, 19-May-94
;-            

pro dec2hex, inp, out, nchar=nchar, quiet=quiet, upper=upper

;
;  negatives not allowed
;
if inp lt 0 then begin
   print,'Negatives not allowed.'
   out = ' '
   return
endif

;
;  select output format as requested
;
if not keyword_set(nchar) then format = '(Z)' else begin
    ch = strtrim( nchar, 2 ) 
    format = '(Z' + ch + '.' + ch + ')'
endelse

;
;  use internal formatting to produce correct string
;
out = strtrim( string(inp, FORM = format), 2)

;
;  which case?
;
if not keyword_set(upper) then out = strlowcase(out) else out = strupcase(out)

;
;  if not silenced then report result
;
if not keyword_set(quiet) then print,out

end



