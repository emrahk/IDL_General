;+
; NAME:
;cs_save
;
;
; PURPOSE:
; saves data to autosave format
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_save,  user_path, user_filename,  xwerte, ywerte, xunit, yunit
;
;
; INPUTS:
;user_path, user_filename,  xwerte, ywerte, xunit, yunit
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
;
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
PRO cs_save,  user_path, user_filename,  xwerte, ywerte, xunit, yunit
format=1    
case format of
   1 : begin   
        orig_length=N_ELEMENTS(xwerte)
        openw,unit_save, user_path+user_filename,/get_lun
        printf,unit_save,orig_length
        for u=0,orig_length-1 do begin 
        printf,unit_save,xwerte(u)
        endfor
        for u=0,orig_length-1 do begin 
        printf,unit_save,ywerte(u)
        endfor
        printf,unit_save,xunit
        printf,unit_save,yunit
        close,unit_save
        free_lun, unit_save
        end
    else:      
   endcase

END
