;+
;
;Name: Data_Grouper_Edg
;
;Purpose: This routine rebins the columns in the row of the DATA array.
;	It is based on and uses Data_Grouper(data, group) but instead of
;	summing columns according group indices, it uses the old edge and new edge scaling
;	along the columns to determine the indices to group (sum over) and then calls Data_Grouper.
;	It is frequently used to
;	bin data together to increase statistics or to
;	deal with a systematic non-linearity.  It can also be used with
;	response matrices.  Note, that this routine adds the columns together
;	so data or responses must be in count or total probability units and
;	not scaled by bin width (e.g. per keV). You may have to multiply
;	by width first and then at the end divide by the final bin width.
;
;
;Input:
;	Data  - 1D, 2D, ...,ND array where the columns are to be regrouped
;	Edgin - the current calibration of the column index along a row.
;		For an response matrix this would be the energy edges of the SRM (Data) array
;		May be in 1D (N+1) or 2D (2xN) format (see edge_products)
;		Must agree with the number of elements in a row of Data
;	Edgout - the data are summed according to the calibration of edgout
;		data has bins edgin entering, edgout leaving
;		edgout values must be found in edgin and edgout must be contiguous
;		For Data_in, NxM, entering and KxM leaving
;			the values of Data_out[i,*] are determined by summing the elements Data_in[K:L,*] such
;			that Edgin[K] is given by Edgout[i] and Edgin[L] is given by Edgout[i+1]
;Optional Keywords:
;	PERWIDTH - Input, If PERWIDTH is set, data is in per edge width (usually per keV) form.
;		Grouping works using total function so the bin width is multiplied through
;		at the start and then divided at the end.
;	EPSILON - default, .001, fractional difference allowed for matching Edgin to Edgout
;	ERROR - Output, if set then edgout was not a subset of edgin
;History:
;	4-jan-2012, richard.schwartz@nasa.gov
;	15-Nov-2012, Kim. Changed default for epsilon to 1.e-6 from 1.e-3 (it's fractional)
;-
pro data_grouper_edg, data, edgin, edgout, error=error, emsg=emsg, $
	 perwidth=perwidth, epsilon=epsilon

error=1
emsg = 'Edgout must be a subset of edgin or edgin not consistent with Data  '
edge_products, edgin, edges_1=edgin1, width=din
edge_products, edgout, edges_1=edgout1, width=dout
ei = get_uniq(edgin1)
eo = get_uniq(edgout1)
default, epsilon, 1.0e-6
if (n_elements( get_uniq( [ei,eo],epsilon=epsilon)) ne n_elements(ei)) or $
	((n_elements(edgin1)-1) ne n_elements(data[*,0])) then begin
	message,/info, emsg
	return
	endif
z = value_locate( edgin1-abs(epsilon)*edgin1, edgout1)
if keyword_set(perwidth) then $
	data *= rebin( din, size(/dim, data))
data = data_grouper( data, z)
if keyword_set(perwidth) then $
	data /= rebin( dout, size(/dim, data))


error = 0
emsg  = ''
end
