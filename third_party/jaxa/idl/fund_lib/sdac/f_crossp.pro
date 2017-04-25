;+
; PROJECT:
;       SDAC
; NAME:
;       F_CROSSP
;
; PURPOSE:
;       This function returns  the Vector (Cross) product of vectors v1 and v2. 
;
; CATEGORY:
;	MATH, UTILITY, GEOMETRY
;
; CALLING SEQUENCE:
;	Result = F_CROSSP(v1,v2)
;
; EXAMPLES:
;	        yc=f_crossp(zc,xc)
;
; INPUTS:
;	v1 = 3 element vector or n vector arrays, 3 x n format.
;	v2 = 3 element vector or n vector arrays, 3 x n format.
;
; OUTPUTS:
;	Result = 3 element floating vector or 3 x n array.
;
; RESTRICTIONS:
;	Vectors must have 3 elements or arrays must be 3 x n
;
; PROCEDURE:
;	v1 X v2 = | i  j  k  | = (b1c2 - b2c1)i+(c1a2-c2a1)j+(a1b2-a2b1)k
;		  | a1 b1 c1 |
;		  | a2 b2 c2 |
;
; MODIFICATION HISTORY:
;	Written, DMS, Aug, 1983;
;       Mod. 06/22/95 by AES - renamed to f_crossp
;	Mod. 05/09/96 by RCJ. Added documentation.
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-
;
function f_crossp,v1,v2
	on_error,2                      ;Return to caller if an error occurs
	vsize=size(v1)
if n_elements(v1) eq 3 then $
	return,[v1(1)*v2(2)-v2(1)*v1(2), V1(2)*v2(0)-V2(2)*v1(0), $
		v1(0)*v2(1)-v2(0)*v1(1) ] $
	else if vsize(0) eq 2 then $
	return,$
	[v1(1,*)*v2(2,*)-v2(1,*)*v1(2,*), $
	V1(2,*)*v2(0,*)-V2(2,*)*v1(0,*), $
	v1(0,*)*v2(1,*)-v2(0,*)*v1(1,*) ] 
return,0.
end
