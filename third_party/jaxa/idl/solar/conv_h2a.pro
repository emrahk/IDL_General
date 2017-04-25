FUNCTION conv_h2a, helio0, date0, behind=bhdlmb, arcmin=arcmin
;+
; NAME:
;	CONV_H2A
; PURPOSE:
;	Computes arcsecs-from-suncenter coordinates from 
;	heliographic coordinate inputs (inverse of CONV_A2H). 
; CALLING SEQUENCE: 
;	arcvec = conv_h2a(helio, date [,/arcmin])
; INPUT:
;       helio	- is a vector of heliocentric coordinates.  It should be 2xN.
;                       (0,*) = longitude (degrees) W positive
;                       (1,*) = latitude (degrees) N positive
;		  They can also be strings in the form 'N30W23'.
;	date	- Unless the date is supplied, today's date is used.
;                 This will affect the Solar axial tilt, B0.
; OUTPUT:
;	arcvec	- The angle in arcseconds as viewed from the earth.
;                       (0,*) = E/W direction with W positive
;                       (1,*) = N/S direction with N positive
; OPTIONAL KEYWORD INPUT:
;	arcmin	- If set, output is in arcminutes, rather than 
;		  arcseconds.
; OPTIONAL KEYWORD OUTPUT:
;	behind  - Returns a binary vector set to 1 when points are behind
;		  the visible limb.
; CAUTIONS: 	There is a limit (although large) on how many pixels IDL's
;		memory will support at once. 
; CALLS: ANYTIM2INTS, GET_RB0P                                               
; HISTORY: 
;	Written 10-Jun-93 by A. McAllister (using HEL2PIX and then VEC_H2P 
;					    as the starting point)
;	16-Jun-93 (MDM) - Modified the header and parameters somewhat
;	17-Jun-93 (MDM) - Renamed variable XYZ to avoid conflict with astron
;			  library function called XYZ
;	22-Jun-93 (MDM) - Corrected typo
;	28-Jun-93 (AHM) - Fixed bug affecting vector usage.
;	29-Jun-93 (AHM) - added BEHIND keyword.
;	21-Jul-93 (MDM) - Modified header information
;	 3-Aug-93 (MDM) Corrected the date option
;         
;-

siz = size(helio0)
typ = siz( siz(0)+1 )
if (typ eq 7) then helio = conv_hs2h(helio0) else helio = helio0
we = helio(0,*)
ns = helio(1,*)
nout = n_elements(ns)

;-------------------- Get the Date
;
if (n_elements(date0) eq 0) then date = anytim2ints(!stime) $
                        else date = anytim2ints(date0)
if ((n_elements(date) ne nout) and (n_elements(date) ne 1)) then begin
    message, 'Improper number of dates.  Using first date for all points.', /info
    date = date(0)
endif

ans = get_rb0p(date)
b0   = ans(1,*)
sunr = ans(0,*)
if keyword_set(arcmin) then sunr=sunr/60.

pix_num = n_elements(ns)

lon = we/!radeg 
colat = (90 - ns)/!radeg 

we=0				;reduce memory requirements
ns=0

; vect is the (x,y,z) location of the point for b0 = 0, where x is in the
; direction of Texas, y is west, and z is north. vect1 is rotated by b0. 

siz = size(helio)
typ = siz( siz(0)+1 )
vect = make_array(3, pix_num, type=typ>4)        ;create 3D array,
vect(0,*) = sin(colat)*cos(lon)			;back to xyz
vect(1,*) = sin(colat)*sin(lon)
vect(2,*) = cos(colat)

;correct for B0

if n_elements(b0) eq 1 then begin
    rotmx = [[cos(b0),0.0,-sin(b0)],[0.0,1.0,0.0],[sin(b0),0.0,cos(b0)]]
    vect = rotmx # vect
    vect = vect*sunr(0)
;    vect(1,*) = vect(2,*)*sunr(0)
endif else begin
    for i = 0,pix_num-1 do begin
	rotmx = [[cos(b0(i)),0.0,-sin(b0(i))], [0.0,1.0,0.0], [sin(b0(i)),0.0,cos(b0(i))]]
	vect(*,i) = rotmx # vect(*,i)
	vect(*,i) = vect(*,i)*sunr(i)
;	vect(1,*) = vect(2,*)*sunr(i)
    endfor
endelse

bhdlmb=bytarr(n_elements(helio(0,*)))		;set flag for points behind the limb
bl_ss=where(vect(0,*) lt 0.0)
if bl_ss(0) ne -1 then bhdlmb(bl_ss)=1

return, vect(1:2,*)

end
