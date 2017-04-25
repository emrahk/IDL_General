;+
;
;Name: Count_Data_MC_Rebin
;
;Purpose: This procedure is used to redistribute counts from bins
;	on one set of edges into bins on a different set of edges.
;Method:
;	This is a generalization of idl's rebin based not on the number of bins but
;	on the calibration of the edges of the bins used to hold the counts.
;	By default, the input, counts, is presumed to be integer events and the
;	redistribution will be done by Monte-Carlo process based on the overlapping
;	fractions between the original and new bin edges.  The Monte-Carlo part of the process
;	is disabled if NOPOISSON is set (/NOPOISSON)
;
; Counts - A 2 d arry of count data (can be any kind of values that need
;	to be redistributed)  One of the dimensions must be the same as
;   the number of bins described by edges.  For example, if counts is energy spectra which
;	we normally dimension as number_energy_bins x number_time_bins we
;	may rebin along either axis.  So to rebin along the energy axis, we'll supply
;	the current and new energy binning in Edges and New_Edges respectively.
;	Or, we could rebin in time supplying the current and new time binning as
;	Edges and New_Edges.  Counts is integrated over the bin widths and is
;	not per unit energy or time.
; Edges - 2XN array of either the current energy or time bins. By energy bin we mean the axis of the
;	first dimension and time the axis of the second dimension
; New_Edges - 2xM array of the new bins on the same axis as Edges
;Category:
;	UTIL
;
;Keywords:
;	SEED - Seed to use with Monte-Carlo process.  Used in a call to Randomu
;	LIVETIME - Integrated livetime in each bin when used with time edges
;	NEW_LIVETIME - rebinned livetime, no Monte-Carlo used
;	REBIN_2ND_INDEX - default is 1, only used when the numbe of bins is the same
;	alog each axis
;	NOPOISSON - if set, don't use a random process to distribute the counts. Simply
;		prorate the counts based on bin overlap
;	ERROR - error is thrown if set
;	ERR_MSG - text message explaining the problem if possible,  the most likely possibility
;	is that the number of bin edges doesn't match the Counts input on either axis.
;
;-
pro count_data_mc_rebin, counts,  edges, new_edges, $
	new_counts, $
	seed=seed, livetime=livetime, $
	new_livetime=new_livetime, $
	rebin_2nd_index=rebin_2nd_index, $
	nopoisson=nopoisson, $
	error = error, $
	err_msg = err_msg


error = 1
err_msg = ''
cdim=size(/dimensions, counts)
edge_products, edges, edges_2=edg2
edge_products, new_edges, edges_2=new_edg2
nedg = n_elements(edg2[0,*])
iedg = where( nedg eq cdim, nmatch)
if nmatch eq 0 then begin
	err_msg = 'Number of edges does not match either dimension of counts'
	message, err_msg,/continue
	return
	endif


default, nopoisson, 0
default, rebin_2nd_index, 1
rebin_2nd_index = rebin_2nd_index<1>0
if cdim[0] eq cdim[1] then iedg = rebin_2nd_index


new_counts = iedg ? transpose(counts) : counts
ssw_rebinner, new_counts, edg2, new_counts, new_edg2

new_counts = ~nopoisson ? poisson_event_bin( new_counts, seed=seed) : new_counts
new_counts = iedg ? transpose(new_counts) : new_counts
if arg_present( new_livetime) then begin
	new_livetime = iedg ? transpose( livetime) : livetime
	ssw_rebinner, new_livetime, edg2, new_livetime, new_edg2
	new_livetime = iedg ? transpose(new_livetime) : new_livetime
	endif

error = 0
end
