;---------------------------------------------------------------------------
; Document name: spectrogram__define.pro
; Time-stamp: <Tue Aug 01 2006 16:34:51 csillag grasshopper.gsfc.nasa.gov>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI / PHOENIX
;
; NAME:
;       spectrogram__define
;
; PURPOSE:
;       This class provides the basic spectrogram object to deal with
;       spectral / temporal measurements.
;
; CATEGORY:
;       generic utilities
;
; INSTANCE CREATION:
;       o = make_spectrogram( spectrogram [, time_axis, spectrum_axis] )
;       o = spectrogram(spectrogram [, time_axis, spectrum_axis] )
;       o = spectrogram( spectrogram_struct )
;
; INPUTS:
;       spectrogram: a 2d array containing the time/energy values
;       time_axis: the time axis associated with the spectrogram.
;                  a 1 d vector with same # of elements as the x-axis
;                  of the spectrogram. the time is referenced to 1-jan-79
;                  (anytim format)
;       spectrum_axis: the spectrum axis associated with the spectrogram.
;                  a 1 d vector with same # of elements as the y-axis
;                  of the spectrogram
;       spectrogram_struct: a spectrogram structure with tags:
;                           {spectrogram, time_axis, spectrum_axis}
;
; OUTPUTS:
;       o: a spectrogram object
;
; METHODS:
;       o->set
;       result = o->get()
;
; PARAMETERS:
;
;
; EXAMPLES:
;
;
; SEE ALSO:
;       http://hessi.ssl.berkeley.edu/~csillag/software/spectrogram_howto.html
;
; HISTORY:
;        5-Jul-2008, Kim.  Changed plotman calls to use new simplified version.
;        1-aug-2006 - acs, added paneldesc parameter
;       20-jul-2004 - acs, tested for use also with spectro_plot, for backward
;                     compatibility, also reactivated the no ut option
;       mar-2004 --- acs, multiplot functionality
;       feb-2004 --- acs, association
;       jan-2004 --- acs, first design with axes, evolution from spectro_plot
;           A Csillaghy, csillag@fh-aargau.ch
;
;--------------------------------------------------------------------------
;


PRO spectrogram_test

;wshow

restore, 'focis.sav'
o = make_spectrogram( alog10(ampspect), time, freq )
o->set, xstyle=3, ystyle=3, /log_scale, /no_ut, xtitle = 'TIME(us)', YTITLE = 'FREQ (MHz)'
o->set, colortable = 39, interpolate = 0
o->plotman

o = make_spectrogram( ampspect, time, freq )
o->set, xstyle=3, ystyle=3, /log_scale
oo = o->getplotman( colortable = 5, interpolate = 0 )
o->plotman

sp_data=dist(256)
xx = findgen(256)+10
o=spectrogram(sp_data, xx, yy)
o->help
o->plot

obj_destroy, o
restore, 'focis.sav'
o = make_spectrogram( ampspect, time, freq )
o->set, xstyle=3, ystyle=3, /log_scale
oo = o->getplotman( colortable = 5, interpolate = 0 )
o->plotman

sp_data = dist( 256 )
time_axis = findgen( 256 )*0.1 + anytim( '2003/12/27 9:14' )
freq_axis = findgen( 256 )*(1000-300)/256. + 300
sp_obj=make_spectrogram(sp_data, time_axis, freq_axis)
sp_obj->help

wshow
print, 'test plotting options'
print, 'default: '
sp_obj->plot
print, 'set mew values for xs and ys'
sp_obj->set, xs=1, ys=1
print, sp_obj->get( /xs )
sp_obj->plot
print, 'now override the defaults:'
sp_obj->plot, xs=3
restore, 'focis.sav'
o = make_spectrogram( ampspect, time, freq )
o->set, xstyle=3, ystyle=3, /log_scale
oo = o->getplotman( colortable = 5, interpolate = 0 )
o->plotman

sp_obj->plot, xs=3, ys=3

print, 'try the interpolate option'
obj_destroy, sp_obj
sp_data = dist( 10 )
sp_obj=make_spectrogram(sp_data)
sp_obj->plot
sp_obj->plot, /interp

print, 'try zlog and zexp:'
sp_obj->plot, /zlog
sp_obj->plot, /zexp

print, 'try ylog:'
sp_obj->set, spectrum_axis = findgen(10) + 1
sp_obj->plot, /zexp, /ylog

obj_destroy, sp_obj
sp=make_spectrogram( dist(100),units='keV')
sp->help
obj_destroy, sp

obj_destroy, sp_obj
sp_data = dist( 256 )
time_axis = findgen( 256 )*0.1 + anytim( '2003/12/27 9:14' )
freq_axis = findgen( 256 )*(1000-300)/256. + 300
sp_obj=make_spectrogram(sp_data, time_axis, freq_axis)
sp_obj->set, units = 'keV'
sp_obj->help
sp_obj->plot
sp_obj->plot, xs=3
sp_obj->plot, xs=3, ys=3

sp_obj->plot, drange = [100,200]
sp_obj->plot, timerange = ['2003/12/27 9:14:10','2003/12/27 9:14:15']
sp_obj->plot, spectrum_range = [400,600]
sp_obj->plot, timerange = ['2003/12/27 9:14:10','2003/12/27 9:14:15'], spectrum_range = [400,600]
sp_obj->plot, timerange = ['2003/12/27 9:14:10','2003/12/27 9:14:15'], spectrum_range = [400,600]
sp_obj->plot, timerange = ['2003/12/27 9:14:10','2003/12/27 9:14:15'], charthick = 2, charsize = 1.5

; need to test: noaxes, nolabel, notitle
; need to implement: contours
; need to implement: utplot switching

!p.multi = [0,1,2]
nc = 100
loadct, 3, ncolors = nc
sp_obj->plot, ncolors = nc
loadct, 1, bottom = nc, ncolors = nc
sp_obj->plot, bottom = nc, ncolors = ncrestore, 'focis.sav'
o = make_spectrogram( ampspect, time, freq )
o->set, xstyle=3, ystyle=3, /log_scale
oo = o->getplotman( colortable = 5, interpolate = 0 )
o->plotman


!p.multi = [0,0,0]
loadct, 5

o = make_spectrogram()
o->set, spectrogram =  findgen(123,456), $
  time_axis= findgen(123)*0.1 + anytim( '2003/08/21 16:55:00' ), /xaxis
o->set,  axis_data= 300 + findgen( 456), /yaxis
help, o->get( /spectrogram )
help, o->get( /time_axis )
restore, 'focis.sav'
o = make_spectrogram( ampspect, time, freq )
o->set, xstyle=3, ystyle=3, /log_scale
oo = o->getplotman( colortable = 5, interpolate = 0 )
o->plotman

help, o->get( /spectrum_axis )

print, 'try with a phoenix spectrogram '
f = file_search( '*fit*gz' )
radio_spectro_fits_read, f[0], sp, /struct

obj_destroy, o
o = make_spectrogram( sp )
o->plot
o->plot, xs= 3, /ylog
o->plot, title = 'phoenix'

o->plot, o
o->plot, [o, o]
o->plot, o, title = ['phoenix 1', 'phoenix 2'], xtitle = 'time', ytitle = ['frequency', 'gaga']

print, 'now test the line plots'
sp1 = {spectrogram: sp.spectrogram[*,0:5], x:sp.x, y:sp.y[0:5]}
oo=make_spectrogram( sp1 )
oo->plot
oo->plot, plot_type = 'utplot'
oo->plot, oo, plot_type = ['utplot', 'specplot' ], /save

restore, 'tplot_test_data.sav'
ooo = make_spectrogram(hh)
o->plot, ooo

loadct, 5


END

;--------------------------------------------------------------------------------

function spectrogram::init, spectrogram, time_axis, spectrum_axis, _extra = _extra

self.old_spectrogram = ptr_new( allocate_heap )
self.old_time_axis = ptr_new( allocate_heap )
self.old_spectrum_axis = ptr_new( allocate_heap )

self.time_axis  = obj_new( 'time_axis' )
self.spectrum_axis = obj_new( 'spectrum_axis' )

; /allocate_heap allows to guarantee the pointer exists
self.spectrogram = ptr_new( /allocate_heap )

self.paneldesc = 'Spectrogram'
if n_params() GE 1 then begin
    self->set, spectrogram = spectrogram, $
      time_axis = time_axis, $
      spectrum_axis = spectrum_axis
endif

IF keyword_set( _extra ) THEN self->set, _extra = _extra

return, 1

END

;---------------------------------------------------------------------------

PRO spectrogram::cleanup

Ptr_free, self.spectrogram
obj_destroy, self.time_axis
obj_destroy, self.spectrum_axis
obj_destroy, self.plot

END

;---------------------------------------------------------------------------

pro spectrogram::help

help, self->make_struct(), /str

end

;---------------------------------------------------------------------------

function spectrogram::make_struct

struct = make_struct( spectrogram  = self->get( /spectrogram ), $
                      time_axis = self->get( /time_axis ), $
                      spectrum_axis = self->get( /spectrum_axis ) )

units = self->get( /units )
if units ne '' then struct = add_tag( struct, units, 'UNITS' )

return, struct

end


;---------------------------------------------------------------------------

function spectrogram::getplotobj, firsttime = firsttime
; helper proc not to use from outsid just checks plot obj befor
; returning it

firsttime = 0
if not obj_valid( self.plot ) then begin
    firsttime = 1
    self.plot = obj_new( 'specplot' )
endif

return, self.plot

end

;---------------------------------------------------------------------------

PRO spectrogram::set, $
               hist_equal_percent = hist_equal_percent, $
               percent = percent, $
               spectrogram_in = spectrogram_in, $
               spectrum_axis = spectrum_axis, $
               time_axis = time_axis, $
               time_range = time_range, $
               time_resolution  = time_resolution, $
               paneldesc = paneldesc, $
               units = units, $
               _ref_extra = extra

; this is the only place with get where i'm allowed to access the data with self.

; check if it's a structure
IF size( spectrogram_in, /type ) eq 8 THEN BEGIN
    struct2spectrogram, spectrogram_in, spectrogram, time_axis, spectrum_axis
ENDif else if exist( spectrogram_in ) then spectrogram = spectrogram_in

IF exist( spectrogram ) THEN BEGIN
    *self.spectrogram = spectrogram
    self.time_axis->set, n_els=self->get( /nx )
    self.spectrum_axis->set, n_els=self->get( /ny )
    self.update = 1B
ENDIF

IF exist( time_axis ) THEN begin
    self.time_axis->set, time_axis = time_axis
    self.update = 1B
ENDIF

if exist( time_range ) then begin
    self.time_axis->set, time_range = time_range
    self.update = 1B
endif

if exist( time_resolution ) then begin
    self.time_axis->set, time_resolution = time_resolution
    self.update = 1B
endif

IF exist( spectrum_axis ) THEN BEGIN
    self.spectrum_axis->set, spectrum_axis = spectrum_axis
    self.update = 1B
ENDIF

IF exist( percent ) and not exist( hist_equal_percent ) THEN hist_equal_percent = percent

if exist( units ) then begin
    self.units = units
    self.update = 1B
endif

if is_string( paneldesc ) then self.paneldesc=paneldesc

if exist( extra ) or exist( hist_equal_percent ) then begin
    plot_obj = self->getplotobj()
    plot_obj->set, _extra = extra, hist_equal_percent = hist_equal_percent
; not really elegant, will have to fix this later
    plotman = self->getplotman( _extra = extra )
endif

end

;--------------------------------------------------------------------------------

function spectrogram::get, $
                    n_time=n_time, $
                    nx = nx, ny=ny, $
                    n_spectrum=n_spectrum, $
                    object_reference = object_reference, $
                    spectrogram = spectrogram, $
                    spectrum_axis = spectrum_axis, $
                    time_axis=time_axis, $
                    units = units, $
    utbase = utbase, $
                    _ref_extra = extra


; get( /xaxis ) ->returns full x axis
; get( /xaxis, /minmax ) -> returns minmax els of array, ordered correctly

IF keyword_set( spectrogram ) THEN BEGIN
    return, *self.spectrogram
ENDIF

if keyword_set( time_axis ) then begin
    if keyword_set( object_reference ) then return, self.time_axis
    return, self.time_axis->get(_extra=extra)
endif

if keyword_set( spectrum_axis ) then begin
    if keyword_set( object_reference ) then return, self.spectrum_axis
    return, self.spectrum_axis->get(_extra = extra )
endif

if keyword_set( n_time ) or keyword_set( nx ) then begin
    return, (size( *self.spectrogram, /dim ))[0]
endif

if keyword_set( n_spectrum ) or keyword_set( ny ) then begin
; need to protect from the case where no spectrogram is set
    size =size( *self.spectrogram, /dim )
    if n_elements( size ) lt 2 or size[0] eq 0 then return, 0
    return, size[1]
endif

if keyword_set( units ) then return, self.units

if keyword_set( n_elements ) then return, size( self->get( /spectrogram ), /n_elements )

if keyword_set( n_dimensions ) then return, size( self->get( /spectrogram ), /n_dimensions )

if keyword_set( extra ) then begin
    plot_obj = self->getplotobj()
    return, plot_obj->get( _extra = extra )
endif

END

;--------------------------------------------------------------------

function spectrogram::getplotman, _extra = extra

if not obj_valid( self.plotman ) then begin
    ;self.plotman = plotman( input = self, plot_type = 'specplot', _extra = extra )
    self.plotman = plotman( /multi, _extra=extra, /nomap )
endif else self.plotman -> set, _extra=extra

return, self.plotman

end

;--------------------------------------------------------------------

pro spectrogram::plotman, _extra = _extra

self -> plot, plotman_obj=self->getplotman(_extra = _extra), _extra = _extra

end

;--------------------------------------------------------------------

pro spectrogram::plot, spectro_obj, $
               plotman_obj=plotman_obj, $
               _extra = extra
;               cbar=cbar, $
;               dim1_use = dim1_use, $
;               INTERPOLATE=interpolate, $
 ;              INVERT=invert, $
 ;              no_ut = no_ut, $
 ;              percent = percent, $
 ;              plot_type = plot_type, $
 ;;              POSTSCRIPT=POSTSCRIPT, $
 ;              save = save, $
 ;              spectrum_range = spectrum_range, $
 ;              TITLE=title, $
  ;             TIMERANGE=timerange, $
  ;             XRANGE=xrange, $
  ;;             xstyle  = xstyle, $
  ;             YINTEGRATE=yintegrate, $
  ;             YRANGE=yrange, $
  ;             ystyle = ystyle, $
  ;             YTITLE=ytitle, $
  ;             YLOG=ylog, $
   ;            ZLOG=zlog, $
   ;            ZEXP=zexp, $
;               _ref_extra = extra


n_par = n_params()
n_spectro = n_elements( spectro_obj ) + 1

; compatibility, but xrange has priority if both are set
if valid_range( xrange ) then local_xrange = xrange $
else if keyword_set( timerange ) then local_xrange = timerange

if n_spectro gt 1 then begin

    local_spectro_obj = [self, spectro_obj]

;; determine the range to plot
    if not exist( local_xrange ) then begin

        FOR i=0, n_spectro-1 DO BEGIN
            this_xrange = anytim( local_spectro_obj[i]->get(/xrange) )
            if not valid_range( this_xrange ) then $
                                this_xrange = minmax( local_spectro_obj[i]->get(/time_axis ) )
            IF i EQ 0  THEN BEGIN
                local_xrange = this_xrange
            ENDIF ELSE BEGIN
                local_xrange = [local_xrange[0] > this_xrange[0], local_xrange[1] < this_xrange[1]]
            endelse
        endfor

    ENDIF

    old_multi = !p.multi
    !p.multi = [0, 1, n_spectro]

endif else begin

    local_spectro_obj = self

endelse

if exist( spectrum_range ) then yrange = spectrum_range

FOR i=0, n_spectro-1 DO BEGIN

    this_spectro_obj = local_spectro_obj[i]
    if exist( extra ) then $
        this_extra = str_tagarray2scalar( extra, i )

    if i lt n_spectro-1 then xcharsize=0.001 else xcharsize = !x.charsize

    plot_obj = this_spectro_obj->getplotobj( firsttime = firsttime )

;    yes_store_values = not firsttime and plot_obj->has_xdata()

;    if yes_store_values then begin
;        stored_timerange =  plot_obj->get( /timerange )
;        stored_plot_type = plot_obj->get( /plot_type )
;        no_defaults = 1
;    endif else no_defaults =0

; print, plot_obj->get( /hist_equal_percent )
; this resets a lot of things. i dont know how to prevent this.

    if not plot_obj->has_xdata() or self.update then begin
    	xdata = this_spectro_obj->get( /time_axis )
;    	utbase = min(xdata)	; kim 10-jun-05 always use utbase=0  !!!!!!!
;        plot_obj->set, xdata = xdata-utbase, utbase=utbase, $
        plot_obj->set, xdata = xdata, utbase=0.d0, $
                            ydata = this_spectro_obj->get( /spectrogram ), $
                            dim1_vals = this_spectro_obj->get( /spectrum_axis, /mean ), $
                            no_defaults=no_defaults
        self.update = 0B
    endif

;    if yes_store_values then begin
;        plot_obj->set, timerange = stored_timerange
;        plot_obj->set, plot_type = stored_plot_type
;    endif

;    print, plot_obj->get( /hist_equal_percent )

;    if has_tag( this_extra, 'plot_type' ) then begin
;        if this_extra.plot_type eq 1 then begin
;            if keyword_set( no_ut ) then begin
;                this_plot_type = 'xyplot'
;            endif else begin
;                this_plot_type = 'utplot'
;            endelse
;        endif else this_plot_type = 'specplot'
;    endif

    if keyword_set(plotman_obj) then begin
;	   status = plotman_obj -> setdefaults (input=plot_obj, plot_type='specplot')
;	   if status then begin
;	      plotman_obj -> set, _extra=extra
;	      plotman_obj -> new_panel, self.paneldesc
;	   endif
       plotman_obj -> new_panel, self.paneldesc, input=plot_obj, plot_type='specplot', _extra=extra

    endif else plot_obj->plot, _extra = extra, xrange = local_xrange

    if keyword_set( save ) then begin
        plot_obj->set, _extra = extra
    endif

ENDFOR

;    IF KEYWORD_SET(POSTSCRIPT) THEN psclose
IF n_spectro GT 1 THEN !p.multi = old_multi


end

;--------------------------------------------------------------------------------

pro spectrogram::bkg_subtract, bck_time_range, $
               auto = auto, $
               elim = elim, $
               noplot = noplot, $
               undo = undo

if keyword_set( undo ) then begin
    if n_elements( self.old_spectrogram ) ne 0 then begin
        self->set, spectrogram = self.old_spectrogram
        self->set, time_axis = self.old_time_axis
        self->set, spectrum_axis = self.old_spectrum_axis
    endif else begin
        message, 'cant und background subtraction, so spectrogram available', /info, /cont
    endelse
endif else begin

    if not keyword_set( auto ) then begin

        if not valid_range( bck_time_range ) then begin
            if not keyword_set( noplot ) then self->plot
            print, 'click on the first time coordinate'
            cursor, t1, y, /up
            print, 'click on the second time coordinate'
            cursor, t2, y, /up
            bck_time_range = [t1,t2] + anytim( self->get( /utbase ))
        endif

        time = self->get( /time_axis ) - anytim( self->get( /utbase ) )
        pixel = value_locate( time, bck_time_range )

    endif else begin

; this is just dummy
        pixel = [0,0]

    endelse

    spectrogram = self->get( /spectrogram )

    forward_function constbacksub
    new_spectrogram = constbacksub( spectrogram, pixel[0], pixel[1], auto = auto )

    time_axis = self->get( /time_axis )
    spectrum_axis = self->get( /spectrum_axis )
    if keyword_set( elim ) then elimwrongchannels, new_spectrogram, time_axis, spectrum_axis

    if not ptr_valid( self.old_spectrogram ) then begin
        self.old_spectrogram = ptr_new( spectrogram )
    endif
    *self.old_spectrogram = spectrogram
    *self.old_time_axis = time_axis
    *self.old_spectrum_axis = spectrum_axis
    self->set, spectrogram = new_spectrogram
    self->set, time_axis = time_axis
    self->set, spectrum_axis = spectrum_axis

endelse

end


;--------------------------------------------------------------------------------

PRO spectrogram__define

dummy =  {spectrogram, $
          old_spectrogram: ptr_new(), $
          old_time_axis: ptr_new(), $
          old_spectrum_axis: ptr_new(), $
          spectrogram: ptr_new(), $
          time_axis: obj_new(), $
          spectrum_axis: obj_new(), $
          update: 0B, $
          units: '', $
          paneldesc: '', $
          plot: obj_new(), $   ; container for specplot
          plotman: obj_new() } ; container for plotman

END


;---------------------------------------------------------------------------
; End of 'spectrogram__define.pro'.
;---------------------------------------------------------------------------

