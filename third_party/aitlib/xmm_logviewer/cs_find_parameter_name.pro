;+
; NAME: 
;cs_find_parameter_name.pro
;
; PURPOSE:  
;searches for the name of a parameter for a given number; e.g. F 1375 => A1 DSLINC
;subroutine of cs_xmm_logviewer.pro
;
; CATEGORY:
;XMM  xmm_logviewer
;
;
; CALLING SEQUENCE:
;cs_find_parameter_name, param_number, name=name, unit=unit
;
;
; INPUTS: 
;number of a paramter; e.g. F 1375
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
;the name of the parameter; 
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

PRO cs_find_parameter_name, param_number, name=name, unit=unit
   openr,unit_find_name,'assocliste.dat',/get_lun
   zeile=strarr(1)
   text=strarr(1)
   name='NOT FOUND'
   unit='NOT FOUND'
   WHILE NOT eof(unit_find_name) DO BEGIN 
       readf,unit_find_name,zeile
       text=str_sep(zeile(0),';')
       IF text(0) EQ param_number THEN BEGIN 
           name=STRTRIM(text(1),1)
           unit=text(2)
   ENDIF
   ENDWHILE
   close,unit_find_name
   free_lun,unit_find_name
END
