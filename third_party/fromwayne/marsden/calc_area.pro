pro calc_area,idfs,idfe,area,xra=xra,$
              cluster=cluster,xdec=xdec
;*******************************************************
; Program calcuates the effective area of the 
; HEXTE collimators towards a specified source 
; direction for a given range of idfs. The 
; variables are:
;      ra,dec..........source equatorial coords. (deg)
;   idfs,idfe..........start and stop idfs
;        area..........effective area (cm^2)
;    xra,xdec..........SC pointing direction
;     cluster..........1 or 2
;    response..........2D HEXTE collimator resp.
;         x,y..........spatial callibration of above
; Requires subroutines get_radec.pro and radec_xyz.pro, 
; and requires previous running of the program resp.pro 
; to load the angular response array into the common 
; block. First define common block:
;*******************************************************
common response,response,x,y,ra,dec
;*******************************************************
; Do usage:
;*******************************************************
if (n_elements(ra) eq 0)then begin
   print,'USAGE: CALC_AREA,IDFSTART,IDFEND,' + $
         'AREA(CM^2),[XRA=XRA],[XDEC=XDEC],' + $
         '[CLUSTER=1 OR 2]'
   return
endif
;*******************************************************
; Get some needed arrays & constants
;*******************************************************
id1 = min([idfs,idfe]) & id2 = max([idfs,idfe])
idfe = id2 
idfs = id1
num = idfe - idfs + long(1)
area = replicate(200.,4.,num)
;*******************************************************
; Get the spacecraft x and y pointing directions
;*******************************************************
get_radec,idfs,idfe,xra,xdec,yr=yra,yd=ydec
if (max(xra) eq 0. and max(xdec) eq 0)then begin
   print,'max(xra) =0.!'
   stop
   return
endif
;*******************************************************
; Convert y-axis RA & DEC to cartesian coordinates.
; Calculate the angle of the collimator response 
; pattern with respect to the celestial equator.
;*******************************************************
radec_xyz,yra,ydec,xyz_y
arg = xyz_y(1,*)/sqrt(xyz_y(0,*)^2.+xyz_y(1,*)^2.)
rotangle = double(360.)*reform(asin(arg),num)/(2d*!dpi)
;*******************************************************
; Loop through the idfs and calculate the response
;*******************************************************
for i=0,num-1 do begin
 resp = rot(response,rotangle(i))
 xx = x + xra(i) & yy = y + xdec(i)
; print,'X: ra=',xra(i),'dec=',xdec(i)
; print,'SOURCE: ra=',ra,'dec=',dec
 delx = abs(xx - ra) & dely = abs(yy - dec)
 inx = where(delx eq min(delx))
 iny = where(dely eq min(dely))
 area(*,i) = resp(inx(0),iny(0))*area(*,i)
; print,'area=',area(*,i)
; print,'*************'
endfor
;*******************************************************
; That's all ffolks.
;*******************************************************
return
end
  



