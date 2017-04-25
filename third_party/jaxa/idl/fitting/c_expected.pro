function c_expected,fmod
;+
; NAME: c_expected
;
; PURPOSE: Expectation value of the C-statistic
;
;          The result of the program is the mean C-statistic
;          for an infinite ensemble of Poisson-distributed
;          count rates with mean values given by fmod.
;
; EXPLANATION:
;          The C-statistic is the same as chi-squared for large
;          count rates, but differs significantly when the
;          counts are < 10 per bin.  The expected value is 1.0
;          for large counts/bin, a bit greater than one for
;          counts/bin in the 0.5-10 range, and progressively
;          less than 1 when the counts/bin << 1.
;
; METHOD:  The expectation <C(f)> = SUM { P_n(f) C(n,f) },
;          where the range of n is 0 to infinity, and P_n is
;          the Poisson distribution function (f^n / n!) exp(-f),
;          and the C-statistic is C(n,f)= 2*(f-n*alog(n)-n*alog(f)).
;          This sum is computed using:

;          <C> = Polynomial * exponential - log term for 0 < fmod < 39
;          <C> = 1.000                                  39 < fmod < infinity
;
; INPUTS: fmod (model count rate)  can be a scalar or vector
;
; OUTPUTS: Expectation value of the C-statistic (vector)
;
; EXAMPLE:

; fmod = randomu(seed,20)>.001
; expec=c_expected(fmod)
; print,'Expectation of C-statistic=',expec
;
;
; RESTRICTIONS: fmod must be positive, never zero
;               The approximation is good to better than 0.1% everywhere.
;
; VERSION HISTORY:
;        VERS. 1 EJS July 6, 2000
;
; NOTES:  Tested analytic form of coefficient array, but explicit form is
;         twice as fast.
;         mm=70
;         a=dblarr(mm) & fact_=a & fact_[2]=1.  & a[2]=alog(2.)
;         for j=3,mm-1 do begin
;           fact_[j]=fact_[j-1]*(j-1.)  ; fact_=[0,0,1,2,6,24,120,720,...]
;           a[j]=alog(j)/fact_[j]
;         endfor
;
;
;-

  if (min(fmod) LE 0) then message,'Zero or negative fmod'

; Coefficients for power series.   Double precision is necessary for fmod > 20.
a=[    0.0000000,     0.0000000,  0.69314718D0,  0.54930615D0, 0.23104906D0, $
   0.067059914D0, 0.014931329D0,0.0027026529D0,0.0004125876D0, 5.4494658d-05,$
   6.3453073d-06, 6.6079567d-07, 6.2252151d-08, 5.3547823d-09, 4.2380738d-10,$
   3.1063355d-11, 2.1202440d-12, 1.3541279d-13, 8.1261568d-15, 4.5989801d-16,$
   2.4626823d-17, 1.2513955d-18, 6.0500793d-20, 2.7895838d-21, 1.2293253d-22,$
   5.1879832d-24, 2.1004786d-25, 8.1723449d-27, 3.0601933d-28, 1.1044357d-29,$
   3.8467417d-31, 1.2946089d-32, 4.2147682d-34, 1.3288095d-35, 4.0610751d-37,$
   1.2042524d-38, 3.4679838d-40, 9.7069424d-42, 2.6428737d-43, 7.0045949d-45,$
   1.8084620d-46, 4.5514186d-48, 1.1173057d-49, 2.6769992d-51, 6.2636319d-53,$
   1.4320066d-54, 3.2006105d-56, 6.9969323d-58, 1.4968496d-59, 3.1350464d-61,$
   6.4312670d-63, 1.2927644d-64, 2.5473508d-66, 4.9223676d-68, 9.3312117d-70,$
   1.7359509d-71, 3.1704660d-73, 5.6864406d-75, 1.0019125d-76, 1.7347080d-78,$
   2.9523021d-80, 4.9403678d-82, 8.1309992d-84, 1.3165358d-85, 2.0976827d-87,$
   3.2898482d-89, 5.0798161d-91, 7.7243170d-93, 1.1569452d-94, 1.7072766d-96]

  expectation = 1.0 + 0*fmod     ; This is the chi-squared limit: expectation(chisq)=1.0

  w=where(fmod LE 39,n1)  ; power series fails for fmod > 39,
;                           but by then expectation=1.000 is good
  if (n1 GT 0) then begin
    f=fmod[w]
    expectation(w)=2*poly(f,a)*exp(-f)-2*f*alog(f)
  endif

  cexpected=total(expectation)/n_elements(expectation)

return,cexpected
end