	PRO LOCK_DATABASE, DATABASE, LOCKFILE
;+
; Project     :	SOHO - CDS
;
; Name        :	LOCK_DATABASE
;
; Purpose     :	Lock a CDS database for write.
;
; Category    :	Class4, Operations, Database
;
; Explanation :	Locks a catalog database for write access.  If another process
;		has the catalog locked, then wait until it is unlocked before
;		locking it.
;
;		An empty file called <database>.LOCK (e.g. experiment.LOCK) is
;		created in the same directory as the database.  This signals to
;		other processes that the database is locked.
;
; Syntax      :	LOCK_DATABASE, DATABASE, LOCKFILE
;
; Examples    :	LOCK_DATABASE, 'experiment', LOCKFILE
;		... write to database, e.g. using DBBUILD ...
;		UNLOCK_DATABASE, LOCKFILE
;
; Inputs      :	DATABASE = The name of the database.  The program looks for a
;			   file with the given name, and the extension .dbf in
;			   either the current directory, or the path given by
;			   the environment variable ZDBASE.
;
; Opt. Inputs :	None.
;
; Outputs     :	LOCKFILE = The complete name of the file <database>.LOCK,
;			   including the path.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	FIND_WITH_DEF, BREAK_FILE, FILE_EXIST, CDS_MESSAGE
;
; Common      :	None.
;
; Restrictions:	Must have write access in the directory containing the database
;		files.
;
; Side effects:	There is no timeout to this procedure.  It will wait forever
;		for the database to be unlocked.  If a process dies leaving the
;		lock file in place, then it must be deleted by hand.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 09-Apr-1996, William Thompson, GSFC
;		Version 2, 12-Apr-1996, William Thompson, GSFC
;			Improved status message
;               Version 3, 19 Mar 2003, Zarro (EER/GSFC) - replaced
;               CDS_MESSAGE by MESSAGE
;
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
;
;  Check the input parameters.
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  LOCK_DATABASE, DATABASE, LOCKFILE'
;
;  See if the lock file exists.  If it does, then wait until it's unlocked.
;  Every 30 seconds, print out a message.
;
	WAITED = 0L
	TEMPNAME = FIND_WITH_DEF(DATABASE+'.dbf','$ZDBASE')
	BREAK_FILE, TEMPNAME, DISK, DIR, LOCKNAME, EXT
	LOCKFILE = DISK + DIR + LOCKNAME + '.LOCK'
	WHILE FILE_EXIST(LOCKFILE) DO BEGIN
		IF (WAITED MOD 10) EQ 0 THEN MESSAGE, /CONTINUE,	$
			'Waiting for database ' + DATABASE +	$
			' to be unlocked ...'
		WAIT, 1
		WAITED = WAITED + 1
	ENDWHILE
;
;  Lock the database.
;
	OPENW, UNIT, LOCKFILE, /GET_LUN
	PRINTF, UNIT, ''
	FREE_LUN, UNIT
;
	RETURN
	END
