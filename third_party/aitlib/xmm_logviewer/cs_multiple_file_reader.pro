;+
; NAME:
;cs_multiple_file_reader
;
;
; PURPOSE:
;evaluates one or more orbits
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_multiple_file_reader, rev_from, rev_to, orig_path, user_path, x_parameter,x_parameter_name,y_parameter, y_parameter_name, time_interval,  color, sym, background, y_style, autosave, datatype=datatype, nachricht=nachricht

;
;
; INPUTS:
;rev_from, rev_to, orig_path, user_path, x_parameter,x_parameter_name,y_parameter, y_parameter_name, time_interval,  color, sym, background, y_style, autosave,
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
;datatype,nachricht
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
; needs: cs_load, cs_correlation_constructor, make_datatype
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_multiple_file_reader, rev_from, rev_to, orig_path, user_path, x_parameter,x_parameter_name,y_parameter, y_parameter_name, time_interval,  color, sym, background, y_style, autosave, datatype=datatype, nachricht=nachricht
nachricht='Done'
ges_xwerte=dblarr(1)
ges_ywerte=dblarr(1)

 FOR i=rev_from, rev_to DO BEGIN

; Laden der einzelnen Umlaufsdaten 
      IF STRUPCASE(x_parameter_name) NE 'TIME' THEN BEGIN
              cs_load, orig_path, user_path, i, 'TIME', x_parameter, autosave, xwerte=xwerte2, ywerte=ywerte2, xunit=xunit2, yunit=yunit2
              cs_load, orig_path, user_path, i, 'TIME', y_parameter, autosave, xwerte=xwerte1, ywerte=ywerte1, xunit=xunit1, yunit=yunit1 
       IF ((xwerte2(0) EQ 'ERROR') OR (xwerte1(0) EQ 'ERROR')) THEN BEGIN
             datatype=''
             nachricht='ERROR: File or Parameter not found'
             RETURN      
        ENDIF 
              cs_correlation_constructor, xwerte1, ywerte1, xwerte2, ywerte2, time_interval, xwerte=xwerte, ywerte=ywerte
		 xunit=yunit2
		 yunit=yunit1
     ENDIF ELSE BEGIN
             cs_load, orig_path, user_path, i, x_parameter, y_parameter, autosave, xwerte=xwerte, ywerte=ywerte, xunit=xunit, yunit=yunit  
            IF STRTRIM(STRING(xwerte(0)), 2) EQ 'ERROR' THEN BEGIN
             datatype=''
             nachricht='ERROR: File or Parameter not found'
             RETURN      
        ENDIF  
   ENDELSE

; Aneinanderhängen der einzelnen Umläufe
     IF (i EQ rev_from) THEN BEGIN  
        ges_xwerte=xwerte
        ges_ywerte=ywerte
       ENDIF ELSE BEGIN
       ges_xwerte=[ges_xwerte,xwerte]
       ges_ywerte=[ges_ywerte,ywerte]
      ENDELSE

 ENDFOR

    make_datatype, ges_xwerte, ges_ywerte, STRING(rev_from)+STRING(rev_to), x_parameter_name, y_parameter_name, xunit, yunit , color, sym, background, y_style, datatype=datatype

 END
