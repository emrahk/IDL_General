;+
; PROJECT:
;	SDAC
; NAME: 
;	TEK_END
;
; PURPOSE: 
;	This procedure closes plot file and set plotting device back to screen device selected. 
;
; CATEGORY:
;	GRAPHICS
;
; CALLING SEQUENCE:
;       TEK_PRINT
;
; INPUTS:
;       None.
;
; COMMON BLOCK:
;       TEK_COMMON.
;
; PROCEDURE:
; 	TEK_END is called after calling TEK_INIT and issuing plot commands, 
; 	to close the plot file and set the plotting device back to the screen
; 	device selected.  Implemented for TEK and PS only.
;
; 	See documentation on TEK_INIT for full explanation.
; 	Briefly, to make hardcopies of plots, use IDL commands:
;   	tek_init
;   	plot commands ...
;   	tek_end
;   	tek_print
;
; MODIFICATION HISTORY:
; 	Written by AKT and richard.schwartz@gsfc.nasa.gov, 1990.
;       Mod. 05/06/96 by RCJ. Added documentation.
;	Version 3, richard.schwartz@gsfc.nasa.gov, 10-nov-1999.  set
;	screen device using xdevice to accommodate WIN and MAC safely.
;-
;
pro tek_end, dummy

common tek_common, lun, tekfile, use_screen, sc_device, hard_device, queue

; To maintain compatibility with old versions, tek device must be closed 
; on this call.

if hard_device eq 'TEK' then begin
   device,/close 
   free_lun,lun
endif
;
; Set plot device back to screen and fonts back to Hershey vector drawn.
set_plot,xdevice(sc_device)
!p.font = -1

end

