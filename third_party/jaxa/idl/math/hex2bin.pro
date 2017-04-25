;+
; Project     : SOHO - CDS     
;                   
; Name        : HEX2BIN
;               
; Purpose     : Convert hexadecimal number to binary representation.
;               
; Explanation : The binary representation of a hexadecimal number is calculated
;               and can be displayed or returned or both or neither.
;               
; Use         : IDL> hex2bin, hexadecimal [, binary, /quiet]
;    
; Inputs      : hexadecimal - the number to convert (string).
;               
; Opt. Inputs : None
;               
; Outputs     : See below
;               
; Opt. Outputs: binary - the binary representation of the input.
;               
; Keywords    : quiet - unless given the binary number is printed to the
;                       terminal
;
; Calls       : None
;               
; Restrictions: Input must be a character string.
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
;
; Version     : Version 1, 7-Oct-93
;-            
pro hex2bin,inp,out,quiet=quiet

;
;  follow the keyword through
;
if keyword_set(quiet) then q=1 else q=0

;
;  convert to decimal and thence to binary
;
hex2dec,inp,outt,/quiet
dec2bin,outt,out,quiet=q

end

