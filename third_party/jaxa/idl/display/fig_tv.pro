pro fig_tv,image,x_range,y_range,z_range,p_position,io,x_label,y_label,ct
;+
; Name        : FIG_TV()
;
; Purpose     : plot of image in grey-scale representation
;		at predifined location in plot
;
; Inputs	image	- fltarr(*,*)   image
;               x_range - fltarr(2)     !x.range of n plotframes
;               y_range - fltarr(2)     !y.range of n plotframes
;		z_range	- fltarr(2)	!z.range clipping of data 
;		p_position - fltarr(4)  !p.position of n plotframes
;		x_label - string for title on x-axis
;		y_label - string for title on y-axis
;		io	- io=1 X-window screen
;			  io=1 postscript files
;		ct      - color table
;			  invert if negative 
;
; Contact     : aschwanden@sag.lmsal.com
;-

 x1_	=p_position(0)
 y1_	=p_position(1)
 x2_	=p_position(2)
 y2_	=p_position(3)
 xr1	=x_range(0)
 xr2	=x_range(1)
 yr1	=y_range(0)
 yr2	=y_range(1)
 dim	=size(image)
 nx	=dim(1)
 ny	=dim(2)
 dx	=(xr2-xr1)/nx
 dy	=(yr2-yr1)/ny
 x	=xr1+dx*(findgen(nx)+0.5)
 y	=yr1+dy*(findgen(ny)+0.5)

 !x.title=x_label
 !y.title=y_label	
 !x.style=1		
 !y.style=1
 !p.position   =p_position(*)
 !x.range      =x_range(*)
 !y.range      =y_range(*)
 plot,[xr1,xr2,xr2,xr1,xr1],[yr1,yr1,yr2,yr2,yr1] ;setup plot parameters
 !noeras=1

 if (io eq 0) then begin
  nxw	=long(!d.x_vsize*(x2_-x1_)+0.5)
  nyw	=long(!d.y_vsize*(y2_-y1_)+0.5)
  z	=congrid(image,nxw,nyw)
 endif
 if (io ne 0) then z=image

 PLOT_TV:
 c1	=z_range(0)
 c2	=z_range(1)
 if ((c1 lt 0) and (c2 lt 0)) then begin       ;logarithmic display
   c1   =abs(c1)        &c2=abs(c2)
   z   =c1+(c2-c1)*(alog(z>1)-alog(c1))/(alog(c2)-alog(c1))
 endif
 zm    =max(z)
 if (ct lt 0) then begin &z=zm-z &c11=c1 &c1=zm-c2 &c2=zm-c11 &endif
 tv,bytscl(z,min=c1,max=c2),x1_,y1_,xsize=(x2_-x1_),ysize=(y2_-y1_),/normal
 oplot,[xr1,xr2,xr2,xr1,xr1],[yr1,yr1,yr2,yr2,yr1] 

end
