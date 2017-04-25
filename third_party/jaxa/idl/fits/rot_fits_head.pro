;+
; Project     : HESSI
;
; Name        : ROT_FITS_HEAD
;
; Purpose     : Rotate FITS header information
;
; Category    : FITS, Utility
;
; Syntax      : IDL> header=rot_fits_head(header)
;
; Inputs      : HEADER = FITS header (string or index structure format)
;
; Outputs     : HEADER with roll adjusted CRPIX, CROTA, CEN values
;
; History     : Written, 3-Feb-2004, Zarro (L-3Com/GSFC)
;               Modified, 13-Apr-2005, Zarro (L-3Com/GSFC) 
;                - fixed long to float conversion
;               Modified, 14-Jun-2010, Zarro (ADNET)
;                - added check for CRVAL
;               Modifed, 22-July-2013, Zarro (ADNET)
;                - added check for CRPIX
;               Modified, 15-August-2014, Zarro (ADNET)
;                - added check for CROTA2
;               Modified, 22 Oct 2014, Zarro (ADNET)
;               - converted to double-precision arithmetic
;
; Contact     : dzarro@solar.stanford.edu
;-

function rot_fits_head,header

if ~exist(header) then return,''

rheader=header

;-- handle structure header input

if is_struct(rheader) then begin
 if have_tag(rheader,'sc_roll') then rheader.sc_roll=0.
 if have_tag(rheader,'crota',/exact) then rheader.crota=0.
 if have_tag(rheader,'crota1',/exact) then rheader.crota1=0.
 if have_tag(rheader,'crota2',/exact) then rheader.crota2=0.
 if have_tag(rheader,'crot',/exact) then rheader.crot=0.
 if ~have_tag(header,'crpix1') or ~have_tag(header,'crpix2') then return,header
 crpix1 = header.naxis1-1.-header.crpix1
 crpix2 = header.naxis2-1.-header.crpix2
 rheader.crpix1=crpix1
 rheader.crpix2=crpix2
 if have_tag(header,'crval1') then crval1=header.crval1 else crval1=0.
 if have_tag(header,'crval2') then crval2=header.crval2 else crval2=0.
 xc=comp_fits_cen(crpix1,header.cdelt1,header.naxis1,crval1)
 yc=comp_fits_cen(crpix2,header.cdelt2,header.naxis2,crval2)
 if have_tag(rheader,'xcen') then rheader.xcen=xc
 if have_tag(rheader,'ycen') then rheader.ycen=yc
 if have_tag(rheader,'crotacn1') then rheader.crotacn1=xc
 if have_tag(rheader,'crotacn2') then rheader.crotacn2=yc
endif

;-- handle string header input

if is_string(rheader) then begin
 rep_fits_head,rheader,'SC_ROLL','0.0'
 rep_fits_head,rheader,'CROT','0.0'
 rep_fits_head,rheader,'CROTA','0.0'
 rep_fits_head,rheader,'CROTA1','0.0'
 rep_fits_head,rheader,'CROTA2','0.0'
 chk1=where(stregex(rheader,'crpix1',/bool,/fold),count1)
 chk2=where(stregex(rheader,'crpix2',/bool,/fold),count2)
 if (count1 eq 0) or (count2 eq 0) then return,header
 naxis1=fxpar(rheader, 'naxis1')
 naxis2=fxpar(rheader, 'naxis2')
 crpix1=fxpar(rheader,'crpix1')
 crpix2=fxpar(rheader,'crpix2')
 cdelt1=fxpar(rheader,'cdelt1')
 cdelt2=fxpar(rheader,'cdelt2')
 crval1=fxpar(rheader,'crval1')
 crval2=fxpar(rheader,'crval2')
 if is_blank(crval1) then crval1=0.
 if is_blank(crval2) then crval2=0.
 crpix1 = double(naxis1)-1.d0-double(crpix1)
 crpix2 = double(naxis2)-1.d0-double(crpix2)
 xcen=comp_fits_cen(crpix1,cdelt1,naxis1,crval1)
 ycen=comp_fits_cen(crpix2,cdelt2,naxis2,crval2)
 rep_fits_head,rheader,'XCEN',trim(xcen,'(f10.2)')
 rep_fits_head,rheader,'YCEN',trim(ycen,'(f10.2)')
 rep_fits_head,rheader,'CRPIX1',trim(crpix1,'(f10.2)')
 rep_fits_head,rheader,'CRPIX2',trim(crpix2,'(f10.2)')
endif

return, rheader
end


