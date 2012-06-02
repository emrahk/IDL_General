PRO mkgfunct, x, a, f, pder   ; Function + partials
   bx = exp( -.5d * ( (x-a(1))/a(2) )^2 )
   f= a(0) * bx +a(4)*x+a(5)*x^2+a(3)          ;Evaluate the function
;   if N_PARAMS() ge 4 then $    ;Return partials?
;     pder= [[bx],$
;            [( a(0)*(x-a(1)) * exp( -0.5d* ( (x-a(1))/a(2) )^2 ) ) /a(2)^2 ],$
;            [( a(0)*(x-a(1))^2 * exp(-0.5d*( (x-a(1))/a(2) )^2 ) ) /a(2)^3 ], $
;            [x],$
;            [x^2],$
;            [replicate(1.0, N_ELEMENTS(x))]]
END


FUNCTION mkgaussfit,xdata,ydata,weights,starters,sigmaa=sigmaa,chi2=chi2,$
                    error=error,result=result,chatty=chatty
   
   ;; set bounds for interresting parameters
   bounds=[[-1E30,1E30],$
           [starters[1]-300.,starters[1]+300.], $ ; Peak of gauss
           [1.,1E30], $         ; sigma of gauss
           [-1E30,1E30], $
           [-1E30,1E30], $
           [-1E30,1E30]]
   ;; do fit with mkgfunct as fit function
   fit=jwcurvefit(xdata,ydata,weights,starters,sigmaa,chi2=chi2,function_name ='mkgfunct', $
                  /noderivative,bounds=bounds)
   ;; the new resulting fit parameters are stored in starters
   ;; starters(1) is the center of the gauss peak
   ;; starters(2) is the sigma of the gauss peak

   result=starters
   IF (keyword_set(chatty)) THEN BEGIN 
       print,'% MKGAUSSFIT: Peak  '+string(result(1))
       print,'% MKGAUSSFIT: Sigma      '+string(format='(F13.9)',result(2))
   ENDIF 
   
   ;; calculate errors for the fit
   error=fiterror(xdata,ydata,weights,starters,sigmaa,chi2=chi2,toldel=1E-7, $
                  /noderivative,bounds=bounds,intpar=[1,2])
   
   ;; calculate total error 
   totalerr=1.
   
  
   return,fit
END





















