;---------------------------------------------------------------------------
; Document name: is_soho_view.pro
; Created by:    Liyun Wang, GSFC/ARC, March 11, 1996
;
; Last Modified: Mon Mar 11 16:19:35 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION soho_view
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       SOHO_VIEW()
;
; PURPOSE: 
;       Check to see if SC_VIEW is set on
;
; CATEGORY:
;       Utility
; 
; SYNTAX: 
;       Result = soho_view()
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, March 11, 1996, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   
   RETURN, (FIX(getenv('SC_VIEW')) EQ 1)
END

;---------------------------------------------------------------------------
; End of 'is_soho_view.pro'.
;---------------------------------------------------------------------------
