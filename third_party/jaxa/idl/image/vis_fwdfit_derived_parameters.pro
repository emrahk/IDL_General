FUNCTION vis_fwdfit_derived_parameters, srcstr, trial_results
;
; Calculates source parameters derived from vis_fwdfit output source structure, and their correponding errors.
; Prints results and returns a structure with derived parameters and their errors.
;
; 15-Jan-06     Initial version just does loop major and minor axes. (ghurford@ssl.berkeley.edu)
; 18-Jan-06 gh  Debug multisource case.
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
dparm       = {srcmajoraxis: 0., $
                srcminoraxis: 0., $
                dblsrcsep: 0., $
                dblsrccg: 0.}
nsrc        = N_ELEMENTS(srcstr)
ntrial      = N_ELEMENTS(trial_results)/nsrc
result      = FLTARR(2, nsrc,ntrial+1)           ; Will hold 2 parameters for each source and trial.
str         = REPLICATE(srcstr[0], nsrc, NTRIAL+1)
str[*,0]    = srcstr
IF ntrial GT 0 THEN str[*,1:*] = trial_results           ; Combined structure holding actual and randomized results will simplify code below
;
; Begin loop over source elements
FOR ns = 0, nsrc-1 DO BEGIN
; Major and minor axes
    IF srcstr[ns].srctype EQ 'loop' THEN BEGIN
        FOR j=0,ntrial DO BEGIN
            dummy = vis_fwdfit_makealoop(str[j], LOOPPARM=loopparm)
            result[*,ns,j] = loopparm                                     ; major axis
        ENDFOR
        looparc = ABS(result[0,0,ns])
        loopwidth = result[1,0,ns]
        IF ntrial GT 0 THEN BEGIN
            siglooparc = STDDEV(ABS(result[0,ns,1:*]))           ; INTERPRETATION OF -VE MAJORAXIS????
            sigloopwidth = STDDEV(result[1,ns,1:*])
            PRINT, ns+1, 'Looparc   =',   looparc,   siglooparc, FORMAT="('Component', I2, A12, F6.2, ' +-', F5.2, ' arcsec FWHM')"
            PRINT, ns+1, 'Loopwidth =', loopwidth, sigloopwidth, FORMAT="('Component', I2, A12, F6.2, ' +-', F5.2, ' arcsec FWHM')"
        ENDIF
    ENDIF
ENDFOR
PRINT
RETURN, dparm
END
