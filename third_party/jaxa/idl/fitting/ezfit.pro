;+
; Project     : SOHO - CDS     
;                   
; Name        : EZFIT
;               
; Purpose     : Easy Gauss fit to data.
;               
; Explanation : Fits a Gaussian + background to a cursor-selected region
;               in any data array.
;               
; Use         : 'IDL>  ezfit,wave,data,wave_limits,k=k'
;    
; Inputs      : wave - typically a wavelength array, but can be plain
;                      pixels.
;
;               data - the data array,, MUST have same dimensions as 'wave'
;               
; Opt. Inputs : wave_limits - limits the initial plot to this region
;                             of the input array.  Must be a 2-element
;                             array eg [120,150].
;               
; Outputs     : Print results to screen
;               
; Opt. Outputs: None
;               
; Keywords    : k - constant to determine order of background fit
;                        k = 0  background = zero (default)
;                        k = 1  background = constant
;                        k = 2  background = linear
;                        k = 3  background = quadratic
;
;
; Calls       : CDS_GAUSS
;
; Common      : None
;               
; Restrictions: K=3 does not work because of a bug in CDS_GAUSS
;               
; Side effects: None
;               
; Category    : Spectral, util
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 11-Feb-96
;               
; Modified    : Better overlayed fit.  CDP, 10-Jun-96
;
; Version     : Version 2, 10-Jun-96
;-            

pro ezfit,win,datain,wlim,k=k

;
;  Help....
;
if (n_params() lt 2) or (k gt 3) or (k lt 0) then begin
    print,'Use: ezfit,wave,data,[wave_start,wave_end],k=k'
    print,' k = 0  background = 0'
    print,' k = 1  background = constant'
    print,' k = 2  background = linear'
    print,' k = 3  background = quadratic'
    return
endif

;
;  if wavelength limits not given, then use the max possible
;
if n_elements(wlim) eq 0 then begin
   wlim = [win(0),last_item(win)]
endif

;
;  if background order not given then use constant zero value
;
if not keyword_set(k) then k = 0

;
;  limit the original plot
;
n0 = where(win ge wlim(0) and win le wlim(1),count)
if count gt 0 then begin
   w = win(n0)
   data = datain(n0)
endif else begin
   print,'No data in that range'
   return
endelse

;
;  try to be clever
;
if w(1)-w(0) eq 1.0 then begin
   xt = 'Pixels'
endif else begin
   xt = 'Wavelength'
endelse

;
;  plot raw data
;
plot,w,data,psym=10,xtit=xt,chars=1.2,xstyle=1

;
;  2 cursor inputs to select fit region
;
print,'Select region to fit with cursor.  '
print,'If fit not possible, double click on eye-ball centre'
print,'When finished, click cursor outside of plot axes.'
print,' '

while 1 do begin

   cursor,a1,b,3,/data
   oplot,[a1,a1],[0,10000],line=2
   if (a1 lt !x.crange(0)) or (a1 gt !x.crange(1)) or $
      (b lt !y.crange(0)) or (b gt !y.crange(1)) then goto, finish

   cursor,a2,b,3,/data
   oplot,[a2,a2],[0,10000],line=2
   if (a2 lt !x.crange(0)) or (a2 gt !x.crange(1)) or $
      (b lt !y.crange(0)) or (b gt !y.crange(1)) then goto, finish


;
;  sort just in case
;
   if a1 gt a2 then begin
      temp = a1
      a1 = a2
      a2 = temp
   endif

;
;  find data indices
;
   nn1 = max(where(w lt a1))
   nn2 = min(where(w gt a2))

;
;  temporary arrays and fit them
;
   x = w(nn1:nn2)
   y = data(nn1:nn2)

;
;  allow exit with no fit
;
   if n_elements(x) gt 5 then begin
      fit = cds_gauss(x,y,c,k)
      fit1 = cds_gauss(x,y,c,k,inter=100)

;
;  overplot on original plot
;
      oplot,fit1(*,0),fit1(*,1),thick=2

;
;  check if in raw or wavelength-type mode
;
      if total(x) eq total(indgen(n_elements(x))+min(n0)+nn1) then begin
         raw = 1
      endif else raw = 0
      if not raw then begin
         f = c(1)
         n1 = max(where(x lt f))
         n2 = min(where(x gt f))
         f1 = x(n1)
         f2 = x(n2)
         pix = (f-f1)/(f2-f1) + n1 + nn1 + min(n0)
         tpix1 = '(pixel: '+fmt_vect([pix],format='(f8.3)',/no_par)+')'
         tpix2 = '(pixel: '+fmt_vect([c(2)/(f2-f1)],format='(f8.2)',/no_par)+')'
      endif else begin
         tpix1 = ''
         tpix2 = ''
      endelse

;
;  Inform of results
;
      print,' '
      print,'Height: '+strtrim(string(c(0),form='(f8.2)'),2)
      print,'Centre: '+strtrim(string(c(1),form='(f9.3)'),2)+'  '+tpix1
      print,'Sigma:  '+strtrim(string(c(2),form='(f8.2)'),2)+'  '+tpix2

;
;  subtract off background
;
      if n_elements(c) gt 3 then begin
         back = n_elements(fit)*((fit(0)+last_item(fit))/2.0)
         n = indgen(n_elements(c)-3)+3
         c = c(n)
         case n_elements(c) of
               1: bf = intarr(n_elements(x))+c(0)
            else: bf = poly(x,c)
         endcase
         oplot,x,bf,thick=3,line=2
         print,'Background parameters: '+fmt_vect(c)
      endif else begin
         back = 0
         bf = 0
      endelse

;
;  calculate total intensity
;
      int_fit = strtrim(string(total(fit)-total(bf),form='(f8.2)'),2)
      int_dat = strtrim(string(total(y)-total(bf),form='(f8.2)'),2)
      print,' '
      print,'Integrated intensity (background subtracted): '+int_fit
      ;print,'                                  (raw data): '+int_dat
      print,' '
   endif else begin
;
;  check if in raw or wavelength-type mode
;
      if total(x) eq total(indgen(n_elements(x))+min(n0)+nn1) then begin
         raw = 1
      endif else raw = 0
      f = average([a1,a2])
      if not raw then begin
         n1 = max(where(x lt f))
         n2 = min(where(x gt f))
         f1 = x(n1)
         f2 = x(n2)
         pix = (f-f1)/(f2-f1) + n1 + nn1 + min(n0)
         tpix1 = '(pixel: '+fmt_vect([pix],format='(f8.3)',/no_par)+')'
      endif else begin
         tpix1 = ''
      endelse

;
;  Inform of results
;
      print,' '
      print,'Centre: '+strtrim(string(f,form='(f9.3)'),2)+'  '+tpix1
      print,' '
   endelse
endwhile
finish:

end


