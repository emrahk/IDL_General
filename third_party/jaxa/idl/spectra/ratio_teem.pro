;+
;NAME:
; ratio_teem
;PURPOSE:
; Given two photon fluxes and responses, obtain t, em and uncertainties
;CALLING SEQUENCE:
; ratio_teem, cnts1, cnts2, resp1, resp2, te_in, te, em, ste, sem, $
;             unc1 = unc1, unc2 = unc2, dt=dt
;INPUT:
; cnts1, cnts2= the photon fluxes in 2 channels, filters, or whatever
; resp1, resp2= the response in 2 channels, filters, or whatever, these
;               must be defined on the same temperature array, and must
;               be defined for the same units of EM.
; te_in = the input temperature array 
;OUTPUT:
; te = T, in the units used for the response curves
; em = EM, in the units used for the response curves
; ste = uncertainty in te
; sem = uncertainty in em
;KEYWORDS:
; unc1, unc2= uncertainty in cnts1 and cnts2, if not passed in,
;          then sqrt(cnts/dt) is used
; dt = the interval times for the count rates, the default is 1.0 seconds
;      this is needed for uncertainties
;HISTORY:
; 4-mar-1997, jmm
;-
Pro Ratio_teem, cnts1, cnts2, resp1, resp2, te_in, te, em, ste, sem, $ ;
                Unc1=unc1, Unc2=unc2, dt=dt

;Some error checking first
  te = 0.0 & em = 0.0 & ste = 0.0 & sem = 0.0
  n1 = N_ELEMENTS(cnts1) & n2 = N_ELEMENTS(cnts2)
  IF(n1 NE n2) THEN BEGIN
    message, /info, 'Mismatching number of counts, bye...'
    RETURN
  ENDIF
  nintv = n1
  n1 = N_ELEMENTS(resp1) & n2 = N_ELEMENTS(resp2)
  IF(n1 NE n2) THEN BEGIN
    message, /info, 'Mismatches in responses, bye...'
    RETURN
  ENDIF
  nr = n1
  nt = N_ELEMENTS(te_in)
  IF(nr NE nt) THEN BEGIN
    message, /info, 'Mismatch between responses and T, bye...'
    RETURN
  ENDIF

;what about dt?
  IF(KEYWORD_SET(dt)) THEN BEGIN
    IF(N_ELEMENTS(dt) EQ nintv) THEN dtx = dt $
    ELSE dtx = replicate(dt(0), nintv)
  ENDIF ELSE dtx = replicate(1.0, nintv)
   
;convert everything to logs, only keep responses with nonzero temperatures
  okt = where(te_in GT 0.0)
  t6 = alog(te_in(okt))
  flux1 = resp1 > 1.0e-38
  flux2 = resp2 > 1.0e-38
  flux1 = alog(flux1(okt))
  flux2 = alog(flux2(okt))

  ok = where(cnts1 GT 0.0 AND cnts2 GT 0.0)
  fluxo1 = cnts1 > 0.0
  fluxo2 = cnts2 > 0.0

;Uncertainties are, as always, a mess
  IF(N_ELEMENTS(unc1) NE 0) THEN BEGIN
    IF(N_ELEMENTS(unc1) EQ nintv) THEN sfluxo1 = unc1 ELSE BEGIN
      message, /info, 'Bad n_elements for unc1, using sqrt(cnts1)'
      sfluxo1 = sqrt(cnts1/dtx)
    ENDELSE
  ENDIF ELSE sfluxo1 = sqrt(cnts1/dtx)

  IF(N_ELEMENTS(unc2) NE 0) THEN BEGIN
    IF(N_ELEMENTS(unc2) EQ nintv) THEN sfluxo2 = unc2 ELSE BEGIN
      message, /info, 'Bad n_elements for unc2, using sqrt(cnts2)'
      sfluxo2 = sqrt(cnts2/dtx)
    ENDELSE
  ENDIF ELSE sfluxo2 = sqrt(cnts2/dtx)
      
  te = fltarr(nintv)
  em = te
  ste = te
  sem = te
      
  IF(ok(0) NE -1) THEN BEGIN
;observed ratio of counts
    ratioo = alog(fluxo1(ok)/fluxo2(ok))
    sigma_roo = sqrt((sfluxo1(ok)/fluxo1(ok))^2+ $ ;fractional uncertainty
                     (sfluxo2(ok)/fluxo2(ok))^2) ;because of the logs...

;ratio of responses      
    ratio = flux1-flux2
    drdt = deriv(t6, ratio)
    te(ok) = interpol(t6, ratio, ratioo) ;temperature in logs
    drdt_te = interpol(drdt, t6, te(ok)) ;drdt at the given temperature
    drdt_te = drdt_te > 1.0e-20
    ste(ok) = sigma_roo/drdt_te ;fractional uncertainty
    maxtest = max([max(fluxo1), max(fluxo2)], lll)
    IF(lll EQ 0) THEN BEGIN     ;flux1 is larger
      flux_te = interpol(flux1, t6, te(ok)) ;is flux1 for em=1e47 at te
      em(ok) = alog(fluxo1(ok))-flux_te
      dfdt = deriv(t6, flux1) ;you need dlogfdlogt for the Klimchuk factor
      dfdt_te = interpol(dfdt, t6, te(ok))
      sem(ok) = sqrt((sfluxo1(ok)/fluxo1(ok))^2+$
                     (ste(ok)*dfdt_te)^2)
    ENDIF ELSE BEGIN
      flux_te = interpol(flux2, t6, te(ok)) ;is flux1 for em=1e47 at te
      em(ok) = alog(fluxo2(ok))-flux_te
      dfdt = deriv(t6, flux2) ;you need dlogfdlogt for the Klimchuk factor
      dfdt_te = interpol(dfdt, t6, te(ok))
      sem(ok) = sqrt((sfluxo2(ok)/fluxo2(ok))^2+$
                     (ste(ok)*dfdt_te)^2)
    ENDELSE
    te(ok) = exp(te(ok))
    ste(ok) = te(ok)*ste(ok)
    em(ok) = exp(em(ok))
    sem(ok) = em(ok)*sem(ok)
  ENDIF ELSE message, /info, 'No non-zero Data'
  RETURN
END
