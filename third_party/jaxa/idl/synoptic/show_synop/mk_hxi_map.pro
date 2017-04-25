;+
; Project     : YOHKOH-HXT
;
; Name        : MK_HXI_MAP
;
; Purpose     : Make an image map from an HXI index/data structure
;
; Category    : imaging
;
; Syntax      : map=mk_hxi_map(index,data)
;
; Inputs      : INDEX,DATA = index/data combination
;
; Outputs     : MAP = map structure
;
; Keywords    : DIMENSIONS = [nx,ny] image dimensions to select
;
; History     : Written 22 January 1997, D. Zarro, ARC/GSFC
;             : Rewritten to use HXI images, jmm, 3-aug-1998
;             : Offset double roll corrections, NVN, 17-Nov-2001
;             : Modified 3-Dec-01, Zarro (EITI/GSFC) - implemented 
;             ; suggestion by T. Metcalf
;-

FUNCTION Mk_hxi_map, index, data, use_hist=use_hist, $
                     tstart=tstart, tstop=tstop, _extra=extra, $
                     dimensions=dimensions

   IF datatype(index) NE 'STC' THEN BEGIN
      message, 'enter an HXI index structure', /cont
      RETURN, 0
   ENDIF

;--  scaling info

   nexp = N_ELEMENTS(index)
   midtim=strarr(nexp)
   for i=0,nexp-1 do midtim(i)=fmt_tim(addtime(index(i),delta=index(i).hxi.actim/20./60.))
   phi=get_roll(midtim)*!pi/180.
   hh = fltarr(2, nexp)
   hh(0, *) = index.hxi.x0
   hh(1, *) = index.hxi.y0
   xcyc = conv_hxt2a(hh, index)
   xc = reform(xcyc(0, *))      ;center position in arcseconds
   yc = reform(xcyc(1, *))

; reset roll correction included in conv_hxt2a
;   xc= xc*cos(phi)+yc*sin(phi)
;   yc=-xc*sin(phi)+yc*cos(phi)

   dx = index.hxi.resolution/1000.0 ;pixel size in arcsec
   dy = dx

;-- dimensions to filter

   nd = N_ELEMENTS(dimensions)
   IF nd GT 0 THEN BEGIN
      sx = dimensions(0)
      sy = dimensions( 1 < (nd-1) )
   ENDIF

   np = N_ELEMENTS(index)
   times = gt_day(index, /str)+' '+gt_time(index, /str)
   
   IF NOT exist(tstart) THEN tstart = anytim2tai(times(0)) $
     ELSE tstart = anytim2tai(tstart)
   IF NOT exist(tstop) THEN tstop = anytim2tai(times(np-1)) $
     ELSE tstop = anytim2tai(tstop)

   IF datatype(data) EQ 'BYT' THEN zero = 0b ELSE zero = 0
   ch_string = ['LO', 'M1', 'M2', 'HI']
   FOR i = 0, nexp-1 DO BEGIN
      err = ''
      time = anytim2tai(times(i))
      IF (time GE tstart) AND (time LE tstop) THEN BEGIN

         nx = index(i).hxi.shape_sav(0) ;size in pixels
         ny = index(i).hxi.shape_sav(1)

         IF NOT exist(sx) THEN sx = nx
         IF NOT exist(sy) THEN sy = ny

         IF (nx EQ sx) AND (ny EQ sy) THEN BEGIN
            map = make_map(data(0:nx-1, 0:ny-1, i) > zero, xc = xc(i), yc = yc(i), $
                           dx = dx, dy = dy, time = times(i), _extra = extra, $
                           dur = index(i).hxi.actim/10.0, $ ;in seconds
                           id = ch_string(index(i).hxi.chan), $
                           err = err, units = 'arcsecs', $
                           roll_angle=phi(i)*180./!pi, $
                           roll_center=[xc(i),yc(i)])
         ENDIF ELSE BEGIN
            err = 'Skipping image dimensions: '+trim(string(nx))+','+trim(string(ny))
         ENDELSE
         IF err NE '' THEN BEGIN
            message, err, /cont
         ENDIF ELSE img = merge_struct(img, map)
      ENDIF

   ENDFOR

   IF NOT exist(img) THEN BEGIN
      message, 'No images during specified times', /cont
      img = 0
   ENDIF

   RETURN, img

END
