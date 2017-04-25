;+
; PROJECT:
;       SDAC
; 	
; NAME:
;	ALPHA_PAGE
;
; PURPOSE:
; 	This procedure switches to alpha from graphics page under Tektronix.
;
; CATEGORY:
;	GRAPHICS
;
; CALLING SEQUENCE:
;	ALPHA_PAGE
;
; INPUTS:
;	None
;
; OUTPUTS:
;	None
;
; SIDE EFFECTS:
;	Issues a carriage return if called.
;
; RESTRICTIONS:
;
; PROCEDURE:
;	A command string (string(24b)) is issued through print to switch the terminal
;
; COMMON BLOCKS:
;	None.
;
; MODIFICATION HISTORY:
; 	Written by:	AKT
;	Version 2:	RAS, 23-Mar-1995, only called for Tektronix
;	Version 3, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-
pro alpha_page,x

if !d.name eq 'TEK' then begin
	alpha = string(24b)
	print,alpha
endif
end
