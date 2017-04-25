;+
; NAME:
;	VERT_LINE
;
; PURPOSE:
;	 Plot a vertical line at the position in the x argument.
;
; CATEGORY:
;	HXRBS
;
; CALLING SEQUENCE:
;	VERT_LINE,X,Linestyle[,COLOR=COLOR]
;
; INPUTS: 
;	X:		x argument where the vertical line is to be plotted.
;	Linestyle:	line style of vertical line (see 2-5R for table of 
;			linestyles).
;
; KEYWORDS:
;	COLOR:		Color assigned to the vertical line
;	
; MODIFICATION HISTORY:
;	Written by Shelby Kennard, February 1991. 
;	Mod. 05/04/94 by AKT. Added color keyword
;	Mod. 05/06/96 by RCJ. Added documentation.
;-
;
pro vert_line,x,line_styl, color=color

yw = !y.window
yi = !y.s
xx = [x,x]
if keyword_set(color) then col = fcolor(color) else col = !p.color
;
logy = !y.type
;
if logy then begin
  dy = 10^((yw-yi(0)) / yi(1))
  oplot,xx,dy,line=line_styl, color=col, thick=2
endif else begin
  dy = (yw-yi(0)) / yi(1)
  oplot,xx,dy,line=line_styl, color=col, thick=2
endelse
!p.linestyle = 0
;
return & end
