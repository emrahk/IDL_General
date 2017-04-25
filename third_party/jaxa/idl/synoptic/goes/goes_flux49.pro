;+
; Routine: GOES_FLUX49
;
; Purpose: For a temperature in MegaKelvin and Solar Emission Measure in 1e49cm^(-3)
;		return the expected Long and Short Wavelength fluxes from the GOES XRS
;		in units of Watts/Meter^2. Based on solar emission derived from Chianti Version 5.2
;
;
; Inputs:
;		TMK - temperature - vector or scalar in MegaKelvin
;			valid range 4-100 MegaKelvin
;			where TMK is out of range, FL and FS are returned as if for 4 and 100 respectively
; 		EM49 - solar emission measure in units of 1e49cm^(-3)

; Outputs:
;		FL - Long wavelength GOES XRS flux in Watts/meter^2
;		FS - Short wavelength GOES XRS flux in Watts/meter^2
;
; KEYWORD;
;	SAT - Number of GOES satellite - 1-12 valid
;	DATE - DATE in anytim readable format, fully referenced.
;		GOES8 fudge factor is date dependent
;	PHOTOSPHERIC - if set use photospheric abundance
;		in GOES_GET_CHIANTI_[TEMP,EM] routines, otherwise coronal is default
;	ERROR - if set then input is problematic
;
; HISTORY: 4-apr-2008, richard.schwartz@nasa.gov,
;	22-apr-2011, richard.schwartz@nasa.gov, changed goes6 date to 28-jun-1983
;
;-
pro goes_flux49, tmk, em49, fl, fs, $
	sat=sat, date=date, photospheric=photospheric,$
	error=error

error = 1
default, tmk ,[ 9.1, 9.33, 10.4]
default, em49, 1.0
default, photospheric, 0 ;default is coronal abundance
ntmk = n_elements(tmk)
nem  = n_elements(em49)
fl   = -1
fs   = -1

case 1 of
	ntmk eq nem :
	ntmk eq 1 : tmk = tmk[0] + em49*0.0
	nem  eq 1 : em49= em49[0] + tmk*0.0
	else: Message,/continue,'Number of Tmk and Em49 must be the same or 1'
	endcase


if keyword_set(sat) then goes=fix(sat) else goes=8
valid_temp = tmk > 1. < 100.

goes_get_chianti_temp,  0.1, t01, sat=goes, r_cor=rt,$
	r_pho=rt_pho, photospheric=photospheric

if photospheric eq 1 then rt = rt_pho



rt=reform(rt[sat-1,*])

logtemp=findgen(101)*.02d0
temp=10^logtemp

fl6 =1e-6+rt*0.0

goes_get_chianti_em, fl6, temp, em6, sat=goes, photospheric=photospheric


;em6[i] is the emission measure necessary to obtain fl of 1e-6 at temp[i]

ord = sort(valid_temp) ; spline requires a monotonic input
fl  = valid_temp
fs  = valid_temp
al10_em_tmk = spline(logtemp, alog10(em6), alog10(valid_temp[ord]), .01)
fl[ord]     = 10^(-6 + 49-al10_em_tmk) * em49[ord]
fs[ord]     = spline(logtemp, rt, alog10(valid_temp[ord])) * fl[ord]


;--------------------------- Takeout any fudge factors ----------------------------

  ; convert long channel flux if needed - GOES 6 data before 28-Jun-83, from 93, ras 22-apr-2011
 if anytim(fcheck(date, 1.4160960e+008),/sec) lt 1.4160960e+008 $
      and goes eq 6 then fl = fl / (4.43/5.32)

 ; Recent fluxes released to the public are scaled to be consistent
 ; with GOES-7: in fact recent fluxes are correct and so we need to
 ; remove this correction before proceeding to use transfer functions
 ; old version from Bornmann et al 1989 used until 2005 July in goes_tem
 ; if (goes lt 8) then scl89= fltarr(2)+1. else scl89 = [0.790, 0.920]
 ; new version from Rodney Viereck (NOAA), e-mail to SW, 2004 June 09
 if (goes lt 8) then scl89= fltarr(2)+1. else scl89 = [0.700, 0.850]
 fl = fl * scl89[0]
 ; don't change input arrays
 fs = fs * scl89[1]

 ; now calculate ratio where data are good
; index=where((fs lt 1.e-10) or (b8 lt 3.e-8))
; bratio=(fs>1.e-10)/(b8>3.e-8)
; if (index[0] ne -1) then bratio[index]=0.003

error = 0
end