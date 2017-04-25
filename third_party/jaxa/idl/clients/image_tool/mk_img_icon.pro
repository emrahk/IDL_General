;+
; Project     : SOHO-CDS
;
; Name        : MK_IMG_ICON
;
; Purpose     : iconize an image
;
; Category    : planning
;
; Explanation : return a byte-scaled image array at a specified icon size 
;               based on the original image. Use TV (not TVSCL) to display it
;
; Syntax      : icon=mk_img_icon(icon_size,image)

; Examples    :
;
; Inputs      : ICON_SIZE = output icon pixel size
;               IMAGE = input image array
;
; Opt. Inputs : 
;
; Outputs     : ICON = iconized image
;
; Opt. Outputs: 
;
; Keywords    : ERR = error string (blank if none)
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 1 July 1998 D. Zarro, SAC/GSFC
;               (extracted from IMAGE_TOOL)
;
; Contact     : dzarro@solar.stanford.edu
;-

FUNCTION mk_img_icon, icon_size, image, err=err

   err = ''
   sz = SIZE(image)
   IF sz(0) LE 1 THEN BEGIN
      err = '2D array required.'
      MESSAGE, err, /cont
      RETURN, 0
   ENDIF
   top = !d.table_size-1
   cmin = MIN(image)
   cmax = MAX(image)
   IF sz(1) EQ sz(2) THEN BEGIN
      icon = BYTSCL(congrid(image, icon_size, icon_size), $
                    min=cmin, max=cmax, top=top)
   ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;     Make sure the icon image array always has the same size
;---------------------------------------------------------------------------
      ysize = FIX((icon_size*sz(2))/sz(1))
      IF sz(2) LT sz(1) THEN BEGIN
         icon = [[congrid(image, icon_size, ysize)], $
                 [BYTARR(icon_size, icon_size-ysize)]]
         icon = BYTSCL(icon, min=cmin, max=cmax, top=top)
      ENDIF ELSE BEGIN
         xsize = FIX((icon_size*sz(1))/sz(2)) > 1
         temp = BYTARR(icon_size-xsize, icon_size)
         icon = TRANSPOSE([[TRANSPOSE(congrid(image, xsize, icon_SIZE))], $
                           [TRANSPOSE(temp)]])
         icon = BYTSCL(icon, min=cmin, max=cmax, top=top)
      ENDELSE
   ENDELSE
   RETURN, icon
END
