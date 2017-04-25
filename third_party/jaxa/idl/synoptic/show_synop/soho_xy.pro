;+
; Project     : SOHO-CDS
;
; Name        : SOHO_XY
;
; Purpose     : convert EARTH-view coordinates to SOHO-view
;
; Category    : imaging
;
; Explanation : convert projected (x,y) grid on solar surface from EARTH-view
;               to SOHO-view, and vice-versa
;
; Syntax      : soho_xy,x,y,date,xs,ys
;
; Examples    :
;
; Inputs      : X,Y = input coordinates (arcsec) (+W, +N)
;               DATE = date of observations
;
; Opt. Inputs : None
;
; Outputs     : XS,YS = output coordinates (arcsec)
;
; Opt. Outputs: None
;
; Keywords    : INVERSE = set to convert SOHO to EARTH-view
;               NO_COPY = don't make extra copies of input coordinates
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 15 April 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


pro soho_xy,x,y,date,xs,ys,err=err,inverse=inverse,no_copy=no_copy

on_error,1
err=''
tdate=anytim2utc(date,err=err)

if (err ne '') or (not exist(x)) or (not exist(y)) or $
 data_chk(x,/ndim) ne data_chk(y,/ndim) then begin
 err='input error'
 pr_syntax,'soho_xy,x,y,date,xs,ys'
 return
endif

no_copy=keyword_set(no_copy)
if no_copy then begin
 xs=copy_var(x) & ys=copy_var(y)
endif else begin
 xs=x & ys=y
endelse

;-- check if input is 2-d (x and y dimensions need to be the same)

twod=0
if data_chk(xs,/ndim) eq 2 then begin
 twod=1
 nx=data_chk(xs,/nx) & ny=data_chk(ys,/ny)
 xs=reform(temporary(xs),nx*ny)/60. & ys=reform(temporary(ys),nx*ny)/60.
endif else begin
 xs=temporary(xs)/60. & ys=temporary(ys)/60.
endelse

;-- transform to heliographic

inverse=keyword_set(inverse)
solar_helio=arcmin2hel(xs,ys,date=tdate,soho=inverse,/no_copy)

if inverse then dprint,'% SOHO_XY: mapping from SOHO- to Earth-view' else $
 dprint,'% SOHO_XY: mapping from Earth- to SOHO-view'

;-- transform back to cartesian

soho_cart=hel2arcmin(solar_helio(0,*),solar_helio(1,*),date=tdate,soho=1-inverse)

if twod then begin
 xs=reform(soho_cart(0,*),nx,ny)*60.
 ys=reform(soho_cart(1,*),nx,ny)*60.
endif else begin
 xs=reform(soho_cart(0,*)*60.)
 ys=reform(soho_cart(1,*)*60.)
endelse

if n_elements(xs) eq 1 then xs=xs(0)
if n_elements(ys) eq 1 then ys=ys(0)

delvarx,solar_helio,soho_cart

return & end

