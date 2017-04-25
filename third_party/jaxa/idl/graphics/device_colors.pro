;+
; Project     : RHESSI
;
; Name        : DEVICE_COLORS
;
; Purpose     : Return current device color table vectors
;
; Category    : Graphics
;
; Syntax      : device_colors,red,green,blue
;
; Inputs      : None
;
; Outputs     : RED, GREEN, BLUE = current device color table vectors
;
; Keywords    : None
;
; History     : Written 30 August 2015, Zarro (ADNET) 
;
; Contact     : dzarro@solar.stanford.edu
;-

pro device_colors,red,green,blue

device2,get_decomp=decomp
device2,decomp=0
tvlct,red,green,blue,/get
device2,decomp=decomp

return
end
