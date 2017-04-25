pro linflx,Te6,wave,Flux,Line,Trans,				$
		photon=photon,erg=erg,wave_range=wave_range,	$
		elem=elem,abun=abun,cosmic=cosmic,		$
		file_in=file_in,qstop=qstop
;+
;  NAME:
;   linflx
;  PURPOSE:
;   Compute the Mewe line spectrum for EM=1.e44 cm^-3
;  CALLING SEQUENCE:
;    linflx,Te6,wave,Flux               ; ph s-1
;    linflx,Te6,wave,Flux,/photon       ; ph s-1
;    linflx,Te6,wave,Flux,/erg          ; erg s-1
;    linflx,Te6,wave,Flux,wave_range=wave_range
;    linflx,Te6,wave,Flux,/cosmic	; Use cosmic abudances
;    linflx,Te6,wave,Flux,Line,Trans	; Return line information
;
;  INPUTS:
;    Te6        = Electron Temperature in MK
;  OUTPUTS:
;    wave       = Wavelengths of lines
;    Flux       = Fluxes of lines.  If Te6 is
;                 a vector, then Flux = fltarr(N_elements(Te6),N_elements(wave))
;  OPTIONAL INPUT KEYWORDS:
;    photon     = If set, calculation is made in ph s-1 (default)
;    erg        = If set, calculation is made in erg s-1
;    wave_range = A 2-element vector with the desired lower and upper wavelength
;                 limits (Ang).  For example, wave_range = [2.,60.] will 
;                 calculate only those lines between 2 and 60 A.
;    cosmic	= If set, read the cosmic abundance file
;    file_in	= To explicitly specify the Mewe line-list file.
;  OPTIONAL OUTPUTS:
;    Line	= Character string with ion information
;    Trans	= Character string with transition informaiton
;  OPTIONAL OUTPUT KEYWORDS:
;    Abun	= Abundances used for calculation
;    elem	= Elements corresponding to the abundances
;
;  METHOD:
;    Reads $DIR_SXT_SENSITIVE/mewe_solar.genx
;       or $DIR_SXT_SENSITIVE/mewe_cosmic.genx if /cosmic switch is specified.
;          Data directory is also $DIR_GEN_SPECTRA to support $SSW/gen/idl/spectra.
;
;    Note:  	If Line argument is present, then picklambda is not called
;       	to sum up lines at the same wavelength
;
;  MODIFICATION HISTORY:
;    29-oct-92, Written, J. R. Lemen, LPARL
;    25-jan-93, JRL  -- change call to picklambda
;    25-feb-93, JRL  -- Mewe file converted to genx file.
;     8-apr-93, JRL  -- Added optional output parameter
;     7-jul-93, JRL  -- Added file_in keyword
;    18-may-94, JRL  -- Fixed up check to prevent unnecessary file reads.
;    21-jun-95, JRL  -- Minor change to make 171A line calculation work with
;			with the SPEX85 data files.  And change to be able
;			work with the SPEX95 data files.
;			Changed the units to return in terms of 1.e44
;    10-nov-98, RAS  -- Allow mewe_xxxxx.genx to be found in DIR_GEN_SPECTRA, too.
;    01-DEC-98, PGS  -- Added '.genx' to 'mewe_xxxxx' in two calls to loc_file 
;    04-Jul-99, LWA  -- Mod to handle case of a single wavelength per bin
;			when working in photons.
;-

if keyword_set(cosmic) then begin
        mewe_file = loc_file(path = ['DIR_SXT_SENSITIVE','DIR_GEN_SPECTRA'],$
	'mewe_cosmic.genx')
endif else begin
        mewe_file = loc_file(path = ['DIR_SXT_SENSITIVE','DIR_GEN_SPECTRA'],$ 
	'mewe_solar.genx')
        cosmic = 0
endelse

if n_elements(file_in) ne 0 then begin
	mewe_file = file_in
	cosmic = 8
endif

; With no calling arguments, display the calling sequence:

if n_params() eq 0 then begin
  doc_library,'linflx'
  return
endif

if keyword_set(photon) and keyword_set(erg) then begin
  print,' **** Error in linflx ****',string(7b),string(7b)
  print,'      You cannot specify both /photon and /erg'
  return
endif else if keyword_set(erg) then Units=1 else Units=0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Keep the Mewe data in a common block
; mewe_nval = Vector containing number of non-zero alpha's
; mewe_start= Vector containing index of first non-zero alpha

common mewe_com,mewe_data,mewe_elem,mewe_abun,mewe_nval,mewe_start,mewe_abun_cal,mewe_file_prev
if n_elements(mewe_data) eq 0 then read_file = 1 else $
   if mewe_file_prev ne mewe_file then read_file = 1 else read_file = 0

if read_file then begin
  print,'Reading the Mewe data file = ',mewe_file
  restgen,file=mewe_file,mewe_data,abunstr,text=text
  mewe_data = mewe_data(where(mewe_data.wv gt 0.))	; Eliminate null cases
  mewe_nval = intarr(n_elements(mewe_data))
  mewe_start= intarr(n_elements(mewe_data))
; Missing flag in Spex95 file is -99.
  if min(mewe_data.intens) le -90. then qnew = 1 else qnew = 0
  TMK = 4.+indgen(51)*.1			; Part of the temporary Fix
  nmiss = 0					; Part of the temporary Fix
  for i=0,n_elements(mewe_data)-1 do begin		; Get # of intens values
;-------begin-temporary-fix-------------------------
; This next section of code takes care of the fact
; that some lines in the SPEX95 version have missing
; temperature values
     if qnew then begin
        k = where(mewe_data(i).intens gt -90.,nn)
        if nn ge 2 then begin
          if max(k(1:*)-k) ne 1 then begin
		print,'Missing Values: ',mewe_data(i).linnum,'  ',mewe_data(i).species,mewe_data(i).tr,mewe_data(i).wv
                j0=round((mewe_data(i).T0-TMK(0))*10)
;print,'-----------------'			;***
;print,mewe_data(i).intens			;***
                mewe_data(i).intens(k(0):k(0)+max(k)) = 	$
			dspline(TMK(j0+k),mewe_data(i).intens(k),TMK(j0:j0+max(k)),interp=0)
;print,'-----------------'			;***
;print,mewe_data(i).intens			;***
;		stop				;***
		nmiss = nmiss + 1
          endif
        endif			; nc ge 2
     endif			; qnew
;-------end-temporary-fix-----------------------
     if qnew then k = where(mewe_data(i).intens gt -90.,nn) $	; SPEX95 files
             else k = where(mewe_data(i).intens ne 0,nn)	; SPEX85 files
     mewe_nval(i) = nn  
     mewe_start(i) = k(0)
  endfor
  if nmiss gt 0 then message,'Number problem T cases = '+strtrim(nmiss,2),/info	; Part of the temporary Fix
  mewe_abun = abunstr.abun
  mewe_elem = abunstr.elem
  mewe_abun_cal = cosmic			; Flag which data base this is
  mewe_file_prev = mewe_file			; Save name of file that was read last
endif
abun = mewe_abun
elem = mewe_elem				; Return elemental abundances
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


if n_elements(wave_range) lt 2 then begin
   nwave = n_elements(mewe_data)
   jj = indgen(nwave) 
endif else jj = where((mewe_data.wv ge min(wave_range)) and 	$
	  	      (mewe_data.wv le max(wave_range)),nwave)

if nwave eq 0 then begin
  wave = 0. &  Flux = 0.		; Return something
  print,' **** Warning in linflx ****',string(7b)
  print,'      No lines in requested wavelength range'
  return
endif

Temp = alog10(Te6*1.e6)
if n_elements(Temp) eq 1 then kk = 0 else kk = sort(Temp)
Ntemp = n_elements(Temp)
Flux  = fltarr(Ntemp,nwave)
Wave  = mewe_data(jj).wv		; Wavelengths
if n_params() ge 4 then begin		; Return line information
  Line = mewe_data(jj).species		; Ion information
  Trans= mewe_data(jj).tr		; Transition information
endif

for i=0,nwave-1 do begin
   j = jj(i)
   if mewe_nval(j) gt 1 then begin
     xx = mewe_data(j).t0 + 0.1 * mewe_start(j) + 0.1 * indgen(mewe_nval(j))  ; Temp Vector
     yy = mewe_data(j).intens(mewe_start(j):mewe_start(j)+mewe_nval(j)-1)
     aa = fltarr(Ntemp)
     k = where((Temp(kk) ge min(xx)) and (Temp(kk) le max(xx)),nk)
     if nk gt 0 then begin
	if mewe_nval(j) gt 2 then aa(kk(k)) = spline(xx,yy,Temp(kk(k))) $
			     else aa(kk(k)) = interpol(yy,xx,Temp(kk(k)))
        Flux(0,i) = aa
     endif
   endif				; mewe_nval(j) gt 1
endfor

;       Calculate Line flux (in erg s-1 or ph s-1)
;            [ Flux = 1.e-23 * 10**(-int_fac)           ! erg cm+3 s-1 ]
;            [ 44. => EM=1.e44 cm-3 ]

k = where(Flux ne 0.,nk)
if nk gt 0 then Flux(k) = 10^(44. - 23. - Flux(k))	; erg cm+3 s-1

if Units eq 0 then begin		; Mod by LWA  4-Jul-99
   if n_elements(wave) eq 1 then begin
      Flux =  Flux / 1.98648e-8 * wave
   endif else begin
      Flux =  Flux / 1.98648e-8 * rebin(transpose(wave),Ntemp,Nwave)
   endelse
endif

; Call picklambda to eliminate duplicate wavelengths
; picklambda wants a 2-d array - First subscript=Temp, 2nd=wavelength

if n_params() le 3 then 		$
  picklambda,wave,flux,wave,flux	; Eliminate duplicate wavelengths

if keyword_set(qstop) then stop
return
end
