function mk_bsc_str, datarectype, length, ncopy=ncopy, roadmap=roadmap, index=index, str=str, sample_index=sample_index, fit=fit
;+
;NAME:
;	MK_BSC_STR
;PURPOSE:
;	Build the BSC data structure definition
;SAMPLE CALLING SEQUENCE:
;	data = mk_bsc_str(1+2+4, 768)
;	data = mk_bsc_str(1+2+4, 768, ncopy=205)
;	data = mk_bsc_str(roadmap=roadmap)
;	data = mk_bsc_str(index=index)
;	index = mk_bsc_str(/sample_index)
;	index = mk_bsc_str(/sample_index, /fit)
;INPUT:
;	datarectype - The bit pattern telling which data tags are
;		      needed.
;	length	- The length of the data arrays within the structure
;		  (e.g.: the length of the wavelength/bin/counts array)
;		  All tags will have the same number of elements
;OPTIONAL KEYWORD INPUT:
;	ncopy	- The number of copies of the structure to make.  It
;		  simply replicates the output structure "ncopy" times
;	roadmap	- The BSC roadmap can be passed instead of datarectype/length
;	index	- The BSC index can be passed instead of datarectype/length
;	sample_index - If set, return an index structure definition with
;		  the nested .GEN and .BSC structures.
;	fit	- If set, then return the nested .FIT structure when using
;		  the /SAMPLE_INDEX option in addition to .GEN and .BSC
;OUTPUT:
;	returns a BSC structure
;OPTIONAL KEYWORD OUTPUT:
;	str	- The structure definition of the output
;HISTORY:
;	written 16-Dec-92 by Mons Morrison
;	 3-Feb-93 (MDM) - Added DATA.FLUX capability
;	31-Jul-93 (SLF) - added /down to str_merge call
;	16-Sep-93 (MDM) - Added .WAVEC option (bit 6)
;			- Added /FIT option
;	 2-Oct-93 (MDM) - Changed .WAVEC to WAVE_FIT and
;			  changed .FIT to .FLUX_FIT
;			- Changed the order that the data tags are built
;	 8-Nov-93 (MDM) - Added .FLUX_FIT2 (bit 8)
;-
;
common mk_bsc_str_blk, make_str_arr, str_name_arr
;
if (keyword_set(sample_index)) then begin
    gen_struct, gen2_index=gen_index
    bsc_struct, bsc_index=bsc_index
    bsc_struct, fit_bsc=fit_bsc
    index = str_merge(gen_index, bsc_index, /down)
    if (keyword_set(fit)) then index = str_merge(index, fit_bsc)
    if (keyword_set(ncopy)) then index = replicate(index, ncopy)
    return, index
end
;
if (keyword_set(roadmap)) then begin
    length 	= roadmap.length
    datarectype = roadmap.datarectypes
end
if (keyword_set(index)) then begin
    length 	= index.bsc.length
    datarectype = index.bsc.datarectypes
end
if (n_elements(length) eq 0) then length = 768
if (n_elements(datarectype) eq 0) then datarectype = 1 + 2	;counts, bin
;
nx = max(length)
if (nx eq 0) then begin
    print, 'MK_BSC_STR: Array length requested is zero elements long'
    print, 'MK_BSC_STR: Making it one element long'
    nx = 1
end
if (max(datarectype) eq 0) then begin
    print, 'MK_BSC_STR: Did not select any tags for the data structure'
    print, 'MK_BSC_STR: Selecting COUNTS and BIN'
    datarectype = 1 + 2
end

bits, datarectype, bitarr
str = '{dummy'
							;that the order of the structure tags is as shown in the case statement
for i=0,15 do begin
    if (max(bitarr(i,*)) ne 0) then case i of
	0: str = str + ', counts:    fltarr(' + strtrim(nx,2) + ')'
	1: str = str + ', bin:       fltarr(' + strtrim(nx,2) + ')'
	2: str = str + ', error:     fltarr(' + strtrim(nx,2) + ')'
	3: str = str + ', junk:      fltarr(' + strtrim(nx,2) + ')'
	4: str = str + ', wave:      fltarr(' + strtrim(nx,2) + ')'
	5: str = str + ', flux:      fltarr(' + strtrim(nx,2) + ')'
	6: str = str + ', wave_fit:  fltarr(' + strtrim(nx,2) + ')'
	7: str = str + ', flux_fit:  fltarr(' + strtrim(nx,2) + ')'
	8: str = str + ', flux_fit2: fltarr(' + strtrim(nx,2) + ')'

	;---- Make sure to edit SAV_BSC when adding new fields

	else:
    endcase
end
str = str + '}'
;
qnew = 1
qfirst = (n_elements(make_str_arr) eq 0)
if (not qfirst) then begin
    ss = where(make_str_arr eq str, count)
    if (count ne 0) then begin
	cmd = 'data = {' + str_name_arr(ss(0)) + '}'
	stat = execute(cmd)
	qnew = 0
    end
end
if (qnew) then begin
    data = make_str(str, str_name=str_name)
    if (qfirst) then begin
	make_str_arr = str
	str_name_arr = str_name
    end else begin
	make_str_arr = [make_str_arr, str]
	str_name_arr = [str_name_arr, str_name]
    end
end
;
if (keyword_set(ncopy)) then data = replicate(data, ncopy)
return, data
end
