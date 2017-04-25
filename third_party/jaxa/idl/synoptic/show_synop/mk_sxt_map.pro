;+
;
; Name        : MK_SXT_MAP
;
; Purpose     : Make an image map from an SXT index/data structure
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : map=mk_sxt_map(index,data)
;
; Examples    :
;
; Inputs      : INDEX,DATA = index/data combination
;
; Opt. Inputs : None
;
; Outputs     : MAP = map structure
;
; Opt. Outputs: None
;
; Keywords    : DIMENSIONS = [nx,ny] image dimensions to select
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 January 1997, D. Zarro, ARC/GSFC
;               Dec 5, 2001, T. Metcalf rewriten to get the roll correction
;                                       correct.
;               Dec 7, 2001: TRM Fixed a small problem when an index array
;                                is passed and prevented multiple warnings
;                                about using the predicted roll angle.
;
;-

function mk_sxt_map,index,data,use_hist=use_hist,$
                    tstart=tstart,tstop=tstop,_extra=extra, $
                    dimensions=dimensions

if datatype(index) ne 'STC' then begin
 message,'enter an SXT index structure',/cont
 return,0
endif

;--  scaling info

xc=gt_center(index,/ang,/x,use_hist=use_hist)
yc=gt_center(index,/ang,/y,use_hist=use_hist)
dx=gt_pix_size(index)
dy=dx

;-- dimensions to filter

nd=n_elements(dimensions)
if nd gt 0 then begin
 sx=dimensions(0)
 sy=dimensions( 1 < (nd-1) )
endif

np=n_elements(index)
times=gt_day(index,/str)+' '+gt_time(index,/str,/msec)
if not exist(tstart) then tstart=anytim2tai(times(0)) $
else tstart=anytim2tai(tstart)
if not exist(tstop) then tstop=anytim2tai(times(np-1)) $
else tstop=anytim2tai(tstop)

pwarned = 0

if datatype(data) eq 'BYT' then zero=0b else zero=0
   for i=0,n_elements(index)-1 do begin
      err=''
      time=anytim2tai(times[i])
      if (time ge tstart) and (time le tstop) then begin

      nx=gt_shape(index[i],/x)
      ny=gt_shape(index[i],/y)
      if not exist(sx) then sx=nx
      if not exist(sy) then sy=ny

      ; Check if sxt_prep was called with roll correction
      roll_corrected = 0b
      if tag_exist(index,'his') then begin
         if index[i].his.q_roll_corr NE 0 then roll_corrected = 1b
      endif

      if NOT roll_corrected then begin
         roll = get_roll(index[i],status=status)
         if NOT status[0] AND NOT pwarned then begin
            message,/info,'Warning: Using predicted roll angle'
            pwarned = 1  ; Only warn once.
         endif
         roll_center = [xc[i],yc[i]]
         xcen = xc[i]
         ycen = yc[i]
      endif else begin
         roll = 0.0
         roll_center = [0.,0.]
         xcen = xc[i]
         ycen = yc[i]
         ; We have to modify the coordinates due to a bug in sxt_prep.
         ; If sxt_prep is ever fixed this rotation should be removed.
         ;phi =  get_roll(index[i],status=status)*!dtor
         ;if NOT status[0] then begin
         ;   message,/info,'Warning: Using predicted roll angle'
         ;   pwarned = 1
         ;endif
         ;xcen =  xc*cos(phi)+yc*sin(phi)
         ;ycen = -xc*sin(phi)+yc*cos(phi)
      endelse

      if (nx eq sx) and (ny eq sy) then begin
         map=make_map(data(0:nx-1,0:ny-1,i) > zero, $
                      xc=xcen,yc=ycen, $
                      dx=dx[i],dy=dy[i], $
                      roll_angle = roll, $
                      roll_center = roll_center, $
                      time=times(i), $
                      dur=gt_expdur(index[i])/1000., $
                      id='SXT '+gt_filtb(index[i],/str),$
                      xunits='arcsecs', $
                      yunits='arcsecs', $
                      soho = 0b, log = 0b, $
                      _extra=extra,$
                      err=err)
        endif else err='Skipping image dimensions: '+ $
                       trim(string(nx))+','+trim(string(ny))
        if err ne '' then begin
         message,err,/cont
      endif else img=merge_struct(img,map)
   endif
endfor

if not exist(img) then begin
 message,'No images during specified times',/cont
 img=0
endif

return,img

end
