;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;     IS_FITS determines whether a file is in fits format
;
;DESCRIPTION:
;     IS_FITS reads the primary header unit from a file and searches
;     for the keyword 'SIMPLE'.  If SIMPLE = T then the file is
;     determined to be a fits file and result = 1.  The keyword
;     'EXTENSIONS' is then searched for; if it is found then then
;     next header unit is read in and the value of the 'XTENSION'
;     keyword is returned in the optional parameter 'extension'. If
;     'EXTENSIONS' is not found then 'extension' is left blank.
;
;
;CALLING SEQUENCE:
;     RESULT = IS_FITS ( filename, [extension] )
;
;ARGUMENTS (I = input, O = output, [] = optional):
;     RESULT        O   integer    Contains 1 for each file that is in
;                                  fits format, SIMPLE = 'T'
;     FILENAME      I   string     File name to be checked
;     EXTENSION    [O]  string     Contains the extension type if
;                                  the fits file contains 'XTENSION'
;                                  keyword
;
;WARNINGS:
;
;EXAMPLE:
;	To check if file 'filename' is fits format use the following:
;
;	    status = is_fits('filename')
;
;	The return status = 1 if it is a fits file and 0 if not.  No
;	information on extensions is returned.
;
;	To determine if a file is a valid fits extension file and what
;	type if extension it is, then include the optional 'extension'
;	keyword:
;
;	    status = is_fits('filename', extension)
;
;	In this case status = 1 if the file is a valid fits file.  The
;	keyword extension = 'BINTABLE' if the file is fits Binary
;	Table Extension.  If no extensions were found then extension
;	is left blank.  !ERROR will be returned as 0 for no errors and
;	as 1 if the file was not found.
;#
;COMMON BLOCKS:
;     None
;
;PROCEDURE (AND OTHER PROGRAMMING NOTES):
;
;PERTINENT ALGORITHMS, LIBRARY CALLS, ETC.:
;	Uses a call to SXPAR to find keyword values.
;
;MODIFICATION HISTORY:
;     Written by Dave Bazell,  General Sciences Corp.  4 Feb 1993 spr 10477
;     Modified by Dalroy Ward, General Sciences Corp. 24 Mar 1993 spr
;              modified routine to handle headers longer than one record
;     13-Aug-2000, Zarro (EIT/GSFC) - added more stringent test for
;     non-zero dimensions
;     6-Feb-2006, William Thompson, GSFC, corrected bug from previous version
;     when EXTEND=T
;     28-Jan-2009, Kim Tolbert (GSFC).  Removed setting !error.  Setting !error in the
;      never_opened block causes IDL to hang in version 7.0 DE.
;     25-Apr-2009, Zarro (ADNET) 
;      - added check for gzipped FITS file
;
;.TITLE
; Routine IS_FITS
;-
;
; Check on input parameters
;
function is_fits, filename, extension

on_error, 2
;!error = 0
;

; initialize simple to false
simple = 0b

if (n_params() eq 2) then extension = ''

; Open file and read first line of header
get_lun, unit
on_ioerror, never_opened
compress=stregex(filename,'\.gz$',/bool)

openr, unit, filename, /BLOCK,compress=compress

; Read the first header record
hdr = bytarr( 80, 36, /NOZERO )

if eof(unit) then goto, return_status
readu, unit, hdr

header = string( hdr > 32b )
endline = where( strmid(header,0,8) EQ 'END     ', Nend )
if Nend GT 0 then header = header( 0:endline(0) )

; setup to see what keywords there are (if any)
keywrd = strupcase(strmid(header(0),0,7))
value = strupcase( strtrim( strmid( header(0), 10, 20 ), 2 ))

; If the first keyword is 'SIMPLE' then get its value
; We have to check now (prior to getting the rest of the fits header) to
; be sure that this is a fits file and that there's a header out there to
; get....
if ( strtrim(keywrd, 2) eq 'SIMPLE' ) then begin
    simple = (value eq 'T')
endif else begin
    simple = 0b
endelse

; Return if simple not 'T'

if not simple then goto, return_status

;
while Nend EQ 0 do begin
   if eof( unit ) then message, $
         'ERROR - EOF encountered while reading FITS header'
   readu, unit, hdr
   hdr1 = string( hdr > 32b )
   endline = where( strmid(hdr1,0,8) EQ 'END     ', Nend )
   if Nend GT 0 then hdr1 = hdr1( 0:endline(0) )
   header = [header, hdr1 ]
   endwhile
;

; Found SIMPLE = 'T' so its a fits files.  Now check that there can
; be extensions.  If there are no extensions, and no primary array, then return
; FALSE.

naxis  = sxpar(header,'naxis')
dims = sxpar(header,'naxis*')   ;Read dimensions

if (not sxpar(header, 'EXTEND') ) then begin
    if (naxis le 0) or (min(dims) eq 0) then begin
        simple = 0
        goto, return_status
    endif
endif

; Calculate the nuber of bytes taken up by the data
bitpix = sxpar(header,'bitpix')
gcount = sxpar(header,'gcount')  &  if gcount eq 0 then gcount = 1
pcount = sxpar(header,'pcount')
if naxis gt 0 then begin

 ndata = dims(0)
 if naxis gt 1 then for i=2,naxis do ndata = ndata*dims(i-1)
endif else ndata = 0


nbytes = (abs(bitpix) / 8) * gcount * (pcount + ndata)

; Read the next extension header in the file.
nrec = long((nbytes + 2879) / 2880)
point_lun, -unit, pointlun			;Current position
mhead0 = pointlun + nrec*2880l
point_lun, unit, mhead0				;Next FITS extension
readu, unit, hdr
header = string( hdr > 32b )

extension = strtrim( strupcase( sxpar( header,'XTENSION' ) ), 2 )

return_status:
	free_lun,unit

	return, simple

;we come here if the file doesn't exist
never_opened:
;	!error = 1
    free_lun, unit
	return, simple

;
end

