function fftrecover, time, rate, fourier_zero_index=fourier_zero_index
;+
; NAME:
;             fftrecover
;
;
; PURPOSE: 
;            try to reconstruct incomplete data by the assumption of
;            zero fourier components. 
;
; CATEGORY: 
;             timing tools
;
;
; CALLING SEQUENCE:
;          fftrecover( time,rate)
; 
; INPUTS:
;             time : a vector containing the time in arbitary units
;             rate : a vector containing the countrate
;	
; KEYWORD PARAMETERS:

;             chatty   : if set, be chatty
;   
; OUTPUTS:
;             returns time/rate array (2-d, 0: time, 1: rate) with all
;             binnings reconstructed.
;
; COMMON BLOCKS:
;             none
;
;
; SIDE EFFECTS:
;             none
;
;
; RESTRICTIONS:
;
;
; PROCEDURE:
;             <Laenger Erklaerung, wenns denn mal tut>
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;             Version 0.1, 2002/05/28, Eckart Goehler IAAT
;                          Initial version.
;-


;; debugging input: create simulated field:
IF n_elements(time) EQ 0 THEN BEGIN 
  simdat,time,rate, noise=0., num=1000,gap_level=1.5

  ;; create gaps:
  gap_index = indgen(20)*20+200
  data_index = indgen(n_elements(time))
  data_index[gap_index] = -1
  data_index = data_index[where(data_index NE -1)]

  time = time[data_index]
  rate = rate[data_index]

  ;; define fourier space 
  fourier_zero_index    = indgen(n_elements(gap_index)) + 30

  ;; debug
  plot,time,rate
  
ENDIF 

;; default binning distance
delta_t=time[1] - time[0]

;; number of bins in entire output data set (reconstructed)
full_data_n = (time[n_elements(time)-1]-time[0]) / delta_t + 1

;; input  data set with zeros for missing input
;; relies on equal spacing
full_data=double(histogram(time,binsize=delta_t))

;; index where in full data no datapoints defined 
gap_index = where(full_data eq 0)

;; no gaps -> we're finished
IF gap_index[0] EQ -1 THEN  return, fft(rate)

;; complement of gaps: the data index:
data_index = indgen(full_data_n)
data_index[gap_index] = -1
data_index = data_index[where(data_index NE -1)]


;; set in input field the rate information:
full_data[data_index] = rate



;; m - number of gap elements:
m = n_elements(gap_index)

;; default index of zero parts of m fourier components:
;; (keep low frequencies):
IF n_elements(fourier_zero_index) EQ 0 THEN $
  fourier_zero_index    = indgen(m)+(full_data_n - m)/2+1


;; default index of nonzero parts of fourier components:
fourier_data_index    = indgen(full_data_n)
fourier_data_index[fourier_zero_index] = -1
fourier_data_index = where(fourier_data_index NE -1)


;; check: fourier zero components must equal number of gaps:
IF n_elements(fourier_zero_index) NE m THEN $
  message, "Error: Number of zero frequencies does not match to gap number"



;; compute fft array:
;; 1.) the exponent i*j/N (modulo bla?):
A1 =   (dindgen(full_data_n) # dindgen(full_data_n) / full_data_n) MOD 1.D0

;; 2.) the array itself:
A = exp(dcomplex(0.D0,-2.D0*!DPI * A1)) /(full_data_n)

;; no gaps -> standard fft (test only!):
;; test: seems to equal fft(full_data)
;; return, a##full_data



;; create submatrices:

;; a_11 - m X n
;exponent =   (fourier_data_index # gap_index  / full_data_n) MOD 1.D0
exponent =   (data_index # fourier_zero_index    / full_data_n) MOD 1.D0
a11 = exp(dcomplex(0.D0,-2.D0*!DPI * exponent))/(full_data_n)

;; a_12 - m X m
;exponent =   (fourier_zero_index # gap_index  / full_data_n) MOD 1.D0
exponent =   (gap_index # fourier_zero_index     / full_data_n) MOD 1.D0
a12 = exp(dcomplex(0.D0,-2.D0*!DPI * exponent))/(full_data_n)


;; the other matrices are not needed currently:
;; a_21 - n X n
;; exponent =   (fourier_data_index # data_index  / full_data_n) MOD 1.D0
;; a21 = exp(dcomplex(0.D0,-2.D0*!DPI * exponent))/(full_data_n)

;; a_22 - n X m
;; exponent =   (fourier_zero_index # data_index   / full_data_n) MOD 1.D0
;; a22 = exp(dcomplex(0.D0,-2.D0*!DPI * exponent))/(full_data_n)


;; recover data:

;; 3.) compute inverse of gap-array (time/memory-consuming!)


;; z - partial mapping of existing data to fourier space:
z =  -reform(a11##rate)


;; solve A11*rate + A12*y = 0:
full_data[gap_index] =  lu_complex(a12,z ,/double)
return, full_data

end







