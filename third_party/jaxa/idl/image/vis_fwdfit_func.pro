FUNCTION vis_fwdfit_func, jdum, srcparm
;
; Calculates expected visibilities for a source described by array, srcparm,
;    at specified u,v points.
; Uses common block, uvdata, to specify u,v values.
; By convention, it returns a 2*nvis element vector corresponding to all real then all imaginary components.
; Number of components is implied by size of srcparm array, which has 6 elements per component.
;
; jdum is an npt-element dummy vector, required by the AMOEBA_C conventions.
;
; 23-May-05     Initial version for a single circular gaussian. (ghurford@ssl.berkeley.edu)
;  6-Aug-05 gh  Add support for ellimptical gaussian.
;  9-Aug-05 gh  Add provision to avoid EXP underflows.
;               Revise handling of ellipse geometry
; 10-Aug-05 gh  Improve nomenclature
; 15-Aug-05 gh  Correct bug affecting projected cross-section of ellipse
;               Add provision to avoid underflows at low but nonzero eccentricity
; 24-Aug-05 gh  Generalize to support multicomponent sources
; 15-Oct-05 gh  Adapt to support 'Cartesian' representation of source ellipticity
;  9-Dec-05 gh  Adapt to revised format of source parameter vector.
;               Add support for loop sources
; 16-Jan-06 gh  Add support for albedo.
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
;
COMMON uvdata, u, v, pa, mapcenter
TWOPI           = 2.*!PI
CONSTANT        = -!PI^2/(4*ALOG(2.))
ALBCONSTANT     = -0.5 * SQRT(ABS(constant))
nvis            = N_ELEMENTS(jdum)/2
obs             = FLTARR(nvis*2)
;
nsrc            = N_ELEMENTS(srcparm)/10
parmarray       = REFORM(srcparm, 10,nsrc)               ; need a 2-d structure for generality
;
; Replace loop parameters with those of a set of circular sources.   -- LOOP MUST BE THE ONLY SOURCE
IF srcparm[0] EQ 3 THEN BEGIN
    ellstr      = vis_fwdfit_array2structure(srcparm, [0,0])  ; mapcenter is arbitrarily set to 0
    ellstr.srctype = 'ellipse'
    loopstr     = vis_fwdfit_makealoop(ellstr)
    parmarray   = vis_fwdfit_structure2array(loopstr, [0,0])    ; same arbitrary mapcenter is taken out again
    nsrc        = N_ELEMENTS(parmarray)/10
    parmarray   = REFORM(parmarray,10,nsrc)
ENDIF
;
; Provision for albdeo
albedoindex = WHERE(parmarray[0,*] EQ 4, albedoflag)    ; albedoflag=0 if there is no albedo, albedoindex is index of the albedo component, if any
IF albedoflag GT 1 THEN MESSAGE, ' By convention, there should only be 1 albedo source component.'
iprimaryindex = WHERE(parmarray[0,*] NE 4, nprimary)
IF albedoflag EQ 1 THEN BEGIN
    Megam2arcsec    = 1.4                             ; nominal Mm to arcsec conversion factor
    solradius       = 960.                              ; nominal
    albratio        = parmarray[8, albedoindex]
    height          = parmarray[9, albedoindex] * Megam2arcsec
    xashift         = -((mapcenter[0]/solradius < 1.) > (-1.)) * height        ; expected shift in albedo centroid from primary centroid (note - sign)
    yashift         = -((mapcenter[1]/solradius < 1.) > (-1.)) * height
    relalbphase     = TWOPI * (u*xashift[0] + v*yashift[0])                    ; nvis element array of albedo phase relative to primary phase (radians)
    albpa           = ATAN(mapcenter[1], mapcenter[0])                        ; angle of long axis, measured E of N (radians)
ENDIF
;
; Begin loop over primary source components
FOR nn = 0, nsrc-albedoflag-1 DO BEGIN              ; loop over non-albedo components
  IF N_ELEMENTS(iprimaryindex) Le nn THEN STOP
    n = iprimaryindex[nn]
    flux            = parmarray[1,n]
    srcx            = parmarray[2,n]
    srcy            = parmarray[3,n]
    srcfwhm         = parmarray[4,n]
    eccos           = parmarray[5,n]
    ecsin           = parmarray[6,n]
    ecmsr           = SQRT(eccos^2 + ecsin^2)
    eccen           = SQRT(1 - EXP(-2*ecmsr))
    IF eccen GT 0.001 THEN srcpa = ATAN(ecsin, eccos) * !RADEG ELSE srcpa = 0  ; PA of long axis, relative to solar N(deg)
    phase           = TWOPI * (u*srcx + v*srcy)
    relpa           = (srcpa - pa) * !DTOR          ; PA of long axis, rel. to uv point PA (radians)
;                                                   ; Note that spatial resolution is orthogonal to uv PA !!
;
; Ellipse calculations
    IF eccen LT 0.001 THEN eccen = 0             ; avoids underflows in calculating eccen^2
    b =  srcfwhm * (1.-eccen^2)^0.25
    fwhmeff2        = b^2 / (1 - (eccen*COS(!PI/2 - relpa))^2)         ; nvis-element vector
    term            = CONSTANT * (u^2 + v^2) * fwhmeff2 > (-20)           ; set a lower bound to avoid underflows
    relvis          = EXP(term)                                       ; nvis-element vector
    obs[0:nvis-1]   = obs[0:nvis-1] + flux * relvis * COS(phase)    ; Each component is added to previous sum
    obs[nvis:*]     = obs[nvis:*]   + flux * relvis * SIN(phase)
;
; If necessary, add a convolved albedo visibility, implemented as the product of the primary and albedo relative visibilities
    IF albedoflag NE 0 THEN BEGIN
        relalbpa        = albpa - pa*!DTOR                                ; Albedo pa relative to uv point PA (radians)
        albscale        = height[0] * ABS(COS(!PI/2-relalbpa))                    ; Effective scale of albedo in direction of resolution for each uv point
        term            = albconstant * SQRT(u^2+v^2) * albscale > (-20)
        relalbvis       = EXP(term)
        obs[0:nvis-1]   = obs[0:nvis-1] + flux*relvis*albratio[0]*relalbvis * COS(phase+relalbphase)
        obs[nvis:*]     = obs[nvis:*]   + flux*relvis*albratio[0]*relalbvis * SIN(phase+relalbphase)
    ENDIF
ENDFOR
RETURN, obs
END