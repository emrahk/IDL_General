pro besel_k1,X,F

 if (X LE 2.0) then begin
    y=X*X/4.0
    F=(alog(X/2.0)*beseli(X,1))+(1.0/X)*(1.0+y*(0.1544+y*(-0.6728+y*(-0.1816$
       +y*(-0.1919e-1+y*(-0.1104e-2+y*(-0.4686e-4)))))))
 endif else begin
    y=2.0/X
    F=(exp(-X)/sqrt(X))*(1.2533+y*(0.235+y*(-0.3656e-1+y*(0.1504e-1+$
       y*(-0.7804e-2+y*(0.3256e-2+y*(-0.6825e-3)))))))
 endelse

 return

end
