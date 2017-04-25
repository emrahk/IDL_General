; (25-jan-1993)
	pro picklambda,wvl,lflux,dummy,dumflx
;+
; NAME:  PICKLAMBDA
; PURPOSE:
;     To sum the lines at the same wavelengths
; CATEGORY:
; CALLING SEQUENCE:
;	picklambda, wvl, lflux, dummy, dumflx
; INPUTS:
;	wvl = 1-d array of wavelengths of lines in the original Mewe file
;	lflux = 2-d array of line strengths with temperature (first 
;		subscript) and wavelength (second subscript)
; OPTIONAL INPUTS: none.
; OUTPUTS:
;	dummy = 1-d array of new wavelengths after eliminating the 
;		overlapping ones
;	dumflx = 2-d array of line strengths with temperature and
;		 new wavelength (dummy)
; OPTIONAL OUTPUTS: none.
; COMMON BLOCKS: none.
; SIDE EFFECTS: none.
; RESTRICTIONS: none.
; MODIFICATIONS: written by N.Nitta, April 1991.
;		 J. R. Lemen, 25-jan-93 Renamed to picklambda
;-
;
; Find the dimension of the original line strengths in temperature
	a=lflux(*,0)
;	help,a
;
	nte=n_elements(a)
;
	nw=n_elements(wvl)
	lamda=fltarr(nw) 
	sum_line=fltarr(nte,nw)
;
	lamda(0)=wvl(0)
	sum_line(*,0)=lflux(*,0)
;
	j=0	; the number of wavelengths after overlapping ones removed
	for i=1,nw-1 do begin
		if (wvl(i) ne wvl(i-1)) then begin
			j=j+1
			lamda(j)=wvl(i)
			sum_line(*,j)=lflux(*,i)
		endif else begin
			sum_line(*,j)=sum_line(*,j)+lflux(*,i)
		endelse
	endfor
;
;	help,nw-1,j,wvl(nw-1),lamda(j)
;	print,lflux(*,nw-1),sum_line(*,j)
	dummy=fltarr(j+1)
	dumflx=fltarr(nte,j+1)
	dummy=lamda(0:j)
	dumflx=sum_line(*,0:j)
;
	return
	end
