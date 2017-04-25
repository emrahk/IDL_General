;+
;Name: TEST_GOES_FLUXES
;
;Purpose: This main procedure is a script to test GOES_FLUXES and GOES_TEM
;	to work as expected and to provide the inverse operations for each.
;
; Starting with temperatures and emission measures chosen at random
;	in the operational range of the GOES XRS detectors, determine
;	the observed long and short wavelength fluxes for each model of 3 for
;	each possible spacecraft using GOES_FLUXES.
;	The derived values are then reversed in GOES_TEM and compared.
;	The routines are successful if the values are recovered to within
;	1 in 1000.
;
;History:
;		7-apr-2008, ras
;-
pro test_goes_fluxes, ntrials, seed, out = out

tmk = 4. + randomu(seed, ntrials)*40.
em49 =  .5 +randomu(seed, ntrials)*1.
print, 'Input Temperatures in MegaKelvin', tmk
date = anytim(/date,40.e7 + 9.e8*randomu(seed),/vms) ;date only matters for GOES6
ff  = fltarr(ntrials)
trial= replicate( {em49:0.0, temp:0.0, fl:0.0, fs:0.0, em49out:0.0, tempout:0.0}, ntrials)

trial.em49 = em49
trial.temp = tmk

out = replicate( {abund:0, sat:0, date:date, trial: trial }, 3,7 )

for abund = 0,2 do $
	for sat=6,12 do begin

		goes_fluxes, tmk, em49, fl, fs, sat=sat,  date=date, abund = abund


		yclean=[[fl],[fs]]

		goes_tem, tarray=yclean[*,0]*0.0,$
			date = date,yclean=yclean, tempr=tempr, emis=emis, savesat=sat, abund=abund
		out[abund,sat-6].abund = abund
		out[abund,sat-6].sat   = sat

		trial =out[abund, sat-6].trial
		trial.fl = fl
		trial.fs = fs
		trial.em49out = emis
		trial.tempout = tempr
		out[abund,sat-6].trial = trial
		print, 'ABUND, GOES Sat#', abund, sat
		tratio = tmk/tempr
		emratio  = em49/emis

		;print, tratio, emratio
		if sat eq 6 then begin
			mtratio = 0 & memratio = 0
			endif

		mtratio = mtratio > max(abs(1-tratio))
		memratio = memratio > max(abs(1-emratio))
		if sat eq 12 then begin

			print, 'For ABUND= '+STRTRIM(ABUND,2)+' Values lt 0.001 indicate the methods agree on input and return'
			PRINT,' Max fractional temperature deviation for input and return is ', mtratio
			print, ' Max fractional emission measure deviation for input and return is ', memratio
			endif
		endfor

end