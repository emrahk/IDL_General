;+
; NAME:
;   vis_fwdfit
;
; PURPOSE:
;   forward fit imaging algorithm based on visibilities
;
; CALLING SEQUENCE:
;   vis_fwdfit, visin0 [, NOPHASE=nophase]     [, CIRCLE=circle]    [, MAXITER = maxiter] [, ABSOLUTE=absolute]   $
;                      [, NOERR=noerr]         [, SRCIN = srcstrin] [, SRCOUT=srcstrout]  [, MULTI=multi]         $
;                      [, FITSTDDEV=fitstddev] [, LOOP=loop]        [, SHOWMAP=showmap]   [, NOPLOTFIT=noplotfit] $
;                      [, QFLAG=qflag]         [, ALBEDO=albedo]    [, SYSERR=syserr]     [, NOEDIT=noedit] $
;                      [, _EXTRA=extra]
;
; CALLS:
;   vis_fwdfit_fixedconfig          [to optimize parameters for a given source configuration]
;   vis_fwdfit_func                 [to calculate model visibilities for a given set of source parameters]
;   vis_fwdfit_plotfit              [to generate plotted display of fit]
;   vis_fwdfit_print                [Generates printed display of source structure]
;   vis_structure2array             [Converts source structure to an array for amoeba_c]
;   vis_src_structure__define       [Defines source structure format]
;
; INPUTS:
;   visin0 = an array of visibiltiy structures, each of which is a single visibility measurement.
;               visin0 is not modified by hsi_vis_fwdfit
;
; OPTIONAL INPUTS:
;	See keywords.
;
; OUTPUTS:
;   Prints fit parameters in log window.
;
; OPTIONAL OUTPUTS:
;   See keywords.
;
; KEYWORDS:
;   /CIRCLE = fits visibilities to a single, circular gaussian.  (Default is an elliptical gaussian)
;   /LOOP   = Fits visibilities to a single curved elliptical gaussian.
;   /MULTI  = fits visibilities to a pair of circular gaussians.
;   /ALBEDO = adds a combined albedo source to the other fitted components. (Not yet fully reliable.)
;   SRCIN   = specifies an array of source structures, (one for each source component) to use as a starting point.
;
;   /NOERR forces fit to ignore input statistical errors. (Default is to use statistical errors.)
;   SYSERR is an estimate of the systematic errors, expressed as a fraction of the amplitude. Default = 0.05
;
;   /NOFIT just creates the uvdat COMMON block but suppresses all other outputs.  No fitting is done.
;   /NOEDIT suppresses the default editing and coonjugate combining of the input visibilities.
;   /NOPHASE forces all input phases to zero.
;   /ABSOLUTE generates fit by minimizing the sum of ABS(input visibility - model visibility). Default = 0
;   MAXITER sets maximum number of iterations per stage (default = 2000)
;
;   SRCOUT names a source structure array to receive the fitted source parameters.
;   FITSTDDEV returns sigma in fitted quantities in SRCOUT.
;   QFLAG returns a quality flag whose bits indicate the type of problem found.  qflag=0 ==> fit appears ok.
;   REDCHISQ names a variable to receive the reduced chi^2 of fit.
;   NITER returns number of iterations done in fit.
;   /NOPLOTFIT suppresses plotfit display.    Default is to generate this display.
;   /SHOWMAP generates a PLOTMAN display of final map
;   /PLOTMAN uses the PLOT_MAP routine instead of plotman to display the final map if /SHOWMAP is set.
;   ID = a character string used to label plots.  (Start time is always shown.)
;   FIT_MASK = 10 element array.  0/1 means fix or fit corresponding element in src structure.
;
; _EXTRA keyword causes inheritance of additional keywords
;
; COMMON BLOCKS:
;	uvdata
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;   vis_fwdfit is still under development - should be used with caution and results reviewed critically.
;   Chi^2 output values are indeterminate if either /ABSOLUTE or /NOERR is set.
;   Bad fits are usually flagged with a warning message.
;
; MODIFICATION HISTORY:
; 23-May-05         Initial version (ghurford@ssl.berkeley.edu) assumes one circular gaussian
; 12-Jun-05 gh      First running version.
;                   Added plot of fitted vs observed amplitudes.
;                   Added /NOPHASE keyword
; 11-Jul-05 gh      Continue debugging.  Single source flux and diameter are ok.
;  1-Aug-05 gh      Major rewrite to use new {hsi_vis} visibility structure as input.
;  5-Aug-05 gh      Explicitly set output to 1 plot per page.
;                   Set initial step size to more reasonable values
;                   Suppress detailed printout from AMOEBA_C
;                   Improve plotted output
;                   Seems ok for locating and characterizing a single gaussian
;  6-Aug-05 gh      Improve printed output.
;                   Add support for elliptical gaussians
;                   Add /CIRCLE switch to force circular sources
;  9-Aug-05 gh      Fit circular source, then adapt to elliptical shape.
; 10-Aug-05 gh      Improve default elliptical step size
;                   Improve nomenclature and labels.
; 15-Aug-05 gh      Add MAXITER keyword
; 18-Sep-05 gh      Adapt to simplified visibility format.
; 22-Sep-05 gh      Add ABSOLUTE keyword
;                   Improve choice of parameter limits.
;                   Display reduced CHI^2.
; 27-Sep-05 gh      Add NOERR keyword.  (Default is to use statistical errors.)
; 15-Oct-05 gh      Use a 'Cartesian' representation to define ellipticity parameters.
;                   Fix display bug for PA > 180.
; 06-Nov-05 gh      Break out fitting to a fixed configuration by using module, hsi_vis_fwdfit_fixedconfig
;                   Set fitting accuracy to SQRT(machine tolerance)
;                   Fit elliptical sources in a single step, rather than doing a circular source first
; 07-Nov-05 gh      Add SRCIN keyword
;                   Break out printing display to hsi_vis_fwdfit_print
;                   Generalize code for multiple sources
; 08-Nov-05 gh      Add SRCOUT keyword
; 09-Nov-05 gh      Break out hsi_vis_structure2array
; 10-Nov-05 gh      Add /MULTI keyword
; 13-Nov-05 gh      Add srctype tag to source component structure
;                   Change xyoffset tag in source component structure to be sun center instead of map center
; 20-Nov-05 gh      Pass maxiter on to hsi_vis_fwdfit_fixedconfig
;                   Use average instead of maximum observed amplitude as initial flux guess.
; 21-Nov-05 gh      Add FITSTDDEV keyword
;  9-Dec-05 gh      Adapt to source structure definition as documented 9Dec05
; 12-Dec-05 gh      Add /LOOP keyword
;                   Add /SHOWMAP keyword
; 13-Dec-05 gh      Eliminate displays of interim fit results
;                   Add /NOPLOTFIT keyword to suppress plot display of fit.
;                   Check input visibilities for consistent times, energies and xyoffsets.
; 14-Dec-05 gh      Print time and energy ranges.
; 15-Dec-05 gh      Display fit quality warnings.
;                   Add QFLAG keyword
; 14-Jan-06 gh      Add mapcenter to uvdata common block
; 16-Jan-05 gh      Add ALBEDO keyword.
; 18-Jan-06 gh      Change default maxiter from 2000 to 500, in view of successful 'fresh start' strategy with amoeba_c
; 16-Feb-06 gh      Combine any conjugate input visibilities.
;                   Add SYSERR keyword parameter to incorporate a rough estimate of systematic errors.
;  7-Mar-06 gh      Add /NOEDIT keyword, but default to pre-editing visibility data.
;  8-Mar-06 gh      Correct bug which bypassed time-consistency check.
;           gh/psh  Add time to SHOWMAP call to get correct limb position
; 28-Mar-06 ejs/gh  Reimplement EJS's changes which added REDCHISQ, NOFIT and _EXTRA keywords.
; 24-May-06 ejs     Put keyword NOFIT into argument list
; 19-Jun-2008, Kim  Add redchisq, niter, nfree to keyword arguments. Changed order of keywords to group input/output.
;                   Also, even if noerr is set, assign all 0s to fitstddev structure so it's defined.
;                   Added nfree to calling args for hsi_vis_fwdfit_fixedconfig
; 18-Jan-08 Kim     Added fit_mask keyword to control which params to fit
; 30-Jun-08 Kim     Added fit_mask keyword.  THIS IS TEMPORARY until a more complete solution to fit params is implemented.
; 22-Jan-09 Kim     Construct srcparm_mask for multiple source input
;  4-May-09 Kim     Call with _REF_EXTRA instead of _EXTRA so plot routine can return window ID it created
; 30-Oct-13 A.M.Massone   Removed RHESSI dependencies, STIX visibilities can be used as input 
;-
;
    
PRO vis_fwdfit, visin0, $
    SRCIN = srcstrin, MULTI=multi, CIRCLE=circle, LOOP=loop, ALBEDO=albedo, FIT_MASK=fit_mask, $
    NOPHASE=nophase, MAXITER = maxiter, ABSOLUTE=absolute, SYSERR=syserr, $
    NOEDIT=noedit, NOERR=noerr, NOFIT=nofit, $    
    SHOWMAP=showmap, NOPLOTFIT=noplotfit, $
    SRCOUT=srcstrout, FITSTDDEV=fitstddev, QFLAG=qflag, REDCHISQ=redchisq, NITER=niter, NFREE=nfree, $
    _REF_EXTRA=extra
;
; Preset constants and masks
TWOPI       =  2. * !PI
DEFAULT, noerr,     0
DEFAULT, maxiter,  500
DEFAULT, syserr,    0.05
DEFAULT, noedit,    0
DEFAULT, fit_mask, [1,1,1,1,1, 1,1,1,1,1]

point_mask  = [0,1,1,1,0, 0,0,0,0,0] * fit_mask
circ_mask   = [0,1,1,1,1, 0,0,0,0,0] * fit_mask
ellip_mask  = [0,1,1,1,1, 1,1,0,0,0] * fit_mask
loop_mask   = [0,1,1,1,1, 1,1,1,0,0] * fit_mask
albedo_mask = [0,0,0,0,0, 0,0,0,1,1] * fit_mask
;
; Verify that all visibilities have the same xyoffset, energy and time ranges.
nvisin0 = N_ELEMENTS(visin0)
IF nvisin0 EQ 0 THEN MESSAGE, 'STOPPING: Input visibility structure is empty.'
dummy = WHERE(visin0.xyoffset NE visin0[0].xyoffset, ndiff)
IF ndiff GT 0 THEN MESSAGE,             'STOPPING: INPUT VISIBILITIES HAVE INCONSISTENT XYOFFSETS'
dummy = WHERE(visin0.erange NE visin0[0].erange, ndiff)
IF ndiff GT 0 THEN PRINT,               'CAUTION:  INPUT VISIBILITIES HAVE INCONSISTENT ENERGY RANGES'
dummy = WHERE(visin0.trange NE visin0[0].trange, ndiff)
IF ndiff GT 0 THEN PRINT,               'CAUTION:  INPUT VISIBILITIES HAVE INCONSISTENT TIME RANGES'
;
;
;;;; Verify that all visibilities lie in the v>0 plane (check usefull for RHESSI visibilities)
dummy=where(visin0.v LT 0, count)
if (count ne 0) then message, $
        'In case of RHESSI visibilities: input visibilities should be edited/combined before using vis_fwdfit' $
         else visin=visin0

;;;; Verify if visibilities need to be reformed (check usefull for STIX visibilities)
dummy=size(visin)
if dummy[0] ne 1 then visin=reform(visin)    
   

; Adjust the input visibility errors to include a systematic term.
visamp          = ABS(visin.obsvis)                              ; input amplitudes
visin.sigamp    = SQRT(visin.sigamp^2  + syserr^2 * visamp^2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Process semi-adjustable input parameters and define a common array to pass uv data
IF KEYWORD_SET(circle) NE 0 AND KEYWORD_SET(multi)  NE 0 THEN MESSAGE, '/CIRCLE and /MULTI switches are incompatible.'
IF KEYWORD_SET(loop)   NE 0 AND KEYWORD_SET(multi)  NE 0 THEN MESSAGE,   '/LOOP and /MULTI switches are incompatible.'
IF KEYWORD_SET(loop)   NE 0 AND KEYWORD_SET(circle) NE 0 THEN MESSAGE,  '/LOOP and /CIRCLE switches are incompatible.'
COMMON uvdata, u,v,pa, mapcenter
;
; Extract the visibility components and convert them to a 1-D vector
; By convention, input to fitting algorithm will be a 2*nvis element vector (all real then all imaginary components)
nvis        = N_ELEMENTS(visin)
npt         = 2*nvis
jdum = FINDGEN(npt)                         ; dummy 'x' values used in fitting routine
IF KEYWORD_SET(nophase) EQ 0 THEN BEGIN        ; normal
    visx    = FLOAT(visin.obsvis)
    visy    = IMAGINARY(visin.obsvis)
ENDIF ELSE BEGIN                               ; Set phase to zero if /NOPHASE is set
    visx    = ABS(visin.obsvis)
    visy    = FLTARR(nvis)
ENDELSE
visxyobs    = [visx, visy]                   ; convert to a 2*nvis vector
amp0      = AVERAGE(visamp)                     ; initial flux guess = average amplitude
IF noerr NE 0 THEN error = FLTARR(npt) + 1. ELSE error  = [visin.sigamp, visin.sigamp]   ; default is to use errors

;
; Prepare contents of common block to convey slit position angles for all uv points and define a common block to convey u,v values.
mapcenter   = visin[0].xyoffset                         ; 2-element vector,  the same for all visibilities

;;;;;;;;;;;;;;;;;
u           = visin.u
v           = visin.v

;;;;;;;;;;; pa computed directly here without calling the hsi_vis_select routine
pa          = ((ATAN(visin.v, visin.u) + TWOPI) MOD TWOPI) * !RADEG

;
; IF NOFIT is set, can return now that the common block is defined.
IF KEYWORD_SET(nofit) THEN RETURN
;
; If an initial source structure is not provided, define and initialize such a structure.
;   Initial parameters are a 10" diameter elliptical gaussian with flux=largest amplitude, located at map center.
IF N_ELEMENTS(srcstrin) EQ 0 THEN BEGIN
    IF KEYWORD_SET(circle) NE 0 THEN firsttype = 'circle' ELSE firsttype = 'ellipse'
    srcstr0             = {vis_src_structure}
    srcstr0.srctype     = firsttype
    srcstr0.srcflux     = amp0
    srcstr0.srcx        = mapcenter[0]
    srcstr0.srcy        = mapcenter[1]
    srcstr0.srcfwhm     = 10.
ENDIF ELSE srcstr0      = srcstrin
;
; Set masks for a circular or elliptical source.
PRINT
nsrc                    = N_ELEMENTS(srcstr0)
;IF N_ELEMENTS(srcstr0) GT 1 THEN srcparm_mask = [circ_mask, circ_mask] $
;ELSE BEGIN
;    IF srcstr0.srctype EQ 'circle'  THEN srcparm_mask =  circ_mask
;    IF srcstr0.srctype EQ 'ellipse' THEN srcparm_mask = ellip_mask
;    IF srcstr0.srctype EQ 'loop'    THEN srcparm_mask =  loop_mask
;ENDELSE
;
for i = 0,nsrc-1 do begin
  case srcstr0[i].srctype of
    'circle':  srcparm_mask = append_arr(srcparm_mask, circ_mask)
    'ellipse': srcparm_mask = append_arr(srcparm_mask, ellip_mask)
    'loop':    srcparm_mask = append_arr(srcparm_mask, loop_mask)
  endcase
endfor

; Fit this configuration
srcstr1 = vis_fwdfit_fixedconfig(visxyobs, error, srcstr0, srcparm_mask, mapcenter,  $
              MAXITER=maxiter, REDCHISQ=redchisq, NITER=niter, NFREE=nfree, _EXTRA=extra)
srcstr = srcstr1

;
;
;
;
; If multiple sources are assumed, bifurcate the elliptical source and re-fit
IF KEYWORD_SET(multi) NE 0 AND nsrc EQ 1 THEN   BEGIN srcstr = vis_fwdfit_bifurcate(srcstr1)
    srcparm_mask    = [circ_mask,circ_mask]
    srcstr2         = vis_fwdfit_fixedconfig( visxyobs, error, srcstr, srcparm_mask, mapcenter, $
                            MAXITER=maxiter, REDCHISQ=redchisq, NITER=niter, NFREE=nfree, _EXTRA=extra)
    srcstr          = srcstr2
ENDIF
;
; If loop source was assumed, re-fit an the elliptical gaussian.
IF KEYWORD_SET(loop) NE 0 AND srcstr[0].srctype EQ 'ellipse' THEN   BEGIN
    srcstr.srctype = 'loop'
    srcparm_mask = loop_mask
    srcstr2 = vis_fwdfit_fixedconfig( visxyobs, error, srcstr, srcparm_mask, mapcenter, $
              MAXITER=maxiter, REDCHISQ=redchisq, NITER=niter, NFREE=nfree, _EXTRA=extra)
    srcstr = srcstr2
ENDIF
;
; If albedo option is chosen, add an albedo source component and refit.
IF KEYWORD_SET(albedo) NE 0 THEN BEGIN
    albstr0                 = {hsi_vis_src_structure}
    albstr0.srctype         = 'albedo'
    albstr0.albedo_ratio    = 0.1
    albstr0.srcheight       = 10.
    srcstr                  = [srcstr, albstr0]
    srcparm_mask            = [srcparm_mask, albedo_mask]
    srcstr3                 = vis_fwdfit_fixedconfig( visxyobs, error, srcstr, srcparm_mask, mapcenter, $
                                MAXITER=maxiter, REDCHISQ=redchisq, NITER=niter, NFREE=nfree)
    srcstr                  = srcstr3
   ENDIF
srcstrout = srcstr
;
; Print and plot final results
PRINT
PRINT, ANYTIM(visin[0].trange, /ECS)
PRINT, visin[0].erange, FORMAT="('Energy range:', 2F7.1, ' keV')"
vis_fwdfit_print, srcstr, _EXTRA=extra
IF KEYWORD_SET(noplotfit) EQ 0 THEN vis_fwdfit_plotfit, visin, srcstr, mapcenter, _EXTRA=extra
;
; Calculate statistical uncertainty in fitted parameters.
qflag = 0                       ; a quality flag, 0 = fit is probably ok
IF KEYWORD_SET(noerr) THEN BEGIN
    fitstddev = {hsi_vis_src_structure}
    fitstddev.srctype = 'std.dev'
ENDIF ELSE BEGIN
    fitstddev = vis_fwdfit_sigmacalc(visxyobs, error, srcstr, srcparm_mask, mapcenter, QFLAG=qflag, TRIAL_RESULTS=trial_results, _EXTRA=extra)
    vis_fwdfit_print, fitstddev, /COMPACT, _EXTRA=extra
    PRINT
ENDELSE
 
derived_parms = vis_fwdfit_derived_parameters(srcstr, trial_results)
PRINT, 'Reduced chi2 = ', redchisq
IF niter EQ maxiter   THEN PRINT, 'WARNING: NO CONVERGENCE after', niter, ' iterations.' ELSE $
                    PRINT, 'Converged after', niter, ' iterations.'
IF (qflag AND 1) NE 0 THEN PRINT, 'WARNING: MARGINAL DETECTION of at least one source component.'
IF (qflag AND 2) NE 0 THEN PRINT, 'WARNING: FIT IS SUSPECT since at least one fitted parameter is at edge of its range.'
IF (qflag AND 4) NE 0 THEN PRINT, 'WARNING: FIT IS UNSTABLE due to shallow chisq minimum.'
IF (qflag AND 8) NE 0 THEN PRINT, 'WARNING: LARGE UNCERTAINTY in at least one fitted parameter.'
PRINT
IF KEYWORD_SET(showmap) NE 0 THEN vis_fwdfit_showmap, srcstr, mapcenter, TIME=visin0[0].trange[0], _EXTRA=extra
END



