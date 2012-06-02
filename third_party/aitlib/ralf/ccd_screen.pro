PRO CCD_SCREEN, filename
;
;+
; NAME:
;	CCD_SCREEN
;
; PURPOSE:   
;	Create PS-file from window.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_SCREEN, filename
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
;	PS-File of active window.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - written 1996.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(filename) then filename='screen.ps'

a=TVRD()

set_plot,'ps'
device,/landscape,xsize=26,ysize=16,yoffset=29,filename=filename

a=max(a)-a
tvscl,a

device,/close
set_plot,'x'


RETURN
END
