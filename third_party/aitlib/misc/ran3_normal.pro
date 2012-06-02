
FUNCTION ran3_normal,idum,dim=dim
   
;+
; NAME:
;        ran3_normal
;
;
; PURPOSE:
;        returns one or more normally-distributed random numbers with
;        mean of zero an standard deviation of one, using the ran3
;        random number generator.
;
;
; CATEGORY:
;        timing tools adopted from Random number generator and
;        simulatiomn by Istvan Deak, Akademiai Kiado, Budapest 1990
;
;
; CALLING SEQUENCE:
;        ran3_normal(seed)
;
; 
; INPUTS: seed : a long integer used to initialize the random number
;        generator (ran3). Set seed to
;        any negative value to start the sequence.
;
; OPTIONAL INPUTS:
;        dim  : the dimension of the result. (default = 1)
;
;
; KEYWORD PARAMETERS:
;        none
;
;
; OUTPUTS:
;        ran2_normal : one or more random deviates from a normal
;        distribution  (dimension of the output = dim)
;
;
; OPTIONAL OUTPUTS:
;        none
;
;
; COMMON BLOCKS:
;        ran3_normalcom,ind,y 
;
;
; SIDE EFFECTS:
;        none
;
;
; RESTRICTIONS:
;        set IDUM to any negative value to initialize or
;        reinitialize the sequence
;
;
; EXAMPLE:
;        ran3_normal(-23887878,dim=1000)
;
;
; MODIFICATION HISTORY:
;        Version 1.0, 2002/02/25, J. Wilms, based on ran2_normal
;-
   
   ;;
   ;; Save ind, y
   ;;
   COMMON ran3_normalcom,ind,y
   
   IF n_elements(dim) EQ 0 THEN dim=1
   ran3_normal = dblarr(dim)

   j = 0L
   IF n_elements(ind) EQ 0 THEN ind = 1

   WHILE j LT dim DO BEGIN 
       ind = -ind 
       IF (ind GT 0) THEN BEGIN 
           ran3_normal[j] = y
       END ELSE BEGIN  
           REPEAT BEGIN 
               u1 = ran3(idum)
               u2 = ran3(idum)
               v1 = 2.*u1[0] -1.
               v2 = 2.*u2[0] -1.
               w = v1^2 + v2^2
           ENDREP UNTIL (w LE 1.)  
       
           r = sqrt(-2.*alog(w)/w)
       
           y = r*v2
           x = r*v1

           ran3_normal[j] = x
       END 
       j = j+1 
   ENDWHILE 
   
   return,ran3_normal
END  


