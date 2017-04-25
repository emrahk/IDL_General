;+
; Project     : RHESSI
;
; Name        : TRUECOLOR_DEVICE
;
; Purpose     : Check if DEVICE support TrueColor display
;
; Category    : Graphics
;
; Syntax      : true=truecolor_device()
;
; Inputs      : None
;
; Outputs     : TRUE = 1/0 = if TrueColor supported or not 
;
; Keywords    : None
;
; History     : Written 17 August 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function truecolor_device
 
device2,get_visual_depth=vdepth,get_visual_name=vname
if ~exist(vdepth) then vdepth=0
if ~exist(vname) then vname=''
true=(strlowcase(vname) eq 'truecolor') && (vdepth eq 24)
return,true

end

