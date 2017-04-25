;+
; Project     : Hinode/EIS
;
; Name        : BLEND_MAP
;
; Purpose     : Blend two maps by adjusting opacity using object 
;               graphics alpha channel
;
; Category    : imaging maps
;
; Syntax      : IDL> blend_map,backmap,foremap
;
; Inputs      : BACKMAP = background image map
;               FOREMAP = foreground image map
;
; Outputs     : Foreground image is overlaid on background image, and
;               its visibility is controlled by a slider.
;
; Keywords    : DIMENSIONS = plot window size (def = [512,512])
;               EXTRA = plot_map keywords to control plotting of  background
;               image map
;
; History     : Written, 3 April 2007, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

 pro blend_map,backmap,foremap,_extra=extra,dimensions=dimensions

 if (1-valid_map(backmap)) or (1-valid_map(foremap)) then begin
  pr_syntax,'blend_map,background_map,foreground_map'
  return
 endif

 if n_elements(dimensions) ne 2 then dimensions=[512,512]

;-- save current plot device and switching to Z-buffer

 s_device=!d.name
 set_plot,'z'
 device,set_res=dimensions
 xsize=dimensions[0] & ysize=dimensions[1]

;-- plot backgound map within FOV of foreground map, and restore as a
;   byte image from the Z-buffer

 plot_map,backmap,fov=foremap,_extra=extra,dimensions=dimensions
 back=tvrd()

;-- plot foreground map (without titles and axes) and restore as well

 plot_map,foremap,/noaxes,/notit,dimensions=dimensions

 fore=tvrd()

;-- return original device and call image_blend

 set_plot,s_device
 image_blend,back,fore,dimensions=dimensions,_extra=extra,color=1

 return & end
