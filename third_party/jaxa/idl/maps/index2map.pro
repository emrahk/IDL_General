;+
; Project     : SOHO, YOHKOH
;
; Name        : INDEX2MAP
;
; Purpose     : Make an image map from index/data pair
;
; Category    : imaging
;
; Syntax      : index2map,index,data,maparr
;
; Inputs      : index - vector of 'index' structures (per mreadfits/fitshead2struct)
;               data  - 2D or 3D
;
; Outputs     : maparr - 2D or 3D array of corresponding 'map structures'
;
; Keywords    : 
;               sub  - if switch, interactively select subfield
;                      if 4 element vector, assume => [x1,x2,y1,y2] 
;               outsize - new output dimensions
;               positive - set negative points to zero
;
; History     : Written, 14 February 1998, S.L. Freeland (LSAL)
;               Embellished, 22 March 1998, D. Zarro (SAC/GFSC)
;		27-Aug-98  rdb  Use xcen and ycen if tags present
;		Added some temporary fixes - TRACE compliance
;		15-Nov-98, Zarro (SM&A) - added call to GET_FITS_PAR
;		9-Mar-99, Zarro (SM&A) - added RCENTER
;               28-Apr-99, Zarro (SM&A) - removed RCENTER if not in FITS header 
;               (let MAKE_MAP handle it internally)
;               11-Jan-00, Zarro (SM&A) - added extra checks for image type
;               12-Jan-00, Zarro (SM&A) - added FILTER and SORT
;               4-Mar-00, Zarro (SM&A) - added INHERIT keyword to save
;               INDEX as a property of MAP
;               15-Mar-00, Zarro (SM&A) - added new roll center check
;               23-Mar-00, Zarro (SM&A) - fixed  INHERIT
;               28-Mar-00, Zarro (SM&A) - allowed INDEX to be string header input
;               20-Aug-00, Zarro (EIT/GSFC) - moved ROLL checks from here 
;               to GET_FITS_PAR
;               20-Sep-00, Zarro (EIT/GSFC) - added additional check for
;               string INDEX input
;               13-Sep-01, Zarro (EITI/GSFC) - added /NO_COPY
;               8-Jan-02, Zarro (EITI/GSFC) - default to EARTH_VIEW
;               22-May-03, Zarro (EER/GSFC) - default to image center
;                          for zero roll image
;               22-Mar-04, Zarro (L-3Com/GSFC) - moved all time checks
;                          to GET_FITS_TIME
;               Call FITSHEAD2WCS to support FITS files using PC or CD matrices
;                       21-Apr-2005, William Thompson, GSFC
;                       26-Apr-2005, Add ERRMSG in FITSHEAD2WCS call.
;                       09-May-2005, Fix bug with multiple images
;               14-Sept-2008, Zarro (ADNET)
;                - added get_map_angles to support different
;                  spacecraft views (such as STEREO)
;                - removed nasty execute
;               7-Jan-2009, Zarro (ADNET)
;                - fixed ROLL_CENTER bug
;               19-Feb-2009, Zarro (ADNET) - added /VERBOSE
;               22-April-2009, Zarro (ADNET)
;                - added more robust check for SOHO roll correction
;               20-July-2009, Zarro (ADNET)
;                - added even more robust check for SOHO roll
;                  correction
;               9-June-2010, Zarro (ADNET)
;                - found and fixed yet another bug where the image
;                  center was incorrectly computed when correcting for
;                  SOHO 180 roll
;               26-Jan-2010, Zarro (ADNET)
;                - passed sub field to make_map
;               23-Aug-2013, Zarro (ADNET)
;                - fixed pixel size calculation when resizing image
;               27-May-2014, Zarro (ADNET)
;                - passed ANGLES from GET_FITS_PAR
;               30-Nov-2015, Zarro (ADNET)
;                - removed resetting ROLL_CENTER to image center
;
; Contact     : dzarro@solar.stanford.edu
;-

pro index2map, index, data, maparr, noclobber=noclobber, outsize=outsize,$
                sub=sub, ref_sub=ref_sub,positive=positive,$
               _extra=extra,err=err,filter=filter,sort_map=sort_map,$
               no_copy=no_copy,verbose=verbose,no_roll=no_roll

err=''

if (~is_struct(index) && ~is_string(index)) || ~exist(data) then begin
 pr_syntax,'index2map,index,data,map'
 err='invalid input'
 return
endif

verbose=keyword_set(verbose)
use_sub=n_elements(sub) gt 0 || n_elements(ref_sub) gt 0  ; sub FOV?
if n_elements(ref_sub) eq 0 then ref_sub=0               ; default->1st 

;-- determine main FITS parameters

if ~is_struct(index) then stc=fitshead2struct(index) else stc=index

get_fits_par,stc,xcen,ycen,dx,dy,time=time,err=err,nx=nx,ny=ny,_extra=extra,$
             roll=roll_angle,rcenter=rcenter,id=id,dur=dur,$
             soho=soho,/current,verbose=verbose,angles=angles

if err ne '' then return

;-- check if rebin requested

if exist(outsize) then begin
 msize=float([outsize[0],outsize[n_elements(outsize)-1]])
endif
nimg=n_elements(stc)
if ~exist(soho) then soho=bytarr(nimg)
if have_tag(extra,'soho',/exact) then soho[*]=extra.soho
use_sub=exist(sub)

delvarx,maparr
for i=0,nimg-1 do begin                

 delvarx,in_extra

 if nimg eq 1 && keyword_set(no_copy) then fdata=temporary(data) else $
  fdata=reform(data[*,*,i])
 sz=float(size(fdata))

 nx[i]=sz[1] & ny[i]=sz[2]

;-- only make maps of images with same dimensions as first image

 if (i eq 0) then begin
  nxr=nx[i] & nyr=ny[i]
  do_map=1
 endif else do_map=(nx[i] eq nxr) && (ny[i] eq nyr)

;-- if filter is set, look for matching expression

 do_map=1
 if is_string(filter) then begin
  do_map=0
  ele=str2arr(filter,'=')
  tag=trim(ele[0]) & value=trim(ele[1])
  if tag_exist(stc[i],tag,index=pos) then $
   do_map=strup(stc[i].(pos)) eq strup(value)
 endif

 if do_map then begin
  if (nxr ne nx[i]) || (nyr ne ny[i]) then fdata=temporary(fdata[0:nxr-1,0:nyr-1])

;-- correct for SOHO roll

  roll_correct=~keyword_set(no_roll)
  if soho[i] && roll_correct then begin
   if have_soho_roll(stc[i]) then begin
    if verbose then mprint,'correcting for SOHO 180 degree roll'
    temp=rot_fits_head(stc[i])
    get_fits_cen,temp,txcen,tycen,dx=dx[i],dy=dy[i]
    xcen[i]=txcen & ycen[i]=tycen
    fdata=rotate(temporary(fdata),2)
    roll_angle[i]=0.
   endif 
  endif

  if exist(msize) then begin
   if (nx[i] ne msize[0]) || (ny[i] ne msize[1]) then begin
    fdata=congrid(temporary(fdata),msize[0],msize[1])
    dx[i]=dx[i]*(nx[i]-1.d0)/(msize[0]-1.d0)
    dy[i]=dy[i]*(ny[i]-1.d0)/(msize[1]-1.d0)
   endif
  endif

; ***** sub should be defined outside of this routine *******

  delvarx,dsub
  if use_sub then begin
   if n_elements(sub) ne 4 then begin   ; interactive
    exptv,fdata
    wshow
    sub_data=tvsubimage(fdata,x1,x2,y1,y2)
    dsub=[x1,x2,y1,y2]
   endif else dsub=sub
  endif
  if keyword_set(positive) then fdata=temporary(fdata) > 0

;-- check for projection angles

  if is_struct(angles) then dangles=angles else begin
   err=''
   angles=get_map_angles(id[i],time[i],err=err,/no_roll,verbose=verbose)
   if is_blank(err) then dangles=angles else delvarx,dangles
  endelse

;-- create map

  if n_elements(rcenter) eq 2 then roll_center=rcenter else roll_center=rcenter[i,*]

  mapi=make_map(fdata,xc=xcen[i],yc=ycen[i],dx=dx[i],$
   dy=dy[i],id=id[i],time=time[i],dur=dur[i],roll_angle=roll_angle[i],$
   err=err,roll_center=roll_center,_extra=dangles,sub=dsub,/no_copy,soho=soho[i])

  if is_string(err) then begin
   smess='nx,ny = ('+num2str(nx[i])+','+num2str(ny[i])+')'
   mprint,'skipping image '+num2str[i]+' -> '+smess,/info
   continue
  endif
  maparr=merge_struct(maparr,temporary(mapi),/no_copy)
 endif 
endfor 

;-- sort?

if (keyword_set(sort_map)) && (n_elements(maparr) gt 1) then begin
 sorder=uniq([maparr.time],sort([maparr.time]))
 maparr=temporary(maparr[sorder])
endif
       
return

end


