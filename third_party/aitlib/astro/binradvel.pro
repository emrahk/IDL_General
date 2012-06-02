FUNCTION binradvel,phase,k=k,period=period,asini=asini,eccen=eccen, $
                   omega=xomega,gamma=gamma,degrees=degrees
;+
; NAME:
;         binradvel
;
;
; PURPOSE:
;         compute radial velocity of a binary system as a function of
;         orbital phase
;
;
; CATEGORY:
;         astronomy
;
;
; CALLING SEQUENCE:
;         vel=binradvel(phase,k=k,period=period,asini=asini,eccen=eccen, $
;                   omega=omega,gamma=gamma,degrees=degrees)
;
; INPUTS:
;          phase: array with the orbital phase points (from 0 to 1)
;                 for which the radial velocity is to be computed
;          k    : velocity amplitude of the system
;          asini,period: alternative to k: semi-major axis *
;                 sin(inclination) and period of the system
;          NOTE: either k or asini and period must be given

;
;
; OPTIONAL INPUTS:
;          omega: longitude of periastron (little omega; radians,
;                 default: 0.)
;          eccen: eccentricity (default: 0.)
;          gamma: systemic velocity (same units as k or asini/P; default:0.)
;
; KEYWORD PARAMETERS:
;          degrees: if set, angular arguments are in degrees instead
;                 of radian
;
; OUTPUTS:
;      the function returns the radial velocity as a function of the
;      phase in the units of k or of asini/period
;
;
; RESTRICTIONS:
;      the eccentricity must be 0<=e<1
;
;
; PROCEDURE:
;      See chapter 3 of 
;         R.W. Hilditch, An Introduction to Close Binary Stars,
;         Cambridge Univ. Press, 2001
;
;
; EXAMPLE:
;
; Radial Velocity of HR7000
; (Hilditch, Fig. 3.27; Griffin et al., 1997, Fig. 2)
; npt=100
; phase=findgen(npt)/(npt-1)
; vel=binradvel(phase,k=21.68,gamma=-22.52,eccen=0.372,omega=306.5,/degrees)
;
; ; Show two orbits for clarity
; pp=[phase,1.+phase]
; vv=[vel,vel]
; plot,pp,vv,xtitle='Orbital Phase',ytitle='Radial Velocity [km/s]'
; xrange=!x.crange
; oplot,xrange,[0.,0.],linestyle=2
;
; MODIFICATION HISTORY:
;
; $Log: binradvel.pro,v $
; Revision 1.1  2002/09/09 14:52:04  wilms
; initial release
;
;-

  IF (n_elements(gamma) EQ 0) THEN gamma=0.
  IF (n_elements(eccen) EQ 0) THEN eccen=0.

  IF (n_elements(xomega) EQ 0) THEN xomega=0.

  omega=xomega
  IF (keyword_set(degrees)) THEN omega=omega*!DPI/180.

  IF (eccen LT 0. OR eccen GE 1.) THEN BEGIN 
      message,'Eccentricity must be between 0 and 1'
  ENDIF 

  ;; radial velocity amplitude
  IF (n_elements(k) NE 0) THEN kampl=k

  ;; Amplitude
  IF (n_elements(kampl) EQ 0) THEN BEGIN 
      IF ( (n_elements(asini) EQ 0) OR (n_elements(period) EQ 0)) THEN BEGIN 
          message,'Need either k or asini and period'
      ENDIF 
      kampl=2.*!dpi*asini/(period*sqrt((1.-eccen)*(1.+eccen)))
  ENDIF 

  ;; Compute mean anomaly from orbital phase
  meananom=2.*!dpi*phase

  ;; Now solve Kepler for each of the times
  eccanom=keplereq(meananom,eccen)

  ;; True anomaly from eccentric anomaly
  theta=2.*atan(sqrt((1.+eccen)/(1.-eccen))*tan(eccanom/2.))

  ;; Velocity amplitude
  vel=kampl*(cos(theta+omega)+eccen*cos(omega))+gamma

  return,vel
END 
