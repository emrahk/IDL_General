;+
; PROJECT:
;       SDAC
; 	
; NAME:
;	GRAPHICS
;
; PURPOSE:
; 	This procedure switches to graphics from alpha page under Tektronix.
;
; CATEGORY:
;	Graphics.
;
; calling sequence: 
;	GRAPHICS
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
;	A command string (string(29b)) is issued through print to switch the terminal
;	
;
; MODIFICATION HISTORY:
; 	Written by:	AKT
;	Version 2:	RAS, 23-Mar-1995, only called for Tektronix
;	Version 3, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-
pro graphics_page,x

if !d.name eq 'TEK' then begin
	graph = string(29b)
	print,graph
endif
end
