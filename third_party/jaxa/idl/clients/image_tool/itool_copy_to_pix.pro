;---------------------------------------------------------------------------
; Document name: itool_copy_to_pix.pro
; Created by:    Liyun Wang, NASA/GSFC, June 12, 1997
;
; Last Modified: Thu Jun 12 10:38:43 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_copy_to_pix
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_COPY_TO_PIX
;
; PURPOSE: 
;       Copy current main plot window to a pixmap window for later use
;
; CATEGORY:
;       IMAGE_TOOL
; 
; SYNTAX: 
;       itool_copy_to_pix
;
; INPUTS:
;       None.
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
; KEYWORDS: 
;       None.
;
; COMMON:
;       @image_tool_com
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, June 12, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com
   ON_ERROR, 2
   
   IF (grep(!d.name, ['X', 'WIN', 'SUN', 'MAC']))(0) NE '' THEN BEGIN
;---------------------------------------------------------------------------
;     Save current image/plot into pix_win.id
;---------------------------------------------------------------------------
      saved_win = !d.window
      win_xsw=!d.x_size
      win_ysw=!d.y_size
;      dprint,'% (1) win_xs,win_ys:',$
;       win_xs,win_ys,!d.x_size,!d.y_size,!d.x_vsize,!d.y_vsize
      WSET, pix_win.id
;      dprint,'% (2) win_xs,win_ys:',$
;       win_xs,win_ys,!d.x_size,!d.y_size,!d.x_vsize,!d.y_vsize
      DEVICE, copy=[0, 0, win_xs < win_xsw, win_ys < win_ysw, 0, 0, saved_win]
      WSET, saved_win
   ENDIF  
END

;---------------------------------------------------------------------------
; End of 'itool_copy_to_pix.pro'.
;---------------------------------------------------------------------------
