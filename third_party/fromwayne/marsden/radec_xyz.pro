pro radec_xyz,ra,dec,xyz
;*******************************************************
; Program converts coordinates from RA, DEC (deg.) to 
; cartesian unit vectors. Variable are:
;     ra,dec........Equatorial coordinates (deg.)
;        xyz........Cartesian coordinates [x,y,z]
; First do usage:
;*******************************************************
if (n_elements(ra) eq 0)then begin
   print,'USAGE: RADEC_XYZ,RA_DEG,DEC_DEG,XYZ_NORM'
   return
end
;*******************************************************
; Do some constants
;*******************************************************
deg_rad = 2d*!dpi/double(360.)
theta = !dpi/2d - deg_rad*dec
phi = deg_rad*ra
xyz = dblarr(3,n_elements(ra))
;*******************************************************
; Find x,y & z and normalize
;*******************************************************
x = sin(theta)*cos(phi)
y = sin(theta)*sin(phi)
z = cos(theta)
nrm = sqrt(x*x + y*y + z*z)
x = x/nrm
y = y/nrm
z = z/nrm
xyz(0,*) = x
xyz(1,*) = y
xyz(2,*) = z
;*******************************************************
; That's all ffolks
;*******************************************************
return
end
