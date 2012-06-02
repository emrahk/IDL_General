;+
; NAME:
;cs_read
;
;
; PURPOSE:
; returns length of pn... file
;
;
; CATEGORY:
; xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_read,filename,length=length
;
;
; INPUTS:
;filename
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;length
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_read,filename,length=length
  
   befehl="wc -l "+filename
   spawn,befehl,dim

   dimension=strarr(1)
   dim=strtrim(dim(0),2)
   dimension=str_sep(dim(0),' ')
   length=long(dimension(0))

END
