FUNCTION ran3,idum
;+
; NAME:
;        ran3
;
;
; PURPOSE:
;        returns a uniform random deviate between 0.0 and 1.0
;
;
; CATEGORY:
;        timing tools adopted from Numerical Recipes Software 
;
;
; CALLING SEQUENCE:
;        ran3(idum)
;
; 
; INPUTS:
;        idum : set IDUM to any negative value to initialize or
;        reinitialize the sequence
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
;        ran3 : uniform random deviate between 0.0 and 1.0
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
;        ran3(-23887878L)
;
;
; MODIFICATION HISTORY:
;        Version 1.0, 1998/03/12  Sara Benlloch (IAAT)
;                                 (benlloch@astro.uni-tuebingen.de) 
;    CVS Version 1.2, 2001/03/13 Joern Wilms
;        changed the example, added a few more LONG-statements in
;        comparisons. When restarting the RNG with the same seed the
;        same sequence of RNGs was NOT produced due to a bug in the
;        initialization subroutine --> that has been changed by now
;        correctly working with base 1 arrays instead of base 0
;        (randomization was thrown off course that way).
;
;        Version 1.3, 2001/03/13 Joern Wilms
;        removed debugging code that was erroneously left in
;-

   ;;
   ;; Save iff,inext,inextp,ma
   ;;
   COMMON ran3com,init,iff,inext,inextp,ma
   MBIG=1000000000L         ;; According to Knuth, any large MBIG and any 
   MSEED=161803398L         ;; smaller ( but still large) MSEED can be 
                            ;; substituted for the gived values. 
   MZ=0L
   FAC=1.D0/MBIG
   ;;
   ;; Initialize common block
   ;;
   IF (n_elements(init) EQ 0) THEN BEGIN
       iff=0L
       inext=0L
       inextp=31L
       ma=lonarr(56)        ;; This value is special and should not be 
                            ;; modified.   (55element array, ma(0) is NOT
                            ;; used)
       init=1
   ENDIF 

   IF (idum LT 0L) OR (iff EQ 0L) THEN BEGIN   ;; Initialization.
       iff=1L
       mj=MSEED-abs(idum)   ;; Initialize ma(54) using the seed IDUM and the
       mj=mj MOD MBIG       ;; large number MSEED.
       ma(55)=mj
       mk=1L
       FOR i=1,54 DO BEGIN  ;; Now initialize the rest of the table, in a 
           ii=((21*i) MOD 55)   ;; slightly random order, with numbers that are
           ma(ii)=mk        ;; not especially random.
           mk=mj-mk
           IF (mk LT MZ) THEN mk=mk+MBIG
           mj=ma(ii)
       ENDFOR 
       FOR k=1,4 DO BEGIN   ;; We randomize them by "warming up the generator".
           FOR i=1,55 DO BEGIN 
               ma(i)=ma(i)-ma(((1+((i+30)) MOD 55)))
               IF (ma(i) LT MZ) THEN ma(i)=ma(i)+MBIG
           ENDFOR 
       ENDFOR 
       inext=0L             ;; Prepare indices for our first generated number.
       inextp=31L           ;; The constant 31 is special (Knuth).
       idum=1
   ENDIF  
   inext=inext+1            ;; Here is where we start, except on initializaton.
                            ;; Increment INEXT, grapping around 56 to 1.
   IF (inext EQ 56) THEN inext=1
   inextp=inextp+1          ;; Ditto for INEXTP.
   IF (inextp EQ 56) THEN inextp=1
   mj=ma(inext)-ma(inextp)  ;; Now generate a new random number subtractively.
   IF (mj LT MZ) THEN mj=mj+MBIG  ;; Be sure that it is in range.
   ma(inext)=mj             ;; Store it,
   ran3=mj*FAC              ;; and output the derived uniform deviate.
   return,ran3
END 










