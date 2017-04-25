;NOTE:  RENAMED TO OLD_AXIS__DEFINE to avoid conflict with IDL 8.0 axis function / object. I think no one is using this
; and I don't think it works anyway.  Will offline if no one complains.  Kim Tolbert 24-Apr-2014
; 
;---------------------------------------------------------------------------
; Document name: axis__define.pro
; Created by:    Andre_Csillaghy, August 21, 2003
;
; Time-stamp: <Wed Apr 14 2004 16:31:04 csillag sunstroke>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       AXIS__DEFINE
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       axis__define,
;
; INPUTS:
;
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURE:
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; EXAMPLES:
;
;
; SEE ALSO:
;
; HISTORY:
;       dec-2003 --- acs, separate display parameters from axis def. parameters
;       Version 1, August 21, 2003,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;--------------------------------------------------------------------------
;

pro axis_test

o = axis()
o->set, axis = indgen(100)
print, o->et( /axis )

end


;--------------------------------------------------------------------------

FUNCTION axis::init, axis, _extra = _extra

self.axis = ptr_new( undef )
IF n_params() EQ 1 THEN self->set, axis = axis
if keyword_set( _extra ) then self->set, _extra = _extra

return, 1

END

;---------------------------------------------------------------------------

PRO axis::cleanup

ptr_free, self.axis

END

;---------------------------------------------------------------------------

pro axis::help

help, self, /struct

end

;---------------------------------------------------------------------------

pro axis::set, $
        center = center, $
        start_val = start_val, $
        end_val = end_val, $
        gain=gain, $
        offset = offset, $
        edges = edges, $
        range = range

; we need three ways of storing the axes.

; first way: the axis element is described by the value
; at the middle of the bin
if keyword_set( axis ) then begin
    *self.axis = axis
endif

; second way: the axis is defined with gain, offset, n_els
if keyword_set( gain ) or keyword_set( offset ) then begin
    checkvar, gain, 1
    checkvar, offset, 0
    *self.axis = findgen( n_els )*gain + offset
 endif

; third way: the axis is defined with start_val, end_val, n_els
if keyword_set( start_val ) or keyword_set( end_val ) then begin
stop
    checkvar, start_val, 0
    checkvar, end_val, n_els -1
    gain = (start_val - end_val ) / n_els
    offset = start_val
    self->set, gain = gain, offset = offset, n_els = n_els
endif

; fourth way: the axis is defined with edges_1 or edges_2
if keyword_set( edges ) then begin
    edge_products, edges, edges_2 = edges_2
    *self.axis = edges_2
endif

if keyword_set( title ) then begin
    self.title = title
endif

if keyword_set( n_els ) then self.n_els = n_els

END

; ------------------------------------------------------------------------

function axis::getstatus

return, n_elements( self->get() ) ne 0

end

; ------------------------------------------------------------------------

function axis::get, axis=axis, $
             n_els = n_els, $
             status=status, $
             reverse = reverse, $
             object_reference = object_reference, $
             els_within_range

; this is the only place where i'm allowed to get data directly through self.

stop

if keyword_set( reverse ) then begin
    axis = self->get( /axis )
    return, axis[0] gt last_item( axis )
endif

if keyword_set( object_reference ) then return, self

if keyword_set( axis ) then begin
    if n_elements( *self.axis ) eq 0 then begin
        if self.n_els eq 0 then return, -1
        return, lindgen( self.n_els )
    endif
    return, *self.axis
endif

if keyword_set( els_within_range ) then begin
    limit = self->get_axis_limits()
    axis = self->get( /axis )
    axis = axis[limit[0]:limit[1]]
    return, axis
ENDIF

if keyword_set( minmax ) then begin
    axis = self->get( /axis )
    mm = minmax( axis )
    if self->get( /reverse ) then return, mm[[1,0]] else return, mm
endif

if keyword_set( n_elements ) then begin
    return, self.n_els
endif

return, self->get( /axis )

END

;---------------------------------------------------------------------------

function axis::get_expanded_range, crange, log

center =  self->get( /els_within_range )

; we assume axis contains the center of the bins.
; thus we need to expand the axis to allow the bin extension at the beginning
; and at the end of the range

; find the edges between bins
edge =  (center + shift( center, -1 ))/2.
edge = edge[0:n_elements(edge)-2]
; the expression before is ok except for the first and last values
; for the first value we take the

first =  center[0] - ( edge[0] - center[0] )
last = 2* last_item( center ) -last_item(edge)

IF first GT last THEN begin
    expanded_range = [last, first]
endif else begin
    expanded_range = [first, last]
endelse

this_crange = log ? 10^(crange) : crange
if this_crange[0] gt this_crange[1] then this_crange = this_crange[[1,0]]
expanded_range = expanded_range > this_crange[0] < this_crange[1]

return, expanded_range

end

;---------------------------------------------------------------------------

function axis::get_axis_limits, range = range

; get the index of the first and last axis element in the range set

range = self->get( /range )
if same_data(range, [0.d, 0.d], /notype_check)then return, [0, self.n_els-1]
limit = (Value_Locate( *self.axis, range ) + [0,1] ) > 0 <  (self.n_els-1)
IF limit[0] GT limit[1] THEN limit = limit[[1, 0]]

return, limit

end

;---------------------------------------------------------------------------

PRO axis__define

dummy =  {axis, $
          axis: ptr_new(), $
          n_els: 0L }

END

;---------------------------------------------------------------------------
; End of 'axis__define.pro'.
;---------------------------------------------------------------------------
