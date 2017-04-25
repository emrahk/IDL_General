;+
; Project	: EUNIS
; 
; Name		: ALIGN_MAP
;
; Purpose	: To align an input map to a referene map
;
; Category	: Imaging, mapping
;
; Syntax	: align_map, in_map, ref_map, aligned_map, offsets, cube_out, window = 30
;
; Inputs 	: in_map = map to be aligned
;			: ref_map = map to align in_map to
;			: Note: both in_map and ref_map must be the same FOV.
;			: Window = window size to be used for alignment (depends on the size of 
;			  the offset.
;
; Outputs	: aligned_map = in_map after it has been aligned to ref_map
;			: cube_out = array containing both reference map (in position 1) and 
;			  aligned_map (pos 2)
;			: offset = offset values
;
; Keywords	: xstep = to step between two aligned maps
;			
; History	: Written 6 October 2006, C. Raftery, Trinity College Dublin, Ireland
;                 Modified 9 November 2009, Zarro (ADNET)
;                 - added _extra to pass keywords to coreg_map
;
;-

pro align_map, in_map, ref_map, aligned_map, offset, cube_out, $
                xstep = xstep, window = window,_extra=extra


;; register ref_map to same size, field of view and dimensions as in_map and 
;; convert to index to use in data array
    reg_map = coreg_map( ref_map, in_map,_extra=extra)									

   
		
;; create data array and set ref_map to position 0 and in_map to position 1		

    sz = size( reg_map.data, /dim )
    cube_in = fltarr( sz( 0 ), sz( 1 ), 2 )

    cube_in( *, *, 0 ) = reg_map.data												
    cube_in( *, *, 1 ) = in_map.data


;; preform alignment between two images with map to be aligned in 
;; position 1 and ref map in position 0
    
    
    offset = cross_corr( cube_in( *, *, 1 ), cube_in( *, *, 0 ), window, sim )
    
    cube_out = cube_in
    cube_out[ *, *, 1 ] = sim
    
    
    aligned_map = in_map
    add_prop, aligned_map, data = cube_out( *, *, 1), /replace
    add_prop, aligned_map, xc = ref_map.xc, yc = ref_map.yc, /replace
  
	
    if keyword_set(xstep) then $
    xstepper, cube_out      


end


