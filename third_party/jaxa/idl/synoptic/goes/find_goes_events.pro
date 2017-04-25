;+
;NAME:
;	find_goes_events
;PURPOSE:
;	Find the peaks above threshold in a range of goes xrs data
;INPUTS:
;	gg - data struture returned from goes object,  gg = goes->getdata(/struct)
;	threshold - threshold for GOES long wavelength channel, default is 1e-6, (C level)
;	temp4thresh - Keyword, if set then use gg.tem for comparison, temperature in MegaKelvin
;OUTPUTS:
;	ss_sel - indices on ss array indicating first element of a run of contiguous integers
;	ss_sel_2d - indices on ss array giving first and last elements of a run
;		of contiguous integers, dimensioned 2xN
;Result:
;	fDL> find_goes_events, gg, 1e-7, out
;		IDL> help, out
;		OUT             STRUCT    = -> <Anonymous> Array[14]
;		IDL> help, out,/st
;		** Structure <2c09800>, 4 tags, length=24, data length=24, refs=1:
;		   TSTART          STRING    ' 2-Nov-2008 13:24:51.000'
;		   TEND            STRING    ' 2-Nov-2008 13:39:03.000'
;		   PEAKFLUX        FLOAT      1.00697e-007   ;flux in watts/m^2
;		   PEAKTEMP        FLOAT           7.28187    ; temp in MegaKelvin

;
;
;HISTORY:
;   Written 12-nov-2008, richard.schwartz@nasa.gov
;
;-
;

pro find_goes_events, gg, threshold, out, temp4thresh = temp4thresh

temp4thresh = keyword_set(temp4thresh)

default, threshold, (temp4thresh ? 1.0 : 1e-6)
data = temp4thresh ?   gg.tem : gg.ydata[*,0]
ndata = n_elements( data)
sel = where(  data ge threshold, nsel)
sets = find_contig(   sel, ss_sel, ss_sel_2d)
;Really want 2d version
sets = transpose(sel[ss_sel_2d])
nset = n_elements(ss_sel)
out = replicate( {tstart:'', tend:'', peakflux:0.0, peaktemp:0.0}, nset)
out.tstart =anytim(/vms, reform( anytim(gg.utbase) + gg.tarray[sets[0,*]]))
out.tend  = anytim(/vms, reform( anytim(gg.utbase) + gg.tarray[sets[1,*]]))
for i=0l,nset-1 do begin
	out[i].peakflux = max(gg.ydata[sets[0,i]:sets[1,i],0])
	out[i].peaktemp = max(gg.tem[sets[0,i]:sets[1,i],0])
	endfor

end
