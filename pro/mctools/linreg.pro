;;
;; Linear Regression on array (x,y); gives y=a x + b
;;
PRO linreg, x, y, a, b
  IF (n_elements(x) NE n_elements(y)) THEN BEGIN
      error, "linreg: number of elements not equal"
      stop
  ENDIF 
  n=n_elements(x)
  sxy = total(x*y)
  sx=total(x)
  sy=total(y)
  sx2=total(x*x)
  
  a=(n*sxy-sx*sy)/(n*sx2-sx*sx)
  b=(sy*sx2-sx*sxy)/(n*sx2-sx*sx)
END 

  
