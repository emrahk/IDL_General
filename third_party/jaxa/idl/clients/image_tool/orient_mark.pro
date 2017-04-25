;---------------------------------------------------------------------------
; Document name: orient_mark.pro
; Created by:    Liyun Wang, NASA/GSFC, May 30, 1995
;
; Last Modified: Thu Aug 14 18:23:32 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO orient_mark, csi=csi, color=color
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ORIENT_MARK
;
; PURPOSE:
;       Plot orientation mark over the display
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       orient_mark, csi=csi
;
; INPUTS:
;       CSI - Coordinate System Info structure
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
; KEYWORD PARAMETERS:
;       COLOR - Index of color to be used for plotting; defaults to
;               !d.n_colors-1 
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;
; PREVIOUS HISTORY:
;       Written May 30, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, May 30, 1995
;       Version 2, April 1, 1996, Liyun Wang, NASA/GSFC
;          Added COLOR keyword
;       Version 3, August 14, 1997, Liyun Wang, NASA/GSFC
;          Made the mark independent from scaling factor
;	Version 4, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; VERSION:
;	Version 4, 8 April 1998
;-
;
   ON_ERROR, 2
   x = csi.drpix1+0.91*csi.daxis1
   y = csi.drpix2+0.91*csi.daxis2
   IF N_ELEMENTS(color) EQ 0 THEN color = !d.table_size-1
   length = 30
   xextra = 0
   yextra = 0
   IF csi.cdelt1 GT 0.0 THEN BEGIN
      xx = length
      xextra = 3
   ENDIF ELSE BEGIN
      xx = -length
      x = x-xx
   ENDELSE
   IF csi.cdelt2 GT 0.0 THEN BEGIN
      yy = length
   ENDIF ELSE BEGIN
      yy = -length
      y = y-yy
      yextra = 3
   ENDELSE
   PLOTS, [x, x], [y,y+yy], /DEVICE, color=color
   XYOUTS, x, y+1.15*yy-yextra, 'N', /device, align = 0.5, color=color

   PLOTS, [x,x+xx],[y,y], /DEVICE, color=color
   XYOUTS, x+1.17*xx+xextra, y-3, 'W', /DEVICE, align = 0.5, color=color
   RETURN
END

;---------------------------------------------------------------------------
; End of 'orient_mark.pro'.
;---------------------------------------------------------------------------
