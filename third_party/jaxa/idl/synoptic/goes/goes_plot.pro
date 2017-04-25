;+ Project     : HESSI
;
; Name        : goes_plot
;
; Purpose     : Quickly plot a time interval of GOES data
;
; Category    : goes
;
; Syntax      : goes_plot, time_range=time_range
; 
; Keywords: Any keyword for the GOES object or plot keyword
; 
; Example:  goes_plot,time_range='20-Jul-2002 ' + ['21:00','22:00']
;           Use an existing plotman session (p):
;           goes_plot, tstart='20-Jul-2002 21:00', tend='20-Jul-2002 22:00', plotman_obj=p, /sdac
;
; History     : Kim Tolbert, 4-Aug-2009
;
;-

pro goes_plot, time_range=time_range,  _extra=extra

g = obj_new('goes')
if exist(time_range) then begin
  time_range = anytim(time_range,/vms)
  g -> set, tstart=time_range[0], tend=time_range[1]
endif
g -> plotman, _extra=extra
obj_destroy,g, exclude='plotman_obj'

end