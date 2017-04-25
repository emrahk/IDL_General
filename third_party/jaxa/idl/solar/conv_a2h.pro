FUNCTION conv_a2h, ang, date0, arcmin=arcmin, off_limb=oflb, string=string
;+
; NAME:
;        CONV_A2H
; PURPOSE:
;          Converts arcmins-from-suncenter coordinates to heliographic
;	   coordinates.
; METHOD:  
;	 This is a vectorized version and replacement of PIX2HEL. It calls 
;	 GET_PB0R with the date to get the line-of-sight axial tilt. The SXT 
;	 roll angle correction is no longer default, allowing use with GBO data. 
;	 It will also work with any CONSISTENT pixel resolution.
; CALLING SEQUENCE:  
;	 lonlat = conv_a2h(ang, date)
;	 lonlat = conv_a2h(ang, date, /string)
;	 lonlat = conv_a2h(ang, date, off_limb=off_limb)
; INPUT:
;	ang	- is a vector of angles from sun center in default units of
;		  arcseconds.  It should be 2xN.
;			(0,*) = angle in E/W direction with W positive
;			(1,*) = angle in N/S direction with N positive
;	date	- Unless the date is supplied, today's date is used.
;		  This will affect the Solar axial tilt, B0. 
; OUTPUT:
;	lonlat  - Heliographic coordinates in decimal degrees.
;                       (0,*) = longitude (degrees) W positive
;                       (1,*) = latitude (degrees) N positive
;		  If the input coordinates are off the solar limb, 
;		  the output is the radial projection back to the nearest 
;		  point on the limb.
;		  Output is FLOAT (or DOUBLE if input is DOUBLE)
; OPTIONAL KEYWORD INPUT:
;	arcmin	- when set the input is in arcminutes.
;	string	- If set, returns coordinates as strings
;		  with 'N/S' and 'W/E' attatched.
; OPTIONAL KEYWORD OUTPUT:
;	off_limb- A flag which is set to 1 when there are 
;		  points off the limb.
; CAUTIONS:	 Note the treatment of points off the limb.
; CALLS: 	ANYTIM2INTS, GET_PB0R.                                            
; HISTORY:
;	Written by A.McAllister Jun-93
;	16-Jun-93 (MDM) - Various changes.
;       17-Jun-93 (MDM) - Renamed variable XYZ to avoid conflict with astron
;                         library function called XYZ
;	22-Jun-93 (MDM) - Corrected typo
;	29-Jun-93 (AHM) - Fixed up the large longitude and pole point code.
;	 3-Aug-93 (MDM) - Corrected the date option
;			- Incorporated  27-jul-93 (AHM) bug fix in large 
;			  longitude code.
;	16-Oct-93 (MDM) - Changed the header information
;-

nout = n_elements(ang)/2

;-------------------- Get the Date
;
if (n_elements(date0) eq 0) then date = anytim2ints(!stime) $
                        else date = anytim2ints(date0)
if ((n_elements(date) ne nout) and (n_elements(date) ne 1)) then begin
    message, 'Improper number of dates.  Using first date for all points.', /info
    date = date(0)
endif

ans=get_rb0p(date)
if n_elements(ans(0,*)) eq 1 then begin		
  b0=ans(1,0)					; get B0 
  sunr=ans(0,0)
endif else begin
  b0=ans(1,*)					
  sunr=ans(0,*)
endelse
if keyword_set(arcmin) then sunr=sunr/60.

we=(ang(0,*)/sunr)			  	;normalize
ns=(ang(1,*)/sunr)
rr=sqrt(we*we + ns*ns)				;get line of sight radial distances

otl_ss = where(rr gt 1.0)			;are there points over the limb?
oflb = bytarr(n_elements(we))
if otl_ss(0) ne -1 then begin 
    we(otl_ss)=we(otl_ss)/rr(otl_ss)		;push them down to the limb
    ns(otl_ss)=ns(otl_ss)/rr(otl_ss)
    rr(otl_ss)=1.0				;reset radii
    oflb(otl_ss) = 1
endif

pix_num=n_elements(ns)
siz = size(ang)
typ = siz( siz(0)+1 )
vect = make_array(3, pix_num, type=typ>4)	;create 3D array,
vect(1,*)=we					;dimensions proper for # below
vect(2,*)=ns					;Here: x towards obs., y = W, z = N
vect(0,*)=sqrt(1-rr*rr)

ns=0						;free memory
we=0
rr=0

;rotate around y axis to correct for B0 angle (B0: hel. lat. of diskcenter)

if n_elements(b0) eq 1 then begin
    rotmx = [[cos(b0),0.0,sin(b0)], [0.0,1.0,0.0], [-sin(b0),0.0,cos(b0)]]
    vect = rotmx # vect
endif else begin
    for i = 0,pix_num-1 do begin
	rotmx = [[cos(b0(i)),0.0,sin(b0(i))], [0.0,1.0,0.0], [-sin(b0(i)),0.0,cos(b0(i))]]
	vect(*,i) = rotmx # vect(*,i)
    endfor
endelse 

;calculate latitude and longitude.

lonlat = make_array(2, pix_num, type=typ>4)
lonlat(0,*) = asin(vect(2,*))                      ; latitude

pole_ss=where(90.0-abs(lonlat(0,*)*!radeg) lt 0.1)	;trap points too near +/- 90 lat

if pole_ss(0) ne -1 then begin

  plat=where(lonlat(0,pole_ss) ge 0)
  mlat=where(lonlat(0,pole_ss) lt 0)
  if plat(0) ne -1 then lonlat(0,pole_ss(plat))  =  89.9/!radeg
  if mlat(0) ne -1 then lonlat(0,pole_ss(mlat))  = -89.9/!radeg

endif

lonlat(1,*) = asin(vect(1,*)/cos(lonlat(0,*)))     ; longitude

; longitude may be larger than 90 degrees due to nonzero B0: get proper value

lrglon=where( vect(0,*) lt 0.0)			  ;are there any large longitudes?
if lrglon(0) ne -1 then begin

  ind=bytarr(pix_num) 				  ;initialize a vector
  ind(lrglon)=1 				  ;set the bits

  plus=where( vect(1,*) ge 0.0 )		  ;positive longitudes 
  if plus(0) ne -1 then begin

    indp=bytarr(pix_num)
    indp(plus)=1
    indp_ss=where(indp eq 1 and ind eq 1)	  ;compound index

    if indp_ss(0) ne -1 then lonlat(1,indp_ss) = !pi-lonlat(1,indp_ss)     ; lon =  180 - lon

  endif

  minus=where( vect(1,*) lt 0.0 )		  ;negative longitudes
  if minus(0) ne -1 then begin 

    indm=bytarr(pix_num)
    indm(minus)=1
    indm_ss=where(indm eq 1 and ind eq 1)	  ;compound index
   
    if indm_ss(0) ne -1 then lonlat(1,indm_ss) = -!pi-lonlat(1,indm_ss)    ; lon = -180 - lon

  endif
endif

lonlat = rotate(lonlat, 5)	; reverse latitude and longitude (still is 2xN output)
lonlat = lonlat * !radeg	; convert to degrees

if keyword_set(string) then lonlat=conv_h2hs(lonlat)
;
return, lonlat
end
