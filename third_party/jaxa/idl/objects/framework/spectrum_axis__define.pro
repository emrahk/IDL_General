;---------------------------------------------------------------------------
; Document name: spectrum_axis__define.pro
; Created by:    Andre_Csillaghy, December 2003
;
; Time-stamp: <Sat May 22 2004 11:29:55 Administrator CRAPPY3>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       SPECTRUM_AXIS__DEFINE
;
; PURPOSE:
;       Creates and manage spectrum axes. Built on top of binning__define.
;
; CATEGORY:
;       Objects
;
; CALLING SEQUENCE:
;       o = spectrum_axis()
;
; INHERITS:
;       binning__define
;
; METHODS:
;       set: used to input axes values in energy format
;
; KEYWORDS:
;       energy_band - sets the energy bands in edge format,
;                     i.e. either 1D with n+1 elements or [2,n]
;                     format, with n=number of energy bands
;       spectrum_axis - sets the axis as means of each bins,
;                       i.e. n-element vector
; EXAMPLES:
;       o = obj_new( 'spectrum_axis')
;       o->set, energy_band = [12,25,50,100]
;       print, o->get()
;
; SEE ALSO:
;       time_axis__define
; HISTORY:
;       dec-2003 --- acs, created
;                    csillag@ssl.berkeley.edu
;--------------------------------------------------------------------------

pro spectrum_axis::set, $
                 energy_band = energy_band, $
                 spectrum_axis = spectrum_axis, $
                 _ref_extra = extra

if exist( energy_band ) then begin 
    self->binning::set, edges = energy_band
endif
if exist( spectrum_axis ) then begin 
    self->binning::set, mean = spectrum_axis
endif

if exist( extra ) then self->binning::set, _extra = extra

end

;---------------------------------------------------------------------------

pro spectrum_axis__define

dummy = {spectrum_axis, $
         inherits binning}
end
