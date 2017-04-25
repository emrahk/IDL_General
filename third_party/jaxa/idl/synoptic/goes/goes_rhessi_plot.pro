;+
;Name: goes_rhessi_plot
;
;PURPOSE : Creates a plot of the two GOES X-Ray channels for the selected time range, and  
;  optionally displays RHESSI observing times with indications of night,SAA, offpointing, or
;  annealing for non-observing times. If GOES data aren't available, use EVE GOES proxy data.
;  This is called by do_goes_rhessi_plots on hesperia.gsfc.nasa.gov to create the 24-hr, 
;  12-hr stacked, and rhessi orbit time plots used in the RHESSI browser at
;  http://sprg.ssl.berkeley.edu/~tohban/browser/.
;  
; Input Keywords:
;  time - Either a time range or a single time. For single time, will assume that day.
;  stacked - if set, divide time into 2 and plot two stacked plots (D=0)
;  orbit - if set, we're doing an orbit plot (Note that the times for the orbit are 
;    in time keyword (for batch runs called by do_goes_rhessi_plots) we just need to know here 
;    that it's an orbit plot, since plot params and browser output dir are different)
;  black_bk - if set, plot background will be black (D=white)
;  rhessi - if set, overlay RHESSI Sun observing times, and show anneal or offpoint times
;  png - if set, write plot in png file
;  outfile - png file name.  (D='goes_rhessi_yyyymmdd.png')
;  filename_time - if set, when constructing file name, use date and time
;  filename_append - add this string to end of outfile
;  browser - if set, then plot is for browser. Can only be used on hesperia.
;    png is set to 1, 
;    directory for output file is set to '/data/goes/xxx/ where 
;       xxx is the directory 24hr_plots, 12hr_plots, or rhessi_orbit_plots and
;    filename is set to goes_rhessi_yyyymmdd.png or goes_rhessi_yyyymmdd_hhmm.png for orbit plots
;    
;
; Output:
;   Either a single plot for the full duration requested, or 2 stacked plots each with half the duration, 
;   plotted on screen or in a .png file.
;   
; Examples:
;   goes_rhessi_plot, time='23-jul-2002', /rhessi, /stacked, /png
;   goes_rhessi_plot, time=['22-jul-2002', '24-jul-2002']
;   
;Written, Kim Tolbert 8-May-2012. Based on Steven Christe's my_goes_plot
;Modifications:
; 14-May-2012, Kim.  Moved call to hsi_linecolors to after set_plot,'z' because in batch mode can't
;  call it for X
; 23-Feb-2015, Kim. Fixed bug - yminor should be 9, not 10 in 3 places.
;
;-

PRO goes_rhessi_plot, time=time, $
  STACKED=stacked, $
  orbit=orbit, $
  black_bk=black_bk, $
  RHESSI=rhessi, $
  PNG=png, $
  OUTFILE=outfile, $
  filename_time=filename_time, $
  filename_append = filename_append, $
  BROWSER = browser

browser = keyword_set(browser)
stacked = keyword_set(stacked)
orbit   = keyword_set(orbit)
nplots = stacked ? 2 : 1
png = keyword_set(png) or keyword_set(outfile) or browser

default, tr, keyword_set(time) ? time : ['22-jul-2002', '22-jul-2002 23:59']
tr = anytim(tr)
if n_elements(tr) eq 1 then tr = anytim(tr,/date) + [0.,86400.]

year = strmid(anytim(tr[0], /ccsds), 0, 4)
month = strmid(anytim(tr[0], /ccsds), 5, 2)

default, charsize, 1.

ytitle = 'Watts m!U-2!N'
gtitle = 'GOES 3-sec X-ray Flux   '
etitle = 'EVE GOES Proxy   '
legend_chan = ['1.0 to 8.0 A', '0.5 to 4.0 A']
legend_obs = 'No RHESSI Solar Data'
rhessi_sun_legend = 0

IF png THEN BEGIN
  dir = chklog('HOME')
  if dir eq '' then dir = curdir()
  file = 'goes_rhessi_' + (keyword_set(filename_time) ? time2file(tr[0]) : time2file(tr[0],/date))		
  default, outfile, file

  IF browser then begin
    dd = stacked ? '12hr_plots/' : '24hr_plots/'
    if orbit then begin
      dd = 'rhessi_orbit_plots/'
      year = year + '/' + month
    endif
    dir = '/data/goes/' + dd + year + '/'
    if ~file_test(dir, /dir) then file_mkdir, dir
    outfile = file
  endif

  if keyword_set(filename_append) THEN  outfile = outfile + filename_append
  outfile = outfile + '.png'

  save_dev = !d.name
  set_plot, 'z'
  ysize = orbit ? 380 : 480
  if nplots eq 2 then ysize = 600 
  res = (nplots eq 2) ? [640,ysize] : [640,ysize]
  device, set_resolution = res
  
endif

hsi_linecolors, /pastel
red = 6
blue = 7
gray = 19
ltblue = 15
ltpurple = 17
ltgreen = 14
ltgray = 18
bw = 0
bkcolor = 255
if keyword_set(black_bk) then begin
  bw = 255
  bkcolor = 0
endif

!p.multi=0
leg_position = [.1,.92]
leg_horiz = 1
leg_right = 0
leg_charsize = charsize
tr_arr = tr
yrange = [1.d-9, 1.d-2]
autoscale = 0
ystyle = 1
IF nplots eq 2 then begin
  !p.multi = [0,1,2]
  dt = tr[1] - tr[0]
  tr_arr = [[tr[0] + [0.,dt/2.]], [tr[0] + [dt/2., dt]]]
  leg_position = [.1,.51]
endif
if orbit then begin
  leg_position = [1.,.9]
  position=[.124,.1,.750, .9]
  leg_horiz = 0
  leg_right = 1
  leg_charsize = charsize * .7
  autoscale = 1
  ystyle = 0
endif 


FOR i = 0, nplots-1 DO BEGIN

  tplot = tr_arr[*,i]
  
  data = get_goes_eve_lc(anytim(tplot,/vms), type=name)
  
  title = i eq 0 ? (name eq 'EVE' ? etitle : gtitle) + anytim(tplot[0],/vms,/date) : ''
  if autoscale then yrange = is_struct(data) ? minmax([data.lo,data.hi]) : [1.d-9, 1.d-2]
  yrange[0] = yrange[0] > 1.d-9
  yrange[1] = yrange[1] < 1.d-2
  
  ; just plot axes and labels first
  utplot, anytim(/ext,tplot), yrange, /nodata, yrange=yrange, timerange=tplot, title=title, $
    ytitle=ytitle, /ylog, ystyle=ystyle, yminor=9, ymargin=[3.5,2.], $
    /xstyle, xmargin=[8,3], xtitle='', $
    position=position, $
    background=bkcolor, charsize = charsize, color=bw, /sav

  IF is_struct(data) THEN BEGIN
		
    tarray = data.time
    tarray_ext = anytim(tarray,/ext)
    lo = data.lo
    hi = data.hi
    dim = n_elements(tarray)
    	
    IF NOT keyword_set(rhessi) THEN BEGIN 
      ; If not overplotting RHESSI observing information, just draw the two GOES traces
      outplot, tarray_ext, lo, color = red, thick = 2
      outplot, tarray_ext, hi, color = blue, thick = 2
    ENDIF ELSE BEGIN
      ;Otherwise get night,saa,anneal,offpoint info and overplot
      rhessi_sun = bytarr(dim)  ; array of 0s and 1s, will be 1 where RHESSI observed Sun
      rhessi_sun_legend = 1
      
      ; for all good time intevals (not eclipse or SAA), set rhessi_sun flag to 1
      good_times = hsi_get_good_time(tplot, night_times=night_t, saa_times=saa_t)
      if good_times[0] ne -1 then begin    	           
        for j = 0, n_elements(good_times[0,*])-1 DO BEGIN
          q = where(tarray GE good_times[0,j] and tarray LE good_times[1,j], count)
          IF (count GE 1) THEN rhessi_sun[q] = 1
        endfor
      endif
      ; Shade in the night and saa intervals with pastel purple and green
      if night_t[0] ne -1 then for j=0,n_elements(night_t[0,*])-1 do color_box, x=night_t[*,j]-tplot[0], color=ltpurple
      if saa_t[0] ne -1 then for j=0,n_elements(saa_t[0,*])-1 do color_box, x=saa_t[*,j]-tplot[0], color=ltgreen
               
      off_data = hsi_get_off_times(err=err)
      if ~err then begin
        ; does our requested time overlaps with any off period?
        index = where(tplot[0] lt off_data.etime and tplot[1] GE off_data.stime, count)
      
        ; for that off period, find data array elements that are during offpoint
        IF count EQ 1 THEN BEGIN
          off = off_data[index[0]]
          
          ; for the data times that are in the off time, set the rhessi_sun flag to 0
          q = where(tarray ge off.stime and tarray le off.etime, count)		
          IF count GT 1 THEN rhessi_sun[q] = 0
            
          if stregex(off.name, 'anneal', /fold, /boolean) then begin
            text = 'Annealing'
            off_color = ltgray
          endif else begin
            text = 'Offpointing'
            off_color = ltblue
          endelse
          toff = [[tplot[0] > off.stime], [tplot[1] < off.etime]] - tplot[0] 
          ; Shade in the anneal or offpoint interval with pastel gray or blue         
          color_box, x=toff, color=off_color
          ; Draw night/saa shading again for offpointing, so they will show (be on top)
          if text eq 'Offpointing' then begin
            if night_t[0] ne -1 then for j=0,n_elements(night_t[0,*])-1 do color_box, x=night_t[*,j]-tplot[0], color=ltpurple
            if saa_t[0] ne -1 then for j=0,n_elements(saa_t[0,*])-1 do color_box, x=saa_t[*,j]-tplot[0], color=ltgreen
          endif
           
          plot_dur = tplot[1] - tplot[0]
          off_dur = toff[1] - toff[0]
          ratio_off = off_dur / plot_dur
          ang = [80., 50., 30.]
          siz = [1, 2, 3]
          rats = [0., .2, .45]  ; cutoffs for angles and size of text message for offpoint and anneal
          cr = !y.crange ; log of y range
          yval = 10.^(cr[0] + .4*(cr[1]-cr[0])) ; yval will be .4 of distance from bottom to top of plot
          j = value_locate(rats, ratio_off) ; find where our ratio is among those cutoffs
          if ratio_off gt .05 then xyouts, average(toff), yval, text, align=.5, $ 
            orient=ang[j], charsize=siz[j], charthick=2, color=bw
        ENDIF  ; end of count gt 1 

	    ENDIF   ; end of if error in reading off data
	  
	   ; Plot all goes data in gray, then overplot RHESSI sun times in red and blue
	    outplot, tarray_ext, lo, color = gray, thick = 1
      outplot, tarray_ext, hi, color = gray, thick = 1
      outplot, tarray_ext, lo*rhessi_sun, color = red, thick = 2
      outplot, tarray_ext, hi*rhessi_sun, color = blue, thick = 2
    ENDELSE  ; end of overplot rhessi info branch
  ENDIF
  
  ; redraw axes in case we used polyfill above
  axis,yaxis=0,color=bw, yminor=9, ytickname=strarr(9)+' ', /ystyle
  axis,yaxis=1,color=bw, yminor=9, ytickname=strarr(9)+' ', /ystyle
  axis, xaxis=0, color=bw, xrange=!x.crange 
  axis, xaxis=1, color=bw, xtickname=strarr(20)+' ',xrange=!x.crange 
  ylims = crange('y')
  ytickv = 10.^[-13+indgen(12)]
  ytickname = [' ',' ',' ',' ',' ','A','B','C','M','X',' ',' ']
  ymm = ylims + ylims*[-1.e-7, 1.e-7]
  q = where(( ytickv ge ymm(0)) and ( ytickv le ymm(1)), kq)
  if kq gt 0 then begin
    axis, yaxis=1, ytickv = ytickv[q],/ylog, ytickname=ytickname[q], yrange=ylims, yticks=kq, color=bw, charsize=charsize*1.2
    for k=0,kq-1 do outplot, !x.crange, ytickv[q[k]]+[0.,0.], color=gray
  endif
  
  clear_utplot
ENDFOR

text = legend_chan
color = [red,blue]
thick = [3,3]
if rhessi_sun_legend then begin
  text = [text, legend_obs]
  color = [color, gray]
  thick = [thick, 1]
endif

; if stacked, legend will be written in between two plots
ssw_legend, text, color=color, lines=0, position=leg_position,/normal, right=leg_right, textcolor=bw, thick=thick, $
  horizontal=leg_horiz, linsize=.7, charsize=leg_charsize, box=0

usersym,[-4.,12,12,-4],[-2.5,-2.5,2.5,2.5],/fill
ssw_legend, ['Night','SAA'],textcolor=0, position=[.1, .035], /normal,/horiz,box=0, $
  /fill,psym=[8,8],colors=[ltpurple,ltgreen],charsize=leg_charsize
timestamp, charsize=charsize*.7, /bottom, color=bw

IF keyword_set(OUTFILE) THEN BEGIN
	tvlct, r, g, b, /get
	filename = concat_dir(dir, outfile)
	write_png, filename, tvrd(), r,g,b
	message, /info, 'Wrote plot file ' + filename
	set_plot, save_dev
ENDIF

!P.multi = 0

END
