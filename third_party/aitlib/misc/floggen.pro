FUNCTION floggen,xmin,xmax,npt
;+
; NAME:
;           floggen
;
;
; PURPOSE:
;           Generate a logarithmic grid from xmin to xmax, each inclusive,
;           with npt points
;
; CATEGORY:
;           general purpose
;
;
; CALLING SEQUENCE:
;           floggen,xmin,xmax,npt
;
; 
; INPUTS:
;           xmin: Minimum x-value
;           xmax: Maxmimum X-value
;           npt : Number of points in the array do be generated
;
; OUTPUTS:
;           The function returns the logarithmically spaced array
;
; RESTRICTIONS:
;           xmin,xmax have to be greater than 0
;           npt has to be greater than 2
;
; PROCEDURE:
;           Generate linear array in logspace, exponentiate
;
; EXAMPLE:
;           print,floggen(10.,1000.,5)
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1997/06/22 Joern Wilms (wilms@astro.uni-tuebingen.de)
;-
   on_error,2
   IF ((xmin LE 0) OR (xmax LE 0)) THEN BEGIN 
       message,'floggen: xmin or xmax is less than zero'
   ENDIF 
   IF (npt LE 2) THEN BEGIN 
       message,'floggen: Number of points has to be greater than zero'
   ENDIF 
   return,10.^( alog10(xmin)+findgen(npt)/(npt-1)*alog10(xmax/xmin))
END 
