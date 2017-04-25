function tem_thermal_power, T, EM, flux_at_1AU=flux_at_1AU, _extra=_extra,	$
	mewe=mewe, nbin=nbin, nmax=nmax, tmax=Tmax, energies=energies, spectrum=spectrum

on_error, 2							; On error, return to caller
COMPILE_OPT hidden

;+
; NAME:
;	tem_thermal_power
; PURPOSE:
;	Calculate thermal X-ray power for a given temperature and emission measure
; CATEGORY:
;	X-ray
; CALLING SEQUENCE:
;	power = tem_thermal_power(T, EM, flux_at_earth=flux_at_earth,	$
;				[/meve, nbin=nbin, nmax=nmax, tmax=tmax, spectrum=spectrum, ...])
; INPUTS:
;	T				array[npnt]; type: float
;						temperature in MK
;	EM				array[npnt] of same type and size as T
;						emission measure in 10^49 cm^-3
;					(these are the same units as used by goes_tem)
; OPTIONAL INPUT PARAMETERS:
;	/mewe			by default the power is calculated using Hugh Hudsons function
;					'thermal_power' (he calls this an 'interim program'; it was
;					written in 1993 ......) It is simple and fast and does not require
;					any specification of energy range.
;
;					if keyword /mewe is set then mewe_spec is called to get the thermal
;					energy spectrum. In that case the keywords below should be used to fix
;					the energy range for integration.
;
;	If /mewe is set then the power is calculated by summing over nbin energy intervals covering
;	the energy range 0 up to nmax*kB*T. The centers of the energy intervals are
;
;		(i/nbin)*nmax*kB*T,	i=1,nbin
;
;	The next three keywords can be used to set the energy intervals over which to sum:
;
;	nbin=nbin		scalar; type: integer; default: 100
;						number of energy intervals
;	nmax=nmax		scalar; type: float; default: 5.0
;						width of total energy range in units of kB*T
;	tmax=tmax		if tmax is set then a single set of intervals corresponding to
;						the specified temperature 'tmax' is used for all [T,EM] pairs.
;					if tmax is not set then for each [T,EM] pair the intervals
;						are based on temperature T (different for each [T,EM] pair).
;
;	_extra=_extra	used to pass arguments to mewe_spec. Any input keyword to mewe_spec
;						other than /erg (which is always set) is permitted.
; OUTPUTS:
;	power			array[npnt]; type: float
;						integrated power in erg/s
; OPTIONAL OUTPUT PARAMETERS:
;	flux_at_1AU=flux_at_1AU
;					array[npnt]; type: float
;						integrated flux at 1 AU in erg/s/cm^2
;						(flux_at_earth = power/(4*pi*r^2) where r = 1 AU)
;
;	The following will exist only if /mewe is set:
;
;	energies=energies
;					array[nbin,npnt]; type: float
;						center energies of energy intervals (keV)
;	spectrum=spectrum
;					array[nbin,npnt]; type: float
;						spectral flux in erg/s/keV at center energy of the intervals
; CALLS:
;	mewe_spec, thermal_power
; PROCEDURE:
;	Revives the /energy option provided by Hugh Hudsons obsolete Thomas_goes procedure
;	(superseded by goes_tem). Hugh's goes_reducer program now calls goes_tem to get
;	temperature and emission measure, then calls this routine to get the integrated power.
; MODIFICATION HISTORY:
;	JUNE-2001, Paul Hick (UCSD/CASS; pphick@ucsd.edu)
;-

mewe = keyword_set(mewe)

if mewe then begin
	message, /info, 'using function "mewe_spec"'

	if n_elements(nbin ) eq 0 then nbin  = 100
	if n_elements(nmax ) eq 0 then nmax  = 5

	kB  = 0.08617342							; Boltzmann constant kB = 0.08617342 keV/MK
	AeV = 12.3984								; Wavelength in Angstrom for 1 keV photon

	npnt= n_elements(T)

; Sum over the energy interval (0.01-1.00)*nmax*kB*T over nbin intervals

	dE = nmax*kB/nbin

	oneT = n_elements(Tmax) ne 0

	case oneT of
	0: Tref = T
	1: Tref = replicate(Tmax, npnt)
	endcase

	E = dE*(1+findgen(nbin))#Tref				; Photon energies (in keV)
	L = AeV/reverse(E,1)						; Photon wavelengths in Angstrom

	spectrum = fltarr(nbin, npnt, /nozero)

; mewe_spec returns erg/s from each of the bins

	case oneT of
	0: for i=0,npnt-1 do spectrum[*,i] = reverse( mewe_spec(T[i], L[*,i], /erg, _extra=_extra)   )
	1:					 spectrum[*  ] = reverse( mewe_spec(T   , L[*,0], /erg, _extra=_extra), 1)
	endcase

	power = total(spectrum, 1)					; erg/s for emission measure 10^44 cm^-3

	dE = replicate(dE,nbin)#Tref				; Widths of energy intervals (keV)

	spectrum = spectrum/dE						; erg/s/keV

endif else begin

;	power = 0.
;	fits =   [3.6287055e+21, -2.7878692e+20, 1.1220324e+19, -1.4370703e+17]
;	for i=0,3 do power = power + fits[i]*T^i

	message, /info, 'using function "thermal_power"'
	power = thermal_power(T)					; erg/s for emission measure 10^44 cm^-3

endelse

; 'power' now contains the integrated power in erg/s for a nominal
; emission measure of 10^44 cm^-3. Multiply with the input em (is in
; 10^49 cm^-3; hence the 1e5)

power = power*EM*1e5								; erg/s for emission measure EM
flux_at_1AU = power/(4*!pi*1.495979e13*1.495979e13)	; erg/s/cm^2

return, power  &  end