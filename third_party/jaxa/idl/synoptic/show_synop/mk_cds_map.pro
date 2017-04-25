;+
; Project     : SOHO-CDS
;
; Name        : MK_CDS_MAP
;
; Purpose     : Make an image map from a CDS QL structure
;
; Category    : imaging
;
; Syntax      : map=mk_cds_map(ql,window)
;
; Inputs      : QL = CDS quicklook data stucture or CDS FITS file
;               WINDOW = window number
;
; Outputs     : MAP = map structure
;
; Keywords    : CLEAN = clean Cosmic ray hits
;               PEAK   = use peak intensity
;               NO_CALIB = do not calibrate data
;               WRANGE = wavelength range over which to sum spectra
;
; History     : Written 22 October 1996, D. Zarro, ARC/GSFC
;               Modified 1 September 1999, Zarro (SM&A/GSFC) 
;                -- removed UPD_CDS_POINT call (done in READCDSFITS)
;                -- added rotate keyword
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_cds_map,ql,window,clean=clean,sum=sum,$
 no_calib=no_calib,rotate=rotate,fdata=fdata,peak=peak,wrange=wrange

if datatype(ql) eq 'STR' then begin
 fdata=readcdsfits(ql)
 if datatype(fdata) ne 'STC' then return,0
endif else begin
 if datatype(ql) eq 'STC' then fdata=ql else begin
  message,'enter a CDS QL structure',/cont &  return,0
 endelse
endelse

for i=0,n_elements(fdata)-1 do begin
 if not exist(window) then window=gt_cds_window(fdata(i))
 if window(0) lt 0 then return,-1

 aa=copy_qlds(fdata(i))

;-- clean

 if keyword_set(clean) then cds_clean_exp,aa

;-- calibrate

 if (1-keyword_set(no_calib)) then begin
  err=''
  vds_calib,aa,err=err
  if err ne '' then message,err,/cont
 endif

 if (keyword_set(rotate)) then begin
  err=''
  nis_rotate,aa,err=err
  if err ne '' then message,err,/cont
 endif

;-- produce image

 sum=keyword_set(sum) or (1-keyword_set(peak))
 dim=gt_dimension(aa)
 roll=get_tag_value(aa,/sc_roll,err=err)
 if err then roll=0.
 rollx=get_tag_value(aa,/sc_x0,err=err)
 if err then rolly=0.
 rolly=get_tag_value(aa,/sc_y0,err=err)
 if err then rolly=0.
 rcenter=[rollx,rolly]
 extra={soho:1b,roll_angle:double(roll),roll_center:double(rcenter)}
 if dim.ssolar_x eq 1 then tmap=mk_cds_smap(aa,window,_extra=extra) else $
  tmap=mk_cds_imap(aa,window,sum=sum,wrange=wrange,_extra=extra)
 if valid_map(tmap) then map=merge_struct(map,temporary(tmap))
endfor

if valid_ql(aa) then delete_qlds,aa
if exist(map) then return,map else begin
 err='No maps defined'
 message,err,/cont
 return,-1
endelse

end
