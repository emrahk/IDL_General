;
; Create spectrum of type type (where 0:ph, 1: fnu, 2: nu fnu, 3: nph)
;
PRO spec2type, spec, type 
   CASE type OF 
       0: spec2phot, spec
       1: spec2fnu, spec
       2: spec2nufnu, spec
       3: spec2nph, spec
       ELSE: BEGIN 
           error, 'Spectral type nonexistent'
       END 
   END 
END 
