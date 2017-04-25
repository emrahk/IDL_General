;+
; Project     : SOHO-CDS
;
; Name        : MK_CDS_IMAP
;
; Purpose     : Make an image map from a CDS QL structure
;
; Category    : imaging
;
; Syntax      : map=mk_cds_imap(ql)
;
; Inputs      : QL = CDS quicklook data stucture
;
; Outputs     : MAP = map structure
;
; Keywords    : SUM   = sum intensities over window wavelength
;               WRANGE = wavelength range to sum over
;
; History     : Written 22 October 1996, D. Zarro, ARC/GSFC
;               Modified 1 Sept 1999, Zarro (SM&A/GSFC) 
;                -- added call to gt_solar_xy for more accurate
;                   pointing
;               15-Jan-2016, Zarro (ADNET) - added angles to map
;
; Contact     : dzarro@solar.stanford.edu
;-

  function mk_cds_imap,aa,window,sum=sum,_extra=extra,err=err,wrange=wrange

  err=''
  qlmgr,aa,valid
  if ~valid then begin
   err='Invalid QL structure'
   return,-1
  endif
  dim=gt_dimension(aa)
  if dim.ssolar_x eq 1 then begin
   err='Singular X-dimension. Use MK_CDS_SMAP'
   mprint,err
   return,-1
  endif

  w=gt_wlimits(aa,/wave,/quiet)
  if ~exist(window) then window=gt_cds_window(aa)
  if window[0] lt 0 then begin
   err='Aborted'
   return,-1
  endif

  nw=n_elements(window)
  dur=float(gt_duration(aa,/sec))
  time=gt_start(aa,/vms)
  for i=0,nw-1 do begin

   if (aa.detdesc[window[i]].ixstop[0] lt 0) then begin
    err='Zero data in window'
   endif else begin
    wlim=w[0:1,window[i]]
    mlam=total(wlim)/n_elements(wlim)
    if keyword_set(sum) then begin
     winsize=gt_winsize(aa)
     ndet=winsize(window[i])
     dummy = gt_iimage(aa,window=window[i],offset=0,lambda=lambda_min)
     dummy = gt_iimage(aa,window=window[i],offset=ndet-1,lambda=lambda_max)
     wmin=max(lambda_min)
     wmax=min(lambda_max)
     if n_elements(wrange) eq 2 then begin
      wrange=float(wrange)
      dmax=max(float(wrange))
      dmin=min(float(wrange))
      ok=(dmin le wmax) and (dmin ge wmin) and $
          (dmax le wmax) and (dmax ge wmin)
      if ~ok then begin
       mprint,'warning - specified WRANGE out of data limits'
       print,'-> '+num2str([wmin,wmax])
      endif
      wmin= wmin > dmin < wmax
      wmax= wmin > dmax < wmax
     endif
     h=float(gt_bimage(aa,wmin,wmax,err=err))
    endif else begin
     h=float(gt_mimage(aa,mlam,/quick))
    endelse

    label=cds_wave_label((aa.detdesc.label)(window[i]))

;-- make map

    if err eq '' then begin
     gt_solar_xy,aa,window[i],xp,yp
     xp=average(xp,1)
     yp=average(yp,1)
     xc=get_arr_center(xp,dx=dx)
     yc=get_arr_center(yp,dy=dy)
     angles=pb0r(time,/arcsec,l0=l0,_extra=extra)
     tmap=make_map(temporary(h),xc=xc,yc=yc,dx=dx,dy=dy,_extra=extra,$
       time=time,dur=dur,b0=angles[1],l0=l0,rsun=angles[2],$
       id=trim2(wmin)+' - '+trim2(wmax)+' A')

     map=merge_struct(map,temporary(tmap))
    endif else begin
     err='No map defined for '+label
     mprint,err
    endelse

   endelse
  endfor

  if exist(map) then return,map else begin
   err='No maps defined'
   mprint,err
   return,-1
  endelse

  end
