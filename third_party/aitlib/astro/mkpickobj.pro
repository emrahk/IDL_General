FUNCTION mkpickobj,name
;+
; NAME:
;        mkpickobj
;
;
; PURPOSE:
;        Get positional, orbital, and pulse period information for a
;        given object name. 
;        
;
;
; CATEGORY:
;        Astronomy
;
;
; CALLING SEQUENCE:
;        obj=mkpickobj("Her X-1")
;
;
; INPUTS:
;        name: Name of the object. You can get a list of valid names
;              by calling mkpickobj with an empty string as name. 
;
;
; OPTIONAL INPUTS:
;        none
;
;
; KEYWORD PARAMETERS:
;        none
;
;
; OUTPUTS:
;        A structure containing positional information, pulse period,
;        dP/dt, and orbital parameters in case the object is a double
;        star system. In addition the type of the object is given,
;        where the following types are possible: 
;
;                  1: Pulsar 
;                  2: Binary 
;         
; OPTIONAL OUTPUTS:
;        none 
;
;
; COMMON BLOCKS:
;        none 
;
;
; SIDE EFFECTS:
;        none 
;
;
; RESTRICTIONS:
;        The orbital parameters are hopefully up to date and taken from
;        the references given in the code. 
;
;
; PROCEDURE:
;        see code 
;
;
; EXAMPLE:
;        obj=mkpickobj("Her X-1")
;
;
; MODIFICATION HISTORY:
;        Version 1.0, 2002/04/02 M. Kuster (kuster@astro.uni-tuebingen.de)
;-
  on_error,2                    ; on error return to caller
   
  object = {name:strarr(1), comment:strarr(1), type:float(1), $ 
            ra:double(1), dec:double(1),  equinox:float(1),$
            per:double(1), pdot:double(1), $
            asini:double(1), porb:double(1), $
            ecc:double(1), omegad:double(1), pporb:double(1),oepoch:double(1) }
  
  ;; object names 
  objects = [ 'Her X-1', $
              'Her X-1 Stelzer', $
              'Vela X-1', $
              'Cyg X-1', $
              'Crab', $
              'PSR B1509', $
              'PSR B0540']

  ;; comments 
  comment = [ 'Ephemeris by Still et. al. 2001', $
              'Ephemeris according to the diploma thesis of B. Stelzer', $
              'Ephemeris TBD', $
              'Ephemeris TBD', $
              'Ephemeris TBD', $
              'Ephemeris TBD', $
              'Ephemeris TBD']
  
  ;; object type: 
  ;;               1 = pulsar
  ;;               2 = binary 
  type    = [ 2 , $             ; Her X-1 
              2 , $             ; Her X-1 
              2 , $             ; Vela X-1 
              2 , $             ; Cyg X-1 
              1 , $             ; Crab 
              1 , $             ; PSR B0540 -69
              1]                ; PSR B1509    
  
  ;; object positions
  ;; RA [deg]
  ra    = [ 254.458298d0, $     ; Her X-1
            254.458298d0, $     ; Her X-1
            0.0d0, $            ; Vela X-1
            0.0d0, $            ; Cyg X-1
            83.6332244d0, $     ; Crab
            85.046028d0, $      ; PSR B0540 -69
            228.481735d0]       ; PSR B1509 
  
  ;; Dec [deg]
  dec   = [  35.342201d0, $     ; Her X-1
             35.342201d0, $     ; Her X-1
             0.0d0, $           ; Vela X-1
             0.0d0, $           ; Cyg X-1
             22.014461d0, $     ; Crab 
             -69.331993d0, $    ; PSR B0540 -69
             -59.135799d0]      ; PSR B1509 
   
  ;; equinox of the positional coordinates 
  equin = [ 2000, $             ; Her X-1
            2000, $             ; Her X-1
            2000, $             ; Vela X-1
            2000, $             ; Cyg X-1
            2000, $             ; Crab 
            2000, $             ; PSR B0540 -69
            2000]               ; PSR B1509 
   
  ;; pulse period [s]
  per   = [1.2377d0, $          ; Her X-1
           0.0d0, $             ; Her X-1
           0.0d0, $             ; Vela X-1
           0.0d0, $             ; Cyg X-1
           0.033508d0, $        ; Crab 
           0.050519d0, $        ; PSR B0540 -69
           0.15111304d0]        ; PSR B1509 

  ;; approximated dper/dt; be aware, for some objects dper/dt is
  ;; changing quite quickly, therefor this can only be an
  ;; approximation 
  pdot  = [0.0d0, $             ; Her X-1
           0.0d0, $             ; Her X-1
           0.0d0, $             ; Vela X-1
           0.0d0, $             ; Cyg X-1
           0.0d0, $             ; Crab 
           0.0d0, $             ; PSR B0540 -69 
           0.0d0]               ; PSR B1509 
  
  ;; binary orbital data 
  ;; epoch for the binary orbital data [MJD]
  oepoch= [51004.7295819d0, $   ; Her X-1 Still et. al. 2001
           43804.5199802d0, $   ; Her X-1 Stelzer Dipl. 
           0.0d0       , $      ; Vela X-1 XXX
           0.0d0, $             ; Cyg X-1
           0.0d0, $             ; Crab 
           0.0d0, $             ; PSR B0540 -69 
           0.0d0]               ; PSR B1509 
  
  ;; projected semi-major axis [lt-secs]
  asini = [ 13.19029d0, $       ; Her X-1 Still et. al. 2001
            13.18313d0, $       ; Her X-1 Stelzer Dipl.
            0.0d0, $            ; Vela X-1 XXX
            0.0d0, $            ; Cyg X-1
            0.0d0, $            ; Crab 
            0.0d0, $            ; PSR B0540 -69 
            0.0d0]              ; PSR B1509 

  ;; orbital period [d]
  porb  = [1.70033d0, $         ; Her X-1 Still et. al. 2001
           1.70016772010d0, $   ; Her X-1 Stelzer Dipl. 
           0.0d0, $             ; Vela X-1 XXX
           0.0d0, $             ; Cyg X-1
           0.0d0, $             ; Crab 
           0.0d0, $             ; PSR B0540 -69 
           0.0d0]               ; PSR B1509 

  ;; eccentricity of binary orbit 
  ecc   = [0.0d0, $             ; Her X-1 
           0.0d0, $             ; Her X-1
           0.0d0, $             ; Vela X-1 XXX
           0.0d0, $             ; Cyg X-1
           0.0d0, $             ; Crab 
           0.0d0, $             ; PSR B0540 -69 
           0.0d0]               ; PSR B1509 

  ;; longitude of periastron [deg]
  omegad= [1.0d0, $             ; Her X-1 
           1.0d0, $             ; Her X-1
           0.0d0, $             ; Vela X-1 XXX
           0.0d0, $             ; Cyg X-1
           0.0d0, $             ; Crab 
           0.0d0, $             ; PSR B0540 -69 
           0.0d0]               ; PSR B1509 

  ;; dprob/dt        
  pporb = [0.0d0, $             ; Her X-1 
           0.0d0, $             ; Her X-1
           0.0d0, $             ; Vela X-1 
           0.0d0, $             ; Cyg X-1
           0.0d0, $             ; Crab 
           0.0d0, $             ; PSR B0540 -69 
           0.0d0]               ; PSR B1509 
            
  ind=where(name EQ objects)
  
  IF (ind(0) LT 0) THEN BEGIN 
    message,'Your object name given, does not match any',/continue
    message,'object in the database !!! Please check your code !!!',/continue
    message,'Valid object names are:',/continue
    FOR j=0,n_elements(objects)-1 DO BEGIN 
      message,'>>>>  '+objects[j],/continue
    ENDFOR 
    return,0
  ENDIF 
  
  object.name   = objects(ind)
  object.comment= comment(ind)
  object.type   = type(ind)
  object.ra     = ra(ind)
  object.dec    = dec(ind)
  object.equinox= equin(ind)
  object.per    = per(ind)
  object.pdot   = pdot(ind)
  object.oepoch = oepoch(ind)
  object.asini  = asini(ind)
  object.porb   = porb(ind)
  object.ecc    = ecc(ind)
  object.omegad = omegad(ind)
  object.pporb  = pporb(ind)
  
  return,object
END 
