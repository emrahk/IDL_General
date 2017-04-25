pro  drexc,ato_data,Te6,wave,stage,exrate
;+
;  NAME:
;    drexc
;  PURPOSE:
;    Compute effective excitation rate due to dielectronic recombination.
;    as a function of electron temperature in units of cm^3 s-1
;  CALLING SEQUENCE:
;     drexc,ato_data,Te6,wave,stage,exrate
;
;     The line intensity is I (ph cm-3 s-1) = Ne * Nz * exrate where
;     Ne (cm-3) and Nz (cm-3) are the electron density and the number density
;     of the responsible stage.
;
;  INPUTS:
;     ato_data	= Structure containing atomic data (returned from rd_sec3)
;     Te6	= Vector of electron temperatures in 1.e6 K
;  OUTPUTS:
;     wave	= Wavelength (in Ang) of lines
;     stage	= Vector describing ion stage as number of electrons (1=H like)
;     exrate	= Effective excitation rate (cm+3 s-1)
;  HISTORY:
;     3-sep-93, J. R. Lemen (LPARL), Written
;    27-sep-93, JRL, Fixed minor problem which occured when Te6 is a vector
;     5-oct-94, JRL, Fixed the statistical weight of Fe XXIII d.r. lines
;-

; Make sure the ato_data is defined and that it is a structure:

siz = size(ato_data)
if siz(n_elements(siz)-2) ne 8 then begin
    message,' Invalid data type for ato_data',/cont
    help,ato_data
    delvarx,wave,stage,exrate           ; Don't return anything
    return
endif

n_Tem = n_elements(Te6)
Temp  = Te6 * 1.e6			; Temperature in K
n_lin = n_elements(ato_data.dr)		; Number of dielectronic recomb lines

exrate = fltarr(n_Tem,n_lin)		; cm^3 s^-1 (will be transposed at end)

; Set up the wavelengths

wave = ato_data.dr.wave
Stage= replicate(2,n_lin)		; This only works for Ca at the moment


; --- Set up ES for n=2 to 16  (Use Hydrogenic approx for n>2)

Znum = ato_data.Znum			; Atomic number
es1 = fltarr(17)			; in eV
es1(2) = ato_data.es			; Read for data file
for N=3,16 do es1(N) = 12399./ato_data.wave0(0)-13.6*((ZNUM-2.)/N)^2

;*************************
;**** Must fix this later
;        real*4          EIL/2024./      ! ionization limit of Fe XXIV
;        real*4          EH/1166.42/     ! Fe XXIV: avg of 3p 2P J=.5,1.5 levels
EIL = 2024.		; ionization limit of Fe XXIV
EH  = 1166.42		; Fe XXIV: avg of 3p 2P J=.5,1.5 levels
;*************************


; --- Now calculate for all the satellites

for i=0,n_lin-1 do begin
   ES = ES1(ato_data.dr(i).n)
; More exact calculation of Es for iron n=3 levels:
   if (Znum eq 26) and (ato_data.dr(i).n eq 3) then Es=12399./wave(i)+EH-EIL

; Calculate effective excitation rate coefficients:
; GS = Statistical Weight of He-like ground state

   exrate(0,i) = 2.06e-16*TEMP^(-1.5)/ato_data.dr(i).GS*ato_data.dr(i).F2S*exp(-ES/TEMP/8.6171e-5)
; This is correction comes from J. Dubau for Ca:
   if (ato_data.dr(i).n ge 4) and (wave(i) gt 3.17) then exrate(0,i) = exrate(0:*,i)*1.25

endfor

exrate = reform(transpose(exrate))
end
