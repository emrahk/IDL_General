;+
; Project     : SSW
;
; Name        : GOES_FLUXES
;
; Purpose     : This procedure calculates the expected fluxes from the GOES X-ray
;		detectors in Watts/meter^2 (reported units) as a function of
;		temperature and emission measure.
;
; Category    : GOES
;
; Explanation : This procedure utilizes the tables in GOES_TEM_OLD made with MAKE_GOES_RESP which
;		have already calculated the fluxes in both GOES channels for GOES 6,7,8,9 and
;		the others (with somewhat less confidence)
;
; Use         : GOES_FLUXES, Temperature, Emission_meas, Flong, Fshort
;
; Inputs      :
;		Temperature - temperature in MegaKelvin
;		Emission_meas- Emission measure in units of 1e49 cm^-3
;
; Opt. Inputs : None
;
; Outputs     : Flong - flux in Watts/meter^2 in GOES 1-8 Angstrom channel
;		Fshort- flux in Watts/meter^2 in GOES 0.5-4 Angstrom channel
;
; Opt. Outputs: None
;
; Keywords    :
;		ABUND : Default is 0 - They have the same meaning as in goes_tem.pro
;			0: Chianti Coronal Abundance model
;			1: Chianti Photospheric model
;			2: MEWE calc using Meyer model - what we used before CHIANTI- considered obsolete
;		SATELLITE- GOES satellite number
;		DATE- Time of observation in ANYTIM format, needed for GOES6 which changed
;		its long wavelength averaged transfer constant used in reporting measured
;		current as Watts/meter^2
; Calls       : GOES_TEM
;
; Common      : None
;
; Restrictions: Temperature between 1 and 98 MegaKelvin,
;
; Side effects: None.
;
; Prev. Hist  : VERSION 1, RAS, 30-JAN-1997
;
; Modified    : 7-apr-2008, ras, updated to provide inverse
;	operations to GOES_TEM and uses same databases with same basic meanings for parameters.
;	Differences are minor, temperature - tempr, emission_meas - emis, satellite - sat
;	flong and fshort form yclean - avback.  Units are the same for flux, temperature,
;	emission measure
;
;
;-
;==============================================================================
pro goes_fluxes, temperature, emission_meas, flong, fshort, $
	 satellite=satellite, date=date, abund = abund, error=error

flong = 0.0
fshort= 0.0
error = 1
default, abund, 0 ;coronal chianti
abund = (abund >0 )< 2

case 1 of
	abund le 1:	goes_flux49, temperature, emission_meas, flong, fshort, $
	sat=satellite, date=date, photospheric=abund, error=error
	else: begin
		goes_tem_old, flong, fshort, temperature, emission_meas, satellite=satellite, date=date
		error = 0
		end
	endcase

end
