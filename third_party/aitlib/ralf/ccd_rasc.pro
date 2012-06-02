PRO CCD_RASC, in, data, head, SILENT=silent
;
;+
; NAME:
;	CCD_RASC	
;
; PURPOSE:   
;	Read simple ascii file row by row, ignoring an arbitrary number
;	of comment lines beginning with '%'.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_RASC, in, [ data, head, SILENT=silent ]
;
; INPUTS:
;	IN : Input filename.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	SILENT : No output of %lines on screen.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	DATA : String array containing rows.
;	HEAD : String array containing %rows.
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

c=''
data=strarr(5000)
head=strarr(5000)

if not EXIST(in) then message,'Name of file to read missing' else $
message,'Reading file : '+in,/inf

openr,unit,in,/get_lun

count=0
hcount=0
repeat begin
   readf,unit,c
   if strmid(c,0,1) eq '%' then begin
      if not EXIST(silent) then print,c
      head(hcount)=c
      hcount=hcount+1
   endif else begin
      data(count)=c
      count=count+1
   endelse
endrep until EOF(unit)

free_lun,unit

if count ge 1 then data=data(0:count-1) else data=''
if hcount ge 1 then head=head(0:hcount-1) else head=''


RETURN
END
