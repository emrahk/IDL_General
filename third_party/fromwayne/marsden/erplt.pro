pro erplt,x,lex,uex,y,ey,linear
;
;******************************************************************************
;
;    Procedure to plot error bars on spectra. Stolen from DLB's spec_plot
;
;   Written 8/19/92  LAF
;******************************************************************************
;
xi=fltarr(2) & yi = xi
l=n_elements(x)
for it=0,l-1 do begin
   xi(0) = x(it)
   xi(1) = x(it)
   yi(0) = y(it)+ey(it)
   yi(1) = y(it)-ey(it)
   if (not keyword_set(linear)) then if (yi(1) le 0) then yi(1)=1e-13
   oplot,xi,yi,line=0
   xi(0) = lex(it)
   xi(1) = uex(it)
   yi(0) = y(it)
   yi(1) = y(it)
   oplot,xi,yi,line=0
endfor
end
