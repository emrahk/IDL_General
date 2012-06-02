
pro make_staircase,x,y,dx,xstair,ystair

;+
; NAME:
;       make_staircase
;
;
; PURPOSE:
;       Calculate a "staircase" of x and y values from input x and y
;       and associated dx and dy arrays. This allows nicer plotting
;       than IDL's "histogram" symbol
;
; CATEGORY:
;       Plotting
;
; CALLING SEQUENCE:
;       make_staircase,x,y,dx,dy,xstair,ystair
; 
; INPUTS:
;       x  : array of original x values
;       y  : array of original y values
;       dx : array of dx values = halfwidth of step
;
; OPTIONAL INPUTS:
;       none
;
; KEYWORD PARAMETERS:
;       none
;
; OUTPUTS:
;       xstair : array of x-values of staircase
;       ystair : array of y-values of staircase
;
; OPTIONAL OUTPUTS:
;       none
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       none
;
;
; RESTRICTIONS:
;       All input arrays must be 1-dimensional and have same size
;
; PROCEDURE:
;       just read it
;
; EXAMPLE:
;       not needed
;
;
; MODIFICATION HISTORY:
;       Version 1.0: 1999/11/10, PK
;                    first version
;-


nx  = n_elements(x)
ny  = n_elements(y)
ndx = n_elements(dx)

IF (NOT (nx EQ ny AND nx EQ ndx)) THEN BEGIN
    print,'staircase error: input arrays must have same size!'
    return
ENDIF

sizex = size(x)

IF (sizex(0) NE 1) THEN BEGIN
    print,'staircase error: input arrays must be one-dimensional!'
    return
ENDIF

xstair=fltarr(2*nx)
ystair=fltarr(2*ny)

FOR i=0,nx-1 DO BEGIN
    xstair(2*i)   = x(i)-dx(i)
    xstair(2*i+1) = x(i)+dx(i)
    ystair(2*i)   = y(i)
    ystair(2*i+1) = y(i)
ENDFOR

END
