FUNCTION f_lor,v,p
;p(0):when p(0)^2 integrated fractional rms (over -inf to +inf)
;p(1):FWHM
;p(2):frequency
p=abs(p)
L=p(0)*p(1)/(2.*!pi)*(1./((p(1)/2.)^2.+(v-p(2))^2.))
RETURN,L
END
