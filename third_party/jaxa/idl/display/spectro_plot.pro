;---------------------------------------------------------------------------
; Document name: spectro_plot
; Time-stamp: <Fri Jul 15 2005 11:52:15 csillag auriga.ethz.ch>
;---------------------------------------------------------------------------
;+
;NAME:
;   spectro_plot
;
;PROJECT:
;   Generic Display utilities
;
;CATEGORY:
;   /ssw/gen/display
;
;PURPOSE:
;       This routine displays 2d arrays as a function of
;       time. This program merges functionalities of the older programs 
;       tplot, rapp_plot_spectrogram,  and show_image. 
;       It is a complete rewrite of the spectro_plot
;       utility that was built on show_image uniquely.
;       This current version just does some preparation for spectro_plot2,
;       which actualy does all the work. It is the non-object oriented
;       interface that can be uesed easily from the command line interface.
;
;CALLING SEQUENCE:
;       1st form:
;       --------
;       spectro_plot, image1, xaxis1, yaxis1, $
;                     image2, xaxis2, yaxis2, $
;                     ....
;                     image4, xaxis4, yaxis4
;
;       2nd form:
;       --------
;       spectro_plot, struct1, struct2, .... struct12
;
;INPUT:
;       image1...image4: 2d arrays
;       xaxis1...xaxis4: 1d array containing the time values
;                        associated with the xaxis of the array
;       yaxis1...yaxis4: 1d array containing the y-values (whatever
;                        they are) associated with the xaxis of the
;                        array
;       struct1...struct12: structures of the form
;                        {spectrogram:fltarr(nx,ny), x: fltarr(nx), y:fltarr(ny)}
;
;KEYWORDS:
;       CBAR: displays a color table with the data, default: no color bar.
;       INVERT: shows data inverted with the color table
;       NO_INTERPOLATE: supresses the interpolation of the image
;                       Note that this might lead to a wrong display,
;                       as the pixels might not be aligned with the
;                       y- and x-axis values.
;       NO_UT: suppresses the use of utplot and plots the time axis
;              with normal decimal values.
;       PERCENT: ignores the last given percent of the image when scaling the data
;                range to the color table.
;       POSTSCRIPT: Sends the output to a postscript file (same as calling ps,
;           /color)
;       XRANGE: sets the time limits of the xaxis window (2-element
;               array). 
;       YLOG: plots the axis and the data with a logarithmic scale
;       YRANGE: a 2xn_plots element setting the range to display
;       ZEXP: applies exp() to the data before display
;       ZLOG: applies log() to the data before display
;
;       ... and all the keywords acccepted by PLOT
;
;HISTORY:
;       acs jul 2005 - revised doc, but needs more on that, cbar is not the
;                      default for display.
;       acs march 2005 - many things moved to spectro_plot2, by popular
;                        demand, spectro_plot is a wrapper that does not need
;                        any objects any more.
;       acs aug 2004 - corrected a  problem w/ the time passed and
;                      utbase
;       acs june 2004- wrapperization, see spectro_plot_obj and spectrogram
;                      for more interesting code.
;       acs july 2003: corrected way of displaying spectrograms with
;                      only few channels
;       acs june 2003: now fully featured xstyle and ystyle keywords
;       acs may 2003: fixing the x/y range problem and refactoring session
;       ACS April 2003: including feedback from kim & paolo
;       ACS March 2003: after meeting with AOBenz, PSG and PG extended version
;                       with YINTEGRATE, NO_INTERPOLATE, YRANGE
;                       PS capabilities checked
;       ACS Feb 2003   : make sure it works with other plot routines
;       ETH Zurich       for integration into the plotman utilities
;                        (i.e. zooming etc )
;                        csillag@ssl.berkeley.edu. This is basically a
;                        merge between the functions of Pascal
;                        Saint-Hilaire, Paolo Grigis and Peter Messmer
;                        with the show_image
;                        - ps option modified to be able to set the ps
;                        option outside of the routine
;                        - replacement of the call to utplot with the
;                        set_utaxis and then axis
;                        - interpolation taken from Davin (tplot)
;                        - compatibility with tplot
;                        - utplot is now default
;                        - full logarithm implemented
;       ACS Jan 2003: merged several version of the same program into
;                     the first prototy of this generic
;                     routines. Contributions from all people listed above.
;
;--------------------------------------------------------------------------------

PRO spectro_plot, param0, param1, param2, param3, $
                  param4, param5, param6, $
                  param7, param8, param9, $
                  param10, param11, $
                  CBAR = cbar, $
                  CHARSIZE=charsize, $
                  XCHARSIZE = xcharsize, $
                  XRANGE=xrange, $
                  XTITLE = xtitle, $
                  TIMERANGE=timerange, $
                  POSTSCRIPT=POSTSCRIPT, $
                  verbose = verbose, $
                  _EXTRA=extra


n_par = N_Params()

if n_par eq 0 then begin 
    message, 'Usage: spectro_plot, image [, xaxis, yaxis] ', /cont
    return
endif

; do not use timerange any more
if valid_range( timerange ) then xrange = timerange

checkvar, cbar, 0

if n_par le 3 and not is_struct( param0 ) then begin 
    spectro_plot2, param0, param1, param2, _extra = extra, $
                   cbar = cbar, $
                   charsize = charsize, $
                   xcharsize = xcharsize, $
                   xrange = xrange, $
                   xtitle = xtitle, $
                   verbose = verbose
    return
endif else if n_par eq 1 and is_struct( param0 ) then begin 
    struct2spectrogram, param0, spectro, x, y
    spectro_plot2, spectro,x,y, _extra = extra, $
                   cbar = cbar, $
                   charsize = charsize, $
                   xcharsize = xcharsize, $
                   xrange = xrange, $
                   xtitle = xtitle, $
                   verbose = verbose
    return
endif

; if we are here we have more than one input
yes_struct = is_struct( param0 )
IF NOT yes_struct THEN n_par = ((n_par-1)/3)+1

; transform inpt params into ptrarr
spectros = ptrarr( n_par, /alloc )

checkvar, verbose, 1

for i=0, n_par-1 do begin 
  
    if not yes_struct then begin 
        exec_cmd = '*spectros[' + strtrim( i, 2 ) + '] = ' + $
                   '{spectrogram: param' + strtrim( i*3, 2 ) + $
                   ', xaxis: param' + strtrim( i*3+1, 2 ) + $
                   ', yaxis: param' + strtrim( i*3+2, 2 ) + '}'
    endif else begin 
        exec_cmd =  'struct2spectrogram, param'  + strtrim( i, 2 ) + ',sp,x,y, /verb'
    endelse
    ok = Execute(  exec_cmd  )
    if not ok then begin 
        message, 'problem parsing parameters', /cont
        print, exec_cmd
        return
    endif else if yes_struct then begin 
        *spectros[i]={spectrogram: sp, xaxis:x, yaxis:y}
    endif

endfor

if not valid_range( XRANGE ) then begin 
    FOR i=0, n_par-1 DO BEGIN
        this_xrange = minmax( (*spectros[i]).xaxis )
        IF i EQ 0  THEN BEGIN
            xrange = this_xrange
        ENDIF ELSE BEGIN
            xrange = [xrange[0] > this_xrange[0], xrange[1] < this_xrange[1]]
        endelse
    ENDfor
endif

IF KEYWORD_SET( POSTSCRIPT ) THEN ps, /color

yes_multi = 1
old_multi = !p.multi
!p.multi = [0, 0, n_par]
cbar = 0

; for several plots we only annotate the last one.
checkvar, xtitle, ''
checkvar, charsize, 0
checkvar, xcharsize, 0
FOR i=0, n_par-1 DO BEGIN

    this_spectro = *spectros[i]
    if exist( extra ) then begin 
        this_extra = str_tagarray2scalar( extra, i )
    endif

    this_xtitle=i LT (n_par-1) ? ' ' : xtitle
    this_xcharsize = xcharsize
    this_xcharsize=i LT (n_par-1) ? 0.001 : this_xcharsize

    spectro_plot2, this_spectro.spectrogram, $
                   this_spectro.xaxis, this_spectro.yaxis, $
                   _EXTRA=this_extra, $
                   charsize = charsize, $
                   xcharsize = this_xcharsize, $
                   xtitle = xtitle, $
                   xrange = xrange, $
                   yes_nextone = (i gt 0 ), cbar = 0
    ;;; cbar does not work yet with multiple plots...
    
    delvarx, this_xcharsize

ENDFOR

IF KEYWORD_SET(POSTSCRIPT) THEN psclose
!p.multi = old_multi

END
;--------------------------------------------------------------------------------
