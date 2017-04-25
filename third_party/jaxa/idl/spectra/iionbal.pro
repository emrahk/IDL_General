function iionbal,bal_data,Te6,Stages,Element=Element,stages=stages1
;+
;  NAME:
;    iionbal
;  PURPOSE:
;    Return interpolated ionization fractions.
;  CALLING SEQUENCE:
;    ion_abun = iionbal(bal_data,Te6)
;    ion_abun = iionbal(bal_data,Te6,Stages,Elem=Elem)
;  INPUTS:
;    bal_data	= Data structure contain data read from the ascii data
;			file with the routine rd_ionbal
;    Te6	= Vector of electron temperatures in units of 1.e6 K
;    Stages	= Vector of ionization stages.  (XVIII = 18, etc.)
;
;  OUTPUTS:
;    The functional result is a 2-d array containing the fractional ion 
;    abundances:
;           ion_abun = fltarr(N_elements(Te6),N_elements(Stages))
;  OPTIONAL OUTPUT KEYWORDS:
;    Element	= The element (which is obtained from the last word in Head)
;    Stages	= The stages returned (in case stages is no defined on input)
;  MODIFICATION HISTORY:
;     4-sep-93, J. R. Lemen (LPARL), Written
;-
on_error,2			; Return to Caller

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Make sure that the input bal_data is a structure:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ss = size(bal_data)
bell = string(7b)
if ss(n_elements(ss)-2) ne 8 then begin
  message,'*** Error: Input balance data must be a structure',/cont
  help,bal_data
  return,-1
endif


Head    = bal_data.Head		; Return comment line from ion. bal. data file
Element = bal_data.Element	; Return the element name (last word of Head)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Make sure that Te6 and Stages are defined:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if n_elements(Te6) eq 0 then message,'Te6 is undefined'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Make sure requested ionization stages are in a valid range
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if n_elements(stages) eq 0 then stages1 = bal_data.stages else stages1 = stages

if (min(stages1) lt min(bal_data.stages)) or 		$
   (max(stages1) gt max(bal_data.stages)) then begin
  message,'  Error in iionbal ***'+bell+bell,/cont
  print,'    Requested ionization stage(s) is out of range'
  print,'    User requested =',stages1
  print,'    File Header = ',bal_data.Head
  print,'    Stages in file =',bal_data.stages
  return,-1
endif


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Set up the return variable - Load the data
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T_Temp = alog10(Te6*1.e6)		; Convert to Log10(Temp)
Num_T = N_elements(T_temp)		; Number of Temperatures
Num_S = N_elements(Stages1)		; Number of Stages

abun = fltarr(Num_T,Num_S)			; Output variable
if Num_T gt 1 then xx = sort(Te6) else xx = 0	; In case input temperatures do
						;- not monotonically increase

for j=0,Num_S-1 do begin
   jj = (where(bal_data.stages eq Stages1(j)))(0)	; Get the Stage
   nn = bal_data.N_Temp(jj)-1	; Number of valid Temperatures for this stage
   yy = T_Temp			; Just to initialize the variable
   yy(xx) = spline(bal_data.L_Temp(0:nn,jj),bal_data.L_abun(0:nn,jj),T_Temp(xx))
   abun(0,j) = 10.^yy		; Return the actual frac. ion. abun.
; Zero out the cases where the requested temperature range is out of bounds.
   ii = where((T_temp lt min(bal_data.L_Temp(0:nn,jj))) or 	$
 	      (T_temp gt max(bal_data.L_Temp(0:nn,jj))),npts)
   if npts gt 0 then abun(ii,j) = 0.		; Zero out
endfor

return,abun
end
