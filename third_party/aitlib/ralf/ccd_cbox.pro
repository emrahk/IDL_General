FUNCTION CCD_CBOX, strvec, LEFT=left
;
;+
; NAME:
;	CCD_CBOX
;
; PURPOSE:   
;	Add blanks to each element of a vector of strings to
;	obtain elements with same length.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_CBOX( strvec, [ LEFT=left ] )
;
; INPUTS:
;	STRVEC : Vector of strings.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;       LEFT : String starts with the first character of original string.
;              Default is ending with last character of original string.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	Oplots on current graphics device.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(strvec) then message,'Vector of strings missing'

str=STRTRIM(strvec,2)
slen=STRLEN(str)
maxlen=max(slen)

fill='                             '
fillen=STRLEN(fill)

if not EXIST(left) then begin
   str=fill+str
   for i=0,n_elements(str)-1 do $
   str(i)=STRMID(str(i),slen(i)+fillen-maxlen,maxlen)
endif else begin
   str=str+fill
   for i=0,n_elements(str)-1 do $
   str(i)=STRMID(str(i),0,maxlen)
endelse

RETURN,str
END
