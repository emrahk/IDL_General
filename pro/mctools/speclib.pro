;
; Speclib.pro: Manipulate Spectra
;
; Dec. 1994, J. Wilms
; wilms@aitxu3.ait.physik.uni-tuebingen.de
;
pro speclib,verbose=verbose
   on_error, 1
   ;;
   ;; Define data-type spectrum
   ;; desc: description of the spectrum
   ;; len: number of points in spectrum, i.e. flux(len-1) is last
   ;;      valid data-point and e(len) is upper boundary of last
   ;;      energy-bin
   ;; flux: 0 for photon number, 1 for flux, 2 for nu f(nu), 3 for
   ;;      phot. In other words
   ;;      flux=0: f(i) = photon number in [e(i),e(i+1)] (ph/cm2 s)
   ;;      flux=1: f(i) = e(i)*Nph        f(nu)          (keV/cm2 s keV)
   ;;      flux=2: f(i) = e(i)^2*Nph   nu f(nu)          (keV^2/cm2 s keV)
   ;;      flux=3: f(i) = Nph                            (ph/cm2 s keV)
   ;; e: beginning of energy-bin, in keV
   ;; f: number of photons or flux in energy-bin
   ;; err: error in f, 0 if not set, negative if f is upper limit
   ;; sat: threshold above which f(nu) values are invalid, negative if
   ;;    not set.
   ;;
   maxpts  = 2500               ; max number of points
   sp = {spectrum, desc:'Spectrum', len:0, flux:0, e:fltarr(maxpts+1), $
         f:fltarr(maxpts), err:fltarr(maxpts), sat:-1.}
   la = {label, ener: 0., text:"", align:0.0, size:1.0, thick:1.0}
   IF (keyword_set(verbose)) THEN BEGIN
       print, 'Spectra Library system variables and data-types' + $
         ' have been added'
   END
END
