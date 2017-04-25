;+
; Project     : STEREO - SSC
;                   
; Name        : ANYTIM2CDF()
;               
; Purpose     : Convert CDS time values to CDF epoch values
;               
; Explanation : This procedure calls ANYTIM2UTC and CDF_EPOCH to convert CDS
;               time values to the "CDF_EPOCH" datatype used within Common Data
;               Format files.
;
; Use         : EPOCH = ANYTIM2CDF(DATE)
;    
; Inputs      : DATE = Array of epoch values from a CDF file.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns the dates converted into CDF_EPOCH format.
;               The CDF documentation describes this as the number of
;               milliseconds since 1-Jan-0000.  (Experiment shows that this
;               value omits leap seconds.)
;               
; Opt. Outputs: None
;               
; Keywords    : ERRMSG	 = If defined and passed, then any error messages 
;			   will be returned to the user in this parameter 
;			   rather than being handled by the IDL MESSAGE 
;			   utility.  If no errors are encountered, then a null 
;			   string is returned.  In order to use this feature, 
;			   the string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				RESULT = ANYTIM2CDF( DATE, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
;               Also accepts any keywords for ANYTIM2UTC
;
; Calls       : GET_UTC, ANYTIM2UTC
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: If an error condition is encountered, and the ERRMSG keyword is
;               used, then the single value -1 is returned.
;
;               Leap seconds, e.g. "2005-12-31T23:59:60", are treated as the
;               same as the first second of the next day.  The previous
;               behavior was to treat them as a repeat of 23:59:59.
;               
; Category    : CDF, Time
;               
; Prev. Hist. : None
;
; History     :	Version 1, 11-Jan-2006, William Thompson, GSFC
;               Version 2, 17-Feb-2006, William Thompson, GSFC
;                       Speed up by using CDF_EPOCH only for a single date, and
;                       then using UTC2TAI with /NOCORRECT for more
;                       processing.  Note that this changes the behavior of
;                       leap seconds.
;
; Contact     :	WTHOMPSON
;-            
;
function anytim2cdf, date, errmsg=errmsg, _extra=_extra
on_error, 2
;
;  Check the input parameter.
;
if n_params() eq 0 then begin
    message = 'Syntax: EPOCH = ANYTIM2CDF(DATE)'
    goto, handle_error
endif
n_times = n_elements(date)
sz = size(date)
;
;  Convert to CDS internal format.
;
message = ''
utc = anytim2utc(date, errmsg=message)
if message ne '' then goto, handle_error
;
;  Convert into the number of non-leap milliseconds since 1-Jan-1958.  Use
;  CDF_EPOCH to convert to the right origin.
;
cdf_epoch, epoch0, 1958, 1, 1, 0, 0, 0, 0, /compute_epoch
return, epoch0  +  1000.d0 * utc2tai(utc,/nocorrect)
;
;  Error handling point.
;
handle_error:
    if n_elements(errmsg) eq 0 then message, message else $
      errmsg = 'ANYTIM2CDF: ' +message
    return, -1
;
end
