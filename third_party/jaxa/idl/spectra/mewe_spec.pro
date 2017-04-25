Function mewe_spec,Te6,wave,photon=photon,erg=erg,elem=elem,abun=abun, $
        cont_flux=cont_flux,cosmic=cosmic,dwave=dwave,edges=edges, $
	wave_range=wave_range,file_in=file_in
;+
;  NAME:
;    mewe_spec
;  PURPOSE:
;    Compute a Mewe thermal spectrum (line + continuum) for EM=1.e44 cm^-3
;  CALLING SEQUENCE:
;    Flux = mewe_spec(Te6,wave)			; ph s-1 
;    Flux = mewe_spec(Te6,wave,/photon)		; ph s-1
;    Flux = mewe_spec(Te6,wave,/erg)		; erg s-1
;    Flux = mewe_spec(Te6,wave,/cosmic)		; Cosmic abundances
;
;  INPUTS:
;    Te6	= Electron Temperature in MK (may be a vector)
;    Wave	= Vector of wavelengths (Ang) (centers of the wavelength bins)
;		  or, if keyword EDGES is set,
;		  a 2xN array of the 2 wavelength edges of N bins.
;
;  OUTPUTS:
;    Flux	= Fluxes in ph s-1 or erg s-1 (total flux with each bin)
;			Fluxes = fltarr(N_elements(Te6),N_elements(wave))
;
;  OPTIONAL INPUT KEYWORDS:
;    Photon	= If set, calculation is made in ph s-1 (default)
;    Erg	= If set, calculation is made in erg s-1
;    Cosmic	= If set, use cosmic abundances (solar is default)
;    Edges	= If set, interpret Wave as a 2xN set of wavelength boundaries
;    file_in	= To specify the input file for linflx explicity.
;  OPTIONAL OUTPUT KEYWORDS:
;    Abun       = Abundances used for calculation
;    elem       = Elements corresponding to the abundances
;    cont_flux	= Continuum flux alone (without line contribution).
;    dwave	= Widths of wavelength bins (Ang)
;    wave_range = Interval over which lines are extracted (Ang)
;
;  METHOD:
;    Calls linflx and conflx.  Linflx reads the line data from either
;    $DIR_SXT_SENSITIVE/mewe_cosmic.genx or $DIR_SXT_SENSITIVE/mewe_solar.genx
;
;    The mewe_cosmic.genx file is taken from the following references:
;
;    Mewe, Gronenschild, van den Oord, 1985, (Paper V)  A. & A. Suppl., 62, 197
;    Mewe, Lemen, and van den Oord,    1986, (Paper VI) A. & A. Suppl., 65, 511
;
;    The solar coronal abundances in mewe_solar.genx a adapted from:
;
;    Meyer, J.-P., 1985, ApJ Suppl., 57, 173.
;
;  MODIFICATION HISTORY:
;    29-oct-92, Written, J. R. Lemen, LPARL
;    25-feb-93, JRL, Added /cosmic option
;     7-jul-93, JRL, Added the file_in= keyword
;     8-jun-94, JMM, Added IF block to avoid crashing when the line
;                    flux comes out to be zero. 
;    13-jul-94, JRL, Added /edges a la R. A. Schwartz cira 1993
;     2-aug-94, JRL, Added the file_in= keyword (again!). Changed header.
;    21-Jun-95, JRL, linflx changed to assume EM=1.e44 cm-3
;     6-Jan-96, JRL, Added the Mewe et al references to the header
;    16-Dec-96, LWA, Added the Meyer reference to the header.
;-


; With no calling arguments, display the calling sequence:

if n_params() eq 0 then begin
  return,'   Flux= mewe_spec(Te6,wave[,/erg]) ; for EM=1.e44 cm-3'
endif

if keyword_set(photon) and keyword_set(erg) then begin
  print,' **** Error in mewe_spec ****',string(7b),string(7b)
  print,'      You cannot specify both /photon and /erg'
  return,-1
endif else if keyword_set(erg) then Units=1 else Units=0

if n_elements(wave) eq 0 then begin
  print,' **** Error in mewe_spec ****',string(7b),string(7b)
  print,'      Wave or Te6 is undefined'
  help,Te6,Wave
  return,-1
endif

if n_elements(cosmic) eq 0 then cosmic = 0	; Solar is default

; Wavelength Bins
if not keyword_set(Edges)  then begin

; Edges aren't specified, only wavelength centers:
	if ((size(wave))(0) eq 2) and ((size(wave))(1) eq 2) then begin
	  message,'** Error:  Wave expected to be defined fltarr(N) or fltarr(1,N)',/cont
	  help,Wave
	  return,-1
        endif
; Make sure the wavelength vector is non-dengenerate
	qsort = sort(wave) 
        ix = n_elements(wave)-n_elements(uniq(wave,qsort))
        if ix ne 0 then begin
	   message,'** Error:  Wavelength vector must be non-degenerate',/cont
	   print,'Number of degenerate bins = ',strtrim(ix,2)
	   help,Wave
	   return,-1
	endif
; Make sure the wavelength vector is monotonically increasing -- if not then sort
	wwave = wave(qsort)
	if min(qsort(1:*)-qsort) gt 0 then delvarx,qsort
; Make sure the wavelength vector is non-zero
        if min(wave) le 0 then begin
	   message,'** Error:  Wavelength vector must be non-negative',/cont
	   print,'min(wave) = ',min(wave)
	   return,-1
        endif
; Compute the bin sizes:
	dwave = (wwave(2:*)-wwave) /2.
	dwave = [dwave(0),dwave,dwave(n_elements(dwave)-1)]	; End bins
	dwave = rebin(transpose(dwave),N_elements(Te6),N_elements(wwave))
	wave_range = [min(wwave),max(wwave)]
	wave_centers = wwave

endif else begin
	if ((size(wave))(0) ne  2) or ((size(wave))(1) ne 2) then begin
	  message,'** Error: Wave not defined for edges, fltarr(2,N)',/cont
	  help,Wave
	  return,-1
	endif
	dwave = reform( wave(1,*)-wave(0,*))
	dwave = abs(  $
		rebin(transpose(dwave),N_elements(Te6),N_elements(wave(0,*))))
	wave_range = [min(wave),max(wave)]
	wave_centers = reform( wave(1,*) + wave(0,*) )/2.
endelse

; Compute the continuum flux (Convert from EM=1.e50 to 1.e44 cm-3):
Flux = (conflx(Te6,Wave_centers,Units+2)/1.e6) * dwave 
cont_flux = flux			; Return continuum flux

; Compute the line flux (assumes EM=1.e44 cm-3):
linflx,Te6,wave_line,Lflux,erg=units,wave_range=wave_range,  $
		elem=elem,abun=abun,cosmic=cosmic,file_in=file_in

; Rebin into the user supplied wavelength bins:
if n_elements(Te6) eq 1 then Flux = transpose(Flux)

;if lflux is zero, then you need not add it in JMM, 8-jun-94
if total(lflux) gt 0.0 then begin ;JMM, 8-jun-94
   for i=0,n_elements(wave_line)-1 do begin
     a=min(abs(wave_line(i)-Wave_centers),cc)
     Flux(*,cc) = Flux(*,cc) + Lflux(*,i)	;changed to vector addition
   endfor					;across Te6 from a loop, ras 93/3/31
endif

dwave = reform(dwave(0,*))
if n_elements(qsort) then begin
  flux = flux(*,qsort)			; Return in the order of the input wave
  dwave = dwave(qsort)
endif

return,reform(flux)			; Line + continuum
end
