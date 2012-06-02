function beselk0,X

 if (X LE 2.0) then begin
    y=X*X/4.0
    R=(-alog(X/2.0)*beseli(X,0))+(-0.5772+y*(0.4228+y*(0.2307+y*(0.3489e-1+$
      y*(0.2627e-2+y*(0.1075e-3+y*0.74e-5))))))
 endif else begin
    y=2.0/X
    R=(exp(-X)/sqrt(X))*(1.2533+y*(-0.7832e-1+y*(0.2190e-1+y*(-0.1062e-1+$
       y*(0.5879e-2+y*(-0.2515e-2+y*0.5321e-3))))))
 endelse

 return,R

end
