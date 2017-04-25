;+
; Project     : HESSI
;
; Name        : MAP2SOHO
;
; Purpose     : convert Earth-view map to SOHO-view
;
; Category    : imaging
;
; Syntax      : smap=map2soho(map)
;
; Inputs      : MAP = image map structure
;
; Outputs     : SMAP = remapped structure 
;
; Opt. Outputs: None
;
; Keywords    : None
;
; History     : Written 18 Oct 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


function map2soho,map

return,map2l1(map)

end


