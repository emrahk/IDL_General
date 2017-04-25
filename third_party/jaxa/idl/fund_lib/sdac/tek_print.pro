;+
; PROJECT:
;	SDAC
; NAME: 
;	TEK_PRINT
;
; PURPOSE: 
;	This procedure sends a plot file to printer.
;
; CATEGORY:
;       GRAPHICS
;
; CALLING SEQUENCE:
;       TEK_PRINT,Delete_file[,VERSION_NUMBER=V,FILENAME=FNM,QUEUE=Q]
; EXAMPLES:
;	tek_print,filename='fsplot'
;
; CALLS:
;       Checkvar, defaults, psplot.
;
; INPUTS:
;	None.
;
; OPTIONAL INPUTS: 
;	DELETE_FILE:	If set to 'D' or 'd', plot file is deleted after 
;			printing.
;
; KEYWORDS:
;       VERSION_NUMBER:	Version number of plot file to print (default is
;			highest version).
;   	FILENAME:	Plot file to print (default is name stored in 
;			common tek_common)
;   	QUEUE:		Printer queue to send plot to (default is net$print)
;	    		queue is remembered for remainder of IDL session
; COMMON BLOCKS:
;       TEK_COMMON.
;
; PROCEDURE:
;       TEK_PRINT is called after calling TEK_INIT, issuing plot commands,
;	and calling TEK_END, to send a plot file to the printer.
; 	See documentation on TEK_INIT for full explanation.
; 	Briefly, to make hardcopies of plots, use IDL commands:
;   	tek_init
;   	plot commands ...
;   	tek_end
;   	tek_print
;
; 	tek_print sends the plot file whose name is stored in common tek_common
; 	to the printer queue selected.
;
; MODIFICATION HISTORY:
;	Written by AKT and richard.schwartz@gsfc.nasa.gov.
;       Mod. 03/29/96 by RAS. Version 2. Made hard_device string lower case 
;		when concatenating filename, and since psplot knows the default
;		queue it should not be passed unless it is explicit.
;	Mod. 05/06/96 by RCJ. Added documentation.
;       Mod. 09/04/97 by AES. changed default printer to EAF_POST1
;	Version 5, richard.schwartz@gsfc.nasa.gov, 8-sep-1997, changed
;	default printer queue to PSLASER
;-
;
pro tek_print, delete_file, version_number=v, filename=fnm, queue=q

on_error,2

common tek_common, lun, tekfile, use_screen, sc_device, hard_device, queue

q_in = exist(q)
; Set queue if not already set.  This will be remembered for rest of session
;checkvar, queue, 'net$print'
checkvar, queue, 'PSLASER' ;'eaf_post1'
checkvar, q, queue
queue=q

; set plot device temporarily back to the printer device so that we can close
; it.  At end of TEK_PRINT, we will reset plot device to the current device.
old_device = !d.name
set_plot,hard_device
device,/close

checkvar,fnm,tekfile,'TEKPLOT'
defaults,fnm,'','','.' + strlowcase(hard_device)
;
;-------------   TEKTRONIX BLOCK   ------------------

if hard_device eq 'TEK' then begin

	free_lun,lun
	use_screen = 1 ; restore use_screen to default value for next call
	checkvar,v,''  ; set version to latest if not set
	if strpos(fnm,';') eq -1 then fnm=fnm+';'
	fnm=fnm+strtrim(v,2)
	if (n_params(0) eq 0) then delete_file = 'N'

	if ((delete_file eq 'D') or (delete_file eq 'd')) then begin
		command_string = "$ PRINT /SETUP=TEK /QUEUE = " + $
			QUEUE + "/DELETE " + fnm
	endif else begin
		command_string = "$ PRINT /SETUP=TEK /QUEUE = " + $
			QUEUE + " "+fnm 
	endelse

	print, command_string
	spawn, command_string
endif 

;---------------  POSTSCRIPT BLOCK  ----------------


if hard_device eq 'PS' THEN begin

	checkvar,delete_file,' '
	checkvar,v,0
	checkvar,fnm,tekfile
        if not q_in then queue = ''
	if strupcase(delete_file) eq 'D' THEN $
		PSPLOT, V, queue=queue, /DELETE, FILENAME=fnm ELSE $
		PSPLOT, V, queue=queue, FILENAME = fnm

endif

set_plot,old_device  ;restore plot device to current screen device

return & end
