;+
; Project     : SOHO - CDS     
;                   
; Name        : CLEAN_EXPOSURE
;               
; Purpose     : Clean cosmic rays from single (slit spectrogram) exposure
;               
; Explanation : This routine identifies cosmic rays by comparing pixels with
;               the median of the surrounding pixels inside a rectangular box.
;
;               The routine is specifically designed to work with slit
;               spectrograms, with the first dimension of the data being the
;               dispersion direction, and the second dimension along the
;               slit. The rectangular box used to calculate the local median
;               value is longer in the slit direction than in the dispersion
;               direction. The size of the median box can be set through the
;               keywords XBOX/YBOX.
;
;               The routine does a fairly good job of identifying cosmic rays
;               when comparing with cosmic rays identified by eye. The method
;               is, however, not foolproof. Both false alarms and undetected
;               cosmic rays do occur, so manual inspection is encouraged.
;
;               A pixel P is determined to be a (first approximation) cosmic
;               ray:
;
;               IF   ( P LT LIMIT AND (P - MEDIAN) GT MAX_VAR_LOW )
;                 OR ( P GE LIMIT AND (P / MEDIAN) GT MAX_FACTOR_HI )
;
;		where LIMIT, MAX_VAR_LOW and MAX_FACTOR_HI can be set through
;		keywords. They have useful default values for debiased CDS NIS
;		exposures.  For other instruments, these parameters, as well as
;		XBOX,YBOX, will need to be retuned.
;
;               Since this definition often leaves (minimally) affected pixels
;               on the borders of cosmic ray hits untouched, all pixels having
;               a (first approximation) cosmic ray neighbour to its left or
;               right, or directly above or below will be marked as cosmic
;               rays as well. This may be turned off by setting the keyword
;               NO_NEIGHBOUR, or modified by setting the KERNEL keyword to a
;               convolution kernel that is used to flag neighbours.
;
;               If a MISSING value is supplied, identified cosmic ray pixels
;               are set to this value. Supplying the MISSING value will also
;               leave pixels with this value out in the calculation of the
;               local median.
;
;               If the keyword FILL is set, or if no MISSING value is
;               supplied, the cosmic ray pixels are filled with the median of
;               the surrounding pixels.
;               
; Use         : clean = CLEAN_EXPOSURE(EXPOSURE)
;    
; Inputs      : EXPOSURE : A 2-dimensional array of counts.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns EXPOSURE with cosmic ray hits set to MISSING or filled
;               
; Opt. Outputs: SWTCH : Byte array, same size as EXPOSURE, entries set to 1
;                       for each flagged pixel
;               
; Keywords    : MISSING : The value of possible missing data (like
;                         already-identified cosmic rays), and the value used
;                         to flag the cosmic ray pixels. If this value is not
;                         supplied, the FILL option is automatically used.
;
;               FILL : Set this flag to fill in the cosmic ray pixels with the
;                      value of the local median.
;
;               NO_NEIGHBOUR : Set this flag to avoid flagging nearest
;                              neighbours (left, right, above, below) of first
;                              approximation cosmic ray pixels as cosmic rays.
;                              
;                              The effect of the KERNEL keyword is turned off
;                              when NO_NEIGHBOUR is set.
;
;               XBOX/YBOX: Determines the size of the box used to calculate
;                          the local median.
;
;               LIMIT : Determines the dividing line between high/low pixels,
;                       see the algorithm description.
;
;               MAX_VAR_LOW : See the algorithm description
;
;               MAX_FACTOR_HI : See algorithm description.
;
;               KERNEL : See algorithm description, and it's use in the
;                        program. Setting NO_NEIGHBOUR disables this keyword.
;
; Calls       : default, fmedian()
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : General Utility
;               
; Prev. Hist. : None.
;
; Written     : S. V. H. Haugan, UiO, 11 December 1996
;               
; Modified    : Version 2, SVHH, 6 May 1998
;               Version 3, SVHH, 17 August 1998
;                          Fixed bug introduced with the kernel keyword in
;                          version 2. Without NO_NEIGHBOUR set, the default 
;                          kernel was always applied twice (regardless of 
;                          the KERNEL keyword setting), causing the neighbours
;                          of neighbours to be flagged too).
;               Version 4, SVHH, 6 March 2007
;                          Added BADIX as an optional output list of bad pixels
;               Version 5, SVHH, 11 March 2007
;                          Changed to use SWTCH as optional ouput mask for
;                          bad (altered) pixels.
; Version     : 5, 11 March 2007
;-            

FUNCTION clean_exposure,expo,$
              missing=missing,$
              fill=fill,no_neighbour=no_neighbour,kernel=kernel,$
              xbox=xbox,ybox=ybox,$
              limit=limit,swtch=swtch,$
              max_var_low=max_var_low,max_factor_hi=max_factor_hi
  
  ;; Pretty good default values (for CDS NIS).
  
  default,max_var_low,6
  default,max_factor_hi,1.7
  default,limit,2*max_var_low
  
  default,xbox,3
  default,ybox,7
  
  IF N_ELEMENTS(missing) NE 1 THEN BEGIN
     fill = 1
     imissing = min(expo)-1
  END ELSE BEGIN
     imissing = missing
  END
    
  med = fmedian(expo,xbox,ybox,missing=imissing)
  
  lowdata = (expo LT limit)
  hidata = lowdata-1b
  
  badix = WHERE(lowdata AND (expo-med) GT max_var_low OR $
                hidata AND (expo/(med > 1)) GT max_factor_hi,count)
  
  sz = SIZE(expo)
  sz(sz(0)+1) = 1
  
  swtch_present = arg_present(swtch)
  
  IF swtch_present THEN swtch = make_array(size=sz)
  
  IF count EQ 0 THEN RETURN,expo
  
  touched = make_array(SIZE=sz)
  touched(badix) = 1
  
  IF NOT keyword_set(no_neighbour) THEN BEGIN
     IF NOT keyword_set(kernel) THEN $
        kernel = [[0b,1b,0b],[1b,1b,1b],[0b,1b,0b]]
     touched = convol(touched,kernel,/edge_truncate)
  END
  
  badix = WHERE(touched)
  
  result = expo
  
  result(badix) = imissing
  IF swtch_present THEN swtch[badix] = 1b
  
  IF KEYWORD_SET(fill) THEN BEGIN
     REPEAT BEGIN
        newmed = fmedian(result,xbox,ybox,missing=imissing)
        result(badix) = newmed(badix)
        IF swtch_present THEN swtch[badix] = 1b
        newmiss = where(newmed(badix) EQ imissing)
        IF newmiss(0) NE -1 THEN badix = badix(newmiss) $
        ELSE badix = -1
     END UNTIL badix(0) EQ -1
  END
  
  RETURN,result
  
END
