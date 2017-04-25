pro img_summary_pixlst, img, x, h, nlst, nx, i0, i1, j0, j1, ii, isign, xx, iline, step
;
;
;
    idone = 0L
    while ((idone lt nlst) and (ii ge 0) and (ii lt n_elements(x))) do begin
	nmatch = h(ii)
	if (nmatch gt 0) then begin
	    ss = where(img eq x(ii), nmatch)
	    for i=0L,nmatch-1 do begin
		if (idone lt nlst) then begin
		    ;xpos = (ss(i) mod (nx+2*margin)) + margin
		    ;ypos = (ss(i) / (nx+2*margin)) + margin
		    xpos = ss(i) mod nx
		    ypos = ss(i) / nx
		    val = img(xpos, ypos)
		    if ((xpos ge i0) and (xpos le i1) and (ypos ge j0) and (ypos le j1)) then begin
			str = string(xpos, ypos, format='(i4,",",i4)') + ' = ' + string(val)
			xyouts2, xx+10, step*iline, str, /dev, siz=f		& iline=iline-1
			idone = idone + 1
		    end
		end else begin
		    i = nmatch	;terminate looping
		end
	    end
	end 
	ii = ii + isign
    end
end
;-------------------------------------------------------------------------
pro img_summary, img, tit, comments, hc=hc, qstop=qstop, $
		scl_min=scl_min, scl_max=scl_max, log_scale=log_scale, $
		brightest=brightest, dimmest=dimmest, $
		margin=margin, progver=progver2
;+
;NAME:
;	img_summary
;PURPOSE:
;	To display summary information of an image.  Display the image
;	along with histograms and line plots, plus other text info
;SAMPLE CALLING SEQUENCE:
;	img_summary, img
;	img_summary, img, 'Main Title Example', ['comment1', 'comment2']
;	img_summary, img, margin=2, brightest=8, dimmest=8
;	img_summary, img, tit, comments, hc=hc, qstop=qstop, $
;		scl_min=scl_min, scl_max=scl_max, log_scale=log_scale, $
;		brightest=brightest, dimmest=dimmest, $
;		margin=margin, progver=progver2
;
;INPUT:
;	img	- The image to be summarized
;OPTIONAL INPUT:
;	tit	- The title to be displayed
;	comments- A string array of comments to display
;OPTIONAL KEYWORD INPUT:
;	hc	- If set, make a hardcopy (do not display to the screen)
;	scl_min	- The minimum to use for stretching
;	scl_max	- The maximum to use for stretching
;	log_scale- If set, display the second form of the image in log
;		  scaling (rather than +/- 1 sigma)
;	qstop	- If set, stop for debugging
;	brightest - If defined, print out information on the brightest
;		  pixel locations and their values.  The number of
;		  values displayed is the value which is passed in.
;	margin	- If defined, print the min/max/avg/dev for the image
;		  less "margin" pixels on the left/right/top/bottom
;		  (ie: margin=1 says ignore first/last columns/lines)
;	progver	- The outside program name and version
;HISTORY:
;	Written 5-Apr-94 by M.Morrison
;V1.1	 5-Apr-94 (MDM) - Changed options/format slightly
;			- Modified histogram to stretch if max-min < 2
;V1.2	 6-Apr-94 (MDM) - Added "brightest" option
;V1.3	 7-Apr-94 (MDM) - Allowed "title" to be an array
;V1.4	19-Apr-94 (MDM) - Added MARGIN keyword option
;			- Added printing information on number of pixels
;			  included in the expanded scale
;			- Added (0,0) label for the images
;			- Added PROGVER keyword option
;			- Added plotting histogram of +/-1 sigma when
;			  the +/- 2 sigma is pretty much the same as
;			  the full range
;V1.41	20-Apr-94 (MDM) - Small format change
;V1.5	22-Apr-94 (MDM) - Corrected error in the second image scaling
;			  (+/- 1 sigma).  Variable name conflict
;V1.51	22-Apr-94 (MDM) - Corrected calculation of average of all
;			  rows and columns when using margin (it was
;			  doing it for the whole image before)
;			- Modified to use "midev" instead of "idev"
;			  for +/- 1 sigma scaling of image when
;			  margin is used.
;			- Scale the expanded histogram using "midev"
;V1.52	25-Apr-94 (MDM) - Modified to call FONT_SIZE when going to an
;			  X-window
;V1.53	29-Apr-94 (MDM) - Modified to only call FONT_SIZE if not PS
;V1.54	14-Jun-94 (MDM) - Corrected error for case when MARGIN is not used
;V1.60	22-Feb-96 (MDM) - Added DIMMEST option
;			- Added sample calling sequence to header
;			- Corrected error where MARGIN range was using Full 
;			  image min (reported incorrect range)
;V1.61	 6-Mar-96 (MDM) - Corrected to display the image properly when it
;			  is not square
;V1.62	11-Jul-96 (MDM) - Added Z output option
;V1.63	24-Oct-96 (MDM) - Modified use TV2, /INIT for all output types
;			  (rather than the case statement)
;V1.64	 6-Nov-96 (MDM) - Moved "save_device" and "save_color" to
;			  outside the conditional for "hc"
;			- Added "/int" to set_plot,'ps'
;			- Added top=!d.table_size-1 to bytscl
;			- Modified to only call "pprint" if /hc is set
;V1.65	 6-Nov-96 (MDM)	- Modified to use "setps"
;V1.70	 6-Dec-96 (MDM) - Modified plotting of lines and columns to
;			  not exclude the "margin" pixels, rather to 
;			  just set the plot range to be the portion
;			  excluding the margin.
;V1.80	16-Apr-97 (MDM) - Added protection for out of bounds for
;			  margin option
;V2.00	08-Apr-98, William Thompson, GSFC
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;			(version number was not updated in PROGVER)
;V2.01	22-Jul-98 (MDM) - Made the font size for Z buffer be 0.8
;-
;
progver = 'IMG_SUMMARY Ver 2.01 '
;
;f = 1.0
save_device = !d.name
save_color = !color
if (keyword_set(hc)) then begin
    f = 0.8
    save_charsize = !p.charsize
    ;;set_plot, 'ps', /int
    setps
    !color = 0
    !p.charsize = f
end else begin
    if (!d.name eq 'Z') then f = 0.8 $
			else f = 6.0 / font_size(1)
    !p.charsize = f
end
;
if (n_elements(img) le 1) then begin
    print, 'IMG_SUMMARY: Image must be at least 2 elements'
    return
end
nx = n_elements(img(*,0))
ny = n_elements(img(0,*))
if (nx eq 1) or (ny eq 1) then begin
    print, 'IMG_SUMMARY: Input must be 2D (and not 1xN or Nx1)
    return
end
;
if (n_elements(margin) eq 0) then margin = 0

redo:
i0 = margin>0<(nx-1)	& i1 = (nx-1-margin)>0<(nx-1)>i0
j0 = margin>0<(ny-1)	& j1 = (ny-1-margin)>0<(ny-1)>j0
if (i1 eq i0) or (j0 eq j1) then begin
    print, 'IMG_SUMMARY: Margin is larger than the image.  Turning margin off.
    margin = 0
    goto, redo
end
;
nn = 180
nnx = nn * ( float(nx) / (nx>ny) )	;MDM added 6-Mar-96
nny = nn * ( float(ny) / (nx>ny) )
nxout = 3*nn*1.2
nyout = 4*nn*1.2
;
tv2, nxout, nyout, /init, /already
;
imin = min(img)
imax = max(img)
if (n_elements(scl_min) eq 0) then scl_min = imin
if (n_elements(scl_max) eq 0) then scl_max = imax
idev = stdev(img, iavg)
devuse = idev
;
if (keyword_set(margin)) then begin
    mimin = min(img(i0:i1, j0:j1))
    mimax = max(img(i0:i1, j0:j1))
    if ((i1-i0) + (j1-j0) eq 0) then begin
	midev = 0.
	miavg = 0.
    end else begin
	midev = stdev(img(i0:i1,j0:j1), miavg)
    end
    devuse = midev
end else begin
    miavg = iavg
end
imin2 = miavg - devuse
imax2 = miavg + devuse
;
bimg1 = congrid(bytscl(img, scl_min, scl_max, top=!d.table_size-1), nnx, nny)
bimg2 = congrid(bytscl(img, imin2, imax2, top=!d.table_size-1), nnx, nny)
;
erase
tv2, bimg1,      0, nyout-nn-80	
mk_refbar,  nn+20, nyout-nn-80, scl_min, scl_max, ysiz=nn, siz=f
xyouts2,        0, nyout-80+4, '  Linear Scale', /dev, siz=f
xyouts2,        0, nyout-nn-80-10, '(0,0)', /dev, siz=f*.7
;
if (keyword_set(log_scale)) then begin
    img2 = alog10( (img-scl_min+1) )
    imin2 = min(img2)
    imax2 = max(img2)
    bimg2 = congrid(bytscl(img2, top=!d.table_size-1), nn, nn)
    tv2, bimg2, nxout/2, nyout-nn-80
    mk_refbar, nxout/2+nn+20, nyout-nn-80, imin2, imax2, /log_scale, log_offset=-scl_min+1, ysiz=nn, siz=f
    xyouts2,   nxout/2, nyout-80+4, '  Log Scale', /dev, siz=f
end else begin
    tv2, bimg2, nxout/2, nyout-nn-80
    mk_refbar, nxout/2+nn+20, nyout-nn-80, imin2, imax2, ysiz=nn, siz=f
    xyouts2,   nxout/2, nyout-80+4, '  Scaled +/- 1 sigma', /dev, siz=f
end
xyouts2, nxout/2, nyout-nn-80-10, '(0,0)', /dev, siz=f*.7
;
case 1 of
   (imax-float(imin) gt 2): begin		;simple histogram
	    hist_code = 0
	    h = histogram(img)
	    nh = n_elements(h)
	    x = findgen(nh) + imin
  	end
   (imax-imin eq 0): begin		;no histogram
	    hist_code = 1
	    x = [-1,0,1] + imin
	    h = [0, n_elements(img), 0]
	end
   else: begin
	    hist_code = 2
	    h = histogram((img-imin)*500)
	    nh = n_elements(h)
	    x = findgen(nh)/500. + imin
	end
endcase
xrange1 = [(iavg-devuse*2)>imin, (iavg+devuse*2)<imax]
temp = deriv_arr(xrange1) / (float(imax)-float(imin))
if (temp(0) gt .7) then xrange1 = [(iavg-devuse*1)>imin, (iavg+devuse*1)<imax]
;
dxwin = nn/nxout
dywin = nn/nxout/2*.85
dxskip = 1/3.
dyskip = 1/6.
x0 = 0.*dxskip+.05
x1 = 1.*dxskip+.05
x2 = 2.*dxskip+.05
y0 = 0.*dyskip+.05
y1 = 1.*dyskip+.05
y2 = 2.*dyskip+.05
y3 = 3.*dyskip+.05
y4 = 4.*dyskip+.05
plot, x, h>.1, /noerase, psym=10, /ytype, position = [x0, y3, x0+dxwin, y3+dywin], tit='Histogram (Log)'
plot, x, h,    /noerase, psym=10,         position = [x0, y2, x0+dxwin, y2+dywin], tit='Histogram'
plot, x, h,    /noerase, psym=10,         position = [x0, y1, x0+dxwin, y1+dywin], tit='Histogram (Expanded)', xrange=xrange1
nexp = 100.
ss = where((x lt !x.crange(0)) or (x gt !x.crange(1)))
if (ss(0) ne -1) then nexp = (1 - total(h(ss)) / float(nx*ny)) * 100.
xyouts, !x.crange(0), !y.crange(1), ' !c' + string(nexp,format='(f7.2)') + '% of pixels'
plot, x, h>.1, /noerase, psym=10, /ytype, position = [x0, y0, x0+dxwin, y0+dywin], tit='Histogram (Expanded Log)', xrange=xrange1
;
rtot = total(img(*,j0:j1),2) / (ny-2*margin)
ctot = total(img(i0:i1,*),1) / (nx-2*margin)
xarr = findgen(nx)
yarr = findgen(ny)
yr = [min(img(i0:i1,ny/2)), max(img(i0:i1,ny/2))]
plot, xarr, img(*,ny/2), tit='Center Row',          /noerase, position = [x1, y3, x1+dxwin, y3+dywin], xstyle=3, yr=yr
yr = [min(rtot(i0:i1)), max(rtot(i0:i1))]
plot, xarr, rtot,        tit='Average all Rows',    /noerase, position = [x1, y2, x1+dxwin, y2+dywin], xstyle=3, yr=yr
yr = [min(img(nx/2,j0:j1)), max(img(nx/2,j0:j1))]
plot, yarr, img(nx/2,*), tit='Center Column',       /noerase, position = [x1, y1, x1+dxwin, y1+dywin], xstyle=3, yr=yr
yr = [min(ctot(j0:j1)), max(ctot(j0:j1))]
plot, yarr, ctot,        tit='Average all Columns', /noerase, position = [x1, y0, x1+dxwin, y0+dywin], xstyle=3, yr=yr
;
;---------------------------------------- Text information
;
for i=1,n_elements(tit) do xyouts2, nxout/2, nyout-20*i, tit(i-1), align=0.5, siz=f*1.6, /dev
temp = progver
if (n_elements(progver2) ne 0) then temp = progver2 + ' / ' + progver
xyouts2, 0, 0, temp, /dev, siz=f
xyouts2, nxout/2, 0, 'Program Run: ' + !stime, /dev, siz=f
;
xx = x2*nxout*.95
yy = y4*nyout*.9
;
step = 15
xyouts2, xx, yy+step*0, /dev, 'Image Size: ' + arr2str(strtrim([nx,ny],2), delim=' x '), siz=f
;
xyouts2, xx, yy-step*1, /dev, '         Whole Img', siz=f
xyouts2, xx, yy-step*2, /dev, 'Average:   ' + strtrim(iavg,2), siz=f
xyouts2, xx, yy-step*3, /dev, 'STDDEV:    ' + strtrim(idev,2), siz=f
;
xyouts2, xx, yy-step*5, /dev, 'Min:       ' + strtrim(imin,2), siz=f
xyouts2, xx, yy-step*6, /dev, 'Max:       ' + strtrim(imax,2), siz=f
xyouts2, xx, yy-step*7, /dev, 'Range:     ' + strtrim(imax-imin,2), siz=f
;
if (keyword_set(margin)) then begin
    xyouts2, xx+120, yy-step*1, /dev, 'Margin='+strtrim(margin,2)+' pix', siz=f
    xyouts2, xx+120, yy-step*2, /dev, strtrim(miavg,2), siz=f
    xyouts2, xx+120, yy-step*3, /dev, strtrim(midev,2), siz=f
    ;
    xyouts2, xx+120, yy-step*5, /dev, strtrim(mimin,2), siz=f
    xyouts2, xx+120, yy-step*6, /dev, strtrim(mimax,2), siz=f
    xyouts2, xx+120, yy-step*7, /dev, strtrim(mimax-mimin,2), siz=f
end
;
;
yy = yy - step*10
xyouts2, xx, yy, /dev, 'Comments: ', siz=f
if (n_elements(comments) gt 0) then begin
    for i=0,n_elements(comments)-1 do xyouts2, xx+10, yy-(i+1)*step, comments(i), /dev, siz=f
end
;
if (keyword_set(brightest) or keyword_set(dimmest)) then begin
    if (keyword_set(margin) and (hist_code eq 0)) then begin
        ;recalc histogram to avoid a bunch of "where" commands on the wrong values
	h = histogram(img(i0:i1,j0:j1))
	nh = n_elements(h)
	x = findgen(nh) + mimin
    end
    if (keyword_set(brightest)) then iline = brightest+2 else iline = 0
    if (keyword_set(dimmest)) then iline = iline + dimmest + 2
    ;
    if (keyword_set(brightest)) then begin
	xyouts2, xx, step*iline, /dev, 'Brightest ' + strtrim(brightest,2) + ' Pixels: ', siz=f		& iline=iline-1
	img_summary_pixlst, img, x, h, brightest, nx, i0, i1, j0, j1, n_elements(x)-1, -1, xx, iline, step
    end
    if (keyword_set(dimmest)) then begin
	xyouts2, xx, step*iline, /dev, 'Dimmest ' + strtrim(dimmest,2) + ' Pixels: ', siz=f		& iline=iline-1
	img_summary_pixlst, img, x, h, dimmest, nx, i0, i1, j0, j1, 0, 1, xx, iline, step
    end
end
;
if (keyword_set(hc)) then pprint
if (!d.name eq 'PS') then begin
    !color = save_color
    set_plot, save_device
end
;
if (n_elements(save_charsize) ne 0) then !p.charsize = save_charsize
if (keyword_set(qstop)) then stop
end
