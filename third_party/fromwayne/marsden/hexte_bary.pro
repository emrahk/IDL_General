pro hexte_bary,idf,ra,dec,bctime_mjd,verbose=verbose,manual=manual,$
               t0geo=t0geo
;***********************************************************************
; This program computes the arrival time of a photon at the solar 
; system barycenter given the photon's arrival time at the spacecraft.
; Based on the fortran program xtebarycen, with additional help 
; from Joe Fiero's PhD thesis (Stanford, 1995). Variables are:
;          ra..........Right ascension of photon direction (deg)
;         dec..........Declination of photon direction (deg)
;         idf..........IDF # (SC time/16.) of photons
;  bctime_mjd..........Barycentric arrival time (MJD)
;     verbose..........Boolean for printouts
; Other variables/constants are:
;         rea..........Earth sat. vec in 2000 coord (light-s)
;         rca..........Vector from SSBC to spacecraft (light-s)
;        etut..........TDB-UTC in seconds
;      dircos..........Unit vector from sun to source
;         rce..........Vector from SSBC to geocenter (light-s)
;         rcs..........Vector from SSBC to suncenter (light-s)
;         vce..........Time derivative of RCE
;        bary..........Sum of propagation delays (seconds)
;      sundis..........Distance from sun to site (light-s)
;      sunsiz..........Apparent radius of the sun (radians)
;        dtgr..........Relativistic (Shapiro) delay (s)
;      xtepos..........Cartesian coordinates of spacecraft (m)
;      manual..........External UTCF correction (s)
;       t0geo..........Calculating correction for t0geo (no HEXTE)
; First do usage:
;***********************************************************************
if (n_elements(idf) eq 0)then begin
   print,'Usage: Hexte_bary,idf,ra_deg,dec_deg,bctime' + $
         ',[verbose=(boolean)],[manual=(s)],[t0geo=(boolean)]'
   print,'Variables are:
   print,'ra..............Right ascension of photon direction (deg)'
   print,'dec.............Declination of photon direction (deg)'
   print,'idf.............IDF # (SC time/16.) of photons'
   print,'bctime..........Barycentric arrival time'
   print,'verbose.........Printouts?'
   print,'manual..........Manual UTCF correction'
   return
endif
;***********************************************************************
; Define some variables. The quantity G*M_sun/c^3 ("Shapiro") is 
; taken from Shapiro & Teukolsky, p. 484. ;***********************************************************************
if (ks(t0geo) eq 0)then t0geo = 0 else t0geo = 1
ra = double(ra)
dec = double(dec)
daysec = 1d/86400.d0
twopi = 6.28318530717958648d
aultsc = 499.004782d
gauss = .01720209895d
rschw = gauss*gauss*aultsc*aultsc*aultsc*daysec*daysec
shapiro = 4.925490d-6
sunrad = 2.315d
mjdrefi = 49353d
mjdreff = .000696574074d
mjdref = mjdrefi + mjdreff
deg_rad = twopi/360d
c = 2.99792458d+8
num = n_elements(idftime)
dircos = dblarr(3)
ddec = double(dec)
dra = double(ra)
idfsave = idf
;***********************************************************************
; Get the spacecraft's ephemeris and the TIMEZERO time correction, 
; such that TT = timezero + mjdref + MET. Calculate the leapseconds
; addition also (and add).
;***********************************************************************
if (t0geo eq 0)then begin
   get_xyz,idf,xtepos,t0=t0,manual=manual 
endif else begin
   xtepos = [0d,0d,0d]
   idfi = double(long(idf))
   idff = idf - idfi
   add = 0d
   add = add + double(idfi gt 49533d) + $
         double(idfi gt 50082d) - double(idfi lt 49169d) - $
         double(idfi lt 48804d)
   idf = (idfi - 49353d + idff)*86400d/16d + add/16d
   t0 = 0d
endelse
if (ks(manual) ne 0)then t0 = manual
if (t0 eq -1)then t0 = 0d
;***********************************************************************
; Convert spacecraft photon times to terrestrial time (TT). Do this 
; by adding a small offsets equal to the "TIMEZERO" value in the 
; FITS files (see above). Scale the resultant number into units 
; such that the fractional part is between -0.5 and +0.5. If 
; calculating for t0geo, do separate calculations. ;***********************************************************************
met = (double(idf)*16d + t0)*daysec
meti = double(long(met))
metf = met - meti
ijd = meti + mjdrefi + 2400001d
frc = metf + mjdreff - .5d
add1 = double(frc ge 1d)
ijd = temporary(ijd) + add1
frc = temporary(frc) - add1
;***********************************************************************
; Compute the direction cosines of the source from its RA and DEC
;***********************************************************************
dircos(0) = cos(deg_rad*ddec)*cos(deg_rad*dra)
dircos(1) = cos(deg_rad*ddec)*sin(deg_rad*dra)
dircos(2) = sin(deg_rad*dec)
;***********************************************************************
; Now get the vector from the spacecraft to the solar system barycenter
;***********************************************************************
istat = hexte_bary_vctr(ijd,frc,xtepos,rca,rcs,etut,vce)
if(not istat) then begin
   print,'Error in HEXTE_BARY_VCTR:  Status = ',istat
   return
endif
;***********************************************************************
; Compute the photon arrival time at the solar system barycenter
; in Euclidean space
;***********************************************************************
dtprop = dircos(0)*rca(0,*) + dircos(1)*rca(1,*) + dircos(2)*rca(2,*)
dtprop = reform(dtprop)
;***********************************************************************
; Calculate the Shapiro delay due to the sun's gravity.
; (I.I. Shapiro, Phys. Rev. Lett. 13, 789 (1964))
;***********************************************************************
satbdt = total(double(xtepos)*vce/c,1)
rsa = rca - rcs
sundis = sqrt(total(rsa*rsa,1))
dirdis = sqrt(total(dircos*dircos,1))
cth = total(dircos*rsa,1)/(dirdis*sundis)
bary = dtprop - 2d*shapiro*alog(1d + cth) + satbdt + etut
;***********************************************************************
; Scale the output and formulate the final answer in MJD.
;***********************************************************************
bctime_mjd = mjdref + idf*16d*daysec + bary*daysec + t0*daysec
idf = idfsave
if (n_elements(verbose) ne 0)then begin
;***********************************************************************
; Print the answers
;***********************************************************************
   print,'JD = ',ijd
   print,'Dayfrac =',frc
   print,'XTE position (m) = ',xtepos
   print,'Barycenter vector (lt-s) = ',rca
   print,'Dtprop (s) = ',dtprop
   print,'Satbdt (s) = ',satbdt
   print,'cth=',cth
   print,'Shapiro delay =',2d*shapiro*alog(1d + cth)
   print,'vce/c = ',vce
   print,'rcs (lt-s)=',rcs
   print,'rsa (lt-s)=',rsa
   print,'etut = ',etut
   print,'Bary(s) =',bary
endif
;***********************************************************************
; That's all ffolks
;***********************************************************************
return
end

