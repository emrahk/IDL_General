;+
; Name:
;      PLOT_ZOOM
;
; Purpose:
;      Wrapper of PLOT with zoom function.
;
; Category:
;      Plot
;
; Calling sequence:
;      PLOT_ZOOM, x, y [ /PRINT, ZOOM_FACTOR=zoom_factor ,  
;                 all keywords accepted by PLOT , 
;                 O_FUNCTION=o_function , O_COLOR=o_color , 
;                 O_LINESTYLE=o_linestyle , O_PSYM=o_psym ,
;                 O_SYMSIZE=o_symsize , O_THICK=o_thick ,
;                 O_MIN_VALUE=o_min_value , O_MAX_VALUE=o_max_value
;
; Input:
;      x : abscissa
;      y : ordinate
;
; Keyword parameters:
;      PRINT: if given, prints the current cursor position
;      ZOOM_FACTOR: zoom factor (e.g. 0.1 will zoom in/out by 10%)
;      All valid graphic keywords accepted by PLOT
;      O_FUNCTION : values of the function to be overplotted
;      O_COLOR    : same as COLOR keyword, but for the overplotted function
;      O_LINESTYLE:    "  LINESTYLE  "
;      O_NSUM     :    "     NSUM    "
;      O_PSYM     :    "     PSYM    "
;      O_SYMSIZE  :    "   SYMSIZE   "
;      O_THICK    :    "    THICK    "
;      O_MIN_VALUE:    "  MIN_VALUE  "
;      O_MAX_VALUE:    "  MAX_VALUE  "
;
; Output:
;      Plot
;
; Common blocks:
;      None
;
; Calls:
;      XYCURSOR,PLOT,OPLOT
;
; Description:
;        Wrapper of PLOT routine; left and middle buttons permit zooming 
;      in and out, respectively, the plot area. The PRINT keyword permits 
;      to print current cursor coordinates. Right button exits.
;        Note that PLOT is called with XRANGE and YRANGE keywords. If those 
;      keyword are also given in the input, the latter values take precedence 
;      over the values computed by PLOT_ZOOM, i.e. no zoom function is 
;      possible for that axis. This fact can be used, for example, to zoom on 
;      only one axis. 
;      All PLOT keywords applicable to OPLOT are used for the functio 
;      given by O_FUNCTION; it is however possible to give specific values 
;      for some keywords through the O_* style keywords. 
;
; Side effects:
;      None
;
; Restrictions:
;      - Do not use within draw widgets (see documentation of routine XYCURSOR).
;      - Maximum zoom factor allowed: 90%
;      - It doesn't work well with multiplot settings of !P.MULTI.
;
; Modification history:
;      V. Andretta, 21/Feb/1998 - Created
;      V. Andretta, 24/Feb/1998 - Handles cursor through XYCURSOR
;      V. Andretta, 25/Feb/1998 - Forces XSTYLE=1 and YSTYLE=1 (some values 
;        of !X.STYLE and !Y.STYLE could interfere with zooming)
;      V. Andretta, 10/Jun/1998 - Uses system defaults for undefined O_* 
;        keywords (required by IDL versions earlier than 5.0)
;
; Contact:
;      andretta@gsfc.nasa.gov
;-
;===============================================================================
;
  pro PLOT_ZOOM,x_in,y_in $
               ,O_FUNCTION = o_y         $
               ,O_COLOR    = o_color     $
               ,O_LINESTYLE= o_linestyle $
               ,O_NSUM     = o_nsum      $
               ,O_PSYM     = o_psym      $
               ,O_SYMSIZE  = o_symsize   $
               ,O_THICK    = o_thick     $
               ,O_MIN_VALUE= o_min_value $
               ,O_MAX_VALUE= o_max_value $
               ,PRINT=print,ZOOM_FACTOR=zoom_factor $
               ,_EXTRA=extra

  on_error,2

;check input

  if n_params() lt 2 then begin
    x=lindgen(n_elements(x_in))
    y=x_in
  endif else begin
    x=x_in
    y=y_in
  endelse


;some definitions and defaults

;zoom factor
  if n_elements(zoom_factor) eq 0 then $
    inc_factor=0.2 $                    ; zoom in/out by 20%
  else $
    inc_factor=abs(zoom_factor(0))<0.90 ; max zoom factor: 90%

;set up for PLOT during the zoom loop 
;default values:
  z_xstyle=1
  z_ystyle=1
  if n_elements(extra) gt 0 then if n_tags(extra) gt 0 then begin
;start up with same settings as for the first plot...
    z_extra=extra
;get tag names:
    kwd=tag_names(z_extra)
;mask XSTYLE and YSTYLE to set the following bits: 
; bit 0 -> 1 (exact ranges)
; bit 1 -> 0 (no extended ranges)
; bit 4 -> 1 (equivalent to YNOZERO=1)
;using 29=10111 as mask to set bit 1 to 0, and 17=10001 to set bit 0 and 4
;XSTYLE:
    tag=where(strmid(kwd,0,2) eq 'XS') & tag=tag(0)
    if tag ge 0 then begin
      z_xstyle=(fix(z_extra.(tag)) and 29) or 17
      z_extra.(tag)=z_xstyle
    endif
;YSTYLE:
    tag=where(strmid(kwd,0,2) eq 'YS') & tag=tag(0)
    if tag ge 0 then begin
      z_ystyle=(fix(z_extra.(tag)) and 29) or 17
      z_extra.(tag)=z_ystyle
    endif
;YNOZERO=1:
    tag=where(strmid(kwd,0,2) eq 'YN') & tag=tag(0)
    if tag ge 0 then z_extra.(tag)=1
  endif

;set up for OPLOT
  o_plot=n_elements(o_y) ne 0
  if o_plot and n_elements(extra) gt 0 then if n_tags(extra) gt 0 then begin
;start up with same settings as for the main plot...
    o_extra=extra
;... but if some keywords have been given specifically for OPLOT, change 
;the corresponding _EXTRA tags (otherwise it would override the O_* keyword):
;get tag names:
    kwd=tag_names(o_extra)
;now look for the right tag (using smallest number of characters)
;O_COLOR:
    tag=where(strmid(kwd,0,2) eq 'CO') & tag=tag(0)
    if n_elements(o_color) ne 0     and tag ge 0 then o_extra.(tag)=o_color
;O_LINESTYLE:
    tag=where(strmid(kwd,0,1) eq 'L') & tag=tag(0)
    if n_elements(o_linestyle) ne 0 and tag ge 0 then o_extra.(tag)=o_linestyle
;O_MAX_VALUE:
    tag=where(strmid(kwd,0,2) eq 'MA') & tag=tag(0)
    if n_elements(o_max_value) ne 0 and tag ge 0 then o_extra.(tag)=o_max_value
;O_MIN_VALUE:
    tag=where(strmid(kwd,0,2) eq 'MI') & tag=tag(0)
    if n_elements(o_min_value) ne 0 and tag ge 0 then o_extra.(tag)=o_min_value
;O_NSUM:
    tag=where(strmid(kwd,0,2) eq 'NS') & tag=tag(0)
    if n_elements(o_nsum) ne 0      and tag ge 0 then o_extra.(tag)=o_nsum
;O_PSYM:
    tag=where(strmid(kwd,0,2) eq 'PS') & tag=tag(0)
    if n_elements(o_psym) ne 0      and tag ge 0 then o_extra.(tag)=o_psym
;O_SYMSIZE:
    tag=where(strmid(kwd,0,2) eq 'SY') & tag=tag(0)
    if n_elements(o_symsize) ne 0   and tag ge 0 then o_extra.(tag)=o_symsize
;O_THICK:
    tag=where(strmid(kwd,0,2) eq 'TH') & tag=tag(0)
    if n_elements(o_thick) ne 0     and tag ge 0 then o_extra.(tag)=o_thick
  endif
;In IDL versions earlier than 5, OPLOT will complain if the O_* keyword 
;are not defined. This segment of the code takes care of that problem.
  IDL_ver=fix((str_sep(!version.release,'.'))(0))
  if o_plot and IDL_ver lt 5 then begin
;O_COLOR:
    if n_elements(o_color) eq 0     then o_color=!p.color
;O_LINESTYLE:
    if n_elements(o_linestyle) eq 0 then o_linestyle=!p.linestyle
;O_MAX_VALUE:
    if n_elements(o_max_value) eq 0 then o_max_value=max(o_y)
;O_MIN_VALUE:
    if n_elements(o_min_value) eq 0 then o_min_value=min(o_y)
;O_NSUM:
    if n_elements(o_nsum) eq 0      then o_nsum=!p.nsum
;O_PSYM:
    if n_elements(o_psym) eq 0      then o_psym=!p.psym
;O_SYMSIZE:
    if n_elements(o_symsize) eq 0   then o_symsize=!p.symsize
;O_THICK:
    if n_elements(o_thick) eq 0     then o_thick=!p.thick
  endif


;startup

  plot,x,y,_EXTRA=extra
  if o_plot then oplot,x,o_y,COLOR=o_color,LINESTYLE=o_linestyle $
    ,NSUM=o_nsum,PSYM=o_psym,SYMSIZE=o_symsize,THICK=o_thick $
    ,MIN_VALUE=o_min_value,MAX_VALUE=o_max_value,_EXTRA=o_extra
  print,'%I> PLOT_ZOOM: LEFT: Zoom in;  MIDDLE: Zoom out; RIGHT: Exit.'
  print_cursor=keyword_set(print)


;main cycle: ends when rightmost button is pressed and released

  repeat begin
;wait for a mouse button to be pressed and then released
    XYCURSOR,xc,yc,BUTTON=button,PRINT=print,/NO_LF
    end_zoom=button eq 4
    if not end_zoom then begin
;LEFT or MIDDLE buttons: zoom in/out
      case button of 
        1:    factor=1.-inc_factor ; LEFT button   (zoom in)
        2:    factor=1.+inc_factor ; MIDDLE button (zoom out)
        else: factor=1.            ; Should never occur. 
      endcase
      if !x.type eq 1 then $
        xrange=xc*10.^(factor*[-0.5,0.5]*(!x.crange(1)-!x.crange(0))) $
      else $
        xrange=xc+factor*[-0.5,0.5]*(!x.crange(1)-!x.crange(0))
      if !y.type eq 1 then $
        yrange=yc*10.^(factor*[-0.5,0.5]*(!y.crange(1)-!y.crange(0))) $
      else $
        yrange=yc+factor*[-0.5,0.5]*(!y.crange(1)-!y.crange(0))
      plot,x,y,_EXTRA=z_extra,xrange=xrange,yrange=yrange $
          ,xstyle=z_xstyle,ystyle=z_ystyle
      if o_plot then oplot,x,o_y,COLOR=o_color,LINESTYLE=o_linestyle $
        ,NSUM=o_nsum,PSYM=o_psym,SYMSIZE=o_symsize,THICK=o_thick $
        ,MIN_VALUE=o_min_value,MAX_VALUE=o_max_value,_EXTRA=o_extra
    endif else $
;RIGHT button: line feed and exit
      if print_cursor then print,form='($,/)'
  endrep until end_zoom


;return

  return
  end

