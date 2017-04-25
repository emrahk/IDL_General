function  acgaunt, wave, te_6, 	$
			G1=gaunt_ff, G2=gaunt_fb, G3=gaunt_2p 
;+
; NAME:		ACGAUNT
; PURPOSE:	Calculate continuum gaunt factor using approximations
;		of R. Mewe (18-JUN-85) to full calculations of 
;		paper VI (Arnaut and Rothenflug for ion balances).
; CATEGORY:
; CALLING SEQUENCE: cgauntf = acgaunt( wave, te_6)
;               cgauntf = acgaunt( wave, te_6, G1=gff, G2=gfb, G3=g2p)
;
; INPUTS:	wave = Wavelength in Angstrom (1-d vector or scalar)
;		te_6 = Temperature in 10^6 K  (1-d vector or scalar)
; OPTIONAL INPUTS: none.
; OUTPUTS: 	Function result
;		 = cgauntf(n_elements(te_6), n_elements(wave)) 
;		 = array of approximate continuum gaunt factors.
; OPTIONAL OUTPUTS:
;		G1 = Free-free  Gaunt factor
;		G2 = Free-bound Gaunt factor
;		G3 = 2-photon   Gaunt factor
;
; COMMON BLOCKS: none
; SIDE EFFECTS:  none
; RESTRICTIONS:  none
; PROCEDURE:	see a paper of R. Mewe et al. (A & Ap)
; MODIFICATIONS: written by N.Nitta from a Fortran version, March 1991.
;	31-jul-93, JRL, Added a check on the exponent to prevent floating underflow message
;       23-Jun-94, DMZ, made Gaunt factors double precision
;
;-
;
;	elements of te_6 and wave
;
		nte_6=n_elements(te_6)
		if(nte_6 le 1) then te_6=te_6*replicate(1.,1)
		nwave=n_elements(wave)
		if(nwave le 1) then wave=wave*replicate(1.,1)
;
;	constituents of gaunt factor as arrays
;
		gaunt_2p=dblarr(nte_6,nwave)
		gaunt_ff=dblarr(nte_6,nwave)
		gaunt_fb=dblarr(nte_6,nwave)
;
;                         
;	Local variables for 2 photon calculation
;
	n_edg = 6	; Number of edges

	lamda = fltarr(n_edg)	; Wavelength of edges
	temp = fltarr(n_edg)	; Max temperature of edges
	CC = fltarr(n_edg)	; Noramlization coefficient
	DD = fltarr(n_edg)	; exponent coefficient

;		       OVIII, OVII, NVII,  NVI ,  CVI,  CV
		lamda=[  19,   22,   25,   29,   34,   41]
		temp= [2.45,  0.9,  1.7,  0.6, 1.05, 0.37]
		CC  = [  3.2, 11.3, 0.69,  2.1,  3.6, 10.3]
		DD  = [ 10.3,  2.5, 10.3,  2.5, 10.3,  2.5]

;
;	Local variables for Free-bound calculation for low temperatures

	n_t_l = 5	; Number of temperature regions
	n_w_l = 4	; Number of wavelength regions

;	integer*4	il,jl		! Column and row number of case table

	al = fltarr(n_t_l,n_w_l)	; al coefficients
	bl = fltarr(n_t_l,n_w_l)	; bl coefficients
	cl = fltarr(n_t_l,n_w_l)	; cl coefficients
	dl = fltarr(n_t_l,n_w_l)	; dl coefficients

	tem_liml = fltarr(n_t_l-1)	; Limits of temperature cases
	wav_liml = fltarr(n_w_l-1)	; Limits of wavelength cases

; Normalization Coefficients
	al(*,0) = [ .248, 5.42e-12, 3.68e-4, 1.86e+3, 6.5e-3]
	al(*,1) = [ .248, 5.42e-12, 3.68e-4,    .176,   .176]
	al(*,2) = [ .248, 5.42e-12,    .323,    .323,   .323]
	al(*,3) = [.0535,    .0535,   .0535,   .0535,  .0535]

; Exponent Coefficients
	bl(*,0) = [-1., -9.39, -4.9, -.686, -5.41]
	bl(*,1) = [-1., -9.39, -4.9,   -1.,   -1.]
	bl(*,2) = [-1., -9.39,  -1.,   -1.,   -1.]
	bl(*,3) = [-1.,   -1.,  -1.,   -1.,   -1.]

; Exponent Coefficients
	cl(*,0) = [.158,	0.0,	0.0,	0.0,	0.0]
	cl(*,1) = [.158,	0.0,	0.0,	.233,	.233]
	cl(*,2) = [.158,	0.0,	.16,	.16,	.16]
	cl(*,3) = [.046,	.046,	.046,	.046,	.046]

; Exponent Coefficients
	dl(*,0) = [-1.,	0.0,	0.0,	0.0,	0.0]
	dl(*,1) = [-1.,	0.0,	0.0,	-1.,	-1.]
	dl(*,2) = [-1.,	0.0,	-1.,	-1.,	-1.]
	dl(*,3) = [-1.,	-1.,	-1.,	-1.,	-1.]

	tem_liml=[.015, .018, .035, .07]	; Boundaries btwn temp. bins
	wav_liml=[227.9, 504.3, 911.9]		; Boundaries btwn wave  bins

;#####################################################################
;
;	Local variables for Free-bound calculation for high temperatures

	n_t = 10	; Number of Temperature regions
	n_w = 16	; Number of wavelength regions


	a = fltarr(n_t,n_w)	; a coefficients
	b = fltarr(n_t,n_w)	; b coefficients
	c = fltarr(n_t,n_w)	; c coefficients
	d = fltarr(n_t,n_w)	; d coefficients

	tem_lim = fltarr(n_t-1)	; Limits of temperature cases
	wav_lim = fltarr(n_w-1)	; Limits of wavelength cases

; Normalization Coefficients
		dumarr=fltarr(10)
	a(*, 0) = [0.68, 3.73, 5.33, 14.0, 49.0, 49.0, 49.0, 4.2, 4.2,  4.2]
	a(*, 1) = [0.68, 3.73, 5.33, 14.0, 49.0, 49.0, 49.0, 4.2, 4.2, 18.4]
	a(*, 2) = [0.68, 3.73, 5.33, 14.0, 49.0, 49.0, 49.0,5.08,5.08, 18.4]
	a(*, 3) = [0.68, 3.73, 5.33, 14.0, 49.0, 49.0, 49.0,3.75,3.75,3.75]
	a(*, 4) = [0.68, 3.73, 5.33, 14.0, 49.0, 22.4, 22.4,2.12,2.12,2.12]
	a(*, 5) = [0.68, 3.73, 5.33, 14.0, 49.0, 22.4, 46.3, 46.3,6.12,6.12]
	a(*, 6) = [0.68, 3.73, 5.33, 14.0, 12.3, 12.3, 12.3, 12.3,6.12,6.12]
	a(*, 7) = [0.68, 3.73, 5.33, 14.0, 12.3, 12.3, 10.2, 10.2,4.98,4.98]
	a(*, 8) = [0.68, 3.73, 5.33, 10.2, 10.2, 10.2, 10.2, 10.2,4.98,4.98]
	a(*, 9) = [0.68, 3.73, 5.33, 10.2, 3.9,  3.9,  2.04, 2.04, 1.1,1.1]
	a(*,10) = [0.68, 3.73,.653,  1.04, 1.04, 1.04, 1.04, 1.04,1.04,1.04]
	a(*,11) = [0.68, 3.73,.653, .653,  .653, .653, 1.04, 1.04,1.04,1.04]
	a(*,12) = [0.68,3.73, .653, .653,  .653, .653, .653, .653,.653,.653]
	a(*,13) = dumarr + 0.6
	a(*,14) = dumarr + .37
	a(*,15) = dumarr + .053

; Exponent Coefficients
	b(*, 0) = [-1.,-1.,-1.595,-.543,-1.572,-1.572,-1.572,-.82,-.82,-.82]
	b(*, 1) = [-1.,-1.,-1.595,-.543,-1.572,-1.572,-1.572,-.82,-.82,-1.33] 
	b(*, 2) = [-1.,-1.,-1.595,-.543,-1.572,-1.572,-1.572, -1., -1.,-1.33]
	b(*, 3) = [-1.,-1.,-1.595,-.543,-1.572,-1.572,-1.572, -1., -1., -1.]
	b(*, 4) = [-1.,-1.,-1.595,-.543,-1.572, -1.2, -1.2, -1., -1., -1.]
	b(*, 5) = [-1.,-1.,-1.595,-.543,-1.572,-1.2,-3.06,-3.06,-1.556,-1.556]
	b(*, 6) = [-1.,-1.,-1.595,-.543,-2.09,-2.09,-2.09,-2.09,-1.556,-1.556]
	b(*, 7) = [-1.,-1.,-1.595,-.543,-2.09,-2.09,-2.19,-2.19,-1.556,-1.556]
	b(*, 8) = [-1.,-1.,-1.595,-2.19,-2.19,-2.19,-2.19,-2.19,-1.556,-1.556]
	b(*, 9) = [-1.,-1.,-1.595,-2.19,-2.763,-2.763,-1.31,-1.31,-1.,-1.]
	b(*,10) = dumarr -1.   
	b(*,11) = dumarr -1.   
	b(*,12) = dumarr -1.   
	b(*,13) = dumarr -1.   
	b(*,14) = dumarr -1.   
	b(*,15) = dumarr -1.   

; Exponent Coefficients
	c(*, 0) = [0.55,0.21,0.0,  0.0,-.826,-.826,-.826,   4.,4.,4.]
	c(*, 1) = [0.55,0.21,0.0,  0.0,-.826,-.826,-.826,   4.,4.,0.0]
	c(*, 2) = [0.55,0.21,0.0,  0.0,-.826,-.826,-.826,  3.9,3.9,0.0]
	c(*, 3) = [0.55,0.21,0.0,  0.0,-.826,-.826,-.826,  4.2,4.2,4.2]
	c(*, 4) = [0.55,0.21,0.0,  0.0,-.826,  0.0,  0.0,  5.6,5.6,5.6]
	c(*, 5) = [0.55,0.21,0.0,  0.0,-.826,  0.0,  0.0,  0.0,0.0,0.0]
	c(*, 6) = [0.55,0.21,0.0,  0.0,-.208,-.208,-.208,-.208,0.0,0.0]
	c(*, 7) = [0.55,0.21,0.0,  0.0,-.208,-.208,-.208,-.208,0.0,0.0]
	c(*, 8) = [0.55,0.21,0.0,-.208,-.208,-.208,-.208,-.208,0.0,0.0]
	c(*, 9) = [0.55,0.21,0.0,-.208,  0.0,  0.0,  0.0,  0.0,0.58,0.58]
	c(*,10) = [0.55,0.21,0.72,0.58, 0.58, 0.58, 0.58, 0.58,0.58,0.58]
	c(*,11) = [0.55,0.21,0.72,0.72, 0.72, 0.72, 0.58, 0.58,0.58,0.58]
	c(*,12) = [0.55,0.21,0.72,0.72, 0.72, 0.72, 0.72, 0.72,0.72,0.72]
	c(*,13) = dumarr + .55
	c(*,14) = dumarr + .158
	c(*,15) = dumarr + .05

; Exponent Coefficients
	d(*, 0) = [-1.,-1.,0.0,0.0,-1.,-1.,-1.,-1.,-1.,-1.]
	d(*, 1) = [-1.,-1.,0.0,0.0,-1.,-1.,-1.,-1.,-1.,0.0]
	d(*, 2) = [-1.,-1.,0.0,0.0,-1.,-1.,-1.,-1.,-1.,0.0]
	d(*, 3) = [-1.,-1.,0.0,0.0,-1.,-1.,-1.,-1.,-1.,-1.]
	d(*, 4) = [-1.,-1.,0.0,0.0,-1.,0.0,0.0,-1.,-1.,-1.]
	d(*, 5) = [-1.,-1.,0.0,0.0,-1.,0.0,0.0,0.0,0.0,0.0]
	d(*, 6) = [-1.,-1.,0.0,0.0,-2.,-2.,-2.,-2.,0.0,0.0]
	d(*, 7) = [-1.,-1.,0.0,0.0,-2.,-2.,-2.,-2.,0.0,0.0]
	d(*, 8) = [-1.,-1.,0.0,-2.,-2.,-2.,-2.,-2.,0.0,0.0]
	d(*, 9) = [-1.,-1.,0.0,-2.,0.0,0.0,0.0,0.0,-1.,-1.]
	d(*,10) = dumarr - 1.
	d(*,11) = dumarr - 1.
	d(*,12) = dumarr - 1.
	d(*,13) = dumarr - 1.
	d(*,14) = dumarr - 1.
	d(*,15) = dumarr - 1.

; Boundaries between temperature bins
	tem_lim = [.2,.258,.4,.585,1.,1.5,3.,4.5,8.] 
; Boundaries between wavelength bins
	wav_lim = [1.4,4.6,6.1,9.1,14.2,16.8,18.6,22.5,25.3,31.6,  $
	51.9,57.0,89.8,227.9,911.9]
;
;
;
;#####################################################################
;	Calculate Free-Free Gaunt factor		: gaunt_ff
;	(good for 1.e4 < te_6*1.e6 < 1.e9 K; 1 < wave < 1000 Ang)
;#####################################################################
;
	low = where (te_6 le 1.,lcount)		; low temperature
	high = where (te_6 gt 1.,hcount)	; high temperature
;
	if(lcount gt 0) then begin
	dummy=mkdarr(wave,te_6(low))
	te_dummy=dummy(1,*)
	wave_dummy=1. > dummy(0,*) < 1000.
	gaunt_ff(low,0:nwave-1)=0.29*wave_dummy^(0.48*(wave_dummy^(-0.08)))$
		   		* te_dummy^(0.133*alog10(wave_dummy)-0.2)  
        
	endif
;
	if(hcount gt 0) then begin	
	dummy=mkdarr(wave,te_6(high))
	te_dummy=dummy(1,*)
	wave_dummy=dummy(0,*)
	gaunt_ff(high,0:nwave-1)=1.01*wave_dummy^(0.355*(wave_dummy^(-0.06)))$
	 		* (te_dummy/100.)^(0.3*(wave_dummy^(-0.066)))   
	endif
;
;#####################################################################
;	Calculate 2-photon Gaunt factor
;#####################################################################
;
	negl_2p = where((wave le 19.) or (wave gt 200.),ncount)
	finit_2p = where((wave gt 19.) and (wave le 200.),fcount)
;
;	gaunt_2p(0:nte_6-1,negl_2p) = 0. 
;	gaunt_2p(0:nte_6-1,finit_2p) = 0.		; 19 < wave <= 200
;
	if(fcount gt 0) then begin 	
	dum_2p=mkdarr(wave(finit_2p),te_6)
	te_2p=dum_2p(1,*)
	wv_2p=dum_2p(0,*)
	for i=0,5 do begin 
		alpha = 106. / (lamda(i)) * (te_2p^(-0.94))
;			print,'i=',i,'  alpha=',alpha
		gaunt_2p(0:nte_6-1,finit_2p)=gaunt_2p(0:nte_6-1,finit_2p) $
			 + (wv_2p gt lamda(i)) * CC(i)	$
			  * ((lamda(i)/wv_2p)^alpha) $
		 * sqrt(abs(cos(!pi*((lamda(i)/wv_2p)-0.5))))$
			 * ((temp(i) / te_2p)^0.45)	$
			 * 10.^((-DD(i)*(alog10(te_2p/temp(i)))^2)>(-37))	; (31-jul-93 JRL)
;				print,'gaunt_2p=',gaunt_2p
	endfor
	endif
;
;#####################################################################
;	Calculate Free-Bound Gaunt factor
;#####################################################################
;
	low0=where(te_6 lt 0.01,lcount0)
	low1=where(((te_6 ge 0.01) and (te_6 lt 0.1)),lcount1)
	high=where(te_6 ge 0.1,hcount)

;	if(lcount0 gt 0) then gaunt_fb(low0,0:nwave-1) = 0.
;
	if(lcount1 gt 0) then begin
;--	Low temperature case  ---   : te_6 < 0.1 M K
	   il = indd( tem_liml,Te_6(low1))	; return il
	   jl = indd( wav_liml,wave )		; return jl
;
;			print,'il,jl -->',il,jl
;
		ijl=mkdarr(jl,il)
;			print,'ijl -->',ijl
		il=ijl(1,*)
		jl=ijl(0,*)
;
		tel=reform(rebin(te_6(low1),n_elements(te_6(low1)),$
			n_elements(wave)),1,	$
			n_elements(te_6(low1))*n_elements(wave))
;
;
;			print,'tel ---> ',tel
;
	gaunt_fb(low1,0:nwave-1) = al(il,jl)*(tel^bl(il,jl))          $
	 			* exp( cl(il,jl)*(tel^dl(il,jl)))
	endif
;
;
	if(hcount gt 0) then begin
;--	High temperature case	---   :   Te_6 >= 0.1 M K
	   i = indd( tem_lim,Te_6(high))	; return i
	   j = indd( wav_lim,wave )		; return j
;
;			print,'i,j -->',i,j
;
		ij=mkdarr(j,i)
;			print,'ij -->',ij
		i=ij(1,*)
		j=ij(0,*)
;
		teh=reform(rebin(te_6(high),n_elements(te_6(high)),$
			n_elements(wave)),1,	$
			n_elements(te_6(high))*n_elements(wave))
;
;			print,'teh ---> ',teh
;
	   gaunt_fb(high,0:nwave-1) = a(i,j)*(teh^b(i,j))      $
	 			* exp( c(i,j)*(teh^d(i,j)))

	endif


	return,  gaunt_ff + gaunt_2p + gaunt_fb
	end
