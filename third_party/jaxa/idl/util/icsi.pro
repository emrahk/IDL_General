pro icsi, wav, int, wavf, intf, int_cor,                            $
          fact=fact, int_dev_max=int_dev_max,                       $
          niterations=niterations, idmax=idmax, intf_all=intf_all,  $
		  cor_all=cor_all, int_dev_all=int_dev_all

; Intensity Conserving Spline Interpolation

; This routine "corrects" (x,y) data in which the ordinate represents the average of a quantity over 
; a finite interval in the abscissa. A typical example is spectral data, where the average intensity 
; over a wavelength bin (the measured quantity) is assigned to the center of the bin. If the profile 
; is curved, the average will be different from the discrete value at the bin center location. 
; ICSI.PRO corrects the intensity using an iterative procedure and cubic spline, as described in 
; Klimchuk, Patsourakos, & Tripathi (2015, ApJ, submitted). The corrected intensity equals the "true" 
; intensity at bin center, rather than the average over the bin.

; INPUTS
;    wav  = original resolution wavelength array (need not be regular, but must be in ascending order)
;    int  = original resolution intensity array

; OPTIONAL KEYWORD INPUTS
;    fact = factor by which resolution is increased, must be an odd integer (default = 99)
;    int_dev_max = solution convergence criterion:  
;                  maximum intensity deviation between the spline fit average and true average (int), 
;                  computed at each bin of the original wavelength grid, and normalized by the maximum 
;                  intensity across the profile (default = 1.e-5)
;    niterations = maximum number of iterations (default = 100)

; OUTPUTS
;    wavf = fine resolution wavelength array (bin center positions of fine grid)
;    intf = fine resolution intensity array
;    int_cor = corrected intensity at original resolution wavelength positions, wav
;                 (intensity that accounts for profile curvature and conserves total intensity)

; OPTIONAL KEYWORD OUTPUTS
;    idmax = array of maximum fractional intensity deviation at each iteration
;    intf_all = 2D array of spline fits (second index) at all iterations (first index)

; HISTORY
;    2014-may-23, written, J. A. Klimchuk
;    2014-nov-25, corrected problem with fine wavf that occurs with nonuniform coarse grids, JAK
;    2014-dec-03, changed F_1/2 (fhalf) to be the spline fit at position wav rather than at the
;                 midpoint of the wavelength bin (only different with nonuniform coarse grids), JAK
;    2014-dec-04, changed convergence test to ignore bins where the true intensity is zero;
;                 added output variable int_cor, JAK
;    2014-dec-08, fixed a small bug with int_cor, JAK


   if not keyword_set(fact) then fact = 99
   if not keyword_set(int_dev_max) then int_dev_max = 1.e-5
   if not keyword_set(niterations) then niterations = 100

   if (fact/2 eq fact/2.) then begin
      print, 'fact not odd'
	  goto, jump99
   endif
   

; Create high resolution wavelength array
;    The left edge of original grid cell i is located at wav(i) - 0.5*(wav(i) - wav(i-1)).
;    The right edge of original grid cell i is located at wav(i) + 0.5*(wav(i+1) - wav(i)).
;    The fine grid cells are uniform within the original grid cell.
;    The edges of the fine grid cells coincide precisely with the edges of the original grid cell.
;    If wav is nonuniform, the bin center (midway between the edges) is offset from wav.

   nwav = n_elements(wav)
   nwavf = nwav*fact
   wavf = dblarr(nwavf)
   dwav = dblarr(nwav)  
   rms = dblarr(niterations)   
   
   for i = 1, nwav-2 do begin
      dwav(i) = 0.5*(wav(i+1) - wav(i-1))
	  wsub = (dindgen(fact) + 0.5)/fact*dwav(i)
	  wavf(i*fact:(i+1)*fact-1) = wsub + 0.5*(wav(i) + wav(i-1))
   endfor

;  First bin   
   dwav(0) = wav(1) - wav(0)   
   wsub = (dindgen(fact) + 0.5)/fact*dwav(0)
   wavf(0:fact-1) = wsub + wav(0) - 0.5*dwav(0) 
   
;  Last bin   
   dwav(nwav-1) = wav(nwav-1) - wav(nwav-2)
   wsub = (dindgen(fact) + 0.5)/fact*dwav(nwav-1)
   wavf(nwavf-fact:nwavf-1) = wsub + wav(nwav-1) - 0.5*dwav(nwav-1)
   
; F (spline fit, fine resolution)
   intf_all = dblarr(niterations, nwavf)     
   intf_all(0,*) = interpol(int, wav, wavf, /spline)    ; initial spline fit
   cor_all = fltarr(niterations,nwav)                   ; correction factors

; I (corrected intensity, original resolution)
   int_new_all = fltarr(niterations, nwav)   
   int_new_all(0,* )= int                               ; initial intensity

; F_avg (average value of spline fit, original resolution)
   int_avg_all = dblarr(niterations, nwav)    
   
; Percent deviation of spline fit average from true average (original resolution)
   int_dev_all = dblarr(niterations, nwav)
   i_d_max = dblarr(niterations)   ;   maximum for iteration

; Loop over iterations

   for i = 1, niterations-1 do begin

; Loop over original wavelength grid
      for j = 0, nwav-1 do begin

; F_1/2, value of spline fit at position wav of previous iteration
;        (wav is equal to the midpoint of the bin only if the original grid is uniform)
         jfmin = fact*j
		 jfmax = fact*(j+1) - 1
         fhalf = interpol(intf_all(i-1,jfmin:jfmax),  $
		         wavf(jfmin:jfmax), wav(j))				 
;    The following line can replace the above if there is need to speed up the calculation  
;    and if the original grid is approximately uniform
;		 fhalf = intf_all(i-1, fact*j + fact/2)

; F_avg, bin-averaged value of spline fit at previous iteration
         favg = total(intf_all(i-1, fact*j:fact*(j+1)-1))/fact
         int_avg_all(i-1, j) = favg
         cor = fhalf/favg
		 
; I, corrected intensity, original resolution (intensity appropriate to position wav)
         int_new_all(i, j) = cor*int(j)
         cor_all(i, j) = cor
		 
      endfor
	  
; Deviation of spline fit average, F_avg, from true average, int
         ss = where(int ne 0.)
         int_norm = max(int)
         int_dev_all(i-1,*) = (int_avg_all(i-1,*) - int)/int_norm
		 i_d_max(i-1) = max(abs(int_dev_all(i-1,ss)))

		 if (i_d_max(i-1) le int_dev_max) then begin
		    print, 'Converged after ', i-1, ' iterations'
			intf = reform(intf_all(i-1,*))
		    goto, jump1
		 endif

; F, new spline fit
      intf_all(i,*)= interpol(reform(int_new_all(i,*)), wav, wavf, $
	                         /spline)  
												 
   endfor
   
   print, 'Not converged after ', niterations, ' iterations'
   print, 'Maximum fractional intensity deviation = ',   $
           max(abs(int_dev_all(niterations-2,*)))
   intf = reform(intf_all(niterations-1,*))
   
jump1:

; Correct NaN values
   test=finite(intf)
   ss=where(test eq 0)
   intf(ss)=0.
   
   ss = where(i_d_max ne 0.)
   idmax = i_d_max(ss)
   
; Corrected intensities at the original grid positions
   int_cor = int_new_all(i-1,*)   

   jump99:
   return

   end

