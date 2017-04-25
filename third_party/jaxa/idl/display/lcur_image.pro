pro lcur_image, index, data, lcur, uncert, satpix, $
	nodisplay=nodisplay, bin=bin, xsize=xsiz, ysize=ysiz, $
	normalize=normalize, nonormalize=nonormalize, total_cnts=total_cnts, $
	ynozero=ynozero, qdebug=qdebug, qstop=qstop, $
	subscript=subscript, lastss=lastss, marks=marks, noscale=noscale, plot6=plot6, $
	polygon_mark=polygon_mark, nodel_win_p=nodel_win_p, $
	avg_uncert=avg_uncert, info_array=info_array
;
;+
;NAME:
;	lcur_image
;PURPOSE:
;	To display a normalized light curve plot for image data.  The user
;	can select the portion of the image to be averaged.
;EXPLANATION:
;	If UNCERT and SATPIX are passed in, then certain data points will
;	be flagged with a different plot symbol.  The symbols are:
;                       for average uncert > 0.25%      - value = 4 (diamond)
;                       for any sat pixel in region     - value = 5 (triangle)
;                       for over 25% sat pix in region  - value = 2 (astrix)
;SAMPLE CALLING SEQUENCE:
;	lcur_image, index, data
;	lcur_image, index, data, lcur
;	lcur_image, index, data, lcur, uncert, satpix
;	lcur_image, index, data, xsiz=512
;	lcur_image, index, data, xsiz=512, /poly
;	lcur_image, index, data, xsiz=512, /nonorm, subscript=subscript
;	lcur_image, index, data, lcur, uncert, satpix, avg_uncert=avg_uncert
;INPUT:
;	index	- The index structure
;	data	- The data array.  It should alreay have been background
;		  subtracted in order to display proper light curves
;		  to be DN/sec (for SXT images, call SXT_PREP with /normalize)
;		  Data could be exposure normalized coming in or else it
;		  will normalize it for you (if it is SXT image data)
;OUTPUT:
;	lcur	- The light curve results in a 2-D array with is N x M
;		  where N is the number of images, and M is the number of
;		  different light curves.
;OPTIONAL INPUT:
;	uncert	- The uncertainty array (output from SXT_PREP).  
;		  If the uncertainy array is passed, then the routine will 
;		  flag points which have a large uncertainty.
;	satpix	- The saturated pixel map array (output from SXT_PREP)
;		  If the saturated pixel array is passed, then the routine will 
;		  flag points which are saturated
;OPTIONAL KEYWORD INPUT:
;	normalize - If set, the images being passed in have been background
;		  subtracted, but not normalized.  The counts being displayed
;		  will be exposure normalized before being displayed.
;		  This is the default as of 30-Nov-93 for SXT inputs.
;	nonormalize - If set, the images will not be exposure normalized.
;	total_cnts - If set, the display will be the total counts in the
;		  region (not the average which is default)
;	nodisplay - If set, then do not display a copy of the image
;		    using stepper (it is already displayed)
;	bin	- If /NODISPLAY is used, then this routine needs to know if
;		  the image was rebinned when displayed.  This is the rebinning
;		  factor.
;	xsiz	- Bin the output image to this size when displaying it
;	ysiz	- Bin the output image to this size when displaying it
;	subscript - The list of subscripts of the images to use.  If not passed
;		  it will use all images.
;	lastss	- The image number of the image that is displayed (normally used
;		  with the /nodisplay option)
;	noscale	- If set, do not auto scale the image (passed down to STEPPER)
;	plot6	- If set, then plot 6 panels
;	polygon_mark - If set, then use the polygon method for marking regions
;	nodel_win_p - If set, do not delete the window with the light curve plot
;       info_arrray - optional text array for image labels (1 per image)
;
;OPTIONAL KEYWORD OUTPUT:
;	marks	- The subscripts within the image that were selected.  The
;		  output array is NxM where N is the largest number of subscripts
;		  that were selected in a region, and M is the number of
;		  different regions selected.  When padding is necessary, the
;		  value is set to -1, so that value needs to be avoided.
;	avg_uncert - The average uncertainty calculated and used to display
;		  the error bars.
;HISTORY:
;	Written 16-Oct-93 by M.Morrison to replace BOX_LC
;	19-Oct-93 (MDM) - Adjusted the header information some
;			- Made many changes (added labeling of regions selected)
;	25-Oct-93 (MDM) - Corrected menu ("A" was supposed to be "R")
;			- Added subscript=subscript parameter to "m" option plot
;			- Added /NOSCALE option (passed to STEPPER)
;	26-Oct-93 (MDM) - Added /PLOT6 option (6 panel plots)
;	29-Nov-93 (MDM) - Added /NOLCUR switch to call to STEPPER
;			- Passed the index to stepper
;			- Added /POLYGON_MARK option
;	30-Nov-93 (MDM) - Made /NORMALIZE the default.  Added /NONORMALIZE.
;	20-Jan-94 (MDM) - Fixed typo in menu list
;	16-Feb-95 (MDM) - Added option to display the regions over an image, 
;			  not a contour image
;	28-Feb-95 (MDM) - Modified to plot error bars on uncertainty passed in
;			- Added some header information
;	 7-Mar-95 (MDM) - Added AVG_UNCERT as optional keyword output
;       10-aug-99 S.L.Freeland - added some 'info_array' derivation for non-SXT
;                 Permit compilation without SXT in SSW path
;                 Use 'data_chk' for nx,ny,nimage to improve efficiency
;-
n  = data_chk(data,/nim)
if n lt 2 then begin 
   box_message,["Fewer than 2 images - just does not make sense...", $
                "IDL> lcur_image, index, data [info_array=info] [...]"]
   return
endif
nx = data_chk(data,/nx)
ny = data_chk(data,/ny)
;
if (n_elements(xsiz) eq 0) then xsiz = nx	;no rebinning
if (n_elements(bin) eq 0) then bin = xsiz/nx	;what about Y binning size - check if same as x (?)
if (n_elements(lastss) eq 0) then lastss = 0
qsat = (n_elements(satpix) gt 10)
;
if (keyword_set(nodisplay)) then win_i = !d.window
;;if (n_elements(win_i) eq 0) then wdef, win_i, /free, /ur
if (!d.window eq -1) then wdef, win_i, /free, /ur else win_i = !d.window
wdef, win_p, /free, /ul
;
mark_method = 'RECT'
if (keyword_set(polygon_mark)) then mark_method = 'POLY'
;
qnorm = 1		;default is to normalize
if (keyword_set(nonormalize)) then qnorm = 0
if (max(strpos(tag_names(index), 'SXT')) eq -1) then qnorm = 0		;not an SXT index being passed in
;
savesys, /aplot
qprint = 1
qfirst = 1
qdone = 0
nout = 0
qoplot = 0
q6plots = 0
qas_image = 0
if (keyword_set(plot6)) then begin
    q6plots = 1
    !p.multi = [0,2,3]
    !p.charsize = 1.6
end
ref_ed = ['DISABLED', 'ENABLED']

case 1 of
   n_elements(info_array) eq n and data_chk(info_array,/string):    ; user
   required_tags(index,'gen,sxt'): $
             exestat=execute('info_array=get_info(index,/non)')     ; SXT
   required_tags(index,'date_obs,wave_len,xcen,ycen,naxis1,naxis2'): $
		  info_array=get_infox(index,'date_obs,wave_len,xcen,ycen,naxis1,naxis2')
   required_tags(index,'time,day') or required_tags(index,'time,mjd'): $
		  info_array=anytim(index,/ecs,/truncate)
   else: info_array='Image# ' + strtrim(indgen(n),2)
endcase

while (not qdone) do begin
    if (qprint) then begin
	print, '-------- LCUR_IMAGE Options --------
	print, 'Enter "p" to mark and plot light curves (loops until exited)
	print, '      "m" to overplot all of the selected light curves
	print, '      "r" to display the regions selected ("R" to make a hardcopy)
	print, '      "s" to change the method to mark regions to plot.  Currently: ' + mark_method
	print, '      "d" to call "stepper" to refresh/display a new image
	if (qsat) then print, '      "S" to call "stepper" with the saturation pixel array
	print, '      "z" to reset (zero out) all of the regions saved so far
	print, '      "o" to enable/disable over plotting of new curves. Currently: ' + ref_ed(qoplot)
	print, '      "6" to enable/disable making 6 window plots.  Currently:      ' + ref_ed(q6plots)
	print, '      "i" to enable/disable displaying regions on image. Currently: ' + ref_ed(qas_image)
	print, '      "h" to produce a hard copy of the most recent light curve
	print, '      "H" to produce a hard copy of all selected light curves
	print, '      "q" to exit LCUR_IMAGE ("x" will work too)
	print, 'Enter your option (no return required).  It is case sensitive.
    end

    if (qfirst) then begin
	if (keyword_set(nodisplay)) then ans = 'p' else ans = 'd'
    end else begin
	ans = get_kbrd2(1)
    end

    case ans of
	'p': begin
		print, 'LCUR_IMAGE: Selecting region to plot light curve

		qdone2 = 0
		while (not qdone2) do begin
		    marks0 = lcur_region(win_i, mark_method, nx*bin, ny*bin, nout, qdone=qdone2, bin=bin)
		    if (marks0(0) ne -1) then begin
			lcur0 = lcur_calc(index, data, marks0, uncert, satpix, plotmark0, avg_uncert0, $
						normalize=qnorm, total_cnts=total_cnts)
			lcur_plot, win_p, index, lcur0, plotmark0, avg_uncert0, ynozero=ynozero, $
						subscript=subscript, qoplot=(qoplot and (nout ne 0)), ioff=nout
			if (nout eq 0) then begin
			    lcur = lcur0
			    plotmark = plotmark0
			    marks = marks0
			    if (n_elements(avg_uncert0) ne 0) then avg_uncert = avg_uncert0
			    nout = 1
			end else begin
			    lcur = [[lcur],[lcur0]]
			    plotmark = [[plotmark],[plotmark0]]
			    if (n_elements(avg_uncert0) ne 0) then avg_uncert = [[avg_uncert],[avg_uncert0]]
			    n1 = n_elements(marks(*,0)) 
			    n2 = n_elements(marks(0,*)) 
			    n0 = n_elements(marks0)
			    if (n1 gt n0) then begin
				temp = [marks0, intarr(n1-n0)-1]
				marks = [[marks],[temp]]
			    end else begin
				temp = lonarr(n0,n2)-1
				temp(0,0) = marks
				marks = [[temp],[marks0]]
			    end
			    nout = nout + 1
			end

		    end
		end
		qfirst = 0
	     end
	'r': begin
		if (n_elements(win_a) eq 0) then wdef, win_a, /free, /lr else wset, win_a
		lcur_plotr, data(*,*,lastss), marks, index(lastss), qas_image=qas_image, xsiz=xsiz, ysiz=ysiz
	     end
	'R': begin
		set_plot,'ps
		device, /land
		lcur_plotr, data(*,*,lastss), marks, index(lastss), qas_image=qas_image, xsiz=xsiz, ysiz=ysiz
		pprint, /reset
	     end
	'm': begin
		!p.multi(0) = 0		;start with a new window
		if (nout ne 0) then lcur_plot, win_p, index, lcur, plotmark, avg_uncert, $
								ynozero=ynozero, subscript=subscript
	     end
	's': begin
		!p.multi(0) = 0		;start with a new window
		print, 'LCUR_IMAGE: Selecting method for marking the region 
		mark_method = lcur_region(/select)
	     end
	'z': begin
		!p.multi(0) = 0		;start with a new window
		nout = 0
	     end
	'd': begin
		print, 'LCUR_IMAGE: Calling "stepper" to display the images. 
		print, 'LCUR_IMAGE: Type "q" to exit "stepper" and to return to "lcur_image"
		wset, win_i
		wshow, win_i
		stepper, index, data, info_array, xsiz=xsiz, ysiz=ysiz, subscript=subscript, lastss=lastss, noscale=noscale, /nolcur

		nodisplay = 1			;so that it will automatically go to the selection/plotting
	     end
	'S': if (qsat) then begin
		print, 'LCUR_IMAGE: Calling "stepper" to display the saturation images. 
		print, 'LCUR_IMAGE: Type "q" to exit "stepper" and to return to "lcur_image"

		wset, win_i
		wshow, win_i
		stepper, satpix, info_array, xsiz=xsiz, ysiz=ysiz, subscript=subscript, lastss=lastss, /nolcur

		nodisplay = 1			;so that it will automatically go to the selection/plotting
	     end else begin
		tbeep, 3
		print, 'LCUR_IMAGE: You must pass in the SATPIX array in order to use this option
	     end
	'h': begin
		!p.multi(0) = 0		;start with a new window
		set_plot, 'ps'
		device, /land
		lcur_plot, win_p, index, lcur0, plotmark0, avg_uncert0, ynozero=ynozero
		pprint, /reset
	     end
	'H': begin
		!p.multi(0) = 0		;start with a new window
		set_plot, 'ps'
		device, /land
		lcur_plot, win_p, index, lcur, plotmark, avg_uncert, ynozero=ynozero
		pprint, /reset
	     end
	'*': stop
	'o': qoplot = abs(1-qoplot)
	'i': qas_image = abs(1-qas_image)
	'6': begin
		q6plots = abs(1-q6plots)
		if (q6plots) then begin
		    !p.charsize = 1.6
		    !p.multi=[0,2,3]
		end else begin
		    !p.charsize = 0
		    !p.multi=0
		end
	     end
	'q': qdone = 1
	'x': qdone = 1
	else: begin
		tbeep
		print, 'Command option not recognized.  Key entered was: ' + ans
	      end
    endcase
end
;
if (keyword_set(qstop)) then stop
restsys, /aplot
if (n_elements(win_a) ne 0) then wdelete, win_a
if (not keyword_set(nodel_win_p)) then wdelete, win_p
end
