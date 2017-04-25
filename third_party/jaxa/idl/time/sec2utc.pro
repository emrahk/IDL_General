;+
; Project     : SOHO - CDS     
;                   
; Name        : SEC2UTC()
;               
; Purpose     : Converts seconds since MJD=0 to CDS UTC time format.
;               
; Explanation : Used in the UTPLOT programs, this function converts elapsed
;               seconds since the zero time of MJD to CDS internal UTC format.
;               It takes no account of leap seconds.  For more information on
;		various time formats, see file aaareadme.txt.
;               
; Use         : IDL>  str = sec2utc(tsec)
;    
; Inputs      : tsec  -  variable with number of elapsed seconds
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns structure with .mjd and .time tags.
;               
; Opt. Outputs: None
;               
; Keywords    : ERRMSG  =  If defined and passed, then any error messages 
;                          will be returned to the user in this parameter 
;                          rather than being handled by the IDL MESSAGE 
;                          utility.  If no errors are encountered, then a null 
;                          string is returned.  In order to use this feature, 
;                          the string ERRMSG must be defined first, e.g.,
;
;                            ERRMSG = ''
;                            UTC = SEC2UTC( TSEC, ERRMSG=ERRMSG )
;                            IF ERRMSG NE '' THEN ...
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: No account of leap seconds.
;               
; Side effects: If an error is encountered and the ERRMSG keyword is set, 
;		SEC2UTC returns a structure of value {mjd:0L,time:0L}.
;               
; Category    : Util, time
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 20-Apr-94
;               
; Modified    :	Version 1, C.D. Pike, RAL, 20 April 1994
;		Version 2, Donald G. Luttermoser, GSFC/ARC, 28 December 1994
;                       Added the keyword ERRMSG.  Added IDL ON_ERROR utility.
;			Note that there are no internally called procedures
;			that use the ERRMSG keyword.
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Made error handling procedure more robust.  Note that
;			this routine can handle both vectors and scalars as
;			input.
;               Version 4, CDP, 5-Dec-95 Made output structure of type
;                                        CDS_INT_TIME
;
; Version     :	Version 4, 05-Dec-95
;-            

function sec2utc, sec, errmsg=errmsg

;
;  Set up error parameters.
;
on_error, 2  ; Return to the caller of this procedure if error occurs.
message=''   ; Error message that is returned if ERRMSG keyword set.

;
;  Check the input parameter.
;
if n_params() ne 1 then message = 'Syntax:  Result = SEC2UTC ( TSEC )'
if message ne '' then goto, handle_error
;
;  calculate integer MJD and millisec qualifier
;
mjd = long(sec/86400.0d0)
msec = sec - (double(mjd)*86400.d0)
msec = long(msec*1000.)

;
; set up standard CDS internal time structure
;
zz = {CDS_INT_TIME,mjd:0L,time:0L}
ss = replicate(zz,n_elements(sec))

;
;  load converted input
;
ss.mjd = mjd
ss.time = msec

if n_elements(errmsg) ne 0 then errmsg = message
return,ss

handle_error:
if n_elements(errmsg) eq 0 then message, message
errmsg = message
return, {mjd:0L,time:0L}
;
end
