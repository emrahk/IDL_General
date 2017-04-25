;+
; Project     : RHESSI
;
; Name        : BW_COLORS
;
; Purpose     : Return black and white color table vectors
;
; Category    : Graphics
;
; Syntax      : bw_colors,red,green,blue
;
; Inputs      : None
;
; Outputs     : RED, GREEN, BLUE = black and white color table vectors
;
; Keywords    : None
;
; History     : Written 30 August 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro bw_colors,red,green,blue

red=bindgen(255)
green=red
blue=red

return
end
