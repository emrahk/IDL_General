PRO rbnary, vec, sgvec, rbvec, sgrbvec, edges, xarr=xarr, xout=xout
;
; rebin an array 
; 
;   vec      the array to rebin
;   sgvec    uncertainties (sigmas) in vec values
;   rbvec    OUTPUT:  the rebinned version of vec
;   sgrbvec  OUTPUT:  sigmas in rbvec
;   edges    array of bin boundaries for rbvec. just the indices in
;            vec if no xarr is given
;   xarr     array of x values corresponding to the entries in vec
;   xout     OUTPUT:  array of x values corresponding to rbvec
;   
;
nbins = n_elements(edges) - 1
rbvec = dblarr(nbins)
sgrbvec = dblarr(nbins)
varvec = sgvec^2
wght = 1./varvec
wvec = vec*wght
;
; if xarr is not given, then edges just gives the bin indices
IF (NOT keyword_set(xarr) ) THEN BEGIN 
    FOR i = 0, nbins-1 DO BEGIN 
        lo = edges(i)
        hi = edges(i+1)-1
        rbvec(i) = total(wvec(lo:hi))/total(wght(lo:hi))
        sgrbvec(i) = 1.d/sqrt(total(wght(lo:hi)))
    END
ENDIF ELSE BEGIN 
; if xarr is set, then edges has x values corrsponding to xarr
    xout = dblarr(nbins)
    FOR i = 0, nbins-1 DO BEGIN 
        indx = where(xarr GE edges(i) AND xarr LT edges(i+1), nvals)
; it's possible that none of xarr falls within this bin
        IF nvals NE 0 THEN BEGIN
            rbvec(i) = total(wvec(indx))/total(wght(indx))
            sgrbvec(i) = 1.d/sqrt(total(wght(indx)))
            xout(i) = total(xarr(indx))/nvals
        ENDIF ELSE BEGIN
            rbvec(i) = -1
            sgrbvec(i) = 0
            xout(i) = (edges(i) + edges(i+1) )/2.
        ENDELSE
    END
;    
ENDELSE   
;
END  
