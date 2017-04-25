;+
; PROJECT: SSW
;
; NAME: HISTOGRAM_PLUS
;
;
; PURPOSE: Returns the normal IDL histogram, with the reverse_indices packaged into
;   a pointer to avoid the nasty syntax.
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;    hist = histogram_plus( array, $
;     Select, Nselect=Nselect, REV_PTR= rev_ptr, $
;	  [, EDGE=edge] $
;     [, BINSIZE=value] [, INPUT=variable] [, MAX=value] [, MIN=value] [, /NAN] $
;     [, NBINS=value] [, OMAX=variable] [, OMIN=variable] $
;     [, /L64 ]  [,REVERSE_INDICES=variable] )
;
;
; CALLS:
; none
; Return Value

; Returns a 32-bit or a 64-bit integer vector equal to the density function of the input Array.
;
; INPUTS:
;       Array -The vector or array for which the density function is to be computed.
;
; OPTIONAL INPUTS:
;
;
; OUTPUTS:
;       Select - valid indices from histogram(ARRAY)
;
; OPTIONAL OUTPUTS:
; none
;
; KEYWORDS:
;   NSELECT - number of elements in select
;   REV_PTR - Ptr array of indices corresponding to elements of Select.
;     If no value are found, REV_PTR is set to 0.
;	  EDGES - Arbitrary bin edges for input Array. 
;   LOCATIONS - Bin edges that were used.
;
;
;   All Keyword Inputs available to HISTOGRAM
; COMMON BLOCKS:
; none
;
; SIDE EFFECTS:
; none
;
; RESTRICTIONS:
; none
;
; PROCEDURE:
;   Input array is scanned using histogram function.  The valid indices are returned
;   in Select.
;
; MODIFICATION HISTORY:
; 24-Jan-2002, Version 1, richard.schwartz@gsfc.nasa.gov
; 28-Jan-2002, ras, fixed bug with r, used r[select[i]] not r[i]
; 05-Aug-2011, ras, Kim - added EDGES for variable bin size histograms; added locations so that
;  locations can be passed out as edges[locations]; changed _extra keyword to _ref_extra
;-

function histogram_plus, array, select, rev_ptr=rev_ptr, $
nselect=nselect, edges=edges, locations=locations, _ref_extra=_extra

iarray = array
if keyword_set(edges) and n_elements(edges) ge 2 then begin
	iarray = value_locate( edges, iarray)
	h=histogram( iarray, min=0,max=n_elements(edges)-2, bin=1, revers=r, locations=locations, _extra=_extra)
	locations = edges[locations]
	endif else h = histogram( iarray, revers=r, locations=locations, _extra=_extra )

select = where( h gt 0, nselect )

rev_ptr = 0
if nselect ge 1 then begin
  rev_ptr = ptrarr( nselect )
  for i=0, nselect-1 do rev_ptr[i] = ptr_new( r[r[select[i]]:r[select[i]+1]-1] )
  endif

return, h
end