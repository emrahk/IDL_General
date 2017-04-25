	PRO FORM_HISTO, ARRAY, STEPS, HISTO, DELTA=DELTA, MISSING=MISSING, $
                        ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	FORM_HISTO
;
; Purpose     :	Forms a histogram from the variable ARRAY.
;
; Category    :	Class4, Graphics
;
; Explanation :	Forms a histogram from the variable ARRAY.  Decides what the
;		coarseness of the histogram should be.  Called from PLOT_HISTO.
;
;		ARRAY is scaled into a temporary variable to run from zero and
;		some reasonable number, depending on the number of elements of
;		ARRAY.  This number is the coarseness of the histogram,
;		i.e. the number of histogram bins.  The more elements in ARRAY,
;		the larger this number will be.  However, it will not exceed
;		100.  The HISTOGRAM function is then used on this temporary
;		variable.
;
;		If the optional parameter DELTA is passed, then FORM_HISTO uses
;		this value to determine the spacing of the histogram bins,
;		rather than calculating it's own bin spacing as described
;		above.
;
; Syntax      :	FORM_HISTO, ARRAY, STEPS, HISTO
;
; Examples    :	See PLOT_HISTO
;
; Inputs      :	ARRAY	= Array to form histogram from.
;
; Opt. Inputs :	None.
;
; Outputs     :	STEPS	= Values at which histogram is taken.  Each value
;			  represents histogram between STEP(I) and STEP(I+1).
;		HISTO	= Histogram values.
;
; Opt. Outputs:	None.
;
; Keywords    :	DELTA	= Distance between histogram steps.  If not passed,
;			  then the routine chooses a suitable value.
;
;               MISSING = Value flagging missing pixels.  Missing pixels can
;                         also be flagged as Not-A-Number.
;
;               ERRMSG  = If defined and passed, then any error messages will
;                         be returned to the user in this parameter rather than
;                         depending on the MESSAGE routine in IDL.  If no
;                         errors are encountered, then a null string is
;                         returned.  In order to use this feature, ERRMSG must
;                         be defined first, e.g.
;
;                               ERRMSG = ''
;                               FORM_HISTO, ERRMSG=ERRMSG, ...
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	WHERE_NOT_MISSING
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	
;	William Thompson	Applied Research Corporation
;	September, 1987		8201 Corporate Drive
;				Landover, MD  20785
;
;	William Thompson, May 1992, made DELTA a keyword parameter.
;	William Thompson, 25 May 1993, changed to call HISTOGRAM with a long
;		array to make compatible with OpenVMS/ALPHA
;
; History     :	Version 1, 22-Jan-1996, William Thompson, GSFC.
;			Incorporated into CDS library.
;		Version 2, 11-Oct-2002, William Thompson, GSFC
;			Corrected bug when the number of steps is large.
;               Version 3, 19-Jun-2006, William Thompson, GSFC
;                       Added keywords MISSING, ERRMSG.  Call to WHERE_NOT_MISSING.
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
        CONTINUE = 0
;
;  Check the number of parameters.
;
	IF N_PARAMS(0) NE 3 THEN BEGIN
            MESSAGE = 'Syntax:  FORM_HISTO, ARRAY, STEPS, HISTO'
            GOTO, HANDLE_ERROR
        ENDIF
;
;  Filter out any missing pixels.
;
        W = WHERE_NOT_MISSING(ARRAY, MISSING=MISSING, COUNT)
        IF COUNT LE 2 THEN BEGIN
            MESSAGE = 'Not enough points to form histogram'
            GOTO, HANDLE_ERROR
        ENDIF
        ATEMP = ARRAY[W]
;
;  Get the maximum and minimum values of ARRAY.
;
	A_MAX = 1.*MAX(ATEMP, MIN=A_MIN)
	A_MIN = 1.*A_MIN
	IF A_MAX EQ A_MIN THEN BEGIN
            MESSAGE = 'No histogram generated--all elements equal to ' +      $
	        TRIM(A_MAX)
            CONTINUE = 1
	    GOTO, HANDLE_ERROR
	END ELSE IF (A_MAX - A_MIN) LT (1E-4 * ABS(A_MIN)) THEN BEGIN
	    MESSAGE = 'No histogram generated--range ' + TRIM(A_MIN) +	      $
	        ' to ' + TRIM(A_MAX) + ' too narrow'
            CONTINUE = 1
            GOTO, HANDLE_ERROR
	ENDIF
;
;  If passed, then check the value of DELTA.
;
	IF N_ELEMENTS(DELTA) NE 0 THEN BEGIN
	    IF N_ELEMENTS(DELTA) NE 1 THEN BEGIN
		MESSAGE = 'DELTA must be scalar'
                GOTO, HANDLE_ERROR
	    END ELSE IF DELTA LE 0 THEN BEGIN
	        MESSAGE = 'DELTA must be positive'
                GOTO, HANDLE_ERROR
	    ENDIF
;
;  If DELTA was not passed, then determine the approximate number of histogram
;  levels from the number of elements of ARRAY. 
;
	END ELSE BEGIN
	    N = FLOAT(N_ELEMENTS(W))
	    N = N < 100. < (7.*ALOG10(N) + N/8.)
;
;  Use N to determine the spacing of the histogram levels.  Break this number 
;  down into mantissa and exponent.
;
	    DELTA = (A_MAX - A_MIN) / (N - 1)
	    POWER = FIX(ALOG10(DELTA))
	    IF POWER GT ALOG10(DELTA) THEN POWER = POWER - 1
	    DELTA = DELTA / 10.^POWER
;
;  Ensure that the spacing of the histogram levels is either 1,2 or 5 times 
;  some power of ten.
;
	    VAL = [10,5,2]
	    VALUE = 1
	    FOR I = 0,2 DO IF VAL(I) GT DELTA THEN VALUE = VAL(I)
	    DELTA = VALUE * 10.^POWER
;
;  If ARRAY is of some integer type (byte, integer or long), then ensure that 
;  DELTA is at least one.
;
	    TYPE = SIZE(ARRAY)
	    TYPE = TYPE(TYPE(0) + 1)
	    IF ((TYPE EQ 1) OR (TYPE EQ 2) OR (TYPE EQ 3)) THEN	$
		    DELTA = DELTA > 1
	ENDELSE
;
;  Find the nearest multiple of DELTA which is LE the minimum of ARRAY.
;
	I_MIN = LONG(A_MIN / DELTA)
	IF I_MIN*DELTA GT A_MIN THEN I_MIN = I_MIN - 1
	A_MIN = I_MIN * DELTA
;
;  Form the histogram, and the variable STEPS, and return.
;
	HISTO = HISTOGRAM(LONG((ATEMP - A_MIN) / DELTA))
	STEPS = FINDGEN(N_ELEMENTS(HISTO))*DELTA + A_MIN
	RETURN
;
;  Error handling point.
;
HANDLE_ERROR:
        IF N_ELEMENTS(ERRMSG) EQ 0 THEN $
          MESSAGE, MESSAGE, CONTINUE=CONTINUE ELSE $
          ERRMSG = 'FORM_HISTO: ' + MESSAGE
        RETURN
	END
