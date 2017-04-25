;+
; Project      : HESSI
;
; Name         : SPECPLOT__DEFINE
;
; Purpose      : Define a general spectogram plot class
;
; Category     : objects
;
; Syntax       : IDL> new=obj_new('specplot')
;
; Modifications: 22-May-02, Zarro (L-3Com/GSFC) - written
;                 8-Oct-2002, Kim.
;                 - Modified plot method to make it compatible with plotman
;                   Added dev2data method to convert between device and data coords.
;                 - added speed-up checks for keywords
;                 5-Feb-03, Zarro (EER/GSFC) - fixed DRANGE bug,
;                   added FREQUENCY, FRANGE, FUNIT keywords.
;                 7-May-03, Zarro (EER/GSC) - removed YLOG keyword from SPECPLOT
;                 method since already passed thru EXTRA.
;                 21-Mar-03, Kim.  Many changes to call new version of spectro_plot
;                 10-Oct-2003, Kim.  Add call to set, _extra=extra in plot, remove log
;                   from keywords in plot method, and add (Log) or (Exp) to title if
;                   log_scale or exp_scale is set
;                 11-April-2005, Kim.  Added call to run addplot_name routine after plotting.
;                   (addplot_name and addplot_arg are properties of xyplot obj)
;                 16-June-2005, Andre and Kim. Lots of new properties, major changes to plot,
;                   set, set_plot.
;                 12-Oct-2006, Kim. In set_plot, if set timerange to xrange, adjust for
;                   utbase.
;                 04-Aug-2009, Kim.  Added _extra keyword to cleanup, and pass through to utplot::cleanup
;                 27-Oct-2014, Kim. Remove xtitle, ytitle, title - they are now properties of xyplot obj 
;                 20-Jan-2015, Kim. Correct 27-oct fix - forgot to comment out title in set method keywords                  
;
; Contact     : dzarro@solar.stanford.edu
;-

function specplot::init,xdata,ydata,_ref_extra=extra

if ~self->utplot::init(_extra=extra) then return,0

self.plot_type='specplot'
self.dim1_sel=0b
if ~self->have_plot_spectrogram() then begin
 self.plot_type='utplot'
 self.dim1_sel=1b
endif
; acs 2004-04 keep track of the style
self->set, xstyle = !x.style, ystyle = !y.style

self.cbar = 1

if exist(xdata) or exist(ydata) or is_string(extra) then $
 self->set,xdata=xdata,ydata=ydata,_extra=extra

dprint,'% SPECPLOT::INIT'

return,1

end

;-----------------------------------------------------------------------
;--destroy object

pro specplot::cleanup, _extra=extra
dprint,'% SPECPLOT::CLEANUP'

self->utplot::cleanup, _extra=extra
return

end

;----------------------------------------------------------------------------
;--set data and plot properties

pro specplot::set,_ref_extra=extra,$
            dim1_fact = dim1_fact, $
            dim1_vals=dim1_vals,$
            frequency=frequency,$
            funit=funit,$
            frange=frange, $
            hist_equal_percent=hist_equal_percent, $
            id = id, $
            no_defaults = no_defaults, $
            no_ut = no_ut, $
            spec_struct = spec_struct, $
            spectrogram = spectrogram, $
            spectrum_axis = spectrum_axis, $
            spectrum_unit = spectrum_unit, $
            spectrum_range = spectrum_range, $
            time_axis = time_axis, $
;            title = title, $
            xdata = xdata, $
            ydata = ydata;, $
;            ytitle = ytitle, $
;            xtitle = xtitle


; acs no_ut 2004-07-20
if is_number( no_ut ) then self.no_ut = no_ut > 0 < 1

; acs data type inputs 2004-04
if exist( spec_struct ) then struct2spectrogram, spec_struct, ydata, xdata, dim1_vals

if exist( spectrogram ) then ydata = spectrogram

if exist( time_axis ) then  xdata = time_axis

if exist( spectrum_axis ) then dim1_vals = spectrum_axis

if exist( spectrum_unit ) then dim1_unit = spectrum_unit

if exist( spectrum_range ) then yrange = spectrum_range

; pass in extra in call below instead of separately. 5/9/03
;if is_string(extra) then self->utplot::set,_extra=extra

; acs 2004-04 added the no_defaults keyword
if is_string(extra) and ~keyword_set( no_defaults ) then self->set_plot,_extra=extra

if exist(frequency) then dim1_vals=frequency ; let frequency take precedence

; acs 2004-04 adds funit and frange for compatibility with other programs
if exist( funit ) then dim1_unit = funit

if exist( frange ) then yrange = frange

; acs 2004-04 mmmm this will disappear as we have offset and scale in
; xyplot -- did not realize this at the first place
if exist( dim1_fact ) then begin
    ptr_free, self.dim1_fact
    if dim1_fact[0] ne 0 then begin
        self.dim1_fact = ptr_new( dim1_fact )
    endif
endif

; acs 2004-04 this is useful for enhancing contrasts in solar radio
; spectrograms
if is_number( hist_equal_percent ) then self.hist_equal_percent = hist_equal_percent

;acs 2004-04 wants to keep this in the object for plotting multiple
;spectrograms
; acs 2004-05-03 in fact title must be stored in id.
;if is_string( title ) then id = title
;
;if is_string( ytitle ) then self.ytitle = ytitle
;if is_string( xtitle ) then self.xtitle = xtitle

self->utplot::set,_extra=extra, dim1_vals=dim1_vals, $
  dim1_unit=dim1_unit,yrange=yrange, $
  xdata = xdata, ydata = ydata, $
  id = id, $
  no_defaults = no_defaults

return & end

;----------------------------------------------------------------------------
;--set plot properties

pro specplot::set_plot, log_scale=log_scale, exp_scale=exp_scale, $
  interpolate=interpolate, integrate=integrate, cbar=cbar, _extra=extra, $
  xstyle = xstyle, ystyle = ystyle, xrange = xrange, timerange = timerange, drange = drange

; acs 2004-04 adds interploate xstyle ystyle xrange timerange drange
if exist( drange ) then self.drange = drange

if is_number(log_scale) then self.log_scale = 0b > log_scale < 1b
if is_number(exp_scale) then self.exp_scale = 0b > exp_scale < 1b
; -- acs 2004-04
if is_number(xstyle) then self.xstyle = xstyle
if is_number(ystyle) then self.ystyle = ystyle

if self.log_scale and self.exp_scale then begin
 message,'conflicting keywords (log scale, exp scale) - neither used',/cont
 self.log_scale=0b & self.exp_scale=0b
endif

; acs 2004-04 changed from no_interpolate to interpolate as no
; interpolate is now the default
if is_number(interpolate) then begin
    self.interpolate = abs( interpolate ) mod 2
endif

; probably we need to hanlde it as interpolate (w/ mod)
if is_number(integrate) then self.integrate = 0b > integrate < 1b

if is_number(cbar) then self.cbar = 0b > cbar < 1b

; acs 2004-04
; timerange has priority over xrange

if exist( xrange ) and ~exist( timerange ) then $
	timerange = (max(xrange) gt 1.e6) ? xrange : anytim(self->get(/utbase))+xrange
if exist( timerange ) then self->utplot::set,timerange=timerange
if is_struct(extra) then self->utplot::set_plot,_extra=extra

end

;---------------------------------------------------------------------------
;-- check for spectrogram plotter in !path

; Unfortunately, most of the cool spectrogram plotting stuff
; is buried in $SSW/radio/ethz. It should all be moved into $SSW/gen
; but I don't have the time

function specplot::have_plot_spectrogram,err=err

err=''
err1='Spectrogram plotter unavailable.'
err2='RADIO/ETHZ IDL branch of SSW needs to be installed.'
err3='Defaulting to lightcurve plots.'
plotter='spectro_plot'

if ~have_proc(plotter) then begin
 eth=local_name('$SSW/radio/ethz/idl')
 if is_dir(eth) then begin
  add_path,eth,/expand,/append
  if ~have_proc(plotter) then err=err1
 endif else err=err2
endif

if err eq '' then return,1b
message,err,/cont
if allow_windows() then xack,[err,err3],/suppress

return,0b

end

;-----------------------------------------------------------------------------
;-- spectrogram plot_cmd method

pro specplot::plot_cmd, x,y,overlay=overlay,_extra=extra
if self->get(/no_ut) then self->xyplot::plot_cmd, x,y,overlay=overlay,_extra=extra else $
	self->utplot::plot_cmd, x,y,overlay=overlay,_extra=extra
end


;-----------------------------------------------------------------------------
;-- spectrogram plot method

pro specplot::plot,$
            dim1_fact = dim1_fact, $
            dim1_use = dim1_use, $
            err_msg=err_msg, $
            plot_type = plot_type, $
            integrate=integrate, $
            yintegrate = yintegrate, $
            xstyle = xstyle, ystyle = ystyle, $
            _extra=extra

; acs 2004-04 plenty of new keywords (might need some cleaning up
; soon): dim_1fact dim1_use (passed to xyplot) plot_type yintegrate
; xstyle ystyle

err_msg=''

; from now on we use set to change the defaults. in plot, the values
; are passed directly to the plotting procedures, i.e. they are not stored.
;if keyword_set(extra) then self->set, _extra=extra

; acs 2004-04 ok not this is all new til ;-*-*-*

if ~exist(plot_type) then begin
    plot_type_local=self->get(/plot_type)
endif else begin
    plot_type_local=plot_type
endelse

integrate = keyword_set(yintegrate) ? 1 : (keyword_set(integrate) ? 1 : self->get( /integrate ))

title = self->get( /title )

; this might move to xyplot?
if ~exist( xstyle ) then xstyle = self->get( /xstyle )
if ~exist( ystyle ) then ystyle = self->get( /ystyle )
if ~exist( ytitle ) then ytitle = self->get( /ytitle )

if plot_type_local ne 'specplot' or integrate ne 0 then begin

    ny = self->get(/ny)
    if ~exist( dim1_use ) then begin
        this_dim1_use =  self->getprop( /dim1_use )
    endif else begin
        this_dim1_use = dim1_use
    endelse
    if ~exist( dim1_fact ) then begin
        dim1_fact =  self->getprop( /dim1_fact )
    endif
    if size( dim1_fact, /type ) ne 7 then begin
        ydata = self->get(/ydata)
        ny = self->get(/ny)
        this_dim1_fact = fltarr(ny ) + 1
        this_dim1_fact[this_dim1_use] = dim1_fact[0:n_elements(this_dim1_use)-1]
        this_dim1_fact = transpose( reproduce( this_dim1_fact, self->get( /nx )  ))
        ydata = ydata*this_dim1_fact
        self->set, ydata = ydata
    endif

    IF integrate ne 0 THEN BEGIN
        ydata = self->get( /ydata )
        yaxis = self->get( /dim1_vals )
        dim1_use = self->getprop( /dim1_use )
        IF valid_range( yintegrate ) THEN BEGIN
            im_y_limit = value_locate( yaxis, yintegrate ) > 0
            IF im_y_limit[0] GT im_y_limit[1] THEN im_y_limit = im_y_limit[[1, 0]]
            yint_range = 'Y: ' + format_intervals(yintegrate)
        ENDIF ELSE BEGIN
            im_y_limit = [0, n_elements( yaxis )-1 ]
            yint_range = 'full Y range'
        ENDELSE
        if im_y_limit[0] ne im_y_limit[1] then begin
            this_ydata = Total( ydata[*, im_y_limit[0]:im_y_limit[1]], 2 )
            this_yaxis = average( yaxis[im_y_limit[0]:im_y_limit[1]] )
        endif
        self->set, ydata = this_ydata, dim1_vals = [this_yaxis]
        this_dim1_use = 0
        ; if title is blank string, then means we don't want a title, so don't append to it
        title = title eq ' ' ? ' ' : title + ' Integrated over ' + yint_range
        ytitle = 'Integrated flux'
    ENDIF

; need to change xrange or timerange?

    self->utplot::plot, err_msg=err_msg,_extra=extra, title = title, $
      dim1_use = this_dim1_use, $
      xstyle = xstyle, $
      ystyle = ystyle, $
      ytitle = ytitle

    self -> set, ydata=ydata, dim1_vals=yaxis, dim1_use=dim1_use ;, xdata=xdata
; acs
;-*-*-*-*

    return

endif else begin

	; acs 2004-04 this replaces the older call to spectro_plot
	spectro_plot2, self, _extra = extra, $
	  dim1_fact = dim1_fact, $
	  dim1_use = dim1_use, $
;	  yintegrate = yintegrate, $
	  xstyle = xstyle, ystyle = ystyle

endelse

if is_string(self.addplot_name) then call_procedure, self.addplot_name, _extra=*self.addplot_arg

return & end

;--------------------------------------------------------------------------
;-- get at underlying data arrays


function specplot::getdata,_ref_extra=extra,frequency=frequency

if arg_present(frequency) then frequency=self->get(/dim1_vals)
return,self->utplot::getdata(_extra=extra)

end

;------------------------------------------------------------------------------

pro specplot__define

; acs added many params. might need some cleanup 2004-04
temp={specplot, $
      cbar: 0b, $
      dim1_fact: ptr_new(), $ acs
      drange: [0D, 0D], $ acs
      exp_scale: 0b, $
      hist_equal_percent: 0.0, $ acs
      integrate: 0b, $ acs
      interpolate: 0b, $ acs changed from no_interpolate
      invert: 0B, $ acs
      log_scale: 0b, $
      no_ut: 0B, $ acs
      percent: 0.0, $ acs
;      title: '', $ acs
      xstyle: 0B, $ acs
      ystyle:0b, $ acs
;      ytitle: '', $ acs
;      xtitle: '', $ acs
      inherits utplot}

return
end

