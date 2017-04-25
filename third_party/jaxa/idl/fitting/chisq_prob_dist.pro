;+
; Name: chisq_prob_dist
; 
; Purpose:  Compute the probability distribution for a chisquare distribution with nf degrees of freedom, and plot if requested.
; 
; Explanation: Returns dr, the probability distribution for a chisquare distribution with nf degrees of freedom.  The total 
;   of dr is 1.
;   To overplot these values on your own reduced chisquare (rchisq) density plot with nf deg of freedom, do this:
;     y = histogram(rchisq, locations=x)
;     wbin = x[1]-x[0]
;     plot, x+wbin/2., y / total(y)
;     dr = chisq_prob_dist(nf, rv=rv, binwidth=binwidth)
;     oplot, rv, dr* wbin / binwidth
;     
; Input arguments: 
;  nf - number of degrees of freedom in the distribution
;  
; Input Keywords:
;  plot - if set, plot dr vs reduced chisq
;  
; Output keywords:
;  rv - values of reduced chisquare corresponding to dr
;  binwidth - spacing between reduced chisq values in distribution
; 
; Examples:
;   dr = chisq_prob_dist(90, /plot)
;   dr = chisq_prob_dist(90, v=v, binwidth=binwidth)
;
; Written: Kim Tolbert 25-Aug-2014
; Modifications:
; 
;-
function chisq_prob_dist, nf, plot=plot, rv=rv, binwidth=binwidth

; Make an array of chisq values covering the range of interest
v = findgen(nf*3)

; pdf will be the probability that a random variable X, from the chisquare distribution with nf degrees
;    of freedom, is less than or equal to the corresponding value in array v
pdf = chisqr_pdf(v,nf)

dr = deriv(pdf)
binwidth = 1. / (nf-2)
rv = v/(nf-2)

; plot dr vs reduced chisquare
if keyword_set(plot) then plot,rv, dr, xtitle='Reduced Chi-square', ytitle='Number density'

return, dr
end