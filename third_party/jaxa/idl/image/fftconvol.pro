 
function fftconvol,fft1,fft2
 
   ; FFT convolution.  The inputs are assumed already fourier transformed.
 
   return,float(fft(fft1*fft2,-1))
 
end
