pro fig_multi_pos,x_range,y_range,ncol,nrow,qgap,p_position 
;+
; Project     : YOHKOH/SXT,HXT - SOHO/EIT,CDS - TRACE 
;
; Name        : FIG_MULTI_POS()
;
; Purpose     : multi-plot !p.positions maintaining correct aspect ratio of 
;		x- and y-axis 
;
; Category    : Graphics, Utility 
;
; Explanation : A mutli-plot configuration containing N columns and M rows of 
;		plot frames is arranged. The aspect ratio of the images 
;		(!y.range/!x.range) is correctly scaled, regardless of the 
;		aspect ratio of the device window (!d.y_vsize y_device/x_device).
;
; Syntax      : IDL> fig_multi_pos,x_range,y_range,ncol,nrow,qgap,p_position 
;
; Example     : IDL> window,0,xsize=640,ysize=512 
; 		IDL> x_range	=[0,1]
;		IDL> y_range	=[0,1]
;		IDL> ncol	=3
;		IDL> nrow	=3
;		IDL> qgap	=0.1
; 		IDL> fig_multi_pos,x_range,y_range,ncol,nrow,qgap,p_position 
;		IDL> phi=findgen(361)/float(360)
;		IDL> for i=0,ncol*nrow-1 do
;		IDL>  !p.position=p_position(*,i)	
;		IDL>  plot,cos(phi),sin(phi)
;		IDL> endfor
;		(This example draws a 3x3 multi-plots of circles with correct 
;		ascpect ratios. Note that !p.multi=[0,3,3,0,0] would turn 
;		circles into ellipses)
;
; Inputs      : x_range - !x.range of individual plots
;               y_range - !y.range of individual plots
;		ncol	- number of columns in mutli-plot arrangement
;		nrow	- number of rows    in mutli-plot arrangement
;		qgap	- gap between plots, measured with respect to 
;		individual plot size 
;
; Outputs     : p_position - fltarr(4,n) of indiviudal plot positions
;		      e.g. place plot_i by !p.position=p_position(*,i)  
;
; Side effects: Window size has to be defined before calling FIG_MULTI_POS, 
;		because it uses device parameters !d.y_vsize and !d.x_vsize
;
; History     : 9-Oct-1998, Written. aschwanden@sag.lmsal.com
;-


asp_window	=float(!d.y_vsize)/float(!d.x_vsize)    
					;aspect ratio x-window (e.g. 512/640)
aspect_yx	=(y_range(1)-y_range(0))/(x_range(1)-x_range(0))
x_	=(ncol+(ncol+1)*qgap)			;x-width of multiplot in pixels
y_	=(nrow+(nrow+1)*qgap)*aspect_yx		;y-width of multiplot in pixels
as	=y_/x_					;aspect ratio of multiplot
if (as le asp_window) then begin 
 xscale=1./x_ 
 yscale=(as/asp_window)/y_ 
endif
if (as gt asp_window) then begin 
 yscale=1./y_ 
 xscale=(asp_window/as)/x_ 
endif
n	=ncol*nrow
k	=0
p_position=fltarr(4,n)
for j=0,nrow-1 do begin
 jj	=nrow-1-j
 for i=0,ncol-1 do begin
  p_position(0,k)=0.5+xscale*(-0.5*x_+( i*(1.+qgap)+qgap)*1.)	
  p_position(1,k)=0.5+yscale*(-0.5*y_+(jj*(1.+qgap)+qgap)*aspect_yx)	
  p_position(2,k)=p_position(0,k)+xscale*1.
  p_position(3,k)=p_position(1,k)+yscale*aspect_yx
  k=k+1
 endfor  
endfor
end
