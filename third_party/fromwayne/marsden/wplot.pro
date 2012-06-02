pro wplot,base,xs,ys,draw,rw,rww
;*****************************************************************
; Routine makes a plotting area
; Variables are:
;          base..............Widget base
;            xs..............size in x-direction
;            ys..............size in y-direction
;            rw..............sub-base
;          draw..............plotting area  
; 6/10/94 Current version
;*****************************************************************
rw = widget_base(base,/frame,/row)
rww = widget_base(rw,/column)
draw = widget_draw(rww,xsize = xs,ysize = ys)
;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end
 
