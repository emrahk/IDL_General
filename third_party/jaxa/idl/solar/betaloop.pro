;+
;NAME:
;  BETALOOP
;PURPOSE:
;  Martens (2009) dimensionless, analytic solution for coronal loops
;  profile with nonuniform heating. The solution is implemented using a 
;  regularized incomplete beta function, hence the name 'betaloop'. The 
;  loop is assumed to be symmetric, with constant width and constant
;  pressure (that is, gravity is ignored --- which assumes the loop length is
;  small compared to the gravitational scale height). By default, a plot
;  of T(x) is produced on the current graphics device. The results can be put 
;  into real, physical units by use of the scaling laws in the paper.
;CALLING SEQUENCE:
;  betaloop, [x [, T [, heating]]] [, Npts=Npts] [, alpha=alpha] [, gamma=gamma]
;INPUT PARAMETERS:
;  None. Amazingly, this procedure will return something for nothing. :)
;OPTIONAL OUTPUT PARAMETERS:
;  x = array of normalized positions along the loop. Nonuniform spacing is 
;     employed to improve sampling throughout the loop.
;  T = array of normalized Temperatures along the loop.
;  heating = array of normalized volumetric heating values along the loop.
;OPTIONAL KEYWORD INPUTS:
;  Npts = number of points a long the loop for which the position and
;     temperature will be returned.  Default 1000. The sampling is nonuniform.
;     If you want the temperature at particular positions (or vice versa),
;     the best approach is to call betaloop with enough points for a well-
;     sampled result and then interpolate to find the desired points.
;  alpha = Parameter controlling the nonuniform heating function. Positive 
;    alpha concentrates the heating near the looptop, more so for larger alpha.
;    Negative alpha concentrates heating near the footpoints.  Analytical (and
;    as it turns out, static numerical) solutions only exist for alpha>-2.5.
;    Default=0, constant heating per unit volume.
;  gamma = Parameter controlling the radiative loss function, which goes
;     as T^(-gamma). Default = 0.5.
;  nograph = if set, then suppress plotting of T(x).
;  xlog = if set, then use a logarithmic x-axis for the plot.
;  Tlog = if set, then use a logarithmic T-axis for the plot.
;  psym = passed through to the plot command.
;MODIFICATION HISTORY:
;  2009-Aug-04  C. Kankelborg, P. Martens
pro betaloop, x, T, heating, Npts=Npts, alpha=alpha, gamma=gamma, $
   nograph=nograph, xlog=xlog, tlog=tlog, psym=psym
;-

;Handle keyword defaults
if n_elements(Npts) ne 1 then Npts = 1001
if n_elements(alpha) ne 1 then alpha = 0.0d
if n_elements(gamma) ne 1 then gamma = 0.5d


;see Eq. (29) in Martens (2009), and Eq. (25) showing that k=lambda+1.
k= (5.5d + gamma) / (4d + 2d *gamma + 2d * alpha)
u=( (findgen(Npts)+1)/Npts )^((2.5d + alpha)/2.0)
   ;nonuniform u-spacing to accommodate extreme alpha values. The u=T=x=0
   ;point is omitted, which is convenient for log plots.
x=ibeta(k,0.5d,u)  ;  regularized incomplete beta-function from IDL lib.
t=u^(1d / (2.5d + alpha))
if not keyword_set(nograph) then begin
   plot,x,t, title='Analytic Loop Model', xtitle='position', $
      ytitle='temperature', xlog=xlog, ylog=Tlog, psym=psym
endif

;Heating function
heating = T^alpha
ss = where(finite(heating))
heating /= max(heating[ss])


end
