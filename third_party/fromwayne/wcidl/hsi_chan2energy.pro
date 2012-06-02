
;+
; PROJECT:
;	HESSI
; NAME:
;	HSI_chan2energy
;
; PURPOSE:
;	This function returns a vector of edges (lower channel pulse-height edge in keV)
;	for the selected a2d_indices.  This supports the extraction
;	of a 3D spectrogram (energy, time, a2d) on a single pass.
;
;
; CATEGORY:
;	HESSI, UTIL, SPECTRA
;
; CALLING SEQUENCE:
;	chan_edge = HSI_chan2energy( eventlist, all_edge, select=select)
;
; CALLS:
;	EDGE2BIN, GT_TAGVAL, HSI_GET_E_EDGE, HESSI_CONSTANT,CHECKVAR,TAG_EXIST,EDGE_PRODUCTS
;	UNIQ,F_DIV, MINMAX
;
; INPUTS:
;
;
;
; OPTIONAL KEYWORD, INPUTS:
;
; OUTPUTS:
;       Function returns a spectrogram with the prescribed binning.
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS INPUTS:
;
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
;
;	Conversion from a2d channel to energy edge (low edge of channel in PHA keV) is done using one
;	of two methods depending on the form of all_edge.
;	If all_edge is a set of gains and coefficients, dimensioned 27 x 2, then the linear gain
;	equation is applied, channel number X GAIN + OFFSET.
;	Otherwise, a set of 8193 x 27 edges is passed and the channel number and a2d_index is
;	used to obtain the value from that array.
;
; MODIFICATION HISTORY:
;	1 SEPT 2001, RICHARD.SCHWARTZ@GSFC.NASA.GOV
;
;-

function HSI_chan2energy,  eventlist, all_edge, $
select=select

nchan = hessi_constant(/n_channel_max) + 1L

if n_elements( all_edge ) eq 54 then $

out = exist(select) ? $
	all_edge[eventlist[select].a2d_index,1] * eventlist[select].channel  + all_edge[eventlist[select].a2d_index, 0] : $
	all_edge[eventlist.a2d_index,1] * eventlist.channel  + all_edge[eventlist.a2d_index, 0] $


else $


out = exist(select) ? $
	all_edge[ eventlist[select].channel +nchan* eventlist[select].a2d_index] : $
	all_edge[ eventlist.channel + nchan * eventlist.a2d_index]

return, out
end
