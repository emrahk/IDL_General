;+
; NAME:
;cs_load
;
;
; PURPOSE:
;loads auto-saved (by xmm_logviewer) file or extracts the arrays from the pn... file 
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_load, orig_path, user_path, i, x_parameter, y_parameter, autosave, xwerte=xwerte, ywerte=ywerte, xunit=xunit, yunit=yunit 
;
;
; INPUTS:
;orig_path, user_path, i, x_parameter, y_parameter, autosave
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
;xwerte=xwerte, ywerte=ywerte, xunit=xunit, yunit=yunit 
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
;needs: cs_find_file_number, cs_array_constructor, cs_save,
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_load, orig_path, user_path, i, x_parameter, y_parameter, autosave, xwerte=xwerte, ywerte=ywerte, xunit=xunit, yunit=yunit 
format=0
CASE 1 OF
		(i LT 10): umlaufzahl='000'+STRTRIM(STRING(i),2) 
       	(i LT 100) AND (i GT 9): umlaufzahl='00'+STRTRIM(STRING(i),2)
  		(i LT 1000) AND (i GT 99): umlaufzahl='0'+STRTRIM(STRING(i),2)
            ELSE: umlaufzahl=STRTRIM(STRING(i),2)
 ENDCASE

user_filename=STRCOMPRESS(y_parameter+'_' +umlaufzahl+'.asci', /REMOVE_ALL)
user_file=FINDFILE(user_path+user_filename, COUNT=filescounter)
cs_find_file_number, y_parameter, file_number=file_number 
IF filescounter NE 0 THEN format=1
IF file_number EQ 10 THEN format=2

CASE format OF 
         1 : BEGIN   
           reader=strarr(1)
           openr,unit_load,user_path+user_filename,/get_lun
           readf,unit_load,length
           xwerte=dblarr(length)
           ywerte=dblarr(length)                 
           readf,unit_load,xwerte
           readf,unit_load,ywerte  
           readf,unit_load,reader
           xunit=STRTRIM(reader,2)  
           readf,unit_load,reader
           yunit=STRTRIM(reader,2)
           close,unit_load
           free_lun,unit_load 
           END
         2: BEGIN   ;; nur für bestimmte files im jahr 2000 
              nummer=STRTRIM(STRING(FLOOR(((umlaufzahl*2-22)-178)/4) ), 2)
              filename=orig_path+'radiation/XMM__XMM_RADIATION_'+nummer+'.DAT'
              pn_file=FINDFILE(filename, COUNT=filescounter)
              IF ((file_number GT 0) AND (filescounter GT 0)) THEN BEGIN
               cs_array_constructor, filename, y_parameter, time=xwerte, messwerte=ywerte, par_unit=yunit , year=year
                xunit='days of year '+STRTRIM(STRING(year),2)
               IF ((autosave EQ 'YES') AND (STRTRIM(STRING(xwerte(0)),2) NE 'ERROR')) THEN cs_save, user_path, user_filename,  xwerte, ywerte, xunit, yunit  
             ENDIF ELSE BEGIN
              xwerte=strarr(1)
              ywerte=strarr(1)
              yunit=strarr(1)
              xunit=strarr(1)
              xwerte(0)='ERROR'
              ywerte(0)='ERROR' 
              yunit(0)='ERROR'
              xunit(0)='ERROR'
              ENDELSE
             END
         ELSE :   BEGIN
              filename=orig_path+'pn_0'+file_number+'_rev'+umlaufzahl+'.dat'
              pn_file=FINDFILE(filename, COUNT=filescounter)
              IF ((file_number GT 0) AND (filescounter GT 0)) THEN BEGIN
               cs_array_constructor, filename, y_parameter, time=xwerte, messwerte=ywerte, par_unit=yunit ,year=year
                xunit='days of year '+STRTRIM(STRING(year),2)
               IF ((autosave EQ 'YES') AND (STRTRIM(STRING(xwerte(0)),2) NE 'ERROR')) THEN cs_save, user_path, user_filename,  xwerte, ywerte, xunit, yunit  
             ENDIF ELSE BEGIN
              xwerte=strarr(1)
              ywerte=strarr(1)
              yunit=strarr(1)
              xunit=strarr(1)
              xwerte(0)='ERROR'
              ywerte(0)='ERROR' 
              yunit(0)='ERROR'
              xunit(0)='ERROR'
              ENDELSE
	    END
    
       ENDCASE
END
