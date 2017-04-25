;+
; NAME: coord_l2v
;
; PURPOSE: To convert linear pixel coordinates to x,y,z pixels.
;
; CALLING SEQUENCE:  xyz=coord_l2v(linind,size(array))
;
; PARAMETERS:   linind   is the linear index into an array 
;               arrsz    is the result of size(array)
;
; OUTPUT:       xyz 	  contains x, xy, or xyz integer pixel coordinates. 
;
; RETURN TYPE: INTEGER
;
; RESTRICTIONS: The 3-D option is limited by the limited memory given to
;		nested routines. It is impossible to do large arrays.
;
; CALLS: MODD                                                               
;
; HISTORY: Drafted by A. McAllister, 12-feb-93.
;	   Reform keyword returns the same shape as array, A.McA. 25-mar-93.
;-
FUNCTION coord_l2v,linind,arrsz,reform=reform 

   pix_num=n_elements(linind)

   case arrsz(0) of

	1: xyz=linind				;do nothing

	2: begin				;plane

		xyz=intarr(2,pix_num)
   		xyz(0,*) = fix(modd(linind,arrsz(1)))	
   		xyz(1,*) = fix(linind/arrsz(1))
		
		if keyword_set(reform) then xyz=reform(xyz,2,arrsz(1),arrsz(2))

	   end

	3:begin					;cube

		xyz=intarr(3,pix_num)
   		xyz(0,*) = fix(modd(modd(linind,arrsz(1)*arrsz(2)),arrsz(1)))
   		xyz(1,*) = fix(modd(linind,arrsz(1)*arrsz(2))/arrsz(1))
		xyz(2,*) = fix(linind/(arrsz(1)*arrsz(2)))

		if keyword_set(reform) then xyz=reform(2,arrsz(1),arrsz(2),arrsz(3))

	   end
   endcase

   return, xyz

end
