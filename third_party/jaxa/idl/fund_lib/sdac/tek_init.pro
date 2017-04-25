;+
; PROJECT:
;	SDAC
; NAME: 
;	TEK_INIT
;
; PURPOSE: 
;	Set up for making Tektronix or PostScript hardcopies of plots from IDL.
;
; CATEGORY:
;	GRAPHICS
;
; CALLING SEQUENCE:
; 	TEK_INIT[,FILENAME=FNM,NOSCREEN=NOSCREEN,UPDATE=UPDATE,QUEUE=Q]
;
; EXAMPLES:
;	tek_init, file='qlarchive', update=update; CALLS:
; CALLS:
;       Checkvar, set_graphics, defaults_2.
;
; INPUTS:
;       None.
;
; KEYWORDS:
;	FILENAME:	File descriptor for plot file, if no extension then
;		   	the default is .tek or .ps
;	NOSCREEN:	Only send tektronix output to the file, Set if tek 
;			is used for hardcopy, while X for instance is used 
;			for screen.
;	UPDATE:		Add to already existing plot file (VALID ONLY FOR tek)
;	QUEUE:		Printer queue.  net$print is default queue.
;
; COMMON BLOCKS:
;       TEK_COMMON.
;
; PROCEDURE:
;
; 	First call SET_GRAPHICS, SCREEN=SCREEN, PRINTER=PRINTER where 
;	SCREEN is 'x', 'tek', or 'regis', and PRINTER is 'TEK' or 'PS'.  
;	If user doesn't call SET_GRAPHICS before calling TEK_INIT, TEK_INIT 
;	will call it and set the printer type to the default which is PS.
;
; 	To make hardcopies of plots, use IDL commands:
;   	tek_init
;   	plot commands ...
;   	tek_end
;   	tek_print
;
; 	For both TEK and PS, calls set_plot to set plot device to the printer 
;	device. TEK_END will reset the plot device to the screen device.  
;	TEK_PRINT will close the file and send it to the printer.
;
; 	TEKTRONIX:
; 	Tektronix output will be created if HARD_DEVICE is set to 'TEK' by
; 	SET_GRAPHICS.  Tektronix graphics is capable of sending plots 
;	simultaneously to the terminal screen and to disk file for hardcopy 
;	plots.  This is the default (both screen and file).  User may disable 
;	plotting to the screen by using /noscreen on the first call to 
;	TEK_INIT.  The output file may be subsequently reopened by using 
;	TEK_INIT,/update in order to overlay plot commands on an existing 
;	plot.  The screen/noscreen option is saved in the common block 
;	variable USE_SCREEN.  The plot device is reset to the screen device 
;	previously selected (SC_DEVICE) when TEK_END is called.
;
; 	POSTSCRIPT:
; 	Postscript files will be created if HARD_DEVICE is set to 'PS' by
; 	SET_GRAPHICS..  Opens a new file is /update is not selected.  Otherwise
; 	does nothing further.
;
; MODIFICATION HISTORY:
;       Written by AKT and richard.schwartz@gsfc.nasa.gov.
;       Mod. 06/28/95 by AES. Make filenames lowercase.
;	Mod. 05/06/96 by RCJ. Added documentation.
;-
;
pro tek_init, filename=fnm, noscreen=noscreen, update=update, queue=q

on_error,2 

common tek_common, lun, tekfile, use_screen, sc_device, hard_device, queue

; If a queue name was passed as keyword arguement, set to default.
checkvar,q,'NET$PRINT'
queue = q
;
; If the user didn't call SET_GRAPHICS, then calling it here will set
; the devices to the defaults.  If user did call it, this call with do nothing.
set_graphics 

; Check that the hardcopy device is supported.
if (hard_device ne 'TEK') AND (hard_device NE 'PS') then begin
   print,'Invalid printer device: ',hard_device
   print,'TEK and PS are supported.'
   return
endif

; Set the plot device to the printer selected. (Plot device will be reset
; to the screen device selected in call to TEK_END.)
set_plot,hard_device

; If we're not overlaying on an exising file, then close any file alread open
if not keyword_set(update) then	device,/close

; ----------  TEKTRONIX BLOCK  -----------

if hard_device eq 'TEK' then begin ;
	
	; use_screen = -1/1 means don't/do plot on screen
	; Default is to plot to the screen, unless screen device is not TEK.
	; If user passed NOSCREEN keyword, don't plot on screen.
	checkvar,use_screen,1 
	if sc_device ne 'TEK' then  use_screen=-1
	if keyword_set(noscreen) then use_screen=-1

	; Default file name is tekplot.dat.
	checkvar,fnm,'TEKPLOT.DAT'
       	defaults_2, file=fnm, ext= '.' + hard_device
;

	; if updating a file, then close it and reopen with append.  Otherwise
	; just open a file.
	if keyword_set(update) then begin
	   device,/close
	   openu, lun, fnm ,/NONE,/append, /get
	endif else openw, lun, fnm, /NONE,/get
;
	device, plot_to= (-1)* use_screen * lun, gin_chars=6
        
endif 


; -----------  POSTSCRIPT BLOCK  -----------

if hard_device ne 'TEK' then begin 

	; Select hardware drawn font
	!p.font = 0

	; If we're updating a file, don't need to do anything.  Otherwise,
	; create a new file called IDL.PS.
	if not keyword_set(UPDATE) then begin
	 	checkvar,fnm,'IDL'
		defaults_2, file=fnm, ext= '.' + strlowcase(hard_device)
	 	device,file=fnm ;
	endif
endif

tekfile=fnm  ; store the filename in common tek_common

end
