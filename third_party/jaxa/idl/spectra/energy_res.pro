
;+
; Project:
;	XRAY
;
; NAME:
;	Energy_res
; PURPOSE:
;	This procedure generates a matrix of gaussian pulse-shapes which can
;	then multiply a matrix of energy-losses to form a full pulse-height
;	matrix.
;
; CATEGORY:
;	MATH, CALIBRATION, INSTRUMENT, DETECTORS, RESPONSE, SPECTROSCOPY
;
; CALLING SEQUENCE:
;	PULSE_SPREAD, INPUT, PSM, INMATRIX, OUTMATRIX
; EXAMPLES:
;	pulse_spread, input_psm, pulse_shape, eloss_mat.eloss_mat, drm
;
; CALLS:
;	EDGE_PRODUCTS, CHKARG, F_DIV
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
;
; OUTPUTS:
;       PSM - pulse-shape matrix, square or SPARSE
;
; OPTIONAL OUTPUTS:
;
;
; KEYWORDS:
;	SPARSE - if set, then psm is a sparse matrix
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	The GAUSSINT function is used to construct the point-spread function.  GAUSSINT is
;	the integral over the normally used GAUSSIAN function and is the correct function
;	where the Gaussian is a valid approximation only when the output channels are
;	narrow wrt the resolution.  Also, if INMATRIX is given, an efficient matrix
;	multiplication is performed on large matrices, multiplying only over the
;	non-zero elements of INMATRIX, useful when INMATRIX is mainly the photoefficiency
;	without a Compton tail.
;
; MODIFICATION HISTORY:
;	16-jun-2006, ras
;-


function energy_res, _extra=_extra

return, obj_new('energy_res',_extra=_extra)
end
