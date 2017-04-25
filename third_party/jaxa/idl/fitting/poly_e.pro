FUNCTION POLY_E,X,C,E
;+
; NAME:
;	POLY_E
;
; PURPOSE:
;	Evaluate a polynomial function of a variable.
;
; CATEGORY:
;	C1 - Operations on polynomials.
;
; CALLING SEQUENCE:
;	Result = POLY_E(X,C,[E])
;
; INPUTS:
;	X:	The variable.  This value can be a scalar, vector or array.
;
;	C:	The vector of polynomial coefficients.  The degree of 
;		of the polynomial is N_ELEMENTS(C) - 1.
;
;	E: 	The vector of exponents.
;
; OUTPUTS:
;	POLY_E returns a result equal to:
;		 C(0) + c(1) * X + c(2)*x^2 + ...
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward.
;
; MODIFICATION HISTORY:
;	Andrew Hayes	16 AUG 2000
;-

typeflag= (size(x))[(size(x))[0]+1] > (size(c))[(size(c))[0]+1] > (size(e))[(size(e))[0]+1] > $
	4*max ((e gt 0) ne e)	;force float computation if there's a negative exponent

res=make_array(  size=size(x), type=typeflag  )
case typeflag of
	2: y=fix(x)
	3: y=long(x)
	4: y=float(x)
	5: y=double(x)
	6: y=complex(x)
	9: y=dcomplex(x)
	else: y=x
endcase 

for i=0,n_elements(e)-1 do res=res+c[i]*y^e[i]

return, res
end
