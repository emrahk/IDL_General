;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: find_limb2.pro
; Created by:    Liyun Wang, GSFC/ARC, October 7, 1994
;
; Last Modified: Fri Oct  7 10:36:29 1994 (lwang@orpheus.gsfc.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO find_limb2, img1, x0, y0, r0, r_err, oblateness, ob_angle, bias, 	$
			brightness,sig_bright,sxt=sxt,qtest=qtest
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;	FIND_LIMB2
;
; PURPOSE:
;       Find the solar coordinates from an aspect camera image.
;
; EXPLANATION:
;	Uses the IDL function SOBEL to differentiate, then fits to circle.
;	Return sun center coordinates, solar radius, error estimate,
;	and oblateness estimate determined from the Fourier spectrum
;	of the limb location. Outputs are in (real) pixel units.
;
; CALLING SEQUENCE:
;	find_limb, img, 	$
;	   [x0, y0, r0, r_err, oblateness, ob_angle, bias, $
;	   brightness, sig_bright,/sxt,qtest=qtest]
;
; INPUTS:
;	img 	= input image 
;
; OUTPUTS:
;	x0	= pixel location of sun center, x (1st harmonic of radius)
;	y0	= pixel location of sun center, y
;	r0	= radius in pixel units
;	r_err	= uncertainty in r0 determination from scatter
;	oblateness 	= second harmonic of radius
;	ob_angle	= phase of 2nd harmonic
;	bias		= distortion of limb due higher harmonics
;	brightness 	= most probable signal at x0,y0
;	sig_bright	= sigma of brightness
;
; OPTIONAL INPUT PARAMETERS:
;	qtest	= 1 for messages+pause, = 2 for messages+plots+pause,
;		= 3 for messages+plots (no pause)
;
; KEYWORD PARAMETERS:
;	SXT -- If set, results will be in units of SXT 1x1 pixels, otherwise
;	       results are in units of pixels of the input image 
;
; CALLS:
;       FIT_CIRCLE, GAUSS_FUNCT2
;
; RESTRICTIONS:
;	1. The input image is assumed to have an oblateness that is < 5%.
;	2. Missing data in the middle of the image will cause large values
;	   in the derivative which are not compensated for.
;	3. The data is assumed to be ge 0.  (Values less than zero will not
;	   be handled correctly by the histogram function).
;	4. In determining summation mode for SXT=1, uses n_elements(img(*,0)).
;	5. To compute brightness, uses a box that is 1/3 * r0 centered at x0,y0.
;	   The image must contain this box (i.e., small crescents may be 
;	    be absent, but a large portion missing at the middle of the
;	    image will cause problems).
;		
; SIDE EFFECTS:
;	None
;
; CATEGORY :
;
; COMMON BLOCKS:
;	None
;
; MODIFICATION HISTORY:
;	HSH written in IDL version 1, Feb. 1991
;	HSH updated with V.2 on real orbital data, Sep. 1991
;	19-Nov-91 MDM - Added a correction factor for changing the
;			resolution back to 1x1 (because of un-summed columns)
;	19-aug-92 JRL+HSH  V3.0 Numerous changes to fix/improve algorithm.
;				Much more robust for SAA data.
;				Brightness is now most probable signal at x0,y0.
;	 1-sep-92 JRL	V3.1	Brightness calculation taken from mean of 
;				histogram
;        Liyun Wang, GSFC/ARC, October 7, 1994
;           Incorporated into the CDS library
;           Made it to return a flag (!err=-1) if it fails to yield good result
;
; VERSION:
;       Version 1, October 7, 1994
;-
   !err = 0
   IF N_PARAMS() EQ 0 THEN BEGIN ; Print information
      PRINT,'FIND_LIMB2 V3.1 (sep-92)'
      PRINT,'FIND_LIMB2,img,					$'
      PRINT,'	[x0, y0, r0, r_err, oblateness, ob_angle, bias, $'
      PRINT,'	   brightness, sig_bright,/sxt,qtest=qtest]'
      !err = -1
      RETURN
   ENDIF

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;  The following parameters control data selection
   rad_limit = 0.95		; Radial limit on interior to exclude
   bright_limit = .5		; Fraction of peak limb signal to cut
   hist_min = .05               ; (HSH to explain this)
   limb_sharp = 0.01		; fraction width of annulus containing limb at
                                ;   final iteration step.
   bright_box = 1/3.		; Size of box at x0, y0 for brightness 
                                ;   calculation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;  Check the dimensions
   dim = SIZE(img1) 
   IF dim(0) LT 2 THEN BEGIN
      PRINT,'*** Error in find_limb: Input array must be 2-d'
      x0 = 0. & y0 = 0. & r0 = 0. & r_err = 1000.
      !err = -1
      RETURN
   ENDIF

   numx = dim(1)		; Number of pixels in the x direction

;
;  Do Sobel filter. Find limb pixels and centroid.
;
   img = img1(*,*,0)
   img = sobel(img)

;  Try to eliminate the very large Sobel values which might be the result
;  of some kind of noise.

   tot_pix = N_ELEMENTS(img)
   hh = histogram(img)          ; Histogram of Sobel image
   j = 1 & not_finished = 1
   WHILE( not_finished ) DO BEGIN
      ii = WHERE(hh GT j)
      max_sobel = MAX(  (INDGEN(N_ELEMENTS(hh)))(ii)    )
      limb_pixels = WHERE((img GT bright_limit*max_sobel) AND $
                          (img LT max_sobel))
      num_pix = N_ELEMENTS(limb_pixels)
      IF (j GT 1) THEN BEGIN	; Assume each loop will result in more pixels
         ccc_percent = (FLOAT(num_pix) - prev_num_pix) / prev_num_pix 
         IF (ccc_percent LT hist_min) AND 			$
            (FLOAT(num_pix)/tot_pix GT .005) THEN not_finished = 0
      ENDIF
      IF KEYWORD_SET(qtest) THEN BEGIN
         IF j EQ 1 THEN BEGIN
            ccc_percent = -9999
            prev_num_pix = num_pix
         ENDIF
         PRINT,'j,prev,num,ccc=',j,prev_num_pix,num_pix,ccc_percent
         IF qtest GE 2 THEN BEGIN
            xx = INDGEN(N_ELEMENTS(hh))
            plot,xx(ii),hh(ii),yrange=[0,200],title='j='+STRTRIM(j,2)+$
               '; change='+STRTRIM(ccc_percent,2)
            bell = STRING(7b)
            ans = '' & IF qtest LT 3 THEN READ,'Pause '+bell+bell,ans
         ENDIF
      ENDIF
      j=j+1
      prev_num_pix = num_pix
      IF j GT 10 THEN BEGIN     ; Prevent an inifinite search situation
         PRINT,'Warning:  find_limb did not find a good cutoff in Sobel space'
         PRINT,'          The resulting fit may be bad'
         not_finished = 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Major change here: Return with !err=-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
         !err = -1
         RETURN
      ENDIF
   ENDWHILE
;
;  Calculate positions of limb pixels:

   x = limb_pixels MOD numx
   y = limb_pixels  / numx

;  Compute weighted average centroids for first guesses of x0,y0.
   totimg = total(img) 	
   y0 = TOTAL(img#FINDGEN(N_ELEMENTS(img(0,*))))/totimg	
   x0 = TOTAL(FINDGEN(N_ELEMENTS(img(*,0)))#img)/totimg	
   r0 = TOTAL(SQRT((x-x0)^2+(y-y0)^2))/N_ELEMENTS(x) ; First guess to radius
   
   FOR i=0,3 DO BEGIN		; Fit for solution 3 times
      IF i EQ 0 THEN BEGIN	
;        Initial guess
         IF KEYWORD_SET(qtest) THEN PRINT,' ** Initial Fit ** '
      ENDIF ELSE IF i EQ 1 THEN BEGIN
;        Restrict the calculation to pixels near the limb
         true_limb = WHERE(rad GT rad_limit*(total(rad))/N_ELEMENTS(rad))
         x = x(true_limb) & y=y(true_limb)
         IF KEYWORD_SET(qtest) THEN $
            PRINT,' ** 2nd Fit: Eliminate inside of',rad_limit
      ENDIF ELSE BEGIN
;        Tigher restriction on the pixels near the limb
         rad2 = (rad - rr(2))/rr(2) ; Residual
         IF i EQ 2 THEN xxx = 1-rad_limit ELSE xxx = limb_sharp
         not_spots = WHERE(abs(rad2) LT xxx)
         x = x(not_spots) & y=y(not_spots)
         IF KEYWORD_SET(qtest) THEN PRINT,' ** 3rd/4th Fit: Accept within ',xxx
      ENDELSE
      IF KEYWORD_SET(qtest) THEN BEGIN
         npix = N_ELEMENTS(x)
         IF i EQ 0 THEN n_start = npix ELSE	 			$
            tot_discard = n_start - npix
         PRINT,'Number of pixels in fit =',STRTRIM(npix,2),		$
            ';  Number discarded=',STRTRIM(n_start-npix,2)
         IF qtest GE 2 THEN BEGIN
            erase & PLOTS,x,y,psym=1,/dev
         ENDIF
      ENDIF
      rr=fit_circle(x,y,tol=.00001)
      x0 = rr(0) & y0 = rr(1) & r0 = rr(2) ; solutions
      dx=x-x0
      dy=y-y0
      angle = ATAN(dy,dx)       ; = tan(dy/dx)
      rad = SQRT(dx^2+dy^2)
      IF KEYWORD_SET(qtest) THEN BEGIN
         PRINT,'Iter:',i,';  x0,y0,r0=',x0,y0,r0,FORMAT='(a,i2,a,3f10.2)'
         bell = STRING(7b)
         ans = '' & IF qtest LT 3 THEN READ,'Pause '+bell+bell,ans
      ENDIF
   ENDFOR

;
;  Analyze limb shape by fitting harmonics (1,2,3,4 * theta).
;
;  r0 = total(rad)/n_elements(rad)
   r0 = rr(2)
   rad = rad - r0
   sin_fun = sin(angle)
   cos_fun = cos(angle)
   sin_1 = poly_fit(sin_fun, rad, 1, sin_fit, yband, ssigma, a)
   cos_1 = poly_fit(cos_fun, rad, 1, cos_fit, yband, csigma, a)

   r_err = SQRT(ssigma^2+csigma^2)/SQRT(N_ELEMENTS(rad))
   rad = rad-(sin_1(0)+cos_1(0))/2-sin_1(1)*sin(angle)-cos_1(1)*cos(angle)
   sin_fun = sin(2*angle)
   cos_fun = cos(2*angle)
   sin_2 = poly_fit(sin_fun, rad, 1, sin_fit, yband, sigma, a)
   cos_2 = poly_fit(cos_fun, rad, 1, cos_fit, yband, sigma, a)
   rad = rad-(sin_2(0)+cos_2(0))/2-sin_2(1)*sin(2*angle)-cos_2(1)*cos(2*angle)
   sin_fun = sin(3*angle)
   cos_fun = cos(3*angle)
   sin_3 = poly_fit(sin_fun, rad, 1, sin_fit, yband, sigma, a)
   cos_3 = poly_fit(cos_fun, rad, 1, cos_fit, yband, sigma, a)
   rad = rad-(sin_3(0)+cos_3(0))/2-sin_3(1)*sin(3*angle)-cos_3(1)*cos(3*angle)
   sin_fun = sin(4*angle)
   cos_fun = cos(4*angle)
   sin_4 = poly_fit(sin_fun, rad, 1, sin_fit, yband, sigma, a)
   cos_4 = poly_fit(cos_fun, rad, 1, cos_fit, yband, sigma, a)
   rad = rad-(sin_4(0)+cos_4(0))/2-sin_4(1)*sin(4*angle)-cos_4(1)*cos(4*angle)
;
;  Generate outputs.
;
   x0 = x0 + cos_1(1) 
   y0 = y0 + sin_1(1) 
   ob_angle = atan(cos_2(1)/sin_2(1))
   oblateness = SQRT(cos_2(1)^2 + sin_2(1)^2)
   bias = SQRT(sin_3(1)^2 + cos_3(1)^2 + sin_4(1)^2 + cos_4(1)^2)

; --------- Compute the brightness at the center --------------------
;	    Take the mean and standard deviation of the distribution

   IF N_PARAMS() GE 9 THEN BEGIN
      nnx = FIX(bright_box * r0 + .5) ; Number of pixels
      img2 = img1(x0-nnx/2:x0+nnx/2,y0-nnx/2:y0+nnx/2)
      hh = histogram(img2)
      xx = MIN(img2) + INDGEN(N_ELEMENTS(hh))
      ii = WHERE(hh GT 0)
      cc = fltarr(4)
      fg = fltarr(4)
      sdev = stdev(img2,mean)
      fg(0) = [MAX(hh),mean,sdev,0.] ; 1st guesses: peak, centroid, 
                                     ; width, background
;  yfit = gaussfit2(xx(ii),hh(ii),cc,fg)
      cc = fg                   ;*** No gaussfit2 call
      gauss_funct2,xx(ii),cc,yfit ;*** Bec. no gaussfit2 call
      brightness = cc(1)        ; Centroid of the histogram
      sig_bright = cc(2)        ; 1/e Gaussian width of histogram 
      IF KEYWORD_SET(qtest) THEN BEGIN
         PRINT,'Gaussfit results=',cc
         IF qtest GE 2 THEN BEGIN
            plot,xx,hh,psym=10
            oplot,xx(ii),yfit   ; Show the fitted result
         ENDIF
         bell = STRING(7b)
         ans = '' & IF qtest LT 3 THEN READ,'Pause '+bell+bell,ans
      ENDIF                     ; keyword_set(qtest)
   ENDIF                        ; n_params() ge 9

; --------- Convert output to SXT 1x1 pixels ------------------------

   IF KEYWORD_SET(sxt) THEN BEGIN
      off_corr = [-1, 0, 1, -1, 3] ;MDM added 19-Nov-91
                                ; changing from 1x1 to 1x1, no offset
                                ; changing from 2x2 to 1x1, offset = 1 
                                ; (1x1 pixels 1&2 are 2x2 pixel 0)
                                ; changing from 4x4 to 1x1, offset = 3 (1x1
                                ; pixels 3,4,5&6 are 4x4 pixel 0) 

      sum = 1024/numx		; Summation for SXT (use number of x pixels)
      x0 = x0 * sum + off_corr(sum)
      y0 = y0 * sum
      r0 = r0 * sum
      r_err = r_err * sum
      oblateness = oblateness * sum
      bias = bias * sum
   ENDIF

   RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'find_limb2.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
