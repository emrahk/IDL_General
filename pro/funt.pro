pro funt, x, a, f, pder

f=a(0)*exp(-(x-a(1))^2/(2.*a(2)^2))
if n_params() GE 4 then begin
   pder=fltarr(n_elements(x),3)
  pder(*,0)=f/a(0)
  pder(*,1)=((x-a(1))/(2.*a(2)^2))*f
  pder(*,2)=((x-a(1))^2/a(2)^3)*f
endif
end