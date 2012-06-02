PRO tripp_rad_plot,ima,centx,centy,circ,estimate=estimate,$
                   a=a,xval=xval,yval=yval,count=count,  $
                   silent=silent,verbose=verbose,sky=sky
;+
; NAME:
;                    TRIPP_RAD_PLOT
;
;
;
; PURPOSE:           
;                    Shrink a stellar image to 1D and return 1D-gaussfit parameters. 
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;                    tripp_rad_plot,ima,centx,centy,circ
;
;
; INPUTS:
;                    ima     : image array
;                    centx   : x coordinate of star in image  
;                    centy   : y coordinate of star in image
;                    circ    : distance out to which fit shall be performed
;                    ===> centx, centy and circ together define a
;                         circular area in image that shall be used
;
; OPTIONAL INPUTS:
;                    estimate: array with estimated values for the
;                              gaussfit parameters a: [a0,a1,a2,a3]
;
;
; KEYWORD PARAMETERS:
;                   silent   : no plots at all, little text
;                   verbose  : display all available information
;                   sky      : plotting range optimized for sky
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;                    a       : array of gaussfit parameters:[a0,a1,a2,a3]
; 
;                                    A0 is the height of the Gaussian
;                                    A1 is the center of the Gaussian 
;                                    A2 is the width of the Gaussian
;                                    A3 is the constant term
;                              
;                    f(x) = a[0]*exp( - ( (x-a[1])/a[2] )^2 /2.) + a[3]
; 
;                    xval    : 1D data points (radial distance)
;                    yval    : 1D data points (counts)
;                    count   : 0 if no points within radius, else 1 
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;                    centx, centy cannot be kept fix                     
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;                    2001/05, author: Stefan Dreizler
;                    2001/05, SLS: added header, added /sky,
;                             /silent and /verbose keywords
;                    2001/06, SLS: faster: only test for inclusion in
;                             circle if point is within square with
;                             side length circ 
;                    2001/07, SLS: avoid negative indices for ima
;                             if circ includes areas outside the image; 
;                             avoid negative heights and fwhm for
;                             gauss curve 
;-

;; ---------------------------------------------------------
;; --- PREPARATIONS ---
;;
  dim     = SIZE(ima)
  count   = 0
  
;; ---------------------------------------------------------
;; --- FIND AND PLOT VALID POINTS ---
;;

  FOR i=max([centx-circ,0]),min([centx+circ,dim[1]-1]) DO BEGIN 
    FOR j=max([centy-circ,0]),min([centy+circ,dim[2]-1]) DO BEGIN 
      
      xdiff = (DOUBLE(i)-centx)*(DOUBLE(i)-centx)
      ydiff = (DOUBLE(j)-centy)*(DOUBLE(j)-centy)
      dist  = SQRT(xdiff + ydiff)
      IF dist LE circ THEN BEGIN 
        
        count = count + 1
        IF count EQ 1 THEN BEGIN 
          xval = dist
          yval = ima[i,j]
        ENDIF ELSE BEGIN 
          xval = [xval,dist]
          yval = [yval,ima[i,j]]
        ENDELSE 
        
      ENDIF 
      
    ENDFOR 
  ENDFOR 
  
  IF count EQ 0 THEN BEGIN 
    print,"TRIPP_RAD_PLOT: WARNING no points within the radius"
    a = [-1,-1,-1,-1]
    ;; IF n_elements(estimate) GT 0 THEN a = estimate ?
    return
  ENDIF
  
  ind  = SORT(xval)
  xval = xval[ind]
  yval = yval[ind]
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    IF KEYWORD_SET(sky) THEN BEGIN
      yrange=[MEDIAN(yval)-3*SQRT(MEDIAN(yval)),MEDIAN(yval)+3*SQRT(MEDIAN(yval))]
    ENDIF ELSE yrange=[MEDIAN(yval)*.8,MAX(yval)*1.05]
    plot,xval,yval,psym=1,/ynozero,ystyle=1,  $
      yrange=yrange,$
      xtitle='Pixel',ytitle='Counts'
  ENDIF
  
;; ---------------------------------------------------------
;; --- GAUSSFIT ---
;;
  IF N_ELEMENTS(estimate) EQ 0 THEN $
    estimate=[MAX(yval),0.,1.,MEDIAN(yval)] ;,0.,0.]
  yfit = GAUSSFIT(xval,yval,a,estimate=estimate,nterms=4)
  
;; ---------------------------------------------------------
;; --- DISPLAY RESULTS ---
;;
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    oplot,xval,yfit
  ENDIF
  IF KEYWORD_SET(verbose) THEN BEGIN
;    oplot,[0,circ],[median(yval),median(yval)]
    oplot,[0,circ],[a[3],a[3]]
    oplot,[a[2],a[2]],[MEDIAN(yval)*.8,MAX(yval)*1.05],linestyle=1
    xyouts,a[2],MEDIAN(yval)*.9,'r:= FWHM'
;   fwhm = 2 * sqrt(2.d)*a[2] * sqrt(alog(2.d))
    ind = where(yfit LT a[3]*1.1,cnt)
    IF cnt GT 0 THEN BEGIN 
      oplot,[xval[ind[1]],xval[ind[1]]],[MEDIAN(yval)*.8,MAX(yval)*1.05],$
        linestyle=1    
      xyouts,xval[ind[1]],MEDIAN(yval)*.95,'r:= Fit=Sky*1.1'
    ENDIF 
  ENDIF
  IF KEYWORD_SET(verbose) THEN BEGIN
    print,"TRIPP_RAD_PLOT: Gaussfit Parameters:",a
    print,"TRIPP_RAD_PLOT: Sky background     :",a[3]
  ENDIF

;; ---------------------------------------------------------
;; --- CHECK RESULTS ---
;;
  IF a[0] LT 0. THEN BEGIN
    message,"WARNING: Gaussfit failed (negative height), ",/inf
    message,"         returning estimates for a!",/inf
    a = estimate
  ENDIF
  IF a[2] LT 0. THEN BEGIN
    message,"WARNING: Gaussfit failed (negative FWHM),   ",/inf
    message,"         returning estimates for a!",/inf
    a = estimate
  ENDIF


;; ---------------------------------------------------------
;; --- END ---
;;
END




