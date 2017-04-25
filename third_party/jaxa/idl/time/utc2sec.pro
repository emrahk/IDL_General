;+
; Project     : SOHO - CDS     
;                   
; Name        : UTC2SEC()
;               
; Purpose     : Converts CDS UTC time format to seconds since MJD=0.
;               
; Explanation : Used in the UTPLOT programs, this function converts CDS 
;               internal UTC format to seconds since MJD=0.
;               It takes no account of leap seconds.
;		For notes on various time formats, see file aaareadme.txt.
;               
; Use         : IDL>  sec = utc2sec(str)
;    
; Inputs      : str  - structure variable containing UTC time format
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns seconds elapsed since MJD=0.
;               
; Opt. Outputs: None
;               
; Keywords    : ERRMSG       =	If defined and passed, then any error messages 
;				will be returned to the user in this parameter 
;				rather than being handled by the IDL MESSAGE 
;				utility.  If no errors are encountered, then a 
;				null string is returned.  In order to use this 
;				feature, the string ERRMSG must be defined 
;				first, e.g.,
;
;					ERRMSG = ''
;					RESULT = UTC2SEC( STR, ERRMSG=ERRMSG )
;					IF ERRMSG NE '' THEN ...
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: No account is taken of leap seconds.
;               
; Side effects: If an error is encountered and the ERRMSG keyword is set, 
;		UTC2SEC returns an integer scalar equal to -1.
;               
; Category    : Util, time
;               
; Prev. Hist. : None
;
; Written     :	C D Pike, RAL, 20-Apr-94
;               
; Modified    :	Version 1, C D Pike, RAL, 20-Apr-94
;		Version 2, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 3 January 1995
;			Added the keyword ERRMSG.  Added ON_ERROR,2 flag.
;			Allow for input of EXTERNAL format of UTC.
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made the error handling routine more robust.  Note 
;			that this routine can handle both scalars and vectors
;			as input.
;               Version 5, 25-Oct-2005, William Thompson, GSFC
;                       Handle structures through UTC2INT - interprets any
;                       structure with MJD and TIME as CDS internal time
;
; Version     :	Version 5, 25-Oct-2005
;-            

function utc2sec, utc, errmsg=errmsg

on_error, 2  ; Return to the caller of this procedure if error occurs.
message=''   ; Error message that is returned if ERRMSG keyword set.
;
;  validate input
;
if n_params() ne 1 then begin
	message = 'Syntax:  Result = UTC2SEC( UTC )'
endif else begin
	if datatype(utc,1) ne 'Structure' then $
		message = $
		 'UTC2SEC:  Input data must be internal CDS time structure.' $
	else utcin = utc2int(utc,errmsg=message)
endelse
if message ne '' then goto, handle_error

if n_elements(errmsg) ne 0 then errmsg = message
return, utcin.mjd*86400.d0 + (utcin.time/1000.d0)

;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message
errmsg = message
return, -1
;
end
