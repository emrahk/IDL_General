;+
; Project     : STEREO - SSC
;                   
; Name        : CDF2TAI()
;               
; Purpose     : Convert CDF epoch values to CDS TAI time values
;               
; Explanation : This procedure calls CDF_EPOCH to break down CDF epoch
;               variables into year, month, day, etc., and then converts this
;               into a CDS TAI time value using UTC2TAI.
;
; Use         : TAI = CDF2TAI(EPOCH)
;    
; Inputs      : EPOCH = Array of values with the CDF_EPOCH datatype from a CDF
;                       file. The CDF documentation describes this as the
;                       number of milliseconds since 1-Jan-0000.  (Experiment
;                       shows that this value omits leap seconds.)
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns CDS TAI time variable.
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
;				RESULT = CDF2TAI( EPOCH, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
;               Also accepts any keywords for UTC2TAI
;
; Calls       : GET_UTC, UTC2TAI
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: If an error condition is encountered, and the ERRMSG keyword is
;               used, then the single value -1 is returned.
;               
; Category    : CDF, Time
;               
; Prev. Hist. : None
;
; History     :	Version 1, 11-Jan-2006, William Thompson, GSFC
;               Version 2, 16-Feb-2006, William Thompson, GSFC
;                       Speed up by using CDF_EPOCH only for a single date, and
;                       then using TAI2UTC with /NOCORRECT for more processing.
;
; Contact     :	WTHOMPSON
;-            
;
function cdf2tai, epoch, errmsg=errmsg, nocorrect=nocorrect, _extra=_extra
on_error, 2
;
;  Check the input parameter.
;
if n_params() eq 0 then begin
    message = 'Syntax: TAI = CDF2TAI(EPOCH)'
    goto, handle_error
endif
n_times = n_elements(epoch)
if n_times eq 0 then begin
    message = 'EPOCH undefined'
    goto, handle_error
endif
sz = size(epoch)
if sz[sz[0]+1] ne 5 then begin
    message = 'EPOCH must be double precision'
    goto, handle_error
endif
;
;  Convert into seconds since 1-Jan-1958, and use TAI2UTC with /NOCORRECT to
;  convert into the proper format, followed by UTC2TAI.
;
cdf_epoch, epoch0, 1958, 1, 1, 0, 0, 0, 0, /compute_epoch
time = (epoch - epoch0) / 1000.d0
if keyword_set(nocorrect) then return, time else $
  return, utc2tai(tai2utc(time, /nocorrect), _extra=_extra)
;
;  Error handling point.
;
handle_error:
    if n_elements(errmsg) eq 0 then message, message else $
      errmsg = 'CDF2TAI: ' + message
    return, -1
;
end
