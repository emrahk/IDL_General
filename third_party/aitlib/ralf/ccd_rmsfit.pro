PRO CCD_RMSFIT, x, a, funct, deriv
;+
; NAME:
;	CCD_RMSFIT
;
; PURPOSE:
;	Return function value and derivatives of fitting function
;	y=|a(0)|+|a(1)|*x+|a(2)|*x^2, used in CCD_STAT.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_RMSFIT, x, a, [ funct, deriv ]
;
; INPUTS:
;	X : Vector with x values.
;	A : Array a(0:2). 
; 
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	FUNCT : Function value - calculated m_abs.
;	DERIV : Derivatives of FUNCT resp. to the a(*).
;
; OPTIONAL OUTPUT PARAMETERS:
;       NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

funct=abs(a(0))+abs(a(1))*x+abs(a(2))*x*x

deriv=[[a(0)/abs(a(0))*REPLICATE(1.0d0,n_elements(x))], $
      [a(1)/abs(a(1))*x],[a(2)/abs(a(2))*x*x]]

RETURN
END
