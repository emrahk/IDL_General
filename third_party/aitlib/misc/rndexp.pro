FUNCTION rndexp,avg,seed
   
;+
; NAME: 
;               rndexp
;
;
; PURPOSE:
;               return a random value on the basis of an exponential
;               distribution with a given average
;
;
; CATEGORY:
;               timing tools
;
;
; CALLING SEQUENCE:
;               rndexp(avg,seed)
;
; 
; INPUTS:
;               avg  : average of the exponential distribution
;               seed : seed value for random number generation via the
;                      ran3 generator (set to negative to reinitialize)
;
; OPTIONAL INPUTS:
;               none
;
;	
; KEYWORD PARAMETERS:
;               none
;
;
; OUTPUTS:
;               rndexp : random value on the basis of an exponential
;                          distribution with the given average
;
;
; OPTIONAL OUTPUTS:
;               none
;
;
; COMMON BLOCKS:
;               none
;
;
; SIDE EFFECTS:
;               none
;
;
; RESTRICTIONS:
;               none 
;
;
; PROCEDURE:
;               see code
;
;
; EXAMPLE:
;               rndexp(100,seed)
;
;
; MODIFICATION HISTORY:
;               Version 1.0, 1998/03/09, Katja Pottschmidt, Joern Wilms,
;                                        Sara Benlloch
;               Version 2.0, 1998/03/12, Sara (ran3)
;                                        (benlloch@astro.uni-tuebingen.de)
;           CVS Version 1.1, 2001/03/13, Joern Wilms
;               removed @ran3 from top to avoid IDL inclusion problems
;
;-% 
   rand=ran3(seed)
   IF (rand LT 1E-15) THEN rand=1E-15
   return,-alog(rand)*avg
END 
















