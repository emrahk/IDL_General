;+
; Project     : SOHO-CDS
;
; Name        : MK_CDS_SMAP
;
; Purpose     : Make an image map from a CDS QL structure in which
;               slit spectrogram mode is used
;
; Category    : imaging
;
; Syntax      : map=mk_cds_smap(aa)
;
; Inputs      : aa = CDS quicklook data stucture
;               window = window number
;
; Outputs     : MAP = map structure
;
; History     : Written 22 June 1997, D. Zarro, ARC/GSFC
;               Modified 1 Sept 1999, Zarro (SM&A/GSFC) 
;                -- added call to gt_solar_xy for more accurate pointing
;               15-Jan-2016, Zarro (ADNET) - added angles to map
;
; Contact     : dzarro@solar.stanford.edu
;-

  function mk_cds_smap,aa,window,_extra=extra,err=err

  err=''
  qlmgr,aa,valid
  if not valid then begin
   err='Invalid QL structure'
   return,-1
  endif
  dim=gt_dimension(aa)
  if dim.ssolar_x gt 1 then begin
   err='Non-singular X-dimension. Use MK_CDS_IMAP'
   mprint,err
   return,-1
  endif

  if ~exist(window) then window=gt_cds_window(aa)
  if window[0] lt 0 then begin
   err='Aborted'
   return,-1
  endif

  map=-1
  nw=n_elements(window)
  time=gt_start(aa,/vms)
  dur=float(gt_duration(aa,/sec))
  for i=0,nw-1 do begin
   temp=gt_windata(aa,window[i],err=err) > 0.
   if err eq '' then begin

;-- get images, pointing, & times

    temp=reform(temporary(temp))
    gt_solar_xy,aa,window[i],xp,yp
    xp=average(xp,1)
    yp=average(yp,1)

;-- make map

    xc=get_arr_center(xp,dx=dx)
    yc=get_arr_center(yp,dy=dy)
    angles=pb0r(time,/arcsec,l0=l0,_extra=extra)
    tmap=make_map(temporary(temp),xc=xc,yc=yc,dx=dx,dy=dy,_extra=extra,$
       time=time,dur=dur,b0=angles[1],l0=l0,rsun=angles[2],$
       id=cds_wave_label((aa.detdesc.label)(window[i])))
    map=merge_struct(map,temporary(tmap))
   endif
  endfor

  return,map

  end
