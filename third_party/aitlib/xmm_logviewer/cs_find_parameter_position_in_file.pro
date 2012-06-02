;+
; NAME: 
;cs_find_parameter_position_in_file.pro
;
; PURPOSE:  
;finds the parameter position in a pn... file
;
; CATEGORY:
;XMM  xmm_logviewer
;
;
; CALLING SEQUENCE:
;cs_find_parameter_position_in_file,file,parameter,par_pos=par_pos,no_elements=no_elements,par_name=par_name,par_unit=par_unit
;
;
; INPUTS: 
;file,parameter
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
;parameter-position,number of elements, parameter-name,parameter-unit
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

PRO cs_find_parameter_position_in_file,file,parameter,par_pos=par_pos,no_elements=no_elements,par_name=par_name,par_unit=par_unit
 line=strarr(1)
 leadin=strarr(5)
 unit=strarr(1)
 
 par_pos=-1
 par_name=' UNDEFINED'
 par_unit=' UNDEFINED'
 
 openr,unit_find_parameter_position_in_file,file,/get_lun
 readf,unit_find_parameter_position_in_file,leadin
 readf,unit_find_parameter_position_in_file,line
 readf,unit_find_parameter_position_in_file,unit
 
 ;wieviel Elemente?
 elements=str_sep(line(0),';')
 elements=strtrim(elements,2)
 no_elements=n_elements(elements)
 name=str_sep(leadin(4),';')
 unit=str_sep(unit(0),';')
 
;das wievielte Element?
 FOR i=0L,no_elements-1 DO BEGIN
     IF elements(i) EQ parameter THEN BEGIN 
         par_pos=i
         par_name=name(i) 
         par_unit=unit(i)
     ENDIF 
 ENDFOR
close,unit_find_parameter_position_in_file
free_lun,unit_find_parameter_position_in_file
END

