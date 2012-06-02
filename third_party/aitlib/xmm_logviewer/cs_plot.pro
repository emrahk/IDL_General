;+
; NAME:
;cs_plot.pro
;
;
; PURPOSE:
;reads and plots datatype 
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
; cs_plot, datatype
;
;
; INPUTS:
;datatype
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;needs: cs_xmm_logviewer_load_subroutines
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_plot, datatype
get_current_xwerte, datatype, current_xwerte=current_xwerte
get_current_ywerte, datatype, current_ywerte=current_ywerte
get_current_xparameter, datatype,current_xparameter=current_xparameter
get_current_yparameter, datatype, current_yparameter=current_yparameter
get_sym, datatype, sym=sym
get_background, datatype, background=background
get_color, datatype, color=dataColor
get_y_style, datatype, y_style=y_style
get_current_xunit, datatype,current_xunit=current_xunit
get_current_yunit, datatype,current_yunit=current_yunit
Plot, current_xwerte,current_ywerte , Background=background, Color=255-background, /NoData, xtitle=current_xparameter+' ['+current_xunit+']',ytitle=current_yparameter+' ['+current_yunit+']',/XSTYLE, YSTYLE=y_style
OPlot, current_xwerte, current_ywerte, Color=dataColor, psym=sym
END
