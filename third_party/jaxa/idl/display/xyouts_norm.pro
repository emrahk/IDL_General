pro xyouts_norm,xnorm,ynorm,string,size,orientation,color 
;+
; Name        	XYOUTS_NORM
;
; Purpose   
;		modified function of xyouts with normalized coordinates xnorm,ynorm with
;		respect to current plot frame
;
; Syntax        xyouts_norm,xnorm,ynorm,string,size,orientation,color
;
; Examples    : xyouts_norm,0.1,0.1,'Here is graph 1'
;
; Inputs      : xnorm	= normalized x-coordinate (0<x<1) with respect to plot frame
;  		ynorm	= normalized y-coordinate (0<x<1) with respect to plot frame
;		string	= text string
;
; Opt. Inputs : size	= character size
;		orientation = angle of text line with respect to x-axis
;		color	= color of text
;
; History     : 1989, written, 
;		1999, contributed to SSW, aschwanden@lmsal.com 
;-

if (n_params(1) le 3) then size=1.0
if (n_params(1) le 4) then orientation=0
x1	=!x.crange(0)	
x2	=!x.crange(1)
y1	=!y.crange(0)
y2	=!y.crange(1)
x3	=x1+(x2-x1)*xnorm
y3	=y1+(y2-y1)*ynorm
if (!x.type eq 1) then x3=10.^x3	;log-scale
if (!y.type eq 1) then y3=10.^y3	;log-scale
if (n_params(1) le 5) then xyouts,x3,y3,string,size=size,orientation=orientation 
if (n_params(1) gt 5) then xyouts,x3,y3,string,size=size,orientation=orientation,color=color 
end

