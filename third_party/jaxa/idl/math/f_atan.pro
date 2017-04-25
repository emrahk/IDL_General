;+
;
; NAME:
;	F_ATAN
;
; PURPOSE:
;	Shell around IDL's ATAN function to prevent the NaN's in the returned value.  NaN's are set to 0.
;
; PROJECT:
;	HESSI
;
; CATEGORY:
;	UTIL
;
; CALLING SEQUENCE:
;	ang = f_atan(x)  or  ang = f_atan(y,x)
;
; INPUTS:
;   X - The tangent of the desired angle.
;   Y - An optional argument. If this argument is supplied, ATAN returns the angle
;      whose tangent is equal to Y/X. If both arguments are zero, the result is 0.
;
; EXAMPLE:
;   IDL> print,f_atan(1.) * !radeg
;      45.0000
;   IDL> print,f_atan(.3,.6)
;      0.463648
;
; CALLS:
;	atan
;
; OUTPUT:
;	Function returns the angle (in radians) whose tangent is x, or y/x
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;  none
;
; MODIFICATION HISTORY:
;	Written: 29-May-2002, kim.tolbert@gsfc.nasa.gov
;
;-


function f_atan, y, x

if n_params() eq 2 then aa = atan(y,x) else aa = atan(y)

q = where (finite(aa) eq 0, nnan)
if nnan gt 0 then aa(q) = 0.0

return, aa
end