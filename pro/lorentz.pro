function lorentz, x

;spawn,'pwd',pwd
restore,'~/temp_lor.dat'

a(0) = abs(a(0))
a(1) = abs(a(1))
a(2) = abs(a(2))

den = (x - a(2))^2 + (0.5*a(1))^2

  return, (a(0)*a(1))/(2.0*!pi*den)

end


