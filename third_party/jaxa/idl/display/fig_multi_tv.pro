pro fig_multi_tv,index,data,x_range,y_range,z_range,p_position,ncol,nrow,io,$
	x_label,y_label,grid
;+
; Name        : FIG_MULTI_TV()
;
; Purpose     : multi-plot of images in grey-scale representation
;
; Category    : Graphics, Utility 
;
; Explanation : A multi-plot configuration containing N columns and M rows of 
;		grey-scale plots, placed at plot positions p_position(*,i)
;		within x-ranges(*,i) and y-ranges(*,i), i=0,...,N*M-1
;
; Syntax      : fig_multi_tv,index,data,x_range,y_range,z_range,p_position,$
;			ncol,nrow,io,x_label,y_label,grid
;
; Example     : IDL> window,0,xsize=640,ysize=512 
; 		IDL> x_range	=[0,1]
;		IDL> y_range	=[0,1]
;		IDL> ncol	=2
;		IDL> nrow	=2
;		IDL> qgap	=0.1
; 		IDL> fig_multi_pos,x_range,y_range,ncol,nrow,qgap,p_position 
;               IDL> fig_multi_tv,index,data,x_range,y_range,z_range,$
;			p_position,x_label,y_label,ncol,nrow,io,grid
;
; Inputs      : index   - strarr(n) 	n structures
;		data	- fltarr(*,*,n) n images 
;               x_range - fltarr(2,n)   !x.range of n plotframes
;               y_range - fltarr(2,n)   !y.range of n plotframes
;		z_range	- fltarr(2,n)	!z.range clipping of data 
;		p_position - fltarr(4,n) !p.position of n plotframes
;		x_label - string for title on x-axis
;		y_label - string for title on y-axis
;		ncol	- number of columns in mutli-plot arrangement
;		nrow	- number of rows    in mutli-plot arrangement
;		io	- io=1 X-window screen
;			  io=1 postscript files
;		grid	- spacing of heliographic coordinate grid
;			  (if grid > 0)
;
; History     : 9-Oct-1998, Written. aschwand@lmsal.com
;-


nimages =ncol*nrow
for ip=0,nimages-1 do begin
 x1_	=p_position(0,ip)
 y1_	=p_position(1,ip)
 x2_	=p_position(2,ip)
 y2_	=p_position(3,ip)
 xr1	=x_range(0,ip)
 xr2	=x_range(1,ip)
 yr1	=y_range(0,ip)
 yr2	=y_range(1,ip)
 index_ =index(ip)
 crpix1	=index_.crpix1
 crpix2	=index_.crpix2
 crval1	=index_.crval1
 crval2	=index_.crval2
 cdelt1	=index_.cdelt1
 cdelt2	=index_.cdelt2
 nx	=index_.naxis1
 ny	=index_.naxis2
 x	=crval1+cdelt1*(findgen(nx)-(crpix1-1.))
 y	=crval2+cdelt2*(findgen(ny)-(crpix2-1.))
 nxx	=long((xr2-xr1)/cdelt1+0.5)
 nyy	=long((yr2-yr1)/cdelt2+0.5)
 xr	=xr1+cdelt1*findgen(nxx)
 yr	=yr1+cdelt2*findgen(nyy)
 image	=fltarr(nxx,nyy)
 ind	=where((xr ge x(0)) and (xr le x(nx-1)),nind)
 jnd	=where((yr ge y(0)) and (yr le y(ny-1)),njnd)
 dxmin	=min(abs(x-xr(ind(0))),i1)	;nearest pixel in array DATA
 dymin	=min(abs(y-yr(jnd(0))),j1)	;nearest pixel in array DATA

 icol	=ip mod ncol
 jcol	=ip/ncol
 !x.title=x_label	&if (icol lt ncol-1) then !x.title=''
 !y.title=y_label	&if (jcol ge 1)      then !y.title=''
 !x.style=1		&!y.style=1
 !p.position   =p_position(*,ip)
 !x.range      =x_range(*,ip)
 !y.range      =y_range(*,ip)
 plot,[xr1,xr2,xr2,xr1,xr1],[yr1,yr1,yr2,yr2,yr1] ;setup plot parameters
 !noeras=1

 if (nind ge 1) and (njnd ge 1) then begin
  for j=0,njnd-1 do image(ind,jnd(j))=float(data(i1:i1+nind-1,j1+j,ip))
  if (io eq 0) then begin
   nxw	=long(!d.x_vsize*(x2_-x1_)+0.5)
   nyw	=long(!d.y_vsize*(y2_-y1_)+0.5)
   z	=congrid(image,nxw,nyw)
  endif
  if (io ne 0) then z=image
  PLOT_TV:
  z1	=z_range(0,ip)
  z2	=z_range(1,ip)
  tv,bytscl(z,min=z1,max=z2),x1_,y1_,xsize=(x2_-x1_),ysize=(y2_-y1_),/normal
  oplot,[xr1,xr2,xr2,xr1,xr1],[yr1,yr1,yr2,yr2,yr1] 
  if (io eq 0) and ((ip mod 2) eq 0) then begin
   print,'Z-range = ',z1,z2
   read,'Change color range  (0,0=no change):  z1,z2=',c1,c2
   if (c1 ne 0) or (c2 ne 0) then begin
    z_range(*,ip)=[c1,c2]
    if (ip mod 2) eq 0then z_range(*,ip+1)=[c1,c2]
    goto,plot_tv
   endif
  endif 
 endif

 if (grid gt 0) then coord_helio_sphere,index_,grid
endfor

end
