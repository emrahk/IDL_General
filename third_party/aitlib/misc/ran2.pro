

FUNCTION ran2,idum,dim=dim
;+
; NAME:
;        ran2
;
;
; PURPOSE:
;        returns one or more uniform random deviate between 0.0 and 1.0
;
;
; CATEGORY:
;        timing tools adopted from Numerical Recipes Software 
;
;
; CALLING SEQUENCE:
;        ran2(idum)
;
; 
; INPUTS:
;        idum : a long integer used to initialize the random number
;               generator. The sequence for subsequent call will be
;               save by ran2 function in the idum variable. Set idum
;               to any negative value to restart the sequence.
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
;        ran2 : uniform random deviate between 0.0 and 1.0
;
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
;        set IDUM to any negative value to initialize or
;        reinitialize the sequence
;
;
; PROCEDURE:
;        none
;
;
; EXAMPLE:
;        ran2(-23887878)
;
;
; MODIFICATION HISTORY:
;        Version 1.0, 1998/03/12, Sara Benlloch (IAAT)     
;                                 (benlloch@astro.uni-tuebingen.de)
;        Version 1.1, 2000/11/28, S. Benlloch (IAAT)   
;                   optional input dim added   
;-


   ;;
   ;; Save iv, idum2, and iy
   ;;
   COMMON sbran2com,init,iv,idum2,iy
   IM1=2147483563L
   IM2=2147483399L
   AM=1.D0/double(IM1)
   IMM1=IM1-1L
   IA1=40014L
   IA2=40692L
   IQ1=53668L
   IQ2=52774L
   IR1=12211L
   IR2=3791L
   NTAB=32
   NDIV=1+IMM1/NTAB
   EPS=1.2D-7
   RNMX=1.D0-EPS
   ;;
   ;; Initialize common block
   ;;
   IF (n_elements(init) EQ 0) THEN BEGIN 
       iv=lonarr(NTAB+1)
       idum2=123456789L
       iy=0L
       init=1
   ENDIF 
   IF (idum LE 0) THEN BEGIN  
       idum=-idum>1
       idum2=idum
       FOR  j=NTAB+8,1,-1 DO BEGIN 
           k=idum/IQ1
           idum=IA1*(idum-k*IQ1)-k*IR1
           IF (idum LT 0) THEN idum=idum+IM1
           IF (j LE NTAB) THEN  iv(j)=idum
       ENDFOR 
       iy=iv(1)
   ENDIF    
   ;; here is where we start except on initialization
   IF n_elements(dim) EQ 0 THEN dim = 1
   ran2 = dblarr(dim)
   FOR i=0L,dim-1 DO BEGIN 
       k=idum/IQ1              
       idum=IA1*(idum-k*IQ1)-k*IR1
       IF (idum LT 0) THEN  idum=idum+IM1
       k=idum2/IQ2
       idum2=IA2*(idum2-k*IQ2)-k*IR2
       IF (idum2 LT 0) THEN  idum2=idum2+IM2
       j=1+iy/NDIV
       iy=iv(j)-idum2
       iv(j)=idum
       IF (iy LT 1) THEN iy=iy+IMM1
       ran2[i]=AM*iy<RNMX
   ENDFOR     
   return,ran2
END






