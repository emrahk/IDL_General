	PRO LOAD, TABLE_NUMBER, DISABLE=DISABLE, BOTTOM=BOTTOM, _EXTRA=_EXTRA
;+
; Project     : SOHO - CDS
;
; Name        : 
;	LOADCT
; Purpose     : 
;	Load predefined color tables.
; Explanation : 
;	The image display device is selected (unless DISABLE is set), and
;	LOADCT is called to display the color tables.  See LOADCT in the IDL
;	User's Library for more information.
; Use         : 
;	LOADCT  [, TABLE]
; Inputs      : 
;	None required.
; Opt. Inputs : 
;	TABLE	= The number of the pre-defined color table to load, from 0 to
;		  15.  If this value is omitted, a menu of the available tables
;		  is printed and the user is prompted to enter a table number.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	DISABLE	= If set, then TVSELECT is not used.
;	BOTTOM	= The minimum value of the scaled image array, as used by
;		  BYTSCL.  The default is 0.
;
;       See the help for LOADCT for other supported keywords.
;
; Calls       : 
;	TVSELECT, TVUNSELECT, GET_IM_KEYWORD
; Common      : 
;	None, but calls LOADCT, which uses the common block COLORS.
; Restrictions: 
;	Works from the file: $IDL_DIR/colors1.tbl.
;
;	In general, the SERTS image display routines use several non-standard
;	system variables.  These system variables are defined in the procedure
;	IMAGELIB.  It is suggested that the command IMAGELIB be placed in the
;	user's IDL_STARTUP file.
;
;	Some routines also require the SERTS graphics devices software,
;	generally found in a parallel directory at the site where this software
;	was obtained.  Those routines have their own special system variables.
;
; Side effects: 
;	The color tables of the currently-selected device are modified.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, April 1992, added SILENT and DISABLE keywords.
; Written     : 
;	William Thompson, GSFC.
; Modified    : 
;	Version 1, William Thompson, GSFC, 13 May 1993.
;		Incorporated into CDS library.
;       Version 2, William Thompson, GSFC, 3-Jan-2006
;               Added BOTTOM, and _EXTRA (which includes /SILENT)
;               Added call to GET_IM_KEYWORD
; Version     : 
;	Version 2, 3-Jan-2006
;-
;
	ON_ERROR,2
;
	TVSELECT, DISABLE=DISABLE
        IF TAG_EXIST(!IMAGE,'BOTTOM') THEN $
          GET_IM_KEYWORD, BOTTOM, !IMAGE.BOTTOM
	IF N_PARAMS(0) EQ 0 THEN LOADCT, BOTTOM=BOTTOM, _EXTRA=_EXTRA ELSE $
          LOADCT, TABLE_NUMBER, BOTTOM=BOTTOM, _EXTRA=_EXTRA
	TVUNSELECT, DISABLE=DISABLE
;
	RETURN
	END
