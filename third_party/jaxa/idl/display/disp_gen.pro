pro disp1gen, x0, y0, nout, img, mask_ss, smin, smax, tit, subtit, $
		mmad_lab=mmad_lab, hbar=hbar, vbar=vbar, nlab=nlab, fmt=fmt, $
		below=below

if (n_elements(img) eq 0) then return

nx = n_elements(img(*,0))
ny = n_elements(img(0,*))
scale = (float(nout)/nx) < (float(nout)/ny)
xoff = 0
if (nx lt ny) then xoff = (ny-nx)/2*scale

if (n_elements(mask_ss) eq 0) then begin		;no mask
    if (smin eq -999.99) then smin = min(img)
    if (smax eq -999.99) then smax = max(img)
    idev = stdev(img, iavg)
    imin = min(img)
    imax = max(img)
end else begin
    img2 = img(mask_ss)
    if (smin eq -999.99) then smin = min(img2)
    if (smax eq -999.99) then smax = max(img2)
    idev = stdev(img2, iavg)
    imin = min(img2)
    imax = max(img2)
end

tv2, bytscl(congrid(img, nx*scale, ny*scale,/interp), smin, smax, top=!d.n_colors-1), x0+xoff, y0
if (keyword_set(vbar)) then mk_refbar, x0+nout+10, y0, smin, smax, nlab=nlab, xsiz=30, ysiz=nout

if (keyword_set(mmad_lab)) then begin
    if (keyword_set(fmt)) then begin
	str = 'Avg: ' + string(iavg, format=fmt) + '  Dev: ' + string(idev, format=fmt) + $
		'  Min: ' + string(imin, format=fmt) + '  Max: ' + string(imax, format=fmt)
    end else begin
	str = 'Avg: ' + strtrim(iavg, 2) + '  Dev: ' + strtrim(idev, 2) + $
		'  Min: ' + strtrim(imin, 2) + '  Max: ' + strtrim(imax, 2)
    end
    xyouts2, x0, y0-10, str, size=0.8
end
;
if (keyword_set(below)) then begin
    if (keyword_set(tit)) then    xyouts2, x0+nout/2, y0-18, align=0.5, tit, size=1.2
    if (keyword_set(subtit)) then xyouts2, x0+nout/2, y0-30,  align=0.5, subtit, size=1.0
end else begin
    if (keyword_set(tit)) then    xyouts2, x0+nout/2, y0+nout+20, align=0.5, tit, size=1.2
    if (keyword_set(subtit)) then xyouts2, x0+nout/2, y0+nout+2,  align=0.5, subtit, size=1.0
end
;
end
;------------------------------------------------------------------------------------------
pro disp_gen, code0, img1, mtit, msubtit, msubtit2, $
	tit1=tit1, subtit1=subtit1, $
	img2=img2, tit2=tit2, subtit2=subtit2, $
	img3=img3, tit3=tit3, subtit3=subtit3, $
	img4=img4, tit4=tit4, subtit4=subtit4, $
	titn=titn0, subtitn=subtitn0, $
	smin=smin0, smax=smax0, sigma=sigma, $
	foot1=foot1, foot2=foot2, date=date, $
	xsize=xsize, ysize=ysize, $
	color=color, hc=hc, fix_font=fix_font, $
	loadct=loadct, mask_ss=mask_ss, $
	nlab=nlab, fmt=fmt, axis1=axis1, axis2=axis2, $
	avg=avg, log_hist=log_hist, $
	std_foot=std_foot, outfil=outfil, $
	xarr=xarr, yarr=yarr, xrange=xrange, yrange=yrange, xtit=xtit, ytit=ytit, mtit=mtit_plot, $
	compass=compass, gif=gif, cmds=cmds, window=window, $
	footnotes=footnotes, $
	xcorner=xcorner, ycorner=ycorner, land=land, $
	gamma=gamma, ppinch=ppinch
;+
;NAME:
;	disp_gen
;PURPOSE:
;	To use the "TV2" and "XYOUTS2" options to display images and
;	data.  Useful for making pretty prints.
;SAMPLE CALLING SEQUENCE:
;	disp_gen
;	disp_gen, 0, bytscl(img, top=!d.n_colors-1), 'MDI Dopplergram', $
;				'16-JAN-96 12:49:09 UT', foot1='SOI/MDI'
;	disp_gen, 0, bimg, tit1, subtit1, /std_foot
;	disp_gen,10,dist(200),'main tit1',/std_foot,img2=dist(200),smin=[0,0],smax=[141,100], $
;		tit1='image 1 tit',tit2='image 2 tit',subtit1='subtitle for image 1',/date,mask=indgen(2000)
;	disp_gen,20,dist(200),xarr=indgen(100),yarr=findgen(100)^3.,xtit='x-title',ytit='y-title',mtit='plot title'
;	disp_gen,40,img1,img2=img2,img3=img3,img4=img4,smin=[0,0,-10,20],smax=[100,200,400,400]
;	disp_gen, code0, img1, mtit, msubtit, $
;		tit1=tit1, subtit1=subtit1, $
;		img2=img2, tit2=tit2, subtit2=subtit2, $
;		smin=smin, smax=smax, sigma=sigma, $
;		foot1=foot1, foot2=foot2, date=date, $
;		xsize=xsize, ysize=ysize, $
;		color=color, hc=hc, fix_font=fix_font, $
;		loadct=loadct, mask_ss=mask_ss, $
;		nlab=nlab, fmt=fmt, axis1=axis1, $
;		avg=avg, log_hist=log_hist, $
;		std_foot=std_foot, outfil=outfil, $
;		xarr=xarr, yarr=yarr, xrange=xrange, yrange=yrange, xtit=xtit, ytit=ytit
;	disp_gen, 1, img, cmds='disp_mdi_hr_fov, 0, 100, scale=0.5'
;	disp_gen, 100, img, msubtit, msubtit2, titn=titn, subtitn=subtitn
;	disp_gen,100,indgen(20,20,9),titn=sindgen(9),'main tit', 'sub tit',subtitn='subtit'
;CAUTION:
;	Use the LOADCT keyword option to be sure that the colors are all reset
;	and that the color table is correct.  The capability to inherit
;	the modified table (by xloadct or something else) should work, but
;	is limited by a bug with IDL (applies only to 8 bit color displays?)
;INPUT:
;	code	- =0 for just a single image with titles
;		  =1 for a single image with a color bar
;		  =10 for single image shown twice with 3 plots
;		  =11 for two separate images being passed in, with 3 plots
;		  =12 for two separate images being passed in, no plots
;		  =20 for single image with plot
;		  =40 for four image display with color bar
;		  =100 for NxN images (put in images as data cube)
;		  =104 for 2x2 images (put in images as img1,img2,img3,img4)
;	img1	- the image to display
;	mtit	- Main title
;	msubtit	- Main subtitle
;	tit1	- Title to go over image 1 (only code 10 and 11)
;	subtit1	- subtitle over image 1 (only code 10 and 11)
;	img2	- the second image to display (only code 11)
;	tit2	- Title to go over image 2 (only code 10 and 11)
;	subtit2	- subtitle over image 2 (only code 10 and 11)
;	smin	- the scaling minimum for display (two element array for code 11)
;	smax	- the scaling minimum for display (two element array for code 11)
;	sigma	- the scaling range for code 10 option (defaults to +/- 1 sigma)
;		  Set the range for code 0 and 1 options
;	foot1	- footnote for lower left corner
;	foot2	- footnote for lower right corner
;	std_foot- if set, use foot1='SOI/MDI' and foot2='Stanford Lockheed 
;		  institute for Space Research'
;	date	- if set, display the date at the bottom of the plot
;	hc	- if set, set device to PS and send to the printer (hardcopy)
;	color	- if set, use color option on hard copy and send to the color
;		  printer on /HC option
;	fix_font -if set, set the default font so the X display character sizes
;		  are closer to matching the printouts
;	loadct	- the color table to establish
;	nlab	- number of labels for the color bars (optionally two elements)
;	fmt	- format statement for the color bar labels and avg/min/max option
;	avg	- if set, plot all line/column average instead of center line/column
;		  (only code 10 and 11)
;	log_hist- if set, display the histogram in log (only code 10 and 11)
;	mask_ss	- the mask for the values to display min/max/avg/dev/histogram
;		  (only code 10 and 11)
;	outfil	- the output file name if device is PS (or /hc is used)
;	xarr	- x-array to plot (code 20 only)
;	yarr	- y-array to plot (code 20 only)
;	xrange	- x-range to plot (code 20 only)
;	yrange	- y-range to plot (code 20 only)
;	xtit	- x-title (code 20 only)
;	ytit	- y-title (code 20 only)
;	compass - If set, then draw a little N/S, E/W compass in lower left
;	gif	- If set, redirect to the Z buffer and then read into a GIF file
;	cmds	- If set, EXECUTE the command strings (allows the execution
;		  of subroutines to do secondary displaying)
;	footnotes- A string array of items to display under the image (only
;		   good for code 0 and code 1.
;	ppinch	- Pixels per inch value to use with TV2
;			Sample:  X = 7.0 inch max for 600 pixel = 85.7 ppinch
;				 Y = 9.5 inch max for 800 pixel = 84.2 ppinch
;		  When adjusting sizes with XSIZE and YSIZE, it will take the largest ppinch
;		  to make sure the other dimension fits.
;		  For LPARL, the codonics color printer wants ppinch = 90 to fix
;		  (because of reduced page size)
;	gamma	- Adjust the color table by this value if passed
;HISTORY:
;	Written 22-Apr-96 by M.Morrison
;	23-Apr-96 (MDM) - Added AXIS2 option and enabled labeling the bar for code 12
;	15-May-96 (MDM) - Added msubtit2
;	15-May-96 (MDM) - Added option 40
;	 1-Aug-96 (MDM) - Added COMPASS and GIF options
;	21-Oct-96 (MDM) - Expanded SIGMA option to codes 0 and 1
;	24-Oct-96 (MDM) - Added WINDOW option
;			- Modified so that SMIN/SMAX were not defined
;			  and passed out (when not passed in)
;	 6-Nov-96 (MDM) - Put 24-Oct mods online
;			- Replaced "set_plot,'ps'" with setps
;	21-Nov-96 (MDM) - Added FOOTNOTES
;	10-Jun-97 (MDM) - Added code 100
;	13-Jun-97 (MDM) - Added code 104 and keywords xcorner,ycorner,land
;	25-Jun-97 (MDM) - Added ppinch and gamma
;        9-Nov-06 S.L.Freeland - elevate->ssw-gen for xdisp_fits.pro 
;-
;
;;on_error, 2
if (n_elements(code0) eq 0) then begin
    print, '=  0 for just a single image with titles
    print, '=  1 for a single image with a color bar
    print, '= 10 for single image shown twice with 3 plots
    print, '= 11 for two separate images being passed in, with 3 plots
    print, '= 12 for two separate images being passed in, no plots
    print, '= 20 for single image with plot
    print, '= 40 for four image display with color bar
    print, '=100 for NxN images (put in images as data cube)
    print, '=104 for 2x2 images (put in images as img1,img2,img3,img4)
    return
end
;
if (n_elements(img1) eq 0) then message, 'IMG1 input must be defined'
code = code0
;
if (keyword_set(std_foot)) then begin
    foot1 = 'SOI / MDI'
    foot2 = 'Stanford Lockheed Institute for Space Research'
end
if (n_elements(color) eq 0) then color = 0
if (n_elements(print_color) eq 0) then print_color = color
if (n_elements(titn0) eq 0) then titn0 = ''
if (n_elements(subtitn0) eq 0) then subtitn0 = ''
;
log_hist = keyword_set(log_hist)
if (n_elements(mask_ss) eq 0) then img1a = img1 $
		else img1a = img1(mask_ss)
if (n_elements(img2) ne 0) then if (n_elements(mask_ss) eq 0) then img2a = img2 $
		else img2a = img2(mask_ss)
;
if (n_elements(smin0) ne 0) then smin = smin0
if (n_elements(smax0) ne 0) then smax = smax0
;
if (keyword_set(sigma)) then begin	;MDM added 21-Oct-96
    idev1 = stdev(img1a, iavg1)
    smin = iavg1-sigma*idev1
    smax = iavg1+sigma*idev1
end
;
if (n_elements(smin) eq 0) then smin = min(img1a)
if (n_elements(smin) le 1) and (n_elements(img2) ne 0) then smin = [smin, min(img2a)]
if (n_elements(smin) le 2) and (n_elements(img3) ne 0) then smin = [smin, -999.99]
if (n_elements(smin) le 3) and (n_elements(img4) ne 0) then smin = [smin, -999.99]
if (n_elements(smax) eq 0) then smax = max(img1a)
if (n_elements(smax) le 1) and (n_elements(img2) ne 0) then smax = [smax, max(img2a)]
if (n_elements(smax) le 2) and (n_elements(img3) ne 0) then smax = [smax, -999.99]
if (n_elements(smax) le 3) and (n_elements(img4) ne 0) then smax = [smax, -999.99]
;
if (code eq 10) then begin
    img2 = img1		;same image as the input
    if (n_elements(sigma) eq 0) then sigma = 1
    idev1 = stdev(img1a, iavg1)
    smin = [smin(0), iavg1-sigma*idev1]
    smax = [smax(0), iavg1+sigma*idev1]
    code = 11
    subtit2 = '+/- ' + strtrim(sigma,2) + ' sigma'
end
;
if (n_elements(imin) eq 0) then imin = smin(0)
if (n_elements(imax) eq 0) then imax = smax(0)
if (n_elements(nlab) eq 0) then nlab = 6
nlab = [nlab, replicate(nlab(0),4)]	;make sure the array is long enough
;
if (n_elements(outfil) eq 0) then outfil = 'idl.ps'
;
qgif = keyword_set(gif)
if (keyword_set(hc)) then setps
if (!d.name eq 'PS') then device, file=outfil
if (qgif) then begin
    set_plot, 'Z'
    if (n_elements(loadct) eq 0) then loadct, 0
end
if (keyword_set(fix_font) and (!d.name eq 'X')) then device, font=get_xfont(closest=13, /only_one)
if (n_elements(loadct) ne 0) then loadct, loadct
if (n_elements(gamma) ne 0) then gamma_ct, gamma
;
nx1 = n_elements(img1(*,0))
ny1 = n_elements(img1(0,*))
scale1a = (512./nx1) < (512./ny1)
scale1b = (200./nx1) < (200./ny1)
scale1c = (330./nx1) < (330./ny1)
if (n_elements(img2) ne 0) then begin
    nx2 = n_elements(img2(*,0))
    ny2 = n_elements(img2(0,*))
    scale2a = (512./nx1) < (512./ny1)
    scale2b = (200./nx2) < (200./ny2)
    scale2c = (330./nx2) < (330./ny2)
end
;
erase
case code of
    0: begin
	    if (n_elements(xsize) eq 0) then xsize = 512
	    if (n_elements(ysize) eq 0) then ysize = 650
	    ;
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, window=window, ppinch=ppinch
	    ;tv2, img1, 0, 50
	    tv2, bytscl(congrid(img1, nx1*scale1a, ny1*scale1a,/interp), smin(0), smax(0), top=!d.n_colors-1), 0, 50
	end
    1: begin
	    if (n_elements(xsize) eq 0) then xsize = 512
	    if (n_elements(ysize) eq 0) then ysize = 700
	    ;
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, window=window, ppinch=ppinch
	    ;tv2, img1, 0, 100
	    tv2, bytscl(congrid(img1, nx1*scale1a, ny1*scale1a,/interp), smin(0), smax(0), top=!d.n_colors-1), 0, 100

	    mk_refbar, 50, 60, imin, imax, nlab=nlab(0), fmt=fmt, xsiz=412, ysiz=30, /horiz
	    if (keyword_set(axis1)) then xyouts2, xsize/2, 35, axis1, align=0.5, size=1.2
	end
    11: begin
	    if (n_elements(xsize) eq 0) then xsize = 700
	    if (n_elements(ysize) eq 0) then ysize = 512
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, /land, window=window, ppinch=ppinch
	    ;
	    h = histogram(img1a)
            nh = n_elements(h)
            x = findgen(nh) + min(img1a)
	    ;
	    tv2, bytscl(congrid(img1, nx1*scale1b, ny1*scale1b,/interp), smin(0), smax(0), top=!d.n_colors-1), 0, 230
	    mk_refbar, 210, 230, smin(0), smax(0), nlab=nlab(0), fmt=fmt, xsiz=30, ysiz=200
	    idev1 = stdev(img1a, iavg1)
	    xyouts2, 580, 400-1*10, 'Avg: ' + string(iavg1, format=fmt)
	    xyouts2, 580, 400-2*14, 'Dev: ' + string(idev1, format=fmt)
	    xyouts2, 580, 400-3*14, 'Min: ' + string(min(img1a), format=fmt)
	    xyouts2, 580, 400-4*14, 'Max: ' + string(max(img1a), format=fmt)
	    if (n_elements(img2) ne 0) then begin
		tv2, bytscl(congrid(img2, nx2*scale2b, ny2*scale2b,/interp), smin(1), smax(1), top=!d.n_colors-1), 290, 230
		mk_refbar, 500, 230, smin(1), smax(1), nlab=nlab(1), fmt=fmt, xsiz=30, ysiz=200
		if (code0 ne 10) then begin
	            idev2 = stdev(img2a, iavg2)
	            xyouts2, 580, 300-1*10, 'Avg: ' + string(iavg2, format=fmt)
	            xyouts2, 580, 300-2*14, 'Dev: ' + string(idev2, format=fmt)
	            xyouts2, 580, 300-3*14, 'Min: ' + string(min(img2a), format=fmt)
	            xyouts2, 580, 300-4*14, 'Max: ' + string(max(img2a), format=fmt)
		end
	    end
	    ;
	    if (keyword_set(tit1)) then    xyouts2, 100, 450, align=0.5, tit1, size=1.2
	    if (keyword_set(subtit1)) then xyouts2, 100, 432, align=0.5, subtit1, size=1.0
	    if (keyword_set(tit2)) then    xyouts2, 390, 450, align=0.5, tit2, size=1.2
	    if (keyword_set(subtit2)) then xyouts2, 390, 432, align=0.5, subtit2, size=1.0
	    ;
	    dx = .22
	    dy = .30
	    plot, x, h>.1,       /noerase, psym=10, ytype=log_hist, position=[.08, .1, .08+dx, .1+dy], ytit='Histogram'
	    if (keyword_set(avg)) then begin
		plot, total(img1,1)/ny1, /noerase, /xstyle, /ynozero, position=[.40, .1, .40+dx, .1+dy], ytit='All line average'
		plot, total(img1,2)/nx1, /noerase, /xstyle, /ynozero, position=[.72, .1, .72+dx, .1+dy], ytit='All column average'
	    end else begin
		plot, img1(*,ny1/2), /noerase, /xstyle,     /ynozero, position=[.40, .1, .40+dx, .1+dy], ytit='Center line'
		plot, img1(nx1/2,*), /noerase, /xstyle,     /ynozero, position=[.72, .1, .72+dx, .1+dy], ytit='Center column'
	    end
	end
    12: begin
	    if (n_elements(xsize) eq 0) then xsize = 700
	    if (n_elements(ysize) eq 0) then ysize = 512
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, /land, window=window, ppinch=ppinch
	    ;
	    tv2, bytscl(congrid(img1, nx1*scale1c, ny1*scale1c,/interp), smin(0), smax(0), top=!d.n_colors-1), 0, 100
	    mk_refbar, 0, 60, smin(0), smax(0), nlab=nlab(0), fmt=fmt, xsiz=330, ysiz=30, /horiz
	    if (keyword_set(axis1)) then xyouts2, 165, 35, axis1, align=0.5, size=1.2
	    if (n_elements(img2) ne 0) then begin
		tv2, bytscl(congrid(img2, nx2*scale2c, ny2*scale2c,/interp), smin(1), smax(1), top=!d.n_colors-1), 360, 100
		mk_refbar, 360, 60, smin(1), smax(1), nlab=nlab(1), fmt=fmt, xsiz=330, ysiz=30, /horiz
	        if (keyword_set(axis2)) then xyouts2, 525, 35, axis2, align=0.5, size=1.2
	    end
	    ;
	    if (keyword_set(tit1)) then    xyouts2, 165, 450, align=0.5, tit1, size=1.2
	    if (keyword_set(subtit1)) then xyouts2, 165, 432, align=0.5, subtit1, size=1.0
	    if (keyword_set(tit2)) then    xyouts2, 535, 450, align=0.5, tit2, size=1.2
	    if (keyword_set(subtit2)) then xyouts2, 535, 432, align=0.5, subtit2, size=1.0
	end
    20: begin
	    if (n_elements(xsize) eq 0) then xsize = 512
	    if (n_elements(ysize) eq 0) then ysize = 650
	    if (n_elements(xarr) eq 0) then message, 'XARR must be defined'
	    if (n_elements(yarr) eq 0) then message, 'YARR must be defined'
	    if (n_elements(xrange) eq 0) then xrange = [min(xarr), max(xarr)]
	    if (n_elements(yrange) eq 0) then yrange = [min(yarr), max(yarr)]
	    if (n_elements(xtit) eq 0) then xtit = ''
	    if (n_elements(ytit) eq 0) then ytit = ''
	    if (n_elements(mtit_plot) eq 0) then mtit_plot = ''
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, window=window, ppinch=ppinch
	    ;
	    tv2, bytscl(congrid(img1, nx1*scale1c, ny1*scale1c,/interp), smin(0), smax(0), top=!d.n_colors-1), 50, 300
	    mk_refbar, 400, 300, smin(0), smax(0), nlab=nlab(0), fmt=fmt, xsiz=30, ysiz=330
	    plot, xarr, yarr, xrange=xrange, yrange=yrange, xtit=xtit, ytit=ytit, tit=mtit_plot, $
			/noerase, /ynozero, position=[.15, .1, .9, .38]
	end
    40: begin
	    if (n_elements(xsize) eq 0) then xsize = 700
	    if (n_elements(ysize) eq 0) then ysize = 540
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, /land, window=window, ppinch=ppinch

	    disp1gen,   0, 260, 200, img1, mask_ss, smin(0), smax(0), tit1, subtit1, /vbar,  nlab=nlab(0), fmt=fmt, /mmad_lab
	    disp1gen, 350, 260, 200, img2, mask_ss, smin(1), smax(1), tit2, subtit2, /vbar,  nlab=nlab(1), fmt=fmt, /mmad_lab
	    disp1gen,   0,  30, 200, img3, mask_ss, smin(2), smax(2), tit3, subtit3, /vbar,  nlab=nlab(2), fmt=fmt, /mmad_lab
	    disp1gen, 350,  30, 200, img4, mask_ss, smin(3), smax(3), tit4, subtit4, /vbar,  nlab=nlab(3), fmt=fmt, /mmad_lab
	end
     100: begin
	    if (n_elements(xsize) eq 0) then xsize = 600
	    if (n_elements(ysize) eq 0) then ysize = 800
	    tv2, xsize, ysize, /init, /hwfont, color=color, /already, window=window, ppinch=ppinch
	    n = n_elements(img1(0,0,*))
	    nsqrt = ceil(sqrt(n))
	    nout0 = xsize/nsqrt
	    nout = nout0 - 10	;10 pixel margin between images left/right

	    if (n_elements(smin0) eq n) then smin=smin0 else smin=replicate(smin(0),n)
	    if (n_elements(smax0) eq n) then smax=smax0 else smax=replicate(smax(0),n)
	    if (n_elements(titn0) eq n) then titn=titn0 else titn=replicate(titn0(0),n)
	    if (n_elements(subtitn0) eq n) then subtitn=subtitn0 else subtitn=replicate(subtitn0(0),n)
	    for i=0,n-1 do begin
		x0 = (i mod nsqrt)*nout0
		y0 = (nsqrt-1-(i/nsqrt))* (nout0+25) + 50	;extra 25 pixel margin for label
		disp1gen, x0, y0+25, nout, img1(*,*,i), mask_ss, smin(i), smax(i), titn(i), subtitn(i), /below
	    end
	end
     104: begin
	    if (not keyword_set(land)) then begin
		if (n_elements(xsize) eq 0) then xsize = 600
		if (n_elements(ysize) eq 0) then ysize = 800
		tv2, xsize, ysize, /init, /hwfont, color=color, /already, window=window, ppinch=ppinch
	    end else begin
		if (n_elements(xsize) eq 0) then xsize = 800
		if (n_elements(ysize) eq 0) then ysize = 600
		tv2, xsize, ysize, /init, /hwfont, color=color, /already, window=window, /land, ppinch=ppinch
	    end
	    nout = 290
	    x0 = 0 & x1 = 300
	    if (keyword_set(xcorner)) then begin & x0 = xcorner(0) & x1 = xcorner(1) & end
	    y0 = 50 & y1 = 375
	    if (keyword_set(ycorner)) then begin & y0 = ycorner(0) & y1 = ycorner(1) & end

	    disp1gen,  x0, y1, nout, img1, mask_ss, smin(0), smax(0), tit1, subtit1, /below
	    disp1gen,  x1, y1, nout, img2, mask_ss, smin(1), smax(1), tit2, subtit2, /below
	    disp1gen,  x0, y0, nout, img3, mask_ss, smin(2), smax(2), tit3, subtit3, /below
	    disp1gen,  x1, y0, nout, img4, mask_ss, smin(3), smax(3), tit4, subtit4, /below
	  end
     else: begin
	    message,'Code Option Not Recognized.  CODE='+strtrim(code,2),/info
	    return
	end
endcase
;
if (keyword_set(compass)) then begin
    x0 = 10
    y0 = 30
    len = 25
    plots2, [len, 0, 0]+x0, [0, 0, len]+y0, /dev
    xyouts2, x0+len+2, y0-2, 'W', /dev
    xyouts2, x0-3, y0+len+2, 'N', /dev
end
;
for i=0,n_elements(cmds)-1 do stat = execute(cmds(i))
;
;---- Titles and footnotes
;
if (keyword_set(mtit)) then    xyouts2, xsize/2, ysize-25, align=0.5, mtit, size=2.2
if (keyword_set(msubtit)) then xyouts2, xsize/2, ysize-50, align=0.5, msubtit, size=1.2
if (keyword_set(msubtit2)) then xyouts2, xsize/2, ysize-65, align=0.5, msubtit2, size=1.0
if (keyword_set(foot1)) then xyouts2, 0, 4, foot1, size=1.4
if (keyword_set(foot2)) then xyouts2, xsize, 4, foot2, align=1, size=1.
if (keyword_set(date)) then  xyouts2, xsize*.2, 0, size=0.9, ut_time() + ' UT'

ncol = 3
nlin = 4
for i=0,n_elements(footnotes)-1 do $
	xyouts2, i/nlin*512/ncol, 50-((i mod nlin)+1) * 7, footnotes(i), size=0.7

if (!d.name eq 'PS') then device, /close
if (!d.name eq 'X') then wshow
if (keyword_set(hc)) then begin
    pprint, color=print_color
    set_plot, 'x
end
if (qgif) then zbuff2file, gif
;
end
