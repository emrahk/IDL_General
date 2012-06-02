pspec = replicate(0.d,4097)
FOR i = 0, 87 DO BEGIN
   fft_f , t2, lcarr(i,*), f, p
   pspec = pspec + p
END
pspec = pspec/88.
END
