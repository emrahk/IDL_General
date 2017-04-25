;+
; Project     : HESSI
;
; Name        : GET_FITS_INSTR
;
; Purpose     : Return source of data (telescop, mission, or instrument) from FITS header
;
; Category    : FITS
;
; Explanation :
;
; Syntax      : instr = get_fits_instr(header)
;
; Inputs      : header - FITS header
;
; Opt. Inputs :
;   file - Can pass in a file name instead of the header structure.  Ignores header argument
;      in this case.  Looks in each extension of file for instrument, telescop or mission.
;
; Outputs     : String containing instrument (or telescop or mission).  Blank if not found.
;
; History     : Written, Kim Tolbert 23-Apr-2003
;  26-Aug-2004, Kim.  Use 'telescop' first, and don't use 'origin'
;  19-Nov-2004, Kim.  Added file keyword.  And changed order so instrument is first.
;  23-Jun-2005, Kim.  Added check for blank - keep looking if blank
;
;-


function get_fits_instr, header, file= file

if keyword_set(file) then begin
	fits_info, file, /silent, n_ext=n_ext
	for i=0,n_ext do begin
		tmp = mrdfits(file,i,header,/silent)
		instr = get_fits_instr(header)
		if instr ne '' then return, instr
	endfor
	return, ''
endif

try  = ['instrume', 'telescop', 'mission']

for i=0,2 do begin
	instr = fxpar (header, try[i], count=count)
	if count gt 0 and trim(instr[0]) ne '' then return, instr[0]
endfor

return, ''
end
