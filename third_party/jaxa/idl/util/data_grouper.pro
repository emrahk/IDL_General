;+
;
;Name: Data_Grouper
;
;Purpose: This routine sums columns in the rows of an array
;	according to the grouping index vector. It is frequently used to
;	either sum data over bins to increase statistics or to
;	deal with a systematic non-linearity.  It can also be used with
;	response matrices.  Note, that this routine adds the columns together
;	so data or responses must be in count or total probability units and
;	not scaled by bin width (e.g. per keV). You may have to multiply
;	by width first and after summing then divide by the final bin width.
;
;
;Input:
;	Data  - 1D, 2D, ...,ND array where the columns are to be regrouped
;	Group_in - 2xN or 1D (N+1) array to group the Data (MxK array, spectrogram collapsed into 2D)
;		into an NxK array.  Grouped (summed) channels are taken from row of length M
;		edge_products, group_in, edges_2=group
;		data[i,*] = total(data[group[0,i]:group[1,i]-1,*],1)
;History:
;	3-jan-2012, ras, based on hsi_spectrogram::channel_regroup
;-
function data_grouper, data, group_in

edge_products, group_in, edges_2=group
dim_group = size(/dim, group)
dim_data   = size(/dim, data)

dim_out    = [dim_group[1], dim_data[1:*]]
dim_data2d = [dim_data[0], product( dim_out[1:*])]
dim_out   = n_elements(dim_out) gt 1 ? dim_out : reform( dim_out, [dim_out[0],1])

dim_out2d = [dim_out[0], dim_data2d[1]]
out = make_array( type = size(/type,data), dim_out2d)
w   = get_edges( group, /width)-1
zg  = where( w, nzg, comp=z1, ncomp=nz1) ; get grouped and ungrouped output bins
;fill all the z1 where there is one bin going into one bin
data = reform( data, /over, dim_data2d)
if nz1 ge 1 then out[z1,*] = data[group[0,z1],*]
;fill all the zg where there is more than one bin going into one bin
if nzg ge 1 then for i=0,nzg-1 do out[zg[i],*] = total( data[group[0,zg[i]]:group[1,zg[i]]-1,*],1)
;reform OUT to original shape
return, reform(/over, out, dim_out)
end
