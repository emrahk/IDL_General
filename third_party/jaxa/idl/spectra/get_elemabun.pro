function get_elemabun,Num,info=info,verbose=verbose
;+
; NAME:
;   get_elemabun
; PURPOSE:
;   Return elemental abundances.  H = 1, He = (approx) .2, etc.
; CALLING SEQUENCE:
;   abun = get_elemabun()		; Return default
;   abun = get_elemabun(Num,info=info)	; info is an information string
;
; INPUTS:
;   Num		= Number of the abundance values to use.  See data statements
;		  below for the descriptions.
; OPTIONAL INTPUT KEYWORDS:
;   verbose	= Give some information while running
; OPTIONAL OUTPUT KEYWORDS:
;   Info	= Information string
;    7-Oct-93, J. R. Lemen (LPARL), Written
;-
on_error,2				; Return to caller in case on an error

delvarx,info

elem = ['??','H ','HE','LI','BE','B ','C ','N ','O ','F ','NE','NA','MG','AL','SI',	$
	'P ','S ','CL','AR','K ','CA','SC','TI','V ','CR','MN','FE','CO','NI']
if n_elements(Num) eq 0 then num = 0

case Num of
  0: begin
; Yohkoh adopted is = Meyer 1985, except Ca=6.65 and Fe=7.65
       info = 'Yohkoh adopted abund.'
       aaa = [0.,12.00,10.9914,0.,0.,0.,8.37161,7.59346,8.39280,	$	; H,He,C,N,O
	      0.,7.54770,6.43856,7.57118,6.43856,7.59346,0.,6.93588,	$	; Ne,Na,Mg,Al,Si,S
	      0.,6.32585,0.,6.65,     0.,0.,0.,0.,0.,7.65 ,0.,6.33382]		; Ar,Ca,Fe,Ni
     endcase
  1: begin
;  Meyer (1985) Coronal Abundance
       info = 'Meyer (1985) Solar Abun'
       aaa = [0.,12.00,10.9914,0.,0.,0.,8.37161,7.59346,8.39280,	$	; H,He,C,N,O
	      0.,7.54770,6.43856,7.57118,6.43856,7.59346,0.,6.93588,	$	; Ne,Na,Mg,Al,Si,S
	      0.,6.32585,0.,6.46852,0.,0.,0.,0.,0.,7.59346,0.,6.33382]		; Ar,Ca,Fe,Ni
     endcase
  2: begin
;  Anders and Grevesse, Geochim. Cosmochim. Acta 53, 197 (1989)
       info = 'Anders and Grevesse '
       aaa = [0.,12.00,10.99,0.,0.,0.,8.56,8.05,8.93,			$	; H,He,C,N,O
	      0.,8.09,   6.33,   7.58,   6.47,   7.55,   0.,7.21,	$	; Ne,Na,Mg,Al,Si,S
	      0.,6.56,   0.,6.36,   0.,0.,0.,0.,0.,7.67,   0.,6.25]		; Ar,Ca,Fe,Ni
     endcase
else: message,'Invalid Abundance Number (must be between 0 and 2)'
endcase
ii = where(aaa gt 0.) & aaa(ii) = 10.^(aaa(ii)-12)

abun = make_str('{dummy,'			+ 	$
		 'elem:' + fmt_tag(size(elem)) 	+ 	$
		 ',abun:' + fmt_tag(size(aaa))	+	$
		 ',info:""}')

abun.abun = aaa
abun.elem = elem
abun.info = info

if keyword_set(verbose) then message,'Elemental Abundances: '+info,/cont

return,abun
end
