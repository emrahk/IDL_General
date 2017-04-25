pro collexc,ato_data,Te6,wave,stage,exrate,dens=dens,qdens=qdens
;+
;  NAME:
;    collexc
;  PURPOSE:
;    Compute effective excitation rate coefficients for a given Temperature
;    in units of cm^3 s-1
;
;  CALLING SEQUENCE:
;     collexc,ato_data,Te6,wave,stage,exrate
;
;     The line intensity is I (ph cm-3 s-1) = Ne * Nz * exrate where
;     Ne (cm-3) and Nz (cm-3) are the electron density and the number density
;     of the responsible stage.
;
;  INPUTS:
;     ato_data	= Structure containing atomic data (returned from rd_atodat)
;     Te6	= Vector of electron temperatures (MK)
;  OPTIONAL INPUT KEYWORD:
;     Dens	= Log10(Ne) where Ne = electron density in cm-3
;		  This keyword only has an effect on S XV calculations
;  OPTIONAL OUTPUT KEYWORD:
;     qdens	= log10(Ne) of returned data
;  OUTPUTS:
;     wave	= Wavelength (in Ang) of lines
;     stage	= Vector describing ion stage as number of electrons (1=H like)
;     exrate	= Effective excitation rate (cm+3 s-1)
;  RESTRICTIONS:
;     The density-dependent ratios x/w, y/w, z/w must be in the ato_data
;     structure if the dens= keyword can have any effect.  
;  HISTORY:
;   10-sep-93, J. R. Lemen (LPARL), Written
;   27-oct-93, JRL, Te6 no longer needs to be monotonic
;   11-mar-94, JRL, Added dens and qdens keywords
;-

; -----------------------------------------------------
;  Check to see if density calculation is requested and
;  if parameter range is satisfied by the atomic data
; -----------------------------------------------------
qdens = 0						; Initialize
if n_elements(dens) ne 0 then begin			; Caller asked for a density
  if n_elements(dens) gt 1 then begin			; DENS must be a scalar
      message,'DENS must be a scalar',/cont & tbeep
      message,'Setting dens = 0',/cont
  endif else if (n_elements(dens) eq 1) and (dens(0) gt 0) then begin
    ii = where(tag_names(ato_data) eq 'XYZ2W',nc)	; Check for density structure
    if (dens(0) gt 0.) and (nc eq 0) then begin		; Requested density - no atomic data
      message,'Atomic data not available for density calculation',/cont
      message,'Setting dens = 0',/cont
      tbeep
    endif else 	$
      if (dens(0) gt 0.) and (nc gt 0) then begin
	if ((dens(0) lt min(ato_data.density)) or (dens(0) gt max(ato_data.density)) or $
	   (max(alog10(Te6*1.e6)) gt max(ato_data.Temp_ne)) or $
	   (min(alog10(Te6*1.e6)) lt min(ato_data.temp_ne))) then begin
      		message,'Requested Temperature or Density is out of range of atomic data',/cont
      		message,'Setting dens 0',/cont
      		tbeep
	 endif else qdens = dens(0)
      endif
    endif					; (n_elements(dens) eq 1) and (dens(0) gt 0) 
endif 

; Make sure the ato_data is defined and that it is a structure:

siz = size(ato_data)
if siz(n_elements(siz)-2) ne 8 then begin
    message,'Invalid data type for ato_data',/cont
    help,ato_data
    delvarx,wave,stage,exrate		; Don't return anything
    return
endif

n_Tem = n_elements(Te6)
Temp  = Te6 * 1.e6			; Temperature in K
N_lin_col = n_elements(ato_data.wave0)
nn = ato_data.radrecomb
if nn(0) eq -1 then N_lin_rad = 0 else $
   N_lin_rad = n_elements(ato_data.radrecomb(0,*))
N_lin = N_lin_col + N_lin_rad

wave   = fltarr(n_lin)
stage  = lonarr(n_lin)
exrate = fltarr(n_Tem,n_lin)		; cm^3 s^-1 (will be transposed at end)

; Set up the wavelengths

wave(0:N_lin_col-1)  = ato_data.wave0
stage(0:N_lin_col-1) = ato_data.Enum
if N_lin_rad gt 0 then begin
   wave(n_lin_col:N_lin-1)  = ato_data.wave0(0:N_lin_rad-1)
   stage(4:N_lin_col-1)     = replicate(ato_data.Enum+1,N_lin_col-4)
   stage(n_lin_col:N_lin-1) = replicate(ato_data.Enum-1,N_lin_rad)
endif

;	*****    DIRECT    *****
Z2F=(ato_data.ZNUM-0.5)^2
C1=8.623E-6/(Z2F*SQRT(Temp)*EXP(1.1842E5*Z2F/Temp))
nlin = 4 < N_lin_col		; Number of direct excitation lines (2 for Hydrogen)
for i=0,nlin-1 do exrate(0,i) = c1 * dspline(ato_data.temp,ato_data.omega(*,i),Te6)

if qdens ne 0 then begin
  message,'Returning values for Dens = '+strtrim(qdens,2),/info
  for i=1,nlin-1 do begin
     xx = interp2d(ato_data.xyz2w(*,*,i-1),ato_data.Temp_ne,ato_data.density,	$
		                         alog10(Te6*1.e6), qdens)
     exrate(0,i) = exrate(*,0) * xx
  endfor
endif

;	*****   RECOMBINATION    *****

xn = 3.947e4*Z2F/Temp
C2 = fltarr(N_Tem)
for i=0,N_Tem-1 do C2(i) = GAMINC(0.,XN(i))*4.076e-7*Z2F*Z2F/(Temp(i)^1.5)
for i=n_lin_col,n_lin-1 do exrate(0,i) = c2 * dspline(ato_data.temp,ato_data.radrecomb(*,i-N_lin_col),Te6)

;       *****   Inner-shell contribution to line z *****

;          xn = 1.5789e5*Z2F/T
;          wave = WVHGB(4,ion)                   ! 4=line Z
;          EERC = 3.584e-5*GAMINC(0.,XN)/(Z2F*exp(XN)*sqrt(T))

;       *****   LITHIUM-LIKE    *****

for i=4,n_lin_col-1 do exrate(0,i) = c1*ato_data.branch(i-4) * 		$
			dspline(ato_data.temp,ato_data.omega(*,i),Te6)

exrate = reform(transpose(exrate))
end

