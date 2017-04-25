;---------------------------------------------------------------------------
; Document name: itool_plot_axes.pro
; Created by:    Liyun Wang, NASA/GSFC, March 13, 1995
;
; Last Modified: Thu Sep 25 16:46:20 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_plot_axes, csi=csi, title=title
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ITOOL_PLOT_AXES
;
; PURPOSE:
;       Plot axes and labels around the current displayed image
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       itool_plot_axes, csi=csi
;
; INPUTS:
;       CSI - Coordinate system info structure
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
;       None.
;
; CALLS:
;       TVAXIS
;
; COMMON BLOCKS:
;       ITOOL_AXES_COM (used by PT_REFRESH_BASE in mk_point_base.pro)
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
;       Written March 13, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, March 13, 1995
;       Version 2, Liyun Wang, NASA/GSFC, April 11, 1995
;          Made data coordinate system established after calling this routine
;       Version 3, August 28, 1996, Liyun Wang, NASA/GSFC
;          Used XRANGE and YRANGE keywords (instead of ORIGIN and
;             SCALE) in call to TVAXIS for better accuracy
;
; VERSION:
;       Version 3, August 28, 1996
;-
;
   COMMON itool_axes_com, x_range, y_range
   ON_ERROR, 2
   
   itool_range, csi, xrange=x_range, yrange=y_range
   
;---------------------------------------------------------------------------
;  The DATA keyword is used for establishing the data coordinate system
;---------------------------------------------------------------------------
   tvaxis, xrange=x_range, yrange=y_range, /data
   
;---------------------------------------------------------------------------
;  I want ticks to be plotted outward
;---------------------------------------------------------------------------
   saved_p = !p
   !p.ticklen = -0.01
   tvaxis, xaxis=0, xtitle=title(0)
   tvaxis, xaxis=1, /noxlabel
   tvaxis, yaxis=0, ytitle=title(1)
   tvaxis, yaxis=1, /noylabel

   !p = saved_p

END

;---------------------------------------------------------------------------
; End of 'itool_plot_axes.pro'.
;---------------------------------------------------------------------------
