;---------------------------------------------------------------------------
; Document name: use_soho_view.pro
; Created by:    Liyun Wang, GSFC/ARC, March 11, 1996
;
; Last Modified: Mon Mar 11 15:51:06 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO use_soho_view
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       USE_SOHO_VIEW
;
; PURPOSE: 
;       Set env variable SC_VIEW on to change point of view to SOHO
;
; CATEGORY:
;       Utility
; 
; SYNTAX: 
;       use_soho_view
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
   setenv, 'SC_VIEW=1' 
END


;---------------------------------------------------------------------------
; End of 'use_soho_view.pro'.
;---------------------------------------------------------------------------
