pro xdisp_fits_event, event
;
;
;
common xdisp_fits_blk1b, infil, dir, files, images, h, img, img2, dirarr, tit
common xdisp_fits_blk2a, ssmin, ssmax, ssigma, quse_sminmax
common xdisp_fits_blk3, bkg, bkg_fil
common xdisp_fits_blk4c, comment, align_comm, max_cross_corr, cross_smoo, fmedian_width
common xdisp_fits_blk5b, img3, logfil
common xdisp_fits_blk6b, h_info, h_lab_info
common xdisp_fits_blk7a, sum_fact
common xdisp_fits_blk8, giffile
common xdisp_fits_blk9, comment2	;median filter
;
qdebug = (getenv('QDEBUG') ne '')
if (qdebug) then print, event_name(event)
if (qdebug) then help, smin, smax, sigma
if (qdebug) then help, ssmin, ssmax, ssigma
widget_control,event.top,get_uvalue=all
if (qdebug) then help, /st, all
;
nx = n_elements(img3(*,0))
ny = n_elements(img3(0,*))
;
quse_sminmax = keyword_set(quse_sminmax)
qreset    = 0
qlist_dir = 0
qdisp_img = 0
qextract  = 0
case (strtrim(event_name(event),2)) of
   ;----------------- Button Events ------------------------
   "BUTTON":begin                               ; option selection
      case strupcase(get_wvalue(event.id)) of
	 ;------ Main buttons
         "QUIT": begin
		widget_control, event.top,/destroy
	    end
	 "SET DIRECTORY": begin
		xmenu_gen_input, 'Enter new directory:', dir, nchar=30, group=event.top
		qlist_dir = 1
	    end
	 "SET PRINTER": set_printer
	 "PRINT HEADER": if (n_elements(h_info) gt 1) then begin
		prstr, h_info, file = '$HOME/xdisp_fits.header'
		pprint, '$HOME/xdisp_fits.header', /force
	    end else begin
		tbeep, 3
		print, '** No header available'
	    end
         "LIST DIRECTORY": begin
                qlist_dir = 1
            end
         "SEL DIR FROM ARRAY": begin
		if (dirarr(0) ne '') then begin
		    ss = xmenu_sel(dirarr, group=event.top)
		    if (ss(0) ne -1) then dir = dirarr(ss)
            	    qlist_dir = 1
		end else begin
		    print, 'No directory array to choose from'
		end
            end
	 "CREATE A NEW WINDOW": begin
		wdef, next_window(/user)
	    end
	 "HARDCOPY": begin
		hc = 1
		qdisp_img = 1
	    end
	 "SAVE2GIF": begin
		xmenu_gen_input, 'Enter GIF filename:', giffile, nchar=60, group=event.top
		if (giffile ne '') then begin
		    qgif = 1
		    qdisp_img = 1
		    set_plot,'Z'
		end
	    end
	 "REDISPLAY IMAGE": qdisp_img = 1
	 "REDISPLAY ORIG IMAGE": begin
		qdisp_img = 1
		img3 = img2
		tit = infil
		align_comm = ''
	        all.e_str = ''
		comment2 = ''
	    end
	 "SET IMAGE MIN/MAX": begin
		xmenu_gen_input, 'Scale', ssmin, ssmax, label=['Min:', 'Max:'], group=event.top
		quse_sminmax = 1
	    end
	 "RESET IMAGE MIN/MAX AND SIGMA": begin
		widget_control, all.id_smin, set_value=' '
		widget_control, all.id_smax, set_value=' '
		widget_control, all.id_sig, set_value=' '
		quse_sminmax = 0
		ssigma = '0'
	    end
	 "SET SIGMA": begin
		xmenu_gen_input, 'Sigma Value (0 to reset)', ssigma, group=event.top
		print, 'SSIGMA: ', ssigma
	    end
	 "RUN PROFILES": begin
		;not the best way to do this - very dangerous in fact
		junk = fltarr(512, 512+50)
		nnnx = n_elements(img3(*,0))
		nnny = n_elements(img3(0,*))
		pscale = (512./nnnx) < (512./nnny)
		junk(0,50) = congrid(img3, nnnx*pscale, nnny*pscale)
		nnn = n_elements(img2(*,0))
		factor = n_elements(img3(*,0))/512.
		if (all.e_n ne 0) then factor = all.e_n * sum_fact / 512
		if (n_elements(img3) gt 2) then profiles, junk, factor=factor, $
					x0=all.e_x0*sum_fact, y0=(all.e_y0*sum_fact-50*factor)
	    end
	 "SAVE TO FITS": begin
		if (n_elements(img3) gt 1) then begin
		    infil0 = file_list(dir, infil)
		    infil0 = infil0(0)
		    outfil = str_replace(infil0, '.fits', '_USER.fits')
		    xmenu_gen_input, 'Output File:', outfil, nchar=100, group=event.top
		    if (file_exist(outfil)) then begin
			print, outfil, ' exists.  No save performed'
			tbeep, 3
		    end else begin
			fxhmake, header, img3, /extend, /initialize
			fxaddpar, header, 'FILE_IN', infil0(0)
			fxaddpar, header, 'FILE_BKG', bkg_fil(0)
			fxaddpar, header, 'FILE_OUT', outfil
			fxaddpar, header, 'EXTRACT', all.e_str
			print, 'Saving: ', outfil
			tr_wrt_fits, outfil, header, img3, head
		    end
		end else begin
		    tbeep, 3
		    print, "No image selected"
		end		
	     end
		

	 "DISPLAY SIMPLE IMAGE": all.style = 0
	 "DISPLAY AS IMG_SUMMARY": all.style = 1

	 "COPY IMG TO BKG BUFF": begin
		bkg = img2
		break_file, infil, dsk_log, dir00, filnam, ext
		bkg_fil = filnam + ext
		widget_control, all.id_bkg, set_value=bkg_fil
	    end
	 "CLEAR BKG BUFF": begin
		bkg = 0
		widget_control, all.id_bkg, set_value=' '
	    end
	 "DO BKG SUBTRACTION": begin
		if (n_elements(bkg) gt 1) then begin
		    tit = infil + '  MINUS  ' + bkg_fil
		    img3 = img2 - bkg
		    qextract = 1
		    qdisp_img = 1
		    align_comm = ''
		end else begin
		    tbeep, 3
		    print, "No background image selected"
		end
	    end
	 "MEDIAN FILTER": begin
		if (n_elements(img3) gt 1) then begin
		    mapx, event.top,/map,/show,sensitive=0
		    img3 = fmedian(img3, fmedian_width)
		    mapx, event.top,/map,/show,sensitive=1
		    comment2 = 'Median Filter (width = ' + strtrim(fmedian_width,2) + ')'
		    qdisp_img = 1
		end else begin
		    tbeep, 3
		    print, "No image selected"
		end		
	     end
		
	 "BOX STATS": begin
		if (n_elements(img3) gt 1) then begin
		    box_cursor, x0, y0, nnx, nny
		    y0 = (y0 - 50)>0
		    factor = n_elements(img3(*,0))/512.
		    nout = nnx<nny		;take the smaller of the two
		    x00 = fix(x0 * factor)
		    x11 = fix(x00 + nnx*factor) -1
		    y00 = fix(y0 * factor)
		    y11 = fix(y00 + nny*factor) -1 
		    ;
		    tmp = img3(x00:x11, y00:y11)
		    idev = stdev(tmp, iavg)
		    imin = min(tmp, max=imax)
		    itot = total(tmp)
		    print, 'Min/Max:', imin, imax
		    print, 'Avg/Dev:', iavg, idev
		    print, 'Total:  ', itot
		end else begin
		    tbeep, 3
		    print, "No image selected"
		end		
	     end

	 "DO CROSS CORR": begin
		if (n_elements(bkg) gt 1) then begin
		    mapx, event.top,/map,/show,sensitive=0
		    if (all.e_n ne 0) then begin
			ix0 = all.e_x0		& ix1 = all.e_x0 + all.e_n-1
			iy0 = all.e_y0		& iy1 = all.e_y0 + all.e_n-1
			imgr2 = img2(ix0:ix1, iy0:iy1)
			imgr1 = bkg(ix0:ix1, iy0:iy1)
			extra = ''
			if (cross_smoo ne 0) then begin
			    imgr2 = smooth(imgr2, cross_smoo)
			    imgr1 = smooth(imgr1, cross_smoo)
			    extra = ' Smoo: ' + strtrim(cross_smoo,2) + ' '
			end
			;;offset = rigid_align(imgr2, imgr1, img3, rsigma, /err)
			offset = cross_corr(imgr2, imgr1, max_cross_corr, img3)
			if (getenv('QDEBUG_ALIGN') ne '') then begin
			    window, 1
			    tvscl, imgr2, 0
			    tvscl, imgr1, 1
			    tvscl, img3,  2
			    tvscl, img3-imgr1, 3
			    tvscl, imgr2-imgr1, 4
			    save, file='tom_b.idl', imgr2, imgr1
			    wset, 0
			end
			img3 = img3 - imgr1
		    end else begin
			;;offset = rigid_align(img2, bkg, img3, rsigma, /err)
			offset = cross_corr(img2, bkg, max_cross_corr, img3)
			img3 = img3 - bkg
		    end
		    ;
		    tit = infil + '  CROSS_CORR  ' + bkg_fil
		    qdisp_img = 1
		    ;align_comm = string('Xoff:', offset(0), '  Yoff:', offset(1), '  Sigmas: ', rsigma)
		    align_comm = string('Xoff:', offset(0), '  Yoff:', offset(1))
		    file_append, logfil, tit + '  ' + all.e_str + extra + '  ' + align_comm
		    widget_control, all.id_info, set_value = align_comm
		end else begin
		    tbeep, 3
		    print, "No background image selected"
		end
	    end
	  "FIND GRID": begin
		if (n_elements(img3) gt 1) then begin
		    find_grid, img3, coord, angles, vals, coeff_arr, /qplot
		    grid_comm = string('Grid X:', coord(0) + all.e_x0, $
				' Y:', coord(1) + all.e_y0, ' Angle: ', angles(0))
		    file_append, logfil, tit + '  ' + grid_comm
		    widget_control, all.id_info, set_value = grid_comm
		end else begin
		    tbeep, 3
		    print, "No image selected"
		end		
	     end
	  "EXTRACT SUB-IMAGE": begin
		print, 'Make sure the marking is made on a non-extracted image'
		box_cursor, x0, y0, nnx, nny
		y0 = (y0 - 50)>0
		nout = nnx<nny		;take the smaller of the two
		all.e_x0 = x0 * nx/512.
		all.e_y0 = y0 * ny/512.
		all.e_n  = nout * nx/512.

		qreset = 1
		qextract = 1
	    end
	  "FIXED EXTRACT": begin
		mat0 = rd_tfile('$XDISP_FITS_DBASE/extract_subimg.txt', nocomment=';')
		remtab, mat0, mat0
		mat = long(rd_tfile('$XDISP_FITS_DBASE/extract_subimg.txt', 3, nocomment=';'))
		iext = xmenu_sel(mat0, group=event.top, /one)
		if (iext ne -1) then begin
		    all.e_x0 = mat(0,iext) / sum_fact
		    all.e_y0 = mat(1,iext) / sum_fact
		    all.e_n  = mat(2,iext) / sum_fact
		    qextract = 1
		    qreset = 1
		end
	    end
	   "CLEAR EXTRACT": begin
		mapx, event.top,/map,/show,sensitive=0
		all.e_x0 = 0
		all.e_y0 = 0
		all.e_n = 0
		all.e_str = ''
		widget_control, all.id_ext, set_value=' '
		qreset = 1
		qdisp_img = 1
		align_comm = ''
	    end
          else: message,/info,"UNKNOWN BUTTON:   " + strupcase(get_wvalue(event.id))
       endcase
   endcase 
   ;----------------- Text Events ------------------------
   "TEXT_CH": begin
	  case event.id of
	    all.id_comm: comment = strtrim(get_wvalue(event.id),2)
	    all.id_fmed: fmedian_width = (long(get_wvalue(event.id)))(0)
	    all.id_cc:   max_cross_corr = (long(get_wvalue(event.id)))(0)
	    all.id_cc_smoo:   cross_smoo = (long(get_wvalue(event.id)))(0)
	    all.id_smin: begin
			    ssmin = ((get_wvalue(event.id)))(0)
			    quse_sminmax = 1
			 end
	    all.id_smax: begin
			    ssmax = ((get_wvalue(event.id)))(0)
			    quse_sminmax = 1
			 end
	    all.id_sig: begin
			    ssigma = ((get_wvalue(event.id)))(0)
			 end
	    else:
	  endcase
	end
   ;----------------- List Events ------------------------
   "LIST": begin
	case event.id of
	    all.id_filelist: begin
		    mapx, event.top,/map,/show,sensitive=0

		    infil = file_list(dir, files(event.index))
		    infil = infil(0)
		    break_file, infil, dsk_log, dir00, filnam, ext
		    img = rfits(infil, h=head)
		    h = head
		    if (keyword_set(getenv('XDISP_FITS_UNSIGN'))) then img = unsign(img)
		    infil = filnam + ext
		    tit = infil
		    nnx = n_elements(img(*,0))
		    nny = n_elements(img(0,*))
		    ;;if ((nny mod 64) ne 0) then img2 = img(9:nnx-8, 0:(nny-9)>0) $
		    ;;			   else img2 = img
		    img2 = img
		    img3 = img2
		    nnx = n_elements(img2(*,0))
		    ;;sum_fact = (1024. / nnx) > 1
		    sum_fact = 1
		    comment = ''
		    qdisp_img = 1
		    qextract = 1
		    align_comm = ''

		    h_info = head
		    tmp = getenv('XDISP_FITS_KEYS')
		    htmp = strcompress(head)
		    pp = strpos(htmp, '/')
		    ss = where(pp eq -1, nss)
		    if (nss ne 0) then pp(ss) = 999
		    htmp = strmids(htmp, 0, pp)
		    h_lab_info = htmp(5:*)
		    if (tmp ne '') then begin
			tmp = strmid(str2arr(tmp) + '          ', 0, 8)
			ss = where_arr(strmid(head, 0, 8), tmp)
			if (ss(0) ne -1) then h_lab_info = htmp(ss)
		    end

                    widget_control, all.id_img_info, set_value=h_info

		    ;mapx, event.top,/map,/show,sensitive=1
	       end
	endcase
   endcase
endcase

if (qlist_dir ne 0) then begin
	mapx, event.top,/map,/show,sensitive=0
	if (qlist_dir eq 1) then files00 = file_list(dir, '*.fit*', file=files) $
			    else files00 = file_list(dir(n_elements(dir)-2:*), '*.fits', file=files)
	files = reverse(files)
	if (n_elements(files) eq 0) then files = ''
	if (files(0) eq '') then files = '****** No Files Found *******'
	widget_control, all.id_filelist, set_value=files
	mapx, event.top,/map,/show,sensitive=1
end
;
if (qreset) then begin
	if (n_elements(bkg) gt 1) then begin
	    tit = infil + '  MINUS  ' + bkg_fil
	    img3 = img2-bkg
	    all.e_str = ''
	end else begin
	    img3 = img2
	    tit = infil
	    all.e_str = ''
	end
	comment2 = ''
end

if (qextract) and (n_elements(img3) gt 2) and (all.e_n gt 0) then begin
    all.e_str= string(all.e_n,all.e_n,all.e_x0, all.e_y0, format='(i4,"x",i4," corner:",i4,",",i4)')
    widget_control, all.id_ext, set_value=all.e_str
    ;
    ;;;if (n_elements(bkg) gt 1) then tit = infil + '  MINUS  ' + bkg_fil $
    ;;;		    			else tit = infil
    ;
    ix0 = all.e_x0		& ix1 = all.e_x0 + all.e_n-1
    iy0 = all.e_y0		& iy1 = all.e_y0 + all.e_n-1
    img3 = img3(ix0:ix1, iy0:iy1)
    qdisp_img = 1
end

if (qdisp_img) and (n_elements(img3) lt 2) then begin
    tbeep, 3
    print, 'You must read data before displaying it'
    qdisp_img = 0
    mapx, event.top,/map,/show,sensitive=1
end
;
if (qdisp_img) then begin
    mapx, event.top,/map,/show,sensitive=0
    imin = min(img3, max=imax)
    comm = [comment, align_comm, all.e_str]
    if (keyword_set(comment2)) then comm = [comm, comment2]
    ss = where(comm ne '', nss)
    if (nss ne 0) then comm = comm(ss)
    comm = arr2str(comm, delim='!c')
    case all.style of
	0: begin
	    idev = stdev(img3, iavg)
	    foot1 = 'Min/Max: ' + strtrim(imin,2) + '/' + strtrim(imax,2) + $
		  '  Avg/Dev: ' + strtrim(iavg,2) + '/' + strtrim(idev,2)
	    ;
	    if (quse_sminmax eq 1) and (n_elements(ssmin) ne 0) then smin = float(ssmin) $
								else smin = imin
	    if (quse_sminmax eq 1) and (n_elements(ssmax) ne 0) then smax = float(ssmax) $
								else smax = imax
	    if (keyword_set(ssigma)) and (quse_sminmax eq 0) then if (ssigma ne '0') then begin
		smin = iavg - float(ssigma)*idev
		smax = iavg + float(ssigma)*idev
	    end
	    foot2 = 'SMin/SMax: ' + strtrim(smin,2) + '/' + strtrim(smax,2)
	    ;
	    disp_gen, keyword_set(disp_gen), img3, '', tit, comm, hc=hc, $
			smin=smin, smax=smax, sigma=sigma, $
			foot1=foot1, footnotes=h_lab_info, foot2=foot2
			
	    smm_wid = [strtrim(smin,2), strtrim(smax,2)]
	   end
	1: begin
	    if (n_elements(margin) eq 0) then margin=4
	    img_summary, img3, [tit, comm], h_lab_info, brightest=4, dimmest=4, margin=margin, hc=hc
	    smm_wid = [' ', ' ']
	   end
    endcase

    widget_control, all.id_imin, set_value=strtrim(imin,2)
    widget_control, all.id_imax, set_value=strtrim(imax,2)
    widget_control, all.id_smin, set_value=smm_wid(0)
    widget_control, all.id_smax, set_value=smm_wid(1)
    if (keyword_set(ssigma)) then if (ssigma ne '0') then $
	widget_control, all.id_sig, set_value=strtrim(ssigma,2)

    if (keyword_set(qgif)) then begin
	zbuff2file, giffile
	set_plot,'x
    end

    mapx, event.top,/map,/show,sensitive=1
end
;
widget_control,event.top, set_uvalue=all, bad_id=destroyed	;update structure holding all of the info

return
end

;-------------------------------------------------------------
pro xdisp_fits, h_out, img_out, img3_out, $
        summary=summary, margin=margin, $
	infil=infil0, dir=dir0, disp_size=disp_size
;
;+
;NAME:
;	xdisp_fits
;PURPOSE:
;	To allow a user to select a file and image to be displayed
;SAMPLE CALLING SEQUENCE:
;	xdisp_fits
;	xdisp_fits, h, img, img3
;OUTPUT:
;	h	- The FITS header
;	img	- The image
;	img3	- The extracted and processed image (back subtraction)
;OPTIONAL KEYWORD INPUT:
;	margin	- The margin value to use in passing to "img_summary"
;	dir	- The list of directories to allow selection from
;	disp_size- The image is rebinned to this size.  Default is 512
;METHOD:
;	The directories to be searched can be set by passing
;	the directory name in by keyword or by:
;	   1. Defining XDISP_FITS_BASE_DIR to the top data directory
;	      and it will find all subdirectories under that
;	      directory
;	   2. Defining XDISP_FITS_DIRS as a comma separated list of
;	      directories.
;	The 16 bit data can be converted to 32 bit unsigned by setting
;	the env var XDISP_FITS_UNSIGN
;	
;	The env var XDISP_FITS_KEYS can be defined as a comma separated 
;	list of keywords to display.
;HISTORY:
;	Written 15-Jul-98 by M.Morrison (taking XDISP_TRACE as start)
;	16-Jul-98 (MDM) - Various fixes and additions
;	22-Jul-98 (MDM) - Added median filter and box stats options
;V1.23	22-Jul-98 (MDM) - Added option to select the keywords for INFO display
;			  by environment variable
;V1.24	23-Jul-98 (MDM) - Corrected passing out of the data
;-
;
common xdisp_fits_blk1b, infil, dir, files, images, h, img, img2, dirarr, tit
common xdisp_fits_blk3, bkg, bkg_fil
common xdisp_fits_blk4c, comment, align_comm, max_cross_corr, cross_smoo, fmedian_width
common xdisp_fits_blk5b, img3, logfil
;
progver = 'XDISP_FITS  V1.24'
img=0
img2=0
img3=0
h = ''
comment = ''
comment2 = ''
align_comm = ''
if (n_elements(bkg) eq 0) then bkg = 0b
if (n_elements(bkg_fil) eq 0) then bkg_fil = ''
if (n_elements(sttim0) eq 0) then sttim = '' else sttim = sttim0
if (n_elements(entim0) eq 0) then entim = '' else entim = entim0
if (n_elements(max_cross_corr) eq 0) then max_cross_corr = 10
if (n_elements(cross_smoo) eq 0) then cross_smoo = 0
if (n_elements(fmedian_width) eq 0) then fmedian_width = 6
if (n_elements(dirarr) eq 0) then dirarr = ''
;
if (n_elements(dir0) eq 0) then begin
    case 1 of
	keyword_set(getenv('XDISP_FITS_BASE_DIR')): begin
		bdir = getenv('XDISP_FITS_BASE_DIR')
		dirarr = get_subdirs(bdir)
	    end
	keyword_set(getenv('XDISP_FITS_DIRS')): begin
		bdir = getenv('XDISP_FITS_DIRS')
		dirarr = str2arr(bdir)
	    end
        else:
    endcase
end else begin
    dir = dir0
end
;
if (n_elements(infil0) ne 0) then begin
    infil = infil0
    break_file, infil0, dsk_log, dir
end else begin
    infil = ''
end
files = ''
file_list00 = file_list(dir, '*.fit*', file=files)
files = reverse(files)
if (max(strlen(files)) lt 10) then files = files + '                                     '
if (n_elements(disp_size) eq 0) then disp_size = 512
if (!d.window eq -1) or (!d.window eq 32) then wdef, next_window(/user), disp_size
;
logfil = concat_dir('$HOME', ex2fid(anytim2ex(!stime))+'.xdisplog')
file_append, logfil, ['XDISP_FITS  Started: ' + !stime, ' ']
;
font = get_xfont(closest=12,/only_one,/fixed)
if (getenv('MDI_DEF_FONT') ne "") then font = getenv('MDI_DEF_FONT')
widget_control, default_font=font
device, font=font

base00=widget_base(/column,title=progver, xoff=0, yoff=0)
xmenu, ['QUIT', 'Set Directory', $
		'List Directory', 'Sel Dir From Array', $
		'Set Printer', 'Print Header'], base00, buttons=main_buts, /row
xmenu, ['Create a new Window', 'Redisplay Image', 'Redisplay Orig Image', $
		'Hardcopy', 'Save2GIF'], base00, buttons=main_buts, /row
xmenu, ['ReSet Image Min/Max and Sigma', 'Run PROFILES', 'Save to FITS'], base00, buttons=main_buts, /row
xmenu, ['Copy Img to Bkg Buff', 'Clear Bkg Buff', 'Do Bkg Subtraction'], $
			base00, buttons=main_buts, /row
xmenu, ['Median Filter', 'Box Stats', 'Do Cross Corr', 'Find Grid'], $
			base00, buttons=main_buts, /row

linebase = widget_base(base00, /row)
xx       = widget_label(linebase, value = 'Bkg File:')
id_bkg   = widget_text(linebase, xsize=30, ysize=1, value=bkg_fil)
;
linebase = widget_base(base00, /row)
xx       = widget_label(linebase, value = 'FMEDIAN Width:')
id_fmed  = widget_text(linebase, xsize=5, ysize=1, value=strtrim(fmedian_width,2), /editable)
xx       = widget_label(linebase, value = 'Max Cross Corr (pixels):')
id_cc    = widget_text(linebase, xsize=5, ysize=1, value=strtrim(max_cross_corr,2), /editable)
xx       = widget_label(linebase, value = 'CC Smooth:')
id_cc_smoo= widget_text(linebase, xsize=5, ysize=1, value=strtrim(cross_smoo,2), /editable)

xmenu, ['Extract Sub-Image', 'Fixed Extract', 'Clear Extract'], base00, buttons=main_buts, /row
linebase = widget_base(base00, /row)
xx       = widget_label(linebase, value = 'Extract Info:')
id_ext   = widget_text(linebase, xsize=30, ysize=1, value='')


xmenu, ['Display simple image', $
        'Display as IMG_SUMMARY'], $
        base00, /row, /exclusive, /frame

base0=widget_base(base00, /row)

base_col1 = widget_base(base00, /column, /frame)            

linebase = widget_base(base_col1, /row)
xx       = widget_label(linebase, value = 'Image Min:')
id_imin  = widget_text(linebase, xsize=12, ysize=1)
xx       = widget_label(linebase, value = ' Max:')
id_imax  = widget_text(linebase, xsize=12, ysize=1)

linebase = widget_base(base_col1, /row)
xx       = widget_label(linebase, value = 'Scale Min:')
id_smin  = widget_text(linebase, xsize=12, ysize=1, /editable)
xx       = widget_label(linebase, value = ' Max:')
id_smax  = widget_text(linebase, xsize=12, ysize=1, /editable)
xx       = widget_label(linebase, value = ' Sigma:')
id_sig   = widget_text(linebase, xsize=12, ysize=1, /editable)


;-------------------------
base_group3=widget_base(base0, /row, /frame)
base3_col1 = widget_base(base_group3, /column, /frame)
xx = widget_label(base3_col1, value = 'File List')
id_filelist = widget_list(base3_col1, ysize=20, value=files)
;widget_control, id_info, /append

base3_col2 = widget_base(base_group3, /column, /frame)
xx = widget_label(base3_col2, value = 'Current Image Info')
id_img_info = widget_list(base3_col2, ysize=20, xsiz=45, value='                         ')

;-------------------------

base_col2 = widget_base(base00, /column, /frame)            

linebase = widget_base(base_col2, /row)
xx       = widget_label(linebase, value = 'Info:')
id_info  = widget_text(linebase, xsize=60, ysize=1)
linebase = widget_base(base_col2, /row)
xx       = widget_label(linebase, value = 'Comments:')
id_comm  = widget_text(linebase, xsize=60, ysize=1, /editable)

;--------------------------

if (n_elements(sigma) eq 0) then sigma = 0
all = {base:base0, $
	id_filelist: id_filelist, $
        id_img_info: id_img_info, $
	disp_size: disp_size, $
	style: keyword_set(summary), $
	sigma: sigma, $
	id_imin: id_imin, id_imax: id_imax, $
	id_smin: id_smin, id_smax: id_smax, id_sig: id_sig, $
	id_bkg: id_bkg, $
	id_info: id_info, id_comm: id_comm, $
	id_ext: id_ext, e_x0: 0, e_y0: 0, e_n: 0, e_str: ' ', $
	id_fmed: id_fmed, id_cc: id_cc, id_cc_smoo:id_cc_smoo, $
	junk:0}

widget_control,set_uvalue=all, base00
widget_control,base0,/realize
widget_control,set_uvalue=all, base00
xmanager, 'xdisp_fits', base00

if (n_elements(h) ne 0) then begin
    h_out = temporary(h)
    img_out = temporary(img)
    img3_out = temporary(img3)
end
return
end
