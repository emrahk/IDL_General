PRO movit_tv, data, size=size, offset=offset, gain=gain,$
              pixel=pixel, energy=energy
;+
; NAME:
;       movit_tv 
;
;
;
; PURPOSE:
;       Plot events on current window, uses TV.
;
;
; CALLING SEQUENCE:
;       movit_tv, data, size=size, pixel=pixel,show_energy=show_energy
;
;
;
; INPUTS:
;      Data - 2-dim double array with 4 columns as:
;             - time
;             - x-pos
;             - y-pos
;             - energy
;             for each event to display.
;             Per default all events are displayed.
;             
; OPTIONAL INPUTS:
;      offset - (double) what to add/subtract of image values. Default 0.
;      gain   - (double) factor to multiply image values with. Default 1.
;      size   - integer which defines the output size. Default is 64x64
;      pixel  - integer which defines the size of a single pixel
;               (event) to display, in units of screen pixels. Default: 4x4
;
; KEYWORD PARAMETERS:
;      energy - Per default all events are counted (integrated). If
;               show_energy is set the event with highest energy
;               is shown. 
;
;
;
; OUTPUTS:
;       Displays events on current window, color coded. 
;
;
;
;
; OPTIONAL OUTPUTS:
;      
;
; COMMON BLOCKS:
;       Beware!
;
; SIDE EFFECTS:
;       Changes current window.
;
; RESTRICTIONS:
;       Position should fit into size. 
;
;
; PROCEDURE:
;
; EXAMPLE:
;       
;
;
; MODIFICATION HISTORY:
;       $Log: movit_tv.pro,v $
;       Revision 1.3  2002/11/21 15:06:17  goehler
;       save/multi options
;
;       Revision 1.2  2002/11/20 07:56:18  goehler
;       added energy option
;
;       Revision 1.1  2002/11/19 17:33:22  goehler
;       initial integral event viewer
;
;
;-


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    IF n_elements(size) EQ 0 THEN size=64

    IF n_elements(offset) EQ 0 THEN offset=1.0

    IF n_elements(gain) EQ 0 THEN gain=1.0

    IF n_elements(pixel) EQ 0 THEN pixel=4

    ;; ------------------------------------------------------------
    ;; PLOT TO IMAGE
    ;; ------------------------------------------------------------


    IF NOT keyword_set(energy) THEN BEGIN 

        ;; create image with x/y column:    
        image = gain*(hist_2d(data[*,1],data[*,2],min1=0,max1=size,min2=0,max2=size) + offset)

    ENDIF ELSE BEGIN 

        image = dblarr(size,size)
      
        ;; sort according energy:
        ind = sort(data[*,3])
        
        ;; set energy:
        image[data[*,1],data[*,2]] = gain*(data[*,3]/100.)+offset
      
    ENDELSE 

    ;; set negative values at zero:
    image=image > 0
    

    ;; set size according pixel via rebin
    imgsize = size(image,/dimensions)
    image = rebin(image,imgsize[0]*pixel,imgsize[1]*pixel,/sample)
  

    ;; set values larger 255 at 255
    ind = where(image GT 255)
    IF ind[0] NE -1 THEN image[ind] = 255
    
    ;; ------------------------------------------------------------
    ;; PUT TO CURRENT WINDOW
    ;; ------------------------------------------------------------

    
    tv, image


END 
