	PRO UITDBLIB
;+
; Project     :	SOHO - CDS
;
; Name        :	UITDBLIB
;
; Purpose     :	Add the system variables used by the UIT database library
;
; Explanation :	This routine adds the non-standard system variables used by the
;		UIT database routines from the IDL Astronomy User's Library.
;
;		The non-standard system variables !PRIV, !DEBUG, !TEXTUNIT, and
;		!TEXTOUT are added using DEFSYSV.
;
; Use         :	UITDBLIB
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	This routine should be called only once, preferably in the
;		startup procedure.
;
; Side effects:	System variables may be changed to their default values.
;
; Category    :	Utilities, Database
;
; Prev. Hist. :	This routine was adapted from ASTROLIB, which had the following
;		history entries:
;
;		Written, Wayne Landsman, July 1986.
;		Use DEFSYSV instead of ADDSYSVAR           December 1990
;
; Written     :	William Thompson, GSFC, 30 March 1994
;
; Modified    :	Version 1, William Thompson, GSFC, 30 March 1994
;
; Version     :	Version 1, 30 March 1994
;-
;
	ON_ERROR,2   
;
	DEFSYSV, '!DEBUG',	0
	MESSAGE, 'Added system variable !DEBUG',	/INFORMATIONAL
	DEFSYSV, '!PRIV',	0
	MESSAGE, 'Added system variable !PRIV',		/INFORMATIONAL
	DEFSYSV, '!TEXTUNIT',	0
	MESSAGE, 'Added system variable !TEXTUNIT',	/INFORMATIONAL
	DEFSYSV, '!TEXTOUT',	1
	MESSAGE, 'Added system variable !TEXTOUT',	/INFORMATIONAL
;
	RETURN
	END
