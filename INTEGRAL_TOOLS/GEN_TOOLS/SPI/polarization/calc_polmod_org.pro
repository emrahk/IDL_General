
From wcoburn@ssl.berkeley.edu Mon Aug 11 16:28:51 2003
Date: Mon, 11 Aug 2003 16:26:32 -0700 (PDT)
From: Wayne Coburn <wcoburn@ssl.berkeley.edu>
To: emrahk@nickel.ssl.berkeley.edu
Subject: calc_polmod.pro

pro calc_polmod, i=index, polmod=polmod

;;
;; set the filename
;;
spawn,'ls out/*.gz',fl,/sh
fl=fl(index)

tfl=strsplit(fl,'.',/extract)
inf=strjoin(tfl(0:3),'.')


;;
;; Unzip our input file
;;
print,'Uncompressing File ',+fl
spawn,'gunzip '+fl,/sh
print,'Done'

;;
;; Open the file for reading
;;
openr,unit,inf,/get_lun


;;
;; Read in the number of input photons and the angles of the sim
;;
c=' '
readf,unit,c
readf,unit,numphots
readf,unit,numphots


;;
;; The data consists of two section
;;
;; The first is a line indicating the photon number, the
;;    number of scatterings, the total recorded energy
;;    of the Event, and zero
;; For each scattering, there is a subsequent set of n lines
;;    indicating the detector ID, Front/Rear ID, X, Y, Z position
;;    of the event in the detector frame, and the recorded
;;    energy of that event.


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
while (eof(unit) ne 1) do begin
   ;; Initalize the second line we read
   ;;    it will become an array if we have more than
   ;;    one scattering
   l1 = dblarr(6)

   ;; Read the first line of the event
   readf,unit,l0

   ;; There will always be at least one scattering, read it in
   readf,unit,l1

   ;; If there was more than one scattering, read those in as well
   ;;    l1 will become an array at this point
   if (l0(1) ge 2) then begin
      for i=1,l0(1)-1 do begin
         readf,unit,ltemp
         l1 = [[l1],[ltemp]]
      endfor
   endif

   ;; Look for detector/detector coincidences
   coinc = uniq(l1(0,*))
   if ( (l0(1) ge 2) and (n_elements(coinc) eq 2) ) then begin
      ;; We have a detector/detector coincidence

      ;; Increment our photon counter
      nphot = nphot + 1.d

      ;; If the photon only scatters once in the first detector,
      ;; we want to use it
;;      w=where(l1(0,*) eq coinc(0),cnt)
;;      if (cnt le 2) then begin
      if (l1(0,0) ne l1(0,1)) then begin
         npol = npol + 1.d
         if (npol mod 2000 eq 0) then print,npol

         efirst=l1(5,0)   ;; energy of first event
         energy=l0(2) ;; energy of incident photon

         ctheta=1.d + me/energy - me/(energy-efirst)
         if (ctheta gt 0.99999) then ctheta=0.99999
         if (ctheta lt -0.99999) then ctheta=-0.99999
         theta  = acos(ctheta)
         beta   = 1.d/(1.d + (energy/me)*(1.d - cos(theta)))
         polmod = (sin(theta))^2.d/(beta+1.d/beta-(sin(theta))^2)
         ave_polmod = ave_polmod+polmod
      endif

   endif

endwhile

polmod = ave_polmod/nphot

print,'RESULTS'
print,'         Ave polmod: ',strcompress(polmod,/remove_all)
print,'   Num Photons Used: ',strcompress(nphot,/remove_all)
print,' '

;;
;; Close our input file
;;
free_lun,unit

;;
;; Recompress the file
;;
print,'Compressing File ',+inf
spawn,'gzip '+inf,/sh
print,'Done'



;;
;; fin
;;


return
end
