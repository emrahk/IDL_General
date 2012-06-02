FUNCTION keplereq,m,ecc,thresh=thresh
;+
; NAME:
;    keplereq
; PURPOSE: 
;    Solve Kepler's Equation
; DESCRIPTION:
;    Solve Kepler's Equation. Method by S. Mikkola (1987) Celestial
;       Mechanics, 40 , 329-334. 
;    result from Mikkola then used as starting value for
;       Newton-Raphson iteration to extend the applicability of this
;       function to higher eccentricities
;
; CATEGORY:
;    Celestial Mechanics
; CALLING SEQUENCE:
;    eccanom=keplereq(m,ecc)
; INPUTS:
;    m    - Mean anomaly (radians; can be an array)
;    ecc  - Eccentricity
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORD INPUT PARAMETERS:
;    thresh: stopping criterion for the Newton Raphson iteration; the
;            iteration stops once abs(E-Eold)<thresh
; OUTPUTS:
;    the function returns the eccentric anomaly
; KEYWORD OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;  2002/05/29 - Marc W. Buie, Lowell Observatory.  Ported from fortran routines
;    supplied by Larry Wasserman and Ted Bowell.
;    http://www.lowell.edu/users/buie/
;
;  2002-09-09 -- Joern Wilms, IAA Tuebingen, Astronomie.
;    use analytical values obtained for the low eccentricity case as
;    starting values for a Newton-Raphson method to allow high
;    eccentricity values as well
;
;  $Log: keplereq.pro,v $
;  Revision 1.1  2002/09/09 14:54:11  wilms
;  initial release into aitlib
;
;
;-

  ;; set default values
  IF (n_elements(thresh) EQ 0) THEN thresh=1D-5

  IF (ecc LT 0. OR ecc GE 1.) THEN BEGIN 
      message,'Eccentricity must be 0<= ecc. < 1'
  ENDIF 

  ;;
  ;; Range reduction of m to -pi < m <= pi
  ;;
  mx=m

  ;; ... m > pi
  zz=where(mx GT !dpi,count)
  IF (count NE 0) THEN BEGIN 
      mx[zz]=mx[zz] MOD (2*!dpi)
      zz=where(mx GT !dpi,count)
      IF (count NE 0) THEN mx[zz]=mx[zz]-2.0D0*!dpi
  ENDIF 

  ;; ... m < -pi
  zz=where(mx LE -!dpi,count)
  IF (count NE 0) THEN BEGIN 
      mx[zz]=mx[zz] MOD (2*!dpi)
      zz=where(mx LE -!dpi,count)
      IF (count NE 0) THEN mx[zz]=mx[zz]+2.0D0*!dpi
  ENDIF 

  ;;
  ;; Bail out for circular orbits...
  ;;
  IF (ecc EQ 0.) THEN return,mx

  aux   =  4.d0*ecc+0.5d0
  alpha = (1.d0-ecc)/aux


  beta=mx/(2.d0*aux)
  aux=sqrt(beta^2+alpha^3)
   
  z=beta+aux
  zz=where(z LE 0.0d0,count)
  if count GT 0 THEN  z[zz]=beta[zz]-aux[zz]

  test=abs(z)^0.3333333333333333d0

  z =  test
  zz=where(z LT 0.0d0,count)
  IF count GT 0 THEN z[zz] = -z[zz]

  s0=z-alpha/z
  s1=s0-(0.078d0*s0^5)/(1.d0+ecc)
  e0=mx+ecc*(3.d0*s1-4.d0*s1^3)

  se0=sin(e0)
  ce0=cos(e0)

  f  = e0-ecc*se0-mx
  f1 = 1.d0-ecc*ce0
  f2 = ecc*se0
  f3 = ecc*ce0
  f4 = -f2
  u1 = -f/f1
  u2 = -f/(f1+0.5d0*f2*u1)
  u3 = -f/(f1+0.5d0*f2*u2+.16666666666667d0*f3*u2*u2)
  u4 = -f/(f1+0.5d0*f2*u3+.16666666666667d0*f3*u3*u3+.041666666666667d0*f4*u3^3)

  eccanom=e0+u4

  zz = where(eccanom GE 2.0d0*!dpi,count)
  IF count NE 0 THEN  eccanom[zz]=eccanom[zz]-2.0d0*!dpi
  zz = where(eccanom LT 0.0d0,count)
  IF count NE 0 THEN eccanom[zz]=eccanom[zz]+2.0d0*!dpi

  ;; Now get more precise solution using Newton Raphson method
  ;; (modification J. Wilms)
  FOR i=0,n_elements(eccanom)-1 DO BEGIN 
      REPEAT BEGIN 
          ;; E-e sinE-M
          fe=eccanom[i]-ecc*sin(eccanom[i])-mx[i]
          ;; f' = 1-e*cosE
          fs=1.-ecc*cos(eccanom[i])
          oldval=eccanom[i]
          eccanom[i]=oldval-fe/fs
      ENDREP UNTIL (abs(oldval-eccanom[i]) LE thresh)
      ;; the following should be coded more intelligently ;-) 
      ;; (similar to range reduction of mx...)
      WHILE (eccanom[i] GE  !dpi) DO eccanom[i]=eccanom[i]-2.*!dpi
      WHILE (eccanom[i] LT -!dpi ) DO eccanom[i]=eccanom[i]+2.*!dpi
  ENDFOR 
  return,eccanom
END 
