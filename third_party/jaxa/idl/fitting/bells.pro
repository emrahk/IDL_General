;+
; Project     : SOHO - CDS     
;                   
; Name        : BELLS()
;               
; Purpose     : Fits bell splines to data array.
;               
; Explanation : Provides a flexible way to 'draw' a curve through a set of 
;               data.  The interpolating line's tautness is controlled by the
;               number of splines fitted.
;               
; Use         : IDL> yapprox = bells(x,y,xapprox,nspline)
;    
; Inputs      : x,y - data arrays
;               xapprox - x values at which data are to be approximated (can
;                         be same array as x.
;               nspline - number of splines to fit, small number = taut string
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns approximated values at xapprox
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Data analysis
;               
; Prev. Hist. : From an old Yohkoh routine from an older C program which 
;               was copied from an even older Fortran program by J Bok of the 
;               Institute of Physics, The Charles University, Prague.
;
; Written     : C D Pike.  RAL, 22-Nov-96
;               
; Modified    : 6-Jul-2004.  Fixed typo in array dimension.  CDP 
;
; Version     : Version 2, 6-Jul-2004
;-            

function bells,x,y,xapr,nspl
;
;  limit number of splines
;
max_num = n_elements(x)/2
;
;  error check
;
if nspl lt 2 then begin
   bell
   print,' Number of splines set to 2.'
   nspl = 2
endif

if nspl ge  max_num then begin
   bell
   print, ' Not a sensible number of splines for data set.'
   repeat begin
      print,' Reduce number of splines to at least ',max_num-2,format='(a,i4)'
      print,' '
      read,' Give number of splines to fit: > ',nspl
   endrep until nspl gt 1 and nspl le max_num-2
endif

;
;  storage arrays
;
c     = fltarr(max_num*7+22)
r     = fltarr(max_num+2)
a     = fltarr(max_num+5)
yapr  = fltarr(n_elements(xapr))
xpart = fltarr(max_num+2)


np = n_elements(x)


;
;  number of output points
;
napprox = n_elements(xapr)

;
;  data window to be used ie all
;
xa = x(0)
xb = x(np-1)

;
;  spline step and boost number of splines to include those centred at
;  xa-step and xb+step
;
step = (xb-xa)/(nspl-1.0)
nspl2 = nspl + 2

;
;  generate equidistant partition in [xa-step,xb+step]
;
for k=1,nspl2   do begin
   xpart(k-1) = xa + step*(k-2)
endfor

;
;  assuming all data given is to be used
;
first = 0
last = np - 1

;
;  another error check
;
npint = last - first + 1
if nspl2 gt npint then begin
   print,' Error - too many splines for the number of data points.'
   yapr(*) = 0.0
   return,yapr
endif

;
;  zero work arrays
;
c(*) = 0.0
r(*) = 0.0

;
;  set up coefficients for linear equations
;
for m=0,3 do begin
   i1 = first
   for j=1,nspl2-m do begin
      ind = (7*j) - 3 + m
      if j le 3 then begin
         i1 = first
      endif else begin
         i1 = first
         while x(i1) le xpart(j-3) do begin
            i1 = i1 + 1
         endwhile
      endelse
      if j lt nspl2-2 then begin
         i2 = i1
         while (x(i2) le xpart(j+1)) and (i2 lt last) do begin
            i2 = i2 + 1
         endwhile
         i2 = i2 - 1
      endif else begin
         i2 = last
      endelse

;
;  compute coefficients and rhs of eqns
;             
      for i=i1,i2 do begin
         dist = abs(x(i) - xpart(j-1))
         sp1 = spl_func(dist,step)
         if m eq 0 then begin
            sp2 = sp1
            r(j-1) = r(j-1) + y(i)*sp1
         endif else begin
            dist = abs(x(i) - xpart(j-1+m))
            sp2 = spl_func(dist,step)
         endelse
         c(ind-1) = c(ind-1) + sp1*sp2
      endfor
   endfor
endfor

;
;  elements of matrix under the main diagonal
;
for k=1,nspl2-1 do begin
   kk = 7*k-1
   c(kk+3) = c(kk-2)
   c(kk+9) = c(kk-1)
   c(kk+15) = c(kk)
endfor

;
;  solve equations
;
for k=1,nspl2-1 do begin
   for m=1,3  do begin
      ii = 7*k - 3
      jj = ii + (6*m)
      factor = -c(jj-1)/c(ii-1)
      for mm=1,3  do begin
         c(jj+mm-1) = c(jj+mm-1) + factor*c(ii+mm-1)
      endfor
      r(k+m-1) = r(k+m-1) + factor*r(k-1)
   endfor
endfor

for k=1,nspl2+3  do begin
   a(k-1) = 0.0
endfor

for kk=1,nspl2 do begin
   k = nspl2 + 1 - kk
   jj = 7*k
   a(k-1) = r(k-1) - c(jj-1)*a(k+2) - c(jj-2)*a(k+1) - c(jj-3)*a(k)
   a(k-1) = a(k-1)/c(jj-4)
endfor

;
;  generate approximated function values
;
for i=1,napprox  do begin
   xx = xapr(i-1)
   first = fix((xx - xpart(0))/step)
   last = first + 3
   if first eq 0 then first = 1
   if last gt nspl2 then last = nspl2
   yapr(i-1) = 0.0
   for k=first,last  do begin
      xl = xpart(0) + step*(k-1.0)
      dist = abs(xx - xl)
      yapr(i-1) = yapr(i-1) + a(k-1)*spl_func(dist,step)
   endfor
endfor

;
;  return array of fitted values
;
return,yapr

end
