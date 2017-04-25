pro align_cube_correl, index, incube, oindex, outcube, $
		       reference=reference, offsets=offsets, $
                       interp=interp, cubic=cubic
;+
;   Name: align_cube_correl
;
;   Purpose: align a data cube via cross correlation; update coordinates
;
;   Input Parameters:
;      index - the header structures   ; SSW standards w/pointing fields
;      data  - the data cube       
;      offsets - the derived offesets fltarr(2,nimage) 
;
;   Calling Sequence:
;        align_cube_correl, index, incube, outindex, outcube ; header & cube 
;   -OR- align_cube_correl, incube, outcube                  ; just cube?
;   -OR- align_cube_correl, inoutcube                        ; just cube?
;     
;   History:
;      15-October-1998 - S.L.Freeland
;      Distillation based on review of SSW correlation/alignment SW  by:
;         G.L.Slater  (SXT..)     get_off, cube-align, translate
;         J.P.Wuelser (SXT/MEES)  korrel, poly_movie
;         T.Tarbell   (TRACE)     tr_get_disp
;       5-Feb-2003 - S.L.Freeland - assure all calling modes permitted
;
;      Proto type - When called with 'index' structures, will
;      adjust the 'pointing' standard tags to reflect alignement and
;      return in 'outindex'
;   
;   Side Effects:
;      Called with one paramater, (input cube), the input is overwritten
;      by the aligned version (memory conservation, for example)
;
;   Method: 
;      call get_correl_offsets to get the cross correlation offsets for cube
;      call image_translate to align the cube (via poly2d method)
;
;   Category:
;      2D , 3D, Image, Alignment, Cross Correlation      
;
;   Restrictions:
;      update of coordinates not yet implemented
;-

npar=n_params()
case 1 of 
   data_chk(index,/struct) and npar ge 2: mode = 1
   data_chk(index,/defined): begin
      mode=2      
   endcase     
   else: begin
     box_message,['   IDL> align_cube_correl, index , data, oindex, odata',$
		   '-OR-', $
		   '   IDL> align_cube_correl, data, odata', $
		   '-OR-', $
		   '   IDL> align_cube_correl, data']
      return
   endcase
endcase   
help,mode,npar    
  
; method 1. - Tarbell, based on B.Lin 
case mode of
   1: offsets=get_correl_offsets(incube,reference=reference)
   else: offsets=get_correl_offsets(index,reference=reference)
endcase
case 1 of 
  mode eq 1 and n_params() ge 4: begin 
     outcube=image_translate(incube,offsets,cubic=cubic,interp=interp)
  endcase
  mode eq 1 and n_params() eq 2: begin 
     incube=image_translate(temporary(incube),offsets,cubic=cubic,interp=interp)
  endcase
  mode eq 2 and npar eq 1: begin
     index=image_translate(temporary(index),offsets,cubic=cubic,interp=interp)
  endcase
  mode eq 2 and npar eq 2: begin
     incube=image_translate(index,offsets,cubic=cubic,interp=interp)
  endcase
  else: box_message,'Option not yet available'
endcase
return
end
  
   
