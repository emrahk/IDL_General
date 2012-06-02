;+
; NAME: 
;cs_find_parameter_number.pro
;
; PURPOSE:  
;searches for the number of a parameter for a given name; e.g. F 1375 <= A1 DSLINC
;subroutine of cs_xmm_logviewer.pro
;
; CATEGORY:
;XMM  xmm_logviewer
;
;
; CALLING SEQUENCE:
;cs_find_parameter_number,parameter, number=number, unit=unit
;
;
; INPUTS: 
;name of a paramter; e.g. A1 DSLINC
;
;
; OPTIONAL INPUTS:
;none
;
;
; KEYWORD PARAMETERS:
;none
;
;
; OUTPUTS:
;the number and the unit of the parameter 
;
;
; OPTIONAL OUTPUTS:
;none
;
;
; COMMON BLOCKS:
;none
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
; none
;
;
; PROCEDURE:
;includes: -
;needs: assocliste.dat
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_find_parameter_number, parameter, number=number, unit=unit
   openr,unit_find_number,'assocliste.dat',/get_lun
   zeile=strarr(1)
   text=strarr(1)
   number='N/A'
   unit='NOT FOUND'
   WHILE NOT eof(unit_find_number) DO BEGIN 
       readf,unit_find_number,zeile
       text=str_sep(zeile(0),';')
       IF STRTRIM(text(1),2) EQ STRTRIM(parameter,2) THEN BEGIN 
           number=text(0)
           unit=text(2)
   ENDIF
   ENDWHILE
   close,unit_find_number
   free_lun,unit_find_number
END
