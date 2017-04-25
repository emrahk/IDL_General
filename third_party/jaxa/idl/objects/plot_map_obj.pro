

FUNCTION plot_map_obj, map, _extra=_extra, log=log, dmin=dmin, dmax=dmax, $
                       reverse=reverse, overplot=overplot, levels=levels, $
                       velocity=velocity

;+
; NAME:
;     PLOT_MAP_OBJ()
;
; PURPOSE:
;     This routine replicates the functionality of the routine
;     plot_map.pro, but plots the image using the built-in IDL routine
;     image.pro, creating a plot object.
;
;     In addition a keyword /velocity has been added for
;     displaying velocity maps with a blue-red color table.
;
; CALLING SEQUENCE:
;       Result = PLOT_MAP_OBJ(map)
;
; CATEGORY:
;     Image; display; maps.
;
; INPUTS:
;     Map:   An IDL map structure.
;
; OPTIONAL INPUTS:
;     Most keywords for the IDL routine IMAGE.PRO can be input. In
;     addition there are the following inputs.
;
;     Dmin:  Specify the minimum data value to plot.
;     Dmax:  Specify the maximum data value to plot.
;     Levels: This sets the intensity levels for contours. Only active
;             if /OVERPLOT is set, i.e., contours are plotted on
;             existing image. If you use /LOG, then LEVELS should be
;             set to values of the original image, not the log image. 
;
; KEYWORDS:
;     Most keywords for the IDL routine IMAGE.PRO can be input. In
;     addition there are the following inputs.
;
;     LOG:   If set, then the logarithm of the image is displayed.
;     REVERSE:  If set, then the color table for the plot is reversed.
;     OVERPLOT: If set, then the image is displayed as a contour.
;     VELOCITY: If set, then the image is interpreted as a velocity map
;            and plotted with a red-white-blue color table. The
;            keywords /log and /reverse are ignored.
;
; OUTPUTS:
;     The image in the input map is plotted to an IDL window. The
;     identifier of the created object is returned to the user.
;
;     If an error occurs, then -1 will be returned.
;
; EXAMPLES:
;     For an SDO image:
;
;     IDL> read_sdo, file, index, data
;     IDL> index2map, index, data, map
;     IDL> p=plot_obj_map(map)
;
;     ---
;     A velocity map is typically produced from a spectroscopic
;     instrument such as Hinode/EIS or IRIS by fitting a Gaussian to
;     an emission line and converting the line centroid to a velocity
;     (see, e.g., the eis_auto_fit and eis_get_fitdata routines). When
;     plotting such maps, it is usual to use a red-white-blue color
;     table. By giving the keyword /vel the map is plotted using this
;     color table. 
;
;     IDL> v=plot_map_obj(velmap, /vel)
;
;     The velocities are scaled between -dmax and +dmax (dmin is not
;     recognized as an input).
;
;     ---
;     To create a png from the displayed image, do:
;
;     IDL> p=plot_obj_map(map)
;     IDL> p.save,'image.png', resolution=96
;
;     resolution=96 means that the output image will have the same
;     dimensions as the plotted image.
;
;     ---
;     To set a color table, use the rgb_table= input. For example:
;
;     IDL> p=plot_obj_map(map,rgb_table=3)
;
;     gives the classic IDL red color table.
;
;     For an AIA color table, use:
;
;     IDL> aia_lct,r,g,b,wave=171,/load
;     IDL> rgb_171=[[r],[g],[b]]
;     IDL> p=plot_obj_map(map,rgb_table=rgb_171)
;
; HISTORY:
;     Ver. 1, 24-Jul-2014, Peter Young
;        Tidied up code and added detailed header in preparation for
;        release to Solarsoft.
;     Ver. 2, 8-Oct-2014, Peter Young
;        Modified LEVELS= input for use with /LOG keyword.
;     Ver. 3, 8-Mar-2016, Peter Young
;        Added time to the plot title in order to be consistent with
;        plot_map.
;     Ver. 4, 25-Mar-2016, Peter Young
;        For /overplot, I've adjusted the spatial locations
;        where the contour appears by one pixel to the top and
;        bottom, as they weren't correctly aligned to intensity
;        features (when plotting a contour on top of its own image). 
;-

IF n_params() LT 1 THEN BEGIN
  print,'Use:  IDL> p=plot_map_obj(map, [ dmin=, dmax=, /log, /reverse, /velocity, /overplot ])'
  print,''
  print,'   dmin, dmax - set min, max values of image for display'
  print,'   /log  - do log plot'
  print,'   /reverse - reverse color table'
  print,'   /velocity - interpret image as a velocity map and use red-blue col. table'
  print,'   /overplot - the map will be overplotted on an existing map as contours'
  return,-1
ENDIF


;
; Get image size
;
s=size(map.data,/dim)
nx=s[0]
ny=s[1]

;
; Get X and Y vectors.
; Note that I've made sure that the image is plotted in the
; same way as for the direct graphics routine plot_map. This means
; that a pixel's coordinate corresponds to the *center* of  the
; pixel. For the IDL image.pro routine, the coordinate corresponds to
; the bottom-left corner of the pixel.
;
; For /overplot, I had to adjust x and y as contours weren't
; appearing at exactly the location of the intensity feature. 
;
IF keyword_set(overplot) THEN BEGIN 
  x=findgen(nx)*map.dx + (map.xc - (nx-1)/2.*map.dx)
  y=findgen(ny)*map.dy + (map.yc - (ny-1)/2.*map.dy)
ENDIF ELSE BEGIN
  x=findgen(nx)*map.dx + (map.xc - nx/2.*map.dx)
  y=findgen(ny)*map.dy + (map.yc - ny/2.*map.dy)
ENDELSE 

;
; This sets the dimensions of the IDL plot window.
;
IF n_elements(dimensions) EQ 0 THEN dimensions=[600,500]

 
;
; This sets the margin around the plot box. Note that if margin
; isn't set, then the image is plotted with exactly the number
; of screen pixels as there are image pixels, which often means it
; will be rather small. Specifiying margin means the image is scaled
; to the IDL plot window size.
;
IF n_elements(margin) EQ 0 THEN margin=0.12


;
; Extract the image from the map
;
img=map.data


;
; Set the min and max values used for scaling the plotted image.
;
IF n_elements(dmin) NE 0 THEN min_value=dmin ELSE min_value=min(img)
IF n_elements(dmax) NE 0 THEN max_value=dmax ELSE max_value=max(img)

;
; /log - take log of image
; 
IF keyword_set(log) THEN BEGIN
  IF min_value LT 1 THEN min_value=1
  img=alog10(img>min_value)
  min_value=alog10(min_value)
  max_value=alog10(max_value)
ENDIF

;
; /reverse - reverse color table of image
;
IF keyword_set(reverse) THEN BEGIN
  img=max_value-img
  max_value=max_value-min_value
  min_value=0
ENDIF 

;
; When /velocity is set we explicitly create a new color table
; (blue-white-red), and the image is scaled in a different way to
; intensity images.
;
IF keyword_set(velocity) THEN BEGIN
 ;
 ; Create color table. Bytes 1:126 will be blue, byte 127 will be white,
 ; and bytes 128:253 will be red. Byte 0 is reserved for missing data
 ; and will be black. Bytes 254 and 255 are not used but are colored white.
 ;
  arr=byte(findgen(126)*253/125)
 ;
  r=bytarr(256)
  r[0]=0
  r[127]=255
  r[128:253]=255
  r[1:126]=arr
  r[254:255]=255
 ;
  g=bytarr(256)
  g[0]=0
  g[127]=255
  g[1:126]=arr
  g[128:253]=reverse(arr)
  g[254:255]=255
 ;
  b=bytarr(256)
  b[0]=0
  b[127]=255
  b[128:253]=reverse(arr)
  b[1:126]=255
  b[254:255]=255
 ;
  rgb_table=[[r],[g],[b]]
 ;
 ; Extract image from map (note: this means we're ignoring any
 ; /log or /reverse commands that have previously been performed). 
 ;
  img=map.data
 ;
 ; Set the max value used for scaling the plotted image.
 ;
  IF n_elements(dmax) NE 0 THEN max_value=dmax ELSE max_value=max(abs(img))
 ;
 ; Flag any missing data (set to black in final image)
 ;
  i_b=where(img EQ map.missing,n_b)
 ;
 ; Convert input image to a suitable byte array
 ;
  array_byte=bytscl(img,min=-max_value,max=max_value,top=252)
  array_byte=array_byte+1b
  img=temporary(array_byte)
  IF n_b NE 0 THEN img[i_b]=0b
 ;
 ; This removes min_value and max_value so that they aren't sent
 ; as inputs to image.pro.
 ;
  junk=temporary(min_value)
  junk=temporary(max_value)
ENDIF


IF keyword_set(overplot) THEN BEGIN
 ;
 ; c_label_show=0 means that contours won't be labeled.
 ;
  IF keyword_set(log) AND n_elements(levels) NE 0 THEN BEGIN
    k=where(levels GT 0,nk)
    IF nk GT 0 THEN c_levels=alog10(levels[k])
  ENDIF ELSE BEGIN
    c_levels=levels
  ENDELSE 
 ;
  IF n_elements(color) EQ 0 THEN color='yellow'
 ;
  p=contour(img,x,y,/overplot,c_value=c_levels,_extra=_extra, $
            color=color,c_label_show=0)
ENDIF ELSE BEGIN 
  IF n_elements(title) EQ 0 THEN BEGIN
   ;
   ; Here I'm trying to reproduce the title from the original
   ; plot_map, but I've removed the milliseconds (/trunc) as I never
   ; liked that! 
   ;
    datestr=anytim2utc(/vms,/date,map.time)
    timestr=anytim2utc(/ccsds,/time,/trunc,map.time)
    title=map.id+' '+datestr+' '+timestr+' UT'
  ENDIF 
 ;
 ; Plot the image
 ;
  p=image(img,x,y,_extra=_extra,axis_style=2, $
          min_value=min_value,max_value=max_value, $
          rgb_table=rgb_table, layout=layout, $
          margin=margin, title=title, $
          xtitle='Solar-X (arcsec)', $
          ytitle='Solar-Y (arcsec)')
ENDELSE 

return,p

END
