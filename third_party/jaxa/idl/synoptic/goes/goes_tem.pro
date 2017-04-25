;+
; Name:
;	GOES_TEM
; Purpose:
;     Drop-in replacement for old TEM_CALC that allows abundance choices.
;	TEM_CALC calculates the temperature and emission measure from the GOES ionization X-ray chambers.
;
; 	The data array must already be cleaned of gain change spikes.  The background
;	in each channel is input through avback or bkarray calling argument.
;
; Explanation:
;	This procedure organizes the inputs and outputs into the GOES_MEWE_TEM and GOES_CHIANTI_TEM procedures.
;   GOES_MEWE_TEM interpolates on
;	the ratio between the long and short wavelength channel fluxes using pre-calcuated tables for the
;	fluxes at a series of temperatures for fixed emission measure.  Note that ratios which lie outside of
;	the default lower limits for the fluxes,
;	and particularly negative values in the case of background subtracted inputs, are
;	returned with fixed values of 4.0 MegaKelvin and 1.0e47 cm-3 for the temperature and emission measure.
;	Normally, those limits are 1e-7 and 1e-9 for the long and short wavelength channel inputs.
;
; Keywords:
;  Mandatory Inputs:

;	YCLEAN-  GOES data cleaned of spikes.
;
;  Optional Inputs:
;	TARRAY- time array
;   AVBACK - A single background value for each channel
;   BKARRAY - An array of background values for each channel (matches yclean array)
;	NOBACKSUB- If set, no background is subtracted
;	SAVESAT  - Number of GOES satellite, calibration changes at 8, default is 8
;	SAT - same meaning as SAVESAT, default is 8, takes precedence if SAVESAT is also present
;	DATE - date in anytim format if tarray is not fully qualified (only sec of day)
;  Outputs:
;
;	NOSUBTEMPR-temperature in Megakelvin, if background not subtracted.
;	NOSUBEMIS-emission measure in 1e49 cm-3, if background not subtracted.
;
;	TEMPR- temperature in Megakelvin, if background subtracted.
;	EMIS-emission measure in 1e49 cm-3, if background subtracted.
;	ADUND-abundances to use: 0=coronal/CHIANTI (Default), 1=photospheric/CHIANTI, 2=Meyer(MEWE)
; Common Blocks:
;	None
; Calls:
;	goes_mewe_tem, goes_chianti_tem
; History:
;	Kim Tolbert 11/92
;	Documented RAS, 15-May-1996,
;	changed cutoff limits, changed default response
;	to GOES_TEM, eback and sback removed as keywords since they did nothing.
;	ras, 22-july-1996, add savesat
;	ras, 20-nov-1996, added GOES6 and GOES7 as GOES_TEM was upgraded
;	ras, 29-jan-1997, add date keyword needed for correct GOES6 calculation!
;	ras, 4-aug-1998, richard.schwartz@gsfc.nasa.gov, integrate GOES10 and future GOESN.
;	smw, 14-feb-2005, add abundance keyword , calls to chianti routines for
;                       photospheric or coronal abundance cases
;   Kim, 13-Dec-2005, This was called sw_tem_calc by smw.  Change to goes_tem and
;      change the routine it calls for mewe (previously goes_tem) to goes_mewe_tem. Also
;      put avback in calling arguments instead of in common.
;   Kim, 9-Jan-2006.  Added bkarray keyword, and setting avback_ch0
;	RAS, 23-oct-2006, broke out computational routine, goes_tem_calc and
;		removed the horrid loopback for the non back subtracted values
;		added SAT keyword that means the same as SAVESAT and has precedence
; Kim, 10-Aug-2008.  For SMS-1, SMS-2 (91,92), use tables for GOES1
; Kim, 01-Dec-2009, For GOES14, use tables for GOES12 until we have new tables
; Kim, 02-Dec-2009, GOES14 tables are now online, so removed change of 1-dec-2009
; Kim, 06-Jun-2011, The calc for avback_ch0 was wrong if bkarray only had 2 elements
;-
;
;  -----------------------------------------------------------------------

pro goes_tem, tarray=tarray, yclean=yclean, tempr=tempr, emis=emis, $
    nosubtempr=nosubtempr, nosubemis=nosubemis, savesat=savesat, $
    sat = sat, $
     nobacksub=nobacksub, date=date, abund=abund, avback=avback, bkarray=bkarray,$
     _extra=_extra


date_in = (anytim(/sec,fcheck(tarray,0)))(0)
if date_in lt 86400. then  date_in = fcheck(date, systime(1)+anytim('1-jan-1970'))
if not keyword_set(abund) then abund=0     ; default = coronal

case abund of
	0:begin
		chianti=1
		photospheric=0
		end
	1:begin
		chianti=1
		photospheric=1
		end
	else: chianti=0
	endcase

ysub = yclean

cutoff0 = 1.0e-8
cutoff1 = 1.0e-10


default, savesat, 8 ;savesat
default, sat, savesat ;newer sat keyword takes precedence oover savesat

; For SMS-1, SMS-2 (91,92), use tables for GOES1
if sat gt 90 then sat = 1

avback_ch0 = -1
ny = n_elements(yclean) / 2
bk = fltarr(2, ny)
if keyword_set(avback) then if avback[0] ne -1. then begin
	bk[0] = reproduce(avback[*], ny)
	;for ich = 0,1 do ysub(*,ich) = yclean(*,ich) - avback(ich)
	avback_ch0 = avback[0]
endif

if keyword_set(bkarray) then if bkarray[0] ne -1. then begin
	bk = bkarray
	avback_ch0 = n_elements(bkarray) eq 2 ? bkarray[0] : average(bkarray[*,0])
endif
ysub = yclean - bk

if avback_ch0 gt 1.5e-6 then begin
	 cutoff0 = 5.e-7
	 cutoff1 = 5.e-9
endif
default, abund, 2

goes_tem_calc, ysub,   tempr, emis, sat=sat, cutoff=[cutoff0,cutoff1], $
	date=date_in, chianti=chianti, photospheric=photospheric, _extra=_extra
goes_tem_calc, yclean, nosubtempr, nosubemis, sat=sat, cutoff=[cutoff0,cutoff1], $
	date=date_in, chianti=chianti, photospheric=photospheric,_extra=_extra

end
