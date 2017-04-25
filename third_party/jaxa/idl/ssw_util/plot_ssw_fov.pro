;+
;NAME:
;       plot_ssw_fov
;PURPOSE:
;       Plot fields of view of selected instruments from catalogs
;SAMPLE CALLING SEQUENCE:
;       plot_ssw_fov,st_time,en_time     [,/trace][,/sxt][,/all]
;	plot_ssw_fov,'4-jun-98 01:00','4-jun-98 02:00',/trace
;INPUTS:
;       st_time     - start time 
;	en_time     - end time
;Keyword Inputs:
;       all         - if set, plot all available FOVs  (the default)
;       sxt         - if set, Yohkoh/SXT FOV
;       trace       - if set, TRACE FOV
;       cds         - if set, SoHO/CDS FOV
;       eit         - if set, SoHO/EIT FOV (304A image backdrop to CDS)
;
;	nonar       - inhibits numbering of the NOAA Active Regions
;       notime      - inhibits plotting of the timeline
;       reset       - cleans up if UTPLOT gets confused...
;PROCEDURE:
;       Reads catalogs for the selected instruments
;       Plots FOV of each on outline of solar disk
;	Plots timeline showing channels used on SXT and TRACE
;RESTRICTIONS:
;	You MUST enter IDL with SSW_INSTR including "cds eit sxt trace" 
;	Required catalogs must be on line and required env. variables defined.
;	For this routine to fully function, it needs:
;	   The SXT FFI and PFI observing logs  (osf and osp file)
;          The TRACE catalog  (tcl files)
;          The CDS observing logs  (too many to mention)
;          The EIT 304A summary images  (very optional; draws limb if absent)
;	If any are missing, that part will not be plotted...
;	Will not try to plot CDS and EIT at times when SOHO was disabled.
;	Will not try tp plot before an instrument was launched...
;
;HISTORY:
;          Feb-99       Written by R.D.Bentley (MSSL/UCL)
;	08-Dec-99  rdb  Enhanced routine; reuse if times the same
;			Added CDS plot (with EIT background; NAR overplot)
;	21-dec-99  rdb  Corrected sxt utplot
;-

pro	plot_ssw_fov, sttim, entim, all=all, reset=reset, $
		sxt=sxt, trace=trace, eit=eit, cds=cds, $
		nonar=nonar, notime=notime, $
		noplot=noplot, debug=debug, _extra=extra

common ssw_fov,old_range,tcat,sxtp0,sxtf0

if n_params() eq 0 then begin
   if n_elements(old_range) eq 0 then begin
      sttim = '1-jul-98 01:00'
      entim = '1-jul-98 02:00'
   endif else begin
      sttim = fmt_tim(old_range(0))
      entim = fmt_tim(old_range(1))
   endelse
endif

if (n_elements(old_range) eq 0) or keyword_set(reset) then begin
   tx = anytim2ints('1-jan-1980')
   old_range = [tx,tx]
   clear_utplot
endif

if n_params() eq 1 then begin
;	assume start time; with duration of 1 day
    entim = fmt_tim(addtime(sttim,delta=24*60.))
endif

range = anytim2ints([sttim,entim])
print,'Selected Time Range: ',fmt_tim(range)

reuse = 1
if (fmt_tim(range(0)) ne fmt_tim(old_range(0))) or $
   (fmt_tim(range(1)) ne fmt_tim(old_range(1))) then reuse = 0
old_range = range

do_all = keyword_set(all)
if (not keyword_set(sxt)) and (not keyword_set(trace)) $
   and (not keyword_set(eit)) and (not keyword_set(cds)) then do_all = 1

;>>	trap some times when we know things are not there...

if addtime(sttim,diff='1-Sep-1991') lt 0 then begin
   print,'Before start of the Yohkoh Mission'
;??	just plot limb and active regions??
   return
endif
if addtime(sttim,diff='1-Jan-1996') lt 0 then begin
   print,'Before start of the SOHO Mission'
   do_all=0 & sxt=1
endif
if addtime(sttim,diff='26-Jun-1998') ge 0 and $
      addtime(sttim,diff='20-Nov-1998') le 0 then begin
   print,'** SOHO was not working during this Interval **'
   cds=0
   if do_all then begin
      do_all=0
      trace=1 & sxt=1
   endif
endif
if addtime(sttim,diff='1-Apr-1998') lt 0 then begin
   print,'Before start of the TRACE Mission'
   trace=0
   trace_wave=[' ']
endif
if addtime(sttim,diff=fmt_tim(systime2())) gt 0 then begin
;	future time...
   box_message,'** One does not have a crystal ball... **'
   return
endif

if do_all then box_message,'PLOT_SSW_FOV - Plotting all available FOVs'

;	create the window and setup scales

if not keyword_set(noplot) then begin

loadct,3,/silent
if keyword_set(cds) or do_all then begin
   window,xsiz=512*2,ysiz=512
   !p.multi=[0,2,1]
   !p.multi[0]=2
endif else begin
   window,xsiz=512,ysiz=512
   !p.multi=0
endelse

;window,xsiz=500,ysiz=500
;!p.position=[0.1,0.1,0.9,0.9]
;;plot,[0,1],[0,1],psym=1,pos=[0.07,0.06,0.95*8.2/11.,0.94],/nodata,          $
plot,[0,1],[0,1],psym=1,xstyle=1,ystyle=1,/nodata,           $
      xtitle='Solar EW (arc sec)',                           $
      ytitle='Solar NS (arc sec)',                           $
;;      xrange=[-20.,20.], yrange=[-20.,20.],                  $
      xrange=[-22.,22.]*60., yrange=[-22.,22.]*60.,          $
      title='Start-time ' + sttim + ', End-time ' + entim ;+ '!C' + seq_nam

;	outline solar limb

rr = get_rb0p(range)
rad = total(rr(0,*)) / n_elements(range)
xcir = cos(2*!pi*findgen(400)/399)
ycir = sin(2*!pi*findgen(400)/399)
oplot, xcir*rad, ycir*rad
empty

endif

;>>>	TRACE images

if keyword_set(trace) or do_all then begin 

   print,''
   print,'* Plot TRACE FOV'

   if ((not reuse) or (n_elements(tcat) eq 0)) then begin
      trace_cat,sttim,entim,temp,loud=loud
      if n_elements(temp) gt 0 then tcat = temp else tcat=-1
   endif else print,'* Re-using existing TRACE Catalog *'
   if keyword_set(debug) then help,/st,tcat

   sz = size(tcat)
   if n_elements(sz) eq 4 then begin
     if not keyword_set(noplot) then begin

      trace_wave = tcat(uniq(tcat.wave_len,sort(tcat.wave_len))).wave_len
      print,'TRACE wavelengths: ',trace_wave
      filter = ['naxis1=1024','wave_len=171,195']
;      ss = struct_where(tcat,test=filter)
        zz = where(tcat.obs_prog ne 'STD.fulldiskmosaic' $
             and tcat.wave_len ne 'PREV')	;skip preview images...
        ss = grid_data(tcat(zz),minutes=5)
        ss = zz(ss)
	if ss(0) eq -1 then ss= indgen(n_elements(tcat))
      help,ss
      tstruct = tcat(ss)
;      index2fov,tstruct,x0,x1,y1,y0	;east,west,north,south in arcsec
;      for i=0,n_elements(x0) do $
;         draw_boxcorn, x0, y0, x1, y1, /data, color=100

      x = tstruct.xcen
      y = tstruct.ycen
      dx = tstruct.CDELT1
      dy = dx				;.CDELT2 not always there
      xfov = tstruct.NAXIS1*dx		;tstruct.CDELT1
      yfov = tstruct.NAXIS2*dy		;tstruct.CDELT2

      plots,x,y,psym=3	;1
      for i=0,n_elements(x)-1 do begin
           draw_boxcensiz, x(i), y(i), xfov(i), yfov(i), /data
      endfor
      xyouts,-1200,1100,'TRACE',charsiz=1.5

     endif
   endif else print,'NO TRACE data in the time interval'

endif

;>>>	YOHKOH/SXT images

if keyword_set(sxt) or do_all then begin 

   print,''
   print,'* Plot YOHKOH/SXT FOV'

   if ((not reuse) or (n_elements(sxtp0) eq 0)) then $
      rd_obs,sttim,entim,bcs0,sxtf0,sxtp0,w_h0,fid0,/sxtp $  ;/sxtf
      else print,'* Re-using existing SXT PFI Catalog *'
   help,sxtp0
   if keyword_set(debug) then help,/st,sxtp0
   struct = sxtp0

   sz = size(struct)
   if n_elements(sz) eq 4 then begin
     if not keyword_set(noplot) then begin

   print,'SXT Filters:',all_vals(gt_filtb(struct))
;   ss = sxt_where(struct,conf_file='sxt.config')	;,/quiet)
        ss = grid_data(struct,minutes=5)
;;	ss= indgen(n_elements(struct))
   help,ss
   struct = struct(ss)		;reduce number of frames to what want...
;   sidx = struct2ssw(struct)

   fov_center = gt_center(struct, /angle)  	;acrminutes from sun center
   x = fov_center(0,*) 
   y = fov_center(1,*)

   sum = 2^gt_res(struct)
   shape_cmd = gt_shape(struct, /obs_region)
   xfov = shape_cmd(0,*)*sum*!ys_sxtpix	              ;size of the plot window in arcminutes
   yfov = shape_cmd(1,*)*sum*!ys_sxtpix

   plots,x,y,psym=3,color=140		;was psym=1
   for i=0,n_elements(struct)-1 do begin
           draw_boxcensiz, x(i), y(i), xfov(i), yfov(i), /data, color=140
   end
      xyouts,-1200,1000,'SXT',color=140,charsiz=1.5

     endif
   endif else print,'NO YOHKOH/SXT data in the time interval'

endif


;>>>	SOHO/EIT images

if keyword_set(eit) or do_all then begin 

   print,''
   print,'* SOHO/EIT shown with SOHO/CDS'

endif


;>>>	SOHO/CDS images

if keyword_set(cds) or do_all then begin 

   print,''
   print,'* Plot SOHO/CDS FOV with EIT background'
   !p.multi[0]=1
   nar=1
   if keyword_set(nonar) then nar=0
   plot_cds_point, sttim, entim, nar=nar, $	;reuse=reuse, $
      xrange=[-22.,22.]*60., yrange=[-22.,22.]*60., $
      _extra=extra
   xyouts,-1200,1100,'CDS',charsiz=1.5

endif


;>>>	Do a Time plot of the images

wsave = !d.window
if not keyword_set(notime) then begin
   nytick=max([17,8+n_elements(trace_wave)])	;may want to filet some TRACE channels...
   ytick = strarr(nytick+1)+' '

;	SXT name
   sxt_chan = ['WL?','Thin AL','Dagwood','Be 119','Thick Al','Mg 3']	;,'* SXT']
   ytick(1) = sxt_chan
   struct = sxtp0	;<<<<<<<<<<<<<<<<
;	trace wavelength -> an value
   if n_elements(tcat) gt 1 then begin
      tri_wave = tcat.wave_len
      wtxx = intarr(n_elements(tri_wave))
      for jw = 0,n_elements(wtxx)-1 do wtxx(jw) = where(trace_wave eq tri_wave(jw))
      ytick(8) = trace_wave	;,'* TRACE']
   endif

;   print,ytick
   !p.multi=0
   window,1,ysiz=400
;;   utplot,struct,gt_filtb(struct),psym=1,color=140, $
   utplot,range,[0,0],/nodata, $
	yrange=[0,nytick],yst=1,timer=old_range,xst=1, $
	tit='Times of TRACE (white) and SXT PFI (yellow) Images', $
	ytickname=ytick,yticks=nytick
   if n_elements(struct) gt 1 then outplot,struct,gt_filtb(struct),psym=1,color=140
   if n_elements(tcat) gt 1 then outplot,tcat,wtxx+8,psym=1
endif
wset,wsave

ans = ''
if keyword_set(debug) then read,'Pause: ',ans

end
