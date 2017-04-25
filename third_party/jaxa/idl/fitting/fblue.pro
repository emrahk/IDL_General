;+
; Project     : YOHKOH-BCS
;    
; Name        : FBLUE
;
; Purpose     : Compute 2 component gaussian where one is blueshifted
;
; Explanation : Gaussian is sum of 2 gaussians in which
;               width of blueshifted component is proportional to blueshift
;               velocity. 
;
; Category    : fitting
;
; Syntax      : f=fblue(x,a,pder)
;
; Inputs      : x = dependent variable
;         	a = background + gaussian coefficients such that,
;               f = a(0)+a(1)*x+a(2)*x^2+a(3)*exp -[(x-a(4))/a(5)]^2 +
;                   a(6)*exp -[(x-a(4)+a(7))/fac*a(7)]^2
;
; Outputs     : f = 2 component gaussian
;
; Opt Outputs : pder = partial derivatives wrt 'a'
;
; Keywords    : extra = extra optional variable in which user can return
;               miscellaneous information.
;
; Common      : FBLUE - contains proportionality constant between
;               Doppler width of blueshifted component and blueshift velocity
;               --> width=fac*blueshift
;
; Restrictions: None.
;
; Side effects: None.
;
; History     : Version 1,  17-July-1993,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;- 

        function fblue,x,a,pder,extra=extra

        common fblue,fac

        if n_elements(fac) eq 0 then fac=1.

        a(7)=(a(7) > .0001)
        a(5)=(a(5) > .0001)
        a(6)=(a(6) > .0001)

        back=a(0)+a(1)*x+a(2)*x^2

        d1=abs((x-a(4))/a(5)) < 10.d
        d2=abs((x-a(4)+a(7))/fac/a(7)) < 10.d
        s1=exp(-d1^2)
        s2=exp(-d2^2)
        f=(back+a(3)*s1+a(6)*s2) 
	if n_params(0) le 2 then return,f 

;-- compute partials

        pder=fltarr(n_elements(x),n_elements(a))

	pder(0,0) = 1.
        pder(0,1) = x
        pder(0,2) = x^2
	pder(0,3) = s1
        pder(0,4) = 2.*a(3)*s1*(x-a(4))/a(5)^2+2.*a(6)*s2*(x-a(4)+a(7))/(fac*a(7))^2
        pder(0,5) = 2.*a(3)*s1*(x-a(4))^2/a(5)^3
        pder(0,6) = s2
        pder(0,7) = 2.*a(6)*s2*(x-a(4)+a(7))*(x-a(4))/fac^2/a(7)^3

        return,f & end
