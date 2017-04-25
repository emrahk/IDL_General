function rotate_3d, array_3d, rotate_param
;
;+
;   Name: rotate_3d
;
;   Purpose: apply rsi 'rotate' to 3d data; multiples of 90deg w/opt transpose
;
;   Input Parameters:
;      array_3d - the input cube
;      rotate_param - per description in rsi 'rotate' documentation
;                 
;   Output:
;      function returns rotated cube
;  
;   Calling Sequence:
;      rot3d=rotate_3d(datacube,rotate_parameter)
;
;   Calling Examples:
;      IDL> help,rotate_3d(lindgen(512,128,5),1)       ; 90 deg clockwise
;       <Expression>    LONG      = Array[128, 512, 5]
;
;   History:
;     10-nov-1999 - S.L.Freeland - hard to believe no one has done thi
;                   but I could not find one with intuitive name...
;
;-

if n_elements(rotate_param) eq 0 then rotate_param=1   ; def=my favorite
nimages=data_chk(array_3d,/nimage)

case nimages of 
   0: begin
      retval=-1
      box_message,['Need input 2d or 3d data...',$
		   'IDL> r3d=rotate_3d(cube,rotateparam)']
   endcase
   1: retval=rotate(array_3d,rotate_param)
   else: begin
      template=rotate(array_3d(*,*,0),rotate_param)
      retval=make_array(data_chk(template,/nx),      $
			data_chk(template,/ny),       $
			type=data_chk(template,/type),nimages)
      retval(0,0,0)=template
      for i=1,nimages-1 do retval(0,0,i)= $
			rotate(array_3d(*,*,i),rotate_param)
	       
   endcase
endcase

return,retval

end
