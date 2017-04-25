;+
; NAME:
;	WIN2PS
;
; PURPOSE:
;	This routine reads the current window and colortable and saves it to 
;	a postscript file in the current directory named win2ps.ps.
;
; CATEGORY:
;	Utilities.  Output.
;
; CALLING SEQUENCE:
;
;	WIN2PS
;
; INPUTS:
;	None.
;
; OUTPUTS:
;	None.
;
; SIDE EFFECTS:
;	Creates a file in the current directory (or /tmp if no write permission) 
;	named win2ps.ps.
;
; MODIFICATION HISTORY:
; 	Written by:	S.E. Paswaters October, 1996
;
; 	Modified:	96/12/12  SEP  Scaled image to 256 colors for postscript
; 			00/10/18  RAH  Added option to not rescale image, default was to rescale
;
; SCCS variables for IDL use
; 
; %W% %H% :NRL Solar Physics
;
;-

PRO WIN2PS, outname, rescale=rescale

    ;** get the current window size
    Nx = !D.X_SIZE
    Ny = !D.Y_SIZE

    ;** read the current window
    image = TVRD(0, 0, Nx, Ny, 0)
 
    IF (DATATYPE(outname) EQ 'UND') THEN out_filePS = 'win2ps.ps' ELSE out_filePS = STRTRIM(outname,2)

    IF (CHECK_PERMISSION(out_filePS) NE 1) THEN BEGIN
      BREAK_FILE, out_filePS, a, dir, name, ext
      out_filePS = '/tmp/'+name+ext
    ENDIF

    TVLCT, r, g, b, /GET
    SET_PLOT,'PS', /INTERPOLATE
    DEVICE, /COLOR, FILENAME=out_filePS

    ;** set up postscript scaling & orientation
    IF (Nx GT Ny) THEN BEGIN
        xs = 9.5 & ys = (xs*Ny/Nx)
        IF (ys GT 7.5) THEN sf = 7.5/ys ELSE sf = 1.0
        DEVICE, /INCHES, XSIZE = xs, YSIZE = ys, SCALE_FACTOR=sf, $
            /LANDSCAPE,  BITS_PER_PIXEL=8, FILENAME = out_filePS
    ENDIF $ 
    ELSE BEGIN
        xs = 7.7 & ys = (xs*Ny/Nx)
        IF (ys GT 10.0) THEN sf = 10.0/ys ELSE sf = 1.0
        DEVICE, /INCHES, XSIZE = xs, YSIZE = ys, SCALE_FACTOR=sf, $
            /PORTRAIT,  BITS_PER_PIXEL=8, FILENAME = out_filePS, $
            XOFFSET = .75, YOFFSET = 1.50
    ENDELSE
    
   
    IF NOT KEYWORD_SET (RESCALE)  THEN image = BYTSCL(image, 0, MAX(image), TOP=255)
    TV, image, 0, 0

    DEVICE, /CLOSE
    SET_PLOT,'X'
    TVLCT, r, g, b
    PRINT, '%WIN2PS: Saved window to postscript file: ', out_filePS
    
END
