; $Id: profil.pro,v 1.5 1997/01/15 03:11:50 ali Exp $
;


Function profil, image, xx, yy, xstart = x0, ystart = y0, nomark = nomark
;+
; NAME:
;	PROFIL
;
; PURPOSE:
;	Extract a profile from an image.
;	Remplace PROFILE
;
; CATEGORY:
;	Image processing.
;
; CALLING SEQUENCE:
;	Result = PROFIL(Image, XX, YY)
;
; INPUTS:
;	Image:	The data array representing the image.  This array can be
;		of any type except complex.
;
; KEYWORD PARAMETERS:
;      XSTART:	The starting X location of the lower-left corner of Image.
;		If this keyword is not specified, 0 is assumed.
;
;      YSTART:	The starting Y location of the lower-left corner of Image.
;		If this keyword is not specified, 0 is assumed.
;
;     NONMARK:	Set this keyword to inhibit marking the image with the 
;		profile line.
;
; OUTPUTS:
;	PROFIL returns a floating-point vector containing the values of
;	the image along the profile line marked by the user.
;
; OPTIONAL OUTPUTS:
;	XX:	After picking the end points, XX contains the X coordinates
;		of the points along the selected profile.
;
;	YY:	After picking the end points, YY contains the Y coordinates
;		of the points along the selected profile.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Cursor on image display is enabled.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Allow the operator to mark two points on the
;	image display with the joystick and draw the line.  
;	Extract and return the points along the line.  Optionally
;	return the X and Y values of each extracted point.
;
; EXAMPLE:
;	Display an image, select a profile and plot that profile in a new
;	window.  Create and display an image by entering:
;
;		A = BYTSCL(DIST(256))
;		TV, A
;
;	Extract a profile from the image.  Enter the following command and
;	mark two points on the image with the mouse:
;
;		R = PROFIL(A)
;
;	Create a new plotting window and plot the profile by entering:
;
;		WINDOW, /FREE
;		PLOT, R
;
;	An interactive version of this routine is available with the User
;	Library procedure PROFILES.
;
; MODIFICATION HISTORY:
;		Modification of PROFILE.PRO 
;	J Bonmartin 23/01/98 compute on floating value
;			     draw the line selected.
;                  
;-
on_error,2                      ;Return to caller if an error occurs
s=size(image)
sx = s[1] & sy=s[2]
DIM = sx>sy

if n_elements(x0) le 0 then x0 = 0
if n_elements(y0) le 0 then y0 = 0


window,/free,/pixmap, xsize=Dim,ysize=Dim
w1= !d.window
window,/free, xsize=Dim,ysize=Dim
w2= !d.window


try: print,'Mark the two end points of the profile.'
wset, w1
tvscl,image
wset,w2
device,Copy=[0,0,Dim,Dim, 0,0,w1]

r = widget_message('Select a ligne')

Pnt1:
	CURSOR,xx,yy,1,/dev	;Get first point
	y = yy - y0
	x = xx - x0
	if !order ne 0 then y = sy - 1 - y ;Invert?
	if (x lt 0) or (x ge sx) or (y lt 0) or (y ge sy) then begin
		message, 'Point outside image', /CONTINUE
		goto, pnt1
		endif
	print,'From: (',x,',',y,')'
!Mouse.Button = 1
pnt2:
REPEAT BEGIN
	wait,.1			;for fast displays
	CURSOR,xx1,yy1,/dev,/nowait	;2nd point.
device,Copy=[0,0,Dim,Dim, 0,0,w1]
	y1 = yy1 - y0
	x1 = xx1 - x0 
	if !order ne 0 then y1 = sy - 1 - y1 ;Invert?
	if (x1 lt 0) or (x1 ge sx) or (y1 lt 0) or (y1 ge sy) then begin
		message, 'Point outside image.', /CONTINUE
		goto, pnt2
		endif

	if not keyword_set(nomark) then $
		plots,[xx,xx1],[yy,yy1],/dev,/noclip ;Draw the line
ENDREP UNTIL !Mouse.Button NE 1
;
dx = float(x1-x)		;delta x
dy = float(y1-y)
n = abs(dx) > abs(dy)
if n eq 0 then 	GOTO, pnt2		;recommencer longueur ligne = 0


	print,'To (',x1,',',y1,')'

;
r = fltarr(n+1)
;
	if x1 ge x then s=1 else s=-1
	if y1 ge y then sy=1 else sy=-1
if abs(dx) gt abs(dy) then begin
	sy = (y1-y)/abs(dx)
   endif else begin
	s = (x1-x)/abs(dy)
   endelse
;
xi = lindgen(n+1l)*(s)+x	;X values, make into longwords.
xx = FIX(xi)
yi = lindgen(n+1l)*(sy)+y	;Y values
yy= FIX(yi)

wdelete,w1
wdelete,w2

return,image[long(yy)*sx + xx]
end

