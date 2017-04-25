;+
; Project     : SOHO - CDS     
;                   
; Name        : DEC2BIN
;               
; Purpose     : Convert integer decimal number to binary representation.
;               
; Explanation : The binary representation of a decimal number is calculated
;               and can be displayed or returned or both or neither.
;               
; Use         : IDL> dec2bin, decimal [, binary, /quiet]
;    
; Inputs      : decimal - the number to convert
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
; Restrictions: Input must be of byte, int or long type.
;               
; Side effects: When the input variable DECIMAL is an array, then the output
;		variable BINARY is also an array with the dimensions
;		(32,N_ELEMENTS(DECIMAL)) no matter what the dimensions of
;		DECIMAL are.
;               
; Category    : Utils, Numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 7-Oct-93
;               
; Modified    : Version 1, C D Pike, RAL, 7-Oct-93
;		Version 2, William Thompson, GSFC, 23 December 1994
;			Modified to work with arrays.
;               Version 3, William Thompson, GSFC, 24 June 2005
;                       Change to use [] array notation
;
; Version     : Version 3, 24 June 2005
;-            

pro dec2bin,inp,out,quiet=quiet

;
;  convert input to LONG so that arithmetic later on will work
;
in=long(inp[*])

;
;  maximum possible output array
;
out=bytarr(32,n_elements(in))

;
;  perform the conversion
;
for i=0,31 do out[31-i,*]=(in and 2L^i)/2L^i

;
;  trim output depending on nature of input
;
case datatype(inp) of
   'BYT': begin 
            if not keyword_set(quiet) then print,'$(8I1,1X)',out[24:31,*]
            out = out[24:31,*] 
          end
   'INT': begin 
            if not keyword_set(quiet) then print,'$(2(8I1,1X))',out[16:31,*] 
            out = out[16:31,*] 
          end
   'LON': begin 
            if not keyword_set(quiet) then print,'$(4(8I1,1X))',out
          end
    else: begin print,'Error: only integer types allowed.' & out = 0 & end
endcase

end
