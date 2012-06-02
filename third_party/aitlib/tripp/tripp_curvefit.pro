FUNCTION TRIPP_CURVEFIT, x, y, w, a, sigmaa, Function_Name = Function_Name, $
                        itmax=itmax, iter=iter, tol=tol, chi2=chi2, $
                        noderivative=noderivative, maxchange=maxch, $
                        bounds=bounds,dof=dof,_extra=extra
; Copyright (c) 1988-1995, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;       TRIPP_CURVEFIT
;
; PURPOSE:
;       Non-linear least squares fit to a function of an arbitrary 
;       number of parameters.  The function may be any non-linear 
;       function.  If available, partial derivatives can be calculated by 
;       the user function, else this routine will estimate partial derivatives
;       with a forward difference approximation.
;
; CATEGORY:
;       E2 - Curve and Surface Fitting.
;
; CALLING SEQUENCE:
;       Result = TRIPP_CURVEFIT(X, Y, W, A, SIGMAA, FUNCTION_NAME = name, $
;                         ITMAX=ITMAX, ITER=ITER, TOL=TOL, /NODERIVATIVE)
;
; INPUTS:
;       X:  A row vector of independent variables.  This routine does
;		not manipulate or use values in X, it simply passes X
;		to the user-written function.
;
;       Y:  A row vector containing the dependent variable.
;
;       W:  A row vector of weights, the same length as Y.
;               For no weighting,
;               w(i) = 1.0.
;               For instrumental weighting,
;               w(i) = 1.0/y(i), etc.
;            comment jw: for REAL Chi^2 values, set w(i)=1./sigma(i)^2
;                                                       =1./variance(i)
;
;
;       A:  A vector, with as many elements as the number of terms, that 
;           contains the initial estimate for each parameter.  If A is double-
;           precision, calculations are performed in double precision, 
;           otherwise they are performed in single precision.
;
; KEYWORDS:
;       FUNCTION_NAME:  The name of the function (actually, a procedure) to 
;       fit.  If omitted, "FUNCT" is used. The procedure must be written as
;       described under RESTRICTIONS, below.
;
;       ITMAX:  Maximum number of iterations. Default = 20.
;       ITER:   The actual number of iterations which were performed
;       TOL:    The convergence tolerance. The routine returns when the
;               relative decrease in chi-squared is less than TOL in an 
;               interation. Default = 1.e-3.
;       CHI2:   The value of chi-squared on exit
;       NODERIVATIVE:   If this keyword is set then the user procedure will not
;               be requested to provide partial derivatives. The partial
;               derivatives will be estimated in CURVEFIT using forward
;               differences. If analytical derivatives are available they
;               should always be used.
;       BOUNDS: 2D-Array providing lower and upper bounds for the
;               parameters. The fitting algorithm will not use any
;               parameters outside the bounds.
;
; OUTPUTS:
;       Returns a vector of calculated values.
;       A:  A vector of parameters containing fit.
;
; OPTIONAL OUTPUT PARAMETERS:
;       Sigmaa:  A vector of standard deviations for the parameters in
;                A. (JW: DO NOT USE AS VALUES ARE COMPLETELY OFF!!!)
;       dof   :  number of degrees of freedom of fit
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       The function to be fit must be defined and called FUNCT,
;       unless the FUNCTION_NAME keyword is supplied.  This function,
;       (actually written as a procedure) must accept values of
;       X (the independent variable), and A (the fitted function's
;       parameter values), and return F (the function's value at
;       X), and PDER (a 2D array of partial derivatives).
;       For an example, see FUNCT in the IDL User's Libaray.
;       A call to FUNCT is entered as:
;       FUNCT, X, A, F, PDER
; where:
;       X = Variable passed into CURVEFIT.  It is the job of the user-written
;		function to interpret this variable.
;       A = Vector of NTERMS function parameters, input.
;       F = Vector of NPOINT values of function, y(i) = funct(x), output.
;       PDER = Array, (NPOINT, NTERMS), of partial derivatives of funct.
;               PDER(I,J) = Derivative of function at ith point with
;               respect to jth parameter.  Optional output parameter.
;               PDER should not be calculated if the parameter is not
;               supplied in call. If the /NODERIVATIVE keyword is set in the
;               call to CURVEFIT then the user routine will never need to
;               calculate PDER.
;
; PROCEDURE:
;       Copied from "CURFIT", least squares fit to a non-linear
;       function, pages 237-239, Bevington, Data Reduction and Error
;       Analysis for the Physical Sciences.
;
;       "This method is the Gradient-expansion algorithm which
;       combines the best features of the gradient search with
;       the method of linearizing the fitting function."
;
;       Iterations are performed until the chi square changes by
;       only TOL or until ITMAX iterations have been performed.
;
;       The initial guess of the parameter values should be
;       as close to the actual values as possible or the solution
;       may not converge.
;
; EXAMPLE:  Fit a function of the form f(x) = a * exp(b*x) + c to
;	sample pairs contained in x and y.
;	In this example, a=a(0), b=a(1) and c=a(2).
;	The partials are easily computed symbolicaly:
;		df/da = exp(b*x), df/db = a * x * exp(b*x), and df/dc = 1.0
;
;		Here is the user-written procedure to return F(x) and
;		the partials, given x:
;       pro gfunct, x, a, f, pder	; Function + partials
;	  bx = exp(a(1) * x)
;         f= a(0) * bx + a(2)		;Evaluate the function
;         if N_PARAMS() ge 4 then $	;Return partials?
;		pder= [[bx], [a(0) * x * bx], [replicate(1.0, N_ELEMENTS(y))]]
;       end
;
;         x=findgen(10)			;Define indep & dep variables.
;         y=[12.0, 11.0,10.2,9.4,8.7,8.1,7.5,6.9,6.5,6.1]
;         w=1.0/y			;Weights
;         a=[10.0,-0.1,2.0]		;Initial guess
;         yfit=curvefit(x,y,w,a,sigmaa,function_name='gfunct')
;	  PRINT, '% TRIPP_CURVEFIT Function parameters: ',a
;         PRINT, '% TRIPP_CURVEFIT                    : '+yfit
;       end
;
; MODIFICATION HISTORY:
;       Written, DMS, RSI, September, 1982.
;       Does not iterate if the first guess is good.  DMS, Oct, 1990.
;       Added CALL_PROCEDURE to make the function's name a parameter.
;              (Nov 1990)
;       12/14/92 - modified to reflect the changes in the 1991
;            edition of Bevington (eq. II-27) (jiy-suggested by CreaSo)
;       Mark Rivers, U of Chicago, Feb. 12, 1995
;           - Added following keywords: ITMAX, ITER, TOL, CHI2, NODERIVATIVE
;             These make the routine much more generally useful.
;           - Removed Oct. 1990 modification so the routine does one iteration
;             even if first guess is good. Required to get meaningful output
;             for errors. 
;           - Added forward difference derivative calculations required for 
;             NODERIVATIVE keyword.
;           - Fixed a bug: PDER was passed to user's procedure on first call, 
;             but was not defined. Thus, user's procedure might not calculate
;             it, but the result was then used.
;       Joern Wilms, Univ. Tuebingen, Institute for Astronomy, 1997/1998:
;           - Added bounds parameter
;           - Added routines to enable the freezing of individual
;             parameters (set low and high bounds to same value) 
;             (necessary for the computation of meaningful errors, see
;             subroutine fiterror)
;           - made more stable by checking for Nan's (presence of 
;             which could result in infinite loops).
;           - return degrees of freedom to enable us to compute
;             meaningful chi^2 instead of reduced chi2 only.
;           - added _extra message passing to the fit function
;           - better bounds handling (could lead to infinite loops)   
;         Stefan Dreizler, Univ. Tuebingen, Institute for Astronomy, 1999
;           - idl.4 compatibility for TRIPP application at Calar Alto
;         Sonja. L.-Schuh, Univ. Tuebingen, Institute for Astronomy, 2001
;           - emergency stop when hitting hard bounds
;         Joern Wilms, Univ. Tuebingen, Institute for Astronomy,
;             03/2001:
;           - SUPPORT DISCONTINUED, J.W. DECLINES ALL RESPONSIBILITY
;             FOR POSSIBLE ERRORS IN THIS ROUTINE! PLEASE USE
;             JWCURVEFIT OR MPFIT INSTEAD.          
;
;-

;       on_error,2              ;Return to caller if error

   ;; Check for existence of frozen parameters
   IF (n_elements(bounds) NE 0) THEN BEGIN 
       froz=where(bounds(0,*) EQ bounds(1,*))
       IF (froz(0) NE -1) THEN BEGIN 
           ;; first save parameters
           savbounds=bounds
           sava=a
           reta = a
           savpar=n_elements(a)
           frpar=bounds(0,froz) ;; remember frozen parameters
           ;; Remove frozen parameters from parameter list
           notfroz=where(bounds(0,*) NE bounds(1,*))
           a=a(notfroz) ;; shrink parameters to non-frozen parameter list
           bounds=bounds(0:1,notfroz)
           frozen=1
       ENDIF 
   ENDIF 
   
   ;; ...do we have extra keywords to give to the fit-function?
   extrakey=n_elements(extra) NE 0
   
   ;; ...Name of function to fit
   IF n_elements(function_name) LE 0 THEN function_name = "FUNCT"
   ;; ...Convergence tolerance
   IF n_elements(tol) EQ 0 THEN tol = 1.e-3
   ;; ...Maximum # iterations
   IF n_elements(itmax) EQ 0 THEN itmax = 20
   
   type = size(a)
   type = type(type(0)+1)
   double = type EQ 5
   ;; ...Make params floating
   IF (type NE 4) AND (type NE 5) THEN a = float(a) 

   ;; If we will be estimating partial derivatives then compute machine
   ;; precision

   IF keyword_set(NODERIVATIVE) THEN BEGIN
       res = nr_machar(DOUBLE=double)
       eps = sqrt(res.eps)
   ENDIF 

   nterms = n_elements(a)       ; # of parameters
   dof = n_elements(y) - nterms ; Degrees of freedom
   IF dof LE 0 THEN message, 'Curvefit - not enough data points.'
   flambda = 0.001              ;Initial lambda
   IF double THEN flambda=0.001D0
   diag = lindgen(nterms)*(nterms+1) ; Subscripts of diagonal elements

   ;;  Define the partial derivative array

   IF double THEN BEGIN 
       pder = dblarr(n_elements(y), nterms)
   END ELSE BEGIN 
       pder = fltarr(n_elements(y), nterms)
   END 

   FOR iter = 1, itmax DO BEGIN ; Iteration loop

       ;; Evaluate alpha and beta matricies.
       IF keyword_set(NODERIVATIVE) THEN BEGIN
           ;;           ;; Evaluate function and estimate partial derivatives
           ;;
           ;; Re-insert frozen parameters
           IF (keyword_set(frozen)) THEN BEGIN 
               sava(notfroz)=a
               sava(froz)=frpar
           END ELSE BEGIN 
               sava=a
           END 
           IF (extrakey) THEN BEGIN 
               call_procedure,function_name,x,sava,yfit,_extra=extra
           END ELSE BEGIN 
               call_procedure,function_name,x,sava,yfit
           END 

           FOR term=0, nterms-1 DO BEGIN 
               p = a            ; Copy current parameters
               ;; Increment size for forward difference derivative
               inc = eps * abs(p(term))    
               IF (inc eq 0.) THEN inc = eps
               p(term) = p(term) + inc
               IF (keyword_set(frozen)) THEN BEGIN 
                   sava(notfroz)=p
                   sava(froz)=frpar
               END ELSE BEGIN 
                   sava=p
               END 
               IF (extrakey) THEN BEGIN 
                   call_procedure,function_name,x,sava,yfit1,_extra=extra
               END ELSE BEGIN 
                   call_procedure,function_name,x,sava,yfit1
               END 
               pder(0,term) = (yfit1-yfit)/inc
           ENDFOR 
       ENDIF ELSE BEGIN
           ;; The user's procedure will return partial derivatives
           IF (keyword_set(frozen)) THEN BEGIN 
               sava(notfroz)=a
               sava(froz)=frpar
           END ELSE BEGIN 
               sava=a
           END 
           IF (extrakey) THEN BEGIN 
               call_procedure,function_name,x,sava,yfit,pder,_extra=extra
           END ELSE BEGIN 
               call_procedure,function_name,x,sava,yfit,pder
           END 
           IF (keyword_set(frozen)) THEN  pder=pder(*,notfroz)
       ENDELSE 
       beta = (y-yfit)*w # pder
       alpha = transpose(pder) # (w # (fltarr(nterms)+1)*pder)
       chisq1 = total(w*(y-yfit)^2.0)/dof ; Present chi squared.

       ;; If a good fit, no need to iterate
       ;;jw: this determination is not very meaningful...
       ;;jw, am not clear what should be done.
       all_done = chisq1 LT total(abs(y))/1e7/DOF

       ;;
       ;; Invert modified curvature matrix to find new parameters.
       ;;

       REPEAT BEGIN
           c = sqrt(alpha(diag) # alpha(diag))
           array = alpha/c

           array(diag) = array(diag)*(1.+flambda)              

           array = invert(array)
           ;;jw
           ;; Fabian Rothers trick for hard bounds
           ;;jw
           change=array/c # transpose(beta)
           IF (n_elements(bounds) GE 2*nterms) THEN BEGIN 
             FOR i=0,nterms-1 DO BEGIN 
               WHILE (((a(i)+change(i)) LE bounds(0,i)) OR $
                      (a(i)+change(i)) GT bounds(1,i)) DO BEGIN 
                 change(i)=change(i)*0.1
                 IF (change(i) EQ 0.) THEN BEGIN 
                   ;;
                   change(i)=(bounds(0,i)+bounds(1,i))/2.-a(i)
                   IF n_elements(emergencystop) EQ 0 THEN emergencystop=0
                   emergencystop=emergencystop+1
                   IF emergencystop GT itmax THEN BEGIN
                   message,'Resetting parameters due to hitting the hard bounds',/informational
                   message,'... check your results!',/informational
                   PRINT,'... parameter :',i,' current value: ',a(i)
                     MESSAGE,'Too many tries, curvefit aborted',/INFORMATIONAL
                     CHISQR = -1
                     GOTO, DONE
                   ENDIF
                 ENDIF 
               ENDWHILE 
             ENDFOR 
           ENDIF 
           b = a+change         ; New params

           ;; check for NaN values and abort if necessary
           problem=where(finite(b) EQ 0 OR finite(a) EQ 0)
           IF (problem(0) NE -1) THEN BEGIN 
               message,'Iteration results in NaN values',/informational
               message,'curvefit aborted',/informational
               chi2=-1.
               return,replicate(-1.,n_elements(x))
           ENDIF 

           IF (keyword_set(frozen)) THEN BEGIN 
               sava(notfroz)=b
               sava(froz)=frpar
           END ELSE BEGIN 
               sava=b
           END 
           IF (extrakey) THEN BEGIN 
               call_procedure,function_name,x,sava,yfit,_extra=extra
           END ELSE BEGIN 
               call_procedure,function_name,x,sava,yfit
           END 
           
           chisqr = total(w*(y-yfit)^2)/dof ; New chisqr

           IF all_done THEN GOTO, done

           flambda = flambda*10.

           
       ENDREP UNTIL chisqr LE chisq1 
       flambda = flambda/100.   ; Decrease flambda by factor of 100

       a=b                      ; Save new parameter estimate.
       
       ;;jw: should we also include an absolute criterion here?
       IF (((chisq1-chisqr)/chisq1) LE tol)  THEN BEGIN 
           GOTO,done            ; Finished?
       END 

   ENDFOR                       ;iteration loop

   message, 'Failed to converge', /INFORMATIONAL

   done:  sigmaa = sqrt(array(diag)/alpha(diag)) ; Return sigma's
   chi2 = chisqr                ; Return chi-squared
   
   ;; return best-fit parameters
   IF (keyword_set(frozen)) THEN BEGIN 
       bounds=savbounds
       sava(notfroz)=a
       sava(froz)=frpar
       a=sava
   ENDIF 
   return,yfit                  ;return result
END 


