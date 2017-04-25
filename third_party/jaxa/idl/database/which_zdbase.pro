	FUNCTION WHICH_ZDBASE
;+
; Project     :	SOHO - CDS
;
; Name        :	WHICH_ZDBASE()
;
; Purpose     :	Returns which database is selected
;
; Explanation :	Returns which database was selected by the FIX_ZDBASE routine.
;
; Use         :	Result = WHICH_ZDBASE
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is one the four possible strings:
;
;			'User'	   = FIX_ZDBASE was last called with /USER
;			'CDS'	   = FIX_ZDBASE was last called with /CDS
;			'Original' = FIX_ZDBASE was last called with /ORIGINAL,
;				     or else FIX_ZDBASE has not yet been
;				     called.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	ZDBASE_DEF from FIX_ZDBASE()
;
; Restrictions:	Only meaningful if only FIX_ZDBASE is used to switch between
;		databases.
;
; Side effects:	None.
;
; Category    :	CDS, Planning, Databases
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 16 May 1995
;
; Modified    :	Version 1, William Thompson, GSFC, 16 May 1995
;		Version 2, William Thompson, GSFC, 17 May 1995
;			Modified so that there are only three possibilities.
;		Version 3, William Thompson, GSFC, 15 January 1996
;			Modified to use string values of ZDB_USED instead of
;			numerical ones.
;
; Version     :	Version 3, 15 January 1996
;-
;
	ON_ERROR, 2
;
;  Common block from FIX_ZDBASE.
;
	COMMON ZDBASE_DEF, ZDB_INITIALISED, ORIG_ZDBASE, ZDB_USED
;
;  Interpret the parameter ZDB_USED
;
	IF N_ELEMENTS(ZDB_USED) NE 1 THEN RESULT = 'Original' ELSE	$
		RESULT = ZDB_USED
;
	RETURN, RESULT
	END
