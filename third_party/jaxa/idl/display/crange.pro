;+
; PROJECT:
;       SDAC
;
; NAME:	
;	CRANGE
;
; PURPOSE:	
;	This function returns the plot range limits for the X,Y, or Z coordinate.
;
; EXPLANATION:
;	The values of !c.xrange depends on whether plot scale is linear or log.
;	This function  returns the ACTUAL  values of the range by interrogating !(xyz).type.
;
; CATEGORY:
;	GRAPHICS
;
; CALLING SEQUENCE:
;	range = crange( XYZ )
; EXAMPLE:
;	yoffset = (!y.crange(1) - !y.crange(0)) / 30.
;
; INPUTS:
;	XYZ- a string specifying the axis of interest.
;
; OUTPUTS:
;	None, Function returns the actual values of the range.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; MODIFICATION HISTORY:
; 	Written by:	RAS, 1/6/93
;	Version 2, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;
;-
FUNCTION CRANGE, XYZ
;
if (datatype( xyz ) eq 'STR') then begin 

	test = strupcase(xyz)

		if (test eq 'X') then begin
			if (!x.type and 1L) eq 0 then $
				ans = !x.crange else ans = 10.^!x.crange
			return, ans
		endif

		if (test eq 'Y') then begin
			if (!y.type and 1L) eq 0 then $
				ans = !y.crange else ans = 10.^!y.crange
			return, ans
                endif

		if (test eq 'Z') then begin
			if (!z.type and 1L) eq 0 then $
				ans = !z.crange else ans = 10.^!z.crange
			return, ans
		endif

endif

print,"INVALID ARGUMENT, use 'X', 'Y', or 'Z'"
ans = 0

return, ans
;
END

