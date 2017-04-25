;+
; Project     : SOHO - CDS     
;                   
; Name        : BIN2HEX
;               
; Purpose     : Convert binary representation to hexadecimal.
;               
; Explanation : The binary representation of a decimal number is converted
;               to hexadecimal and can be displayed or returned or 
;               both or neither.
;               
; Use         : IDL> bin2hex, binary [, hex, nchar=nchar, /quiet, /upper]
;    
; Inputs      : binary - the binary representation to convert. It can either
;                        be a string of zeros and ones or an array with each
;                        element a zero or one.
;                        eg bin2hex,'01010101'    or
;                           bin2hex,['1','0','1','0','1','0','1','0']    or
;                           bin2hex,[1,0,1,0,1,0,1,0]
;                        The MSB is assumed to come first
;
;               nchar  - the number of characters in the hex format.
;
; Opt. Inputs : None
;               
; Outputs     : See below
;               
; Opt. Outputs: hex - the hexadecimal equivalent of the input.
;               
; Keywords    : quiet - unless given the hexadecimal number is printed to the
;                       terminal
;
;               upper - convert output to upper case else given in lower case
;
; Calls       : None
;               
; Restrictions: Input must be a string or an array of integers or strings.
;               
; Side effects: None
;               
; Category    : Utils, Numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 7-Oct-93
;               
; Modified    : Add /upper keyword, CDP, 20-Dec-93
;
; Version     : Version 2, 20-Dec-93
;-            

pro bin2hex,inp,out,nchar=nchar,quiet=quiet,upper=upper

;
;  follow the keywords
;
if keyword_set(quiet) then q = 1 else q = 0
if keyword_set(nchar) then n = nchar else n = 0
if keyword_set(upper) then u = 1 else u = 0
;
;  convert to decimal and thence to hex
;
bin2dec,inp,x,/quiet
dec2hex, x, out, nchar=n, quiet=q, upper=u

end
