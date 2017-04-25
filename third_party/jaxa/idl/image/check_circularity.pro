;+
; PURPOSE
; Returns a measure of the circularity of the flevel contour

; INPUTS:
;  plevel = fraction of maximum where circularity is to be measured

; OUTPUTS:
;  measure = a measure of circularity
;  For a 2:1 ellipse, measure=0.33
;  for a 1.5:1 ellipse, measure=0.20
;  for a 1.25:1 ellipse, measure=0.11
;
; METHOD:
; Gets the flevel contour using 
; the structure produced by keyword PATH_INFO in IDL's contour
; returns a measure of circularity
; (max(radius)-min(radius))/(max(radius)+min(radius))

;
; VERSION HISTORY
; schmahl@hessi.gsfc.nasa.gov 2002
;-
 
function check_circularity,clnmap,flevel,PLOT=plot


if (flevel LE 0 OR flevel GE 1.0) then message,'flevel out of range'

CONTOUR, clnmap, level=[flevel]*max(clnmap),PATH_XY=xy, PATH_INFO=info
ncontours=n_elements(info)
x=reform(xy(0,*))
y=reform(xy(1,*))

if keyword_set(PLOT) then plot,[x,x[0]],[y,y[0]];,xra=[0,1],yra=[0,1]
xbar=mean(x) & ybar=mean(y)
radius=sqrt((x-xbar)^2+(y-ybar)^2)

measure=(max(radius)-min(radius))/(max(radius)+min(radius))
return,measure                     
end

