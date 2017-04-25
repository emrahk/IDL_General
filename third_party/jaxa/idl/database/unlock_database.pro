	PRO UNLOCK_DATABASE, LOCKFILE
;+
; Project     :	SOHO - CDS
;
; Name        :	UNLOCK_DATABASE
;
; Purpose     :	Unlock a previously locked database.
;
; Category    :	Class4, Operations, Database
;
; Explanation :	Unlocks a previously locked catalog database by deleting the
;		lock file.
;
; Syntax      :	UNLOCK_DATABASE, LOCKFILE
;
; Examples    :	UNLOCK_DATABASE, 'experiment', LOCKFILE
;		... write to database, e.g. using DBBUILD ...
;		UNUNLOCK_DATABASE, LOCKFILE
;
; Inputs      :	LOCKFILE = The complete name of the lock file created by
;			   LOCK_DATABASE, including the path.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	FIND_WITH_DEF, BREAK_FILE, FILE_EXIST, CDS_MESSAGE
;
; Common      :	None.
;
; Restrictions:	Must have write access in the directory containing the
;		experiment catalog.
;
; Side effects:	There is no timeout to this procedure.  It will wait forever
;		for the database to be unlocked.  If a process dies leaving the
;		lock file in place, then it must be deleted by hand.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 09-Apr-1996, William Thompson, GSFC
;               Version 2, 19 Mar 2003, Zarro (EER/GSFC) - replaced
;               DELETE_FILE by improved FILE_DELETE
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
;
;  Check the input parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  UNLOCK_DATABASE, LOCKFILE'
;
;  Unlock the database by deleting the lock file.
;
        FILE_DELETE,LOCKFILE, /QUIET
;
	RETURN
	END
