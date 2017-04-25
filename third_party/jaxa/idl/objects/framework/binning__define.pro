;---------------------------------------------------------------------------
; Document name: binning__define.pro
; Created by:    Andre_Csillaghy, August 21, 2003
;
; Time-stamp: <Thu Nov 17 2005 14:02:31 csillag auriga.ethz.ch>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI
;
; NAME:
;       binning__define
;
; PURPOSE:
;       this class provides the basic capabilities of dividing an
;       interval into a number of sub-intervals, or "bins"
;
;       you can divide the interval by specifying diverse parameters
;       - the values of the center of the bins (the "mean")
;       - the values of each bin edge, either with a 1-dimensional array
;         (consecutive bins) or with a 2-dimensional array (non-consecutive bins)
;       - the start of the interval, the width of the bins, and the
;             number of elements
;
;       this can (and is) used to define several kinds of axes, see
;       time_axis__define or spectrum_axis__define
;
;       The objects uses several strategies to understand how the
;       interval must be divided.
;
; CATEGORY:
;       utilities
;
; INSTANCE CREATION:
;       o = binning()
;
; METHODS:
;       o->set
;       result = o->get()
;
; (KEYWORD) PARAMETERS:
;       mean: the center of the bins
;       width: the width of the bins
;       edges: the edges of the bins. can be either 1d or 2d
;       start_val: the start value of the interval
;       end_val: the end value of the interval
;       n_els: the number of elements within the interval
;
; EXAMPLES:
;       see binning_test below
;
; SEE ALSO:
;
;
; HISTORY:
;       feb-2004 --- acs, lots of changes
;       jan-2004 --- acs, binning__define as a class for itself (from axis__define)
;       dec-2003 --- acs, separate display parameters from binning def. parameters
;       Version 1, August 21, 2003,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;--------------------------------------------------------------------------
;

pro binning_test

print, 'first method to set the binnning: pass the mean of the bin: '
o = binning()
o->set, mean = indgen(10)
print, 'this should have 11 els: '
print, o->get( /edges_1 )
print, 'this should be a 2d array of 2 by 10 els )'
print, o->get( /edges_2 )
print, 'width = '
print, o->get( /width )
print, 'mean = '
print, o->get( /mean )
obj_destroy, o

print, 'ok now lets try something else, we pass the edges'

o = binning()
o->set, start=0, n_els = 9, width = 10
print, 'this should have 10 els: '
print, o->get( /edges_1 )
print, 'this should be a 2d array of 2 by 10 els )'
print, o->get( /edges_2 )
print, 'width = '
print, o->get( /width )
o->help

print, 'mean = '
print, o->get( /mean )

print, 'minmax: '
print, o->get( /mean, /minmax )
print, o->get( /edges_1, /minmax )
print, o->get( /edges_2, /minmax )
print, o->get( /width, /minmax )

end

;--------------------------------------------------------------------------

FUNCTION binning::init, _extra = _extra

if keyword_set( _extra ) then self->set, _extra = _extra

self.vector = ptr_new( [0,0] )
self.n_els = -1
self.width = -1
return, 1
return, self->gen::init()

END

;---------------------------------------------------------------------------

PRO binning::cleanup

heap_free, self.vector
self->gen::cleanup

END

;---------------------------------------------------------------------------

pro binning::help

help, self, /struct

end

;---------------------------------------------------------------------------

pro binning::set, $
    mean=mean, $
    n_els = n_els, $
    start_val = start_val, $
    end_val = end_val,$
    edges = edges, $
    width = width, $
    vector = vector

; middle of the bin
; compatibility: keep mean, edges etc.
if exist( mean ) then begin 
    self.yes_mean = 1
    self.width = -1
    vector = mean
endif else self.yes_mean = 0

if exist( edges ) then vector = edges

if is_number( start_val ) or is_number( end_val ) then begin 
    if exist( start_val ) then (*self.vector)[0] = start_val
    if exist( end_val ) then (*self.vector)[1] = end_val
endif

; we'll put some more consistency checks... eventually
if exist( vector) then begin 
    *self.vector = vector
; if we have more than 2 els, that's OK, otherwise check out width and n_els
; also, if we pass edges with only 2 elements (i.e. one bin) do not set n_els
    if n_elements( vector ) eq 2 and not exist( edges ) then begin 
; now recalc width and n_els 
        if self.width ne 0 then begin
            self.n_els = ( ( (*self.vector)[1] - (*self.vector)[0] ) / self.width )
        endif
    endif else self.n_els = -1
endif

; if a user sets n_els, that means it's a range minmax diveded in
; homogeneous intervals
if is_number( n_els ) then begin
    self.n_els = n_els
; if we are here we know we have a range min/max in self.vector
; recalculate the width -- if it is not just given
    if not is_number( width ) then begin 
        if n_els ne 0 then begin 
            if (*self.vector)[1] ne 0 and (*self.vector)[0] ne 0 then begin 
                self.width = ( (*self.vector)[1] - (*self.vector)[0] )/float( n_els )
; acs 2005-02-08 if width is still 0 then set width =1
            endif else begin 
                self.width =1
            endelse
        endif else self.width = (*self.vector)[1] - (*self.vector)[0]
    endif
endif

if is_number( width ) then begin
    self.width = width
; recalculate n_els if width is set
    if not is_number( n_els ) then begin
; sometimes the width is set befor the vector, so we have to protect
; against that
        if width ne 0 and valid_range( *self.vector ) then begin 
; protect  (>0) against the case where width is bigger than the
; interval. In that case width will take over 
            self.n_els = (( (*self.vector)[1] - (*self.vector)[0] ) / width) > 1
        endif else begin 
; do this test only if vector contains a range, not if the intervals are
; defined in the vector itself
            if n_elements( (*self.vector) ) EQ 2 then self.n_els =1 
        endelse
    endif
endif

END

; ------------------------------------------------------------------------

function binning::getstatus

return, n_elements( self->get() ) ne 0

end

; ------------------------------------------------------------------------

function binning::get, $
                edges_1=edges_1, $
                edges_2 = edges_2, $
                mean=mean, $
                range = range, $
                n_els = n_els, $
                width=width, $
                minmax = minmax

; this is the only place where i'm allowed to get data directly through self.

; compatibility
if keyword_set( minmax ) then range = 1

; first do the easy ones -- those that dont need the vector
if keyword_set( n_els ) then begin 
    if self.n_els gt -1 then return, self.n_els
    if self.yes_mean then return, N_Elements( *self.vector )
endif

if keyword_set( width ) then begin 
    if self.n_els ne -1 then  return, self.width
endif

; this one is easy too -- just pass the vector back if that's
; what needed, otherwise , go on
if self.yes_mean and valid_range( (*self.vector)[0:1] ) then begin 
    if keyword_set( mean ) then return, *self.vector
    arr_to_return = axis_get_edges( *self.vector )
endif else if self.n_els gt -1 and self.width ne 0 then begin
    if self.yes_mean then nels = self.n_els else nels = self.n_els +1
    arr_to_return = dindgen( nels )*self.width + (*self.vector)[0]
endif else arr_to_return = *self.vector

; this means that if we want the number of elements, we have to
; count the mean values.
if keyword_set( n_els ) then mean = 1

arr_to_return = get_edge_products( arr_to_return, $
                                   edges_1=edges_1, $
                                   width = width, $
                                   edges_2 = edges_2, $
                                   mean = mean )


if keyword_set( n_els ) then begin
    return, n_elements( arr_to_return )
end

if keyword_set( range ) then return, minmax( arr_to_return )

return, arr_to_return

END

;---------------------------------------------------------------------------

PRO binning__define

; ok in fact we have two forms. either edge-based or definition based.

; if edge based:
; - one var. goes in/out with get_e_edges.

; if definition based: this one we dont want to expand it
; because it could tak a lot of memory (e.g. fine time bins)
; so we store:
; - min/max (in the ptr var of the other form)
; - n_els or width which 

; yes_nels and yes_vector are there just to make it clear which mode is used
; it isnt necessary but ib brings clarity

; this def. assumes that the bins have the same width. 
dummy =  {binning, $
          vector: ptr_new(), $
          width: 0D, $
          n_els: 0L, $
          yes_mean: 0B, $
         inherits gen}

END

;---------------------------------------------------------------------------
; End of 'binning__define.pro'.
;---------------------------------------------------------------------------
