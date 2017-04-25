;+
; Project     : General mapping
;
; Name        : time_at_meridian
;
; Purpose     : calculate the time a map was at the central meridian
;
; Category    : imaging
;
; Syntax      : ntime = time_at_meridian( map, [ center = center, time = time, ncenter = ncenter ] )
;
; Inputs      : map = image structure map created by MAKE_MAP
;
; Keywords    : center = [ solar_x, solar_y ] = heliocentric position in arcseconds
;               time = the time in ANYTIM format
;               ncenter = the heliocentric position closest to the central meridian
;
; Outputs     : ntime = the time the map center was closest to the central meridian
;
; History     : Written 18 May 2004, Peter T Gallagher (L-3 Communications GSI/NASA GSFC)
; 
; Contact     : ptgallagher@solar.stanford.edu
;
;-

function time_at_meridian, map, center = center, time = time, ncenter = ncenter
    
  if ( n_params() eq 1 ) then begin
    center = [ map.xc, map.yc ] 
    time = map.time
  endif
  
  ; Generate an array of times in 1-hour steps   
  
  if ( center[ 0 ] ge 0. ) then tgrid = anytim( timegrid( anytim( time ) - 7. * 24. * 60. * 60., time, /hours ), /vms ) else $
                                tgrid = anytim( timegrid( time, anytim( time ) + 7. * 24. * 60. * 60., /hours ), /vms )
  
  
  ; Find the position of the map center at each time
  
  ncenter = fltarr( 2, n_elements( tgrid ) ) 
  index = 0
  dx = 2000.
  
  while ( dx ge 0 ) do begin
  
    ncenter[ *, index ] = rot_xy( center[ 0 ], center[ 1 ], tstart = time, tend = tgrid[ index ], /soho )
    dx = ncenter[ 0, index ]
    if ( ncenter[ 0, 0 ] lt 0 ) then dx = -dx
    index = index + 1
  
  endwhile
    
  ncenter = ncenter[ *, index - 1 ]
  return, tgrid[ index - 1]
  
end


