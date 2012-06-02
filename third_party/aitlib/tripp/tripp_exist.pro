FUNCTION EXIST, var
;+
; NAME:                
;                       EXIST
;
;
;
; PURPOSE:              
;                       Check whether a variable exists or not using
;                       the size function
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
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
;
on_error,2                      ;Return to caller if an error occurs
;
siz=size(var)
if siz[1] eq 0 then exfl=0 else exfl=1

return,exfl
end
