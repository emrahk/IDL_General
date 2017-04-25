;+
;
; NAME: 
;	GET_RECON
;
; PURPOSE:
; 	This function returns the number of lines in an ASCII FILE
;
;
; CATEGORY:
;	GEN
;
; CALLING SEQUENCE:
;	recno = get_recno( file )
;
; CALLS:
;	none
;
; INPUTS:
;       file - file name
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
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
; Uses FSTAT in a loop
;
; MODIFICATION HISTORY:
;	DOC. RAS JUNE 1996
;-

function get_recno, file

openr, lu, /get, file
line =''

i=0
fs = fstat(lu)
while fs.cur_ptr lt fs.size do begin 
	i=i+1
	readf, lu, line
	fs = fstat(lu)
endwhile

free_lun,lu

return, i
end
