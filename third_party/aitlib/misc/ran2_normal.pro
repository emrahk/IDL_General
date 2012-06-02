
FUNCTION ran2_normal,idum,dim=dim
   
;+
; NAME:
;        ran2_normal
;
;
; PURPOSE:
;        returns one or more normally-distributed random numbers with
;        mean of zero an standard deviation of one.
;
;
; CATEGORY:
;        timing tools adopted from Random number generator and
;        simulatiomn by Istvan Deak, Akademiai Kiado, Budapest 1990
;
;
; CALLING SEQUENCE:
;        ran2_noraml(idum)
;
; 
; INPUTS: idum : a long integer used to initialize the random number
;        generator (ran2). The sequence for subsequent call will be
;        save in the idum variable by the ran2 function. Set idum to
;        any negative value to restart the sequence.
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
;        ran2_normalcom,ind,y 
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
; PROCEDURE:
;        ran2
;
;
; EXAMPLE:
;        ran2_normal(-23887878,dim=1000)
;
;
; MODIFICATION HISTORY:
;        Version 1.0, 2000/11/29, S. Benlloch (IAAT)
;-
   
   
   
   IF n_elements(dim) EQ 0 THEN dim=1
   ran2_normal = dblarr(dim)
   ;;
   ;; Save ind, y
   ;;
   COMMON ran2_normalcom,ind,y
   j = 0L
   IF n_elements(ind) EQ 0 THEN ind = 1

   WHILE j LT dim DO BEGIN 
       ind = -ind 
       IF (ind GT 0) THEN BEGIN 
           ran2_normal[j] = y
       END ELSE BEGIN  
           REPEAT BEGIN 
               u1 = ran2(idum)
               u2 = ran2(idum)
               v1 = 2.*u1[0] -1.
               v2 = 2.*u2[0] -1.
               w = v1^2 + v2^2
           ENDREP UNTIL (w LE 1.)  
       
           r = sqrt(-2.*alog(w)/w)
       
           y = r*v2
           x = r*v1

           ran2_normal[j] = x
       END 
       j = j+1 
   ENDWHILE 
   
   return,ran2_normal
END  


