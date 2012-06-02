;+
; NAME: 
;cs_find_file_number.pro
;
;
; PURPOSE:  
;if the file format is pn... , the procedure returns the correct filenumber for a parameter 
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_find_file_number, param_number, file_number=file_number
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
;the number of the file; 1 or 2
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
;includes: 
;needs: assocliste.dat
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

PRO cs_find_file_number, param_number, file_number=file_number
   openr,unit_find_file_number,'assocliste.dat',/get_lun
   zeile=strarr(1)
   text=strarr(1)
   file_number=0
   file_no=0
   WHILE NOT eof(unit_find_file_number) DO BEGIN 
       file_no=file_no+1
       readf,unit_find_file_number,zeile
       text=str_sep(zeile(0),';')
       IF text(0) EQ param_number THEN BEGIN 
CASE 1 of
   (file_no LE 64): file_number=1
   ((file_no GT 64) and (file_no LE 127)): file_number=2 
   ((file_no GT 127) and (file_no LE 191)): file_number=3
   ((file_no GT 191) and (file_no LE 197)): file_number=4
   ((file_no GT 197) and (file_no LE 204)): file_number=10
 ELSE:
ENDCASE
      ENDIF
   ENDWHILE
   close,unit_find_file_number
   free_lun,unit_find_file_number
   file_number=STRTRIM(STRING(file_number), 2)
END
