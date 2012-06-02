PRO CCD_DOC
;
;+
; NAME:
;	CCD_DOC
;
; PURPOSE:   
;	Write info lines of IDL programs in *.doc_txt.
;
; CATEGORY:
;	General
;
; CALLING SEQUENCE:
;	CCD_DOC
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	FILE : Filename, defaulted to interactive search on
;	       current directory.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	Ascii file *.doc_txt
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
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
;	Ralf D. Geckeler -  %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs
on_ioerror,BAD

c=''

file=findfile('ccd_*.pro')
num_f=n_elements(file)
if num_f(0) eq -1 then goto,DONE

for i=0,num_f-1 do begin
   openr,unit1,file(i),/get_lun
   message,'Reading '+file(i),/inf
   get_lun,unit2
   openw,unit2,CCD_APP(file(i),ext='doc_txt')

   repeat begin
      readf,unit1,c
      p=STRPOS(c,';+')
      if p ne -1 then repeat begin
      readf,unit1,c 
      printf,unit2,c
      m=STRPOS(c,';-')
      endrep until (EOF(1) or (m ne -1))
      m=STRPOS(c,';-')
   endrep until (EOF(1) or (m ne -1))

   free_lun,unit1
   free_lun,unit2
endfor

get_lun,unit
openw,unit,'all.doc_txt'
for i=0,num_f-1 do begin
   FDECOMP,file(i),disk,dir,name,qual,version
   printf,unit,name+'.'+qual
endfor
free_lun,unit

BAD:message,'No info for this file available',/inf & free_lun,unit1

DONE:
RETURN
END
