;+
; NAME:
;	FUNCT_FIT
; PURPOSE:
;	Non-linear least squares fit to a function of an
;	arbitrary number of parameters.
;	Function may be any non-linear function where
;	the partial derivatives are known or can be approximated.
; CATEGORY:
;	Curve Fitting
; CALLING SEQUENCE:
;	YFIT = FUNCT_FIT(X,Y,W,A,SIGMAA,FUNCT=FUNCT)
; INPUTS:
;	X = Row vector of independent variables.
;	Y = Row vector of dependent variable, same length as x.
;	A = Vector of nterms length containing the initial estimate
;		for each parameter.  If A is double precision, calculations
;		are performed in double precision, otherwise in single prec.
; OPTIONAL INPUT PARAMETERS:
; OUTPUTS:
;	A = Vector of parameters containing fit.
;	Function result = YFIT = Vector of calculated
;		values.
; OPTIONAL OUTPUT PARAMETERS:
;	Sigmaa = Vector of standard deviations for parameters
; KEYWORDS:
;       goodness(out) = goodnesss of fit = 1 - igamma(nfree/2,chisqr/2)
;	weights(in)  = row vector of weights, same length as x and y.
;	              For no weighting
;		      w(i) = 1., instrumental weighting w(i) = 1./y(i), etc.
;       funct(in) =  function to be fit. If not included, then the 
;                    current function in the library version of FUNCT will 
;                    be used.
;       stepfac (in) = fractional stepsize for numerical differencing
;       fixp (in)    = logical vector identifying which parameters to
;                      keep fixed (e.g. fixp=[1,2] means keep parameters 1 and 2 fixed)
;       corr (in)  = correlation matrix specifying actual links between parameters
;                (e.g. corr(3,2)=alpha implies a(3)=alpha*a(2) and a(3) will be
;                fixed. 
;       con (in)   = linear term to be added to correlation matrix
;       fxrange (in) = range to limit fit
;       chi2 (out) = chi squared of fit
;       nfree (out) = no. of free parameters
;       niter (out) = no. of iterations
;       extra (out) = extra optional variable in which user can return 
;                     miscellaneous information.
;       ss (in)     = indicies to include in fit
;       status      = 1/0 converged/failed
; PROCEDURE:
;	Copied from "CURFIT", least squares fit to a non-linear
;	function, pages 237-239, Bevington, Data Reduction and Error
;	Analysis for the Physical Sciences.
; MODIFICATION HISTORY:
;	Written, DMS, RSI, September, 1982.
;       Modified by DMZ, Applied Research Corp
;       Modified by DMZ, Aug 1987 to allow parameter fixing
;       Modified by DMZ, Oct 1987 to allow parameter linking     
;       Converted to version 2 - DMZ (ARC) April, 1992
;       Added CHISQR, WEIGHTS, and FXRANGE - Zarro (ARC) Oct'93
;-

function funct_fit,x,y,a,sigmaa,funct=funct,fixp=fixp,niter=iter,nfree=nfree,$
         chi2=chi2,stepfac=stepfac,corr=corr,con=con,fxrange=fxrange,$
         extra=extra,weights=weights,goodness=goodness,verbose=verbose,ss=ss,$
         status=status,param=param,max_iter=max_iter

        on_error,1
        status=0
        if datatype(funct) ne 'STR' then begin
         message,'Enter function name',/cont
         return,0
        endif

;-- weights

        if n_elements(weights) eq 0 then weights=replicate(1.d,n_elements(y))

;-- stepsize for derivatives

         if not exist(max_iter) then max_iter=20
;        if stepfac le 0. then message,/info,'pde will be computed analytically'

;-- ensure that matrix operations work right

        xf=double(reform(x)) & yf=double(reform(y)) 
        wf=double(reform(weights))
        a=double(reform(a))
	nterms = n_elements(a)  	;# of params.
        sigmaa=dblarr(nterms)           ;sigma errors

;-- indicies to fit

        if n_elements(ss) ne 0 then begin
         new_ss=ss(uniq(ss,sort(ss)))
         if n_elements(new_ss) lt nterms then begin
          message,'Insufficient or no overlapping data',/contin
          return,0
         endif
         xf=xf(new_ss) & yf=yf(new_ss) & wf=wf(new_ss)
        endif
         
;-- range to fit
    
        if n_elements(fxrange) ne 0 then begin
         subs=where((xf ge min(fxrange)) and (xf le max(fxrange)),count)
         if count eq 0 then message,'no data to fit'
         xf=xf(subs) & yf=yf(subs) & wf=wf(subs)
        endif

;-- make monotonic

        o=sort(xf) 
        xf=xf(o) & yf=yf(o) & wf=wf(o)

        verbose=keyword_set(verbose)
        if keyword_set(verbose) then begin
         message,'fit range : ',/contin
         print,min(xf),max(xf)
        endif


;-- fixed parameters?

        if n_elements(fixp) eq 0 then fixp=-1
        vary=replicate(1.,nterms)
        if min(fixp) ne -1 then vary(fixp)=0

;-- linked parameters ?

        link=0
        if n_elements(con) eq 0 then con=fltarr(nterms)
        if n_elements(corr) ne 0 then begin
         diag=indgen(nterms)*(nterms+1) 
         links=where(corr ne 0,count)
         if count gt 0 then begin
          ij=get_ij(links,nterms)
          vary(ij(0))=0 
; if vary(ij(1)) ne 0 then vary(ij(1))=1
          if keyword_set(verbose) then begin
           message,'parameter'+string(ij(0))+' will be linked to ' + $
                   'parameter'+string(ij(1)),/contin
          endif
          corr(diag)=1
          temp=transpose(corr)
          temp(ij(0),ij(0))=0.
          link=1
         endif
        endif

;-- update fixed parameters

        fixp=where(vary eq 0,nfix)
        if nfix gt 0 then begin
         if keyword_set(verbose) then begin
          message,/contin,'following parameters will be kept fixed:'
          print,fixp
         endif
        endif

        cvary=where(vary eq 1,nvary)
	nfree = (n_elements(yf)<n_elements(xf))-nvary       ;degs of freedom

	if nfree lt 0 then begin
         message,'Not enough data points.',/contin
         return,0
        endif
        if nfree eq 0 then nfree=1  
	flambda=.001                  ;initial lambda
	diag=indgen(nvary)*(nvary+1)  ;subscripts of diagonal elements
        if link then a=a#temp+con     ;apply links
        btemp=a                       ;save initial values
        
        for iter = 1,max_iter do begin      ;iteration loop


;-- evaluate alpha and beta matricies.

         if ((iter mod 5) eq 0) and keyword_set(verbose) then $
          message,'working on iteration '+string(iter,'(i2)'),/contin

	 yfit=funct_val(xf,a,pder,funct=funct,$
                    stepfac=stepfac,fixp=fixp,corr=corr)

  	 beta = (yf-yfit)*wf # pder

	 alpha = transpose(pder) # (wf # (dblarr(nvary)+1.d0)*pder)

	 chisq1 = total(wf*(yf-yfit)^2)/nfree ;present chi squared.

;-- already a good fit?

;         if chisq1 lt total(abs(yf))/1.e7/nfree then begin
;          message,'not iterating since first guess is good',/contin
;          sigmaa=fltarr(nterms)
;          chi2=chisq1*nfree
;          return,funct_val(x,a,funct=funct,extra=extra)
;         endif


;-- invert modified curvature matrix to find new parameters.

         i=-1
	 repeat begin
                i=i+1
		c = sqrt(alpha(diag) # alpha(diag)) 
                bad=where(c eq 0.,cnt)
                if cnt gt 0 then begin
                 c(bad)=.001d
                endif
		array = alpha/c
		array(diag) = array(diag)*(1.d0+flambda)
		array = invert(array)
		b = a(cvary)+ array/c # transpose(beta)  ;new params
                btemp(cvary)=b
                if link then btemp=btemp#temp+con      ;update links
		yfit=funct_val(xf,btemp,funct=funct)
		chisqr = total(wf*(yf-yfit)^2)/nfree     ;new chisqr
		flambda = flambda*10.                    ;assume fit got worse
         endrep until (chisqr le chisq1) or (i gt 100)

         if (i gt 100) then message,'iteration problems',/contin

;-- have all parameters stopped changing?

         if keyword_set(param) then begin
          ok=where(a ne 0,cnt)
          if cnt gt 0 then begin
           pdiff=abs((btemp(ok)-a(ok))/a(ok))
           conv=where(pdiff le .001,count)
           if count eq cnt then begin
            if verbose then message,'parameter iterations converged',/cont
            a=btemp
            status=1
            goto,done
           endif
          endif  
         endif

;-- has chi^2 stopped changing?

         cdiff=abs((chisq1-chisqr)/chisq1)
	 if cdiff le .001 then begin
          if verbose then message,'CHI^2 converged',/cont
          a=btemp
          status=1
          goto,done 
         endif

         a=btemp
         if  (flambda gt 1.d-40) then flambda= flambda/100.             ;decrease flambda by factor of 10

        endfor			;iteration loop

;	message,'did not converge in '+num2str(max_iter)+' iterations',/contin
        status=0
done:	
        st_dev = sqrt((array(diag)/alpha(diag)) > 0.) ;return sigma's
        sigmaa(cvary)=st_dev
        if link then sigmaa=sigmaa#abs(temp)
        if total(wf) eq n_elements(wf) then sigmaa=sigmaa*sqrt(chisqr)
        chi2=chisqr*nfree
;        goodness=(1.d)-igamma(nfree/2.,chi2/2.)/gamma(nfree/2.)

        yfit=funct_val(x,a,funct=funct,extra=extra)

        if keyword_set(verbose) then begin
         print,'- Chisqr   = ',chisqr
;         print,'- Goodness = ',goodness
        endif

	return,yfit		;return result
        end
                               
