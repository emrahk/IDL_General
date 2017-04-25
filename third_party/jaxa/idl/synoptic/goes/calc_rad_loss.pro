;+
; Name: calc_rad_loss
;
; Purpose: Calculate radiative loss rate from Chianti version 5.1 for a
;	  plasma at given temperatures and emission measures
;
; Calling arguments:
;	in_emis - emission measure (scalar or array) in 10^49 cm^-3
;   in_tempr - temperature (scalar or array) in K (note: NOT MK)
;
; Output:
;   Scalar or array (same size as emis and temp input) of radiative loss rate
;   in ergs/second.
;
; Method:
;	Radiative loss rate = EM * 1.e49 * 6.e-22 / SQRT(T/1.e5) erg s^-1
;	Cox & Tucker (1969)
;	Interpolate from table of loss rate (erg s^-1) vs. temperature (K)
;	  made from Chianti v. 5.1 using rad_loss.pro
;	Table made using coronal abundances, the default density of 10^10 cm^-3,
;	  and the Mazzotta ionization equilibrium
;
; Written:  Brian Dennis December 2005
; Modifications:
;	9-Jan-2006, Kim.  renamed, added common, and documentation.
;	11-Jan-2006, Kim.  Fix path to txt file
;	15-May-2014, Kim. Use new rad_loss table created with chianti version 7.1 (was 5.1)
;-

FUNCTION calc_rad_loss, in_emis, in_tempr

common chianti71_rad_loss_vs_temp, temperature, loss_rate

if n_elements(temperature) eq 0 then begin

	path = [curdir(),break_path(!path),chklog('SSWDB_GOES')]
	filename = loc_file('chianti7p1_rad_loss.txt', path=path)

	data = rd_tfile(filename,  2, /hskip, head = head)
	data = float(temporary(data))  ; convert text strings to numbers
	temperature = (reform(data(0,*))) ; remove the dimension of 1
	loss_rate = reform(data(1,*))  ; remove the dimension of 1

endif

lrad = in_emis * interpol(loss_rate, temperature, in_tempr)	* 1.e30
lrad = lrad * 1.e19

RETURN, lrad

END