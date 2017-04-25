;---------------------------------------------------------------------------
; Document name: itool_adj_ctable.pro
; Created by:    Liyun Wang, NASA/GSFC, March 13, 1996
;
; Last Modified: Wed Mar 13 18:05:01 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_adj_ctable, event, initialize=initialize
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_ADJ_CTABLE
;
; PURPOSE: 
;       Adjust color table interactively through a draw widget
;
; CATEGORY:
;       Image_tool, utility
; 
; SYNTAX: 
;       itool_adj_ctable, event
;       itool_adj_ctable, /initialize
;
; INPUTS:
;       EVENT - Draw widget event structure
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
;       INITIALIZE - Initialize some of parameters required
;
; COMMON:
;       CTABLE4ITOOL, COLORS (defined in use-library LOADCT)
;
; RESTRICTIONS: 
;       The draw widget must create button events
;       after 
;
; SIDE EFFECTS:
;       Color table is modified
;
; HISTORY:
;       Version 1, March 13, 1996, Liyun Wang, NASA/GSFC. Written
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
   COMMON ctable4itool, mevent, x00, wxsize, pstatus, vbot, vtop, gamma, $
      vbot0, vtop0, lgamma0, lgamma
 
   IF KEYWORD_SET(initialize) THEN BEGIN
      IF N_ELEMENTS(r_orig) EQ 0 THEN BEGIN
         TVLCT, r_orig, g_orig, b_orig, /get
         r_curr = r_orig
         g_curr = g_orig
         b_curr = b_orig
      ENDIF
      vbot = 0
      vtop = 100
      lgamma = 50
      gamma = 1.0
      RETURN
   ENDIF

   IF TAG_NAMES(event, /structure_name) NE 'WIDGET_DRAW' THEN RETURN
   
   CASE (event.type) OF
      0: BEGIN
;---------------------------------------------------------------------------
;        Button pressed; record some basic info
;---------------------------------------------------------------------------
         IF N_ELEMENTS(gamma) EQ 0 THEN BEGIN
            vbot = 0
            vtop = 100
            lgamma = 50
            gamma = 1.0
         ENDIF
         vtop0 = vtop
         vbot0 = vbot
         lgamma0 = lgamma
         x00 = event.x
         pstatus = event.press
         mevent = WIDGET_INFO(event.id, /draw_motion)
;---------------------------------------------------------------------------
;        Set draw motion event on, and get xsize of the widget window
;---------------------------------------------------------------------------
         WIDGET_CONTROL, event.id, draw_motion=1, get_value=cur_wid
         win_saved = !d.window
         wset, cur_wid
         wxsize = FLOAT(!d.x_size)
         wset, win_saved
      END
      1: BEGIN 
;---------------------------------------------------------------------------
;        Button released; set the motion event attribute back
;---------------------------------------------------------------------------
         WIDGET_CONTROL, event.id, draw_motion=mevent
      END
      ELSE:
   ENDCASE
   
;---------------------------------------------------------------------------
;  Return if it is not a motion event
;---------------------------------------------------------------------------
   IF event.type NE 2 THEN RETURN
   
   dx = 100*FLOAT(event.x-x00)/wxsize
   
   CASE (pstatus) OF
      1: BEGIN
;---------------------------------------------------------------------------
;        Dragging left button, streching bottom
;---------------------------------------------------------------------------
         vbot = (vbot0+dx) > 0 < 100
     END
      2: BEGIN
;---------------------------------------------------------------------------
;        Dragging middle button, adjust gamma
;---------------------------------------------------------------------------
         lgamma = (lgamma0+dx) > 0 < 100
         gamma = 10^((lgamma/50.) - 1)
      END
      4: BEGIN 
;---------------------------------------------------------------------------
;        Dragging right button, streching top
;---------------------------------------------------------------------------
         vtop = (vtop0+dx) > 0 < 100
      END
      ELSE:
   ENDCASE
   
   nc = !d.table_size
   s = (nc-1)/100.
   cbot = 0

   x0 = vbot * s
   x1 = vtop * s
   IF x0 NE x1 THEN s = (nc-1.0)/(x1 - x0) ELSE s = 1.0
   int = -s * x0
   IF gamma EQ 1.0 THEN $
      s = ROUND(FINDGEN(nc) * s + int > 0.0) $
   ELSE $
      s = ((FINDGEN(nc) * (s/nc) + (int/nc) > 0.0) ^ gamma) * nc
   s = s + cbot
   r_curr(cbot) = (r=r_orig(s))
   g_curr(cbot) = (g=g_orig(s))
   b_curr(cbot) = (b=b_orig(s))
   TVLCT, r, g, b, cbot
   
   RETURN
END

;---------------------------------------------------------------------------
; End of 'itool_adj_ctable.pro'.
;---------------------------------------------------------------------------
