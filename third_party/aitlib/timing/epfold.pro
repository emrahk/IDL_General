PRO epfold,intime,inrate,raterr=inerror,pstart=pstart,pstop=pstop, $
           nbins=nbins,sampling=sampl,chatty=chatty,chierg=chierg, $
           maxchierg=maxchierg,persig=persig,linear=linear,        $
           trial_period=trial_period,fitchi=fitchi, tolerance=tolerance
;+
; NAME:
;             epfold
;
;
; PURPOSE: 
;
; CATEGORY: 
;             timing tools
;
;
; CALLING SEQUENCE:
;             epfold,time,rate,raterr=raterr,pstart=pstart,pstop=pstop, 
;                    nbins=nbins,sampling=sampling,/chisq
;                       
; 
; INPUTS:
;             time : a vector containing the time in arbitary units
;             rate : a vector containing the countrate
;             pstart:   lowest period to be considered
;             pstop:    highest period to be considered
;
; OPTIONAL INPUTS:
;             raterror: a given error vector for the countrate. If not
;                       given, raterror is computed using Poissonian
;                       statistics.
;             nbins:    number of phase-bins to be used in creating the trial
;                       pulse (default=20)
;             sampling: how many periods per peak to use (default=10)   
;             linear  : if set, use a linear trial period array with
;                       step equal to the value of linear
;             trial_period : array contains the trial periods. If set,
;                            pstart is the smallest trial period and
;                            pstop the longest. 
;            tolerance: parameter defining the lower limit for the gap
;                       length; the reference is the time difference
;                       between the first and second entry in the time
;                       array; tolerance defines the maximum allowed relative
;                       deviation from this reference bin length; 
;                       default: 1e-8; this parameter is passed to timegap
;                       (see timgap.pro for further explanation)
;	
; KEYWORD PARAMETERS:

;             fitchi   : fit a Gauss distribution to the chi^2 and use
;                        the center of the gauss to determine the
;                        period, instead of using the maximum of the
;                        chi^2 distribution. This is mainly needed by
;                        eperror.pro. In case this keyword is set
;                        chierg will be 3 dimensional array and the
;                        fit result is stored in
;                        chierg[2,*]. maxchierg[1] still contains the
;                        maximum chi^2 and NOT the chi^2 of the fitted
;                        period !!
;             chatty   : if set, be chatty
;   
; OUTPUTS:
;             chierg   : 2D-array, chierg[0,*] contains the trial
;                        period, and chierg[1,*] the respective chi^2
;                        value. 
;
; OPTIONAL OUTPUTS:
;             maxchierg: 2 dim. array, maxchierg[0] contains the
;                        period of maximum chi^2, and maxchierg[1] the
;                        respective maximum chi^2
;             persig   : uncertainty of that period, from triangular
;                        approximation, not to be interpreted in a
;                        statistical sense!
;
;
; COMMON BLOCKS:
;             none
;
;
; SIDE EFFECTS:
;             none
;
;
; RESTRICTIONS:
;
;             the input lightcurve has to be given in count rates (not
;             in photon numbers). To prevent convergence problems of
;             the fit (only if keyword /fitchi is set), the maximum of
;             the chi^2 distribution has to be in between pstart and
;             pstop, and the period interval has to be resonable
;             large.
;
;
; PROCEDURE:
;             This subroutine performs a period search using epoch
;             folding. For each trial period, a pulse profile is
;             generated using pfold. This profile is then tested for
;             constancy using a chi^2 test. The maximum chi^2,
;             i.e., the maximum deviation, is the most possible
;             period. This is done for all periods between pstart and
;             pstop using a grid-search operating on the minimum
;             possible period that can still be detected (given by
;             p^2/t). 
;
;             Caveat: The significance of the found periods SHOULD NOT
;             be tested using the chi^2 value obtained from this
;             routine, since the values are only asymptotically chi^2
;             distributed (see Davies, 1990, Schwarzenberg-Czerny,
;             1989, Larsson, 1996)
; 
;             Read (and understand) the references before using this
;             routine!
;
;             References:
;                 Davies, S.R., 1990, MNRAS 244, 93
;                 Larsson, S., 1996, A&AS 117, 197
;                 Leahy, D.A., Darbro, W., Elsner, R.F., et al., 1983,
;                    ApJ 266, 160-170
;                 Schwarzenberg-Czerny, A., 1989, MNRAS 241, 153
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;             Version 1.0, Michael Koenig IAAT
;             Version 1.1, 1998/04/04, Markus Kuster IAAT
;             Version 2.0, 1998/07/01, Joern Wilms, IAAT
;             Version 2.1, 1998/07/20, Joern Wilms, IAAT
;                Now use clearer formula for chi^2
;             Version 2.2, 1999/08/05, Joern Wilms, IAAT
;                * make use of dt keyword of new pfold
;                  (slight speed improvement)
;                * removed significance keyword
;                  (caused too much trouble)
;             Version 2.3, 2000/11/28, SB, 
;                  add maxchierg optional output   
;             Version 2.4, 2001/01/08, SB,   
;                  add linear optional input/keyword
;             Version 2.5, 2001/03/07, SB,   
;                  add trial_period optional input
;             Version 2.6, 2001/07/30, Markus Kuster, IAAT
;                  add fitchi keyword 
;-
   
   ;; ******* Set default values *********
   
   time=intime
   rate=inrate
   
   ;; calculate error or use given error-vector
   IF (n_elements(inerror) EQ 0) THEN BEGIN 
       error=sqrt(abs(rate))
   END ELSE BEGIN 
       error=inerror
   END 

   ;; set default value sampling per peak
   IF (n_elements(sampl) EQ 0) THEN sampl =10.              
   
   ;; set default value number of bins
   IF (n_elements(nbins) EQ 0) THEN nbins=15

   ;; set default tolerance:
   IF (n_elements(nbins) EQ 0) THEN tolerance=1e-8 


   dim=n_elements(time) 

   IF (keyword_set(chatty)) THEN BEGIN 
       print,' '
       print,' >> Starting data analysis <<'
       print,' '
   ENDIF 

   ;; ******* DATA ANALYSIS *******

   time = time-time[0]   ; set first bin = 0 sec
   mittel = total(rate)/float(dim) ; calculate medium value
   rate = rate-mittel         ; renormalize to mean countrate
   var = variance(rate)    ;; sample variance

   ;; Temporal resolution
   delta_t = temporary(shift(time,-1))-time
   delta_t[n_elements(time)-1]=delta_t[0] ;; somewhat arbitrary
   ;; calculate smallest delta_t and set it to bintime
   bintime=min(delta_t)
   ;; Max. Timescale = pdim*dtstep = TGes
   tges = time[dim-1]-time[0]+ bintime ; 
   ;;
   IF (keyword_set(chatty)) THEN BEGIN 
       rms = sqrt(total(rate^2.)/(dim-1.))
       print,' mean / rms             ',mittel,rms ; medium countrate
       print,' total observation time ',tges
       print,' effective observation  ',dim*bintime
       print,' duty cycle             ',100.*(dim*bintime)/tges,' %'
       print
   ENDIF 

   ;; ******* CHI^2-Distribution *******

   ;; Determine final dimension of result
   IF n_elements(trial_period) EQ 0 THEN BEGIN 
     ergdim=0L
     p = pstart
     IF n_elements(linear) EQ 0 THEN BEGIN 
       WHILE (p LE pstop) DO BEGIN
         ergdim = ergdim + 1L
         p=p+p*p/(tges*sampl)
       ENDWHILE
     ENDIF ELSE BEGIN 
       ergdim = long((pstop - pstart)/double(linear)) +1L
     ENDELSE 
   ENDIF ELSE BEGIN 
     ;; sort the array in ascending order 
     trial_period = trial_period[sort(trial_period)]
     ;; dimension of the result
     ergdim = n_elements(trial_period)
     ;; determine the first and last trial period
     pstart = trial_period[0]
     pstop = trial_period[ergdim-1]
   ENDELSE
 
   IF (keyword_set(fitchi)) THEN BEGIN 
     ;; We need a 3 dimensional array to store the chi^2 fit 
     chierg=dblarr(3,ergdim)
   ENDIF ELSE BEGIN 
     chierg=dblarr(2,ergdim)
   ENDELSE      
 
   ptest = pstart
   i=0L
   WHILE (ptest LE pstop) DO BEGIN
       chierg[0,i]=ptest
       
       ;; compute profile for testperiod ptest. Since we're working 
       ;; with rates, we do not have to test for gaps.
       pfold,time,rate,profile,period=ptest,nbins=nbins, $
         proferr=proferr,raterr=error,npts=npts,/nogap, $
         dt=delta_t,tolerance=tolerance
       
       ;;JW I'm not entirely sure where the equation used by MK came
       ;;JW from. Here use eq. (4) from Davies.
       ;;JW That is MKs formula
       ;chierg(1,i)=total(profile^2.)/(nbins*total(proferr^2.))
       ;;JW and this is the Davies, eq.4 / Larsson, eq.1
       chierg[1,i]=total(npts*profile^2.)/var
       
       ;; Next test period
       IF n_elements(trial_period) EQ 0 THEN BEGIN 
         IF n_elements(linear) EQ 0 THEN $
           ptest = ptest + ptest*ptest/(tges*sampl)
         IF n_elements(linear) NE 0 THEN $
           ptest = ptest + double(linear)        
       ENDIF ELSE BEGIN 
         IF i+1L LT ergdim THEN ptest = trial_period[i+1L] $
           ELSE ptest = pstop + 1.
       ENDELSE  
       i=i+1L

       ;; Current status
       IF (keyword_set(chatty)) THEN BEGIN 
           IF ((i MOD 500) EQ 0) THEN print,i*100./ergdim,' % done'
       ENDIF 
   ENDWHILE

   chimean=total(chierg[1,*])/ergdim
   chisig=sqrt(total((chierg[1,*]-chimean)^2.)/(ergdim-1))
   maxchi=max(chierg[1,*],maxindex)
   
   IF (keyword_set(fitchi)) THEN BEGIN 
     ;; perform a simple gauss fit 
     chifit=gaussfit(chierg(0,*),chierg(1,*),f,nterms=4)
     ;; set period to the center of the gaussian
     period=f(1)
     chierg[2,*]=chifit
   ENDIF ELSE BEGIN 
     period=chierg[0,maxindex]
   ENDELSE 
      
   maxchierg = [period,maxchi]
   
   persig=period^2./tges
   ;;jw this formula is most probably wrong
   ;; sig=(maxchi-chimean)/chisig
   
   IF (keyword_set(chatty)) THEN BEGIN 
       print,' Max. Chisquare : ',maxchi, $
         ' ( P=',period,')'
   ENDIF 
END









