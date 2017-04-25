PRO SSW_WRITE_GIF, FILENAME, IMG, R, G, B
;+
; NAME:
;	SSW_WRITE_GIF
;
; PURPOSE:
;	Write an IDL image and color table vectors to a
;	GIF (graphics interchange format) file.
;
;       For IDL 5.3 and earlier, this routine simply calls WRITE_GIF.  For
;       later versions of IDL, WRITE_PPM is called, and ppmtogif is spawned
;       (Unix only).
;
; CATEGORY:
;
; CALLING SEQUENCE:
;
;	SSW_WRITE_GIF, File, Image  ;Write a given array.
;
;	SSW_WRITE_GIF, File, Image, R, G, B  ;Write array with color tables.
;
;
; INPUTS:
;	Image:	The 2D array to be output.
;
; OPTIONAL INPUT PARAMETERS:
;      R, G, B:	The Red, Green, and Blue color vectors to be written
;		with Image.
; Keyword Inputs:
;       None.  The WRITE_GIF keywords are not supported.
;
; OUTPUTS:
;	If R, G, B values are not provided, the last color table
;	established using LOADCT is saved. The table is padded to
;	256 entries. If LOADCT has never been called, we call it with
;	the gray scale entry.
;
;
; COMMON BLOCKS:
;	COLORS
;
; SIDE EFFECTS:
;	If R, G, and B aren't supplied and LOADCT hasn't been called yet,
;	this routine uses LOADCT to load the B/W tables.
;
; RESTRICTIONS:
;	This routine only writes 8-bit deep GIF files of the standard
;	type: (non-interlaced, global colormap, 1 image, no local colormap)
;
;       For IDL versions 5.4 and above, the ppmtogif program must be installed,
;       and in the user's path.  This program is part of the Netpbm package,
;       available at http://netpbm.sourceforge.net/
;
;	The Graphics Interchange Format(c) is the Copyright property
;	of CompuServ Incorporated.  GIF(sm) is a Service Mark property of
;	CompuServ Incorporated.
;
; MODIFICATION HISTORY:
;	Version 1, 8-Aug-2003, William Thompson
;       Version 2, 13-Aug-2003, William Thompson
;               Call ALLOW_GIF
;-
;
ON_ERROR, 2
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
;
;  Check the input parameters.
;
N_PARAMS = N_PARAMS();
IF ((N_PARAMS EQ 5) AND (N_ELEMENTS(R) EQ 0)) THEN N_PARAMS = 2
IF ((N_PARAMS NE 2) AND (N_PARAMS NE 5))THEN $
        MESSAGE, "usage: SSW_WRITE_GIF, file, image, [r, g, b]'
IMG_SIZE = SIZE(IMG)
IF IMG_SIZE[0] NE 2 OR IMG_SIZE[IMG_SIZE[0]+1] NE 1 THEN	$
	MESSAGE, 'Image must be a byte matrix.'
;
;  For older versions of IDL, simply call WRITE_GIF.
;
IF ALLOW_GIF() THEN BEGIN
    CASE N_PARAMS OF
        2: WRITE_GIF, FILENAME, IMG
        5: WRITE_GIF, FILENAME, IMG, R, G, B
    ENDCASE
    RETURN
ENDIF
;
;  Otherwise, use ppmtogif, but only under Unix.
;
IF !VERSION.OS_FAMILY NE 'unix' THEN MESSAGE,   $
        'WRITE_GIF emulation only supported under Unix'
PPMTOGIF_COMMAND = SSW_BIN('ppmtogif',FOUND=FOUND)
IF PPMTOGIF_COMMAND EQ '' THEN MESSAGE,         $
        'The ppmtogif program was not found'
;
;  If the color tables were not passed, then populate it from the
;  common block.
;
IF (N_PARAMS EQ 2) THEN BEGIN
    IF (N_ELEMENTS(R_CURR) EQ 0) THEN LOADCT, 0	; LOAD B/W TABLES
    R	= R_CURR
    G	= G_CURR
    B	= B_CURR
ENDIF
;
;  Check the color table vectors.
;
R_SIZE = SIZE(R)
G_SIZE = SIZE(G)
B_SIZE = SIZE(B)
IF ((R_SIZE[0] + G_SIZE[0] + B_SIZE[0]) NE 3) THEN $
        MESSAGE, "R, G, & B must all be 1D vectors."
IF ((R_SIZE[1] NE G_SIZE[1]) OR (R_SIZE[1] NE B_SIZE[1]) ) THEN $
	MESSAGE, "R, G, & B must all have the same length."
;
;  Form a 3-color image, based on the color tables.
;
TEMP = BYTARR(3,IMG_SIZE[1],IMG_SIZE[2])
TEMP[0,*,*] = REVERSE(R[IMG],2)
TEMP[1,*,*] = REVERSE(G[IMG],2)
TEMP[2,*,*] = REVERSE(B[IMG],2)
;
;  Write a temporary PPM file, spawn a process to convert this to GIF, and
;  delete the temporary file.
;
WRITE_PPM, 'TEMPORARY.ppm', TEMP
SPAWN, PPMTOGIF_COMMAND + ' < TEMPORARY.ppm >! ' + FILENAME
FILE_DELETE, 'TEMPORARY.ppm'
;
END
