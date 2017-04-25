;+
; Project:
;	 SDAC
;
; NAME:
;	 SET_GRAPHICS
;
; PURPOSE:
;	This procedure sets screen and hardcopy output graphic devices for use with the
;	TEK_INIT, TEK_PRINT, and TEK_END procedures (which now
;	handle both Tektronix and PostScript format).
;
; CATEGORY:
;	GRAPHICS
;
; CALLING SEQUENCE:
;       SET_GRAPHICS[,SCREEN=SCREEN,PRINTER=PRINTER,ERROR=ERROR,QUERY=QUERY, $
;		HELP=HELP]
; CALLS:
;       Checkvar, chklog.
;
; INPUTS:
;       None.
;
; KEYWORDS:
;   	SCREEN:		Screen device type.  Options are 'TEK', 'REGIS', 'X',
;			and 'Z', 'NULL'. On return, SCREEN contains the screen
;			device type selected. Default is X in X-windows, MAC for
;			MacOS, Win for WINDOWS
;			machines, TEK otherwise.
;   	PRINTER:	Printer device type.  Options are 'TEK' and 'PS'.
;			On return PRINTER contains the printer device type
;			selected. Default is PS.
;   	ERROR:		0/1 means no error / error
;   	QUERY:		0/1 means prompt/don't prompt user for device types
;			(only for device not selected via SCREEN or PRINTER
;			keyword)
;   	HELP:		=1 means print current selection of device types on
;			screen.
;
; COMMON BLOCKS:
;       TEK_COMMON.
;
; PROCEDURE:
; 	To make hardcopies of plots on Talaris 800, use IDL commands:
;   	tek_init
;    	plot commands ...
;   	tek_end
;   	tek_print
; 	(tek_init calls set_graphics if you haven't called it explicitly)
;
; 	Screen and printer device types are saved in sc_device and hard_device
; 	in common tek_common.
;
; MODIFICATION HISTORY:
;       Mod. 09/02/92 by AKT. Made PS the default for hard_device.
;	Mod. 05/06/96 by RCJ . Added documentation.
;	Version 3, richard.schwartz@gsfc.nasa.gov, 2-feb-1998.
;	Version 4, richard.schwartz@gsfc.nasa.gov, 5-apr-1998.; CONTACT:
;	Version 5, richard.schwartz@gsfc.nasa.gov, 10-nov-1999.  set
;	screen device in common to WIN under Windows.
;	richard.schwartz@gsfc.nasa.gov
;-
;
pro set_graphics, screen = SCREEN, printer= PRINTER, error=error, query=query,$
	help=help

on_error,2
!quiet = 1
;
common tek_common, lun, tekfile, use_screen, sc_device, hard_device, queue
;
;
error=0 ;initialize to no error condition
;
checkvar, sc_device, 'NOTSET'
checkvar, hard_device, 'NOTSET'
;
;-------------------------------------------------------------------------
;
;If help requested, tell user which graphics device types are currently
;selected, then exit set_graphics.
;
sc_device = ([sc_device,xdevice()])( (where( sc_device eq ['X','MAC','WIN']))(0)+1<1 )
if keyword_set(help) then begin
        PRINT,' '
	PRINT,'Current screen type  = ',SC_DEVICE, $
            '  (Options are TEK, REGIS, X, WIN, Z, or NULL)'
       	PRINT,'Current printer type = ',HARD_DEVICE, '  (Options are PS or TEK)'
        PRINT,' '
        PRINT,'Calling syntax to set graphics devices:'
        PRINT,'    SET_GRAPHICS,[SCREEN=screen_device],[PRINTER=print_device]
        PRINT,"    where screen_device = 'TEK', 'REGIS', 'X','WIN', 'Z',or 'NULL'"
	;Print,"    Use X for any windowing operating system."
        PRINT,"    and   print_device  = 'PS', or 'TEK'"
        PRINT,' '
;	goto,getout
endif
;
;-------------------------------------------------------------------------
;  Set screen device explicitly through SCREEN, by default, or by query
;
checkvar, SCREEN,''
if SCREEN ne '' then sc_device = strupcase(SCREEN)
if keyword_set(query) then begin
   if SCREEN eq '' then $
      read,'Enter screen graphics device type (TEK, REGIS, X, WIN, Z, or NULL) ',SCREEN
   sc_device = strupcase(SCREEN)
endif
;
if sc_device eq 'NOTSET' then begin
;  if this device is capable of windows (the logical name idl_device
;  will be set to 'X') set screen device to X,  otherwise TEK.
   sc_device = 'TEK'
   idl_device = chklog ('idl_device', os)    ; Translate the logical
   if idl_device eq '' then begin
      if os eq 'vms' then begin
         spawn, 'write sys$output f$getdvi("tt", "devtype")', result
         if result(0) eq '112' then idl_device ='X' else idl_device= 'TEK'
      endif else idl_device = 'TEK'
   endif
   idl_device = ([idl_device,'X'])( (where( sc_device eq ['X','MAC','WIN']))(0)+1<1 )
   idl_device = xdevice(!d.name)
   if (not keyword_set(query)) and  ( (where( idl_device eq ['X','MAC','WIN']))(0)+1<1 ) $
      then sc_device=xdevice()
   ;if (!d.name eq 'X') then idl_device='X'
   ;if (not keyword_set(query)) and (strupcase(idl_device) eq 'X') $
   ;   then sc_device='X'
endif
SCREEN = sc_device
;
;-------------------------------------------------------------------------
;  Set printer device explicitly through PRINTER, by default, or by query
;
checkvar, PRINTER, ''
if PRINTER ne '' then hard_device = strupcase(PRINTER)
if keyword_set(query) then begin
   if PRINTER  eq '' then $
   read,'Enter printer graphics device type (TEK or PS) ', PRINTER
   hard_device = strupcase(PRINTER)
endif
;
if hard_device eq 'NOTSET' then begin
;  if user has already set a valid graphics hard copy device outside of
;  set_graphics, then it should be the default, otherwise the default will
;  be PS.
   hard_device = 'PS'
   if !d.name eq 'TEK' then hard_device='TEK'
endif
PRINTER = hard_device
;
;-------------------------------------------------------------------------
;
;Check for unsupported graphics device types.
valid_screen = 'TEK,REGIS,NULL,Z,X,MAC,WIN'
valid_print  = 'TEK,PS'
wscreen = where( xdevice(sc_device) eq str_sep(valid_screen,','),nscreen)
whard   = where( hard_device eq str_sep(valid_print,','),nhard)
;
if nhard*nscreen THEN GOTO, VALID else begin
	error=1
	PRINT,'ERROR: Invalid screen or print graphics device type chosen.'
	PRINT,'Screen options are TEK, REGIS, NULL, Z, X, MAC, or WIN.  Current = ',SC_DEVICE
	PRINT,'Printer options are PS or TEK.  Current = ',HARD_DEVICE
ENDELSE

VALID:
GETOUT:
screen = xdevice(sc_device)

return
end
