
;+
; Project     : VSO
;
; Name        : SC_ROLL_CORRECT
;
; Purpose     : Correct spacecraft roll to 0 degrees (North up)
;
; Category    : FITS, Utility
;
; Syntax      : IDL> sc_roll_correct,header,data
;
; Inputs      : HEADER = FITS string header or index structure
;               DATA = 2-D image data array
;
; Outputs     : HEADER = header with FITS keywords adjusted for SC_ROLL=0
;               DATA = roll-corrected image data
;
; History     : Written, 14-Feb-2013, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sc_roll_correct,header,data,_ref_extra=extra,verbose=verbose

if is_string(header) then cindex=fitshead2struct(header)
if is_struct(header) then cindex=header

if ~is_struct(cindex) or ~exist(data) then begin
 pr_syntax,'sc_roll_correct,header,data'
 return
endif

if ~have_tag(cindex,'crpix1') or ~have_tag(cindex,'crpix2') then begin
 message,'Missing CRPIX1/CRPIX2 keywords.',/info
 return
end

;-- do easy 0 and 180 degree cases first

if cindex.sc_roll eq 0. then return

if keyword_set(verbose) then message,'Correcting for '+trim(cindex.sc_roll)+' degree roll..',/info

if abs(cindex.sc_roll) eq 180. then begin
 data=rotate(data,2)
 crpix1 = cindex.naxis1-1.-cindex.crpix1
 crpix2 = cindex.naxis2-1.-cindex.crpix2
 cdelt1 = cindex.cdelt1
 cdelt2 = cindex.cdelt2
 crval1 = 0.
 crval2 = 0.
 xc=comp_fits_cen(crpix1,cdelt1,cindex.naxis1,crval1)
 yc=comp_fits_cen(crpix2,cdelt2,cindex.naxis2,crval2)
endif else begin
 index2map,cindex,data,map,/no_copy,/no_roll
 rmap=rot_map(map,roll=0,/no_copy,_extra=extra)
 data=rmap.data
 cdelt1=rmap.dx
 cdelt2=rmap.dy
 xc=rmap.xc
 yc=rmap.yc
 crval1=0.
 crval2=0.
 crpix1=comp_fits_crpix(xc,cdelt1,cindex.naxis1,crval1)
 crpix2=comp_fits_crpix(yc,cdelt2,cindex.naxis2,crval2)
endelse

;-- make all tags self-consistent

cindex.crpix1=crpix1
cindex.crpix2=crpix2
cindex.crval1=crval1
cindex.crval2=crval2
cindex.cdelt1=cdelt1
cindex.cdelt2=cdelt2
cindex=rep_tag_value(cindex,0.,'sc_roll')
cindex=rep_tag_value(cindex,xc,'xcen')
cindex=rep_tag_value(cindex,yc,'ycen')
cindex=add_fits_hist(cindex,'Rotated to Solar North.')

;-- following are optional

if have_tag(cindex,'crota',/exact) then cindex.crota=0.
if have_tag(cindex,'crota1',/exact) then cindex.crota1=0.
if have_tag(cindex,'crot',/exact) then cindex.crot=0.
if have_tag(cindex,'crotacn1') then cindex.crotacn1=xc
if have_tag(cindex,'crotacn2') then cindex.crotacn2=yc

if is_struct(header) then header=cindex else header=struct2fitshead(cindex)
delvarx,rmap,map,cindex

return & end


