;---------------------------------------------------------------------------
; Document name: time_axis__define.pro
; Created by:    Andre_Csillaghy, August 2003
;
; Time-stamp: <Tue Feb 08 2005 12:10:40 csillag auriga.ethz.ch>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       TIME_AXIS__DEFINE
;
; PURPOSE:
;		This defines a generic time axis that can be specified in several ways.
;
; CATEGORY:
;		Utilities
;
; CALLING SEQUENCE:
;       o = time_axis()
;
; METHODS:
; 		o->set, parameter = value: sets a parameter from the list below.
;       var = o->get( /parameter ): gets the value of a parameter from the list below.
;
; PARAMETERS:
;		time_range: the time range, in anytim format. A 2-element array.
;		time_resolution the resolution of the sub_intervals between time_range
;
; EXAMPLES:
;		see time_axis_test below
;
; SEE ALSO:
;       binning__define
;
; HISTORY:
;       apr-2004 --- acs further development for the new hsi_image object
;       dec-2003 --- acs, separate display parameters from axis def. parameters
;       Version 1, August 21, 2003,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;--------------------------------------------------------------------------

pro time_axis_test

o = obj_new( 'time_axis' )
o->set, time_range = '2002-aug-30 ' + ['13:27:45', '13:28:25']
o->set, time_resolution = 0.1
help, o->get( /time_edges )

end

;--------------------------------------------------------------------------

pro time_axis::set, $
             time_axis = time_axis, $
             time_range=time_range, $
             time_resolution = time_resolution, $
             _ref_extra = extra

if exist( time_range ) then begin
    self->binning::set, vector = anytim(double(time_range))
endif

if exist( time_axis ) then begin
    self->binning::set, mean = anytim( double(time_axis) )
endif

if exist( time_resolution ) then begin
    self->binning::set, width = time_resolution
endif

if exist( extra ) then self->binning::set, _extra = extra

end

;---------------------------------------------------------------------------

function time_axis::get, $
	time_edges=time_edges, $
	time_mean = time_mean, $
	time_resolution = time_resolution, $
	time_range = time_range, $
	_ref_extra = extra

if keyword_set( time_edges ) then begin
    return, self->binning::get( /edges_1 )
endif

if keyword_set( time_resolution ) then begin
    return, self->binning::get( /width )
endif

if keyword_set( time_range ) then begin
    return, self->binning::get( /range )
endif

return, self->binning::get( _extra = extra )

end

;---------------------------------------------------------------------------

pro time_axis__define

dummy = {time_axis, $
         inherits binning}

end
