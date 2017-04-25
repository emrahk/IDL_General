;+
; Project     : RHESSI
;
; Name        : VALID_COLORS
;
; Purpose     : Check if input RED, GREEN, BLUE color table vectors are valid
;
; Category    : Graphics
;
; Syntax      : chk=valid_colors(red,green,blue)
;
; Inputs      : RED,GREEN,,BLUE = color table vectors
;
; Outputs     : 1 = if vectors are same size and not all zeroes
;
; Keywords    : None
;
; History     : Written 30 August 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function valid_colors,red,green,blue

nred=n_elements(red)
ngreen=n_elements(green)
nblue=n_elements(blue)
if (nred le 1) || (ngreen le 1) || (nblue le 1) then return,0b
if (nred ne nblue) || (nred ne ngreen) || (ngreen ne nblue) then return,0b
sum=(red+green+blue)
smax=max(sum,min=smin)
if (smax eq 0) && (smin eq 0) then return,0b
return,1b
end
