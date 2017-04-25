;+
; Project     : SOHO - CDS
;
; Name        : 
;	LINECOLOR
; Purpose     : 
;	Set a color index to a particular color.
; Explanation : 
;	Set one particular element in each of the red, green and blue color
;	tables to some standard values for line plotting.
; Use         : 
;	LINECOLOR, I_COLOR, S_COLOR
;       LINECOLOR, I_COLOR, VALUES=[Red, Green, Blue]
; Inputs      : 
;	I_COLOR = Color table element to be used for line plotting.  Must be in
;		  the range [0,!D.NCOLORS-1].  If SET is set, then the system
;		  variable !P.COLOR is set to I_COLOR.
;	S_COLOR = String variable denoting the color.  May be upper or lower
;		  case.  Acceptable values are 'RED', 'GREEN', 'BLUE',
;		  'YELLOW', 'ORANGE', 'PURPLE', 'MAGENTA', 'BROWN',
;		  'TURQUOISE', 'BLACK' and 'WHITE'.
;	DISABLE	= If set, then TVSELECT not used.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	SET	= If set, then !P.COLOR is changed by this procedure.
;       DARKEN  = A relative value from 0.0 to 1.0 by which to darken the color
;       WHITEN  = A relative value from 0.0 to 1.0 by which to whiten the color
;       VALUES  = A three-element array containing the red, green, and blue
;                 color values from 0-255.
; Calls       : 
;	TRIM, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	The variable S_COLOR must be of type string.
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
;	If SET is set, then the variable !P.COLOR is set to I_COLOR.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson	Applied Research Corporation
;	July, 1986		8201 Corporate Drive
;				Landover, MD  20785
;
;	William Thompson, April 1992, changed to use TVLCT,/GET instead of
;				      common block, and added DISABLE keyword.
; Written     : 
;	William Thompson, GSFC, July 1986.
; Modified    : 
;	Version 1, William Thompson, GSFC, 13 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;	Version 3, William Thompson, GSFC, 18 December 2002
;		Changed !COLOR to !P.COLOR
;       Version 4, 12-Nov-2008, WTT, added keywords DARKEN, WHITEN, VALUES
; Version     : 
;	Version 4, 12-Nov-2008
;-
;
PRO LINECOLOR, I_COLOR, S_COLOR, SET=SET, DISABLE=DISABLE, $
               DARKEN=DARKEN, WHITEN=WHITEN, VALUES=VALUES
;
ON_ERROR,2
;
IF (N_ELEMENTS(VALUES) EQ 3) THEN BEGIN
    NMIN = 1
    IF N_ELEMENTS(S_COLOR) EQ 0 THEN S_COLOR = ''
END ELSE NMIN = 2
;
IF N_PARAMS(0) LT NMIN THEN BEGIN
    PRINT,'*** LINECOLOR must be called with 2 parameters:'
    PRINT,'               I_COLOR , S_COLOR'
    RETURN
ENDIF
;
TVSELECT,DISABLE=DISABLE
MAXCOLOR = !D.TABLE_SIZE - 1
IF ((I_COLOR LT 0) OR (I_COLOR GT MAXCOLOR)) THEN BEGIN
    PRINT,'*** I_COLOR must be between 0 and ' +	$
      TRIM(MAXCOLOR) + ', procedure LINECOLOR.'
    TVUNSELECT,DISABLE=DISABLE
    RETURN
ENDIF
;
TVLCT,RED,GREEN,BLUE,/GET
;
CASE STRUPCASE(S_COLOR) OF
    'RED':  BEGIN
        RED[I_COLOR]   = 255
        GREEN[I_COLOR] = 0
        BLUE[I_COLOR]  = 0
    END
    'GREEN':  BEGIN
        RED[I_COLOR]   = 0
        GREEN[I_COLOR] = 255
        BLUE[I_COLOR]  = 0
    END
    'BLUE':  BEGIN
        RED[I_COLOR]   = 0
        GREEN[I_COLOR] = 0
        BLUE[I_COLOR]  = 255
    END
    'YELLOW':  BEGIN
        RED[I_COLOR]   = 255
        GREEN[I_COLOR] = 255
        BLUE[I_COLOR]  = 0
    END
    'ORANGE':  BEGIN
        RED[I_COLOR]   = 255
        GREEN[I_COLOR] = 127
        BLUE[I_COLOR]  = 0
    END
    'PURPLE':  BEGIN
        RED[I_COLOR]   = 255
        GREEN[I_COLOR] = 0
        BLUE[I_COLOR]  = 255
    END
    'MAGENTA':  BEGIN
        RED[I_COLOR]   = 255
        GREEN[I_COLOR] = 100
        BLUE[I_COLOR]  = 150
    END
    'BROWN':  BEGIN
        RED[I_COLOR]   = 200
        GREEN[I_COLOR] = 127
        BLUE[I_COLOR]  = 100
    END
    'TURQUOISE':  BEGIN
        RED[I_COLOR]   = 0
        GREEN[I_COLOR] = 255
        BLUE[I_COLOR]  = 255
    END
    'BLACK':  BEGIN
        RED[I_COLOR]   = 0
        GREEN[I_COLOR] = 0
        BLUE[I_COLOR]  = 0
    END
    'WHITE':  BEGIN
        RED[I_COLOR]   = 255
        GREEN[I_COLOR] = 255
        BLUE[I_COLOR]  = 255
    END
    ELSE:  BEGIN
        IF N_ELEMENTS(VALUES) EQ 3 THEN BEGIN
            RED[I_COLOR]   = VALUES[0]
            GREEN[I_COLOR] = VALUES[1]
            BLUE[I_COLOR]  = VALUES[2]
        END ELSE BEGIN
            PRINT,' Unrecognized color: ',S_COLOR
            PRINT,' Valid colors are: RED, GREEN, BLUE, YELLOW, ORANGE, PURPLE,'
            PRINT,'                   MAGENTA, BROWN, TURQUOISE, BLACK, WHITE'
            TVUNSELECT,DISABLE=DISABLE
            RETURN
        ENDELSE
    END
ENDCASE
;
IF N_ELEMENTS(DARKEN) EQ 1 THEN BEGIN
    RED[I_COLOR]   = BYTE(RED[I_COLOR]   * (1-DARKEN))
    GREEN[I_COLOR] = BYTE(GREEN[I_COLOR] * (1-DARKEN))
    BLUE[I_COLOR]  = BYTE(BLUE[I_COLOR]  * (1-DARKEN))
ENDIF
;
IF N_ELEMENTS(WHITEN) EQ 1 THEN BEGIN
    RED[I_COLOR]   = BYTE(RED[I_COLOR]   * (1-WHITEN) + 256*WHITEN)
    GREEN[I_COLOR] = BYTE(GREEN[I_COLOR] * (1-WHITEN) + 256*WHITEN)
    BLUE[I_COLOR]  = BYTE(BLUE[I_COLOR]  * (1-WHITEN) + 256*WHITEN)
ENDIF
;
IF KEYWORD_SET(SET) THEN !P.COLOR = I_COLOR
TVLCT,RED,GREEN,BLUE
TVUNSELECT,DISABLE=DISABLE
;
RETURN
END
