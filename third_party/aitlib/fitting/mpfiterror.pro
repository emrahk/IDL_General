FUNCTION mpfiterror, fcn,x, y,err,start_params,parinfo=parinfo, $
                     bestnorm=bestnorm,delchi=delchi,toldel=toldel, $
                     perror=perror,debug=debug,intpar=iintpar, $
                     maxtry=maxtry,chierr=chierr,_extra=extra
;+
; NAME:
;        mpfiterror
;
;
; PURPOSE:
;        compute two-sided, asymmetric error bars for a chi^2 fit
;
;
; CATEGORY:
;        function fitting
;
;
; CALLING SEQUENCE:
;         result=mpfiterror(fnctn,x, y,err,start_params, weights=weights, $
;                   parinfo=pari,bestnorm=chi2, $
;                   delchi=delchi,toldel=toldel, $
;                   debug=debug,intpar=intpar,...)
;
;
; 
; INPUTS:
;          similar to mpfitfun, see the documentation of mpfitfun
;          for an exhaustive explanation.
;          The input-parameter bestpar is the best-fit vector as returned
;          from mpfitfun, perror is the "uncertainty" (i.e. the
;          diagonal elements of the Hessian matrix) as returned from
;          jwcurvefit.
; 
;        fnctn: name of the fit function
;        x,y,err: x- and y-value, and error 
;        start_params: if given, best fit parameter values for which
;           the error is to be computed. I recommend use of the
;           parinfo structure instead (see below)
;
;
; KEYWORD PARAMETERS:
;        parinfo: structure containing parameter information,
;           required. If start_params are not given, the value tag
;           should contain the best fit value of each parameter 
;        bestnorm= the chi^2 value of the best fit 
;                 as returned from mpfitfun (bestnorm keyword)
;        debug= return tons of debugging information.
;                     1: basic information
;                     2: current try value
;                     3: detailed information
;        intpar= array containing the indexes of all interesting
;                 parameters, i.e., those for which the uncertainty
;                 is to be computed (note: although the word
;                 interesting is used here, this is not to be confused
;                 with the notion of "interesting parameters" in chi^2
;                 minimization)
;        delchi= delta chi^2 to be used for the determination of
;                 the uncertainty. default: 1, corresponding to 1
;                 sigma errors. Use 2.71 for 90% uncertainty
;                 (in general, delchi=chisqr_dvf(1-prob,1) where
;                 prob is the probability that the n dimensional
;                 parameter space spanned by the uncertainties
;                 contains the real value)
;        maxtry= maximum number of invocations of mpfitfun in the
;                 determination of ONE error (used to determine
;                 non-convergence).
;        toldel= max. allowed relative deviation between
;                 chi2min+delchi and the current chi^2 value. used to
;                 define precision of the bounds. 
;        chierr= 2d array, contains for each parameter the real
;                 chi^2 value at the bounds, to enable checking of
;                 the precision of the bounds.
;
;
; OUTPUTS:
;           a 2 dimensional array containing the error ranges for all
;           fit parameters (lower boundary = upper boundary for the
;           fixed parameters).
;
;
; OPTIONAL OUTPUTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;           a not very stable combination of a secant method and bisection 
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;     based on fiterror.pro, written by Joern Wilms on 1999.10.21,
;     based on previous work by JW and Mike Nowak, and subsequent
;     corrections.
;
;     CVS Version 1.0, 2001.12.06, Joern Wilms
;         (mainly written while at SSO in October 2001)
;
;-
   
   ;; 
   ;; Save parameters
   ;;
   pbest=parinfo
   chi2=bestnorm
   intpar=iintpar

   IF (n_elements(debug) EQ 0) THEN debug=0
   
   ;; no delchi given; use 1sigma error
   IF (n_elements(delchi) EQ 0) THEN delchi=1.
   
   ;; ...number of frozen parameters
   dummy=where(pbest.fixed,numfroz)

   ;; ...set bounds for all parameters to simplify our life
   ndx=where(pbest.limited[0] NE 1) ;; lower bound
   IF (ndx[0] NE -1) THEN pbest[ndx].limits[0]=-1E30

   ndx=where(pbest.limited[1] NE 1) ;; upper bound
   IF (ndx[0] NE -1) THEN pbest[ndx].limits[1]=+1E30

   pbest[*].limited[*]=1 

   ;; if start_params is given, the values in start_params override
   ;; those in the parinfo keyword
   IF (n_elements(start_params) NE 0) THEN pbest.value=start_params

   ;; list of interesting parameters
   IF (n_elements(intpar) EQ 0) THEN BEGIN 
       intpar=where(pbest[*].fixed EQ 0)
   ENDIF 

   ;;
   ;; estimate for the parameter uncertainties
   ;;
   dof=n_elements(y)-(n_elements(pbest)-numfroz)
   uncert=perror*sqrt(chi2/dof)

   ;;
   ;; toldel: relative tolerance of reaching chi2+delchi
   ;;
   IF (n_elements(toldel) EQ 0) THEN toldel=1E-4
   
   ;;
   ;; maxtry: maximum number of invocations to jwcurvefit before
   ;;   giving up
   ;;
   IF (n_elements(maxtry) EQ 0) THEN maxtry=20

   ;;
   ;; Initialization of error array
   ;;
   error = replicate({mpfiterr,min:0.,max:0.,mininfo:0,maxinfo:0}, $
                     n_elements(pbest)) 
   error[*].min=pbest.value
   error[*].max=pbest.value

   ;; Chi2 values at error bounds
   chierr= fltarr(2,n_elements(pbest))

   ;;
   ;; Check whether one of the interesting parameters is fixed
   ;; and remove them from the list
   ;;
   ndx=where(pbest[intpar].fixed EQ 0)
   IF (ndx[0] EQ -1) THEN return,error
   intpar=intpar[ndx]

   ;;
   ;; delchi is the chi^2 change we're looking for, usually 2.706 for 90%
   ;;
   chimin=chi2
   chimax=chimin+delchi

   IF (debug GE 1) THEN BEGIN 
       print,'minimum chi2 :', chimin
       print,'searched chi2:',chimax
   ENDIF 

   ;; .. helper
   boundary=[' lower ',' upper ']
       
   FOR ii=0,n_elements(intpar)-1 DO BEGIN 
       i=intpar[ii]

       IF (debug GE 1) THEN BEGIN 
           IF (debug EQ 2) THEN print
           print,'Working on parameter '+strtrim(string(i),2)
           IF (debug EQ 2) THEN print,format='($,"   ")'
       ENDIF 
       
       ;;
       ;; search two times, once for the lower bound, once for the upper
       ;;
       
       ;; starting values for lower bound,
       ;; catching starting values outside allowed range
       ;; (for upper get set below)
       astart=pbest[i].value-uncert[i]

       IF (astart LT pbest[i].limits[0]) THEN BEGIN 
           uu=uncert[i]/3.
           WHILE (astart LT pbest[i].limits[0]) DO BEGIN 
               astart=pbest[i].value-uu
               uu=uu/3.
           ENDWHILE 
       ENDIF 

       FOR numit=0,1 DO BEGIN 
           ;;
           ;; do a secant method to find parameter value where chi^2 is
           ;; larger than chi^2min+delchi in the range lowbounds-highbounds
           ;;
           ;; to avoid oscillations: when two parameters bracketing the
           ;; chi^2min+delchi are found: use bisection
           ;; 
           IF (debug EQ 2) THEN BEGIN 
               IF (numit EQ 1) THEN print
               print,'  '+boundary[numit]+' boundary: '
           ENDIF 

           aold=pbest[i].value
           chi2old=chimin

           IF (debug GE 3) THEN BEGIN 
               print,'  '+boundary[numit]+' boundary'
               print,'  aold:'+strtrim(string(aold),2)
           ENDIF 

           anew=astart ;; starting value

           
           numcall=0
           done=0
           WHILE (done EQ 0) DO BEGIN 
               ;; Set stepped parameter to test value, freeze, and fit
               p=pbest
               p[i].value=anew
               p[i].fixed=1

               IF (debug EQ 2) THEN BEGIN 
                   print,format='($,A,",")', $
                     strtrim(string(format='(G10.5)',anew),2)
               ENDIF 
               
               numcall=numcall+1
               imfit = mpfitfun(fcn,x,y,err,parinfo=p,bestnorm=chi2, $
                                _extra=extra)
               chi2new=chi2

               ;;
               ;; Test several stopping conditions
               ;;
               
               ;;
               ;; Stopping Condition: NaN is reached
               ;;
               IF (NOT finite(chi2) ) THEN BEGIN 
                   message,'Aborted for parameter '+string(i),/informational
                   message,'NaN reached at'+boundary[numit]+'boundary',$
                     /informational
                   done=3
               END 
               
               ;;
               ;; Stopping Condition: max. number of calls
               ;;
               IF (numcall EQ maxtry) THEN BEGIN 
                   message,'Aborted for parameter '+string(i),/informational
                   message,'maximum number of calls reached',/informational
                   message,'at'+boundary[numit]+'boundary',/informational
                   message,'during secant stage',/informational
                   done=3
               END 
               
               IF (debug GE 3) THEN BEGIN 
                   print,'  anew, chi2new, chimax',anew,chi2new,chimax
               END 

               ;;
               ;; stopping criterion: chi2 is about chimax
               ;;
               IF (abs(chi2new-chimax)/chimax LT toldel) THEN done=1
                      
               ;;
               ;; Stopping criterion: interval is found (then do bisection)
               ;;
               IF (done NE 1) THEN BEGIN 
                   IF ((chi2old-chimax)*(chi2new-chimax) LT 0.) THEN BEGIN 
                       done=2
                   END 
               ENDIF  

               ;;
               ;; If we've evaluated at the hard bounds and chi2 value
               ;; there is smaller than the desired value, return lower
               ;; bounds as lower error margin
               ;; note: separate if from the linear extrapolation step
               ;; below is required!
               ;;
               IF (done EQ 0) THEN BEGIN 
                   IF (aold LE  pbest[i].limits[0]+uncert[i] OR $
                       aold GE  pbest[i].limits[1]-uncert[i] AND $
                       chi2old LT chimax) THEN BEGIN 

                       done=-2
                   ENDIF 
               END 


               ;;
               ;; No stopping condition --> next step
               ;;
               IF (done EQ 0) THEN BEGIN 
                   ;;
                   ;; linear extrapolation to find next parameter
                   ;;
                   anext=(chimax-chi2old)/(chi2new-chi2old)*(anew-aold)+aold

                   IF (numit EQ 0) THEN BEGIN 
                       IF (anext GT pbest[i].value) THEN BEGIN 
                           message,'Crossing best fit value from below',$
                             /informational
                           anext=anew-uncert[i] ;; shoot instead
                       ENDIF 
                       IF (anext LT pbest[i].limits[0]) THEN BEGIN 
                           message,'Applying lower limit',/informational
                           anext=pbest[i].limits[0]+uncert[i]
                       ENDIF 
                   ENDIF 

                   IF (numit EQ 1) THEN BEGIN 
                       IF (anext LT pbest[i].value) THEN BEGIN 
                           message,'Crossing best fit value from above',$
                             /informational
                           anext=anew+uncert[i] ;; shoot instead
                       ENDIF 
                       IF (anext GT pbest[i].limits[1]) THEN BEGIN 
                           message,'Applying upper limit',/informational
                           anext=pbest[i].limits[1]-uncert[i]
                       ENDIF 
                   ENDIF 

                   ;; Remember old a for next step, keep new a within 
                   ;; lower bound and best fit value 
                   aold=anew
                   chi2old=chi2new

                   ;; Set new parameter
                   anew=anext

               ENDIF 

           END 

           IF (debug GE 3) THEN BEGIN 
               IF (done EQ 1) THEN print,'bound found at ',aold
               IF (done EQ 2) THEN BEGIN 
                   print,'bracketing: ',aold,chi2old,chimax
                   print,'            ',anew,chi2new
               ENDIF 
           ENDIF 

           ;;
           ;; If we found the interval, search exact value by bisection 
           ;; we are guaranteed to stay within the bounds (that has
           ;; been ensured within the secant method above)
           ;;
           IF (done EQ 2) THEN BEGIN 
               IF (debug GE 3) THEN BEGIN 
                   print,'range found'
                   print,'  new  ',chi2new,anew
                   print,'  goal ',chimax
                   print,'  old  ',chi2old,aold
               ENDIF 

               done=0
               WHILE (done EQ 0) DO BEGIN 
                   ;; Starting parameters are best fit parameters
                   p=pbest
                   
                   ;; Set stepped parameter to test value, freeze, and fit
                   amid=(anew+aold)/2.
                   p[i].value=amid
                   p[i].fixed=1
                   numcall=numcall+1

                   IF (debug GE 2) THEN BEGIN 
                       print,format='($,A,",")', $
                         strtrim(string(format='(G10.5)',amid),2)
                   ENDIF 

                   imfit = mpfitfun(fcn,x,y,err,parinfo=p,bestnorm=chi2, $
                                    _extra=extra)
                   chi2mid=chi2

                   IF ((chi2old-chimax)*(chi2mid-chimax) LT 0.) THEN BEGIN 
                       anew=amid
                       chi2new=chi2mid
                   END ELSE BEGIN 
                       aold=amid
                       chi2old=chi2mid
                   END 

                   IF (debug GE 3) THEN BEGIN 
                       print,'New Range for parameter '+strtrim(i,2)+': '
                       print,'   ',chi2new,string(format='(E22.15)',anew)
                       print,'   ',chimax
                       print,'   ',chi2old,string(format='(E22.15)',aold)
                       print,'   ',(anew+aold)/2.
                   END 

                   ;;
                   ;; stopping criterion: chi2 is about chimax
                   ;;
                   IF (abs(chi2old-chimax)/chimax LT toldel) THEN done=1
                   
                   ;; Stopping criterion: max number of curvefit calls reached
                   IF (numcall EQ maxtry) THEN BEGIN 
                       boundary=['lower','upper']
                       message,'Aborted for par. no. '+string(i),/informational
                       message,'maximum number of calls reached',/informational
                       message,'at '+boundary[numit]+' boundary',$
                         /informational
                       message,'during bisection stage',/informational
                       done=2
                   END 

                   ;;
                   ;; stopping criterion: lower and upper value
                   ;; very close to each other and chi varies by
                   ;; a lot --> this indicates discontinuous chi2 valley
                   ;; 
                   IF (abs(aold-anew)/aold LE 1D-5) THEN BEGIN 
                       IF (debug EQ 2) THEN print 
                       message,'Possible discontinuous chi2 valley',$
                         /informational
                       done=-1 ;; i.e., almost o.k.
                   ENDIF 

                   ;;
                   ;; stopping criterion: wrong convergence
                   ;;
                   IF (aold EQ anew) THEN BEGIN 
                       print,'WARNING: aold eq anew in fiterror, 1'
                       print,'ABORTING'
                       anew=!values.f_nan
                       done=4
                   ENDIF 
               END  
           END  
           
           ;;
           ;; Return the error bound
           ;;
           remval=anew
           remchi=chi2new
           IF (done EQ 3) THEN BEGIN 
               remval=!values.f_nan
               remchi=!values.f_nan
           ENDIF 

           IF (numit EQ 0) THEN BEGIN 
               error[i].min=remval
               error[i].mininfo=done
           ENDIF ELSE BEGIN 
               error[i].max=remval
               error[i].maxinfo=done
           ENDELSE 
           chierr[numit,i]=remchi

           IF (debug GE 3) THEN BEGIN 
               IF (done EQ 1) THEN print,'new boundary ',anew
           ENDIF 
       
           ;;
           ;; Change limits for the next run through the loop
           ;;
           startp=pbest
           astart=pbest[i].value+uncert[i]
           ;; catch starting values outside allowed range
           IF (astart GT pbest[i].limits[1]) THEN BEGIN 
               uu=uncert[i]/3.
               WHILE (astart GT pbest[i].limits[1]) DO BEGIN 
                   astart=pbest[i].value+uu
                   uu=uu/3.
               ENDWHILE 
           ENDIF 
       END    
   END 

   IF (debug EQ 2) THEN print

   return,error
END  
