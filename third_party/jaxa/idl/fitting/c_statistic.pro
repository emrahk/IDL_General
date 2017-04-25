

;c_statistic.pro

function c_statistic,f_obs,f_mod,            $
                     F_MOD_MIN=f_mod_min,    $
                     CHISQ=chisq,            $
                     NN=NN,        			 $
                     QUIET=QUIET, $
                     ERROR=ERROR, $
                     ERRMSG=ERRMSG, $
                     EXPECTATION=expectation
;+
;
; PURPOSE:
;      To provide a goodness-of-fit statistic valid for very low countrates
;      e.g., counts/bin < 10  (Webster Cash, AP.J., 1979)
;
; INPUTS:
;      f_obs = array of integer counts
;      f_mod = same size array of positive model counts (likely
;      non-integer), some or all must be positive to be evaluated
;	   non-positive values are excluded from the computation
;
; Keywords:
;
;	   F_MOD_MIN: If f_mod is not positive everywhere, one can set a minimum
;      allowed value using the f_mod_min keyword.
;      CHISQ; if set, the chi-squared statistic for Poisson
;      distributed f_obs will be returned.
;
;      EXPECTATION: if set to an existing variable, the expected
;      C-statistic will be returned in it.
;      NN: This will return the number of valid pts where f_mod gt 0
;      ERROR: set to 1 if computation failed, normally no positive f_mod
;      ERRMSG: returns message for ERROR set.  '' for ~ERROR
;
;
; NOTES:
;      If f_mod and f_obs form the best possible match, cash_statistic
;      will have a local minimum (which may be <1 or > 1).  This is
;      not true for chi-squared when counts/bin < 10.
;      If counts/bin >> 10, cash_statistic = Chisquared
;	   F_mod eq 0 rejected if f_mod_min not set gt 0
;	   F_mod lt 0 causes warning if f_mod_min not set ge 0, only f_mod gt 0 used
;
; HISTORY:
;      EJS April 19, 2000
;      W. Cash Ap.J., 1979
;      EJS May 1, 2000 -- FLOATED f_mod to prevent f_obs/f_mod
;                         becoming zero if f_obs and f_mod both INTEGER.
;      EJS Jun 6, 2000 -- Added option to get expectation of C-statistic
;      Kim, Mar 4, 2005 -- Uploaded to SSW
;	   6-oct-2010, richard.schwartz@nasa.gov, added some protections to the inputs so
;		they'll remain unchanged.  combined some terms on the computation
;		of the Cash (c) statistic, Only printing warning for negative f_mod
;      26-oct-2010, enhanced failure mode information for no positive f_mod
;      19-nov-2010, richard.schwartz@nasa.gov, handle the case where nw is 0.  Before it would crash
;      24-feb-2011, richard.schwartz@nasa.gov, reduce the where calls on x_mod by using the complement wnz
;      11-Apr-2011, Kim. corrected 24-feb change - use ncomp (previously, if wnz=-1, nn was 1, not 0)
;-

error = 1
errmsg= 'C-statistic failed, normally no positive expectation values'
default, quiet, 1
x_mod =float(f_mod) ;Use x_mod internally because it's bad to modify inputs
if keyword_set(f_mod_min) then   x_mod=x_mod>(f_mod_min)

wz = where(x_mod le 0, nz, comp=wnz, ncomp=nn)
;nn = n_elements(wnz) ; use ncomp above instead
if ~quiet && (where(x_mod lt 0))[0] ne -1 then $

 message,/continue, 'f_mod must be gt 0!, some values lt 0. Evaluating only for positive f_mod!!!!'

x_obs = f_obs

if total(x_mod) lt 0 then begin
	errmsg = 'Total predicted counts from f_mod lt 0.  C-stat is meaningless'
	if ~quiet then message,/continue, errmsg
	return, 0
	endif
;wnz = where( x_mod gt 0, nn)
if nn eq 0 then begin
		errmsg = 'No valid points for C-stat. No positive expectation values, f_mod.'
		if ~quiet then message,/continue, errmsg
		return, 0
		endif ;number of valid elements, expected cts le 0 don't count
if nn ne n_elements(x_mod) then begin
	x_obs = x_obs[wnz]
	x_mod = x_mod[wnz]
	endif
if keyword_set(chisq) then begin
 z_chi2=(x_obs-x_mod)^2/x_mod
 statistic=avg(z_chi2)
 nn = n_elements(x_obs)
endif else begin
;Revised from the EJS coding for enhanced efficiency
;Old coding follows
; z_cash=(2./NN)*f_mod
; w=where(f_obs NE 0)
;
; z_cash(w)=(2./NN)*(f_obs(w)*alog(f_obs(w)/f_mod(w))+f_mod(w)-f_obs(w))
; statistic=total(z_cash)
;RAS coding is used now:
 statistic = total(x_mod - x_obs)
 w=where(x_obs NE 0, nw )
;RAS, 19-nov-2010, handle the case where nw is 0.  Before it would crash

 x_obs = (nw ge 1) ? x_obs[w] : 0.0
 statistic= (2./NN)*(statistic +  ((x_obs[0] gt 0) ? total( x_obs*alog(x_obs/x_mod[w])): 0.0))
endelse
if n_elements(expectation) GT 0 then expectation=c_expected(x_mod)
errmsg = ''
error  = 0
return,statistic
end

