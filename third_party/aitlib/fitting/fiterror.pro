FUNCTION fiterror, x, y, ww, apar, sigmaa,chi2=cchi2, $
                   bounds=bounds, delchi=delchi,toldel=toldel, $
                   debug=debug,intpar=intpar,maxtry=maxtry,_extra=extra
;+
; NAME:
;        fiterror
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
;         result=fiterror(x, y, ww, apar, sigmaa,chi2=cchi2, $
;                   bounds=bounds, delchi=delchi,toldel=toldel, $
;                   debug=debug,intpar=intpar,...)
;
;
; 
; INPUTS:
;          similar to jwcurvefit, see the documentation of jwcurvefit
;          for an exhaustive explanation.
;          The input-parameter apar is the best-fit vector as returned
;          from jwcurvefit, sigmaa is the "uncertainty" (i.e. the
;          diagonal elements of the Hessian matrix) as returned from
;          jwcurvefit.
;
; KEYWORD PARAMETERS:
;           chi2= the (reduced) chi^2 value of the best fit 
;                 as returned from jwcurvefit
;           debug= return tons of debugging information if set.
;           intpar= array containing the indexes of all interesting
;                 parameters, i.e., those for which the uncertainty
;                 is to be computed (note: although the word
;                 interesting is used here, this is not to be confused
;                 with the notion of "interesting parameters" in chi^2
;                 minimization)
;           delchi= delta chi^2 to be used for the determination of
;                 the uncertainty. default: 1, corresponding to 1
;                 sigma errors. Use 2.71 for 90% uncertainty
;                 (in general, delchi=chisqr_dvf(1-prob,1) where
;                 prob is the probability that the n dimensional
;                 parameter space spanned by the uncertainties
;                 contains the real value)
;           maxtry= maximum number of invocations of jwcurvefit in the
;                 determination of ONE error (used to determine
;                 non-convergence).
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
;          Version 1.0, 1999.10.21, Joern Wilms
;             (wilms@astro.uni-tuebingen.de), based on previous work by
;             JW and input from Mike Nowak
;             (mnowak@rocinante.colorado.edu). 
;          CVS Version 1.4, 2001.02.01, Joern Wilms
;             corrected bug occuring when trial starting value was
;             outside the bounds
;          CVS Version 1.5, 2001.10.07, Joern Wilms
;             corrected bug resulting in the code to loop (logical mistake)
;-
   
   ;; 
   ;; Save parameters
   ;;
   w=ww
   a=apar
   chi2=cchi2
   
   ;; no delchi given; use 1sigma error
   IF (n_elements(delchi) EQ 0) THEN delchi=1.
   
   ;; no bounds given --> bounds go from +/- infinity
   IF (n_elements(bounds) EQ 0) THEN BEGIN 
       bounds=fltarr(2,n_elements(a))
       bounds(0,*)=-1E30
       bounds(1,*)=+1E30
   ENDIF 
   
   ;; ...save best fit value
   bestfit=a
   savbounds=bounds
   savsig=0.5*abs(sigmaa)
   
   ;; ...number of frozen parameters
   dummy=where(bounds(0,*) EQ bounds(1,*),numfroz)

   ;; ...degrees of freedom
   dofhere=n_elements(y)-n_elements(a)+numfroz
   
   ;; list of interesting parameters
   IF (n_elements(intpar) EQ 0) THEN intpar=indgen(n_elements(a))
   
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
   ;; delchi is the chi^2 change we're looking for, usually 2.706 for 90%
   ;; need to multiply the reduced chi2 with dof to get the real chi2
   ;;
   chimin=chi2*dofhere
   chimax=chimin+delchi
   IF (keyword_set(debug)) THEN BEGIN 
       print,'minimum chi2 :', chimin
       print,'searched chi2:',chimax
   ENDIF 
       
   nparm=n_elements(a)
   ans = fltarr(2,nparm)

   FOR ii=0,n_elements(intpar)-1 DO BEGIN 
       i=intpar[ii]
       ;IF (keyword_set(debug)) THEN BEGIN
       ;    print,'SEARCHING parameter ',i
       ;    print,'  starting at ',bestfit[i],chimin
       ;    print,'  estimate    ',savsig[i]
       ;ENDIF 
       
       ;;
       ;; search two times, one for the lower error, one for the upper
       ;;
       
       lowbounds=savbounds[0,*]
       highbounds=bestfit
       astart=bestfit-savsig
       ;; catch starting values outside allowed range
       ndx=where(astart LT lowbounds)
       IF (ndx[0] NE -1) THEN BEGIN 
         astart(ndx)=(lowbounds[ndx]+highbounds[ndx])/2.
       ENDIF 
       
       FOR numit=0,1 DO BEGIN 
           a = bestfit
           ;;
           ;; do a secant method to find parameter value where chi^2 is
           ;; larger than chi^2min+delchi in the range lowbounds-highbounds
           ;;
           ;; to avoid oscillations: when two parameters bracketing the
           ;; chi^2min+delchi are found: use bisection
           ;; 
           aold=bestfit[i]
           chi2old=chimin
           anew=astart[i] ;; starting value
           
           numcall=0
           done=0
           WHILE (done EQ 0) DO BEGIN 
               a = bestfit ;; starting parameters are best fit parameters
               a[i]=anew
               bounds=savbounds
               bounds[0:1,i] = anew ;; freeze stepped parameter
               ;;
               ;; new fit
               ;;
               imfit = jwcurvefit(x,y,w,a,chi2=chi2,bounds=bounds,dof=dof, $
                                  _extra=extra)
               numcall=numcall+1
               chi2new=chi2*dof ;;..already includes the extra 1 dof less...
               
               IF (chi2 LT 0.) THEN BEGIN 
                   boundary=[' lower ',' upper ']
                   message,'Aborted for parameter '+string(i),/informational
                   message,'NaN reached at'+boundary[numit]+'boundary',$
                     /informational
                   done=3
               END 
               
               IF (numcall EQ maxtry) THEN BEGIN 
                   boundary=[' lower ',' upper ']
                   message,'Aborted for parameter '+string(i),/informational
                   message,'maximum number of calls reached at'+boundary[numit]+'boundary',$
                     /informational
                   message,'during secant stage',/informational
                   done=3
               END 
               
               IF (keyword_set(debug)) THEN BEGIN 
                   print,'  anew, chi2new, chimax',anew,chi2new,chimax
               END 

               ;;
               ;; stopping criterion: chi2 is about chimax
               ;;
               IF (abs(chi2new-chimax)/chimax LT toldel) THEN done=1
                      
               ;;
               ;; stop when interval is found (then do bisection)
               ;;
               IF (done NE 1) THEN BEGIN 
                   IF ((chi2old-chimax)*(chi2new-chimax) LT 0.) THEN BEGIN 
                       done=2
                   END 
               END 

               ;; 
               ;; No stopping condition -> next step
               ;;
               IF (done EQ 0) THEN BEGIN 
                   ;;
                   ;; linear extrapolation to find next parameter
                   ;;
                   aa=(chimax-chi2old)/(chi2new-chi2old)*(anew-aold)+aold
               
                   ;; Remember old a for next step, keep new a within 
                   ;; lower bound and best fit value 
                   aold=anew
                   chi2old=chi2new

                   anew=aa
                   IF (anew LT lowbounds[i]) THEN anew=lowbounds[i]
                   IF (anew GT highbounds[i]) THEN anew=highbounds[i]
           
                   ;;
                   ;; If we've evaluated at the hard bounds and chi2 value
                   ;; there is smaller than the desired value, return lower
                   ;; bounds as lower error margin
                   ;;
                   IF ((aold EQ savbounds[0,i]) AND (chi2old LT chimax)) THEN BEGIN 
                       anew=aold
                       done=1
                       print,'WARNING STILL TO BE DONE !!!!!!!!!'
                   ENDIF 
               ENDIF 
           ENDWHILE 

           IF (keyword_set(debug)) THEN BEGIN 
               IF (done EQ 1) THEN print,'bound found at ',aold
               IF (done EQ 2) THEN BEGIN 
                   print,'bracketing: ',aold,chi2old,chimax
                   print,'            ',anew,chi2new
               ENDIF 
           ENDIF 
           ;;
           ;; Search exact value by bisection 
           ;;
           IF (done EQ 2) THEN BEGIN 
               IF (keyword_set(debug)) THEN BEGIN 
                   print,'range found'
                   print,'  new  ',chi2new,anew
                   print,'  goal ',chimax
                   print,'  old  ',chi2old,aold
               ENDIF 

               done=0
               WHILE (done EQ 0) DO BEGIN 
                   amid=(anew+aold)/2.
                   a = bestfit ;; starting parameters are best fit parameters
                   a[i]=amid
                   bounds=savbounds
                   bounds[0:1,i] = amid ;; freeze stepped parameter
                   ;;
                   ;; new fit
                   ;;
                   imfit = jwcurvefit(x,y,w,a,chi2=chi2,bounds=bounds, $
                                      dof=dof,_extra=extra)
                   numcall=numcall+1
                   chi2mid=chi2*dof

                   IF ((chi2old-chimax)*(chi2mid-chimax) LT 0.) THEN BEGIN 
                       anew=amid
                       chi2new=chi2mid
                   END ELSE BEGIN 
                       aold=amid
                       chi2old=chi2mid
                   END 
                   IF (keyword_set(debug)) THEN BEGIN 
                       print,'New Range for parameter '+strtrim(i,2)+': '
                       print,'   ',chi2new,string(format='(E22.15)',anew)
                       print,'   ',chimax
                       print,'   ',chi2old,string(format='(E22.15)',aold)
                   END 
                   ;;
                   ;; stopping criterion: chi2 is about chimax
                   ;;
                   IF (abs(chi2old-chimax)/chimax LT toldel) THEN done=1
                   
                   ;; Stopping criterion: max number of curvefit calls reached
                   IF (numcall EQ maxtry) THEN BEGIN 
                       boundary=[' lower ',' upper ']
                       message,'Aborted for parameter '+string(i),/informational
                       message,'maximum number of calls reached at'+boundary[numit]+'boundary',$
                         /informational
                       message,'during bisection stage',/informational
                       done=2
                   END 

                   ;;
                   ;; stopping criterion: wrong convergence
                   ;;
                   IF (aold EQ anew) THEN BEGIN 
                       print,'WARNING: aold eq anew in fiterror, 1'
                       print,'ABORTING'
                       anew=!values.f_nan
                       done=-1
                   ENDIF 
               END  
           END  
           
           ;;
           ;; Return low value
           ;;
           IF (done EQ 3) THEN BEGIN 
               ans[numit,i]=!values.f_nan
           END ELSE BEGIN 
               ans(numit,i)=anew ;; remember new lower boundary
           END
       
           IF (keyword_set(debug)) THEN BEGIN 
               IF (done EQ 1) THEN BEGIN 
                   print,'new boundary ',anew
               ENDIF 
           ENDIF 
       
           ;;
           ;; Change to upper bounds for the next run through the loop
           ;; (NOT using result from lower bound!!!)
           ;;
           lowbounds=bestfit
           highbounds=savbounds[1,*]
           astart=bestfit+savsig
           ;; catch starting values outside allowed range
           ndx=where(astart GT highbounds)
           IF (ndx[0] NE -1) THEN BEGIN 
             astart(ndx)=(lowbounds(ndx)+highbounds(ndx))/2.
           ENDIF 
       END    
   END 
   bounds=savbounds

   return,ans
END  
