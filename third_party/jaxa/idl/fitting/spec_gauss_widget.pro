
;+
; NAME
;
;     SPEC_GAUSS_WIDGET
;
; EXPLANATION
;
;     A general purpose emission line fitting widget. The inputs are simply
;     1D arrays for wavelength, intensity/flux and errors on the
;     intensity/flux. By default the routine assumes a Gaussian
;     fitting function. It is possible to use different fitting
;     functions, but there are restrictions on this (see the FITFUNC=
;     keyword below). FITFUNC has been implemented for the SOHO/CDS
;     instrument. 
;
;     A tutorial for using spec_gauss_widget is available at:
;
;     http://files.pyoung.org/spec_gauss_widget_tutorial.pdf
;
; INPUTS
;
;     XX    A vector of wavelengths. (Assumed to be angstroms.)
;
;     YY    A vector of intensities or fluxes. (Assumed to be in /pixels 
;           units rather than /angstrom units; use /angpix to change
;           this.) 
;
;     EE    Error vector giving 1-sigma errors on the YY values.
;
;     QQ    Data quality vector. Should be same size as XX, etc.
;
; OPTIONAL INPUTS
;
;     MISSING  The value for 'missing' data. Some instruments assign a 
;              specific value (e.g., -100) to bad data. Passing this value 
;              to SPEC_GAUSS_WIDGET through the MISSING keyword means that 
;              any pixels with this value are automatically removed from the 
;              fitting process.
;
;     DEF_WIDTH This allows the user to specify a default width for
;               the emission lines. Therefore if the user does not
;               choose an initial width for an emission line (i.e.,
;               he/she simply clicks once with the mouse rather
;               drawing the triangle), then the routine will assume
;               the user just wants to use the default width. This is
;               useful if the spectrum's line widths are
;               dominated by instrumental broadening.
;
;     OUTNAME   Specifying the name of a file OUTNAME sends the fitted line 
;               parameters to this file in a fixed width format. This file 
;               is then suitable for sending to Microsoft Excel, or 
;               converting to a Latex table format.
;
;     LINE_LIST This must be a structure with the tags
;               .fname  Name of a line list file.
;               .width  Width (angstroms) over which to check for wavelength 
;                       matches.
;               The line list file contains a list of wavelengths, with an 
;               ion and CHIANTI level indices associated with each. After 
;               SPEC_GAUSS_WIDGET has performed a fit, the centroid of a 
;               line is compared with the contents of the line list file, 
;               and if a nearby identification is found ('nearby' defined by 
;               the .width tag) then the CHIANTI database is checked and the 
;               CHIANTI wavelength and ion extracted. SPEC_GAUSS_WIDGET 
;               then displays the line identification next to the line fit.
;               The line list file must have a particular format (see the 
;               routine READ_LINE_IDS.PRO for more details)
;
;     QQMAX     Maximum value of data quality. If not set, then it is taken
;               to be max(QQ).
;
;     QQMIN     Minimum value of data quality. If not set, then it is taken
;               to be zero.
;
;     QQSET     If set to 1, then the data quality is automatically
;               overplotted from the start. Otherwise, it is not displayed.
;
;     FITFUNC   By default the routine assumes that a Gaussian is being fit
;               to the data (defined by the routine GAUSS1.PRO). The name
;               of an alternative routine can be specified by FITFUNC. The
;               function must be defined by 3 parameters, the first being
;               peak, the 2nd being centroid, and the third being width.
;               Note that names of possible routines are explicitly coded
;               in SPEC_GAUSS_WIDGET, as the factor relating intensity to
;               peak * FWHM will be different (do a search for 'const2' in
;               the code below).
;
;     XRANGE    Allows the default X-range for the plot to be specified.
;
;     YRANGE    Allows the default Y-range for the plot to be
;               specified.
;
;     WIDTH_RANGE  Two element array that specifies the default range
;                  of FWHM values that fitted Gaussians are allowed to
;                  have. If not specified then assumed to be [0.1,2.0]
;                  (units: angstroms). See also the keyword
;                  /SET_WIDTH_RANGE.
;
;     PARINFO_WVL_STEP This is the step size to be used by the PARINFO
;                      input to MPFITEXPR. It allows the user to
;                      manually specify the step size for optimizing
;                      the line centroid positions. A recommendation
;                      is to use 0.25 of the wavelength pixel size. If
;                      PARINFO_WVL_STEP is not given then MPFITEXPR
;                      will automatically work out a step size.
;
;     INT_FACTOR  If set, then spec_gauss_widget will internally
;                 multiply YY and EE by INT_FACTOR. The fit parameters
;                 for peak, intensity/flux and background will be
;                 divided by INT_FACTOR after the fit has been
;                 performed. This scaling is intended for astronomical
;                 applications where fluxes can be small (10^-15),
;                 which can affect the accuracy of the fits. The
;                 output line parameters are fully consistent with the
;                 input flux/intensity array.
;
; KEYWORDS
;
;     ANGPIX    Set to 1 if the flux/intensity units are given in PER ANGSTROM
;               units rather than PER PIXEL units.
;
;     SET_WIDTH_RANGE  If set, then spec_gauss_widget will restrict
;                      the FWHMs of the fitted Gaussians to lie
;                      within the range specified by WIDTH_RANGE. If
;                      WIDTH_RANGE is not specified then a default of
;                      0.1 to 2.0 is assumed.
;
;     INT_POSITIVE  If set, then line intensities will be forced to be
;                   positive. 
;
; OUTPUTS
;
;     The fit parameters are written to a file called
;     'spec_gauss_fits.txt' in the current working directory. As you
;     go through a spectrum fitting the lines, each new set of fit
;     parameters will be appended to the file. Note that the
;     parameters are sent to the file when you click on the 'Exit'
;     button within the 'FIT LINES' widget. If you click on the
;     'Reset' button before clicking 'Exit' then you will erase the
;     fit parameters and nothing will be written to the text
;     file. This is useful if the fit is not good.
;
;     The spec_gauss_fits.txt file can be read into an IDL structure
;     using the routine READ_LINE_FITS.PRO (available in Solarsoft).
;
;     The columns of the spec_gauss_fits.txt file are as follows:
;
;     Col1  wavelength
;     Col2  wavelength error
;     Col3  line peak
;     Col4  line peak error
;     Col5  FWHM
;     Col6  FWHM error
;     Col7  intensity
;     Col8  intensity error
;     Col9  wvl1 (see below)
;     Col10 wvl2 (see below)
;     Col11 bg1 (see below)
;     Col12 error on bg1
;     Col13 bg2 (see below)
;     Col14 error on bg2
;     
;     The last six parameters define the background for the
;     fit. This is a straight line that passes through
;     (wvl1,bg1) and (wvl2,bg2).
;
;     Note that the format is 2f12.4,2e12.3,2f12.4,2e12.4,2f12.4,4e12.4.
;
; INTERNAL ROUTINES
;
;     LINE1_PLOT, SPEC_GAUSS_FONT, MAKE_FIT_STRING,
;     MAKE_LINE_STRUC, SETUP_PIX, PLOT_THE_SPEC, SG_BASE_EVENT, 
;     GAUSS_WIDGET
;
; CALLS
;
;     READ_LINE_IDS, TRIM, MPFITEXPR, DRAWTRIANGLE, LINE_SG, GAUSS_SG,
;     CH_DRAWBOX 
;
; COMMON BLOCKS
;
;     PIXELS, INIT_DATA, FIT_DATA
;
; PROGRAMMING NOTES
;
;     Data quality
;     ------------
;     The inputs QQ, QQMIN, QQMAX, and QQSET are used to overplot the data
;     quality on the plot. An example of the use of this is for SOHO/CDS
;     data: the displayed spectrum may be extracted from a number, N, of
;     spatial pixels. However, some of these pixels will be affected by
;     cosmic ray hits and so should not be included in the analysis. If, for
;     a given wavelength pixel, M spatial pixels are affected by cosmic
;     rays, then the data quality is set to N-M in this case. This is
;     shown in the plot window as follows: two red dashed lines are drawn
;     to indicate the data quality minimum and maximum (0 and N in this
;     case). The yellow line shows the data quality of the spectrum. For
;     the wavelength pixel mentioned above, the data quality value is
;     fractionally set between the lower and upper limits based on the
;     value N-M.
;
; HISTORY
;
;     Ver. 1, 6-Dec-2005, Peter Young
;
;     Ver. 2, 12-Dec-2005, Peter Young
;          Removed line1 and gauss1 from routine - they're now external
;          routines
;
;     Ver. 3, 26-Jan-2006, Peter Young
;          Added FITFUNC keyword.
;
;     Ver. 4, 7-Mar-2006, Peter Young
;          Now plots the background level after fitting
;
;     Ver. 5, 16-Mar-2006, Peter Young
;          Adjusted plot and font sizes for display on small screens, and
;          also re-formatted the button widgets into 2 columns.
;
;     Ver. 6, 28-Apr-2006, Peter Young
;          Changed gauss1 and line1 references to gauss_sg and line_sg
;
;     Ver. 7, 8-Dec-2006, Peter Young
;          Added the "Ion IDs" plot button.
;
;     Ver. 8, 24-Oct-2008, Peter Young
;          Modified way line IDs are displayed; modified text output
;          file to include background parameters.
;
;     Ver. 9, 31-Oct-2008, Peter Young
;          Added XRANGE= and YRANGE= optional inputs; removed
;          PLOTDATA, MCHOICE and COMM common blocks; made plot window
;          larger for large screens.
;
;     Ver. 10, 12-Nov-2008, Peter Young
;          Added WIDTH_RANGE= and /SET_WIDTH_RANGE keywords, and extra
;          widget features to the 'FIT LINES' widget. These allow the
;          user to restrict the range of FWHM values that the fitted
;          Gaussians are allowed to have.
;
;     Ver. 11, 3-Apr-2009, Peter Young
;          If line_list.shift has been specified, then I change the
;          position the line IDs appear on the spectrum based on the
;          shift. A bug was also corrected related to the unzoom
;          function. 
;
;     Ver. 12, 14-Dec-2009, Peter Young
;          Updated header (no change to code).
;
;     Ver. 13, 15-Jun-2010, Peter Young
;       -  When exiting the 'Perform fit' widget area, the 'Same
;          width?' and 'Background' widgets are reset to their
;          default values.
;       -  Error bars are now shown on the residuals plot window. 
;       -  GUI is now positioned closer to the center of
;          the screen for large displays. 
;       -  Centroid locations are now shown on residual plot. 
;       -  If background is not specified then initial value is set
;          to minimum Y-value in plot window.
;
;     Ver. 14, 16-Jun-2010, Peter Young
;       -  I've activated the DEF_WIDTH keyword now.
;       -  Instead of vertical line being shown to indicate the
;          initial guess at the line amplitude, a triangle is now
;          drawn.
;       -  If the user does not choose a background level, then the
;          method for estimating the background automatically has been
;          modified. The average of 25% of pixels with the lowest
;          intensity is now used (using the pixel with the lowest
;          intensity sometimes gave bad fits for unknown reasons).
;
;     Ver. 15, 4-May-2011, Peter Young
;       -  Added the PARINFO_WVL_STEP input
;       -  Chi^2 value is now printed to the widget rather than the
;          IDL window.
;
;     Ver. 16, 27-Jun-2011, Peter Young
;       - Added INT_FACTOR= optional keyword
;
;     Ver. 17, 12-Dec-2011, Peter Young
;       - Added the keyword /INT_POSITIVE.
;
;     Ver. 18, 10-Apr-2012, Peter Young
;       - Now switches off line IDs when 'Unzoom' is pressed.
;
;     Ver. 19, 5-Jul-2012, Peter Young
;       - The default X-range is modified so that missing pixels at
;         the ends of the spectrum are not included.
;-


FUNCTION line1_plot, x, x0, y0
;
; This is for plotting a linear background. The y0 (2 element array) are 
; expected to be parameters output by the fit, giving the background values
; at the ends of fitted wavelength range. The x0 are the wavelengths at the
; ends of this range.
;
f=(x-x0[0])*(y0[1]-y0[0])/(x0[1]-x0[0]) + y0[0]
return,f
END

;------------------
PRO spec_gauss_font, font, big=big, fixed=fixed, scale=scale
;+
;  Defines the fonts to be used in the widgets. Allows for Windows and Unix 
;  operating systems.
;-
CASE !version.os_family OF

  'unix': BEGIN
    IF keyword_set(fixed) THEN fstr='-*-courier-' ELSE $
         fstr='-adobe-helvetica-'
    IF keyword_set(big) THEN str='18' ELSE str='12'
    IF keyword_set(scale) THEN BEGIN
      floatstr=float(str)*0.8
      str=trim(round(floatstr))
    ENDIF
    font=fstr+'bold-r-*-*-'+str+'-*'
  END

  ELSE: BEGIN
    IF keyword_set(fixed) THEN fstr='Courier' ELSE $
         fstr='Arial'
    IF keyword_set(big) THEN str='20' ELSE str='16'
    IF keyword_set(scale) THEN BEGIN
      floatstr=float(str)*0.8
      str=trim(round(floatstr))
    ENDIF
    font=fstr+'*bold*'+str
  END

ENDCASE

END


FUNCTION make_fit_string, lines, state

;+
;  Fit parameters are displayed in the fit_info widget within 
;  spec_gauss_widget. MAKE_FIT_STRING() creates the string that is displayed in
;  fit_info. Note the call to READ_LINE_IDS to get the line identifications.
;-

line_list=state.data.line_list
chi2=state.data.chi2

outstr='REDUCED CHI^2: '+trim(string(format='(f15.2)',chi2))
FOR i=0,n_elements(lines)-1 DO BEGIN
  str2=''
  IF n_tags(line_list) NE 0 THEN BEGIN
    read_line_ids,line_list.fname,lines[i].cent.fit,struc, $
         range=line_list.width,shift=line_list.shift
    IF n_tags(struc) NE 0 THEN BEGIN
      n=n_elements(struc)
      str2='  >>  '
      IF n NE 0 THEN BEGIN
        FOR j=0,n-1 DO BEGIN
          vel=lamb2v(lines[i].cent.fit-struc[j].wvl,struc[j].wvl)
          vel='('+trim(string(format='(f10.1)',vel))+' km/s)'
          str2=str2+struc[j].str+' '+vel+'  '
        ENDFOR
      ENDIF
    ENDIF
  ENDIF
  str1=trim(i+1)+'. '+ $
       '  INT  '+trim(string(format='(e12.3)',lines[i].int.fit))+ $
       ' '+string(177b)+' '+trim(string(format='(e12.3)',lines[i].int.sigma))+$
       '  |  WID  '+trim(string(format='(f12.4)',lines[i].width.fit))+$
       ' '+string(177b)+' '+trim(string(format='(f12.4)',lines[i].width.sigma))+ $
       '  |  WVL  '+trim(string(format='(f12.3)',lines[i].cent.fit))+$
       ' '+string(177b)+' '+trim(string(format='(f12.3)',lines[i].cent.sigma))+$
       str2
  outstr=[outstr,str1]
ENDFOR
;outstr=outstr[1:*]

return,outstr

END


;------------------
function make_line_struc

;+
;   The LINES structure contains entries for each line that the user is 
;   fitting. It stores the initial fit parameters, as well as the final 
;   fits and associated errors. This routine sets up the format of the 
;   LINES structure but does not fill it with data.
;-

str={init: 0., fit: 0., sigma: 0.}
return,{peak: str, cent: str, gwidth: str, width: str, int: str}

END


;------------
PRO setup_pix, state

COMMON pixels, xpix, pix, pix_min1
;
; XPIX    Contains the indices (within XX) of all pixels in the plot range
;         that are not flagged as missing. Remains the same until setup_pix
;         is called again.
; PIX_MIN1 Vector of same size as XPIX, and with the same values, except that
;          those pixels de-selected by user are given a value of -1.
; PIX     Defined as XPIX(where (PIX_MIN1 ne -1)), thus can be a vector of
;         smaller length than XPIX.
;-
xx=state.data.xx
yy=state.data.yy
miss=state.data.miss
xrange=state.wid_data.xrange

ind=where(xx GE xrange[0] AND xx LE xrange[1])
xpix=ind
ind=where(yy[xpix] NE miss)
xpix=xpix[ind]
pix=xpix
pix_min1=xpix

END

;----------------
PRO plot_the_spec, state, restore=restore, show_pix=show_pix
;+
;   This routine is used to plot the spectrum and also the residuals plot.
;   The different plot options are contained within the variable TST_PP.
;
;   RESTORE   Plots the full spectrum (e.g., UNZOOM feature).
;
;   SHOW_PIX  Used when selecting/de-selecting pixels. Plots asterisks on 
;             the acutal data making it easier to see what's being modified.
;-
COMMON pixels, xpix, pix, pix_min1
COMMON init_data, init, lines, backg, nback, wflag
COMMON fit_data, aa, sigmaa, background

xx=state.data.xx
yy=state.data.yy
ee=state.data.ee
missing=state.data.miss
outname=state.data.outname
widget_control,state.pparams,get_value=tst_pp

line_list=state.data.line_list

wset,state.wid_data.spec_plot_id

IF keyword_set(restore) THEN BEGIN
  xrange=state.data.xrange
  yrange=state.data.yrange
 ;
  state.wid_data.xrange=xrange
  state.wid_data.yrange=yrange
  widget_control,state.sg_base,set_uval=state
ENDIF ELSE BEGIN
  xrange=state.wid_data.xrange
  yrange=state.wid_data.yrange
ENDELSE 

plot,xx,yy,psym=10,xrange=xrange,yrange=yrange,/xsty,/ysty, $
     xticklen=-.02,yticklen=-0.02

yr=!y.crange
xr=!x.crange

;
; Overplot chosen pixels
; ----------------------
IF tst_pp[0] EQ 1 AND n_elements(pix) NE 0 THEN BEGIN
  n=n_elements(pix)
  IF n NE 0 THEN oplot,xx[pix],(fltarr(n)+1.)*0.5*(yr[1]+yr[0]),psym=2
ENDIF

IF keyword_set(show_pix) THEN oplot,xx[pix],yy[pix],psym=2

;
; Overplot data quality
; ---------------------
IF tst_pp[1] EQ 1 THEN BEGIN
  qmin=state.data.qqmin
  qmax=state.data.qqmax
  qq=state.data.qq
 ;
  q_plot=(float(qq)-qmin)/(qmax-qmin)*(yr[1]-yr[0])/2.+0.25*(yr[1]+3.*yr[0])
  oplot,xx,q_plot,psym=10,col=50
  oplot,xx,fltarr(n_elements(xx))+(0.75*yr[1]+0.25*yr[0]),line=1,col=51
  oplot,xx,fltarr(n_elements(xx))+(0.25*yr[1]+0.75*yr[0]),line=1,col=51
ENDIF

;
; Overplot error bars
; -------------------
IF tst_pp[2] EQ 1 THEN oploterr,xx,yy,ee,psym=3

;
; Overplot initial guess parameters
; ---------------------------------
IF tst_pp[3] EQ 1 THEN BEGIN 
  IF backg EQ 0. AND n_elements(pix) NE 0 THEN BEGIN
    npix=n_elements(pix)
    k=sort(yy[pix])
    backg=average(yy[pix[k[0:npix/4]]])
;    backg=min(yy[pix])
  ENDIF 
  oplot,th=2,xx,(yy-yy)+backg
 ;
  IF n_elements(lines) NE 0 THEN BEGIN
    n=n_elements(lines)
    IF n NE 0 THEN BEGIN
      FOR i=0,n-1 DO BEGIN
        oplot,lines[i].cent.init+[lines[i].width.init,0], $
              backg+[0.,lines[i].peak.init],th=2
        oplot,lines[i].cent.init+[-lines[i].width.init,0], $
              backg+[0.,lines[i].peak.init],th=2

;        oplot,lines[i].cent.init*[1,1], $
;                           backg+[0.,lines[i].peak.init],th=2
      ENDFOR 
    ENDIF
  ENDIF 
ENDIF

;
; Overplot the fit function
; -------------------------
IF tst_pp[4] EQ 1 AND n_elements(aa) NE 0 THEN BEGIN
 ;
 ; plot background
  n=n_elements(lines)
  IF nback EQ 2 THEN BEGIN
    bg=line1_plot(xx,[background.x0,background.x1],aa[3*n:3*n+1])
  ENDIF ELSE BEGIN
    bg=aa[3*n]+fltarr(n_elements(xx))
  ENDELSE
  oplot,xx,bg,th=2,col=52
 ;
 ; plot individual lines
  totfunc=0.
  FOR i=0,n-1 DO BEGIN
    func=call_FUNCTION(state.data.fitfunc,xx,aa[3*i:3*i+2])
    totfunc=totfunc+func
    oplot,xx,func+bg,th=2,col=51
  ENDFOR
 ;
 ; plot total profile
  totfunc=totfunc+bg
  oplot,xx,totfunc,th=2,col=50
 ;
 ; Plot residuals
 ; --------------
  IF n_elements(pix) NE 0 THEN BEGIN
    wset,state.wid_data.res_plot_id
    getmax=max(abs(totfunc[pix]-yy[pix]))
    plot,/nodata,xrange,[-1.15,1.15]*getmax,/xsty,/ysty, $
         ytit='Residuals (Data-Fit)'
    FOR i=0,n-1 DO oplot,aa[3*i+1]*[1,1],[-1,1]*getmax*1.5,col=51
    oploterr,xx[pix],yy[pix]-totfunc[pix],ee[pix],psym=2
;    oplot,xx[pix],yy[pix]-totfunc[pix],psym=2
    oplot,xrange,[0,0],line=2
    xr=!x.crange
    yr=!y.crange
    xyouts,0.98*xr[0]+0.02*xr[1],0.94*yr[0]+0.06*yr[1], $
           'Centroids shown in red',col=51
    wset,state.wid_data.spec_plot_id
  ENDIF
ENDIF

;
; Over-plot line identifications
; ------------------------------
IF tst_pp[5] EQ 1 AND n_tags(line_list) NE 0 THEN BEGIN
  read_line_ids,line_list.fname,0.5*(xr[1]+xr[0]),struc, $
       range=(xr[1]-xr[0])/2.
  IF n_tags(struc) NE 0 THEN BEGIN
    n=n_elements(struc)
 ;
    y0=(yr[1]-yr[0])/200.*70.
    dy=(yr[1]-yr[0])/200.*10.
    dy2=(yr[1]-yr[0])/200.*7.
    IF n_tags(struc) NE 0 THEN BEGIN
      FOR k=0,n_elements(struc)-1 DO BEGIN
        ypos=y0+ (k MOD 10)*dy + yr[0]
        xpos=struc[k].wvl+v2lamb(line_list.shift,struc[k].wvl)
;        xyouts,struc[k].wvl,ypos,struc[k].name
;        oplot,[1,1]*struc[k].wvl,[-dy2,0]+ypos
        xyouts,xpos,ypos,struc[k].name
        oplot,[1,1]*xpos,[-dy2,0]+ypos
      ENDFOR 
    ENDIF
  ENDIF
ENDIF

END


;-------------
PRO sg_base_event, event

COMMON pixels, xpix, pix, pix_min1
COMMON init_data, init, lines, backg, nback, wflag
COMMON fit_data, aa, sigmaa, background

WIDGET_CONTROL,Event.top, get_uvalue=state

xx=state.data.xx
yy=state.data.yy
ee=state.data.ee
miss=state.data.miss
outname=state.data.outname
widget_control,state.pparams,get_value=tst_pp
spec_plot_id=state.wid_data.spec_plot_id
res_plot_id=state.wid_data.res_plot_id

CASE 1 OF
  event.id EQ state.main_butts: BEGIN

    CASE event.value OF
      0: BEGIN
        txt=['ZOOM: click-and-drag cursor to zoom into the selected part of '+$
             'the spectrum.']
        widget_control,state.help_txt,set_val=txt
        result=ch_drawbox(spec_plot_id,/data)
       ;
        state.wid_data.xrange=[result[0],result[2]]
        state.wid_data.yrange=[result[1],result[3]]
        widget_control,state.sg_base,set_uval=state
       ;
        plot_the_spec,state
        widget_control,state.help_txt,set_val=''
      END

      1: BEGIN
        tst_pp[2]=0    ; switch off error bars
        tst_pp[4]=0    ; switch off fit over-plot
        tst_pp[5]=0    ; switch off line IDs
        widget_control,state.pparams,set_val=tst_pp
        plot_the_spec,state,/restore
      END

      2: WIDGET_CONTROL, event.top, /DESTROY

    ENDCASE
  END

  event.id EQ state.pix_choose: BEGIN
    widget_control,state.pix_base2,sens=1
    widget_control,state.pix_ch_base,sens=0
    widget_control,state.fit_ch_base,sens=0
    widget_control,state.base1,sens=0
    widget_control,state.mb_base,sens=0
   ;
    setup_pix,state
    tst_pp[0]=1
    widget_control,state.pparams,set_value=tst_pp
    plot_the_spec,state
  END

  event.id EQ state.pix_type: BEGIN
    plot_the_spec,state,show_pix=event.value GT 0
   ;
   ; BOX SELECT/DE-SELECT
   ; --------------------
    IF event.value EQ 1 THEN BEGIN
      txt=['BOX SELECT: Choose pixels to add to the line-fitting by '+ $
           'clicking-and-dragging the cursor. Exit','by clicking outside '+ $
           'of the plot axes.']
      widget_control,state.help_txt,set_val=txt
    ENDIF
    IF event.value EQ 2 THEN BEGIN
      txt=['BOX DE-SELECT: Choose pixels to remove from the line-fitting '+ $
           'by clicking-and-dragging the','cursor. Exit by clicking '+ $
           'outside of the plot axes.']
      widget_control,state.help_txt,set_val=txt
    ENDIF
   ;    
    IF event.value EQ 1 OR event.value EQ 2 THEN BEGIN
      widget_control,state.pix_base2,sens=0
      tst=0
      WHILE tst EQ 0 DO BEGIN
        result=ch_drawbox(spec_plot_id,/data)
        xr=[min([result[0],result[2]]),max([result[0],result[2]])]
        yr=[min([result[1],result[3]]),max([result[1],result[3]])]
        IF xr[1] LE !x.crange[1] AND xr[0] GE !x.crange[0] AND $
             yr[1] LE !y.crange[1] AND yr[0] GE !y.crange[0] THEN BEGIN
          ind=where(xx[xpix] GT xr[0] AND xx[xpix] LT xr[1])
          n=n_elements(ind)
          FOR i=0,n-1 DO BEGIN
            j=ind[i]
            IF event.value EQ 1 THEN pix_min1[j]=xpix[j] ELSE pix_min1[j]=-1
          ENDFOR
          pix=xpix(where(pix_min1 NE -1))
          plot_the_spec,state,/show_pix
        ENDIF ELSE BEGIN
          widget_control,state.pix_base2,sens=1
          widget_control,state.pix_type,set_value=0
          tst=1
        ENDELSE
      ENDWHILE 
      widget_control,state.help_txt,set_val=''
    ENDIF
   ;
   ; PIXEL SELECT/DE-SELECT
   ; ----------------------
    IF event.value EQ 3 THEN BEGIN
      txt='PIXEL SELECT: Choose individual pixels to add to the line-fitting'+ $
           'by clicking on them. Exit by clicking outside '+ $
           'of the plot axes.'
      widget_control,state.help_txt,set_val=txt
    ENDIF
    IF event.value EQ 4 THEN BEGIN
      txt='PIXEL DE-SELECT: Choose individual pixels to remove from the '+ $
           'line-fitting by clicking on them. Exit by clicking outside '+ $
           'of the plot axes.'
      widget_control,state.help_txt,set_val=txt
    ENDIF
   ;    
    IF event.value EQ 3 OR event.value EQ 4 THEN BEGIN
      tst=0
      WHILE tst EQ 0 DO BEGIN
        cursor,x1,y1,/data,/down
        IF x1 LE !x.crange[1] AND x1 GE !x.crange[0] AND $
             y1 LE !y.crange[1] AND y1 GE !y.crange[0] THEN BEGIN
          getmin=min(abs(x1-xx[xpix]),ind)
          ind=ind[0]
          IF event.value EQ 3 AND pix_min1[ind] EQ -1 $
               THEN pix_min1[ind]=xpix[ind]
          IF event.value EQ 4 AND pix_min1[ind] EQ xpix[ind] $
               THEN pix_min1[ind]=-1
        ENDIF ELSE BEGIN
          widget_control,state.pix_base2,sens=1
          widget_control,state.pix_type,set_value=0
          tst=1
        ENDELSE
        pix=xpix(where(pix_min1 NE -1))
        tst_pp[0]=1
        widget_control,state.pparams,set_val=tst_pp
        plot_the_spec,state,/show_pix
      ENDWHILE
      widget_control,state.help_txt,set_val=''
    ENDIF
  END

  event.id EQ state.pix_exit: BEGIN
    CASE event.value OF
     ; RESET: resets pixels so that all are selected again
      0: BEGIN
        setup_pix,state
        plot_the_spec,state,/show_pix
      END
     ; EXIT: return to main level of widget
      1: BEGIN
        widget_control,state.pix_base2,sens=0
        widget_control,state.pix_ch_base,sens=1
        widget_control,state.fit_ch_base,sens=1
        widget_control,state.base1,sens=1
        widget_control,state.mb_base,sens=1
      END
    ENDCASE
  END

  event.id EQ state.fit_choose: BEGIN
   ;
   ; destroy any existing fit data before starting new fit
   ;
    IF n_elements(init) NE 0 THEN junk=temporary(init)
    IF n_elements(aa) NE 0 THEN junk=temporary(aa)
    IF n_elements(lines) NE 0 THEN junk=temporary(lines)
    IF n_elements(backg) NE 0 THEN backg=0.
   ;
   ; if pix has not been set-up, then use default
   ;
    IF n_elements(pix) EQ 0 THEN setup_pix,state
   ;
   ; remove previous fit and initial data from plot
   ; show pixels that will be used in fit
   ;
    tst_pp[3:4]=0
    tst_pp[0]=1
    widget_control,state.pparams,set_val=tst_pp
   ;
   ; de-sensitise relevant widgets
   ;
    widget_control,state.fit_base2,sens=1
    widget_control,state.mb_base,sens=0
    widget_control,state.fit_ch_base,sens=0
    widget_control,state.pix_ch_base,sens=0
    widget_control,state.base1,sens=0
       ;
       ; Set 'Same width?' widget back to 'No'
       ;
        widget_control,state.width,set_val=1
        wflag=1
       ;
       ; Set 'Background' widget back to 'Linear'
       ;
        widget_control,state.back,set_value=1
        nback=2
       ;
       ; Set 'Restrict FWHM range?' back to 'No'
       ;
        widget_control,state.fix_back,set_value=1
        state.data.set_width_range=0
        widget_control,state.sg_base,set_uval=state
        widget_control,state.fix_back_min_txt,sens=0
        widget_control,state.fix_back_max_txt,sens=0
   ;
   ; print help message
   ;
    txt='Only pixels indicated with * will be used in fit.'
    widget_control,state.help_txt,set_val=txt
   ;
    plot_the_spec,state
  END

  event.id EQ state.fit_butts: BEGIN
    CASE event.value OF

     ;
     ; 'BACKGROUND'
     ; ============
      0: BEGIN
        widget_control,state.fit_base2,sens=0
        tst_pp[3]=1
        tst=0
       ;
        txt='BACKGROUND: Select a background level by clicking once near '+$
             'minimum of spectrum.'
        widget_control,state.help_txt,set_val=txt
       ;
        WHILE tst EQ 0 DO BEGIN
          cursor,x1,y1,/data,/down
          IF x1 LE !x.crange[1] AND x1 GE !x.crange[0] AND $
               y1 LE !y.crange[1] AND y1 GE !y.crange[0] THEN BEGIN
            backg=y1
            tst=1
          ENDIF ELSE BEGIN
            backg=0.
            tst=1
          ENDELSE
        ENDWHILE
        widget_control,state.help_txt,set_val=''
        widget_control,state.fit_base2,sens=1
        widget_control,state.pparams,set_val=tst_pp
        plot_the_spec,state
      END

     ;
     ; 'CHOOSE LINES'
     ; ==============
      1: BEGIN
        widget_control,state.fit_base2,sens=0
       ;
        txt=['SELECT LINES: click-and-drag near line peaks. Set width of '+$
             'triangle to the FWHM of the line.','Repeat for additional '+$
             'lines. '+ $
             'Exit by clicking outside of plot axes.']
        widget_control,state.help_txt,set_val=txt
       ;
        IF n_elements(lines) NE 0 THEN junk=temporary(lines)
        tst_pp[3]=1
        widget_control,state.pparams,set_val=tst_pp
        plot_the_spec,state
        tst=0
        WHILE tst EQ 0 DO BEGIN
          result=drawtriangle(spec_plot_id,/data,col=52)
          x1=result[0]
          y1=result[1]
          wid=result[2]
          IF wid LT state.data.d_width/2. THEN wid=state.data.d_width
          const=2*sqrt(2*alog(2)) ; conversion to FWHM from Gauss width
          IF x1 LE !x.crange[1] AND x1 GE !x.crange[0] AND $
               y1 LE !y.crange[1] AND y1 GE !y.crange[0] THEN BEGIN
            IF n_elements(lines) EQ 0 THEN BEGIN
              lines=make_line_struc()
              lines.cent.init=x1
              lines.peak.init=y1-backg
              lines.gwidth.init=wid/const
              lines.width.init=wid
            ENDIF ELSE BEGIN
              newlines=make_line_struc()
              newlines.cent.init=x1
              newlines.peak.init=y1-backg
              newlines.gwidth.init=wid/const
              newlines.width.init=wid
              lines=[lines,newlines]
            ENDELSE
            widget_control,state.pparams,set_val=tst_pp
            plot_the_spec,state
          ENDIF ELSE BEGIN
            tst=1
          ENDELSE
        ENDWHILE
        widget_control,state.help_txt,set_val=''
        
        widget_control,state.fit_base2,sens=1
      END

     ;
     ; 'PERFORM FIT'
     ; =============
      2: BEGIN
       ;
       ; If background has not been specified by user, then set it to be the
       ; minimum value in the fit range.
       ;
        IF n_elements(backg) EQ 0 THEN BEGIN
          npix=n_elements(pix)
          k=sort(yy[pix])
          backg=yy[pix[k[npix/4]]]
        ENDIF 

        n=n_elements(lines)
        FOR i=0,n-1 DO BEGIN
          IF i EQ 0 THEN init=[lines[i].peak.init,lines[i].cent.init, $
                               lines[i].gwidth.init] $
               ELSE init=[init,lines[i].peak.init,lines[i].cent.init, $
                          lines[i].gwidth.init]
        ENDFOR
        IF nback EQ 2 THEN init=[init,backg,backg] ELSE init=[init,backg]

       ;
       ; Construct EXPR (the fit function)
       ; --------------
       ; Note that if WFLAG is set to 0, then
       ; all lines will have the width p[2]
        expr=''
        FOR i=0,n-1 DO BEGIN
          ss1=strtrim(string(3*i),2)       ; index for peak
          ss2=strtrim(string(3*i+2),2)     ; index for width
          ss3=strtrim(string(3*i+1),2)     ; index for centroid
          IF wflag[0] EQ 0 THEN BEGIN
            expr=expr+state.data.fitfunc+'(x,[p['+ss1+':'+ss3+'],p[2]]) +'
          ENDIF ELSE BEGIN
            expr=expr+state.data.fitfunc+'(x,p['+ss1+':'+ss2+']) +'
          ENDELSE
        ENDFOR
       ;
       ; Add the function for the background
       ;
        IF nback EQ 2 THEN BEGIN
          ss1=strtrim(string(n*3),2)
          ss2=strtrim(string(n*3+1),2)
          expr=expr+'line_sg(x,p['+ss1+':'+ss2+'])'
        ENDIF ELSE BEGIN
          ss=strtrim(string(n*3),2)
          expr=expr+'p['+ss+']'
        ENDELSE

       ;
       ; Set constants (CONST and CONST2) for conversion of Gaussian width to
       ; FWHM, and peak*width to intensity
       ;
        const=2*sqrt(2*alog(2))
        CASE state.data.fitfunc OF
          'gauss_sg': const2=sqrt(2.*!pi)/const
          'cds_mod_gauss1': const2=6.420/const
          'cds_mod_gauss2': const2=3.498/const
          ELSE: const2=sqrt(2.*!pi)/const
        ENDCASE
       ;
       ; Create the parinfo structure
       ; 
        parinfo=replicate({fixed:0, limited:[0,0], limits:[0.D,0.D], step: 0.},n_elements(init))

       ;
       ; If the user has requested a fixed range for the line widths, then
       ; the following sets this up in the PARINFO structure for input to the
       ; MPFIT routine.
       ;
        IF state.data.set_width_range EQ 1 THEN BEGIN
          FOR i=0,n-1 DO BEGIN
            parinfo[i*3+2].limited=[1,1]
            parinfo[i*3+2].limits=state.data.width_range/const
            IF init[i*3+2] LT parinfo[i*3+2].limits[0] THEN init[i*3+2]=parinfo[i*3+2].limits[0]
            IF init[i*3+2] GT parinfo[i*3+2].limits[1] THEN init[i*3+2]=parinfo[i*3+2].limits[1]
          ENDFOR
        ENDIF

       ;
       ; The following forces intensities to be positive if the keyword
       ; /INT_POSITIVE has been set.
       ;
        IF state.data.int_positive EQ 1 THEN BEGIN
          FOR i=0,n-1 DO BEGIN
            parinfo[i*3].limited=[1,0]
            parinfo[i*3].limits=0.
          ENDFOR
        ENDIF 

       ;
       ; This manually sets the step size for the line centroid 
       ; (It is expected that spectra from different instruments will
       ; require different step sizes.)
       ;
        IF state.data.parinfo_wvl_step NE 0. THEN BEGIN
          FOR i=0,n-1 DO BEGIN
            parinfo[i*3+1].step=state.data.parinfo_wvl_step
          ENDFOR
        ENDIF 

;;         FOR i=0,n-1 DO BEGIN
;;           parinfo[i*3].step=max(yy[pix])/10.
;;         ENDFOR 

        aa = MPFITEXPR(expr, xx[pix], yy[pix], ee[pix], init, $
                       perr=sigmaa, /quiet, bestnorm=bestnorm,yfit=yfit, $
                       parinfo=parinfo,niter=niter,status=status)


        chi2=bestnorm/(n_elements(pix) - n_elements(aa))
;        print,format='("Reduced chi^2:",f10.2)',chi2
        state.data.chi2=chi2

        int_factor=state.data.int_factor

        n=n_elements(lines)
       ;
        FOR i=0,n-1 DO BEGIN
          IF wflag[0] EQ 0 THEN BEGIN
            aa[3*i+2]=aa[2]
            sigmaa[3*i+2]=sigmaa[2]
          ENDIF
          getmin=min(abs(aa[3*i+1]-xx),ind)
          IF state.data.angpix EQ 1 THEN wconv=1.0 ELSE $
               wconv=abs(xx[ind]-xx[ind-1])
          lines[i].peak.fit=aa[3*i]/int_factor
          lines[i].peak.sigma=sigmaa[3*i]/int_factor
          lines[i].cent.fit=aa[3*i+1]
          lines[i].cent.sigma=sigmaa[3*i+1]
          lines[i].gwidth.fit=aa[3*i+2]
          lines[i].gwidth.sigma=sigmaa[3*i+2]
          lines[i].width.fit=lines[i].gwidth.fit*const
          lines[i].width.sigma=lines[i].gwidth.sigma*const
          lines[i].int.fit=lines[i].peak.fit*lines[i].width.fit/wconv*const2
          lines[i].int.sigma=max([lines[i].peak.fit*lines[i].width.sigma, $
                                  lines[i].peak.sigma*lines[i].width.fit]) $
               /wconv*const2
        ENDFOR
        str1=make_fit_string(lines,state)
        widget_control,state.fit_info,set_val=str1

       ;
       ; Create background structure
       ;
        naa=n_elements(aa)
        background={x0: 0., x1: 0., y0: 0., y1: 0., sigy0: 0., sigy1: 0.}
        background.x0=min(xx[pix])
        background.x1=max(xx[pix])
        background.y1=aa[naa-1]/int_factor
        background.sigy1=sigmaa[naa-1]/int_factor
        IF nback EQ 2 THEN BEGIN 
          background.y0=aa[naa-2]/int_factor
          background.sigy0=sigmaa[naa-2]/int_factor
        ENDIF ELSE BEGIN
          background.y0=background.y1
          background.sigy0=background.sigy1
        ENDELSE

       ;
       ; Display error bars and fit function on spectrum plot
       ;
        tst_pp[[0,2,3,4]]=[0,1,0,1]
        widget_control,state.pparams,set_value=tst_pp
        plot_the_spec,state

      END

     ;
     ; RESET FIT
     ; ---------
      3: BEGIN
        IF n_elements(init) NE 0 THEN junk=temporary(init)
        IF n_elements(aa) NE 0 THEN junk=temporary(aa)
        IF n_elements(lines) NE 0 THEN junk=temporary(lines)
        IF n_elements(backg) NE 0 THEN backg=0.
        tst_pp[3:4]=0
        widget_control,state.pparams,set_val=tst_pp
        plot_the_spec,state
      END

     ;
     ; EXIT FIT WIDGET
     ; ---------------
      4: BEGIN
       ;
       ; re-sensitise other widgets
       ;
        widget_control,state.base1,sens=1
        widget_control,state.fit_ch_base,sens=1
        widget_control,state.pix_ch_base,sens=1
        widget_control,state.mb_base,sens=1
        widget_control,state.fit_base2,sens=0
       ;
       ; add line fit data to outname
       ; 
        n=n_elements(lines)
        IF n NE 0 THEN BEGIN
          openw,lun,outname,/get_lun,/append
          FOR i=0,n-1 DO BEGIN
            printf,lun,format='(2f12.4,2e12.3,2f12.4,2e12.4,2f12.4,4e12.4)', $
                   lines[i].cent.fit,lines[i].cent.sigma, $
                   lines[i].peak.fit,lines[i].peak.sigma, $
                   lines[i].width.fit,lines[i].width.sigma, $
                   lines[i].int.fit,lines[i].int.sigma, $
                   background.x0, background.x1, $
                   background.y0, background.sigy0, $
                   background.y1, background.sigy1
          ENDFOR
          free_lun,lun
        ENDIF
       ;
       ; destroy pix so that it does not get re-used on later fits
       ;
        IF n_elements(pix) NE 0 THEN junk=temporary(pix)
        tst_pp[0]=0
        widget_control,state.pparams,set_val=tst_pp
        plot_the_spec,state
      END
      ELSE:
    ENDCASE
  END

  event.id EQ state.back: BEGIN
    IF n_elements(aa) NE 0 THEN junk=temporary(aa)
    tst_pp[4]=0
    widget_control,state.pparams,set_val=tst_pp
    plot_the_spec,state
    nback=event.value+1
  END

 ;
 ; 'SAME WIDTH?' 
 ; -------------
 ; If WFLAG set to 0 then lines will be forced to have the same width.
 ;
  event.id EQ state.width: BEGIN
    widget_control,state.width,get_value=val1
    wflag[0]=val1
  END

  event.id EQ state.fix_back: BEGIN
    widget_control,state.fix_back,get_value=val1
    state.data.set_width_range=1-val1
    widget_control,state.sg_base,set_uval=state
    IF val1 EQ 0 THEN sens=1 ELSE sens=0
    widget_control,state.fix_back_min_txt,sens=sens
    widget_control,state.fix_back_max_txt,sens=sens
  END 

  event.id EQ state.fix_back_min_txt: BEGIN
    oldval=state.data.width_range[0]
    widget_control,state.fix_back_min_txt,get_value=val1
    IF val1 GE 0. AND val1 LT state.data.width_range[1] THEN BEGIN
      state.data.width_range[0]=val1
      widget_control,state.sg_base,set_uval=state
    ENDIF ELSE BEGIN
      widget_control,state.fix_back_min_txt,set_value=trim(oldval)
    ENDELSE
  END

  event.id EQ state.fix_back_max_txt: BEGIN
    oldval=state.data.width_range[1]
    widget_control,state.fix_back_max_txt,get_value=val1
    IF val1 GE 0. AND val1 GT state.data.width_range[0] THEN BEGIN
      state.data.width_range[1]=val1
      widget_control,state.sg_base,set_uval=state
    ENDIF ELSE BEGIN
      widget_control,state.fix_back_max_txt,set_value=trim(oldval)
    ENDELSE
  END

  event.id EQ state.pparams: BEGIN
;    tst_pp[event.value]=1-tst_pp[event.value]
;    widget_control,state.pparams,set_val=tst_pp
    plot_the_spec,state
  END

  ELSE:
ENDCASE

END


;=======================================
PRO gauss_widget, group=group, data=data

COMMON init_data, init, lines, backg, nback, wflag
COMMON pixels, xpix, pix, pix_min1
COMMON fit_data, aa, sigmaa, background

IF n_elements(aa) NE 0 THEN junk=temporary(aa)
IF n_elements(lines) NE 0 THEN junk=temporary(lines)
IF n_elements(backg) NE 0 THEN backg=0.
IF n_elements(init) NE 0 THEN junk=temporary(init)

IF n_elements(pix) NE 0 THEN BEGIN
  junk=temporary(xpix)
  junk=temporary(pix)
  junk=temporary(pix_min1)
ENDIF


;
; Apply scale factors to the plot windows if the screen size is small
;
screen_size=get_screen_size()
ssy=screen_size[1]
CASE 1 OF 
  ssy LT 1024: BEGIN
    plot_scale=0.8
    font_scale=1
  END
  ssy GE 1500: BEGIN
    plot_scale=1.2
    font_scale=0
    wid_xoff=500   ; these position the widget closer to the center of the screen
    wid_yoff=200   ;
  END
  ELSE: BEGIN
    plot_scale=1.0
    font_scale=0
  END
ENDCASE
  
;; IF screen_size[1] LT 1024 THEN BEGIN
;;   plot_scale=0.8
;;   font_scale=1
;; ENDIF ELSE BEGIN
;;   plot_scale=1.0
;;   font_scale=0
;; ENDELSE


spec_gauss_font,bigfont,/big,scale=font_scale
spec_gauss_font,font,scale=font_scale

wid_data={spec_plot_id: 0, res_plot_id: 0, $
         xrange: [0.,0.], yrange: [0.,0.]}

sg_base=widget_base(/col,map=1,title='SPEC_GAUSS',xoff=wid_xoff,yoff=wid_yoff)

file_info=widget_label(sg_base,value=data.info,font=bigfont,/align_left)

base1=widget_base(sg_base,/col,map=1,sens=1)
base2=widget_base(sg_base,/row,map=1)
base2_1=widget_base(base2,/col,map=1)
base2_2=widget_base(base2,/col,map=1)

fit_info=widget_text(sg_base,ysiz=5,value='',font=font,/scroll)


;
; This base allows the user to add extra features to the plot: chosen pixels,
; data quality, error bars, etc.
;
pparams_base=widget_base(base2_2,col=1,map=1,/frame)
choices=['Chosen pixels','Data quality','Error bars', $
         'Initial guess','Fit data','Ion IDs']
tst_pp=intarr(n_elements(choices))
IF data.qqset EQ 1 THEN tst_pp[1]=1
pparams=cw_bgroup(pparams_base,choices, $
                  set_value=tst_pp,/nonexclusive,col=2,font=font)


;
; PIXEL SELECTION
; ---------------
pix_base=widget_base(base2_2,/col,/frame)
;
pix_ch_base=widget_base(pix_base)
pix_choose=widget_button(pix_ch_base,value='PIXEL SELECT',font=bigfont)
;
pix_base2=widget_base(pix_base,/col,sens=0)
pix_type=CW_BGROUP(pix_base2,['Do nothing','Box select','Box de-select', $
                           'Pixel select','Pixel de-select'],set_value=0, $
                   col=2,/exclusive,font=font)
pix_exit=cw_bgroup(pix_base2,['RESET','EXIT'],/row,font=font)



;
; LINE-FITTING WIDGETS
; --------------------
fit_base=widget_base(base2_2,/col,map=1,/frame)
;
fit_ch_base=widget_base(fit_base)
fit_choose=widget_button(fit_ch_base,value='FIT LINES',font=bigfont)
;
fit_base2=widget_base(fit_base,/col,sens=0)
fit_butts=cw_bgroup(fit_base2,['Background','Choose lines','Perform Fit', $
                               'Reset','Exit'],/row,font=font)
;
wflag=[1,1]
width_base=widget_base(fit_base2,/row)
width_l=widget_label(width_base,value='SAME WIDTH?',/align_left,font=font)
width=CW_BGROUP(width_base,['Yes','No'], $
                set_value=wflag[0], $
                /row,/exclusive,font=font)
;
;pick_width=cw_bgroup(fit_base2,label_left='PICK WIDTHS?',['Yes','No'], $
;                     set_value=wflag[1],/row,/exclusive,font=font)
;
nback=2
backg=0.
back_base=widget_base(fit_base2,/row)
back_l=widget_label(back_base,value='BACKGROUND',/align_left,font=font)
back=cw_bgroup(back_base,['Constant','Linear'],/row,set_value=nback-1,/excl,font=font)

wr_set=data.set_width_range
fix_back_base=widget_base(fit_base2,/row)
fix_back_l=widget_label(fix_back_base,value='Restrict FWHM range?',/align_left,font=font)
fix_back=cw_bgroup(fix_back_base,['Yes','No'],/row,set_value=1-wr_set,/excl,font=font)
;
IF wr_set EQ 1 THEN sens=1 ELSE sens=0
fix_back_base2=widget_base(fit_base2,/row)
fix_back_min_lbl=widget_label(fix_back_base2,value='Min FWHM',/align_left,font=font)
fix_back_min_txt=widget_text(fix_back_base2,value=trim(data.width_range[0]), $
                       font=font,xsiz=8,/editable,sensitive=sens)
fix_back_max_lbl=widget_label(fix_back_base2,value='Max FWHM',/align_left,font=font)
fix_back_max_txt=widget_text(fix_back_base2,value=trim(data.width_range[1]), $
                       font=font,xsiz=8,/editable,sensitive=sens)


;
; EXIT AND ZOOM BUTTONS
; ---------------------
mb_base=widget_base(base2_2,/col,sens=1)
main_butts=CW_BGROUP(mb_base, $
                     ['ZOOM','UNZOOM','EXIT'], $
                     /row,/frame,font=bigfont)

space_txt=widget_label(base2_2,value='',font=bigfont)
email_txt=widget_label(base2_2,font=font, $
                     value='Please report errors to pyoung@ssd5.nrl.navy.mil', $
                      /align_left)

spec_plot = WIDGET_DRAW(BASE2_1, $
                       RETAIN=1, $
                       uval='spec_plot', $
                       XSIZE=round(650*plot_scale), $
                       YSIZE=round(500*plot_scale),/button_events, $
                       sensitive=1)

help_txt=widget_text(base2_1,font=font, $
                     value='Help messages will appear in this window', $
                    ysiz=2)
;
; RESIDUALS PLOT
;
res_plot=WIDGET_DRAW(BASE2_1, $
                       RETAIN=1, $
                       uval='res_plot', $
                       XSIZE=round(650*plot_scale), $
                       YSIZE=round(150*plot_scale))

state={spec_plot: spec_plot, width:width, back:back, $
       main_butts:main_butts, pix_base2: pix_base2, pix_type:pix_type, $
       pix_choose:pix_choose, pix_exit:pix_exit, pparams:pparams, $
       fit_butts:fit_butts, fit_base2:fit_base2, base1:base1, $
       fit_choose:fit_choose, fit_ch_base: fit_ch_base, $
       pix_ch_base:pix_ch_base,mb_base:mb_base, help_txt:help_txt, $
       fit_info:fit_info, $
       wid_data: wid_data, data: data, sg_base:sg_base, $
       fix_back: fix_back, fix_back_max_txt: fix_back_max_txt, $
       fix_back_min_txt: fix_back_min_txt}

WIDGET_CONTROL, sg_base, /REALIZE, set_uvalue=state

WIDGET_CONTROL, spec_plot, GET_VALUE=spec_plot_id
WIDGET_CONTROL, res_plot, GET_VALUE=res_plot_id

state.wid_data.spec_plot_id=spec_plot_id
state.wid_data.res_plot_id=res_plot_id
WIDGET_CONTROL, sg_base, /REALIZE, set_uvalue=state

plot_the_spec,state,/restore

XMANAGER, 'sg_base', sg_base, group=group

END

;-------------------------------
PRO spec_gauss_widget, xx, yy, ee, qq, missing=missing, $
                       qqmin=qqmin, qqmax=qqmax, qqset=qqset, $
                       def_width=def_width, info=info, $
                       outname=outname, line_list=line_list, $
                       angpix=angpix, fitfunc=fitfunc, $
                       xrange=xrange, yrange=yrange, $
                       width_range=width_range, set_width_range=set_width_range, $
                       parinfo_wvl_step=parinfo_wvl_step, int_factor=int_factor, $
                       int_positive=int_positive


;
; the following prevents the missing data value being remembered from a 
; previous call to the routine.
;
IF n_elements(miss2) NE 0 THEN junk=temporary(miss2)
IF n_elements(missing) NE 0 THEN miss2=missing ELSE miss2=-100.
IF n_elements(llist) NE 0 THEN junk=temporary(llist)

;
; Set some arbitrary width range if not specified by user.
;
IF keyword_set(set_width_range) EQ 1 AND n_elements(width_range) EQ 0 THEN width_range=[0.1,2.0]
IF n_elements(width_range) EQ 0 THEN width_range=[0,0]

IF n_elements(line_list) NE 0 THEN llist=line_list ELSE llist=-1

IF n_elements(outname) EQ 0 THEN outname2='spec_gauss_fits.txt' $
   ELSE outname2=outname


IF NOT keyword_set(int_positive) THEN int_positive=0

;
; if data quality (qq) is not set, then the default value is an array of
; same size of xx with value 1.
;
IF n_elements(qq) EQ 0 THEN qq=intarr(n_elements(xx))+1
IF n_elements(qqmin) EQ 0 THEN qqmin=0
IF n_elements(qqmax) EQ 0 THEN qqmax=max(qq)
IF n_elements(qqset) EQ 0 THEN qqset=0

IF n_elements(info) EQ 0 THEN info=''

IF n_elements(def_width) EQ 0. THEN d_width=0.0 $
   ELSE d_width=def_width

IF n_elements(fitfunc) EQ 0 THEN fitfunc='gauss_sg'

yy2=yy
ee2=ee
IF n_elements(int_factor) EQ 0 THEN BEGIN
  int_factor=1.0
ENDIF ELSE BEGIN
  k=where(yy NE miss2,nk)
  IF nk GT 0 THEN BEGIN
    yy2[k]=yy2[k]*int_factor
    ee2[k]=ee2[k]*int_factor
  ENDIF 
ENDELSE 

IF n_elements(xrange) EQ 0 THEN BEGIN
  i=where(yy2 NE miss2,ni)
  xrange=[min(xx[i])-1,max(xx[i])+1]
ENDIF
IF n_elements(yrange) EQ 0 THEN BEGIN
  i=where(yy2 NE miss2,ni)
  yrange=[min(yy2[i]),max(yy2[i])*1.1]
ENDIF 

IF n_elements(parinfo_wvl_step) EQ 0 THEN parinfo_wvl_step=0.

data={xx: xx, yy:yy2, ee: ee2, $
      qq: qq, qqmin: qqmin, qqmax: qqmax, qqset: qqset,$
      miss: miss2, d_width: d_width, info: info,  $
      outname: outname2, line_list: llist, angpix: keyword_set(angpix), $
      fitfunc: fitfunc, xrange: xrange, yrange: yrange, $
      width_range: width_range, set_width_range: keyword_set(set_width_range), $
      parinfo_wvl_step: parinfo_wvl_step, chi2: 0., int_factor: int_factor, $
      int_positive: int_positive }

device,dec=0
tvlct,r,g,b,/get
loadct,0
tvlct,[[255],[255],[0]],50   ; 50 is yellow
tvlct,[[255],[50],[50]],51   ; 51 is red
tvlct,[[100],[100],[255]],52   ; 52 is blue

gauss_widget, data=data

;
; restore original colour scheme before exiting
;
tvlct,r,g,b

END
