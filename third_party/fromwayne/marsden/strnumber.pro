function strnumber, st, val
;+
; NAME:
;	STRNUMBER
; PURPOSE:
;	Function to determine if a string is a valid numeric value.
;
; CALLING SEQUENCE:
;	result = strnumber( st, [val] )
;
; INPUTS:
;	st - any IDL scalar string
;
; OUTPUTS:
;	1 is returned as the function value if the string st has a
;	valid numeric value, otherwise, 0 is returned.
;
; OPTIONAL OUTPUT:
;	val - (optional) value of the string.  real*8
;
; WARNING:
;	(1)   In V2.2.2 there was a bug in the IDL ON_IOERROR procedure that
;	      will cause the following statement to hang up IDL
;
;	      IDL> print,'' + string( strnumber('xxx') )
;	      This bug was fixed in V2.3.0
;	(2)   In V2.3.2, an IDL bug is seen in the following statements 
;	      IDL> st = 'E'
;	      IDL> q = strnumber(st)  & print,st
;	      The variable 'st' gets modified to an empty string.   This problem
;	      is related to the ambiguity of whether 'E' is a number or not 
;	      (could be = 0.0E).    This bug was fixed in V3.0.0
;	(3)   STRNUMBER was modified in February 1993 to include a special 
;	      test for empty or null strings, which now returns a 0 (not a 
;	      number).     Without this special test, it was found that a
;	      empty string (' ') could corrupt the stack.
; HISTORY:
;	version 1  By D. Lindler Aug. 1987
;       test for empty string, W. Landsman          February, 1993
;-
 if N_params() EQ 0 then begin
      print,'Syntax - result = strnumber( st, [val] )
      return, 0
 endif

 newstr = strtrim( st )

 if ( newstr EQ '' ) then return, 0    ;Empty string is a special case

 On_IOerror, L1			;Go to L1 if conversion error occurs

 val = double( newstr )
 return, 1			;No conversion error

 L1: return, 0			;Conversion error occured

 end
