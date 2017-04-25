pro wrt_fits_bin_exten, struct, outfil, main_prog, main_progver, $
	append=append, get_ver=get_ver
;+
;NAME:
;	wrt_fits_bin_exten
;PURPOSE:
;	To write FITS binary extension table using the structure
;	passed in.  The column names match the tag names of the
;	structure
;SAMPLE CALLING SEQUENCE:
;	wrt_fits_bin_exten, struct, outfil
;	wrt_fits_bin_exten, ver, /get_ver
;	wrt_fits_bin_exten, struct, outfil, /append
;INPUTS:
;	struct	- The structure to save to FITS file
;	outfil	- The name of the output file
;OPTIONAL INPUTS:
;	main_prog- The name of the main program (calling WRT_FITS_BIN_EXTEN)
;	main_progver- The program version number of the main program
;OPTIONAL KEYWORD INPUT:
;	append	- If set, append the binary extension structure
;		  to an existing file
;	get_ver	- If set, return the program version number in the
;		  first argument
;RESTRICTIONS:
;	Currently the /APPEND option only works if the FITS
;	file was opened with the /extend option (when calling
;	fxhmake)
;HISTORY:
;	Written 18-Nov-97 by M.Morrison
;V1.01	 1-Dec-97 (MDM) - Added /APPEND option
;			- Added /GET_VER option
;-
;
prog_ver = 1.0
if (keyword_set(get_ver)) then begin
    struct = prog_ver
    return
end
;
if (data_type(struct) ne 8) then begin
    print, 'WRT_FITS_BIN_EXTEN: First parameter must be a structure'
    return
end
;
n = n_elements(struct)

if (not keyword_set(append)) then begin
    junk = bytarr(10,10)	;needed because fxb* doesn't like no data (ie "junk = 0b")
    fxhmake, header, junk, /extend, /initialize
    fxaddpar, header, 'EXT_NROW', n
    if (keyword_set(main_prog))    then fxaddpar, header, 'MPROGNAM', main_prog
    if (keyword_set(main_progver)) then fxaddpar, header, 'MPROGVER', main_progver
    fxaddpar, header, 'PROG_NAM', 'WRT_FITS_BIN_EXTEN', 'Make a FITS binary extension file from structure'
    fxaddpar, header, 'PROG_VER', prog_ver
    fxaddpar, header, 'PROG_RUN', !stime
    fxwrite, outfil, header, junk
end else begin
    header = rfits(outfil, /nodata)
end
;
nbyte_head = get_nbytes(byte(header))
;
fxbhmake, bheader, n, 'GENERIC_EXT', 'Binary extension'

tags = tag_names(struct)
ntags = n_elements(tags)
;
;---- Initialize the column setup
;
for itag=0,ntags-1 do begin
    istr = strtrim(itag,2)
    ;fxbaddcol, col_variable, bheader, data_sample, tag_label'
    cmd = 'fxbaddcol, col' + istr + ', bheader, struct(0).' + tags(itag) + ', "' + tags(itag) + '"'
    ;;print, cmd
    stat = execute(cmd)
end
;
fxbcreate, lun, outfil, bheader
;
for icol=1,n do begin
    for itag=0,ntags-1 do begin
	istr = strtrim(itag, 2)
	;fxbwrite, lun, data, col_variable, column_number
	cmd = 'fxbwrite, lun, struct(icol-1).' + tags(itag) + ', col' + istr + ', icol'
	stat = execute(cmd)
    end
end
;;print, cmd
fxbfinish, lun
end
