	FUNCTION AVG_WO_CR, ARRAY, DIMENSION, MISSING=MISSING, MINSIG=MINSIG, $
                                              NO_AVERAGE=NO_AVERAGE
;+
; Project     :	SOHO - CDS
;
; Name        :	AVG_WO_CR()
;
; Purpose     :	Average together multiple images, ignoring cosmic rays
;
; Category    :	Class3, Analysis
;
; Explanation :	Averages an array over one of it's dimensions.  The average is
;		done such that any pixels which are more than 3 sigma above the
;		rest of the pixels making up that average are not counted in
;		the average.
;
; Syntax      :	Result = AVG_WO_CR(ARRAY, DIMENSION, MISSING=MISSING)
;
; Examples    :	Suppose that A represented a series of three exposures at the
;		same location, and had the dimensions (100,100,3).  Also
;		suppose that values of -1 represent missing pixels.  Then the
;		command
;
;			B = AVG_WO_CR(A,3,MISSING=-1)
;
;		would return an array of (100,100), representing the average of
;		the three exposures.  Any pixels in B where there was a cosmic
;		ray hit in one of the exposures in A, would only be an average
;		of the other two exposures in A.
;
; Inputs      :	ARRAY	  = Array to be averaged.
;		DIMENSION = Dimension to average over.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the average array.  It has one
;		fewer dimension than the input array.
;
; Opt. Outputs:	None.
;
; Keywords    :	MISSING	= Value representing missing pixels.  If not passed, or
;			  set with the SETFLAG routine, then the routine
;			  assigns it's own value, to use for filtering out
;			  pixels containing cosmic ray hits.
;
;		MINSIG	= Minimum value to use when estimating the standard
;			  deviation in the pixels.
;
;               NO_AVERAGE = Don't perform the final average, ie return
;                            original 3-D array with cosmic ray affected 
;                            pixels set to the MISSING value.
;
; Calls       :	AVERAGE, SIG_ARRAY, GET_IM_KEYWORD
;
; Common      :	None.
;
; Restrictions:	A critical assumption is made here that the data being averaged
;		over are essentially the same thing.  The routine can only
;		recognize cosmic rays which are significantly larger than the
;		variation between exposures.
;
; Side effects:	Computationally intensive.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 26-Mar-1996, William Thompson, GSFC
;		Version 2, 11-Apr-1996, William Thompson, GSFC
;			Corrected problems when DIMENSION not last in array.
;			Added keyword MINSIG
;		Version 3, 02-Aug-1996, William Thompson, GSFC
;			Pay attention to MISSING value set with SETFLAG.
;
;               Version 4, 08-Aug-96, CDP, Include NO_AVERAGE keyword
;
; Contact     :	WTHOMPSON
;-
;
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 2 THEN MESSAGE, $
		'Syntax:  Result = AVG_WO_CR(ARRAY, DIMENSION)

;
;  If the MISSING keyword wasn't set, then use the smallest value in the array,
;  minus 1.
;
	GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
	IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MIN(ARRAY) - 1
;
;  Get the number of elements in the requested dimension, and the number of
;  elements in all the dimensions both before and after.
;
	SZ = SIZE(ARRAY)
	IF DIMENSION GT SZ(0) THEN MESSAGE,	$
		'ARRAY doesn''t have ' + TRIM(DIMENSION) + ' dimensions'
	ND = SZ(DIMENSION)
	IF DIMENSION GT 1 THEN NB = PRODUCT(SZ(1:DIMENSION-1)) ELSE NB = 1
	IF DIMENSION LT SZ(0) THEN NA = PRODUCT(SZ(1+DIMENSION:SZ(0))) ELSE $
		NA = 1
;
;  Create a temporary working array.
;
	NB = LONG(NB)
	NA = LONG(NA)
	TEMP = REFORM(ARRAY,NB,ND,NA)
;
;  Step through all the subarrays that will be averaged together.
;
	FOR ID = 0, ND-1 DO BEGIN
;
;  Extract the subarray, and all the other observations.
;
		SUB = REFORM(TEMP(*,ID,*),NB,NA)
		REST = 0*TEMP(*,1:*,*) - 1000
		IF ID GT 0 THEN REST(0,0,0) = TEMP(*,0:ID-1,*)
		IF ID LT (ND-1) THEN REST(0,ID,0) = TEMP(*,ID+1:*,*)
;
;  Reject any pixels that are more than 3 sigma above the average from the
;  other observations.
;
		AV = AVERAGE(    REST, 2, MISSING=MISSING )
		SIG = SIG_ARRAY( REST, 2, MISSING=MISSING )
		IF N_ELEMENTS(MINSIG) EQ 1 THEN SIG = SIG > MINSIG
		W = WHERE((SUB GT (AV+3*SIG)) AND (AV NE MISSING) AND	$
			(SIG NE 0), COUNT)
		IF COUNT GT 0 THEN BEGIN
			I = W MOD NB
			J = W / NB
			TEMP(I+NB*ID+J*NB*ND) = MISSING
		ENDIF
	ENDFOR
;
;  Average the data together, if required.
;
	TEMP = REFORM(TEMP, SZ(1:SZ(0)))
        IF NOT KEYWORD_SET(NO_AVERAGE) THEN BEGIN
           RETURN, AVERAGE(TEMP, DIMENSION, MISSING=MISSING)
        ENDIF ELSE BEGIN
           RETURN, TEMP
        ENDELSE
	END
