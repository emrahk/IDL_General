;+
;
; NAME:
;  vis_fwdfit_sigmacalc
;
; PURPOSE:
;   Returns 1-sigma statistical error in forward-fitted source parameters calculated from visibilities.
;   Method is to repeatedly randomize vector of input visibilities with known statistical errors, and note scatter in
;       fitted parameters
;
; CALLING SEQUENCE:
; fitsigmas = vis_fwdfit, visxyobs, error, srcstr, srcparm_mask, mapcenter, $
;                [, DIAGNOSTIC=diagnostic] [, QFLAG=qflag] [, TRIAL_RESULTS=trial_results]
;
; CALLS:
;   vis_fwdfit_print
;   vis_fwdfit_fixedconfig
;
; INPUTS:
;   visxyobs      = vector of real, then imaginary components of observed visibilities
;   error         = corresponding vector of 1-sigma statistical errors
;   srcstr        = array of source structures (in vis_fwdfit format) specifying the fit results
;   srcparm_mask  = parameter mask used in fit.
;   mapcenter     = xyoffset from sun center of map center
;
; OPTIONAL INPUTS:
;   none
;
; OUTPUTS:
;   Results are returned as an array of source structures corresponding to srcstr.
;
; OPTIONAL OUTPUTS:
;   see keywords
;
; KEYWORDS:
;   qflag = named variable to receive quality flag
;       qflag       = 0 ==> No problems...
;       qflag bit 0 = 1 ==> flux / sigmaflux < 3
;       qflag bit 1 = 1 ==> a fitted parameter is near edge of range
;       qflag bit 2 = 1 ==> at least one outlier in a fitted trial parameters
;       qflag bit 3 = 1 ==> uncertainty is so large as to make at least one parameter meaningless.
;   trial_results   = nsrc x ntry array of source structures found by randomizing the input data
;
; COMMON BLOCKS:
;   none
; SIDE EFFECTS:
;   none
;
; RESTRICTIONS:
;
; MODIFICATION HISTORY:
;
; 14-Nov-05     Initial version just calculates randomized parameters (ghurford@ssl.berkeley.edu)
; 20-Nov-05 gh  Returns structure of standard deviations.
;  9-Dec-05 gh  Adapt to revised source structure format
;          Add provision for loop_angle errors.
; 13-Dec-05 gh  Add /DIAGNOSTIC keyword to display results of multiple tries
; 14-Dec-05 gh  Revise method of calculating standard deviations (See Numerical Recipes, 14.4)
; 15-Dec-05 gh  Add QFLAG keyword to return quality warnings.
; 19-Dec-05 gh  Minor bug fix.
; 14-Jan-06 gh  Add TRIAL_RESULTS keyword to support calculation of errors in derived parameters.
; 18-Jan-06 gh  Add provision for albedo.
; 27-Oct-08 gh  Correct units bug in calculation of avsrcpa which affected calculation of error in srcpa
;               Added standard header documentation.
; 8-Aug-09 ejs Implemented inheritance with _EXTRA in called programs.
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
;-
;
FUNCTION vis_fwdfit_sigmacalc, visxyobs, error, srcstr, srcparm_mask, mapcenter, DIAGNOSTIC=diagnostic, QFLAG=qflag, TRIAL_RESULTS=trial_results,_EXTRA = _extra
;
; Initialize some parameters and then calculate multiple trials
DEFAULT, diagnostic, 0
ntry                    = 20                          ; Number of randomization attempts
nvis                    = N_ELEMENTS(visxyobs)
nsrc                    = N_ELEMENTS(srcstr)
trial_results           = REPLICATE(srcstr[0], nsrc, ntry)                 ; nsrc x ntry array of fitted parameters
FOR n = 0, ntry-1 DO BEGIN
    testerror           = RANDOMN(iseed, nvis)          ; nvis element vector normally distributed with sigma = 1
    visxytest           = visxyobs + testerror * error
    result              = vis_fwdfit_fixedconfig(visxytest, error, srcstr, srcparm_mask, mapcenter, _EXTRA = _extra)
    IF KEYWORD_SET(diagnostic) THEN vis_fwdfit_print, result, /COMPACT ; Optional display of individual trial results
    trial_results[*,n]  = result
ENDFOR
;
; Convert multiple fit results to standard deviation from the original run.
fitsigmas        = srcstr          ; define the output structure
fitsigmas.srctype   = 'std.dev'
FOR n=0, nsrc-1 DO BEGIN
    fitsigmas[n].srcflux        = STDDEV( trial_results[n,*].srcflux)
    fitsigmas[n].srcx           = STDDEV( trial_results[n,*].srcx)
    fitsigmas[n].srcy           = STDDEV( trial_results[n,*].srcy)
    fitsigmas[n].srcfwhm        = STDDEV( trial_results[n,*].srcfwhm)
    fitsigmas[n].eccen          = STDDEV( trial_results[n,*].eccen)
    fitsigmas[n].loop_angle     = STDDEV( trial_results[n,*].loop_angle)
    fitsigmas[n].albedo_ratio   = STDDEV( trial_results[n,*].albedo_ratio)          ; If undefined for a srctype, fitsigmas tag will be zero
    fitsigmas[n].srcheight      = STDDEV( trial_results[n,*].srcheight)             ; If undefined for a srctype, fitsigmas tag will be zero
        avsrcpa                 = ATAN(TOTAL(SIN(trial_results[n,*].srcpa*!DTOR)), TOTAL(COS(trial_results[n,*].srcpa*!DTOR))) *!RADEG
    groupedpa                   = ((810 + avsrcpa - trial_results[n,*].srcpa) MOD 180.) - 90. ; groupedpa values are in range [-90,+90] rel. to avsrcpa
    fitsigmas[n].srcpa          = STDDEV(groupedpa)
ENDFOR
;
; Hardwired parameters and limits.
s2nmin              = 3.        ; Minimum expected s/n
max_location_error  = 30.       ; Maximum expected source displacement
min_fwhm            = 1.2       ; Min and max expected source sizes
max_fwhm            = 150       ; [arcsec]
min_eccen           = 0.01
max_eccen           = 0.99
min_loop_angle      = 1.        ; [degrees]
max_loop_angle      = 179.
kurtosis_limit      = -5.
xylimit             = 30.       ; [arcsec]
srcpa_limit         = 30.
min_albedo_ratio    = 0.01
max_albedo_ratio    = 1.00
min_srcheight       = 1.0
max_srcheight       = 30.
;
; Calculate a quality flag
qflag               = 0
FOR n=0, nsrc-1 DO BEGIN
    IF srcstr[n].srctype EQ 'albedo' THEN BEGIN
        IF srcstr[n].albedo_ratio GT max_albedo_ratio OR srcstr[n].albedo_ratio LT min_albedo_ratio THEN qflag = qflag OR 2
        IF srcstr[n].srcheight GT max_srcheight OR srcstr[n].srcheight LT min_srcheight THEN qflag = qflag OR 2
        CONTINUE
    ENDIF
    IF srcstr[n].srcflux LT s2nmin * fitsigmas[n].srcflux THEN qflag = qflag OR 1
    IF (ABS(srcstr[n].srcx-mapcenter[0]) > ABS(srcstr[n].srcy-mapcenter[1])) GT max_location_error THEN qflag = qflag OR 2
    IF srcstr[n].srcfwhm LT min_fwhm OR srcstr[n].srcfwhm GT max_fwhm THEN qflag = qflag OR 2
    IF srcstr[n].srctype NE 'circle' THEN $
       IF srcstr[n].eccen LE min_eccen OR srcstr[n].eccen GT max_eccen THEN qflag = qflag OR 2
    IF srcstr[n].srctype EQ 'loop' THEN $
       IF ABS(srcstr[n].loop_angle) LT min_loop_angle OR ABS(srcstr[n].loop_angle) GT max_loop_angle THEN $
                                           qflag = qflag OR 2
    IF KURTOSIS(trial_results[n,*].srcflux)             LT kurtosis_limit THEN qflag = qflag OR 4
    IF KURTOSIS(trial_results[n,*].srcx)                LT kurtosis_limit THEN qflag = qflag OR 4
    IF KURTOSIS(trial_results[n,*].srcy)                LT kurtosis_limit THEN qflag = qflag OR 4
    IF KURTOSIS(trial_results[n,*].srcfwhm)             LT kurtosis_limit THEN qflag = qflag OR 4
    ; IF KURTOSIS(trial_results[n,*].albedo_ratio)             LT kurtosis_limit THEN qflag = qflag OR 4
    ; IF KURTOSIS(trial_results[n,*].srcheight)             LT kurtosis_limit THEN qflag = qflag OR 4
    IF srcstr[n].srctype NE 'circle' THEN BEGIN
        IF KURTOSIS(trial_results[n,*].eccen)           LT kurtosis_limit THEN qflag = qflag OR 4
        IF KURTOSIS(trial_results[n,*].srcpa)           LT kurtosis_limit THEN qflag = qflag OR 4
        IF srcstr[n].srctype EQ 'loop' THEN $
        IF KURTOSIS(trial_results[n,*].loop_angle)   LT kurtosis_limit THEN qflag = qflag OR 4
    ENDIF
    IF fitsigmas[n].srcx  GT xylimit                                THEN qflag = qflag OR 8
    IF fitsigmas[n].srcy  GT xylimit                                THEN qflag = qflag OR 8
    IF fitsigmas[n].srcfwhm GT srcstr[n].srcfwhm                    THEN qflag = qflag OR 8
    IF fitsigmas[n].srcpa GT srcpa_limit                            THEN qflag = qflag OR 8
ENDFOR
RETURN, fitsigmas
END
