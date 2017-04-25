;+
; Project     :	STEREO - SWAVES
;
; Name        :	BLANKTICKS
;
; Purpose     :	Used in XTICKFORMAT to stop tick labeling
;
; Category    :	Graphics
;
; Explanation :	This function is used to stop labeling of tick marks via the
;               [XYZ]TICKFORMAT keywords.
;
; Syntax      :	[XYZ]TICKFORMAT='blankticks'
;
; Examples    :	PLOT, X, Y, XTICKFORMAT='blankticks'
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	Originally called no_label.pro from SWAVES library (M. Kaiser)
;
; History     :	Version 1, 11-Nov-2007, W. Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
function blankticks, axis, index, t

; this function used to stop labeling of tick marks
; call as plot, x, y, xtickformat='blankticks'

return, " "
end
