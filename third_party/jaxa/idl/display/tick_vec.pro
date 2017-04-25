;+
; Project     : SOHO - CDS     
;                   
; Name        : TICK_VEC
;               
; Purpose     : Generate tickmarks for tight (or wide) displays.
;               
; Explanation : Up to a specified number of equidistant tickmarks are
;               returned.
;               
; Use         : TICVEC = TICK_VEC(MAXN,MIN,MAX)
;    
; Inputs      : MAXN : The maximum number of tick marks allowed.
;               MIN  : The minimum value on the axis
;               MAX  : The maximum value on the axis
;
; Opt. Inputs : None.
;               
; Outputs     : Returns a vector in the interval [ MIN, MAX ], with up to MAXN
;               entries.
;               
; Opt. Outputs: None.
;               
; Keywords    : MINOR : Number of minor ticks that are appropriate.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utilities
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar Haugan, June 1994
;               
; Modified    : Version 2, SVHH, 30 May 1996
;                       Improved algorithm, added SUBTICKS keyword
;
; Version     : 2, 30 May 1996
;-            



FUNCTION tick_vec,MaxN,MIN,MAX,subticks=subticks
  
  mmin = MIN(DOUBLE([MIN,MAX]))
  mmax = MAX(DOUBLE([MIN,MAX]))
  
  CASE 1 OF 
     mmin EQ 0.0d: offset = -1d-20
     mmin LT 0.0d: BEGIN
        ex = FIX(alog10(abs(mmin)))+1 > FIX(alog10(abs(mmax)))+1
        offset = -10.0d^ex
     END
     ELSE : offset = 0.0d
  END
  
  
  mMIN = mmin-offset
  mMAX = mmax-offset
  
  diffmagn = alog10(abs(mMAX-MMIN))+1
  
  f = FIX(diffmagn)
  
  REPEAT BEGIN
     relmax = mMAX/(10.d^f)
     relmin = MMIN/(10.d^f)

     common_first = FIX(relmin)
     
     fracmax = relmax-common_first
     fracmin = relmin-common_first
     
     IF fracmax GT 1.0 THEN f = f+1
  END UNTIL fracmin GT 0.0 AND fracmax LT 1.0
  
  divisors = [2L,5,10,20,50,100,$
              200,500,1000,2000,5000,10000L,$
              20000L,50000L]
  subticks = [0,5,2,10,5,2,10,5,2,10,5,2,10,5,2,10,5,2,10]

  dvi = 0
  lastgood = [fracmax+fracmin]*0.5d
  
  WHILE dvi LT N_ELEMENTS(divisors) DO BEGIN
     dvisor = divisors(dvi)
     tags = DINDGEN(dvisor+1)/DOUBLE(dvisor)
     validi = WHERE(tags GE fracMIN AND tags LE fracMAX,count)
     IF count GT 0 THEN BEGIN
        IF count GT maxn THEN BEGIN
           subticks = subticks(dvi)
           RETURN,([lastgood]+common_first)*10.d^f+offset
        END
        
        lastgood = tags(validi)
     END
     dvi = dvi+1
  END
  RETURN,0
END

