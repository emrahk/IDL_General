;+
;NAME:
;     STOKESFIT
;PURPOSE:
;     Fits Unno profiles, including magneto-optical effects, to Stokes
;     profiles to derive magnetic field parameters. 
;CATEGORY:
;CALLING SEQUENCE:
;     fit = stokesfit(Ist,Qst,Ust,Vst,dlambda,dl_deriv,glande,lambda,mu)
;INPUTS:
;     Ist,Qst,Ust,Vst = Stokes profiles (all same size arrays).
;     dlambda = relative wavelenth in A, same size as Ist, etc.
;     dl_deriv = wavelength (A), relative to line center, at which to
;                compute JLS field.  default = 0.1 if set to empty
;                variable. 
;     glande = Lande g factor for this spectral line.
;     lambda = wavelenth of line in A.
;     mu = cosine of position angle on solar disk.
;          mu is cos(lat)*cos(b0)*cos(long) + sin(lat)*sin(b0)
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS:
;     aiquv = on output contains the fit parameter array.
;     sigma = errors on aiquv.  Only set when curvefit or lmfit is used.
;     guess = on input contains the initial guess for the fit
;             parameter array.  If not set, something reasonable is
;             assumed.  Not recommended unless you are sure you have a
;             really good guess.
;     /nocheckguess = if a guess is input the values are checked and
;                     may be modified to more sane values if they seem
;                     off.  If /nocheckguess is set, the guess is
;                     taken as is.
;     wiquv = the noise in I, Q, U, and V is, by default, set to
;             sqrt(I), sqrt(2I), sqrt(2I), and sqrt(2I).  wiquv is a
;             four element vector which multipies these noise levels.
;             So, 1./sqrt(wiquv) is the relative weighting for I, Q, U,
;             and V.
;     weight = weight of each spectral point in the fit, must be the
;              same size as dlambda.  Default = replicate(1.0,nlambda).
;              To keep the chi^2 calculation correct, the weight array
;              should have a mean of 1.
;     vpguess = Set guess for Voigt parameter.  If a valid guess parameter
;               is also set, this is ignored.
;     doppguess = Set guess for Doppler width (A)  If a valid guess parameter
;               is also set, this is ignored.
;     eta0guess,eta0nmguess = Set guess for eta0,eta0nm.  If a valid guess parameter
;               is also set, this is ignored.
;     b0guess,b0nmguessb1guess = Set guess for B0,B0nm,B1  If a valid guess parameter
;               is also set, this is ignored.
;     x0guess = Set guess for line center in units of dlambda.
;     x1guess = Set guess for non-magnetic line center in units of
;               dlambda.  Ignored if /nofitmagcenter is set.
;     /use_curvefit = Use the curvefit routine to fit the Unno
;                     profiles.  This is the fastest algorithm and is
;                     the default.
;     /use_lmfit = Use the IDL lmfit routine to fit the Unno profiles.
;                  Very similar to curvefit.  In principle, the IDL
;                  routines curvefit and lmfit do the same thing, but,
;                  since they are diffent implementations, I include
;                  both. 
;     /use_powell = Use the powell routine to fit the Unno profiles.
;                   Very slow, but possibly more robust than
;                   curvefit.
;     /use_dfpmin = Use the dfpmin routine to fit the Unno profiles.
;                   Almost as fast as curvefit, but less robust.
;     /use_amoeba = Use the amoeba routine to fit the Unno profiles.
;                   Faster than powell, slower than curvefit.  Less
;                   robust than both.
;     /use_genetic = Use genetic algorithm to fit the Unno profiles.
;                    This algorithm is hopelessly slow, but very
;                    robust *if you let it run for enough generations*.
;                    (see ngenerations keyword, below). If all else
;                    fails, /use_genetic will likely find 
;                    the right answer, but you'll have to be patient.
;                    You must have the ipikaia package in 
;                    your path for this to work.  See
;                    http://zeus.nascom.nasa.gov/~scott/ga.html and
;                    http://www.hao.ucar.edu/public/research/si/pikaia/pikaia.htm 
;     cfit_itmax  = Maximum number of iterations for curvefit.
;                   Default is 1000 (which is alot).
;     amoeba_nmax = passed on to amoeba as the nmax keyword.
;                   Controls how many function calls are allowed.
;                   The default is 20000L.
;     ngenerations = max number of generations to use in the genetic
;                    algorithm.  Default = 1000.  
;     decimalplaces = number of decimal places to use in the pikaia
;                     genetic algorithm.  Default = 7.  5 or 6 is
;                     likely enough accuracy (smaller is faster). 4 is
;                     too small.
;     /smooth = If set, smooth I,Q,U, and V before fitting.  If set, the
;               spectral response (spprofile) is convolved with the
;               smoothing kernel.  If there is not spectral response
;               set, then the spectral response is set to the
;               smoothing kernel.
;     kernel = Smoothing kernel for Q, U, V.  Must be symmetric,
;              positive-definite, and have an odd number of elements
;              to avoid shifts. Def = [.05,.2,.5,.2,.05].  Ignored
;              unless /smooth is set. 
;     /nofitfill = Do not fit the filling factor (assume fill=1.0).
;     min_fill = Minimum filling factor (default = 0.0).
;     /nofitqu = Do not fit Q and U, only I and V.  Qst and Ust are
;                ignored, but dummy variables must be in the argument
;                list.
;     /nofitmagcenter = do not allow the line center of the magnetic and
;                     non-magnetic components to vary independently.
;                     Default if /nofitfill is set.  Setting this
;                     keyword will speed the algorithm up
;                     significantly.  
;     fitmaglimit = Polarization limit below which the magnetic and
;                   non-magnetic line centers are not fit
;                   independently.  Ignored if /nofitmagcenter is set.
;                   Default = 0.0 (always fit magnetic line center).
;     spprofile = Spectral response of the instrument.  This profile
;                 is convolved with the Unno profiles before comparing
;                 to the data.  Must have the same number of elements
;                 as Ist, etc., and it must be centered in the array at
;                 spectral point (n-1)/2 where n is the number of
;                 spectral points.  If it is not properly centered, 
;                 the Unno profiles will be shifted. If this keyword
;                 is not set, then fields will typically be
;                 underestimated by an amount that depends on your
;                 instrument.  If the spectral response is narrow,
;                 there will be little or no impact.  The convolutions
;                 slow things down considerably, but if you can
;                 contrive to have n a power of 2 it will help
;                 since the convolutions are done with fft.
;     /spdeconvolve = Directly deconvolve spprofile from the spectra.
;                     This option is much faster than the default
;                     forward method when spprofile is set, but it may
;                     cause problems if your spectra are noisy.  A
;                     Wiener filter is applied to make the
;                     deconvolution more stable. This keyword is
;                     ignored if spprofile is not set.
;     /use_observed_derivative = If set, use the observed derivative
;                                of Ist in the JLS calculation.  The
;                                default is to use the analytic
;                                derivative of the magnetic profile.
;                                If this keyword is set, the JLS
;                                result is the flux, not the field.
;                                Setting this keyword can make the
;                                code very slow as the number 
;                                of wavelength points becomes large.
;                                The smoothing of the derivative is
;                                set by the noise on Ist, so be sure
;                                that wiquv is set correctly if you
;                                use this keyword.  If this keyword is
;                                set, it is highly recommended that
;                                /nofitfill or /nofitmagcenter also be
;                                set, otherwise the wavelength where the
;                                derivative is taken may not be what
;                                you expect with potentially bizarre
;                                results. 
;     /double = Use double precision.  Slower, but possibly more
;               robust. 
;     /plot = Plot final fit.
;     /nofixplotrange = do not fix the plot range of the final plot:
;                       let it float.
;     /verbose = Output text diagnostics along the way and, if /plot
;                is set, also plot the initial guess.
;     /quiet = Try to work with only minimal text output.
;OUTPUTS:
;     fit = structure with lots of data in it:
;
;            aparam:     Voigt parameter (Unno fit)
;            doppler:    Doppler width in A (Unno fit)
;            eta0:       absorption coefficient (Unno fit)
;            eta0nm:     absorption coefficient, non-magnetic (Unno fit)
;            b0:         coeff of linear source function (Unno fit)
;            b0nm:       coeff of linear source function, non-magnetic (Unno fit)
;            b1:         coeff of linear source function (Unno fit)
;            btotal:     total magnetic field in G (Unno fit)
;            gamma:      field inclination, degrees (Unno fit)
;            chi:        field azimuth, degrees (Unno fit)
;            blong:      LOS B(Gauss) from Unno fit (btotal*cos(gamma))
;            btran:      Transverse B(Gauss) from Unno fit (btotal*sin(gamma))
;            bazim:      Transverse B azimuth (degrees) from Unno fit (chi)
;            fill:       filling factor and/or scattered light fraction (Unno fit) 
;            x0:         Magnetic Line center in dlambda units (Unno fit)
;            x1:         Non-Magnetic Line center in dlambda units (Unno fit)
;            btotal_jls: Total magnetic field in G from JLS method
;            blong_jls:  LOS B (Gauss) from JLS method
;            btran_jls:  Transverse B (Gauss) from JLS method
;            bazim_jls:  Transverse B azimuth (degrees) from JLS method
;            gamma_jls:  field inclination, degrees from JLS method
;            dl_deriv:   DLambda used by JLS (input)
;            btotal_int  total magnetic field (G) from integral method
;            blong_int:  LOS magnetic field (G) from integral method
;            btran_int:  Transverse magnetic field (G) from integral method
;            bazim_int:  Transverse B azimuth (degrees) from integral method
;            gamma_int:  field inclination (degrees) from integral method
;            glande:     Lande g factor (input)
;            lambda:     Wavelength of line in A (input)
;            mu:         cosine of postion angle on disk (input)
;            ichi2:      Chi^2 for the Unno I fit
;            qchi2:      Chi^2 for the Unno Q fit
;            uchi2:      Chi^2 for the Unno U fit
;            vchi2:      Chi^2 for the Unno V fit
;            chi2:       Chi^2 for the Unno fit (I, Q, U, and V)
;            okfit:      Is the Unno fit good? 0=no, 1=yes
;            okjls:      Is the JLS calculation good? 0=no, 1=yes
;            version:    stokesfit.pro version
;
;     btotal, blong, and btran from the unno fit and the JLS method are the magnetic
;     field, assuming that the filling factor was fit (and fit
;     correctly). However, if /use_observed_derivative is set, then
;     the JLS result is the flux not the field, even if the filling
;     factor is fit (btrans_jls*sqrt(fill) is the transverse flux if
;     use_observed_derivative is set, as with the integral method).
;     blong_int from the integral method is the flux density, so the
;     field would be blong_int/fill.  btrans_int is neither the field
;     nor the flux density since the filling factor comes into the
;     btrans_int calculation as sqrt(fill).  The field would be
;     btrans_int/sqrt(fill) and the flux density would be
;     btrans_int*sqrt(fill), if you believe the derived filling 
;     factor.  The integral method tends to saturate (weak field
;     limit) well below where the JLS values saturate. 
;COMMON BLOCKS:
;     lots of private common blocks
;SIDE EFFECTS:
;RESTRICTIONS:
;     The center of the line must be visible in I.  The magnetic field
;     is limited to 10000 G, the voigt parameter is limited to 100,
;     the doppler width is limited to lamda/50, eta0 is limited
;     to 1000, and the difference between the magnetic and
;     non-magnetic line centers is limited to 10 km/sec.  The field
;     parameters for the integral method in the output structure are
;     only computed when an initial guess is *not* passed into this
;     routine; otherwise they are set to zero. 
;EXAMPLES:
;     The code runs much faster if you pass in a very good initial
;     guess.  If you are analyzing multiple, related data points you
;     can pass nearby results (keyword aiquv) in as the guess
;     (keyword guess), but be sure to check the okfit tag in the
;     output structure.  If okfit is 0, do not use the result in the
;     guess for the next data point.  But I prefer to pass in vpguess,
;     doppguess, eta0guess, b0guess, b1guess, and x0guess rather
;     than passing in a full set of parameters into the guess keyword.
;     This allows the magnetic field guess to be set by the integral
;     method rather than from the field nearby.
;PROCEDURE:
;     Calls curvefit, lmfit, dfpmin, powell, or amoeba to compute the
;     best fit to the Unno profiles.  The fit has 13 parameters and
;     fits I, Q, U, and V simultaneously.   The fit parameters are:
;          Voigt parameter
;          Doppler width 
;          absorption coefficient, magnetic
;          absorption coefficient, non-magnetic
;          coeff of linear source function, magnetic
;          coeff of linear source function, non-magnetic
;          slope of linear source function
;          Bz
;          Bx
;          By             (unless /nofitqu is set)
;          filling factor (unless /nofitfill is set)
;          Non-magnetic line center *shift* (if /nofitmagcenter and /nofitfill are not set)
;          Magnetic line center in dlambda units
;     The Unno profiles include magneto-optical effects: see Landolfi
;     and Landi Degl'Innocenti 1982, Solar Physics, 78, 355. 
;MODIFICATION HISTORY:
;     T. Metcalf  January 31, 2004  Version 1.0
;     Feb 2, 2004 TRM  Added /nofitqu keyword. verstion 1.1
;     Feb 4, 2004 TRM  Version 1.2
;                      Fixed a bit of confusion between double and
;                      float that was causing curvefit to think it was
;                      not converging even though it was.  This
;                      happened when the I,Q,U,V fits were double, but
;                      the derivatives were float.  Also changed the
;                      way the emission/absorption line is detected to
;                      make it more robust.
;     Feb 4, 2004 TRM  Version 1.3
;                      The /nofitqu algorithm was improved.
;     Feb 5, 2004 TRM  Version 1.4 
;                      Fit Bx but not By when /nofitqu is set.  This is
;                      necessary since the line splitting is
;                      proportional to btotal and Bx plays the role of
;                      btrans.  This works since I and V depend on
;                      btrans through btotal, but do not depend on the
;                      azimuthal angle of the transverse field.  Fixed
;                      numerical problem with curvefit when bt=0
;                      (needed to fix bx and by derivs in this case).
;     Feb 6, 2004 TRM  Version 1.5
;                      Force curvefit to reduce the filling factor
;                      slowly so that the algorithm does not get stuck
;                      with huge field and tiny fill factor.
;     Feb 12, 2004 TRM Version 1.6
;                      Improved the calculation of B0,B1, and eta0 in
;                      the initial guess.  This better initial guess
;                      improves the robustness of the curvefit
;                      algorithm considerably. 
;     Feb 13, 2004 TRM Version 1.7
;                      Fixed sign of Q and U in the JLS calculation
;                      when the line is in emsission.
;     Feb 20, 2004 TRM Version 1.8
;                      Added some error checking in the initial
;                      guess.   Added okfit and okjls tags to output
;                      structure.  Made sure the weight is always
;                      positive.  Added upper limits to the voigt
;                      parameter, the Doppler width, and eta0.  Added
;                      upper and lower limits to x0.
;     Feb 24, 2004 TRM Version 1.9
;                      Added sanity checks on any initial guess that
;                      is input.  Fixed small bug in initial guess
;                      where qtest and utest were interpolated using
;                      dlambda rather than dl.  Added integral field
;                      parameters to the output structure.
;     Feb 27, 2004 TRM Version 1.95
;                      Added /use_dfpmin keyword.  Added smoothing in
;                      the initial guess when computing the sign of Q,
;                      U, and V.
;     Mar 9, 2004  TRM Version 2.0
;                      Added x1 option to the fit parameters.  If the
;                      initial guess fails the sanity checks, compute
;                      a new guess from scratch.  Force a guess passed
;                      in to use fill=1 and flux density.  Added
;                      vpguess, doppguess, et0guess, b0guess, b1guess,
;                      x0guess, and x1guess keywords. 
;     Mar 10, 2004 TRM Version 2.01
;                      Added fitmaglimit keyword to limit lowest
;                      polarization at which the fitmagcenter keyword
;                      is valid.
;     May 21, 2004 TRM Version 2.02
;                      Added lmfit option and the /use_lmfit keyword.
;     May 26, 2004 TRM Version 2.03
;                      Added /quiet keyword.  Better scale calculation
;                      for amoeba, dfpmin, and powell algorithms.
;                      Added amoeba_nmax keyword.
;     Jun 3, 2004  TRM Version 2.04
;                      Added spprofile keyword.
;     Jun 8, 2004  TRM Version 2.05
;                      Fixed typo in dQ_da, dI_dx1
;     Jun 11, 2004 TRM Version 2.06
;                      Convolve spprofile with the smoothing kernel.
;                      Added wiquv keyword.  Make curvefit quiet when
;                      /quiet is set.  Make /fitmagcenter work with
;                      /nofitqu. 
;     Aug 4, 2004  TRM Version 2.07
;                      Added /nofixplotrange keyword.  Added
;                      /nocheckguess keyword.
;     Oct 14, 2004 TRM Version 2.08 
;                      Changed the default value of fitmaglimt to 0.0
;                      from 0.025.
;     Oct 15, 2004 TRM Version 3.00
;                      Added eta0nm and b0nm to the fit.
;                      fitmagcenter -> nofitmagcenter.
;                      Added ssa, ssdopp, sseta0, etc. to simplify the
;                      indexing in the code considerably.
;     Oct 19, 2004 TRM Version 3.01
;                      Use the analytic derivative of the magnetic I
;                      profile when computing the JLS field.
;     Oct 20, 2004 TRM Version 3.02
;                      Added min_fill keyword.
;     Oct 25, 2004 TRM Version 3.03
;                      Added weight keyword.
;     Nov 19, 2004 TRM Version 3.04
;                      Added /use_genetic.
;     Nov 22, 2004 TRM Version 3.05
;                      Made pikaia fitwatch more robust.
;     Dec 02, 2004 TRM Version 3.06
;                      Minor change to error output when no_fit_fill
;                      is set.
;     Dec 17, 2004 TRM Version 3.07
;                      Fixed bug in JLS calculation.  I,Q,U,V used for
;                      the JLS calculation erroneously had the
;                      instrument spectral response and smoothing
;                      applied to them which is inconsistent with the
;                      way the analytical derivative is computed.
;                      Also fixed a bug in which the smoothing profile
;                      was applied twice if the instrument spectral
;                      response was not set. Smooth I as well as Q,U,V
;                      when /smooth is set.  This is required for
;                      consistency since the spectral profile is set
;                      to the smoothing kernel.  eta0 out of range is
;                      not an error since, when eta0 is >> 1, it is
;                      folded into b1: removed this check.  No longer
;                      set a bad fit when the initial guess is
;                      out-of-range. 
;     Dec 20, 2004 TRM Version 3.08
;                      Added /spdeconvolve and the Wiener filter.
;     Apr 14, 2005 TRM Version 3.09
;                      Use amoebax instead of amoeba.
;     Apr 19, 2005 TRM Version 3.10
;                      Added /use_observed_derivative keyword.
;     Apr 20, 2005 TRM Version 3.11
;                      Added error checking aroud deriv_lud call which
;                      is called when use_observed_derivative is set.
;-

pro voigt_funct_iquv,x,guess,fout,pder,no_instrument_response=no_instrument_response

   ; Compute Unno profiles at x, including magneto-optical effects.
   ; See Landolfi and Landi Degl'Innocenti, Solar Physics, 78, 355, 1982.

   common stokes_fit_private,nterms,npoints,nstokes,nofitd,nofita, $
                              one_over_sqrt_pi,plot,verbose, $
                              use_double,no_fit_fill,no_fit_qu,min_fill, $
                              alimit,dlimit,elimit,x0min,x0max,fit_x1,x1limit, $
                              fftprofile,use_sp_profile
   common stokes_fit_private_iquv,wave, $  ; wave in cm!!!
                                  glande, $
                                  mu, $
                                  clight, $
                                  elec, $
                                  me,eps,deps,Blimit,clarmor
   common stokes_fit_private_indices,ssa,ssdopp,sseta0,sseta0nm,ssb0,ssb0nm,ssb1,ssbz,ssbx,ssby,ssfill,ssx1,ssx0

   ; Independent parameter

   ; x = relative wavelength in A

   nx = n_elements(x)

   ; Free parameters: 

   guess[ssa] = abs(guess[ssa])<alimit        ; Voigt paramter upper limit
   guess[ssdopp] = abs(guess[ssdopp])<dlimit        ; Doppler width upper limit
   guess[sseta0] = abs(guess[sseta0])<elimit        ; eta0 upper limit
   if NOT no_fit_fill then guess[sseta0nm] = abs(guess[sseta0nm])<elimit    ; eta0nm upper limit

   a        = guess[ssa]                       ; Voigt parameter
   dopplerl = guess[ssdopp]                       ; Doppler width in A
   eta0     = guess[sseta0]                       ; absorption coefficient
   if NOT no_fit_fill then eta0nm   = guess[sseta0nm]                       ; abs coeff non-magnetic
   b0       = guess[ssb0]                       ; coeff of linear source function
   if NOT no_fit_fill then b0nm     = guess[ssb0nm]                       ; coeff of LSF, non-magnetic
   b1       = guess[ssb1]                       ; coeff of linear source function
   sbz      = 2*(guess[ssbz] GE 0.0)-1          ; sign of Bcos(gamma)
   sbx      = 2*(guess[ssbx] GE 0.0)-1          ; sign of -Bsin(gamma)sin(chi)
   guess[ssbz] = sbz*(abs(guess[ssbz])<Blimit)     ; upper limit on Bz
   guess[ssbx] = sbx*(abs(guess[ssbx])<Blimit)     ; upper limit on Bx
   bz       = guess[ssbz]                       ; Bcos(gamma)
   bx       = guess[ssbx]                       ; -Bsin(gamma)sin(chi)
   if no_fit_qu then begin                   ; btrans is 0 if not fitting Q,U
      sby = 1
      by = 0.
   endif else begin
      sby      = 2*(guess[ssby] GE 0.0)-1       ; sign of Bsin(gamma)cos(chi)
      guess[ssby] = sby*(abs(guess[ssby])<Blimit)  ; upper limit on By
      by       = guess[ssby]                    ; +Bsin(gamma)cos(chi)
   endelse
   bt       = sqrt(bx^2+by^2)                ; Btrans
   chi      = atan(-bx,by)                   ; chi
   btotal   = sqrt(bz^2+bt^2)                ; Btotal
   gamma    = atan(bt,bz)                    ; gamma
   guess[ssx0] = (guess[ssx0]<x0max)>x0min
   x0       = guess[ssx0]                 ; Line center
   if no_fit_fill then begin
      fill     = 1.0                         ; filling factor 
      x1       = 0.0
   endif else begin
      guess[ssfill] = (abs(guess[ssfill])<1.0)>min_fill  ; in range [min_fill,1]
      fill     = guess[ssfill]                 ; filling factor 
      if fit_x1 then begin
         sx1      = 2*(guess[ssx1] GE 0.0)-1    ; sign of x1
         guess[ssx1] = sx1*(abs(guess[ssx1])<x1limit)
         x1       = guess[ssx1]                 ; Line center of non-magnetic profile
      endif else begin
         x1       = 0.
      endelse
   endelse

   doppler = (clight/wave^2)*dopplerl*1.0e-8 ; Hz ...  dopplerl in A
   larmor = clarmor*Btotal
   vb = larmor/doppler

   vf = (x-x0)/dopplerl

   voigt, a, vf, h, f
   voigt, a, vf+vb, hr, fr
   voigt, a, vf-vb, hl, fl

   kappa_p = eta0 * h
   kappa_r = eta0 * hr
   kappa_l = eta0 * hl
   kappa_avg = (kappa_r+kappa_l)/2.0

   kappa_pp = eta0 * f
   kappa_pr = eta0 * fr
   kappa_pl = eta0 * fl
   kappa_pavg = (kappa_pr+kappa_pl)/2.0

   kappa_p_avg   = kappa_p - kappa_avg
   kappa_pp_pavg = kappa_pp - kappa_pavg
   cg = cos(gamma)
   sg = sin(gamma)
   sg2 = (sg)^2
   cg2 = (cg)^2
   c2c = cos(2*chi)
   s2c = sin(2*chi)

   etaI = 0.5*(kappa_avg*(1.0+cg2) + kappa_p*sg2)
   etaQ = 0.5*kappa_p_avg*sg2*c2c
   etaU = 0.5*kappa_p_avg*sg2*s2c
   etaV = 0.5*(kappa_r - kappa_l)*cg

   rhoQ = 0.5*kappa_pp_pavg*sg2*c2c
   rhoU = 0.5*kappa_pp_pavg*sg2*s2c
   rhoV = 0.5*(kappa_pr - kappa_pl)*cg

   ; These are used more than once so save time by saving results

   etaI1 = (1+etaI)
   eta12 = etaI1^2
   erQUV = etaQ*rhoQ+etaU*rhoU+etaV*rhoV
   etaQ2 = etaQ^2
   etaU2 = etaU^2
   etaV2 = etaV^2
   rhoQ2 = rhoQ^2
   rhoU2 = rhoU^2
   rhoV2 = rhoV^2
   delta = eta12 * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2) - erQUV^2

   mB1d = mu*B1/delta

   ;Im = B0 + (mu*B1/delta)*(1+etaI)*((1+etaI)^2+rhoQ^2+rhoU^2+rhoV^2)

   ;Q = -fill*(mu*B1/delta)*((1+etaI)^2*etaQ+(1+etaI)*(etaV*rhoU-etaU*rhoV) + $
   ;      rhoQ*(etaQ*rhoQ + etaU*rhoU + etaV*rhoV))

   ;U = -fill*(mu*B1/delta)*((1+etaI)^2*etaU+(1+etaI)*(etaQ*rhoV-etaV*rhoQ) + $
   ;      rhoU*(etaQ*rhoQ + etaU*rhoU + etaV*rhoV))

   ;V = -fill*(mu*B1/delta)*((1+etaI)^2*etaV + $
   ;           rhoV*(etaQ*rhoQ+etaU*rhoU+etaV*rhoV))

   Im = B0 + mB1d*etaI1*(eta12+rhoQ2+rhoU2+rhoV2)

   if NOT no_fit_qu then begin
      Q = -fill*mB1d*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV) + $
            rhoQ*erQUV)

      U = -fill*mB1d*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + $
            rhoU*erQUV)
   endif

   V = -fill*mB1d*(eta12*etaV + rhoV*erQUV)

   ; Get non-magnetic I profile

   if NOT no_fit_fill then begin
      vfnm = (x-(x0+x1))/dopplerl
      voigt, a, vfnm, hnm, fnm
      kappa_p_nm = eta0nm * hnm
      ;Inm = B0 + mu*B1/(1+etaInm)
      Inm = B0nm + mu*B1/(1.+kappa_p_nm)
   endif else Inm = 0.0

   I = fill*Im + (1.0-fill)*Inm

   if no_fit_qu then fout = [I,V] $
   else fout = [I,Q,U,V]

   ; Convolve the Unno profiles with the spectral response of the insturment.
   if use_sp_profile AND NOT keyword_set(no_instrument_response) then begin
      for istk=0,nstokes-1 do begin
         if use_double then $
            fout[nx*istk:nx*(istk+1)-1] = $
               double(fft(fft(fout[nx*istk:nx*(istk+1)-1],-1,/double)*fftprofile,+1,/double)) $
         else $
            fout[nx*istk:nx*(istk+1)-1] = $
               float(fft(fft(fout[nx*istk:nx*(istk+1)-1],-1)*fftprofile,+1))
      endfor
   endif

;   if keyword_set(verbose) then begin  ; Plots
;      dl = x - x0
;      if n_elements(where(finite(dl))) EQ n_elements(dl) then begin
;         !p.multi=[0,2,2,0]
;         if n_elements(where(finite(i))) EQ n_elements(dl) then $
;            plot,dl,i,title='I + Fit'
;         if n_elements(where(finite(q))) EQ n_elements(dl) then $
;            plot,dl,q,title='Q + Fit'
;         if n_elements(where(finite(u))) EQ n_elements(dl) then $
;            plot,dl,u,title='U- + Fit'
;         if n_elements(where(finite(v))) EQ n_elements(dl) then $
;            plot,dl,v,title='V + Fit'
;      endif
;   endif

   if n_params() LE 3 then return ; need partials?

   ;if use_double then pder = dblarr(npoints,nterms) else  pder = fltarr(npoints,nterms)
   if use_double then pder = dblarr(nx*nstokes,nterms) else  pder = fltarr(nx*nstokes,nterms)

   ; pder[*,0] is dIQUV/da
   ; pder[*,1] is dIQUV/ddopplerl
   ; pder[*,2] is dIQUV/deta0
   ; pder[*,3] is dIQUV/deta0nm
   ; pder[*,4] is dIQUV/db0
   ; pder[*,5] is dIQUV/db0nm
   ; pder[*,6] is dIQUV/db1
   ; pder[*,7] is dIQUV/dBz
   ; pder[*,8] is dIQUV/dBx
   ; pder[*,9] is dIQUV/dBy
   ; pder[*,10] is dIQUV/dfill
   ; pder[*,11] is dIQUV/dx1
   ; pder[*,12] is dIQUV/dx0


   ; Calculate numeric derivatives (only for testing analytic derivatives)

   ; if 1 then begin
   ;   npder = pder
   ;   gp = double(guess)
   ;   gm = double(guess)
   ;   iitop = nterms
   ;   ;if no_fit_fill then iitop=iitop-2
   ;   ;if no_fit_qu then iitop=iitop-1
   ;   for ii=0,iitop-1 do begin
   ;      gii = double(guess[ii])
   ;      d = ((abs(gii)*(eps*10.d0)) )>1.e-2
   ;      gp[ii] = gii + d
   ;      gm[ii] = gii - d
   ;      voigt_funct_iquv,double(x),gp,fp
   ;      voigt_funct_iquv,double(x),gm,fm
   ;      npder[*,ii] = float((fp-fm)/(2.*d))
   ;      gp[ii] = gii
   ;      gm[ii] = gii
   ;   endfor
   ; endif

   ; Calculate analytic derivatives.  Just be glad that you did not 
   ; have to calculate and type all this in!

   vfp = vf+vb
   vfm = vf-vb

   ; dIQUV/da

   dh_da = 2.0*(a*h+vf*f-one_over_sqrt_pi)
   if NOT no_fit_fill then dhnm_da = 2.0*(a*hnm+vfnm*fnm-one_over_sqrt_pi)
   dhl_da = 2.0*(a*hl+vfm*fl-one_over_sqrt_pi)
   dhr_da = 2.0*(a*hr+vfp*fr-one_over_sqrt_pi)
   df_da = 2.0*(a*f-vf*h)
   dfl_da = 2.0*(a*fl-vfm*hl) 
   dfr_da = 2.0*(a*fr-vfp*hr) 
   dkappa_r_da = eta0 * dhr_da
   dkappa_l_da = eta0 * dhl_da
   if NOT no_fit_fill then dkappa_p_nm_da = eta0 * dhnm_da
   dkappa_p_da = eta0 * dh_da
   dkappa_pp_da = eta0 * df_da
   dkappa_pr_da = eta0 * dfr_da
   dkappa_pl_da = eta0 * dfl_da
   dkappa_avg_da = (dkappa_r_da+dkappa_l_da)/2.0
   dkappa_pavg_da = (dkappa_pr_da+dkappa_pl_da)/2.0
   dkappa_pp_pavg_da = dkappa_pp_da - dkappa_pavg_da
   dkappa_p_avg_da = dkappa_p_da - dkappa_avg_da
   detaQ_da = 0.5*dkappa_p_avg_da*sg2*c2c
   detaU_da = 0.5*dkappa_p_avg_da*sg2*s2c
   detaV_da = 0.5*(dkappa_r_da - dkappa_l_da)*cg
   drhoQ_da = 0.5*dkappa_pp_pavg_da*sg2*c2c
   drhoU_da = 0.5*dkappa_pp_pavg_da*sg2*s2c
   drhoV_da = 0.5*(dkappa_pr_da - dkappa_pl_da)*cg
   detaI1_da = 0.5*(dkappa_avg_da*(1.0+cg2)+dkappa_p_da*sg2)
   deta12_da = 2.0*etaI1*detaI1_da
   detaQ2_da = 2.0*etaQ*detaQ_da
   detaU2_da = 2.0*etaU*detaU_da
   detaV2_da = 2.0*etaV*detaV_da
   drhoQ2_da = 2.0*rhoQ*drhoQ_da
   drhoU2_da = 2.0*rhoU*drhoU_da
   drhoV2_da = 2.0*rhoV*drhoV_da
   derQUV_da =  detaQ_da*rhoQ+detaU_da*rhoU+detaV_da*rhoV $
               +etaQ*drhoQ_da+etaU*drhoU_da+etaV*drhoV_da
   ddelta_da = deta12_da * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2) $
               + eta12 * (deta12_da-detaQ2_da-detaU2_da-detaV2_da+drhoQ2_da+drhoU2_da+drhoV2_da) $
               - 2.0*erQUV*derQUV_da

   dmB1d_da = (-mu*B1/(delta^2))*ddelta_da

   dIm_da = dmB1d_da*etaI1*(eta12+rhoQ2+rhoU2+rhoV2)  $
            + mB1d*(eta12+rhoQ2+rhoU2+rhoV2)*detaI1_da $
            +mB1d*etaI1*(deta12_da+drhoQ2_da+drhoU2_da+drhoV2_da)
   if NOT no_fit_fill then dInm_da = -(mu*B1/((1+kappa_p_nm)^2))*dkappa_p_nm_da else dInm_da=0.
   dI_da = fill*dIm_da + (1.0-fill)*dInm_da
   if NOT no_fit_qu then begin
      dQ_da = -fill*(dmB1d_da*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV)+rhoQ*erQUV) +$
                     mB1d*( deta12_da*etaQ+ eta12*detaQ_da+ $
                            detaI1_da*(etaV*rhoU-etaU*rhoV) + $
                            etaI1*(detaV_da*rhoU+etaV*drhoU_da -detaU_da*rhoV-etaU*drhoV_da ) +$
                            drhoQ_da*erQUV + rhoQ*derQUV_da) $
                    )

      dU_da = -fill*(dmB1d_da*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ)+rhoU*erQUV) + $
                      mB1d*(deta12_da*etaU + eta12*detaU_da + $
                            detaI1_da*(etaQ*rhoV-etaV*rhoQ) + $
                            etaI1*(detaQ_da*rhoV+etaQ*drhoV_da  - detaV_da*rhoQ-etaV*drhoQ_da) + $
                            drhoU_da*erQUV + rhoU*derQUV_da $
                           ) $
                    )
   endif
   dV_da = -fill*(dmB1d_da*(eta12*etaV + rhoV*erQUV)+mB1d*(deta12_da*etaV+eta12*detaV_da+drhoV_da*erQUV+rhoV*derQUV_da))

   if no_fit_qu then dIQUV_da = [dI_da,dV_da] else dIQUV_da = [dI_da,dQ_da,dU_da,dV_da]
   pder[*,ssa] = dIQUV_da 


   ; dIQUV/d_dopplerl

   dvf_dd = -vf/dopplerl
   if NOT no_fit_fill then dvfnm_dd = -vfnm/dopplerl
   dvb_dd = -vb/dopplerl
   dvfm_dd = dvf_dd - dvb_dd 
   dvfp_dd = dvf_dd + dvb_dd

   dh_dd = 2.0*(a*f-vf*h)*dvf_dd
   if NOT no_fit_fill then dhnm_dd = 2.0*(a*fnm-vfnm*hnm)*dvfnm_dd
   dhl_dd = 2.0*(a*fl-vfm*hl)*dvfm_dd
   dhr_dd = 2.0*(a*fr-vfp*hr)*dvfp_dd
   df_dd = -2.0*(a*h+vf*f-one_over_sqrt_pi)*dvf_dd
   dfl_dd = -2.0*(a*hl+vfm*fl-one_over_sqrt_pi)*dvfm_dd
   dfr_dd = -2.0*(a*hr+vfp*fr-one_over_sqrt_pi)*dvfp_dd

   dkappa_p_dd = eta0 * dh_dd
   if NOT no_fit_fill then dkappa_p_nm_dd = eta0 * dhnm_dd
   dkappa_r_dd = eta0 * dhr_dd
   dkappa_l_dd = eta0 * dhl_dd
   dkappa_avg_dd = (dkappa_r_dd+dkappa_l_dd)/2.0
   dkappa_p_avg_dd = dkappa_p_dd - dkappa_avg_dd
   dkappa_pr_dd = eta0 * dfr_dd
   dkappa_pl_dd = eta0 * dfl_dd
   dkappa_pp_dd = eta0 * df_dd
   dkappa_pavg_dd = (dkappa_pr_dd+dkappa_pl_dd)/2.0
   dkappa_pp_pavg_dd = dkappa_pp_dd - dkappa_pavg_dd

   detaI_dd = 0.5*(dkappa_avg_dd*(1.0+cg2) + dkappa_p_dd*sg2)
   detaQ_dd = 0.5*dkappa_p_avg_dd*sg2*c2c
   detaU_dd = 0.5*dkappa_p_avg_dd*sg2*s2c
   detaV_dd = 0.5*(dkappa_r_dd - dkappa_l_dd)*cg
   drhoQ_dd = 0.5*dkappa_pp_pavg_dd*sg2*c2c
   drhoU_dd = 0.5*dkappa_pp_pavg_dd*sg2*s2c
   drhoV_dd = 0.5*(dkappa_pr_dd - dkappa_pl_dd)*cg

   detaI1_dd = detaI_dd
   deta12_dd = 2.0*etaI1*detaI1_dd
   detaQ2_dd = 2.0*etaQ*detaQ_dd
   detaU2_dd = 2.0*etaU*detaU_dd
   detaV2_dd = 2.0*etaV*detaV_dd
   drhoQ2_dd = 2.0*rhoQ*drhoQ_dd
   drhoU2_dd = 2.0*rhoU*drhoU_dd
   drhoV2_dd = 2.0*rhoV*drhoV_dd

   derQUV_dd = detaQ_dd*rhoQ + etaQ*drhoQ_dd + $
               detaU_dd*rhoU + etaU*drhoU_dd + $
               detaV_dd*rhoV + etaV*drhoV_dd

   ddelta_dd =   deta12_dd * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2)  $
               + eta12 * (deta12_dd-detaQ2_dd-detaU2_dd-detaV2_dd+drhoQ2_dd+drhoU2_dd+drhoV2_dd)  $
               - 2.0*erQUV*derQUV_dd

   dmB1d_dd = (-mB1d/delta)*ddelta_dd

   dIm_dd = dmB1d_dd*etaI1*(eta12+rhoQ2+rhoU2+rhoV2) + $
            mB1d*detaI1_dd*(eta12+rhoQ2+rhoU2+rhoV2) + $
            mB1d*etaI1*(deta12_dd+drhoQ2_dd+drhoU2_dd+drhoV2_dd)

   if NOT no_fit_fill then dInm_dd = -mu*B1*dkappa_p_nm_dd/((1+kappa_p_nm)^2) else dInm_dd=0.


   dI_dd =  fill*dIm_dd + (1.0-fill)*dInm_dd


   if NOT no_fit_qu then begin
      dQ_dd = -fill*(dmB1d_dd*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV)+rhoQ*erQUV) + $
                     mB1d*(deta12_dd*etaQ + eta12*detaQ_dd + $
                           detaI1_dd*(etaV*rhoU-etaU*rhoV) + $
                           etaI1*(detaV_dd*rhoU+etaV*drhoU_dd-detaU_dd*rhoV-etaU*drhoV_dd) + $
                           drhoQ_dd*erQUV+rhoQ*derQUV_dd) $
                    )


      dU_dd = -fill*( dmB1d_dd*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV) + $
                      mB1d*( deta12_dd*etaU + eta12*detaU_dd + $
                             detaI1_dd*(etaQ*rhoV-etaV*rhoQ) + $
                             etaI1*(detaQ_dd*rhoV+etaQ*drhoV_dd-detaV_dd*rhoQ-etaV*drhoQ_dd) +$
                             drhoU_dd*erQUV+rhoU*derQUV_dd $
                           ) $
                    )
   endif



   dV_dd = -fill*(  dmB1d_dd*(eta12*etaV + rhoV*erQUV) + $
                    mB1d*(deta12_dd*etaV+eta12*detaV_dd  + drhoV_dd*erQUV+rhoV*derQUV_dd) $
                  )

   if no_fit_qu then dIQUV_dd = [dI_dd,dV_dd] else dIQUV_dd = [dI_dd,dQ_dd,dU_dd,dV_dd]
   pder[*,ssdopp] = dIQUV_dd 


   ; dIQUV/de0

   dkappa_r_de0 = hr
   dkappa_l_de0 = hl
   dkappa_p_de0 = h
   if NOT no_fit_fill then dkappa_p_nm_de0 = hnm
   dkappa_pr_de0 = fr
   dkappa_pl_de0 = fl
   dkappa_pp_de0 = f
   dkappa_avg_de0 = (dkappa_r_de0+dkappa_l_de0)/2.0
   dkappa_pavg_de0 = (dkappa_pr_de0+dkappa_pl_de0)/2.0
   dkappa_pp_pavg_de0 = dkappa_pp_de0 - dkappa_pavg_de0
   dkappa_p_avg_de0 = dkappa_p_de0 - dkappa_avg_de0

   detaI_de0 = 0.5*(dkappa_avg_de0*(1.0+cg2) + dkappa_p_de0*sg2)
   detaQ_de0 = 0.5*dkappa_p_avg_de0*sg2*c2c
   detaU_de0 = 0.5*dkappa_p_avg_de0*sg2*s2c
   detaV_de0 = 0.5*(dkappa_r_de0 - dkappa_l_de0)*cg
   drhoQ_de0 = 0.5*dkappa_pp_pavg_de0*sg2*c2c
   drhoU_de0 = 0.5*dkappa_pp_pavg_de0*sg2*s2c
   drhoV_de0 = 0.5*(dkappa_pr_de0 - dkappa_pl_de0)*cg

   detaI1_de0 = detaI_de0
   deta12_de0 = 2.0*etaI1*detaI1_de0

   detaQ2_de0 = 2.0*etaQ*detaQ_de0
   detaU2_de0 = 2.0*etaU*detaU_de0
   detaV2_de0 = 2.0*etaV*detaV_de0
   drhoQ2_de0 = 2.0*rhoQ*drhoQ_de0
   drhoU2_de0 = 2.0*rhoU*drhoU_de0
   drhoV2_de0 = 2.0*rhoV*drhoV_de0

   derQUV_de0 = detaQ_de0*rhoQ + etaQ*drhoQ_de0+ $
                detaU_de0*rhoU + etaU*drhoU_de0 + $
                detaV_de0*rhoV + etaV*drhoV_de0

   ddelta_de0 =   deta12_de0 * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2)  $
               + eta12*(deta12_de0-detaQ2_de0-detaU2_de0-detaV2_de0+drhoQ2_de0+drhoU2_de0+drhoV2_de0)  $
               - 2.0*erQUV*derQUV_de0

   dmB1d_de0 = (-mB1d/delta)*ddelta_de0

   dIm_de0 = dmB1d_de0*etaI1*(eta12+rhoQ2+rhoU2+rhoV2) + $
             mB1d*detaI1_de0*(eta12+rhoQ2+rhoU2+rhoV2) + $
             mB1d*etaI1*(deta12_de0+drhoQ2_de0+drhoU2_de0+drhoV2_de0)

   if fill LE 0.1 then $   ; If deriv gets too small, e0 goes out of range
      dI_de0 = 0.1*dIm_de0 $
   else $
      dI_de0 = fill*dIm_de0 

   if NOT no_fit_qu then begin
      dQ_de0 = -fill*( dmB1d_de0*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV)+rhoQ*erQUV) + $
                       mB1d*(deta12_de0*etaQ + eta12*detaQ_de0 +$
                             detaI1_de0*(etaV*rhoU-etaU*rhoV) + $
                             etaI1*(detaV_de0*rhoU+etaV*drhoU_de0 -detaU_de0*rhoV-etaU*drhoV_de0) + $
                             drhoQ_de0*erQUV+rhoQ*derQUV_de0) $
                     )


      dU_de0 = -fill*( dmB1d_de0*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ)+rhoU*erQUV) + $
                       mB1d*( deta12_de0*etaU + eta12*detaU_de0 +$
                              detaI1_de0*(etaQ*rhoV-etaV*rhoQ) + $
                              etaI1*(detaQ_de0*rhoV+etaQ*drhoV_de0-detaV_de0*rhoQ-etaV*drhoQ_de0) + $
                              drhoU_de0*erQUV+rhoU*derQUV_de0) $
                     )
   endif

   dV_de0 = -fill*( dmB1d_de0*(eta12*etaV + rhoV*erQUV) + $
                    mB1d*(deta12_de0*etaV+eta12*detaV_de0 + drhoV_de0*erQUV+rhoV*derQUV_de0) $
                  )

   if no_fit_qu then dIQUV_de0 = [dI_de0,dV_de0] else dIQUV_de0 = [dI_de0,dQ_de0,dU_de0,dV_de0]
   pder[*,sseta0] = dIQUV_de0


   ;dIQUV/de0nm

   if NOT no_fit_fill then begin

      dkappa_p_nm_de0nm = hnm
      dInm_de0nm = -mu*B1*dkappa_p_nm_de0nm/((1.+kappa_p_nm)^2)

      if fill GE 0.9 then $
         dI_de0nm = 0.1*dInm_de0nm $  ; If deriv gets too small, e0nm goes out of range
      else $
         dI_de0nm = (1.0-fill)*dInm_de0nm

      if NOT no_fit_qu then begin
         dQ_de0nm = replicate(0.0,nx)
         dU_de0nm = replicate(0.0,nx)
      endif
      dV_de0nm = replicate(0.0,nx)
   
      if no_fit_qu then dIQUV_de0nm = [dI_de0nm,dV_de0nm] $
      else dIQUV_de0nm = [dI_de0nm,dQ_de0nm,dU_de0nm,dV_de0nm]

      pder[*,sseta0nm] = dIQUV_de0nm

   endif


   ; dIQUV/b0

   dIm_db0 = replicate(1.0,nx)

   if fill LE 0.1 then $
      dI_db0 = 0.1*dIm_db0 $
   else $
      dI_db0 = fill*dIm_db0

   if NOT no_fit_qu then begin
      dQ_db0 = replicate(0.0,nx)
      dU_db0 = replicate(0.0,nx)
   endif
   dV_db0 = replicate(0.0,nx)


   if no_fit_qu then dIQUV_db0 = [dI_db0,dV_db0] else dIQUV_db0 = [dI_db0,dQ_db0,dU_db0,dV_db0]
   pder[*,ssb0] = dIQUV_db0


   ; dIQUV/db0nm

   if NOT no_fit_fill then begin

      dInm_db0nm = replicate(1.0,nx)

      if fill GE 0.9 then $
         dI_db0nm = 0.1*dInm_db0nm $  ; If deriv gets too small, e0nm goes out of range
      else $
         dI_db0nm = (1.0-fill)*dInm_db0nm

      if NOT no_fit_qu then begin
         dQ_db0nm = replicate(0.0,nx)
         dU_db0nm = replicate(0.0,nx)
         endif
      dV_db0nm = replicate(0.0,nx)
   
      if no_fit_qu then dIQUV_db0nm = [dI_db0nm,dV_db0nm] else dIQUV_db0nm = [dI_db0nm,dQ_db0nm,dU_db0nm,dV_db0nm]
      pder[*,ssb0nm] = dIQUV_db0nm

   endif


   ;dIQUV/b1

   md = (mu/delta)

   dIm_db1 = md*etaI1*(eta12+rhoQ2+rhoU2+rhoV2)
   if NOT no_fit_fill then dInm_db1 = mu/(1+kappa_p_nm) else dInm_db1 = 0.

   dI_db1 = fill*dIm_db1 + (1.0-fill)*dInm_db1
   if NOT no_fit_qu then begin
      dQ_db1 = -fill*md*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV) + rhoQ*erQUV)
      dU_db1 = -fill*md*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV)
   endif
   dV_db1 = -fill*md*(eta12*etaV + rhoV*erQUV)



   if no_fit_qu then dIQUV_db1 = [dI_db1,dV_db1] else dIQUV_db1 = [dI_db1,dQ_db1,dU_db1,dV_db1]
   pder[*,ssb1] = dIQUV_db1


   ; dIQUV/dbz

   if Btotal EQ 0.0 then dlarmor_dbz = sbz*clarmor $
   else dlarmor_dbz = clarmor*bz/Btotal
   dvb_dbz = dlarmor_dbz/doppler

   dvfm_bz = -dvb_dbz
   dvfp_bz = +dvb_dbz

   dhl_dbz = 2.0*(a*fl-vfm*hl)*dvfm_bz
   dhr_dbz = 2.0*(a*fr-vfp*hr)*dvfp_bz
   dfl_dbz = -2.0*(a*hl+vfm*fl-one_over_sqrt_pi)*dvfm_bz
   dfr_dbz = -2.0*(a*hr+vfp*fr-one_over_sqrt_pi)*dvfp_bz
   
   dkappa_r_dbz = eta0 * dhr_dbz
   dkappa_l_dbz = eta0 * dhl_dbz
   dkappa_pr_dbz = eta0 * dfr_dbz
   dkappa_pl_dbz = eta0 * dfl_dbz
   dkappa_avg_dbz = (dkappa_r_dbz+dkappa_l_dbz)/2.0
   dkappa_pavg_dbz = (dkappa_pr_dbz+dkappa_pl_dbz)/2.0
   dkappa_p_avg_dbz = - dkappa_avg_dbz
   dkappa_pp_pavg_dbz = - dkappa_pavg_dbz

   if bt EQ 0. and bz EQ 0. then dgamma_dbz = 0.0 $
   else dgamma_dbz = -bt/(bz^2+bt^2)   ;atan(bt,bz)
   dcg_dbz = -sg*dgamma_dbz
   dsg_dbz = +cg*dgamma_dbz
   dsg2_dbz = 2.0*sg*dsg_dbz
   dcg2_dbz = 2.0*cg*dcg_dbz

   detaI_dbz = 0.5*(dkappa_avg_dbz*(1.0+cg2) + kappa_avg*dcg2_dbz + $
                    kappa_p*dsg2_dbz) 
   detaQ_dbz = 0.5*dkappa_p_avg_dbz*sg2*c2c + $
               0.5*kappa_p_avg*dsg2_dbz*c2c
   detaU_dbz = 0.5*dkappa_p_avg_dbz*sg2*s2c + $
               0.5*kappa_p_avg*dsg2_dbz*s2c 
   detaV_dbz = 0.5*(dkappa_r_dbz - dkappa_l_dbz)*cg + $
               0.5*(kappa_r - kappa_l)*dcg_dbz
   drhoQ_dbz = 0.5*dkappa_pp_pavg_dbz*sg2*c2c + $
               0.5*kappa_pp_pavg*dsg2_dbz*c2c
   drhoU_dbz = 0.5*dkappa_pp_pavg_dbz*sg2*s2c + $
               0.5*kappa_pp_pavg*dsg2_dbz*s2c
   drhoV_dbz = 0.5*(dkappa_pr_dbz - dkappa_pl_dbz)*cg + $
               0.5*(kappa_pr - kappa_pl)*dcg_dbz

   detaI1_dbz = detaI_dbz
   deta12_dbz = 2.0*etaI1*detaI1_dbz

   detaQ2_dbz = 2.0*etaQ*detaQ_dbz
   detaU2_dbz = 2.0*etaU*detaU_dbz
   detaV2_dbz = 2.0*etaV*detaV_dbz
   drhoQ2_dbz = 2.0*rhoQ*drhoQ_dbz
   drhoU2_dbz = 2.0*rhoU*drhoU_dbz
   drhoV2_dbz = 2.0*rhoV*drhoV_dbz

   derQUV_dbz = detaQ_dbz*rhoQ + etaQ*drhoQ_dbz+ $
                detaU_dbz*rhoU + etaU*drhoU_dbz + $
                detaV_dbz*rhoV + etaV*drhoV_dbz


   ddelta_dbz  =   deta12_dbz * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2)  $
               + eta12*(deta12_dbz-detaQ2_dbz-detaU2_dbz-detaV2_dbz+drhoQ2_dbz+drhoU2_dbz+drhoV2_dbz)  $
               - 2.0*erQUV*derQUV_dbz


   dmB1d_dbz = (-mB1d/delta)*ddelta_dbz
   

   dIm_dbz  = dmB1d_dbz*etaI1*(eta12+rhoQ2+rhoU2+rhoV2) + $
              mB1d*detaI1_dbz*(eta12+rhoQ2+rhoU2+rhoV2) + $
              mB1d*etaI1*(deta12_dbz+drhoQ2_dbz+drhoU2_dbz+drhoV2_dbz)

   dI_dbz = fill*dIm_dbz
   if NOT no_fit_qu then begin
      dQ_dbz = -fill*( dmB1d_dbz*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV) + rhoQ*erQUV) + $
                       mB1d*(  deta12_dbz*etaQ  + eta12*detaQ_dbz  + $
                               detaI1_dbz*(etaV*rhoU-etaU*rhoV) + $
                               etaI1*(detaV_dbz*rhoU+etaV*drhoU_dbz-detaU_dbz*rhoV-etaU*drhoV_dbz) + $
                               drhoQ_dbz*erQUV+rhoQ*derQUV_dbz)  $
                     )

      dU_dbz = -fill*(dmB1d_dbz*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV) + $
                      mB1d*(deta12_dbz*etaU + eta12*detaU_dbz +$
                            detaI1_dbz*(etaQ*rhoV-etaV*rhoQ) + $
                            etaI1*(detaQ_dbz*rhoV+etaQ*drhoV_dbz -detaV_dbz*rhoQ-etaV*drhoQ_dbz) + $
                            drhoU_dbz*erQUV+rhoU*derQUV_dbz) $
                     )
   endif
   dV_dbz = -fill*(dmB1d_dbz*(eta12*etaV + rhoV*erQUV) + $
                   mB1d*(deta12_dbz*etaV+eta12*detaV_dbz + drhoV_dbz*erQUV+rhoV*derQUV_dbz) $
                  )

   if no_fit_qu then dIQUV_dbz = [dI_dbz,dV_dbz] else dIQUV_dbz = [dI_dbz,dQ_dbz,dU_dbz,dV_dbz]
   
   pder[*,ssbz] = dIQUV_dbz

   ; dIQUV/dBx

   if Btotal EQ 0.0 then dlarmor_dbx = sbx*clarmor $
   ; Numerical problem with curvefit requires this
   else if bt EQ 0.0 then dlarmor_dbx = clarmor*sbx/Blimit $  ; nonzero
   else dlarmor_dbx = clarmor*bx/Btotal
   dvb_dbx = dlarmor_dbx/doppler

   dvfm_bx = -dvb_dbx
   dvfp_bx = +dvb_dbx

   dhr_dbx = 2.0*(a*fr-vfp*hr)*dvfp_bx
   dhl_dbx = 2.0*(a*fl-vfm*hl)*dvfm_bx
   dfr_dbx = -2.0*(a*hr+vfp*fr-one_over_sqrt_pi)*dvfp_bx
   dfl_dbx = -2.0*(a*hl+vfm*fl-one_over_sqrt_pi)*dvfm_bx

   dkappa_r_dbx = eta0 * dhr_dbx
   dkappa_l_dbx = eta0 * dhl_dbx
   dkappa_pr_dbx = eta0 * dfr_dbx
   dkappa_pl_dbx = eta0 * dfl_dbx
   dkappa_avg_dbx = (dkappa_r_dbx+dkappa_l_dbx)/2.0
   dkappa_p_avg_dbx =  -dkappa_avg_dbx
   dkappa_pavg_dbx = (dkappa_pr_dbx+dkappa_pl_dbx)/2.0
   dkappa_pp_pavg_dbx = -dkappa_pavg_dbx


   if Btotal EQ 0.0 then dgamma_dbx = 0.0 $
   else if bt EQ 0.0 then dgamma_dbx = 1./bz $
   else dgamma_dbx = (bx/bt)*bz/(bz^2+bt^2)
   dcg_dbx = -sg*dgamma_dbx
   dsg_dbx = +cg*dgamma_dbx
   dsg2_dbx = 2.0*sg*dsg_dbx
   dcg2_dbx = 2.0*cg*dcg_dbx

   if bt EQ 0.0 then dchi_dbx = 0.0 $
   else dchi_dbx = -by/(bt^2)
   ds2c_dbx = +2.0*c2c*dchi_dbx
   dc2c_dbx = -2.0*s2c*dchi_dbx

   detaI_dbx = 0.5*( dkappa_avg_dbx*(1.0+cg2) + $
                     kappa_avg*dcg2_dbx + $
                     kappa_p*dsg2_dbx $
                   )
   detaQ_dbx = 0.5*dkappa_p_avg_dbx*sg2*c2c + $
               0.5*kappa_p_avg*dsg2_dbx*c2c + $
               0.5*kappa_p_avg*sg2*dc2c_dbx
   detaU_dbx = 0.5*dkappa_p_avg_dbx*sg2*s2c + $
               0.5*kappa_p_avg*dsg2_dbx*s2c + $
               0.5*kappa_p_avg*sg2*ds2c_dbx 
   detaV_dbx = 0.5*(dkappa_r_dbx - dkappa_l_dbx)*cg + $
               0.5*(kappa_r - kappa_l)*dcg_dbx
   drhoQ_dbx = 0.5*dkappa_pp_pavg_dbx*sg2*c2c + $
               0.5*kappa_pp_pavg*dsg2_dbx*c2c + $
               0.5*kappa_pp_pavg*sg2*dc2c_dbx
   drhoU_dbx = 0.5*dkappa_pp_pavg_dbx*sg2*s2c + $
               0.5*kappa_pp_pavg*dsg2_dbx*s2c + $
               0.5*kappa_pp_pavg*sg2*ds2c_dbx
   drhoV_dbx = 0.5*(dkappa_pr_dbx - dkappa_pl_dbx)*cg + $
               0.5*(kappa_pr - kappa_pl)*dcg_dbx

   detaQ2_dbx = 2.0*etaQ*detaQ_dbx
   detaU2_dbx = 2.0*etaU*detaU_dbx
   detaV2_dbx = 2.0*etaV*detaV_dbx
   drhoQ2_dbx = 2.0*rhoQ*drhoQ_dbx
   drhoU2_dbx = 2.0*rhoU*drhoU_dbx
   drhoV2_dbx = 2.0*rhoV*drhoV_dbx

   derquv_dbx = detaQ_dbx*rhoQ + etaQ*drhoQ_dbx +$
                detaU_dbx*rhoU + etaU*drhoU_dbx +$
                detaV_dbx*rhoV + etaV*drhoV_dbx 

   detaI1_dbx = detaI_dbx
   deta12_dbx = 2.0*etaI1*detaI1_dbx

   ddelta_dbx =   deta12_dbx * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2)  $
               + eta12*(deta12_dbx-detaQ2_dbx-detaU2_dbx-detaV2_dbx+drhoQ2_dbx+drhoU2_dbx+drhoV2_dbx)  $
               - 2.0*erQUV*derQUV_dbx

   dmB1d_dbx = (-mB1d/delta)*ddelta_dbx

   dIm_dbx = dmB1d_dbx*etaI1*(eta12+rhoQ2+rhoU2+rhoV2) + $ 
             mB1d*detaI1_dbx*(eta12+rhoQ2+rhoU2+rhoV2) + $ 
             mB1d*etaI1*(deta12_dbx+drhoQ2_dbx+drhoU2_dbx+drhoV2_dbx)

   dI_dbx = fill*dIm_dbx
   if NOT no_fit_qu then begin
      dQ_dbx =-fill*( dmB1d_dbx*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV) + rhoQ*erQUV) + $
                       mB1d*(  deta12_dbx*etaQ  + eta12*detaQ_dbx  + $
                               detaI1_dbx*(etaV*rhoU-etaU*rhoV) + $
                               etaI1*(detaV_dbx*rhoU+etaV*drhoU_dbx-detaU_dbx*rhoV-etaU*drhoV_dbx) + $
                               drhoQ_dbx*erQUV+rhoQ*derQUV_dbx)  $
                     )
 
      dU_dbx =  -fill*(dmB1d_dbx*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV) + $
                      mB1d*(deta12_dbx*etaU + eta12*detaU_dbx +$
                            detaI1_dbx*(etaQ*rhoV-etaV*rhoQ) + $
                            etaI1*(detaQ_dbx*rhoV+etaQ*drhoV_dbx -detaV_dbx*rhoQ-etaV*drhoQ_dbx) + $
                            drhoU_dbx*erQUV+rhoU*derQUV_dbx) $
                     )
   endif
   dV_dbx = -fill*(dmB1d_dbx*(eta12*etaV + rhoV*erQUV) + $
                   mB1d*(deta12_dbx*etaV+eta12*detaV_dbx + drhoV_dbx*erQUV+rhoV*derQUV_dbx) $
                  )

   if no_fit_qu then dIQUV_dbx = [dI_dbx,dV_dbx] else dIQUV_dbx = [dI_dbx,dQ_dbx,dU_dbx,dV_dbx]
   
   pder[*,ssbx] = dIQUV_dbx


   ; dIQUV/dBy


   if NOT no_fit_qu then begin
      if Btotal EQ 0.0  then dlarmor_dby = sby*clarmor $
      ; Numerical problem with curvefit requires this
      else if bt EQ 0. then dlarmor_dby = clarmor*sby/Blimit $   ; nonzero
      else dlarmor_dby = clarmor*by/Btotal
      dvb_dby = dlarmor_dby/doppler

      dvfm_by = -dvb_dby
      dvfp_by = +dvb_dby

      dhr_dby = 2.0*(a*fr-vfp*hr)*dvfp_by
      dhl_dby = 2.0*(a*fl-vfm*hl)*dvfm_by
      dfr_dby = -2.0*(a*hr+vfp*fr-one_over_sqrt_pi)*dvfp_by
      dfl_dby = -2.0*(a*hl+vfm*fl-one_over_sqrt_pi)*dvfm_by

      dkappa_r_dby = eta0 * dhr_dby
      dkappa_l_dby = eta0 * dhl_dby
      dkappa_pr_dby = eta0 * dfr_dby
      dkappa_pl_dby = eta0 * dfl_dby
      dkappa_avg_dby = (dkappa_r_dby+dkappa_l_dby)/2.0
      dkappa_p_avg_dby =  -dkappa_avg_dby
      dkappa_pavg_dby = (dkappa_pr_dby+dkappa_pl_dby)/2.0
      dkappa_pp_pavg_dby = -dkappa_pavg_dby

      if Btotal EQ 0.0 then dgamma_dby = 0.0 $
      else if bt EQ 0.0 then dgamma_dby = 1.0/bz $
      else dgamma_dby = (by/bt)*bz/(bz^2+bt^2)
      dcg_dby = -sg*dgamma_dby
      dsg_dby = +cg*dgamma_dby
      dsg2_dby = 2.0*sg*dsg_dby
      dcg2_dby = 2.0*cg*dcg_dby

      if bt EQ 0.0 then dchi_dby = 0.0 $
      else dchi_dby = bx/(bt^2)
      ds2c_dby = +2.0*c2c*dchi_dby
      dc2c_dby = -2.0*s2c*dchi_dby

      detaI_dby = 0.5*( dkappa_avg_dby*(1.0+cg2) + $
                        kappa_avg*dcg2_dby + $
                        kappa_p*dsg2_dby $
                      )
      detaQ_dby = 0.5*dkappa_p_avg_dby*sg2*c2c + $
                  0.5*kappa_p_avg*dsg2_dby*c2c + $
                  0.5*kappa_p_avg*sg2*dc2c_dby
      detaU_dby = 0.5*dkappa_p_avg_dby*sg2*s2c + $
                  0.5*kappa_p_avg*dsg2_dby*s2c + $
                  0.5*kappa_p_avg*sg2*ds2c_dby
      detaV_dby = 0.5*(dkappa_r_dby - dkappa_l_dby)*cg + $
                  0.5*(kappa_r - kappa_l)*dcg_dby
      drhoQ_dby = 0.5*dkappa_pp_pavg_dby*sg2*c2c + $
                  0.5*kappa_pp_pavg*dsg2_dby*c2c + $
                  0.5*kappa_pp_pavg*sg2*dc2c_dby
      drhoU_dby = 0.5*dkappa_pp_pavg_dby*sg2*s2c + $
                  0.5*kappa_pp_pavg*dsg2_dby*s2c + $
                  0.5*kappa_pp_pavg*sg2*ds2c_dby
      drhoV_dby = 0.5*(dkappa_pr_dby - dkappa_pl_dby)*cg + $
                  0.5*(kappa_pr - kappa_pl)*dcg_dby

      detaQ2_dby = 2.0*etaQ*detaQ_dby
      detaU2_dby = 2.0*etaU*detaU_dby
      detaV2_dby = 2.0*etaV*detaV_dby
      drhoQ2_dby = 2.0*rhoQ*drhoQ_dby
      drhoU2_dby = 2.0*rhoU*drhoU_dby
      drhoV2_dby = 2.0*rhoV*drhoV_dby

      derquv_dby = detaQ_dby*rhoQ + etaQ*drhoQ_dby +$
                   detaU_dby*rhoU + etaU*drhoU_dby +$
                   detaV_dby*rhoV + etaV*drhoV_dby 

      detaI1_dby = detaI_dby
      deta12_dby = 2.0*etaI1*detaI1_dby

      ddelta_dby =   deta12_dby * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2)  $
                  + eta12*(deta12_dby-detaQ2_dby-detaU2_dby-detaV2_dby+drhoQ2_dby+drhoU2_dby+drhoV2_dby)  $
                  - 2.0*erQUV*derQUV_dby

      dmB1d_dby = (-mB1d/delta)*ddelta_dby

      dIm_dby = dmB1d_dby*etaI1*(eta12+rhoQ2+rhoU2+rhoV2) + $ 
                mB1d*detaI1_dby*(eta12+rhoQ2+rhoU2+rhoV2) + $ 
                mB1d*etaI1*(deta12_dby+drhoQ2_dby+drhoU2_dby+drhoV2_dby)

      dI_dby = fill*dIm_dby
      if NOT no_fit_qu then begin
         dQ_dby = -fill*( dmB1d_dby*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV) + rhoQ*erQUV) + $
                          mB1d*(  deta12_dby*etaQ  + eta12*detaQ_dby  + $
                                  detaI1_dby*(etaV*rhoU-etaU*rhoV) + $
                                  etaI1*(detaV_dby*rhoU+etaV*drhoU_dby-detaU_dby*rhoV-etaU*drhoV_dby) + $
                                  drhoQ_dby*erQUV+rhoQ*derQUV_dby)  $
                        )
         dU_dby = -fill*(dmB1d_dby*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV) + $
                         mB1d*(deta12_dby*etaU + eta12*detaU_dby +$
                               detaI1_dby*(etaQ*rhoV-etaV*rhoQ) + $
                               etaI1*(detaQ_dby*rhoV+etaQ*drhoV_dby -detaV_dby*rhoQ-etaV*drhoQ_dby) + $
                               drhoU_dby*erQUV+rhoU*derQUV_dby) $
                        )
      endif
      dV_dby = -fill*(dmB1d_dby*(eta12*etaV + rhoV*erQUV) + $
                      mB1d*(deta12_dby*etaV+eta12*detaV_dby + drhoV_dby*erQUV+rhoV*derQUV_dby) $
                     )


      dIQUV_dby = [dI_dby,dQ_dby,dU_dby,dV_dby]
   
      pder[*,ssby] = dIQUV_dby
   endif


   ; dIQUV/dfill

   if NOT no_fit_fill then begin
      dI_df = Im - Inm
      if NOT no_fit_qu then begin
         dQ_df = -mB1d*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV) + rhoQ*erQUV)
         dU_df = -mB1d*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV)
      endif
      dV_df = -mB1d*(eta12*etaV + rhoV*erQUV)

      if min(dI_df) EQ 0.0 and max(dI_df) EQ 0.0 then dI_df = -Inm*0.001

      if no_fit_qu then dIQUV_df = [dI_df,dV_df] else dIQUV_df = [dI_df,dQ_df,dU_df,dV_df]
      pder[*,ssfill] = dIQUV_df

      if fit_x1 then begin
         ; dIQUV/dx1

         dvf_dx1 = -1.0/dopplerl
         dhnm_dx1 = 2.0*(a*fnm-vfnm*hnm)*dvf_dx1
         dkappa_p_nm_dx1 = eta0 * dhnm_dx1
         dInm_dx1 = -mu*B1*(dkappa_p_nm_dx1)/(1.+kappa_p_nm)^2
         if fill GE 0.9 then $
            dI_dx1 = 0.1*dInm_dx1 $  ; If the deriv gets too small, x1 will go out of range
         else $
            dI_dx1 = (1.0-fill)*dInm_dx1
      
         if no_fit_qu then dIQUV_dx1 = [dI_dx1,fltarr(n_elements(dInm_dx1))] $
         else dIQUV_dx1 = [dI_dx1,fltarr(3*n_elements(dInm_dx1))]

         pder[*,ssx1] = dIQUV_dx1
      endif

   endif


   ; dIQUV/dx0

   dvf_dx0 = -1.0/dopplerl
   dvfm_dx0 = dvf_dx0
   dvfp_dx0 = dvf_dx0

   dh_dx0 = 2.0*(a*f-vf*h)*dvf_dx0
   if NOT no_fit_fill then dhnm_dx0 = 2.0*(a*fnm-vfnm*hnm)*dvf_dx0
   dhl_dx0 = 2.0*(a*fl-vfm*hl)*dvfm_dx0
   dhr_dx0 = 2.0*(a*fr-vfp*hr)*dvfp_dx0
   df_dx0 = -2.0*(a*h+vf*f-one_over_sqrt_pi)*dvf_dx0
   dfl_dx0 = -2.0*(a*hl+vfm*fl-one_over_sqrt_pi)*dvfm_dx0
   dfr_dx0 = -2.0*(a*hr+vfp*fr-one_over_sqrt_pi)*dvfp_dx0

   dkappa_p_dx0 = eta0 * dh_dx0
   if NOT no_fit_fill then dkappa_p_nm_dx0 = eta0 * dhnm_dx0
   dkappa_r_dx0 = eta0 * dhr_dx0
   dkappa_l_dx0 = eta0 * dhl_dx0
   dkappa_avg_dx0 = (dkappa_r_dx0+dkappa_l_dx0)/2.0
   dkappa_p_avg_dx0 = dkappa_p_dx0 - dkappa_avg_dx0
   dkappa_pr_dx0 = eta0 * dfr_dx0
   dkappa_pl_dx0 = eta0 * dfl_dx0
   dkappa_pp_dx0 = eta0 * df_dx0
   dkappa_pavg_dx0 = (dkappa_pr_dx0+dkappa_pl_dx0)/2.0
   dkappa_pp_pavg_dx0 = dkappa_pp_dx0 - dkappa_pavg_dx0

   detaI_dx0 = 0.5*(dkappa_avg_dx0*(1.0+cg2) + dkappa_p_dx0*sg2)
   detaQ_dx0 = 0.5*dkappa_p_avg_dx0*sg2*c2c
   detaU_dx0 = 0.5*dkappa_p_avg_dx0*sg2*s2c
   detaV_dx0 = 0.5*(dkappa_r_dx0 - dkappa_l_dx0)*cg
   drhoQ_dx0 = 0.5*dkappa_pp_pavg_dx0*sg2*c2c
   drhoU_dx0 = 0.5*dkappa_pp_pavg_dx0*sg2*s2c
   drhoV_dx0 = 0.5*(dkappa_pr_dx0 - dkappa_pl_dx0)*cg

   detaQ2_dx0 = 2.0*etaQ*detaQ_dx0
   detaU2_dx0 = 2.0*etaU*detaU_dx0
   detaV2_dx0 = 2.0*etaV*detaV_dx0
   drhoQ2_dx0 = 2.0*rhoQ*drhoQ_dx0
   drhoU2_dx0 = 2.0*rhoU*drhoU_dx0
   drhoV2_dx0 = 2.0*rhoV*drhoV_dx0

   derquv_dx0 = detaQ_dx0*rhoQ + etaQ*drhoQ_dx0 +$
                detaU_dx0*rhoU + etaU*drhoU_dx0 +$
                detaV_dx0*rhoV + etaV*drhoV_dx0 

   detaI1_dx0 = detaI_dx0
   deta12_dx0 = 2.0*etaI1*detaI1_dx0

   ddelta_dx0 =   deta12_dx0 * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2)  $
               + eta12*(deta12_dx0-detaQ2_dx0-detaU2_dx0-detaV2_dx0+drhoQ2_dx0+drhoU2_dx0+drhoV2_dx0)  $
               - 2.0*erQUV*derQUV_dx0

   dmB1d_dx0 = (-mB1d/delta)*ddelta_dx0



   dIm_dx0 = dmB1d_dx0*etaI1*(eta12+rhoQ2+rhoU2+rhoV2) + $
             mB1d*detaI1_dx0*(eta12+rhoQ2+rhoU2+rhoV2) + $
             mB1d*etaI1*(deta12_dx0+drhoQ2_dx0+drhoU2_dx0+drhoV2_dx0)

   if NOT no_fit_fill then dInm_dx0 = -(dkappa_p_nm_dx0*mu*B1)/((1.+kappa_p_nm)^2) else dInm_dx0 = 0.

   dI_dx0 = fill*dIm_dx0 + (1.0-fill)*dInm_dx0
   if NOT no_fit_qu then begin
      dQ_dx0 = -fill*(dmB1d_dx0*(eta12*etaQ+etaI1*(etaV*rhoU-etaU*rhoV)+rhoQ*erQUV) + $
                     mB1d*(deta12_dx0*etaQ + eta12*detaQ_dx0 + $
                           detaI1_dx0*(etaV*rhoU-etaU*rhoV) + $
                           etaI1*(detaV_dx0*rhoU+etaV*drhoU_dx0-detaU_dx0*rhoV-etaU*drhoV_dx0) + $
                           drhoQ_dx0*erQUV+rhoQ*derQUV_dx0) $
                    )
      dU_dx0 = -fill*( dmB1d_dx0*(eta12*etaU+etaI1*(etaQ*rhoV-etaV*rhoQ) + rhoU*erQUV) + $
                      mB1d*( deta12_dx0*etaU + eta12*detaU_dx0 + $
                             detaI1_dx0*(etaQ*rhoV-etaV*rhoQ) + $
                             etaI1*(detaQ_dx0*rhoV+etaQ*drhoV_dx0-detaV_dx0*rhoQ-etaV*drhoQ_dx0) +$
                             drhoU_dx0*erQUV+rhoU*derQUV_dx0 $
                           ) $
                    )
   endif
   dV_dx0 = -fill*(  dmB1d_dx0*(eta12*etaV + rhoV*erQUV) + $
                    mB1d*(deta12_dx0*etaV+eta12*detaV_dx0  + drhoV_dx0*erQUV+rhoV*derQUV_dx0) $
                  )


   if no_fit_qu then dIQUV_dx0 = [dI_dx0,dV_dx0] else dIQUV_dx0 = [dI_dx0,dQ_dx0,dU_dx0,dV_dx0]
   
   pder[*,ssx0] = dIQUV_dx0

   ; convolve the derivatives with the spectral response.

   if use_sp_profile AND NOT keyword_set(no_instrument_response) then begin
      for itrm=0,nterms-1 do begin
         for istk=0,nstokes-1 do begin
            if use_double then $
               pder[nx*istk:nx*(istk+1)-1,itrm] = $
                  double(fft(fft(pder[nx*istk:nx*(istk+1)-1,itrm],-1,/double)*fftprofile,+1,/double)) $
            else $
               pder[nx*istk:nx*(istk+1)-1,itrm] = $
                  float(fft(fft(pder[nx*istk:nx*(istk+1)-1,itrm],-1)*fftprofile,+1))
         endfor
      endfor
   endif

end

;--------------------------------------------------------------

function dImdl, x, aiquv

   ; compute the derivative of the magnetic I profile wrt lambda

   common stokes_fit_private,nterms,npoints,nstokes,nofitd,nofita, $
                              one_over_sqrt_pi,plot,verbose, $
                              use_double,no_fit_fill,no_fit_qu,min_fill, $
                              alimit,dlimit,elimit,x0min,x0max,fit_x1,x1limit, $
                              fftprofile,use_sp_profile
   common stokes_fit_private_iquv,wave, $  ; wave in cm!!!
                                  glande, $
                                  mu, $
                                  clight, $
                                  elec, $
                                  me,eps,deps,Blimit,clarmor
   common stokes_fit_private_indices,ssa,ssdopp,sseta0,sseta0nm,ssb0,ssb0nm,ssb1,ssbz,ssbx,ssby,ssfill,ssx1,ssx0


   a        = aiquv[ssa]                       ; Voigt parameter
   dopplerl = aiquv[ssdopp]                       ; Doppler width in A
   eta0     = aiquv[sseta0]                       ; absorption coefficient
   ;if NOT no_fit_fill then eta0nm   = aiquv[sseta0nm]                       ; abs coeff non-magnetic
   b0       = aiquv[ssb0]                       ; coeff of linear source function
   ;if NOT no_fit_fill then b0nm     = aiquv[ssb0nm]                       ; coeff of LSF, non-magnetic
   b1       = aiquv[ssb1]                       ; coeff of linear source function
   bz       = aiquv[ssbz]                       ; Bcos(gamma)
   bx       = aiquv[ssbx]                       ; -Bsin(gamma)sin(chi)
   if no_fit_qu then begin                   ; btrans is 0 if not fitting Q,U
      by = 0.
   endif else begin
      by       = aiquv[ssby]                    ; +Bsin(gamma)cos(chi)
   endelse
   bt       = sqrt(bx^2+by^2)                ; Btrans
   chi      = atan(-bx,by)                   ; chi
   btotal   = sqrt(bz^2+bt^2)                ; Btotal
   gamma    = atan(bt,bz)                    ; gamma
   x0       = aiquv[ssx0]                    ; Line center
   if no_fit_fill then begin
      fill     = 1.0                         ; filling factor 
      x1       = 0.0
   endif else begin
      fill     = aiquv[ssfill]                 ; filling factor 
      if fit_x1 then begin
         x1       = aiquv[ssx1]                 ; Line center of non-magnetic profile
      endif else begin
         x1       = 0.
      endelse
   endelse

   if no_fit_qu then bt = aiquv[ssbx] else bt = sqrt(aiquv[ssbx]^2+aiquv[ssby]^2)
   Btotal = sqrt(aiquv[ssbz]^2+ bt^2)

   doppler = (clight/wave^2)*dopplerl*1.0e-8 ; Hz ...  dopplerl in A
   larmor = clarmor*Btotal
   vb = larmor/doppler

   vf = (x-x0)/dopplerl
   vfp = vf+vb
   vfm = vf-vb

   voigt, a, vf, h, f
   voigt, a, vfp, hr, fr
   voigt, a, vfm, hl, fl

   kappa_p = eta0 * h
   kappa_r = eta0 * hr
   kappa_l = eta0 * hl
   kappa_avg = (kappa_r+kappa_l)/2.0

   kappa_pp = eta0 * f
   kappa_pr = eta0 * fr
   kappa_pl = eta0 * fl
   kappa_pavg = (kappa_pr+kappa_pl)/2.0

   kappa_p_avg   = kappa_p - kappa_avg
   kappa_pp_pavg = kappa_pp - kappa_pavg
   cg = cos(gamma)
   sg = sin(gamma)
   sg2 = (sg)^2
   cg2 = (cg)^2
   c2c = cos(2*chi)
   s2c = sin(2*chi)

   etaI = 0.5*(kappa_avg*(1.0+cg2) + kappa_p*sg2)
   etaQ = 0.5*kappa_p_avg*sg2*c2c
   etaU = 0.5*kappa_p_avg*sg2*s2c
   etaV = 0.5*(kappa_r - kappa_l)*cg

   rhoQ = 0.5*kappa_pp_pavg*sg2*c2c
   rhoU = 0.5*kappa_pp_pavg*sg2*s2c
   rhoV = 0.5*(kappa_pr - kappa_pl)*cg

   ; These are used more than once so save time by saving results

   etaI1 = (1+etaI)
   eta12 = etaI1^2
   erQUV = etaQ*rhoQ+etaU*rhoU+etaV*rhoV
   etaQ2 = etaQ^2
   etaU2 = etaU^2
   etaV2 = etaV^2
   rhoQ2 = rhoQ^2
   rhoU2 = rhoU^2
   rhoV2 = rhoV^2
   delta = eta12 * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2) - erQUV^2

   mB1d = mu*B1/delta

   Im = fill*(B0 + mB1d*etaI1*(eta12+rhoQ2+rhoU2+rhoV2))

   dvdl = 1.0/dopplerl

   dhdv = 2.0*(a*f-vf*h)
   dhrdv = 2.0*(a*fr-vfp*hr)
   dhldv = 2.0*(a*fl-vfm*hl)
   dfdv = -2.0*(a*h+vf*f-one_over_sqrt_pi)
   dfrdv = -2.0*(a*hr+vfp*fr-one_over_sqrt_pi)
   dfldv = -2.0*(a*hl+vfm*fl-one_over_sqrt_pi)

   dhdl = dhdv*dvdl
   dhrdl = dhrdv*dvdl
   dhldl = dhldv*dvdl
   dfdl = dfdv*dvdl
   dfrdl = dfrdv*dvdl
   dfldl = dfldv*dvdl
   
   dkappa_pdl = eta0 * dhdl
   dkappa_rdl = eta0 * dhrdl
   dkappa_ldl = eta0 * dhldl
   dkappa_avgdl = (dkappa_rdl+dkappa_ldl)/2.0
   dkappa_ppdl = eta0 * dfdl
   dkappa_prdl = eta0 * dfrdl
   dkappa_pldl = eta0 * dfldl
   dkappa_pavgdl = (dkappa_prdl+dkappa_pldl)/2.0
   dkappa_p_avgdl = dkappa_pdl - dkappa_avgdl
   dkappa_pp_pavgdl = dkappa_ppdl - dkappa_pavgdl

   detaIdl = 0.5*(dkappa_avgdl*(1.0+cg2) + dkappa_pdl*sg2)
   deta12dl = 2*etaI1*detaIdl
   detaQdl = 0.5*dkappa_p_avgdl*sg2*c2c
   detaUdl = 0.5*dkappa_p_avgdl*sg2*s2c
   detaVdl = 0.5*(dkappa_rdl - dkappa_ldl)*cg
   drhoQdl = 0.5*dkappa_pp_pavgdl*sg2*c2c
   drhoUdl = 0.5*dkappa_pp_pavgdl*sg2*s2c
   drhoVdl = 0.5*(dkappa_prdl - dkappa_pldl)*cg

   detaQ2dl = 2.*etaQ*detaQdl
   detaU2dl = 2.*etaU*detaUdl
   detaV2dl = 2.*etaV*detaVdl

   drhoQ2dl = 2.*rhoQ*drhoQdl
   drhoU2dl = 2.*rhoU*drhoUdl
   drhoV2dl = 2.*rhoV*drhoVdl

   derQUVdl = detaQdl*rhoQ + etaQ*drhoQdl + $
              detaUdl*rhoU + etaU*drhoUdl +$
              detaVdl*rhoV + etaV*drhoVdl

   ddeltadl = eta12 * (deta12dl-detaQ2dl-detaU2dl-detaV2dl+drhoQ2dl+drhoU2dl+drhoV2dl) + $
              deta12dl * (eta12-etaQ2-etaU2-etaV2+rhoQ2+rhoU2+rhoV2) - $
              2.*erQUV*derQUVdl

   return,fill * (mB1d*(eta12+rhoQ2+rhoU2+rhoV2)*detaIdl + $
                  mB1d*etaI1*(deta12dl+drhoQ2dl+drhoU2dl+drhoV2dl) - $
                  mu*B1*etaI1*(eta12+rhoQ2+rhoU2+rhoV2)*ddeltadl/delta^2)



end

;--------------------------------------------------------------

function voigt_funct_iquv_lmfit, x, a, initialize=init

   ; Function used to drive the lmfit algorithm

   common stokes_fit_private_chi2_iquv,dlambda,iquv,weight,dfpscale,nstokes
   common voigt_funct_iquv_lmfit_private1,sresults,presults,lasta,computed,ndl,nx,na

   ; LMFIT does one point at a time, but the result from
   ; voigt_funct_iquv has I,Q,U, and V all at once so 
   ; we need to store the results to avoid computing 
   ; everything four times.  Also, it is very inefficient
   ; to do the IQUV calculation one lambda at a time.  So,
   ; compute all wavelenths whenever the parameters change
   ; and save them. Much more efficient.

   if keyword_set(init) then begin  ; Must be initialized on the first call
      ndl = n_elements(dlambda)
      nx = n_elements(x)
      na = n_elements(a)
      sresults = make_array(ndl,nstokes,type=size(iquv,/type))
      presults = make_array(ndl,nstokes,na,type=size(iquv,/type))
      computed = make_array(ndl,nstokes,/byte,value=0)
      lasta = a
   endif

   if total(lasta EQ a) NE na OR keyword_set(init) then begin
      computed[*] = 0b
      lasta = a
      ; the following may be commented out.  It seems that lmfit
      ; just cycles through all the lambdas, one at a time, which 
      ; is not very efficient.  I'm not sure if this is always the 
      ; case, but it is much more efficient to compute them all at
      ; once, if so.  If the following is commented out, then the 
      ; values will be computed below, one at a time.
      voigt_funct_iquv,dlambda,a,fout,pder
      for i=0L,nstokes-1L do begin
         sresults[*,i] = fout[ndl*i:ndl*(i+1L)-1L]
         presults[*,i,*] = pder[ndl*i:ndl*(i+1L)-1L,*]
      endfor
      computed[*] = 1b
   endif

   xs = long(x MOD ndl) ; Which lambda is this?
   st = long(x / ndl)   ; Is this I, Q, U, or V?

   if NOT keyword_set(computed[xs,st]) then begin  ; Computed already?
      voigt_funct_iquv,dlambda[xs],a,fout,pder
      sresults[xs,*] = fout
      presults[xs,*,*] = pder
      computed[xs,*] = 1b
   endif
 
   if keyword_set(init) then return,1 $
   else return,[sresults[xs,st],reform(presults[xs,st,*])]

end

;--------------------------------------------------------------

function dfp_deriv_iquv,guess
   ; Compute deriv of chi^2 for the dfpmin algorithm
   common stokes_fit_private_chi2_iquv,dlambda,iquv,weight,dfpscale,nstokes
   g = guess*dfpscale[1:*]  ; rescale and protect guess from changing
   voigt_funct_iquv,dlambda,g,fout,pder
   d = make_array(size=size(g),value=0.0)
   for i=0,n_elements(g)-1 do begin
      d[i] = -2.0*total(weight*(iquv-fout)*pder[*,i])*dfpscale[i+1]/dfpscale[0]
   endfor
   return,d
end

;--------------------------------------------------------------

function chi2_iquv,guess,fout,dolimits=dolimits
   ; Compute chi^2 for the Unno profiles
   common stokes_fit_private_chi2_iquv,dlambda,iquv,weight,dfpscale,nstokes
   ; The scaling, dfpscale, is only used with dfpmin, otherwise it is 
   ; all ones.
   if NOT keyword_set(dolimits) then begin
      g = guess*dfpscale[1:*]  ; scale protect guess from changing
      voigt_funct_iquv,dlambda,g,fout
   endif else $  ; Caution: no rescaling is done when dolimits is set!
      voigt_funct_iquv,dlambda,guess,fout  ; modify guess according to limits
   chi2 = total((iquv-fout)^2*weight)/dfpscale[0]
   return,chi2
end



;--------------------------------------------------------------

function pikaia_iquv, n, x
   common stokes_fit_private_pikaia1,pikaiamax,pikaiamin,pikaiaseed,npoints

   ; rescale the parameters since they are [0,1] in pikaia
   chi2 = chi2_iquv(x*(pikaiamax-pikaiamin) + pikaiamin,fout)
   if NOT finite(chi2) then chi2 = (n+npoints)*1000.0
   return,-chi2  ; negative since pikaia is a maximizer not a minimizer

end

;--------------------------------------------------------------

function iquv_wiener_filter,a,verbose=verbose, double=double

;     Derives an optimal Wiener filter for regularizing the spectral
;     deconvolution.  This follows the suggestion in Numerical
;     Recipes to fit the noise at high frequencies and the signal at
;     low frequencies.

   sa = size(a)
   n = sa[1]
   pa = abs(fft(a*hanning(n,alpha=0.54,double=double),-1,double=double))^2  ; power spectrum of a

   ; use the power only for the positive frequencies since
   ; the power is symmetric about zero freq for real functions
   ; and the negative frequencies would not add any information.
   n21 = n/2+1
   if keyword_set(double) then f = dindgen(n21) else f = findgen(n21)
   pa = pa[0:n21-1]
   pi2 = 1.0/(!pi*!pi) ; spectral leakage falls off as 1/(s*pi^2), s=bin #
   pa = convol(pa,[pi2,1.0-2.0*pi2,pi2],/edge_truncate,/center) ; a little smoothing

   n2 = n21/2  ; latter half to get noise

   ; Fit the noise at high freq and the signal at low freq
   ; As described in Numerical Recipes

   ; Fit the noise^2 at high freq with an exponential
   plog = alog((pa[n2:*])>(min(pa[n2:*])/1000.))
   ncoeff = poly_fit(f[n2:*],plog,1, $
                     measure_errors=sqrt(1./(1.0+findgen(n21-n2))), $
                     sigma=sigma)  ; fit noise
   ; Add 1 sigma noise so the fit is to the upper range of the noise
   noise2  = exp((ncoeff[0]+sigma[0]) + f*ncoeff[1])

   ; fit the signal^2 with a Gaussian.  The repeat is necessary since gaussfit
   ; sometimes does not converge fast enough in its curvefit call.
   pas = (pa-noise2)
   i = 0L
   q = !quiet & !quiet = 1
   signal2 = gaussfit(f[0:n2],pas[0:n2],scoeff,nterms=3) ; get a guess at low freq
   REPEAT begin
      sold = scoeff
      signal2 = gaussfit(f,pas,scoeff,nterms=3,estimates=scoeff)  ; Fit the Gaussian
      i = i+1L
   endrep UNTIL max(abs((sold-scoeff)/scoeff)) LE 1.e-3 OR i GE 100
   !quiet = q
   signal2=signal2>0.0

   if keyword_set(verbose) then begin  ; Plot the results
      plot,f,pa,/yst,/ylog,title='Wiener Filter'
      oplot,f,noise2,linestyle=1,color=!d.table_size/2
      oplot,f,signal2,linestyle=2,color=!d.table_size/2
      oplot,f,signal2+noise2,linestyle=3,color=!d.table_size/2
   endif

   w = signal2/(signal2+noise2)   ; Wiener filter
   w = [w,rotate(w[0:n21-1-(n MOD 2)],2)]  ; add the negative freq back in

   return,w

end

;--------------------------------------------------------------



function stokesfit,Istin,Qstin,Ustin,Vstin,dlambdain,dl_deriv, $
                  glandein,lambda,muin, $
                  verbose=verbosein,quiet=quietin,plot=plotin, $
                  guess=guessin,aiquv=aiquv,kernel=kernel, $
                  use_curvefit=use_curvefit,use_amoeba=use_amoeba, $
                  use_powell=use_powell,use_dfpmin=use_dfpmin, $
                  use_lmfit=use_lmfit,use_genetic=use_genetic, $
                  double=use_doublein, $
                  doppguess=doppguess,vpguess=vpguess, $
                  eta0guess=eta0guess, eta0nmguess=eta0nmguess, $
                  b0guess=b0guess, b0nmguess=b0nmguess, b1guess=b1guess, $
                  x0guess=x0guess, x1guess=x1guess, $
                  smooth=dosmooth, nofitfill=nofitfill, $
                  nofitqu=nofitqu,sigma=sigma,decimalplaces=decimalplaces, $
                  nofitmagcenter=nofitx1,fitmaglimit=fitx1lim, $
                  amoeba_nmax=amoeba_nmax,ngenerations=ngenerations, $
                  spprofile=spprofilein, spdeconvolve=spdeconvolve, $
                  wiquv=wiquv, weight=weightin, $
                  cfit_itmax=cfit_itmax, nofixplotrange=nofixplotrange, $
                  nocheckguess=nocheckguess,min_fill=min_fill_in, $
                  ssa=kssa,ssdopp=kssdopp,sseta0mg=ksseta0,sseta0nm=ksseta0nm, $
                  ssb0mg=kssb0,ssb0nm=kssb0nm,ssb1=kssb1,ssbz=kssbz,ssbx=kssbx, $
                  ssby=kssby,ssfill=kssfill,ssx1=kssx1,ssx0=kssx0, $
                  use_observed_derivative=use_observed_derivative


 
   common stokes_fit_private,nterms,npoints,nstokes,nofitd,nofita, $
                             one_over_sqrt_pi,plot,verbose,use_double, $
                             no_fit_fill,no_fit_qu,min_fill, $
                             alimit,dlimit,elimit,x0min,x0max,fit_x1,x1limit, $
                             fftprofile,use_sp_profile
   common stokes_fit_private_iquv,wave, $  ; wave in cm!!!
                                  glande, $
                                  mu, $
                                  clight, $
                                  elec, $
                                  me,eps,deps,Blimit,clarmor
   common stokes_fit_private_chi2_iquv,dlambda,iquv,weight,dfpscale,nstokes1
   common stokes_fit_private_indices,ssa,ssdopp,sseta0,sseta0nm,ssb0,ssb0nm,ssb1,ssbz,ssbx,ssby,ssfill,ssx1,ssx0
   common stokes_fit_private_pikaia1,pikaiamax,pikaiamin,pikaiaseed,npikaiapoints

   version = 3.11

   if keyword_set(plotin) then plot=1 else plot=0
   if keyword_set(plot) then begin
     pmulti = !p.multi
     !p.multi = [0,2,2,0]
   endif
   except = !except
   !except=0

   if keyword_set(use_doublein) then use_double=1 else use_double=0

   if use_double then one_over_sqrt_pi = 1.0/sqrt(!dpi) $
   else one_over_sqrt_pi = 1.0/sqrt(!pi)
   if use_double then clight = 2.99792458d10 else clight = 2.99792458e10   ; cm/s
   if use_double then elec = 4.80653d-10 else elec = 4.80653e-10     ; esu
   if use_double then me = 9.1093826d-28 else me = 9.1093826e-28       ; g

   res = machar()
   eps = sqrt(res.eps)
   deps = sqrt((machar(/double)).eps)

   if keyword_set(min_fill_in) then min_fill = (float(min_fill_in)<1.0)>0.0 $
   else min_fill = 0.0 ; minimum allowed filling factor

   ; These parameter upper limits should be something like 3 times 
   ; the largest value expected.
   if use_double then Blimit = 1.0d4 $ ; A magnetic field that is much larger than expected. 
   else Blimit = 1.0e4
   if use_double then min_fill = double(min_fill)
   if use_double then alimit = 100.d0 else alimit = 100.0 ; Voigt parameter upper limit
   if use_double then dlimit = lambda/50.d0 else dlimit = lambda/50.0 ; Doppler width upper limit (A)
   if use_double then elimit = 1000.d0 else elimit = 1000.0 ; Eta0 upper limit
   ; The limit on x1 prevents the magnetic and non-magnetic line
   ; centers from differing by more than 10 km/sec.
   if use_double then x1limit = lambda*10.0d0/3.d5 else x1limit = lambda*10.0/3.e5; x1 upper limit

   if n_elements(fitx1lim) NE 1 then fitx1lim = 0.0  ; min polarization to fit mag center

   nofitd=0
   nofita=0

   if n_elements(guessin) GT 0 then guess = guessin ; protect the input from change

   if n_elements(ngenerations) NE 1 then ngenerations = 1000L

   nist = n_elements(istin)
   if keyword_set(nofitqu) then no_fit_qu=1 else no_fit_qu=0
   if (n_elements(qstin) NE nist AND NOT keyword_set(nofitqu)) OR $
      (n_elements(ustin) NE nist AND NOT keyword_set(nofitqu)) OR $
      n_elements(vstin) NE nist OR $
      n_elements(dlambdain) NE nist then $
      message,'ERROR: I, Q, U, V, and dlambda must have the same size'
   if use_double then wave = double(lambda) * 1.0d-8 else wave = float(lambda) * 1.0e-8 ; in cm
   if use_double then mu = double(muin) else mu = float(muin)
   if use_double then glande = double(glandein) else glande = float(glandein)
   if use_double then dlambda = double(dlambdain) else dlambda = float(dlambdain)
   x0min = min(dlambda)  ; lower limit on line center - line must be in view!
   x0max = max(dlambda)  ; upper limit on line center
   dispersion = abs(total((dlambda - shift(dlambda,1))[1:*])/(nist-1.0)) ; mean dispersion
   clarmor = (glande*elec)/(4.0*(!pi)*me*clight)
   if NOT keyword_set(dl_deriv) then dl_deriv = 0.1
   if keyword_set(verbosein) then verbose=1 else verbose=0
   if keyword_set(quietin) then quiet=1 else quiet=0
   if NOT keyword_set(amoeba_nmax) then amoeba_nmax = 20000L
   if NOT keyword_set(cfit_itmax) then cfit_itmax = 1000L else cfit_itmax=long(cfit_itmax[0])>20L

   if keyword_set(use_curvefit) then begin
      use_dfpmin = 0
      use_amoeba = 0
      use_powell = 0
      use_lmfit = 0
      use_genetic = 0
   endif
   if keyword_set(use_lmfit) then begin
      use_dfpmin = 0
      use_powell = 0
      use_curvefit = 0
      use_amoeba = 0
      use_genetic = 0
   endif
   if keyword_set(use_dfpmin) then begin
      use_amoeba = 0
      use_powell = 0
      use_curvefit = 0
      use_lmfit = 0
      use_genetic = 0
   endif
   if keyword_set(use_powell) then begin
      use_dfpmin = 0
      use_amoeba = 0
      use_curvefit = 0
      use_lmfit = 0
      use_genetic = 0
   endif
   if keyword_set(use_amoeba) then begin
      use_dfpmin = 0
      use_powell = 0
      use_curvefit = 0
      use_lmfit = 0
      use_genetic = 0
   endif
   if keyword_set(use_genetic) then begin
      use_dfpmin = 0
      use_powell = 0
      use_curvefit = 0
      use_lmfit = 0
      use_amoeba = 0
   endif
   if NOT keyword_set(use_powell) AND $
      NOT keyword_set(use_amoeba) AND $
      NOT keyword_set(use_curvefit) AND $
      NOT keyword_set(use_dfpmin) AND $
      NOT keyword_set(use_lmfit) AND $
      NOT keyword_set(use_genetic) then use_curvefit = 1  ; default
   if keyword_set(nofitfill) then no_fit_fill=1 else no_fit_fill=0

   ist = istin
   if NOT no_fit_qu then begin
      qst = qstin
      ust = ustin
   endif
   vst = vstin


   if n_elements(spprofilein) EQ nist then spprofile = spprofilein ; protect input

   if keyword_set(dosmooth) then begin
      if keyword_set(kernel) then begin
         nkern = n_elements(kernel)
         nkmid = floor(nkern/2.)
         if (nkern MOD 2) NE 1 then $
            message,'ERROR: the smoothing kernel must have an odd number of elements'
         if total(kernel[0:nkmid]) NE total(kernel[nkmid:*]) then $
            message,'ERROR: the smoothing kernel must be symmetric'
         kern = float(kernel)/total(float(kernel))
      endif else kern = [.05,.2,.5,.2,.05]	; Make it odd length or get shifts
      xx=fltarr(nist+4)
      xx(0)=replicate(ist(0),2) & xx(2)=ist & xx(nist+2)=replicate(ist(nist-1),2)
      ist=(convol(xx,kern,/edge_truncate,/center))(2:2+nist-1)
      if NOT no_fit_qu then begin
         xx(0)=replicate(qst(0),2) & xx(2)=qst & xx(nist+2)=replicate(qst(nist-1),2)
         qst=(convol(xx,kern,/edge_truncate,/center))(2:2+nist-1)
         xx(0)=replicate(ust(0),2) & xx(2)=ust & xx(nist+2)=replicate(ust(nist-1),2)
         ust=(convol(xx,kern,/edge_truncate,/center))(2:2+nist-1)
      endif
      xx(0)=replicate(vst(0),2) & xx(2)=vst & xx(nist+2)=replicate(vst(nist-1),2)
      vst=(convol(xx,kern,/edge_truncate,/center))(2:2+nist-1)
      if NOT keyword_set(spprofile) then begin
         ; If there is no spectral response set, then set it to the smoothing
         ; kernel.  Otherwise, the spectral response will be convolved with the
         ; smoothing kernel below.
         spprofile=fltarr(nist)
         spprofile[0] = kern
         spprofile = shift(spprofile,(nist-1)/2-(n_elements(kern)-1)/2)
      endif else if n_elements(spprofile) EQ nist then begin
         xx[0]=replicate(spprofile[0],2) & xx[2]=spprofile & xx[nist+2]=replicate(spprofile[nist-1],2)
         spprofile = (convol(xx,kern,/edge_truncate,/center))[2:2+nist-1]
      endif
   endif

   ; Set up the convolution with the spectral response of the instrument
   if n_elements(spprofile) EQ nist then begin
      if keyword_set(verbose) then message,/info,'Using spectral profile'
      spprofile = float(nist)*spprofile/total(spprofile) ; normalize for fft convolution
      junk = max(spprofile,ssspp)
      if ssspp NE (nist-1)/2 and NOT keyword_set(quiet) then $
         message,/info,'WARNING: spectral profile is not peaked at the center: ' + $
                       'the profiles may be shifted!'
      if use_double then $
         fftprofile = dcomplex(fft(shift(spprofile, -(nist-1)/2), -1 ,/double)) $
      else $
         fftprofile = complex(fft(shift(spprofile, -(nist-1)/2), -1 ))
      use_sp_profile = 1
      if keyword_set(spdeconvolve) then begin
         ; Directly deconvolve the spectral response from the Stokes profiles.
         ; Use Wiener filters to stabilize the deconvolution.
         ifilter = iquv_wiener_filter(ist,verbose=verbose,double=use_double)
         vfilter = iquv_wiener_filter(vst,verbose=verbose,double=use_double)
         if NOT no_fit_qu then begin
            qfilter = iquv_wiener_filter(qst,verbose=verbose,double=use_double)
            ufilter = iquv_wiener_filter(ust,verbose=verbose,double=use_double)
         endif
         if use_double then begin
            ist = double(fft(fft(ist,-1,/double)*ifilter/fftprofile,+1,/double))
            vst = double(fft(fft(vst,-1,/double)*vfilter/fftprofile,+1,/double))
            if NOT no_fit_qu then begin
               qst = double(fft(fft(qst,-1,/double)*qfilter/fftprofile,+1,/double))
               ust = double(fft(fft(ust,-1,/double)*ufilter/fftprofile,+1,/double))
            endif
         endif else begin
            ist = float(fft(fft(ist,-1)*ifilter/fftprofile,+1))
            vst = float(fft(fft(vst,-1)*vfilter/fftprofile,+1))
            if NOT no_fit_qu then begin
               qst = float(fft(fft(qst,-1)*qfilter/fftprofile,+1))
               ust = float(fft(fft(ust,-1)*ufilter/fftprofile,+1))
            endif
         endelse
         use_sp_profile = 0
      endif
   endif else begin
     if keyword_set(spprofilein) then $
        message,/info,'WARNING: the spectral profile has the wrong dimension: ' + $
                      'the profile will not be used.'
     use_sp_profile = 0
   endelse

   fit_x1_off = 0
   if NOT keyword_set(nofitx1) AND NOT no_fit_fill then begin
      if no_fit_qu then polfrac = max(abs(vst)/ist)/2 $
      else polfrac = max((sqrt(qst^2+ust^2)+abs(vst))/ist)/2
      if polfrac LT fitx1lim then begin
         fit_x1 = 0
         fit_x1_off = 1
         if NOT keyword_set(quiet) then $
            message,/info,'WARNING: polarization too low to fit magnetic ' + $
                          'and non-magnetic line centers independently.'
         ng = n_elements(guess)
         if no_fit_qu then nt = 10 else nt = 11
         if ng EQ nt then begin
            ; Since we are not going to fit x1 after all, remove
            ; x1 from the guess.  If we don't do this, the guess
            ; will be ignored since it will appear to be of the 
            ; wrong size.
            guess = [guess[0:ng-3],guess[ng-1]]  ; careful!  must correspond to ssx1 below
         endif
      endif else fit_x1 = 1 
   endif else fit_x1 = 0

   ; Set parameter indices, -1 means not fitting that parameter

   if no_fit_fill then begin
      if no_fit_qu then begin
         ssa      = 0
         ssdopp   = 1
         sseta0   = 2
         sseta0nm = -1
         ssb0     = 3
         ssb0nm   = -1
         ssb1     = 4
         ssbz     = 5
         ssbx     = 6
         ssby     = -1
         ssfill   = -1
         ssx1     = 7
         ssx0     = 8
      endif else begin
         ssa      = 0
         ssdopp   = 1
         sseta0   = 2
         sseta0nm = -1
         ssb0     = 3
         ssb0nm   = -1
         ssb1     = 4
         ssbz     = 5
         ssbx     = 6
         ssby     = 7
         ssfill   = -1
         ssx1     = 8
         ssx0     = 9
      endelse
   endif else begin
      if no_fit_qu then begin
         ssa      = 0
         ssdopp   = 1
         sseta0   = 2
         sseta0nm = 3
         ssb0     = 4
         ssb0nm   = 5
         ssb1     = 6
         ssbz     = 7
         ssbx     = 8
         ssby     = -1
         ssfill   = 9
         ssx1     = 10
         ssx0     = 11
      endif else begin
         ssa      = 0
         ssdopp   = 1
         sseta0   = 2
         sseta0nm = 3
         ssb0     = 4
         ssb0nm   = 5
         ssb1     = 6
         ssbz     = 7
         ssbx     = 8
         ssby     = 9
         ssfill   = 10
         ssx1     = 11
         ssx0     = 12
      endelse
   endelse
   if NOT fit_x1 then begin
      ssx0 = ssx0 - 1
      ssx1 = -1
   endif

   ; ouptut the indices as keyword parameters
   kssa=ssa & kssdopp=ssdopp & ksseta0=sseta0 & ksseta0nm=sseta0nm
   kssb0=ssb0 & kssb0nm=ssb0nm & kssb1=ssb1 & kssbz=ssbz & kssbx=ssbx
   kssby=ssby & kssfill=ssfill & kssx1=ssx1 & kssx0=ssx0

   ; Fit I,Q,U,V simultaneously

   nterms = 13
   if no_fit_fill then nterms = nterms - 3 ; not fitting fill factor, eta0nm, b0nm 
   if no_fit_fill OR NOT fit_x1 then nterms = nterms - 1 ; not fitting x1
   if no_fit_qu then nterms = nterms - 1   ; not fitting By
   aiquv = fltarr(nterms)
   dfpscale = fltarr(nterms+1)+1.0  ; set to 1 to turn off scaling.

   ; Assume polarization is the difference of two I's so that the error
   ; on Q,U, and V is sqrt(2) times the error on I.
   if keyword_set(wiquv) AND n_elements(wiquv) NE 4 AND keyword_set(verbose) then $
      message,/info,'WARNING: wiquv has the wrong dimension and will be ignored.'
   if n_elements(wiquv) NE 4 then wiquv = [1.,1.,1.,1.]
   if no_fit_qu then begin
      iquv = [Ist,Vst] 
      sigma2_iquv = abs([Ist*wiquv[0],2.*Ist*wiquv[3]])
      nstokes = 2
   endif else begin
       iquv = [Ist,Qst,Ust,Vst]
       sigma2_iquv = abs([Ist*wiquv[0],2.*Ist*wiquv[1],2.*Ist*wiquv[2],2.*Ist*wiquv[3]])
       nstokes = 4
   endelse
   nstokes1 = nstokes ; duplicate so that it can be in 2 common blocks
   npoints = nist * nstokes
   bad = where(sigma2_iquv EQ 0.0,nbad)
   if nbad GT 0 then sigma2_iquv[bad] = 1.0
   weight = 1./sigma2_iquv ; normal weighting (minimizes chi^2 for this w)
   if nbad GT 0 then weight[bad] = 0.0
   if n_elements(weightin) EQ nist then begin
      ;message,/info,'Using weight'
      for i=0L,long(nstokes)-1L do $
         weight[i*nist:(i+1L)*nist-1L] = weight[i*nist:(i+1L)*nist-1L] * float(weightin)
   endif else begin
      if keyword_set(weightin) and keyword_set(verbose) then $
         message,/info,'WARNING: weight keyword has the wrong dimension, ignoring. '+string(nist)+ $
                       ' '+string(n_elements(weightin))
   endelse

   okfit = 1   ; Flag to test whether Unno fit is ok
   okjls = 1   ; Flag to test whether JLS calculation is ok
   fbad = ''   ; String to store info on what went wrong

   ; Compute the initial guess.  It is very important to get this as
   ; close as possible to the correct solution.  First we do some
   ; sanity checks on any guess passed in.  If a guess is not passed
   ; in, or if the guess passed in fails the sanity checks, then a
   ; guess is computed from scratch.

   if n_elements(guess) EQ nterms then begin ; The user passed in a correctly sized guess array.
      aiquv = float(guess)
      ; Do some sanity checking on the guess passed in:  We do 
      ; not want to start the iteration up against one of the limits.
      gmodified = 0
      if aiquv[ssa] GE alimit/3.0 and NOT keyword_set(nocheckguess) then begin
         aiquv[ssa] = alimit/3.0          ; voigt param
         ;okfit = 0 & fbad = fbad + ' vp_init'
         gmodified = 1
      endif
      if aiquv[ssa] LE 0.0 and NOT keyword_set(nocheckguess) then begin
         aiquv[ssa] = 0.1                 ; voigt param
         ;okfit = 0 & fbad = fbad + ' vp_init'
         gmodified = 1
      endif
      if aiquv[ssdopp] GE dlimit/3.0 and NOT keyword_set(nocheckguess)then begin
         aiquv[ssdopp] = dlimit/3.0          ; doppler width
         ;okfit = 0 & fbad = fbad + ' dopp_init'
         gmodified = 1
      endif
      if aiquv[ssdopp] LE 0.0 and NOT keyword_set(nocheckguess)then begin
         aiquv[ssdopp] = 0.030               ; doppler width
         ;okfit = 0 & fbad = fbad + ' dopp_init'
         gmodified = 1
      endif
      if aiquv[sseta0] GE elimit/3.0 and NOT keyword_set(nocheckguess)then begin
         aiquv[sseta0] = elimit/3.0          ; eta0
         ;;okfit = 0 & fbad = fbad + ' e0_init'
         gmodified = 1
      endif
      if aiquv[sseta0] LE 0.0 and NOT keyword_set(nocheckguess) then begin
         aiquv[sseta0] = 1.0                 ; eta0
         ;;okfit = 0 & fbad = fbad + ' e0_init'
         gmodified = 1
      endif
      if NOT keyword_set(no_fit_fill) then begin
         if aiquv[sseta0nm] GE elimit/3.0 and NOT keyword_set(nocheckguess)then begin
            aiquv[sseta0nm] = elimit/3.0          ; eta0nm
            ;;okfit = 0 & fbad = fbad + ' e0nm_init'
            gmodified = 1
         endif
         if aiquv[sseta0nm] LE 0.0 and NOT keyword_set(nocheckguess) then begin
            aiquv[sseta0nm] = 1.0                 ; eta0nm
            ;;okfit = 0 & fbad = fbad + ' e0nm_init'
            gmodified = 1
         endif
      endif
      if NOT keyword_set(nocheckguess) then begin
         if NOT keyword_set(no_fit_fill) then begin  ; Force fill to start at 1.0
               fill = guess[ssfill] 
               aiquv[ssfill] = 1.0
         endif else fill = 1.0
         aiquv[ssbz] = aiquv[ssbz]*fill                       ; Bz flux density
         aiquv[ssbx] = aiquv[ssbx]*fill                       ; Bx flux density
         if NOT no_fit_qu then aiquv[ssby] = aiquv[ssby]*fill ; By flux density
      endif
      if abs(aiquv[ssbz]) GT Blimit/3.0 and NOT keyword_set(nocheckguess) then begin
         aiquv[ssbz] = (2*(aiquv[ssbz] GE 0.0)-1)*Blimit/3.0     ; Bz
         ;okfit = 0 & fbad = fbad + ' Bz_init'
         gmodified = 1
      endif
      if abs(aiquv[ssbx]) GT Blimit/3.0 and NOT keyword_set(nocheckguess) then begin
         aiquv[ssbx] = (2*(aiquv[ssbx] GE 0.0)-1)*Blimit/3.0     ; Bx
         ;okfit = 0 & fbad = fbad + ' Bx_init'
         gmodified = 1
      endif
      if NOT no_fit_qu then begin
         if abs(aiquv[ssby]) GT Blimit/3.0 and NOT keyword_set(nocheckguess) then begin
            aiquv[ssby] = (2*(aiquv[ssby] GE 0.0)-1)*Blimit/3.0  ; By
            ;okfit = 0 & fbad = fbad + ' By_init'
            gmodified = 1
         endif
      endif
      x0e = abs(x0max-x0min)*0.05   ; 5% of the wavelength range
      if aiquv[ssx0] GE x0max-x0e and NOT keyword_set(nocheckguess) then begin
         aiquv[ssx0] = (x0max+x0min)/2.  ; x0
         ;okfit = 0 & fbad = fbad + ' x0_init'
         gmodified = 1
      endif
      if aiquv[ssx0] LE x0min+x0e and NOT keyword_set(nocheckguess) then begin
         aiquv[ssx0] = (x0max+x0min)/2.  ; x0
         okfit = 0 & fbad = fbad + ' x0_init'
         gmodified = 1
      endif
      if fit_x1 then begin
         if abs(aiquv[ssx1]) GE x1limit/3.0 and NOT keyword_set(nocheckguess) then begin 
            aiquv[ssx1] = (2*(aiquv[ssx1] GE 0.0)-1)*x1limit/3.0  ; x1
            ;okfit = 0 & fbad = fbad + ' x1_init'
            gmodified = 1
         endif
      endif 
      ; Was the guess modified??
      if gmodified and keyword_set(verbose) then begin
         message,/info,'WARNING: Modified guess to more sane values'
      endif
      btotal_int = 0.   ; Not computed
      blong_int = 0.
      btran_int = 0.
      bazim_int = 0.
      gamma_int = 0.
   endif else if n_elements(guess) GT 0 and keyword_set(verbose) then $
      message,/info,'WARNING: The guess passed in has the wrong dimension: ignoring.'

   ; The user did not supply a guess, or the guess was out of range, so compute one.

   if n_elements(guess) NE nterms or keyword_set(gmodified) then begin

      ; Is the line in absorption or emission?
      ; Use smoothed second derivative to figure this out.
      second = smooth(deriv(smooth(deriv(smooth(ist,fix(nist/5)>1,/edge_truncate)), $
                                   fix(nist/5)>1,/edge_truncate)), $
                      fix(nist/5)>1,/edge_truncate)
      junk = max(abs(second[nist/5:nist-nist/5-1]),sssecond)
      if second[sssecond+nist/5] GE 0 then emission=0 else emission=1

      if keyword_set(verbose) and NOT keyword_set(quiet) then begin
         if keyword_set(emission) then $
            message,/info,'Deriving initial guess ... assuming emission line' $
         else $
            message,/info,'Deriving initial guess ... assuming absorption line'
      endif
      minI = min(Ist,minplace)
      maxI = max(Ist,maxplace)
      ; Start with a Voigt fit on the I profile.
      ; This sets the voigt parameter, the Doppler width,
      ; and the line center.
      if keyword_set(vpguess) then vpg = vpguess         ; must protect from change
      if keyword_set(doppguess) then dpg = doppguess*2.0 ; must protect from change
      ivfit=voigtfit(dlambda,ist,vpar,/quiet,emission=emission, $
                     goodfit=goodfit,vpguess=vpg,doppguess=dpg)

      continuum = vpar[0]
      if n_elements(doppguess) NE 1 then dopplerw = abs(vpar[3]/2.0) $
      else dopplerw = float(doppguess)
      if dopplerw GT dlimit/3.0 then begin
         dopplerw = dlimit/3.0
         okfit = 0 & fbad = fbad + ' dopp_guess'
      endif
      if dopplerw EQ 0.0 then dopplerw = 0.03  ; Indicates error in voigtfit
      if n_elements(vpguess) NE 1 then aparam = abs(vpar[2]) $
      else aparam = float(vpguess)
      if aparam GT alimit/3.0 then begin
         aparam = alimit/3.0
         okfit = 0 & fbad = fbad + ' vp_guess'
      endif
      if n_elements(x0guess) NE 1 then lcenter = vpar[4] $
      else lcenter = float(x0guess)
      if lcenter LT x0min then begin
         if keyword_set(verbose) then $
            message,/info,'WARNING: Initial guess: Line center is not in wavelength range (too blue)'
         lcenter = min(dlambda)
         okfit = 0 & fbad = fbad + ' x0_guess'
      endif
      if lcenter GT x0max then begin
         if keyword_set(verbose) then $
            message,/info,'WARNING: Initial guess: Line center is not in wavelength range (too red)'
         lcenter = max(dlambda)
         okfit = 0 & fbad = fbad + ' x0_guess'
      endif
      if n_elements(x1guess) NE 1 then x1 = 0.0 $
      else x1 = float(x1guess)-lcenter
      if abs(x1) GT x1limit/3.0 then begin
         sx1 = 2*(x1 GE 0.0)-1 ; sign of x1
         x1 = sx1*x1limit/3.0
      endif

      voigt,aparam,0.,h0,f0

      dl = dlambda - lcenter

      ; Compute B0, B1 and eta0 from a fit to the non-magnetic stokes I

      ; first a rough guess from the Voigt fit
      i0 = interpol(ist,dl,0.0)
      if keyword_set(b0guess) then b0=b0guess else b0 = continuum - vpar[1]*h0*(1.0+i0/continuum)
      if keyword_set(b1guess) then b1=b1guess else b1 = vpar[1]*h0*(1.0+i0/continuum)/mu
      if keyword_set(eta0guess) then eta0=eta0guess else eta0 = (continuum/(i0*h0))<(elimit/3.0)
      bbeguess = [b0,b1,eta0]

      ; Then an iterative improvement to the guesses. It's iterative 
      ; since it is non-linear in eta0.  This is a fit to
      ; I = B0 + mu*B1/(1+eta0*H)
      if NOT keyword_set(b0guess) OR NOT keyword_set(b1guess) OR $
         NOT keyword_set(eta0guess) then begin
         v = (dl)/dopplerw
         voigt,aparam,v,h,f
         muarray = mu+fltarr(nist)
         iharray = -ist*h
         for irepeat=0,2 do begin
            m = transpose([[1.0+eta0*h], $
                           [muarray], $
                           [iharray]])
            catch,error_status
            if error_status NE 0 then begin
               b0converge = 1.0
               b1converge = 1.0
               eta0converge = 1.0
               catch,/cancel
               break
            endif else begin
               svdc,m,wsvd,usvd,vsvd
            endelse
            catch,/cancel
            b0b1eta0 = svsol(usvd,wsvd,vsvd,ist)
            if b0 NE 0. then b0converge = abs((b0b1eta0[0]-b0)/b0) else b0converge = 0.
            if b1 NE 0. then b1converge = abs((b0b1eta0[1]-b1)/b1) else b1converge = 0.
            if eta0 NE 0. then eta0converge = abs((b0b1eta0[2]-eta0)/eta0) else eta0converge = 0.
            b0   = b0b1eta0[0]
            b1   = b0b1eta0[1]
            eta0 = b0b1eta0[2]
         endfor
         if b0converge GT 0.1 or b1converge GT 0.1 or eta0converge GT 0.1 or $
            eta0 LE 0.0 or eta0 GT (elimit/3.0) then begin
            ; revert to rough guess if not converged or out of range
            b0 = bbeguess[0]
            b1 = bbeguess[1]
            eta0 = bbeguess[2]
            okfit = 0 & fbad = fbad + ' b0b1e0_guess'
         endif
         if keyword_set(b0guess) then b0 = b0guess
         if keyword_set(b1guess) then b1 = b1guess
         if keyword_set(eta0guess) then eta0 = eta0guess 
      endif   
      if keyword_set(eta0nmguess) then eta0nm=eta0nmguess else eta0nm = eta0
      if keyword_set(b0nmguess) then b0nm=b0nmguess else b0nm = b0

      ; Integral method to guess field

      ldepth = abs(continuum - i0)
      vint = int_tabulated(dlambda,abs(vst),/double)*(clight/wave^2)*1.0e-8
      if NOT no_fit_qu then begin
         qint = int_tabulated(dlambda,abs(qst),/double)*(clight/wave^2)*1.0e-8
         uint = int_tabulated(dlambda,abs(ust),/double)*(clight/wave^2)*1.0e-8
         quint = int_tabulated(dlambda,sqrt(qst^2+ust^2),/double) * $
                 (clight/wave^2)*1.0e-8
      endif

      ; Sign of integrals for integral method
      ;dIdl = deriv(dl,ist)
      dIdl = deriv(dl,smooth(ist,fix(nist/10)>1,/edge_truncate))
      signV = 2*(smooth(vst,fix(nist/10)>1,/edge_truncate) GE 0.0)-1
      signI = 2*(dIdl GE 0.0)-1
      samesign = where(signV EQ signI,nsame)
      if nsame LE nist/2 then vint = -vint
      if NOT no_fit_qu then begin
         dIdx = interpol(dIdl,dl,[-dl_deriv,dl_deriv])
         qtest = interpol(smooth(qst,fix(nist/10)>1,/edge_truncate),dl,[-dl_deriv,dl_deriv]) / dIdx
         utest = interpol(smooth(ust,fix(nist/10)>1,/edge_truncate),dl,[-dl_deriv,dl_deriv]) / dIdx
         ; qtest[0] and qtest[1] should have opposite sign so qtest[0]-qtest[1]
         ; determines the sign of qint.
         if qtest[0]-qtest[1] GT 0. then qint = -qint
         if utest[0]-utest[1] GT 0. then uint = -uint

         ; derive constant for integral method btrans (xjls): from JLS
         a = aparam
         if n_elements(h) NE nist then begin
            v = dl/dopplerw
            voigt, a, v, h, f            ;Get Voigt profile
         endif
         ;Humlicek's method gives derivs analytically
         second_deriv = 4.0 * ((v^2-a^2)*h-2.0*a*v*f-h/2.0+a*0.56418958)
         voigt_term = abs(second_deriv)/(1.+eta0*h)^2
         if n_elements(h0) NE 1 then h0 = interpol(h,v,0.0)
         catch,error_status
         if error_status NE 0 then begin
            if keyword_set(verbose) then $
               message,/info,'Error computing xjls: setting xjls to 3.0.'
            xjls = 3.0
            okfit = 0 & fbad = fbad + ' xjls'
         endif else begin
            xjls = ((1.+eta0)/h0)*int_tabulated(v,voigt_term)
         endelse
         catch,/cancel
         if not finite(xjls) or xjls EQ 0.0 then begin
            if keyword_set(verbose) then $
               message,/info,'Warning: Cannot compute xjls: setting xjls to 3.0.'
            xjls = 3.0
            okfit = 0 & fbad = fbad + ' xjls'
         endif
      endif

      ; Guess field from stokes integrals
      blong = (2.0*(!pi)*me*clight/(glande*elec))*vint/ldepth
      if NOT no_fit_qu then begin
         btran = (4.0*(!pi)*me*clight/(glande*elec)) * $
                 sqrt(abs(4.*dopplerw*((clight/wave^2)*1.0e-8)*quint/(ldepth*xjls)))
         b_azim = 0.5e0*atan(uint,qint)
      endif else begin
         btran = 0.
         b_azim = 0.
     endelse

      if not finite(btran) then btran = 0.0
      if not finite(blong) then blong = 0.0
      btotal = sqrt(blong^2+btran^2) < Blimit
      b_incl = atan(btran,blong)
      bx = -btran*sin(b_azim)
      by =  btran*cos(b_azim)
      bz =  blong

      if abs(bx) GT Blimit/3.0 then begin
         sbx = 2*(bx GE 0.0)-1
         bx = sbx*Blimit/3.0
         okfit = 0 & fbad = fbad + ' Bx_guess'
      endif
      if abs(by) GT Blimit/3.0 then begin
         sby = 2*(by GE 0.0)-1
         by = sby*Blimit/3.0
         okfit = 0 & fbad = fbad + ' By_guess'
      endif
      if abs(bz) GT Blimit/3.0 then begin
         sbz = 2*(bz GE 0.0)-1
         bz = sbz*Blimit/3.0
         okfit = 0 & fbad = fbad + ' Bz_guess'
      endif

      btotal_int = btotal
      blong_int = blong
      btran_int = btran
      bazim_int = b_azim*!radeg
      gamma_int = b_incl*!radeg

      ; Last hope for the guess: hardwired values.
      if not finite(aparam) then aparam = 0.4
      if not finite(dopplerw) then dopplerw = 0.03
      if not finite(eta0) then eta0 = 10.0
      if not finite(eta0nm) then eta0nm = 10.0
      if not finite(b0) then b0 = 1000.
      if not finite(b0nm) then b0nm = 1000.
      if not finite(b1) then b1 = 5000.
      if not finite(bz) then bz = 0.
      if not finite(bx) then bx = 0.
      if not finite(by) then by = 0.
      if not finite(lcenter) then lcenter = 0.0

      aiquv[ssa] = abs(aparam)    ; Voigt parameter
      aiquv[ssdopp] = abs(dopplerw)  ; Doppler width in A
      aiquv[sseta0] = abs(eta0)      ; absorption coefficient
      if NOT keyword_set(no_fit_fill) then aiquv[sseta0nm] = abs(eta0nm)    ; absorption coefficient, non-magnetic
      aiquv[ssb0] = b0             ; coeff of linear source function
      if NOT keyword_set(no_fit_fill) then aiquv[ssb0nm] = b0nm           ; coeff of linear source function, non-magnetic
      aiquv[ssb1] = b1             ; coeff of linear source function
      aiquv[ssbz] = bz             ; LOS magnetic field
      aiquv[ssbx] = bx             ; transverse magnetic field
      if NOT keyword_set(no_fit_qu) then aiquv[ssby] = by ; transverse magnetic field
      if NOT keyword_set(no_fit_fill) then aiquv[ssfill] = 1.  ; filling factor
      aiquv[ssx0] = lcenter             ; Line center
      if fit_x1 then aiquv[ssx1] = x1   ; non-mag line center x1

      if keyword_set(plot) and keyword_set(verbose) then begin
         chi2 = chi2_iquv(aiquv,fit)
         if no_fit_qu then begin
            ifit = fit[0:nist-1]
            vfit = fit[nist:nist*2-1]
         endif else begin
            ifit = fit[0:nist-1]
            qfit = fit[nist:nist*2-1]
            ufit = fit[nist*2:nist*3-1]
            vfit = fit[nist*3:nist*4-1]
         endelse
         plot,dl,ist,title='I + Guess'
         oplot,dl,ifit,line=2,color=128
         if NOT no_fit_qu then begin
            plot,dl,qst,title='Q + Guess'
            oplot,dl,qfit,line=2,color=128
            plot,dl,ust,title='U + Guess'
            oplot,dl,ufit,line=2,color=128
         endif
         plot,dl,vst,title='V + Guess'
         oplot,dl,vfit,line=2,color=128
         xyouts,/normal,0.25,0.5,align=0.5, $
            strcompress('Btran = '+string(long(sqrt(bx^2+by^2))))
         xyouts,/normal,0.75,0.5,align=0.5, $
            strcompress('Blong = '+string(long(bz)))
         xyouts,/normal,0.50,0.5,align=0.5, $
            strcompress('Chi^2 = '+string(long(chi2)))
         empty
      endif
   endif   ; end of initial guess calculation

   if keyword_set(use_double) then aiquv = double(aiquv) $
   else aiquv = float(aiquv)

   delvarx,sigma

   catch,error_status
   if error_status NE 0 then begin
      if NOT keyword_set(quiet) then $
         message,/info,'WARNING: Error while fitting data.  ' + $
                       'Result may not be reliable.  '+!error_state.msg
      okfit = 0
      okjls = 0
      fbad = fbad + ' err'
      if min(dfpscale) NE 1. OR max(dfpscale) NE 1. then begin
         chi2 = chi2*dfpscale[0]
         aiquv = aiquv*dfpscale[1:*]
         dfpscale = fltarr(nterms+1)+1.0 ; reset for later calls to chi2_iquv
      endif
   endif else begin

      if keyword_set(use_dfpmin) then begin
         scale = [1.0, $    ; voigt param
                  1.0, $    ; Doppler width
                  10.0, $   ; eta0
                  10.0, $   ; eta0nm
                  abs(aiquv[ssb0])*2.0, $  ; b0
                  abs(aiquv[ssb0nm>ssb0])*2.0, $  ; b0nm
                  abs(aiquv[ssb1])*2.0, $  ; b1
                  500.0, $  ; bz
                  500.0, $  ; bx
                  500.0, $  ; by
                  0.5, $    ; fill
                  dispersion, $  ; x1
                  dispersion  ]  ; x0
         if NOT fit_x1 then scale = [scale[0:10],scale[12:*]] ; careful!  must correspond to ssa etc.
         if no_fit_fill then scale = [scale[0:9],scale[11:*]]
         if no_fit_qu then scale = [scale[0:8],scale[10:*]]
         if no_fit_fill then scale = [scale[0:4],scale[6:*]]
         if no_fit_fill then scale = [scale[0:2],scale[4:*]]
         ; The dfpmin algorithm will fail if the parameters and chi2 are not
         ; scaled to be of order 1.
         ;;dfpscale = [chisqr_cvf(0.1,(nist*4-nterms)>1),abs(aiquv)>0.1]
         dfpscale = [chisqr_cvf(0.1,(nist*4-nterms)>1),scale]
         aiquv = aiquv/dfpscale[1:*]
         for irestart=0,10 do begin
            dfpmin,aiquv,1.e-7,chi2,'chi2_iquv','dfp_deriv_iquv',double=use_double, $
                   iter=iter,itmax=1000,eps=(machar(double=use_double)).eps, $
                   stepmax=100.,tolx=1.e-7
            if iter LE 1 AND irestart GT 0 then break
         endfor
         chi2 = chi2*dfpscale[0]
         aiquv = aiquv*dfpscale[1:*]
         dfpscale = fltarr(nterms+1)+1.0 ; reset for later calls to chi2_iquv
         if iter GE 1000 then begin
            okfit=0
            okjls=0
            fbad = fbad + ' iter'
         endif
      endif

      if keyword_set(use_lmfit) then begin
         itmax = 250
         aiquv0 = aiquv  ; Save guess in case LMFIT fails
         dllmfit = make_array(size=size(iquv),value=0.0) & dllmfit[0]=findgen(npoints)
         junk = voigt_funct_iquv_lmfit(dllmfit[0],aiquv,/initialize)
         fit = lmfit(dllmfit,iquv,aiquv,chisq=chi2,convergence=convergence,covar=covar, $
                     double=use_double,function_name='voigt_funct_iquv_lmfit', $
                     iter=iter,itmax=itmax,measure_errors=1./sqrt(weight),sigma=sigma)
         if convergence LE 0 OR iter GT itmax then begin
            okfit=0
            okjls=0
            fbad = fbad + ' iter'
         endif
         if n_elements(aiquv) NE n_elements(aiquv0) OR min(finite(aiquv)) LE 0 then begin
            okfit=0
            okjls=0
            fbad = fbad + ' lmfit'
            aiquv = aiquv0
         endif
      endif

      if keyword_set(use_curvefit) then begin
         ; Restart to make sure we are not stuck at a local min.
         ; Also reduce the min fill factor slowly so that the 
         ; field is determined first.  This avoids instabilities when
         ; the algorithm cannot tell the difference between a 
         ; small field with a large fill and a large field with
         ; a small fill.
         mfarr = [0.5,min_fill]
         for irestart=0,1 do begin
            min_fill = mfarr[irestart]
            if keyword_set(quiet) then begin ; Make curvefit quiet
               squiet = !quiet
               !quiet = 1
            endif
            fit = curvefit(dlambda,iquv,weight,aiquv,sigma,itmax=cfit_itmax,tol=1.e-4, $
                           function_name='voigt_funct_iquv',double=use_double,iter=iter)
            if keyword_set(quiet) then !quiet = squiet
         endfor
         if iter GE cfit_itmax then begin
            okfit=0
            okjls=0
            fbad = fbad + ' iter'
         endif

      endif

      if keyword_set(use_amoeba) then begin
         scale = [1.0, $    ; voigt param
                  1.0, $    ; Doppler width
                  10.0, $   ; eta0
                  10.0, $   ; eta0nm
                  abs(aiquv[ssb0])*2.0, $  ; b0
                  abs(aiquv[ssb0nm>ssb0])*2.0, $  ; b0nm
                  abs(aiquv[ssb1])*2.0, $  ; b1
                  500.0, $  ; bz
                  500.0, $  ; bx
                  500.0, $  ; by
                  0.5, $    ; fill
                  dispersion*10.0, $  ; x1
                  dispersion*10.0  ]  ; x0
         if NOT fit_x1 then scale = [scale[0:10],scale[12:*]]  ; careful!  must correspond to ssa etc.
         if no_fit_fill then scale = [scale[0:9],scale[11:*]]
         if no_fit_qu then scale = [scale[0:8],scale[10:*]]
         if no_fit_fill then scale = [scale[0:4],scale[6:*]]
         if no_fit_fill then scale = [scale[0:2],scale[4:*]]

         amaiquv = amoebax(1.e-6 > 10.*(machar(double=use_double)).eps, $
                           1.e-6 > 10.*(machar(double=use_double)).eps, $
                           function_name='chi2_iquv', $
                           function_value=chi2,p0=aiquv, $
                           ;;scale=(abs(aiquv)>0.1)*2.0, $
                           scale = scale, $
                           nmax=amoeba_nmax, $
                           simplex=simplex,ncalls=ncalls)
         if n_elements(amaiquv) EQ nterms then aiquv = amaiquv $
         else begin
            aiquv = simplex[*,0]
            message,'Amoeba did not converge'  ; error will be caught
         endelse
      endif

      if keyword_set(use_genetic) then begin
         ; This sets the boundaries of the search algorithm.
         ; Assume the limits are 3 times the largest value expected.
         pikaiamax = [alimit/3., $   ; voigt param
                      dlimit/3., $   ; Doppler width
                      elimit/3., $   ; eta0
                      elimit/3., $   ; eta0nm
                      abs(aiquv[ssb0])*3.0, $  ; b0
                      abs(aiquv[ssb0nm>ssb0])*3.0, $  ; b0nm
                      abs(aiquv[ssb1])*3.0, $  ; b1
                      Blimit/3., $  ; bz
                      Blimit/3., $  ; bx
                      Blimit/3., $  ; by
                      1.0, $    ; fill
                      x1limit/3., $  ; x1
                      x0max]         ; x0
         pikaiamin = [0., $   ; voigt param
                      0., $   ; Doppler width
                      0., $   ; eta0
                      0., $   ; eta0nm
                      -abs(aiquv[ssb0])*3.0, $  ; b0
                      -abs(aiquv[ssb0nm>ssb0])*3.0, $  ; b0nm
                      -abs(aiquv[ssb1])*3.0, $  ; b1
                      -Blimit/3., $  ; bz
                      -Blimit/3., $  ; bx
                      -Blimit/3., $  ; by
                      0.0, $    ; fill
                      -x1limit/3., $  ; x1
                      x0min]          ; x0

         ; careful!  must correspond to ssa etc.
         if NOT fit_x1 then begin
            pikaiamax = [pikaiamax[0:10],pikaiamax[12:*]] 
            pikaiamin = [pikaiamin[0:10],pikaiamin[12:*]] 
         endif
         if no_fit_fill then begin
            pikaiamax = [pikaiamax[0:9],pikaiamax[11:*]]
            pikaiamin = [pikaiamin[0:9],pikaiamin[11:*]]
         endif
         if no_fit_qu then begin
            pikaiamax = [pikaiamax[0:8],pikaiamax[10:*]]
            pikaiamin = [pikaiamin[0:8],pikaiamin[10:*]]
         endif
         if no_fit_fill then begin
            pikaiamax = [pikaiamax[0:4],pikaiamax[6:*]]
            pikaiamin = [pikaiamin[0:4],pikaiamin[6:*]]
         endif
         if no_fit_fill then begin
            pikaiamax = [pikaiamax[0:2],pikaiamax[4:*]]
            pikaiamin = [pikaiamin[0:2],pikaiamin[4:*]]
         endif

         if keyword_set(plot) then begin  ; Set up for fitwatch
            savedevice = !d.name
            savewindow = !d.window
            savepmulti = !p.multi
            !p.multi = 0
            set_plot,'X'
         endif

         if n_elements(decimalplaces) NE 1 then decimalplaces = 7
         npikaiapoints = npoints ; in common block, used to set chi2 when params go bad
         ; All parameters scaled between 0 and 1
         aiquv = (aiquv-pikaiamin)/(pikaiamax-pikaiamin)
         ; for fitwatch to work, pikaia.pro has to be modified
         ; a bit: use abs(fbest) etc. and remove the default yrange.
         ; For pikaia to work, I also had to make a 
         ; modification to pikaia_encode.pro: 
         ; Old: temp = string(phenotype(ii))  ; This fails for small numbers
         ; New: temp = string(phenotype(ii),format='(f14.12)') ; TRM 2004-Nov-19
         pikaia,'pikaia_iquv',nterms,aiquv,fit, $
                pop=80,generations=ngenerations, $
                fitstore=fitout,seed=pikaiaseed,replacement=2, $
                tolerance=-CHISQR_CVF(1.d-20,(npoints-nterms)>1)/10., $
                variable=1,verbose=verbose,decimalplaces=decimalplaces, $
                fitwatch=(keyword_set(plot) and !d.name eq 'X'), $
                creepmutation=1,twopoint=1,testinput=aiquv,muteprob=0.25
         aiquv = aiquv*(pikaiamax-pikaiamin) + pikaiamin

         if keyword_set(plot) then begin
            set_plot,savedevice
            if savewindow GE 0 then wset,savewindow
            !p.multi = savepmulti
         endif

      endif

      if keyword_set(use_powell) then begin
         scale = [0.1, $    ; voigt param
                  0.03, $    ; Doppler width
                  1.0, $   ; eta0
                  1.0, $   ; eta0nm
                  abs(aiquv[ssb0])/2.0, $  ; b0
                  abs(aiquv[ssb0nm>ssb0])/2.0, $  ; b0nm
                  abs(aiquv[ssb1])/2.0, $  ; b1
                  50.0, $  ; bz
                  50.0, $  ; bx
                  50.0, $  ; by
                  0.1, $    ; fill
                  dispersion, $  ; x1
                  dispersion  ]  ; x0
         if NOT fit_x1 then scale = [scale[0:10],scale[12:*]] ; careful!  must correspond to ssa etc.
         if no_fit_fill then scale = [scale[0:9],scale[11:*]]
         if no_fit_qu then scale = [scale[0:8],scale[10:*]]
         if no_fit_fill then scale = [scale[0:4],scale[6:*]]
         if no_fit_fill then scale = [scale[0:2],scale[4:*]]

         itmax = 500
         if use_double then xi = dblarr(nterms,nterms) else xi = fltarr(nterms,nterms)
         ;;for ixi = 0,nterms-1 do xi[ixi,ixi]=abs(aiquv[ixi])>0.1
         for ixi = 0,nterms-1 do xi[ixi,ixi]=scale[ixi]
         powell,aiquv,xi,1.e-4,chi2,'chi2_iquv',itmax=itmax,iter=iter,double=use_double
         if iter GE itmax then begin
            okfit=0
            okjls=0
            fbad = fbad + ' iter'
         endif
      endif
   endelse    ; end of error catching
   catch,/cancel

   chi2 = chi2_iquv(aiquv,fit,/dolimits)  ; Get the model Stokes profiles

   if no_fit_qu then begin
      ifit = fit[0:nist-1]
      vfit = fit[nist:nist*2-1]
      ichi2 = total((ifit-ist)^2/ist)
      qchi2 = 0.
      uchi2 = 0.
      vchi2 = total((vfit-vst)^2/ist)
   endif else begin
      ifit = fit[0:nist-1]
      qfit = fit[nist:nist*2-1]
      ufit = fit[nist*2:nist*3-1]
      vfit = fit[nist*3:nist*4-1]
      ichi2 = total((ifit-ist)^2/ist)
      qchi2 = total((qfit-qst)^2/ist)
      uchi2 = total((ufit-ust)^2/ist)
      vchi2 = total((vfit-vst)^2/ist)
   endelse

   aparam   = abs(aiquv[ssa])        ; Voigt parameter
   dopplerl = abs(aiquv[ssdopp])        ; Doppler width in A
   eta0     = abs(aiquv[sseta0])        ; absorption coefficient
   eta0nm   = eta0
   if NOT keyword_set(no_fit_fill) then eta0nm  = abs(aiquv[sseta0nm])  ; absorption coefficient, non-magnetic
   b0       = aiquv[ssb0]             ; coeff of linear source function
   b0nm = b0
   if NOT keyword_set(no_fit_fill) then b0nm    = aiquv[ssb0nm]      ; coeff of linear source function, non-magnetic
   b1       = aiquv[ssb1]             ; coeff of linear source function
   bz       = aiquv[ssbz]             ; Bcos(gamma)
   bx       = aiquv[ssbx]             ; -Bsin(gamma)sin(chi)
   if no_fit_qu then begin
      by = 0.
   endif else begin
      by       = aiquv[ssby]             ; +Bsin(gamma)cos(chi)
   endelse 
   bt       = sqrt(bx^2+by^2)      ; Btrans
   gamma    = atan(bt,bz)          ; gamma
   chi      = atan(-bx,by)         ; chi
   btotal   = sqrt(bz^2+bt^2)      ; Btotal (G)
   x0       = aiquv[ssx0]         ; Line center
   if no_fit_fill then begin
      fill     = 1.0
      x1       = 0.               ; Line center diff not fit
   endif else begin
      fill     = aiquv[ssfill]        ; filling factor 
      if fit_x1 then begin
         x1       = aiquv[ssx1]       ; non-mag Line center shift
      endif else begin
         x1       = 0.                ; Line center diff not fit
      endelse
   endelse

   ; Check that fit is in range
   x0e = abs(x0max-x0min)*0.01   ; 1% of the wavelength range
   if abs(btotal) GT Blimit*0.99 or not finite(btotal) or $
      abs(bt) GT Blimit*0.99 or not finite(bt)  or $
      abs(bx) GT Blimit*0.99 or not finite(bx)  or $
      abs(by) GT Blimit*0.99 or not finite(by)  or $
      abs(bz) GT Blimit*0.99 or not finite(bz)  or $ 
      abs(aparam) GT alimit*0.99 or not finite(aparam) or $
      abs(dopplerl) GT dlimit*0.99 or dopplerl EQ 0.0 or not finite(dopplerl) or $
      ;abs(eta0) GT elimit*0.99 or (not no_fit_fill and (abs(eta0nm) GT elimit*0.99)) or $
      not finite(eta0) or (not no_fit_fill and not finite(eta0nm)) or $
      not finite(b0) or not finite(b1) or $
      (not no_fit_fill and not finite(b0nm)) or $
      (not no_fit_fill and not finite(fill)) or $
      x0 LE (x0min+x0e) or x0 GE (x0max-x0e) or not finite(x0) or $
      (not no_fit_fill and (abs(x1) GT x1limit*0.99 or not finite(x1))) then begin
      okfit=0
      okjls=0
      fbad = fbad + ' range('
      if abs(btotal) GT Blimit*0.99 or not finite(btotal) then fbad = fbad + 'btotal '
      if abs(bt) GT Blimit*0.99 or not finite(bt) then fbad =fbad + 'bt '
      if abs(bx) GT Blimit*0.99 or not finite(bx) then fbad =fbad + 'bx '
      if abs(by) GT Blimit*0.99 or not finite(by) then fbad =fbad + 'by '
      if abs(bz) GT Blimit*0.99 or not finite(bz) then fbad =fbad + 'bz '
      if abs(aparam) GT alimit*0.99 or not finite(aparam) then fbad =fbad + 'a '
      if abs(dopplerl) GT dlimit*0.99 or dopplerl EQ 0.0 or not finite(dopplerl) then fbad =fbad + 'dopp '
      ;if abs(eta0) GT elimit*0.99 then fbad =fbad + 'eta0lim '
      if not finite(eta0) then fbad =fbad + 'eta0 '
      ;if not no_fit_fill and (abs(eta0nm) GT elimit*0.99) then fbad =fbad + 'eta0nmlim '
      if not no_fit_fill and (not finite(eta0nm)) then fbad =fbad + 'eta0nm '
      if not finite(b0) then fbad =fbad + 'b0 '
      if not no_fit_fill and not finite(b0nm) then fbad =fbad + 'b0nm '
      if not finite(b1) then fbad =fbad + 'b1 '
      if not no_fit_fill and not finite(fill) then fbad =fbad + 'fill '
      if x0 LE (x0min+x0e) or x0 GE (x0max-x0e) or not finite(x0) then fbad =fbad + 'x0 '
      if not no_fit_fill and (abs(x1) GT x1limit*0.99 or not finite(x1)) then fbad =fbad + 'x1 '
      fbad = strmid(fbad,0,strlen(fbad)-1) ; get rid of last space
      fbad=fbad + ')'
      if keyword_set(verbose) then message,/info,'Bad fit: parameter out of range'
   endif
   if x0 LT x0min+abs(dl_deriv) then begin
      if keyword_set(verbose) then $
         message,/info,'WARNING: Line center is not in wavelength range (too blue): JLS field not valid'
      okjls = 0
   endif
   if x0 GT x0max-abs(dl_deriv) then begin
      if keyword_set(verbose) then $
         message,/info,'WARNING: Line center is not in wavelength range (too red): JLS field not valid'
      okjls = 0
   endif

   dl = dlambda - x0

   if keyword_set(plot) or keyword_set(verbose) then begin
      maxI = max(ist)
      plot,dl,ist,title='I + Fit',/xst
      oplot,dl,ifit,line=2,color=128
      if fit_x1 then oplot,[x1,x1],[0.,max(ifit)]*2,line=1,color=128
      oplot,[0.,0.],[0.,max(ifit)]*2,line=1
      if NOT no_fit_qu then begin
         if keyword_set(nofixplotrange) then $
            plot,dl,qst,title='Q + Fit',/xst $
         else $
            plot,dl,qst,title='Q + Fit',yrange=[-maxI,+maxI]*0.06,/xst
         oplot,dl,qfit,line=2,color=128
         oplot,[0.,0.],[-maxI,+maxI]*0.06*2,line=1
         oplot,[dl[0],dl[nist-1]],[0.,0.],line=1
         if keyword_set(nofixplotrange) then $
            plot,dl,ust,title='U + Fit',/xst $
         else $
            plot,dl,ust,title='U + Fit',yrange=[-maxI,+maxI]*0.06,/xst
         oplot,dl,ufit,line=2,color=128
         oplot,[0.,0.],[-maxI,+maxI]*0.06*2,line=1
         oplot,[dl[0],dl[nist-1]],[0.,0.],line=1
      endif
      if keyword_set(nofixplotrange) then $
         plot,dl,vst,title='V + Fit',/xst $
      else $
         plot,dl,vst,title='V + Fit',yrange=[-maxI,+maxI]*0.20,/xst
      oplot,dl,vfit,line=2,color=128
      oplot,[0.,0.],[-maxI,+maxI]*0.20*2,line=1
      oplot,[dl[0],dl[nist-1]],[0.,0.],line=1
      xyouts,/normal,0.25,0.5,align=0.5, $
         strcompress('Btran = '+string(long(fill*btotal*sin(gamma))))
      xyouts,/normal,0.75,0.5,align=0.5, $
         strcompress('Blong = '+string(long(fill*btotal*cos(gamma))))
      xyouts,/normal,0.50,0.5,align=0.5, $
         strcompress('Chi^2 = '+string(long(chi2)))
   endif

   ; Use only the magnetic component so
   ; that we get the field rather than the flux density
   ; unless the use_observed_serivative keyword is set.

   if NOT keyword_set(use_observed_derivative) then begin
      didx = dImdl(dlambda,aiquv)  ; Analytic derivative of *magnetic* line fit
   endif else begin
      ; Numeric derivative of observed line
      ; deriv_lud gets very slow for a large number of points
      catch,error_status
      if error_status NE 0 then begin
         catch,/cancel
         didx = deriv(dlambda,ist)
      endif else begin
         deriv_lud,dlambda,ist,didx,midpoints=mid,yerror=sqrt((ist*wiquv[0])>0.0),/quiet
         didx = interpol(didx,mid,dlambda)
         catch,/cancel
      endelse
   endelse

   ; Now compute all the quatities at dl_deriv for JLS calculation

   di = interpol(didx,dl,[-dl_deriv,+dl_deriv])
   di = (di[0] - di[1])/2.0
   disign = 2*(di GE 0.0)-1
   voigt_funct_iquv,[-dl_deriv,dl_deriv]+x0,aiquv,fit,/no_instrument_response
   if no_fit_qu then begin
      ii = (fit[0]+fit[1])/2.0
      vv = (fit[3]-fit[2])/2.0
   endif else begin
      ii = (fit[0]+fit[1])/2.0
      ; Set Q&U sign for emission/absorption line to get azimuth right
      qq = -disign*(fit[2]+fit[3])/2.0
      uu = -disign*(fit[4]+fit[5])/2.0
      vv = (fit[7]-fit[6])/2.0
   endelse

   ; Now compute the magnetic field using the JLS derivative method.
   ; Jefferies & Mickey 1991, ApJ, 372, 694.

   v = double(dl_deriv/dopplerl)
   a = double(aparam)
   voigt, a, v, h, f            ;Get Voigt profile
   first_deriv = 2.0*(a*f-v*h)  ;Humlicek's method gives derivs analytically
   second_deriv = 4.0 * ((v^2-a^2)*h-2.0*a*v*f-h/2.0+a*0.56418958)
   ; If the following limit is reached, the weak field approx is not really
   ; valid anyway, so should be OK to avoid places where the 
   ; second derivative is zero.  In the line wings, |v*s| = |f|*pi,, so 
   ; the limit does nothing when the WFA is valid.  The value of the limit
   ; was selected to make the transition across the singulatity
   ; more or less smooth.  Don't change the value.
   vsd = abs(v*second_deriv) > abs(first_deriv/(2.25))
   ;voigt_term = sqrt(abs(first_deriv/(v*second_deriv)))
   voigt_term = sqrt(abs(first_deriv/vsd))
   if NOT finite(voigt_term) then begin
      if keyword_set(verbose) then $
         message,/info,'WARNING: JLS voigt_term for transverse field is not finite.'
      voigt_term = 1.0
      okjls = 0
   endif
   if NOT use_double then voigt_term = float(voigt_term)

   cos_con = 2.1422E12/(glande*lambda^2)    ; From JLS (lambda in Angstroms!!!)
   sin_con = 2.00E0 * cos_con

   ;  The minus sign in B_cos is just convention - no physics
   B_cos = -(cos_con) * (vv/di)     ; Formulae from JLS
   if no_fit_qu then B_sin = 0. $
   else B_sin = (sin_con) * voigt_term * sqrt( sqrt(qq^2+uu^2)*abs(dl_deriv/di) )

   blong = B_cos                            ; Longitudinal field
   btran = B_sin                            ; Transverse field
   if no_fit_qu then bazim = 0. $
   else bazim = 0.5E0*atan(uu,qq)*(!radeg)  ; Azimuthal angle (degrees)
   btot_jls = sqrt(blong^2+btran^2)
   gamma_jls = atan(btran,blong)

   if not finite(blong) or not finite(btran) then okjls = 0

   blong_unno = btotal*cos(gamma)
   btran_unno = btotal*sin(gamma)

   if keyword_set(verbose) then print,'JLS B:',blong,btran,bazim

   if keyword_set(plot) then begin
     !p.multi = pmulti
   endif
   check = check_math(mask=32) ; Ignore underflows which come from voigt.pro
   !except = except

   if okfit or okjls then begin
      cl4 = CHISQR_CVF(1.d-20,(npoints-nterms)>1)
      cl  = CHISQR_CVF(1.d-20,(nist-nterms)>1)
      if (chi2 GT cl4) then begin
         okfit=0
         okjls=0
         fbad = fbad + ' chi2'
         if keyword_set(verbose) then message,/info,'Bad fit: chi2'
      endif
      if (qchi2 GT cl) then begin
         okfit=0
         okjls=0
         fbad = fbad + ' Qchi2'
         if keyword_set(verbose) then message,/info,'Bad fit: Qchi2'
      endif
      if (uchi2 GT cl) then begin
         okfit=0
         okjls=0
         fbad = fbad + ' Uchi2'
         if keyword_set(verbose) then message,/info,'Bad fit: Uchi2'
      endif
      if (vchi2 GT cl) then begin
         okfit=0
         okjls=0
         fbad = fbad + ' Vchi2'
         if keyword_set(verbose) then message,/info,'Bad fit: Vchi2'
      endif 
   endif

   if keyword_set(plot) or keyword_set(verbose) then begin
      if not okfit then xyouts,/normal,0.5,0.0,align=0.5,'BAD:'+fbad $
      else xyouts,/normal,0.5,0.,align=0.5,'OK'
      empty
   endif

   if keyword_set(fit_x1_off) then begin
      ; The x1 fit was turned off because of low polarization,
      ; but aiquv should still return with a value since x1 
      ; fit was requested.
      aiquv = [aiquv[0:nterms-2],0.0,aiquv[nterms-1]]  ; careful!  indexing must correspond to ssa, etc.
      if n_elements(sigma) EQ n_elements(aiquv) then $
         sigma = [sigma[0:nterms-2],0.0,sigma[nterms-1]]
   endif

   return,{  aparam:aparam, $    ; Voigt parameter (Unno fit)
             doppler:dopplerl, $ ; Doppler width in A (Unno fit)
             eta0:eta0, $        ; absorption coefficient (Unno fit)
             eta0nm:eta0nm, $    ; absorption coefficient, non-magnetic (Unno fit)
             b0:b0, $            ; coeff of linear source function (Unno fit)
             b0nm:b0nm, $          ; coeff of linear source function, non-magnetic (Unno fit)
             b1:b1, $            ; coeff of linear source function (Unno fit)
             btotal:btotal, $    ; total magnetic field in Gauss (Unno fit)
             gamma:gamma*!radeg,$; field inclination, degrees (Unno fit)
             chi:chi*!radeg, $   ; field azimuth, degrees (Unno fit)
             blong: blong_unno, $; LOS B(Gauss) from Unno fit
             btran: btran_unno, $; Transverse B(Gauss) from Unno fit
             bazim: chi*!radeg, $; Transverse B azimuth (degrees) from Unno fit
             fill:fill, $        ; filling factor  (Unno fit)
             x0:x0, $            ; Line center (magnetic) in dlambda units (Unno fit)
             x1:x1+x0, $         ; Line center (non-magnetic) in dlambda units (Unno fit)
             btotal_jls:btot_jls, $ ; total magnetic field (G) from JLS
             blong_jls:blong, $  ; LOS B (Gauss) from JLS method
             btran_jls:btran, $  ; Transverse B (Gauss) from JLS method
             bazim_jls:bazim, $  ; Transverse B azimuth (degrees) from JLS method
             gamma_jls:gamma_jls*!radeg, $ ; field inclination, degrees from JLS
             dl_deriv:dl_deriv, $; DLambda used by JLS, input
             btotal_int:btotal_int, $ ; total magnetic field (G) from integral method
             blong_int:blong_int, $ ; LOS magnetic field (G) from integral method
             btran_int:btran_int, $ ; Transverse magnetic field (G) from integral method
             bazim_int:bazim_int, $ ; Transverse B azimuth (degrees) from integral method
             gamma_int:gamma_int, $ ; field inclination (degrees) from integral method
             glande: glande, $   ; Lande g factor (input)
             lambda: lambda, $   ; Wavelength of line (A), input
             mu: mu, $           ; cosine of postion angle on disk (input)
             ichi2: ichi2, $     ; Chi^2 for the Unno I fit
             qchi2: qchi2, $     ; Chi^2 for the Unno Q fit
             uchi2: uchi2, $     ; Chi^2 for the Unno U fit
             vchi2: vchi2, $     ; Chi^2 for the Unno V fit
             chi2:  chi2, $      ; Chi^2 for the Unno fit (I,Q,U, and V)
             okfit: okfit, $     ; Is the Unno fit good? 0=no, 1=yes
             okjls: okjls, $     ; Is the JLS calculation good? 0=no, 1=yes
             version: version $  ; stokesfit.pro version
          }

end
