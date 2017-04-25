;+
; NAME: coord_v2l
;
; PURPOSE: To convert pixels (x,y,z) to linear coordinates
;
; CALLING SEQUENCE:  linind=coord_v2l(xyz,size(array))
;
; PARAMETERS:   xyz 	 contains xy (or xyz) integer pixel coordinates
;               arrsz    is the result of size(array) which may be larger
;		 	 then the region contained in xyz
;
; OUTPUT:  	linind   is the linear index into an array, LONG. 
;
; CALLS: MODD                                                              
;
; HISTORY: Drafted by A. McAllister, 12-feb-93.
;
;-
FUNCTION coord_v2l,xyz0,arrsz0

   arrsz=long(arrsz0)
   xyz=long(xyz0)
   linind=long(intarr(n_elements(xyz(0,*)))) 

   case arrsz(0) of

	1: linind = xyz					;do nothing

	2: linind(*)=xyz(0,*)+xyz(1,*)*arrsz(1) 	;plane

	3: linind(*)=xyz(0,*)+xyz(1,*)*arrsz(1)+xyz(2,*)*arrsz(1)*arrsz(2)  ;cube

   endcase

   return, linind

end
