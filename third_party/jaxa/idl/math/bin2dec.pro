;+
; Project     : SOHO - CDS     
;                   
; Name        : BIN2DEC
;               
; Purpose     : Convert binary representation to decimal integer.
;               
; Explanation : The binary representation of a decimal number is converted
;               to a decimal integer and can be displayed or returned or 
;               both or neither.
;               
; Use         : IDL> bin2dec, binary [, decimal, /quiet]
;    
; Inputs      : binary - the binary representation to convert. It can either
;                        be a string of zeros and ones or an array with each
;                        element a zero or one.
;                        eg bin2dec,'01010101'    or
;                           bin2dec,['1','0','1','0','1','0','1','0']    or
;                           bin2dec,[1,0,1,0,1,0,1,0]
;                        The MSB is assumed to come first
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
; Modified    : 
;
; Version     : Version 1, 7-Oct-93
;-            

pro bin2dec,inp,out,quiet=quiet

;
;  initialise output and find size of input
;
out = 0L
n = n_elements(inp)

;
;  is input a single string? If so break it up.
;
if n eq 1 and datatype(inp) eq 'STR' then begin
   n = strlen(inp)
   inp1 = intarr(n)
   for i=0,n-1 do inp1(i) = strmid(inp,i,1)
   inp = inp1
endif

;
;  is input a multiple string?
;
if n gt 1 and datatype(inp) eq 'STR' then begin
   inp = fix(inp)
endif


;
;  switch array around for convenience
;
x = reverse(byte(inp))

;
;  calculate integer
;
for i=0,n-1 do out = out + long(x(i))*2L^i

;
;  if not silenced then report
;
if not keyword_set(quiet) then print,out

end
