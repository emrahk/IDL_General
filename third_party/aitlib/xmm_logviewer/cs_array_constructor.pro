;+
; NAME: 
;cs_array_constructor.pro
;
; PURPOSE:  
;reads data from pn files 
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_array_constructor, file, parameter, time=time, messwerte=messwerte, par_unit=par_unit
;
;
; INPUTS: 
;file, parameter
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
;time=time, messwerte=messwerte, par_unit=par_unit
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
;needs: cs_read,  cs_find_parameter_position_in_file
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_array_constructor,file,parameter, time=time, messwerte=messwerte, par_unit=par_unit, year=year
cs_read, file, length=length
cs_find_parameter_position_in_file,file,parameter,par_pos=par_pos,no_elements=no_elements,par_name=par_name,par_unit=par_unit
IF par_pos EQ -1 THEN BEGIN
time=strarr(1)
messwerte=strarr(1)
year=-1
time(0)='ERROR'
messwerte(0)='ERROR'
RETURN
ENDIF
array=dblarr(length-5,2)
daten=strarr(1)
text=strarr(1)
info=strarr(7)
i=0
openr,unit_array_constructor,file,/get_lun
readf,unit_array_constructor,info

WHILE NOT eof(unit_array_constructor) DO BEGIN  
       readf,unit_array_constructor,daten
       text=str_sep(daten(0),';')

       ;Zeit aus String lesen   
       year=(strmid(text(0),0,4))
       days=double(strmid(text(0),5,3))
       hours=double(strmid(text(0),9,2))
       minutes=double(strmid(text(0),12,2))
       seconds=double(strmid(text(0),15,2))
       subseconds=double(strmid(text(0),18,2))
       ;ERZEUGE DEZIMALEN TAG
       subh=hours/24.0
       subm=minutes/1440.0
       subs=seconds/86400.0
       subss=subseconds/8640000

    IF text(par_pos) NE '' THEN BEGIN
     array(i,0)=days+subh+subm+subs+subss
     array(i,1)=double(text(par_pos))
     i=i+1
    ENDIF
ENDWHILE    
close,unit_array_constructor
free_lun,unit_array_constructor
array=extrac(array,0,0,i,2)
time=extrac(array, 0,0,i-1,1)
messwerte=extrac(array, 0,1,i-1,1)
END
