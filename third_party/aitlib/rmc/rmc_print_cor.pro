PRO RMC_PRINT_COR,event
;+
; NAME:  rmc_print_cor
;
;
;
; PURPOSE:  starts rmc_print with the keyword correlation, for
; printing the 2D correlation map
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_PRINT_COR,event  (from menu in the main program) 
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
; $Log: rmc_print_cor.pro,v $
; Revision 1.2  2002/05/21 13:08:53  slawo
; Add comments
;
;-
   
   rmc_print,event,/correlation
END 




