;+
; NAME:
;	GET_ASPECT
;
; PURPOSE:
;	This function calculates and returns the normalized position
;	coordinates necessary to put a plot with a specified aspect ratio
;	into the currently active graphics window. It works on the display
;	output window as well as in a PostScript output window.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;
;	position = GET_ASPECT(aspectRatio)
;
; INPUTS:
;	aspectRatio: A floating point value that is the desired aspect
;	ratio (ratio of heigth to width) of the plot in the current 
;	graphics output window. If this parameter is missing, an aspect
;	ratio of 1.0 (a square plot) is assumed.
;
; KEYWORD PARAMETERS:
;	MARGIN:	The margin around the edges of the plot. The value must be
;	a floating point value between 0.0 and 0.5. It is expressed in
;	normalized coordinate units. The default margin is 0.15
;
;       XRANGE,YRANGE: optional range of data coordinates. Must be
;       two-element vectors.
;
; OUTPUTS:
;	position: A four-element floating array of normalized coordinates.
;	The order of the elements is [x0, y0, x1, y1], similar to the
;	!P.POSITION system variable or the POSITION keyword on any IDL
;	graphic command.
;
; EXAMPLE:
;	To create a plot with an aspect ratio of 1:2 and a margin of
;	0.10 around the edge of the output window, do this:
;
;	   plotPosition = GET_ASPECT(0.5, Margin=0.10)
;	   PLOT, Findgen(11), POSITION=plotPosition
;	
;	Notice this can be done in a single IDL command, like this:
;	
;	   PLOT, Findgen(11), POSITION=GET_ASPECT(0.5, Margin=0.10)
;
; MODIFICATION HISTORY:
; 	Written by:	David Fanning, November 1996.
;       Added better error checking, 18 Feb 97, DWF.
;       Modified, 28 June 2000, Zarro (EIT/GSFC)
;        - Added XRANGE/YRANGE keywords to allow for skewed data ranges
;       Modified, 24 Feb 2007, Zarro (ADNET)
;        - Fixed so that MARGIN=0 really means zero margin
;       Modified, 22 Oct 2014, Zarro (ADNET)
;        - Converted to double-precision arithmetic
;
;-

FUNCTION GET_ASPECT, aspectRatio, MARGIN=margin, XRANGE=xrange, YRANGE=yrange


   ; Check for aspect ratio parameter and possibilities.
   
IF ~is_number(aspectRatio) then  aspectRatio = 1.0d

IF aspectRatio EQ 0 THEN BEGIN
   MESSAGE, 'Aspect Ratio of 0. Changing to 1...', /Informational
   aspectRatio = 1.0d
ENDIF

; Check for margins.
   
def_margin=.15d
IF N_ELEMENTS(margin) EQ 0 THEN margin = def_margin

if margin le 0. then begin
 position=[0.d0,0.d0,1.d0,1.d0]
 return,position
endif

; Error checking.
   
if margin GE 0.5 THEN begin
 MESSAGE, 'The MARGIN keyword value must be between 0.0 and 0.5.',/info
 margin=def_margin
endif
 
; Calculate the aspect ratio of the current window.

skew=1.
if (n_elements(xrange) eq 2) and (n_elements(yrange) eq 2) then begin
 dx=(max(xrange)-min(xrange))
 dy=(max(yrange)-min(yrange))
 if (dx ne 0.) and (dy ne 0.) then skew=double(dx)/double(dy)
endif

wAspectRatio = skew*double(!D.Y_VSIZE) / !D.X_VSIZE


; Calculate normalized positions in window.
   
IF (aspectRatio LE wAspectRatio) THEN BEGIN
   xstart = margin
   ystart = 0.5d0 - (0.5d0 - margin) * (aspectRatio / wAspectRatio)
   xend = 1.0d0 - margin
   yend = 0.5d0 + (0.5d0 - margin) * (aspectRatio / wAspectRatio)
ENDIF ELSE BEGIN
   xstart = 0.5d0 - (0.5d0 - margin) * (wAspectRatio / aspectRatio)
   ystart = margin
   xend = 0.5d0 + (0.5d0 - margin) * (wAspectRatio / aspectRatio)
   yend = 1.0d0 - margin
ENDELSE

position = [xstart, ystart, xend, yend]

RETURN, position
END
