pro wmean, x, dx, mu, sigma

if (n_params() eq 0) then begin
   print,'USAGE: wmean,x,dx,mu,sigma'
   print,' INPUTS:  x,     array of input values'
   print,'          dx,    array of errors on input values'
   print,' OUTPUTS: mu,    weighted mean of x'
   print,'          sigma, error on mu'
   return
endif

xnew = double(x)
dxnew = double(dx)

num = total( xnew / (dxnew)^2.d )
den = total( 1.d / (dxnew)^2.d )

mu = num/den

sigma = sqrt( 1.d / den )

return
end
