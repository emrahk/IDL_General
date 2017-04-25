
function image_decon_func, imagein, gradient

   common decon_func_common1, data, fpsf, cfpsf, sigma2, nx, ny, cdouble, $
                              uselog,quiet,mask, sigma, psf, useautocorr, $
                              usepsfcorr, lfactor, ntotal, usepoisson, $
                              flux, btot, beta, fbeta

   if keyword_set(uselog) then image = exp(imagein) else image = imagein
   fimage = fft(image,+1,double=cdouble)
   new = fftconvol(fimage,fpsf)
   residual = new-data
   ;if keyword_set(mask) then $
   if mask[0] GE 0 then residual[mask] = 0.0

   rs = residual/sigma
   r2s2 = rs^2
   if keyword_set(usepoisson) then $
      gof = -2.0*total(data - new + data*alog(new/data)) $
   else $
      gof = total(r2s2)

   ; MEM term

   ptotal = total(image)
   ;lambda = 2.0/ptotal
   ; The constant in front of lambda is about the reduced
   ; chi^2 contribution from the entropy term
   ; So if the entropy term is to contribute
   ; 0.1 to the reduced chi^2, then the constant
   ; is about 0.1

   lambda = lfactor*1.0*ntotal/(ptotal*alog(ntotal))
   mimage = alog((image>(max(image)/1.e32))/(ptotal))

   gof = gof - lambda*total(image*mimage)

   ; Balanced resdiduals term

   if flux then begin
      gof = gof + total(abs(residual*beta))
   endif

   if NOT quiet then begin
      tvscl,rs,0,ny
      xyouts,/device,align=0.5,nx/2,1.0*ny,'Residual/sigma ' + $
         string(min(rs))+' '+string(max(rs))
      tvscl,alog(image>.1),2*nx,ny
      xyouts,/device,align=0.5,(5*nx)/2,1.0*ny,'log Image ' + $
         string(min(image))+' '+string(max(image))
   endif

   if keyword_set(usepsfcorr) then begin
      ; correlation between PSF and residual should be flat so apply an
      ; entrpy term to force this
      ;icorr = abs(fft(cfpsf*fimage,-1,double=cdouble))
      ;icorr = abs(fft(cfpsf*fft(rs,+1,double=cdouble),-1,double=cdouble))^2
      icorr=abs(fft(usepsfcorr*fft(rs,+1,double=cdouble),-1,double=cdouble))^2
      ;fr2s2 = fft(r2s2,+1,double=cdouble)
      ;icorr = abs(fft(cfpsf*fr2s2,-1,double=cdouble))
      ictotal = total(icorr)
      clambda = lfactor*1.0*ntotal/(ictotal*alog(ntotal))
      ;clambda = lfactor*1.0*ntotal/(ictotal*alog(ntotal))
      ccorr = (icorr>(max(icorr)/1.e32))/(ictotal)
      mcorr = alog(ccorr)
      gof = gof - clambda*total(icorr*mcorr)
   endif

   if n_params() GE 2 then begin
      if keyword_set(usepoisson) then $
         r2s = 2.0*(1.-data/new) $
      else $
         r2s = 2.*residual/sigma2
      fr2s = fft(r2s,+1,double=cdouble)
      gradient = fftconvol(fr2s,fpsf)

      ; Code to test gradient calculation.  Normally
      ; commented out.  /double should be set for this!
      ;xsstest = [nx/2,nx/2+1,nx/2-1,nx/2-2,(2*nx)/3,(2*nx)/3,(1*nx)/3]
      ;ysstest = [ny/2,ny/2+1,ny/2-1,ny/2-2,(1*ny)/3,(2*ny)/3,(2*ny)/3]
      ;for itest = 0,n_elements(xsstest)-1 do begin
      ;   x = xsstest[itest]
      ;   y = ysstest[itest]
      ;   timage = image
      ;   delta = max(image)/1000.
      ;   timage[x,y] = timage[x,y] + delta
      ;   ftimage = fft(timage,+1,/double)
      ;   tnew = fftconvol(ftimage,fpsf)
      ;   tresidual = tnew-data
      ;   ;if keyword_set(mask) then $
      ;   if mask[0] GE 0 then tresidual[mask] = 0.0
      ;   if keyword_set(usepoisson) then $
      ;      gof = -2.0*total(data - new + data*alog(new/data)) $
      ;   else $
      ;      gof = total(residual^2/sigma2)
      ;   if keyword_set(usepoisson) then $
      ;      tgof = -2.0*total(data - tnew + data*alog(tnew/data)) $
      ;   else $
      ;      tgof = total(tresidual^2/sigma2)
      ;   gcalc = (tgof-gof)/delta
      ;   gtest = float(gradient[x,y])
      ;   print,gtest,gcalc,gcalc/gtest
      ;endfor
      ;stop

      if keyword_set(cdouble) then $
         gradient = double(gradient) $
      else $
         gradient = float(gradient)
      if keyword_set(usepsfcorr) then $  ; usepsfcorr term: approximate
         gradient = gradient - $
            clambda*(1.+mcorr)*float(fft(fft(2.0/sigma,+1,double=cdouble)*usepsfcorr,-1,double=cdouble))*sqrt(icorr)
      gradient = gradient - lambda*(1.+mimage)  ; MEM term
      if flux then begin
         ;  Balanced residual term
         signmat = fix(residual GT 0) - fix(residual LT 0)  ; sign function
         fbeta = fft(signmat*beta,+1,double=cdouble)
         gradient = gradient + fftconvol(fbeta,fpsf)
      endif
      if keyword_set(uselog) then gradient = image*gradient

      if NOT quiet then begin
         tvscl,gradient,nx,0
         tvscl,r2s,nx,ny
         xyouts,/device,align=0.5,1.5*nx,0,'Gradient ' + $
            string(min(gradient))+' '+string(max(gradient))
         xyouts,/device,align=0.5,1.5*nx,ny,'Residual/sigma^2 ' + $
            string(min(r2s))+' '+string(max(r2s))
      endif
   endif

   return, gof

end


;+

function image_deconvolve,datain,psfin,sigmain,guess=guess, $
                          maxiterations=maxiter,double=double, $
                          uselog=uselogin, positive=positive, $
                          quiet=quietin, mask=maskin, float=float, $
                          usepsfcorr=usepsfcorrin, $
                          useautocorr=useautocorrin, chi2limit=chi2limitin, $
                          memweight=memweight, usepoisson=usepoissonin, $
                          chi2aim=chi2aimin, fixmemweight=fixmemweight, $
                          flux=fluxin,fftguess=fftguess

;NAME:
;     IMAGE_DECONVOLVE
;PURPOSE:
;     Deconvolve a PSF from an image
;CATEGORY:
;CALLING SEQUENCE:
;     new_image = image_deconvolve(image,psf,sigma)
;INPUTS:
;     image = raw image
;     psf = PSF centered on floor(nx/2),floor(ny/2)
;     sigma = error estimate for image (must be positive and non-zero)
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;     guess = initial guess (default = image)
;     /fftguess = Use the direct FFT inversion as the initial guess.  The
;                 inversion is returned in teh guess keyword, overwriting
;                 the contents of guess.
;     maxiterations = maximum number of iterattions (def = 100)
;     /double = use double precision in the FFT's (DEFAULT)
;     /float = use single precision in the FFT's (faster but less robust)
;     /uselog = Iterate the log of the image to provide an absolute positivity
;               constraint.
;     /positive = Apply crude positivity constraint.  Can cause failure to 
;                 converge.  Ignored if /uselog is set.  If neither /positive
;                 not /uselog is set, then the deconvolved image is allowed to 
;                 go negative.
;     flux = Try to force flux to be conserved by adding a condition that 
;            the residuals are balanced (i.e. sum to zero).  The value of 
;            flux is the weight given to the condition, start at 1.0 and work
;            work your way up or down from there (bigger means more weight on
;            this condition).
;            There is no guarantee that the flux conservation will succeed.
;            Note that masked areas are allowed to float and are not included
;            in the flux calculation.
;     /quiet = Do not print diagnostics or plot intermediate images.
;     mask = index vector of pixels in image that should be NOT be included in the
;            GOF calculation.  If not set, all pixels are used.  Slows down the
;            calculation, so should not be used unless necessary.
;     /usepsfcorr = add a term to force the correlation of the residual and the
;                   PSF to be flat.  This is sometimes useful for avoiding
;                   overcorrections. 
;     chi2limit = limit for chi^2.  When this value is reached the iteration
;                 is terminated.
;     chi2aim = The value of chi^2 that the algorithm should aim for.  The
;               weight is dynamically adjusted to get chi^2 to this value.
;               there's no guarantee it will succeed, however.  Default = 1.0.
;     /usepoisson = Use poisson statistics instead of Gaussian statistics.
;                   In this case sigma isn't really used, but you have to 
;                   put in something reasonalbe to make the displays look
;                   right.  Also if /usepsfcorr is set, sigma is used in the
;                   gradient calculation even when /usepoisson is set.
;     memweight = Initial weight of the entropy terms.  Will be adjusted by
;                 the algorithm to make chi^2=chi2aim.  Default = 1.0.
;     /fixmemweight = Force memweight to reamain fixed at the value given by
;                     the memweight keyword.  Try setting this if the
;                     algorithm fails to converge.
;OUTPUTS:
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     The deconvolution is done with the FFT so the dimension of the input
;     data should be a power of two for speed.
;
;     The iteration is done on the log of the image to give a strict
;     positivity constraint.  Hence, if the data is anywhere equal to zero,
;     the zero values are changed to 1. 
;PROCEDURE:
;     Uses a simple (and slow!) maximum entropy technique.  Iterates the log
;     of the image for a positivity constraint with the /uselog keyword set.
;MODIFICATION HISTORY:
;     T. Metcalf 1999-Sep-21
;     T. Metcalf 1999-Oct-01  Added /uselog and /positive.
;     T. Metcalf 2000-Feb-09  Added /quiet keyword
;     T. Metcalf 2000-Mar-01  Added /float and made /double the default.
;     T. Metcalf 2000-Mar-07  Changed the weighting of the entropy term
;     T. Metcalf 2000-Mar-21  New implementation of usepsfcorr
;     T. Metcalf 2000-Mar-23  Fixed bug in entropy gradient
;     T. Metcalf 2000-Mar-24  Added /usepoisson, chi2aim keywords.
;     T. Metcalf 2000-Mar-31  Added memweight and /fixmemweight keywords and
;                             allow a crude search for the best value of the
;                             MEM weighting by attempting to reach a final
;                             chi^2 value given by the chi2aim keyword.  Also
;                             changed the implementation of the usepsfcorr
;                             term slightly.
;     T. Metcalf 2000-Sep-15  Added /flux keyword.
;     T. Metcalf 2001-Jan-10  Fixed calculation of flux when mask is set.
;     T. Metcalf 2001-Jan-16  Added check for sigma > 0.0
;     T. Metcalf 2001-Jan-24  Added /fftguess keyword
;     T. Metcalf 2001-Jan-29  The main code now uses the C-statistic when 
;                             /usepoisson is set.  The image_decon_func always
;                             used this anyway, but the change makes the
;                             MEM Lagrange multiplier calculation better with
;                             /usepoisson.
;     T. Metcalf 2002-Oct-25  Slight modification to the way
;                             /usepsfcorr works.  (Now use the central
;                             value).
;-

   common decon_func_common1, data, fpsf, cfpsf, sigma2, nx, ny, cdouble, $
                              uselog, quiet, mask, sigma, psf, useautocorr, $
                              usepsfcorr, lfactor, ntotal, usepoisson,  $
                              flux, btot, beta, fbeta

   psf = psfin

   if keyword_set(float) then cdouble = 0 else cdouble = 1
   if keyword_set(uselogin) then uselog = 1 else uselog = 0
   if keyword_set(quietin) then quiet = 1 else quiet = 0
   if keyword_set(maskin) then mask = maskin else mask=-1
   if keyword_set(useautocorrin) then useautocorr=1 else useautocorr=0
   if keyword_set(usepsfcorrin) then usepsfcorr=1 else usepsfcorr=0
   if keyword_set(chi2limitin) then chi2limit=float(chi2limitin) $
   else chi2limit=0.0
   if keyword_set(usepoissonin) then usepoisson=1 else usepoisson=0
   if keyword_set(chi2aimin) then chi2aim=float(chi2aimin>0.) $
   else chi2aim = 1.0
   if keyword_set(fluxin) then flux=float(fluxin) else flux=0

   if n_elements(maxiter) LE 0 then maxiter = 100

   nx = n_elements(datain[*,0])
   ny = n_elements(datain[0,*])
   ntotal = nx*ny - n_elements(mask)

   fpsf = fft(shift(psf,-floor(nx/2),-floor(ny/2)),+1,double=double)
   cfpsf = conj(fpsf)
   if keyword_set(usepsfcorr) then begin
      psf2 = psf
      ;psf2[floor(nx/2),floor(ny/2)] = 0.
      if total(psf2) EQ 0. then psf2=psf $
      else psf2 = psf2/total(psf2)
      usepsfcorr = conj(fft(shift(psf2,-floor(nx/2),-floor(ny/2)),+1, $
                            double=double))
   endif

   if keyword_set(fftguess) then begin
      guess = double(fft( fft(double(datain),+1,/double)/ fpsf ,-1,/double))
   endif

   if n_elements(guess) EQ n_elements(datain) then begin
      if keyword_set(double) then $
         image=double(guess) $
      else $
         image=float(guess) 
      message,/info,'Using supplied initial guess'
   endif else begin 
      if keyword_set(double) then $
         image = double(datain) $  
      else $
         image = float(datain)
   endelse


   if keyword_set(double) then $
      data = double(datain) $
   else $
      data = float(datain)
   btot = total(data)
   if keyword_set(double) then begin
      sigma = double(sigmain)
      sigma2 = double(sigmain)^2
   endif else begin
      sigma = float(sigmain)
      sigma2 = float(sigmain)^2
   endelse
   if min(sigma) LE 0.0 then $
      message,'ERROR: sigma must be positive and non-zero'
   beta = flux/(sigma*2.0)
   if keyword_set(usepoisson) then data = data>.01

   ; Iterate log for positivity constraint
   if keyword_set(uselog) then image = alog(image>1.)

   if NOT quiet then begin
      tvscl,alog(data>1.),nx*2,0
      xyouts,nx*2.5,0,align=0.5,/device,'Log Data ' + $
         string(min(data))+' '+string(max(data))
      print
      print,'       Iteration   chi^2        GOF      Convergence    min(image)    max(image)  MEM-weight  Flux/Data'
   endif
   if n_elements(memweight) GT 0 then $
      lfactor=float(memweight) else lfactor = 1.0
   if keyword_set(usepsfcorr) then lfactor = lfactor/2.0
   rchi2 = 0.
   for irepeat=0,5 do begin   ; Restart to make sure we have a global min
      if irepeat NE 0 AND rchi2 GT chi2aim $
         AND NOT keyword_set(fixmemweight) then lfactor=lfactor*chi2aim/rchi2
      oldrchi2 = rchi2
      line = 0L
      REPEAT begin
         lastrchi2 = rchi2
         ; Positivity constraint.  Can cause failure to converge
         if (NOT keyword_set(uselog)) then begin
            if keyword_set(positive) then image = image > 0.
         endif
         minf_conj_grad,image,gof,conv,func_name='image_decon_func', $
                        use_deriv=1,init=(line EQ 0L)
         if keyword_set(uselog) then eimage = exp(image) else eimage = image
         fimage = fft(eimage,+1,double=cdouble)
         new = fftconvol(fimage,fpsf)
         nbtot = total(new)
         if mask[0] GE 0 then nbtot = nbtot - total(new[mask]) + $
                                              total(data[mask]) 
         residual = new - data
         ;if keyword_set(mask) then $
         if mask[0] GE 0 then residual[mask] = 0.0
         if NOT keyword_set(usepoisson) then $
            rchi2 = total((residual^2)/sigma2)/ntotal $
         else $
            rchi2 = (-2.0*total(data - new + data*alog(new/data)))/ntotal
         if NOT quiet then begin
            print,line,float(rchi2),float(gof),float(conv), $
                  float(min(eimage)),float(max(eimage)),float(lfactor), $
                  float(total(new)/btot)
            if keyword_set(uselog) then begin
               tvscl,image
            endif else begin
               tvscl,alog(image>1.)
            endelse
            xyouts,nx*0.5,0,align=0.5,/device,'Log Deconvolved Image'
         endif
         if rchi2 LT chi2aim and NOT keyword_set(fixmemweight) then $
            lfactor = lfactor*(sqrt(2.0)<(chi2aim/rchi2))
         if rchi2 GT chi2aim and NOT keyword_set(fixmemweight) AND $
            lastrchi2 GT chi2aim AND $
            rchi2 GT lastrchi2 then $
            lfactor = lfactor*(sqrt(0.5)>(chi2aim/rchi2))
         line = line + 1
         if line GT maxiter then $
            message,/info,'WARNING: Failed to converge after ' + $
                          string(maxiter)+' line minimizations.'
      endrep UNTIL conv EQ 0. OR line GT maxiter OR rchi2 LT chi2limit
      if abs((rchi2-oldrchi2)/rchi2) LE 0.005 then goto,BAILOUT
   endfor

   BAILOUT:
   return,eimage

end
