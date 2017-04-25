function get_ionbal,ZZ,TE6,Stages,				$
		Nel=Nel,ioncal=ioncal,				$	; input
		Element=Element,stages=stages1,			$	; output
		ion_data=ion_data
;+
;  NAME:
;    get_ionbal
;  PURPOSE:
;    Return interpolated ionization fractions.
;  CALLING SEQUENCE:
;    ion_abun = get_ionbal(Z,Te6)
;    ion_abun = get_ionbal(Z,Te6,stages,ioncal=ioncal)
;    ion_abun = get_ionbal(Z,Te6,Nel=Nel,Elem=Elem,		$
;			   stages=stages1,ion_data=ion_data)
;  INPUTS:
;    Z		= Atomic Number (e.g., 16 for S, 20 for Ca, 26 for Fe)
;    Te6	= Vector of electron temperatures in units of 1.e6 K
;  OPTIONAL INPUTS:
;    Stages	= Vector of ionization stages.  (XVIII = 18, etc.)
;  OPTIONAL INPUT KEYWORDS:
;    Nel	= Number of electrons.  Can be used instead of Stages.
;                 For example, Nel=1 is H-like, Nel=He-like, etc.
;    ioncal	= Ionization calculation to use (default is ioncal=0)
;  OUTPUTS:
;    The functional result is a 2-d array containing the fractional ion 
;    abundances:
;           ion_abun = fltarr(N_elements(Te6),N_elements(Stages))
;  OPTIONAL OUTPUT KEYWORDS:
;    Element	= The element (which is obtained from the last word in Head)
;    Stages	= The ion stages returned
;    Ion_data	= Data structure contain data read from the ascii data
;			file with the routine rd_ionbal
;  METHOD:
;    Reads ascii data files contained in $DIR_GEN_SPECTRA
;    The files have the following names: subal1.dat, cabal1.dat, febal1.dat
;
;  MODIFICATION HISTORY:
;     7-oct-93, J. R. Lemen (LPARL), Written
;-
on_error,2				; Return to caller

; Set up common for BCS ions

common ionbal_comm,ion16,ion20,ion26


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Make Sure ZZ and Te6 are defined
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (n_elements(ZZ) eq 0) or (n_elements(Te6) eq 0) then message,' *** Z or Te6 is not defined'
if n_elements(ioncal) eq 0 then cal = 0 else cal = ioncal

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Determine if we have to read the data
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Zname = 'ion'+string(ZZ,format='(i2)')
i = execute('ncheck = n_elements('+Zname+')')
if ncheck eq 0 then q_read=1 else begin
   i = execute('ncal = '+Zname+'.Cal')  
   if ncal eq cal then q_read=0 else q_read=1
endelse

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The file names are set up for S, Ca, and Fe.  
; (The scheme could be easily extended)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FN = concat_dir('$DIR_GEN_SPECTRA',['subal1.dat','cabal1.dat','febal1.dat'])
jj = replicate(-1,27) & jj([16,20,26]) = [0,1,2]
if jj(ZZ) eq -1 then message,'Requested Element is not available'

if q_read then begin
  ion_data = rd_ionbal(FN(jj(ZZ)),Cal)
  i = execute(Zname+'=ion_data')		; Copy ion_dat to common name
endif else i = execute('ion_data='+Zname)	; Copy common name to ion_data

if n_elements(Nel) ne 0 then stages = ion_data.Z - Nel + 1
return,iionbal(ion_data,Te6,Stages,Elem=Elem,stages=stages1)

end

