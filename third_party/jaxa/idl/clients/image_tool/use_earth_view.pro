;---------------------------------------------------------------------------
; Document name: use_earth_view.pro
; Created by:    Liyun Wang, GSFC/ARC, March 11, 1996
;
; Last Modified: Mon Mar 11 15:53:02 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO use_earth_view
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       USE_EARTH_VIEW
;
; PURPOSE: 
;       Set env variable SC_VIEW off to change point of view to Earth
;
; CATEGORY:
;       Utility
; 
; SYNTAX: 
;       use_earth_view
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
   setenv, 'SC_VIEW=0'    
END

;---------------------------------------------------------------------------
; End of 'use_earth_view.pro'.
;---------------------------------------------------------------------------
