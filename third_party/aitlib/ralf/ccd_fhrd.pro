PRO CCD_FHRD, file, key, extr, extension=extension
;
;+
; NAME:
;	CCD_FHRD
;
; PURPOSE:   
;	Extract a string or number from FITS header.
;	Program returns either the string or in case of a number a
;	double precision number.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_FHRD, file, key , [ extr ]
;
; INPUTS:
;	FILE : Name of FITS file.
;	KEY  : FITS header keyword to search for, e.g. 'EXPTIME'
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	EXTR : Extracted string or number.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(file) then message,'File name missing'
if n_elements(extension) EQ 0 then extension=0

if not EXIST(key) then message,'Search key missing' else key=STRLOWCASE(key)

h=HEADFITS(file,exten=extension)

num_h=n_elements(h)
hkey=strarr(num_h)
for i=0,num_h-1 do begin
   p=STRPOS(h(i),'=')
   if p(0) ne -1 then hkey(i)=STRTRIM(STRMID(h(i),0,p(0)),2)
endfor

ind=where(STRLOWCASE(hkey) eq STRLOWCASE(key))
if ind(0) eq -1 then $
message,'Error finding key in FITS header' else row=h(ind(0))

if STRPOS(row,"'") ne -1 then begin
   row=STR_SEP(row,"'")
   if n_elements(row) ne 3 then $
   message,'Error reading string from FITS header'
   extr=STRTRIM(STRCOMPRESS(row(1)),2)
endif else begin
   pos=STRPOS(row,'=')
   if pos eq -1 then $
      message,'Error reading number from FITS header' else begin $
      row=STRMID(row,pos+1,100)
      row=STRTRIM(STRCOMPRESS(row),2)
      row=STR_SEP(row,' ')
      extr=double(row(0))
   endelse
endelse

RETURN
END
