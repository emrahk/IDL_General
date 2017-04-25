;+
; Project     : RHESSI
;                   
; Name        : get_image_profile
;               
; Purpose     : return profile of image at line defined by input points
;               
; Category    : utility
;               
; Syntax      : IDL> out=in_box(input, xaxis, yaxis)
;    
; Inputs      : 
;  p1 - start x,y location of line to use for profile.  If not defined or not within xaxis, uses  
;    lower left corner of plot.
;  p2 - end x,y location of line to use for profile.  If not defined or not within yaxis, uses  
;    upper right corner of plot.
;  xaxis - 1-D array of x axis values (number of bins is 1 less than n_elements(xaxis))
;  yaxis - 1-D array of yaxis values (number of bins is 1 less than n_elements(yaxis))
;  image - 2-d image array
;  lim_from_plot - set to 1 if the limits of the plot box should be taken from the most recent plot,
;    otherwise use limits of xaxis, yaxis.
;  verbose - if set, print location of line used for profile
;               
; Outputs     : structure containing 
;   dist - distance along profile line
;   profile - profile of image along line
;   xvals - x elements of image used for profile
;   yvals - y elements of image used for profile 
;     (i.e. profile[i] is equal to image[xvals[i], yvals[i]]
;
; History     : Kim Tolbert, 6-Nov-2009
;
; Modifications : 
;-      

function get_image_profile, p1=p1, p2=p2, xaxis=xaxis, yaxis=yaxis, image=image, lim_from_plot=lim_from_plot, verbose=verbose

verbose = keyword_set(verbose)

; if points defining line aren't defined, or aren't in xaxis,yaxis, make them the [lower left, upper right] corners.
if ~exist(p1) || ~in_box(p1, xaxis, yaxis) then begin
  message,'Start location of profile line not defined, or not in image limits, setting to lower left corner.', /cont
  p1 = [min(xaxis),min(yaxis)]
endif
if ~exist(p2) || ~in_box(p2, xaxis, yaxis)  then begin
  message,'End location of profile line not defined, or not in image limits, setting to upper right corner.', /cont
  p2 = [max(xaxis),max(yaxis)]
endif

if verbose then $
  message,/cont, 'Line for profiles in get_image_profile: Start x,y = ' + arr2str(trim(p1)) + '  End x,y = ' + arr2str(trim(p2))

;find xedge,yedge - coordinates of two intercepts of line with box
; if lim_from_plot is set, get limits of box from plot instead of axes.

if ~keyword_set(lim_from_plot) then begin
  xlimit=minmax(xaxis)
  ylimit=minmax(yaxis)
endif

find_edge_intercept,[p1[0],p2[0]], [p1[1],p2[1]], xedge,yedge, xlimit=xlimit,ylimit=ylimit

; find elements in image that fall on that line
image_dim=size(image,/dim)
xy =find_pixel_intersects(xedge,yedge, xaxis,yaxis, ylog=0, image_dim, dist=dist,xvals=xvals,yvals=yvals)

profile = image[xy[*,0], xy[*,1]]

return, {dist: dist, profile: profile, xvals: xy[*,0], yvals: xy[*,1]}
end