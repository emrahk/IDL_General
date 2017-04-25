;+
; Name: Get_Fits_Nextend
;
; Purpose: Returns the number of extensions to a FITS file
;
; Call:
;
;		number_extensions = Get_Fits_Nextend( File [,ERROR=ERROR])
;
; Inputs:
;	File - fully qualified path to file
;
; Keyword Outputs:
;	ERROR - Set to 1 if the file doesn't exist.  Doesn't
;		check that it is a valid FITS file.
;
; Method
;	Uses Fits_Open, file, fcb and extracts the value from the fcb structure
;
; History:
;	9-apr-2007, richard.schwartz@gsfc.nasa.gov

;-

function get_fits_nextend, file, error=error

error = 1
if file_exist(file) then begin

	fits_open, file, fcb

	nextend = fcb.nextend
	free_lun, fcb.unit

	error = 0
	return, nextend
	endif

message,/info, file +' is not a valid FITS file'
return, 0
end