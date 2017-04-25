
pro voigt_funct,x,guess,fout,pder

   ; Used by curvefit.pro.  This routine computes the Voigt function and
   ; its partial derivatives.  Should not be called externally.
   ; See the comments in voigt.pro for the computation of the derivatives.

   common voigt_fit_private,npoints,nterms,npder,one_over_sqrt_pi,nofita,voigtp,nofitd,doppl

   on_error,2

   if nofitd NE 0 then guess(3) = doppl
   guess(3) = abs(guess(3))   ; doppler width is not allowed to be negative
   v = (x-guess(4))/guess(3)

   if nofita NE 0 then guess(2) = voigtp
   a = (guess(2)>0.)          ; a is not allowed to be negative
   guess(2) = a

   voigt,a,v,h,f
   fout = guess(0) - guess(1)*h
   if n_params() LE 3 then return ; need partials?

   if n_elements(pder) NE npder then pder = fltarr(npoints,nterms)
   B2 = guess(1)*2.0
   af_vh = a*f - v*h
   pder(*,0) = 1.0                                    ; dI/dC
   pder(*,1) = -h                                     ; dI/dB
   pder(*,2) = -B2*(a*h+v*f-one_over_sqrt_pi)  ; dI/da
   pder(*,3) = B2*(x-guess(4))*af_vh/(guess(3)^2)     ; dI/x_d
   pder(*,4) = B2*af_vh/guess(3)                      ; dI/dx0

end

function voigtfit,x,y,a,verbose=verbose,sigma=sigma,weight=w,plot=plot, $
                  derivative=derivative,emission=emission,guess=guess, $
                  vpguess=vpguess,doppguess=doppguess,quiet=quiet,chi2=chi2, $
                  goodfit=goodfit,nofitvp=nofitvp,nofitdopp=nofitdopp

;+
;NAME:
;     VOIGTFIT
;PURPOSE:
;     Fits a 5 parameter Voigt function to a vector, presumably representing
;     a spectral line):
;
;     y(x) = C - B * H(a,(x-x0)/x_D)
;
;CATEGORY:
;CALLING SEQUENCE:
;     fit = voigtfit(x,y,a,guess=guess)
;INPUTS:
;     x = vector of x values
;     y = vector of y values
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;     guess = vector of initial guesses (same format as a ... see output).  
;             Computed and returned in guess if not specified (see 
;             restrictions).
;     /plot = plot the fit over the data in the current window
;     /verbose = print diagnostics
;     /quiet = do print anything
;     sigma = returns with the standard deviations for each parameter
;     weight = vector with same dimension as x,y.  Gives the weights for
;              each point in the fit.  Default = uniform weighting.
;     /derivative = return the derivative, dI(x)/dx, in the vector "fit" rather
;                   than the fit to Voigt function
;     /emission = Assume and emission line when computing initial guess.  The
;                 default is to assume an absorption line.  This does not
;                 affect the fit, only the initial guess when one is not 
;                 supplied.
;     vpguess = initial guess for the damping paramter.  Only used if
;               voigtfit computes the initial guess.  Default=0.1
;     /nofitvp = do not fit to the voigt parameter ... use initial guess
;     doppguess = initial guess for the doppler width (x units).  Only used if
;                 voigtfit computes the initial guess.  Default=computed value.
;     /nofitdopp = do not fit to the doppler width ... use initial guess
;     goodfit = returns with a flag:  true = the fit was good, false = the
;               fit was bad.
;     chi2 = the chi**2 for the fit.  Assumes that the errors on y are sqrt(y)
;OUTPUTS:
;     a = vector of fit values:
;        a(0) = C   (continuum in y units)
;        a(1) = B   (line strength in y units)
;        a(2) = a   (damping parameter)
;        a(3) = x_D (doppler width in x units)
;        a(4) = x0  (x-value of line center)
;     fit = vector of computed values (same dimension as x and y)
;COMMON BLOCKS:
;     voigt_fit_private for internal use only
;SIDE EFFECTS:
;     o If /verbose is set, plots in the current window.
;RESTRICTIONS:
;     o If the initial guess is not supplied, it is computed under the 
;       assumption that the line is an absorption line, not an emission line,
;       unless /emission is set.
;     o If you call voigtfit repeatedly and both want voigtfit to compute a new
;       initial guess each time and return the guess in guess, you must reset
;       guess to 0 before each call.  If you don't, the guess for the first
;       dataset will be used repeatedly.
;EXAMPLES:
;     deriv1 = voigtfit(x,data1,guess=guess) ; guess returns with initial guess
;     deriv2 = voigtfit(x,data2,guess=guess) ; uses guess for data1
;     guess=0
;     deriv3 = voigtfit(x,data3,guess=guess) ; computes a new guess for data3
;PROCEDURE:
;     Calls voigt.pro to compute the Voigt function and derivatives.
;     Calls curvefit.pro to compute the fit.
;MODIFICATION HISTORY:
;     T. Metcalf  January, 1994
;-

   common voigt_fit_private,npoints,nterms,npder,one_over_sqrt_pi,nofita,voigtp,nofitd,doppl

   on_error,2

   if keyword_set(nofitvp) then nofita=1 else nofita=0
   if keyword_set(nofitdopp) then nofitd=1 else nofitd=0

   if n_elements(vpguess) NE 1 then vpguess=0.1
   one_over_sqrt_pi = 1.0d0/sqrt(!pi)
   nterms = 5L
   npoints = n_elements(x)
   npder = nterms*npoints
   if n_elements(y) NE npoints then $
      message,'x and y must have the same dimension'

   if n_elements(guess) NE nterms then begin
      if keyword_set(verbose) and NOT keyword_set(quiet) then begin
         if keyword_set(emission) then $
            message,/info,'Deriving initial guess ... assuming emission line' $
         else $
            message,/info,'Deriving initial guess ... assuming absorption line'
      endif
      miny = min(y,minplace)
      maxy = max(y,maxplace)
      guess = fltarr(nterms)
      if keyword_set(emission) then guess(0) = miny $  ; continuum
      else guess(0) = maxy 
      if n_elements(doppguess) NE 1 then begin
         ; Doppler width is half the half width (assumes a full spectral line)
         if keyword_set(emission) then $
            halfmax = where(y GT (miny+maxy)/2.0,nhalfmax) $
         else $
            halfmax = where(y LT (miny+maxy)/2.0,nhalfmax)
         if nhalfmax GE 1 then $
            guess(3) = 0.5*abs(x(halfmax(1))-x(halfmax(nhalfmax-2))) $
         else message,'Cant guess doppler width'
      endif else guess(3)=doppguess
      guess(2) = vpguess   ; damping parameter ... first guess hardwired (yuk)
      voigt,guess(2),0.,h0,f0
      if keyword_set(emission) then begin
         guess(1) = (guess(0)-maxy)/h0  ; strength of line
         guess(4) = x(maxplace)         ; line center 
      endif else begin
         guess(1) = (guess(0)-miny)/h0  ; strength of line
         guess(4) = x(minplace)         ; line center 
      endelse
   endif

   voigtp = guess(2)
   doppl = guess(3)
   if n_elements(w) NE npoints then w = fltarr(npoints)+1.0
   a = guess

   q=!quiet   ; Don't print the convergence failure messages
   if NOT keyword_set(verbose) then !quiet=1 

   fit = curvefit(x,y,w,a,sigma,function_name='voigt_funct')

   !quiet=q

   ; Check that we got a good fit
   ; Guess that errors are sqrt(y) to compute chi squared
   chi2 = total(w*(y-fit)^2/abs(y))
   chi_limit = chi_sqr(0.001,npoints-nterms)
   goodfit = chi2 LE chi_limit
   if (NOT goodfit) AND (NOT keyword_set(quiet)) then $
      message,/info,strcompress('Questionable fit '+string(chi2)+' > '+ $
                                string(chi_limit))

   if keyword_set(derivative) then begin
      v = (x-a(4))/a(3)
      voigt,a(2),v,h,f
      dIdx = -2.0*a(1)*(a(2)*f-v*h)/a(3) 
   endif

   if keyword_set(plot) then begin
      plot,x,y
      oplot,x,fit,thick=2
   endif
   if keyword_set(verbose) and NOT keyword_set(quiet) then begin
      print,chi2,chi_limit,format="('   Chi**2:',f9.2,' Limit:',f8.2)"
      print,a(0),guess(0),format="('Continuum:',f9.2,' from:',f9.2)"
      print,a(1),guess(1),format="(' Strength:',f9.2,' from:',f9.2)"
      print,a(2),guess(2),format="('Damping P:',f9.2,' from:',f9.2)"
      print,a(3),guess(3),format="('Doppler W:',f9.2,' from:',f9.2)"
      print,a(4),guess(4),format="('L. Center:',f9.2,' from:',f9.2)"
   endif

   if keyword_set(derivative) then return,dIdx else return,fit

end
