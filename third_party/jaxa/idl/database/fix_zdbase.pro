;+
; Project     :	SOHO - CDS     
;
; Name        :	FIX_ZDBASE()
;
; Purpose     :	To control the value of env. var. ZDBASE.
;
; Explanation :	The environment variable ZDBASE controls access to the
;		databases.  The user may have access to either a private
;		set of data bases or the 'official' CDS set.  This function
;		allows the uset to set the ZDBASE variable to be the
;		equivalent of either ZDBASE_CDS or ZDBASE_USER depending
;		on the database access required.  These latter two variables
;		must be defined before this routine is called.  The original
;		definition of ZDBASE is stored in common and can be restored to
;		that variable by use of the /ORIGINAL keyword.
;
; Use         :	IDL> status = fix_zdbase(/user, errmsg=errmsg)
;
;		first time used so record the current value of ZDBASE and set
;		its current value to be that of ZDBASE_USER
;
;		IDL> status = fix_zdbase(/cds, errmsg=errmsg)
;
;		if not the first time used then just set current ZDBASE
;		definition to that of ZDBASE_CDS
;
;		IDL> status = fix_zdbase(/orig, errmsg=errmsg)
;
;		all finished, so restore ZDBASE to its original value.
;
;		Note that this routine is more likely to be used within other
;		procedures rather than at a user level as in the above
;		example.
;
;		IDL> status = fix_zdbase(/resolve, errmsg=errmsg)
;
;		Resolve the current definition of ZDBASE, to expand any plus
;		signs in the path.  This speeds up software using the ZDBASE
;		environment variable.  If this is the first time that
;		FIX_ZDBASE() is called, then the expanded version will be
;		stored as the original.
;    
; Inputs      :	None (see keywords).
;
; Opt. Inputs :	None
;
; Outputs     :	Function returns 1 for success, 0 for error.
;		(Values in common may change, and see ERRMSG keyword)
;
; Opt. Outputs:	None
;
; Keywords    :	The following keywords are used to select the appropriate
;		database.
;
;		USER      -   switch ZDBASE to value of ZDBASE_USER
;		CDS       -   switch ZDBASE to value of ZDBASE_CDS
;		SOHO	  -   switch ZDBASE to value of ZDBASE_SOHO
;		EIS	  -   switch ZDBASE to value of ZDBASE_EIS
;		ORIGINAL  -   restore original value of ZDBASE
;		RESOLVE   -   optimize the current value of ZDBASE
;
;		Additional keywords.
;
;		ERRMSG    -   if defined on entry any error messages
;			      will be returned in it.
;               INIT      -  initialise common block
;
; Calls       :	get_environ
;		setenv
;
; Common      :	zdbase_def
;
; Restrictions:	Uses common block variable to signal whether original value
;		of ZDBASE has been saved or not.  Be careful of the common
;		block's memory.
;
; Side effects:	Environment variable ZDBASE is changed.
;
; Category    :	Util, database
;
; Prev. Hist. :	None
;
; Written     :	C D Pike, RAL, 17-Jan-95
;
; Modified    :	Improve error handling.  CDP, 6-Mar-95
;		Allow '+' format option in env var specification. CDP,15-May-95
;		Version 4, William Thompson, GSFC, 16 May 1995
;			Added keyword /PLUS_REQUIRED to FIND_ALL_DIR call.
;			Allows more than one tree in input.
;			Added variable ZDB_USED to common block
;		Version 4.1, SVHH, UiO, 22-Sep-1995
;			Altered EXECUTE command in order to avoid 
;			problem with commands longer than 256 characters.
;		Version 5, William Thompson, GSFC, 15 January 1996
;			Added SOHO keyword.  Simplified structure.
;		Version 6, William Thompson, GSFC, 6 August 1996
;			Call DEF_DIRLIST instead of SETENV
;		Version 7, William Thompson, GSFC, 7 August 1996
;			Call get_environ instead of getenv.
;		Version 8, Dominic Zarro, 15 June 2001
;			Added INIT keyword to initialize common
;		Version 9, William Thompson, GSFC, 14-Jan-2001
;			Added keyword RESOLVE
;               Version 10, William Thompson, GSFC, 16-Sep-2005
;                       Added keyword EIS
;                       Allow /USER, /CDS, /SOHO, and /EIS keywords to be
;                       combined.  Databases are searched in that
;                       order.
;                       Modified 20-Nov-2008, Zarro (ADNET)
;                        - made $ZDBASE and ZDBASE to point to same
;                          definition for cross-compatibility between
;                          Unix and Windows.
;-            
;
function fix_zdbase, user=user, cds=cds, soho=soho, eis=eis, $
                     original=original, errmsg=errmsg, initialize=initialize, $
                     resolve=resolve
;
;  common to store original value of ZDBASE.  Also, the variable ZDB_USED
;  contains as a text string the database used.
;
common zdbase_def, zdb_initialised, orig_zdbase, zdb_used
;
;  Initialize MESSAGE and RESULT.  These will be updated later.
;
result = 1
message = ''
if keyword_set(initialize) then $
 delvarx,zdb_initialised, orig_zdbase, zdb_used
;
;  Check that at least one keyword is set.
;
N_KEYWORDS = KEYWORD_SET(CDS) + KEYWORD_SET(USER) + KEYWORD_SET(SOHO) +	$
  KEYWORD_SET(ORIGINAL) + KEYWORD_SET(RESOLVE) + KEYWORD_SET(EIS)
IF N_KEYWORDS EQ 0 THEN BEGIN
    MESSAGE = 'Use: At least one of /user,/cds,/soho,/eis,/original,' +$
	    '/resolve keywords must be set.'
    GOTO, HANDLE_ERROR
ENDIF
;
;  If the RESOLVE keyword was passed, then expand out the path before storing
;  the original definition.
;
if keyword_set(resolve) then begin
   u = get_environ('ZDBASE',/path)
   if strpos(u,'+') ge 0 then begin
      u = find_all_dir(u,/path,/plus_required)
      command = "def_dirlist,'ZDBASE',u"
      status = execute(command)
      if not status then begin
         message = 'Unable to set variable ZDBASE to user value.'
	 GOTO, HANDLE_ERROR
      endif
   endif
   goto, finish
endif
;
;  First use (original value undefined or set to zero)?  
;  If so record value of ZDBASE
;
if not keyword_set(zdb_initialised) then begin
   orig_zdbase = get_environ('ZDBASE',/path)
   if orig_zdbase eq '' then begin
	message = 'Warning: no original definition of ZDBASE.'
	if n_elements(errmsg) eq 0 then begin
		message, message, /informational
		message = ''
	endif
   endif else begin
	zdb_used = 'Original'
	zdb_initialised = 1
   endelse
endif 
;
;  Return to original definition, first check initialised flag is defined
;  and not set to zero
;
if keyword_set(original) then begin
   command = "def_dirlist,'ZDBASE',orig_zdbase"
   status = execute(command)
   if not status then begin
      message = 'Unable to reset ZDBASE to original value.'
      GOTO, HANDLE_ERROR
   endif else begin
      zdb_used = 'Original'
      zdb_initialised = 0
      orig_zdbase = ''
      GOTO, FINISH
   endelse
endif
;
;  The remaining keywords can be used in conjunction with each other.
;
zdbase = ''
zdbase_used = ''
if !version.os eq 'vms' then sep = ',' else sep = ':'
;
;  USER option (allow multiple directories if '+' format used)
;
if keyword_set(user) then begin
   u = get_environ('ZDBASE_USER',/path)
   if u ne '' then begin
      u = find_all_dir(u,/path,/plus_required)
      if zdbase eq '' then zdbase = u else zdbase = zdbase + sep + u
      command = "def_dirlist,'ZDBASE',zdbase"
      status = execute(command)
      if not status then begin
         message = 'Unable to set variable ZDBASE to user value.'
	 GOTO, HANDLE_ERROR
      endif else begin
         if zdbase_used eq '' then zdbase_used = 'User' else $
           zdbase_used = zdbase_used + ',' + 'User'
      endelse
   endif else begin
      message = 'Variable ZDBASE_USER is not defined.'
      if n_keywords gt 1 then print, message else GOTO, HANDLE_ERROR
   endelse    
endif

;
;  CDS option (gather all subdirectories if '+' format used
;
if keyword_set(cds) then begin
   u = get_environ('ZDBASE_CDS',/path)
   if u ne '' then begin
      u = find_all_dir(u,/path,/plus_required)
      if zdbase eq '' then zdbase = u else zdbase = zdbase + sep + u
      command = "def_dirlist,'ZDBASE',zdbase"
      status = execute(command)
      if not status then begin
         message = 'Unable to set variable ZDBASE to cds value.'
	 GOTO, HANDLE_ERROR
      endif else begin
         if zdbase_used eq '' then zdbase_used = 'CDS' else $
           zdbase_used = zdbase_used + ',' + 'CDS'
      endelse   
   endif else begin
      message = 'Variable ZDBASE_CDS is not defined.'
      if n_keywords gt 1 then print, message else GOTO, HANDLE_ERROR
   endelse    
endif


;
;  SOHO option (gather all subdirectories if '+' format used.
;
if keyword_set(soho) then begin
   u = get_environ('ZDBASE_SOHO',/path)
   if u ne '' then begin
      u = find_all_dir(u,/path,/plus_required)
      if zdbase eq '' then zdbase = u else zdbase = zdbase + sep + u
      command = "def_dirlist,'ZDBASE',zdbase"
      status = execute(command)
      if not status then begin
         message = 'Unable to set variable ZDBASE to soho value.'
	 GOTO, HANDLE_ERROR
      endif else begin
         if zdbase_used eq '' then zdbase_used = 'SOHO' else $
           zdbase_used = zdbase_used + ',' + 'SOHO'
      endelse   
   endif else begin
      message = 'Variable ZDBASE_SOHO is not defined.'
      if n_keywords gt 1 then print, message else GOTO, HANDLE_ERROR
   endelse    
endif


;
;  EIS option (gather all subdirectories if '+' format used.
;
if keyword_set(eis) then begin
   u = get_environ('ZDBASE_EIS',/path)
   if u ne '' then begin
      u = find_all_dir(u,/path,/plus_required)
      if zdbase eq '' then zdbase = u else zdbase = zdbase + sep + u
      command = "def_dirlist,'ZDBASE',zdbase"
      status = execute(command)
      if not status then begin
         message = 'Unable to set variable ZDBASE to eis value.'
	 GOTO, HANDLE_ERROR
      endif else begin
         if zdbase_used eq '' then zdbase_used = 'EIS' else $
           zdbase_used = zdbase_used + ',' + 'EIS'
      endelse   
   endif else begin
      message = 'Variable ZDBASE_EIS is not defined.'
      if n_keywords gt 1 then print, message else GOTO, HANDLE_ERROR
   endelse    
endif


;
;  If ZDBASE is still undefined, then signal an error.
;
if zdbase eq '' then goto, handle_error
message = ''
GOTO, FINISH
;
;  Error handling point.
;
HANDLE_ERROR:
	RESULT = 0
;
;  Exit point.
;
FINISH:
	IF MESSAGE NE '' THEN BEGIN
		IF N_ELEMENTS(ERRMSG) GT 0 THEN ERRMSG = 'FIX_ZDBASE: ' + $
			MESSAGE ELSE MESSAGE, MESSAGE, /CONTINUE
	ENDIF
;
        MKLOG,'$ZDBASE','ZDBASE'
	RETURN, RESULT
	END

