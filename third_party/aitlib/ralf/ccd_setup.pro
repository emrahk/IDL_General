PRO CCD_SETUP
;
;+
; NAME:
;	CCD_SETUP
;
; PURPOSE:   
;	Set path for %CCD% package.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_SETUP
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	Expands !path.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

astrolib        ;link astro routines library

c=!path                         ;expand path for mid_rd_image

a=STRPOS(c,'@idl_dir:[ait]midas.tlb')
if a eq -1 then !path='@idl_dir:[ait]midas.tlb,'+!path

a=STRPOS(c,'ait321$dka400:[geckeler.idllib]')
if a eq -1 then !path='ait321$dka400:[geckeler.idllib],'+!path

RETURN
END
