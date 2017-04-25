pro arctan,x,y,a,a_deg
;+
; NAME: 
;	ARCTAN
; PURPOSE:
;	Generalized arctan function that resolves the 180-degree ambiguity 
;	which is not resolved with the standard atan function.
; INPUTS:
;	x	=cos(angle), can be arrays 
;	y	=sin(angle), can be arrays
; OUTPUTS:
;	a	=angle [0<a<2*pi] in radian
;	a_deg	=angle [0<a<360]  in degrees
; EXAMPLE:
;	a0	=225.*(!pi/180.)
;	x	=cos(a0)
;	y	=sin(a0)
;	arctan,x,y,a,a_deg
;	print,a_deg		  --> 225.	;180-degree ambiguity is resolved
;	print,atan(y/x)*(180./!pi) --> 45.	;180-degree ambiguity is not resolved
; MODIFICATION HISTORY:
;	1990, written, aschwand@lmsal.com
;	1999 Dec 1, contributed to SSW 
;-

n	=n_elements(x)
a	=fltarr(n)
i=where((x gt 0) and (y eq 0)) &if i(0) ne -1 then a(i)=0.
i=where((x gt 0) and (y gt 0)) &if i(0) ne -1 then a(i)=atan(y(i)/x(i))
i=where((x eq 0) and (y gt 0)) &if i(0) ne -1 then a(i)=!pi/2.
i=where((x lt 0) and (y gt 0)) &if i(0) ne -1 then a(i)=!pi-atan(abs(y(i))/abs(x(i)))
i=where((x lt 0) and (y eq 0)) &if i(0) ne -1 then a(i)=!pi
i=where((x lt 0) and (y lt 0)) &if i(0) ne -1 then a(i)=!pi+atan(abs(y(i))/abs(x(i)))
i=where((x eq 0) and (y lt 0)) &if i(0) ne -1 then a(i)=!pi*3./2.
i=where((x gt 0) and (y lt 0)) &if i(0) ne -1 then a(i)=2.*!pi-atan(abs(y(i))/abs(x(i)))
a_deg	=a*180./!pi
end
