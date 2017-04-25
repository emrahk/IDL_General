FUNCTION vis_fwdfit_fixedconfig, visxyobs, error, srcstr, srcparm_mask, mapcenter, MAXITER=maxiter, $
			REDCHISQ=redchisq, NITER=niter, NFREE=nfree, _EXTRA = _extra
;+
; Internal routine used by vis_fwdfit that to fit the parameters of a fixed source configuration, specified by
;	an array of 1 or more source structures.
; Returns a source structure array with the fitted values.
; REDCHISQ, NITER, and NFREE return reduced chi^2, number of iterations, and number of degrees of freedom, respectively.
;
;  6-Nov-05		First version, adapted from code previously internalized in hsi_fwd_fit
; 11-Nov-05 gh	Adapt FOV for double source.
; 20-Nov-05 gh	Add MAXITER keyword.
;  9-Dec-05		Minor changes.
; 12-Dec-05 gh	Replace LABEL keyword with SHOWIT
; 15-Dec-05 gh	Replace SHOWIT keyword with REDCHISQ and NITER keywords
; 18-jAN-06 gh  Plot fitted amplitudes in color to make them more visible.
;               Restart AMOEBA_C fit if iterations max out.
;               Minor correction to calculation of reduced chisq.
; 19-Jun-2008, Kim.  Added nfree to keyword params
; 26-Aug-09 ejs Enabled inheritance with _EXTRA in called module hsi_vis_fwdfit_parmrange.
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
;-
; Potentially-adjustable parameters
fov     		= 180.     							; field of view
IF N_ELEMENTS(srcstr) EQ 2 THEN fov = 	SQRT((srcstr[0].srcx-srcstr[1].srcx)^2 + (srcstr[0].srcy-srcstr[1].srcy)^2)
DEFAULT, maxiter, 1000      						; Maximum acceptable number of iterations
DEFAULT, absolute, 0
machineparms 	= MACHAR()							; Floating point accuracy of machind
accuracy 		= SQRT(machineparms.eps)			; per recommendation in Numerical Recipes
;
; Convert source structure to a source parameter array, specify basic step size and value limits, and
;    masking out step sizes for parameters that are to be fixed
srcparm 	= vis_fwdfit_structure2array(srcstr, mapcenter)
vis_fwdfit_parmrange, srcstr, fov, prange, basicstepsize,_EXTRA=_extra 		; calculate prange & basicstepsize
stepsize	= basicstepsize * srcparm_mask

;
; Do the actual fit
npt 		= N_ELEMENTS(visxyobs)
jdum 		= FINDGEN(npt)	                         ; dummy 'x' values used in fitting routine
AMOEBA_C, jdum, visxyobs, 'vis_fwdfit_func', srcparm, ERROR=error, MAX_ITER=maxiter, N_ITER=niter, $
            PRANGE=prange, LAMBDA=stepsize, ABSOLUTE=absolute, CHISQ=chisq, ACCURACY=accuracy, /NOPRINT
;
; Redo the fit if number of iterations has maxed out.
IF niter EQ maxiter THEN BEGIN $
    AMOEBA_C, jdum, visxyobs, 'vis_fwdfit_func', srcparm, ERROR=error, MAX_ITER=maxiter, N_ITER=niter, $
            PRANGE=prange, LAMBDA=stepsize, ABSOLUTE=absolute, CHISQ=chisq, ACCURACY=accuracy, /NOPRINT
    niter = maxiter+niter
ENDIF

;
; Convert source parameters back to an array of source structures.
srcout      = vis_fwdfit_array2structure(srcparm, mapcenter)
;
print, srcout

; Optionally, print progress report before returning
dummy       = WHERE(stepsize NE 0, nparm)       ; nparm = number of parameters fit
nfree 		= npt - nparm         ; nfree = number of degrees of freedom
redchisq	= chisq/nfree
IF KEYWORD_SET(showit) EQ 0 THEN RETURN, srcout
IF niter EQ maxiter THEN converge = '   Did not converge in' ELSE converge = '   Converged after    '
PRINT, 'Reduced chi2=', redchisq, converge, niter, ' iterations
RETURN, srcout				; Return output structure with fitted values.
END
