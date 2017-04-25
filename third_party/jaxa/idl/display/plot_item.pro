PRO plot_item, t1, t2, row, label, $
               color=color, maxcharsize=maxcharsize, tt=tt, ucolor=ucolor
;+
; Project     :	SOHO - CDS
;
; Name        :	PLOT_ITEM
;
; Purpose     :	Plots individual planning items on science plan.
;
; Explanation :	This routine plots lines for the beginning and end times of a
;		given planning item for a particular instrument at the
;		appropriate point on the science plan display.  The text label
;		for the item is then written inside the resulting box.
;
; Use         :	PLOT_ITEM, T1, T2, ROW, LABEL
;
; Inputs      :	T1	= The start time for the item.
;		T2	= The end time for the item.
;		ROW	= The row that the item belongs to.
;		LABEL	= The label for the item.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	MAXCHARSIZE = The maximum character size to use in displaying
;			      the message.  If not passed, then determined from
;			      !P.CHARSIZE.
;		COLOR	    = The color in which the item should be drawn.
;               TT          = 1 or 0 if ITEM is TIME-TAGGED or NOT
;		UCOLOR	    = The color in which the un-time-tagged
;		              item should be drawn.
;
; Calls       :	WRITE_IN_BOX
;
; Common      :	None.
;
; Restrictions:	PLAN_FRAME must be called first.
;
; Side effects:	None.
;
; Category    :	Planning, Science.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 16 July 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 16 July 1993.
;		Version 2, Elaine Einfalt, GSFC (HSTX), 23 March 1994
;			Added the COLOR keyword to the call to WRITE_IN_BOX.
;               Version 2.1, Dominic Zarro (ARC), 18 September 1994
;                       Vectorized
;               Version 2.2, Liyun Wang, GSFC/ARC, May 17, 1995
;                       Changed name from plan_item_plot.
;               Version 2.3, Liyun Wang, GSFC/ARC, Liyun Wang, GSFC/ARC
;                       Made the line for an item that is cut off by the
;                          display plotted dashed line
;               Version 2.3.1, Dominic Zarro, ARC, added UCOLOR and TT
;               Version 2.4, Liyun Wang, GSFC/ARC, August 22, 1995
;                       Modified such that if LABEL is an empty string, 
;                          the item is plotted with the polyfill function
;
; Version     :	Version 2.4, August 22, 1995
;-
;
   ON_ERROR, 2

;---------------------------------------------------------------------------
;  Check the number of parameters
;---------------------------------------------------------------------------
   IF N_PARAMS() NE 4 THEN MESSAGE,	$
      'Syntax:  PLOT_ITEM, T1, T2, ROW, LABEL'

;---------------------------------------------------------------------------
;  Check to see if the item should be displayed
;---------------------------------------------------------------------------
   IF N_ELEMENTS(color) EQ 0 THEN color = !p.color
   IF N_ELEMENTS(maxcharsize) EQ 0 THEN maxcharsize = !p.charsize
   nt = N_ELEMENTS(t1)
   IF N_ELEMENTS(tt) EQ 0 THEN tt = REPLICATE(1, nt)
   IF N_ELEMENTS(ucolor) EQ 0 THEN ucolor = 0

   FOR i=0L, nt-1 DO BEGIN

      x1 = t1(i) > !x.crange(0)
      x2 = t2(i) < !x.crange(1)
      
      IF x1 EQ !x.crange(0) THEN lstyle1 = 2 ELSE lstyle1 = 0
      IF x2 EQ !x.crange(1) THEN lstyle2 = 2 ELSE lstyle2 = 0

      pcolor = color
      IF (NOT tt(i)) AND (ucolor GT 0) THEN pcolor = ucolor

      IF x2 GE x1 THEN BEGIN
         OPLOT, [x1, x1], [row, row+1], psym=0, linestyle=lstyle1, color=pcolor
         OPLOT, [x2, x2], [row, row+1], psym=0, linestyle=lstyle2, color=pcolor
         IF x2 GT x1 THEN BEGIN
            IF STRTRIM(label(i), 2) NE '' THEN $
               write_in_box, x1, x2, row, row+1, label(i), $
               color=pcolor, maxcharsize=maxcharsize $
            ELSE $
               polyfill, [x1, x2, x2, x1], [row, row, row+1, row+1], $
               color=pcolor
         ENDIF
      ENDIF
   ENDFOR

   RETURN
END
