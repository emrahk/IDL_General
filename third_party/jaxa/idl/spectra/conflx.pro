FUNCTION CONFLX,TE_6,WAVE,OPT,ERG=ERG,APPROX=APPROX
;+
; NAME:
;	CONFLX
;
; PURPOSE:
;	Calculate continuum flux in (ph s-1 A-1) or (erg s-1 A-1).
;	The resultant flux assumes an emission measure of 1.e50 cm^3.
;
; CALLING SEQUENCE:
;	Continuum_flux = CONFLX(TE_6,WAVE)		; photons s-1 A-1
;	Continuum_flux = CONFLX(TE_6,WAVE,/erg)		; erg     s-1 A-1
;
; INPUTS:
;	TE_6    = Electron temperature in MK.  (1-d vector or scalar)
;	WAVE	= Wavelength in Angstroms.     (1-d vector or scalar)
;
; OPTIONAL INPUTS:
; 	OPT	 = Options: (must be scalar integer)
;	Bit Value   Effect
;	 0    1     This bit sets the units of the flux calculations. 
;		    If this bit is not set: photons s-1 
;		    If this is set:         erg s-1.
;	 1    2     This bits controls the calculation which is used
;		    to compute the continuum flux.
;		    If this bit is NOT set:  approx of Mewe, Groenschild,
;		    and van den Oord (1985, Paper V).
;		    If this bit IS set:  Mewe, Lemen, and van den Oord (1986,
;		    Paper VI).
;
;  ****	Prior to 29-Sep-94 default was OPT = 0 *****
;  ****	After    29-Sep-94 default is  OPT = 2 *****
;
;	ERG	= 1 Will force Bit 0 of OPT to be set: calculation in erg s-1.
;	APPROX	= 1 Will unset Bit 1 of OPT (to use Mewe Paper V approximations)
;
;  **** ERG and/or APPROX keywords will be ignored if OPT is defined. *****
;
; OUTPUTS:
;	Function result  = Vector (or array) continuum fluxes.
;
;	If one input is a scalar and other is a vector, the result will be 
;	a vector which is the length of the input variable.
;
;	If both inputs are vectors, the output will be a two-dimensional
;	array of the type: FLTARR(N_ELEMENTS(TE_6),N(ELEMENTS(WAVE)).
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	TE_6 	must not be of complex type.
;	WAVE 	must not be of complex type.
;
;	TE_6 and WAVE must be scalers or 1-d vectors.  Multi-dimensional
;	arrays are not permitted and may cause the routine to halt with 
;	an error.
;
; PROCEDURE:
;   OPT = 0 (OPT and 2) eq 0 [bit 0 is not set]
;	Calculation is based on equations no. 29 and 30
;	in R. Mewe, J. Schrijver, and J. Sylwester (A. & A. Suppl., 40, 327.), 
;	but the G_c formula was updated and is given by Mewe, Gronenchild, 
;	and van den Oord (Paper V, A. & A. Suppl. Ser. 62, 197).  Equation (3)
;	of Paper V reads as:
;	  G_c = 27.83*(Te_6+0.65)^(-1.33) + 0.15 * wave^0.34 * Te_6^0.422
;
;	The approximation works well in the range of the BCS (e.g., 1.8 - 3.2 A).
;
;   OPT => (OPT and 2) eq 2  [bit 1 is set]
;	Calculation is performed using the ACGAUNT routine given by Mewe, 
;	Lemen, and van den Oord (Paper VI, 1986, A. & A. Suppl., 65, 511.).
;
;	If OPT is not set, will default to OPT=2
;
; MODIFICATION HISTORY:
;	Mar, 1986,	Written, J.R. Lemen, MSSL
;	Dec, 1987,	J.R. Lemen, LPARL
;		Removed the restriction that either TE_6 or WAVE could be a
;		vector, but not both.  See discussion above under "OUTPUTS:".
;		The option to use the improved approximation given by Mewe,
;		Lemen, and van den Oord (1986) was added.
;	Feb, 1988,	J.R. Lemen, LPARL
;		Added the option of erg s-1 A-1 or ph s-1 A-1
;	Feb, 1991,	N.Nitta
;		Changed to IDL Version 2.0 format (getting rid of linkimage)     
;	31-jul-93, JRL, Added check on exponent to prevent Floating underflow message
;       22-sep-94, JMM, removed check on the exponent, do calculation in logs
;                       to avoid the underflows.
;	29-sep-94, JRL, Added ERG and APPROX switches.  Changed default to opt=2
;	 1-oct-94, JRL, Removed a diagnostic stop
;       22-Feb-96, JRL, Minor change to document header
;-

;	Convert TE_6 and WAVE to 1-d vectors:

	TE_x = Te_6*replicate(1.,n_elements(Te_6)) & TE_x(0) = TE_x(0:*)
	WAVV = WAVE*replicate(1.,n_elements(WAVE)) & WAVV(0) = WAVV(0:*)

	if N_elements(OPT) eq 0 then begin
	   OPT = 2
	   if keyword_set(approx) then OPT = 0		; Keywords do not override
	   if keyword_set(erg)    then OPT = OPT + 1	;- OPT if it is supplied
        endif
	if (OPT and 2) eq 2 then begin

;	Mean gaunt factor Gaunt:	Gaunt = Mean Gaunt factor

;	Use the new approximation:
	  nx = n_elements(Te_x) & ny = n_elements(WAVV)
	  Gaunt = fltarr(nx,ny)				; Set up output variable
 	  GAUNT = acgaunt(wavv,te_x) 	; call ACGAUNT directly
	  if ny eq 1 then Gaunt = Gaunt(0:*)		; Collapse 2-d array if
        endif else begin				;-  only 1-d input.

;	Use the old approximation  (Eq (3) from Paper V)
	  Gaunt1= 27.83*(Te_x+0.65)^(-1.33) 
	  Gaunt2= 0.15 * ( Te_x^0.422 # wavv^0.34 )
	  Gaunt1= Gaunt1 # replicate(1.,n_elements(wavv)); Make 2-d if necessary
	  Gaunt = Gaunt1 + Gaunt2
	endelse
;  
; 	gf=Gaunt         ; for a test purpose
;
;	Y  Factor (the Boltzman factor)
	Y = 143.9/(TE_x#wavv)		; wavv in Ang, TE_x in MK

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Flux calculation:  (photons sec-1 A-1)
	if (OPT and 1) eq 0 then begin
; This stuff ought to be done in logs, jmm 9/22/94
           clog = alog(2.051e28 * 5.034e7)
                
           FLUX =  exp(clog-Y) * Gaunt/(sqrt(TE_x)#wavv)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Flux calculation:  (erg sec-1 A-1)
	endif else begin

           clog = alog(2.051e28)
           FLUX =  exp(clog-Y) * Gaunt/(sqrt(TE_x)#(wavv^2))
        endelse
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	IF N_ELEMENTS(TE_x) EQ 1 THEN FLUX = FLUX(0:*) ; Make (1,N) a (N) vector

	return, FLUX
	end
