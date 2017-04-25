	FUNCTION CROSS_CORR2,ARRAY1,ARRAY2,NCORR,CORR_X,CORR_Y,		$
		MISSING=MISSING, COUNT=COUNT, REPORT=REPORT
;+
; Project     : SOHO - CDS
;
; Name        : 
;	CROSS_CORR2()
; Purpose     : 
;	Takes two-dimensional cross-correlation of two arrays.
; Explanation : 
;	The cross-correlations are calculated by shifting the second array by
;	-NCORR to +NCORR pixels relative to the first array.  This permutation
;	is performed in both the X and Y directions.
; Use         : 
;	Result = CROSS_CORR2( ARRAY1, ARRAY2, NCORR  [, CORR_X, CORR_Y ] )
; Inputs      : 
;	ARRAY1	= First array to take cross-correlation of.
;	ARRAY2	= Second array.
;	NCORR	= Size of the cross-correlation.  The calculation will range
;		  between +/- NCORR in both directions.  Can also be passed as
;		  a two element array, with different numbers for X and Y.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	CORR_X	= Relative shift in the X direction.
;	CORR_Y	= Relative shift in the Y direction.
; Keywords    : 
;	MISSING	 = Value flagging missing pixels.
;	COUNT	 = If set, then the COUNTDOWN routine is called to show a
;		   running display of where you are in the processing.
;       REPORT   = Report the (x,y) shift determined
;
; Calls       : 
;	AVERAGE, COUNTDOWN, GET_IM_KEYWORD, IS_NOT_MISSING
; Common      : 
;	None.
; Restrictions: 
;	The arrays must be two-dimensional, and must have the same dimensions
;	as the other.
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
;	None.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, March 1991, modified to use BADPIXEL keyword.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
; Written     : 
;	William Thompson, GSFC.
; Modified    : 
;	Version 1, William Thompson, GSFC, 13 May 1993.
;		Incorporated into CDS library.
;       version 2, C D Pike, RAL, Added REPORT keyword.  27-Jul-95
;	Version 3, William Thompson, GSFC, 26-Aug-1996
;		Made more robust in the presence of missing data.
;	Version 4, William Thompson, GSFC, 07-May-1997
;		Allow NCORR to be two values.
;	Version 5, William Thompson, GSFC, 13-Aug-1997
;		Made less sensitive to roundoff error
;       Version 6, 11-May-2005, William Thompson, GSFC
;               Handle NaN values
;
; Version     : 
;	Version 6, 11-May-2005
;-
;
	GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 3 THEN BEGIN
	    PRINT,'*** CROSS_CORR2 must be called with five parameters:'
	    PRINT,'       ARRAY1, ARRAY2, NCORR, CORR_X, CORR_Y'
	    RETURN, 0
	ENDIF
;
;  Check the size of the arrays.
;
	S1 = SIZE(ARRAY1)
	S2 = SIZE(ARRAY2)
	IF ((S1(0) NE 2) OR (S2(0) NE 2)) THEN BEGIN
	    PRINT,'*** Arrays must be two-dimensional, ' +		$
	        'routine CROSS_CORR2.'
	    RETURN, 0
	END ELSE IF ((S1(1) NE S2(1)) OR (S1(2) NE S2(2))) THEN BEGIN
	    PRINT,'*** Arrays must have same dimensions, ' +	$
	        'routine CROSS_CORR2.'
	    RETURN, 0
	ENDIF
;
;  Get the dimensions of the array, initialize CORR, and calculate CORR_X and
;  CORR_Y.
;
	NI = S1(1)
	NJ = S1(2)
	NCORRX = NCORR(0)
	IF N_ELEMENTS(NCORR) EQ 2 THEN NCORRY = NCORR(1) ELSE NCORRY = NCORRX
	CORR = FLTARR(2*NCORRX+1,2*NCORRY+1)
	CORR_X = FINDGEN(2*NCORRX+1) - NCORRX
	CORR_Y = FINDGEN(2*NCORRY+1) - NCORRY
	IF KEYWORD_SET(COUNT) THEN COUNTDOWN,(2*NCORRX+1)*(2*NCORRY+1),/OPEN
;
;  Shift ARRAY2 in X relative to ARRAY1.
;
	FOR I = -NCORRX,NCORRX DO BEGIN
	    IF I LT 0 THEN BEGIN
	        I1A1 = 0   &  I2A1 = NI+I-1
	        I1A2 = -I  &  I2A2 = NI-1
	    END ELSE BEGIN
	        I1A1 = I   &  I2A1 = NI-1
	        I1A2 = 0   &  I2A2 = NI-I-1
	    ENDELSE
;
;  Shift ARRAY2 in Y relative to ARRAY1.
;
	    FOR J = -NCORRY,NCORRY DO BEGIN
	        IF J LT 0 THEN BEGIN
	            J1A1 = 0   &  J2A1 = NJ+J-1
	            J1A2 = -J  &  J2A2 = NJ-1
	        END ELSE BEGIN
	            J1A1 = J   &  J2A1 = NJ-1
	            J1A2 = 0   &  J2A2 = NJ-J-1
	        ENDELSE
;
;  Calculate CORR.
;
	        A1 = 1.*ARRAY1(I1A1:I2A1,J1A1:J2A1)
	        A2 = 1.*ARRAY2(I1A2:I2A2,J1A2:J2A2)
                W = WHERE(IS_NOT_MISSING(A1, MISSING=MISSING) AND $
                          IS_NOT_MISSING(A2, MISSING=MISSING), CNT)
                IF (CNT GT 1) AND (CNT NE N_ELEMENTS(A1)) THEN BEGIN
                    A1 = A1(W)
                    A2 = A2(W)
                END
		IF CNT GT 0 THEN BEGIN
		    AVG_A1 = AVERAGE(A1)
		    AVG_A2 = AVERAGE(A2)
	            CORR(I+NCORRX,J+NCORRY) =			$
			    AVERAGE((A1 - AVG_A1) * (A2 - AVG_A2)) /	$
	            	    SQRT( AVERAGE((A1 - AVG_A1)^2) *	$
			          AVERAGE((A2 - AVG_A2)^2) )
		ENDIF
		IF KEYWORD_SET(COUNT) THEN COUNTDOWN,	$
			(2*NCORRY + 1) * (I + NCORRX) + J + NCORRY + 1
	    ENDFOR
	ENDFOR
	IF KEYWORD_SET(COUNT) THEN COUNTDOWN,/CLOSE
;
;  Report the shift which gives best match
;
        IF KEYWORD_SET(REPORT) THEN BEGIN
	   REP = LOCATE_VAL(CORR,/TOP)
           NX = (SIZE(CORR))(1)
           NY = (SIZE(CORR))(2)
           REP(0,*) = NX/2 - REP(0,*)
           REP(1,*) = NY/2 - REP(1,*)
           PRINT,'Maximum correlation found for shift of '+$
                 'second image relative to first of :'
           FOR I=0,N_ELEMENTS(REP)/2-1 DO BEGIN
              PRINT,FMT_VECT([REP(0,I),REP(1,I)])
           ENDFOR
        ENDIF
;
	RETURN, CORR
	END
