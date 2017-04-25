pro smooth_flatedge,z,s,w

; PURPOSE:
;	smoothing function which flat edge 
;
; INPUT:
;	z	= 2D image
;	w	= number of pixels of ramp (to be set flat)
;
; OUTPUT:
;	s	= smoothed 2D image
;
; HISTORY:
;	aschwand@lmsal.com


s	=smooth(z,w)
dim	=size(z)
nx	=dim(1)
ny	=dim(2)
for i=0,w-1 do s(i,*)=s(w,*)
for i=nx-1-w,nx-1 do s(i,*)=s(nx-1-w,*)
for j=0,w-1 do s(*,j)=s(*,w)
for j=ny-1-w,ny-1 do s(*,j)=s(*,ny-1-w)
end
