pro calc_polmod, datamul, polmod=polmod

;; Initialize a few variables
l0 = dblarr(3)
ltemp = dblarr(6)

me=510.999d ;; keV
polmod=0.0d
ave_polmod=0.0d
dsctang=0.0d
nphot=0.0d
npol=0.0d

;;
;; Read in the data
;;

;; Only energy deposition ge 20 keV will be recorded as multiple
;; events

xx=where((datamul.flag eq 'comp') and (datamul.en[0] ge 20.) and $
                                                 (datamul.en[1] ge 20.))
yy=n_elements(where((datamul.flag eq 'msfd') and (datamul.en[0] ge 20.) and $
                                                 (datamul.en[1] ge 20.)))
num=n_elements(xx)

tot=yy+num
j=0.


for i=0L,num-1L do begin

;;         I should only check nearest neighbors
         if ((psdetnum(datamul[xx(i)].dete[0],$
                       datamul[xx(i)].dete[1]) eq 0)) then j=j+1. else begin
         efirst=datamul[xx(i)].en[0]   ;; energy of first event
         energy=datamul[xx(i)].en[0]+datamul[xx(i)].en[1] ;; energy of incident photon

         ctheta=1.d + me/energy - me/(energy-efirst)
         if (ctheta gt 0.99999) then ctheta=0.99999
         if (ctheta lt -0.99999) then ctheta=-0.99999
         theta  = acos(ctheta)
         beta   = 1.d/(1.d + (energy/me)*(1.d - cos(theta)))
         polmod = (sin(theta))^2.d/(beta+1.d/beta-(sin(theta))^2)
         ave_polmod = ave_polmod+polmod
  endelse
endfor   

print,tot,j
polmod = ave_polmod/(tot-j)

print,'RESULTS'
print,'         Ave polmod: ',strcompress(polmod,/remove_all)
print,'   Num Photons Used: ',strcompress(nphot,/remove_all)
print,' '


end
