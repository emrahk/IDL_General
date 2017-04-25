;+
; Project     : SOHO - CDS     
;                   
; Name        : FIND_DRAW_WIDGET()
;               
; Purpose     : Find the widget ID corresponding to a draw window.
;               
; Explanation : To use the WIDGET_EVENT routine instead of the CURSOR
;               procedure one needs to be able to find out whether a draw
;               window is actually a WIDGET_DRAW window, if this is not known
;               a priori.
;
;               This routine simplifies the rewrites necessary to convert
;               CURSOR-dependent routines into widget-driven
;               routines. FIND_DRAW_WIDGET() finds and returns the WIDGET_DRAW
;               ID of the window (if it exists) by performing a search through
;               possible widget IDs. If the corresponding widget ID is not
;               found, -1L is returned.
;
;               The routine assumes that widgets are given ever-increasing ID
;               numbers, starting from 0L (or higher).
;
;               The routine is also a lot faster than one would expect for
;               such an exhaustive search - partially because of a cache
;               system keeping track of which widgets have been searched.
;
; Use         : WIDGET = FIND_DRAW_WIDGET(WINDOW)
;    
; Inputs      : WINDOW : The window number (as in WSET,WINDOW)
; 
; Opt. Inputs : None.
;               
; Outputs     : Returns the WIDGET_DRAW ID corresponding to the draw window,
;               or -1L if none is found (this means the draw window is *not* a
;               widget window).
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: Assumes widgets are given ever-increasing ID numbers starting
;               from zero (or higher).
;               
; Side effects: None.
;               
; Category    : Display, Widgets
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar H. Haugan, UiO, 15 May 1997
;               
; Modified    : Not yet.
;
; Version     : 1, 15 May 1997
;-            

FUNCTION find_draw_widget,window
  COMMON find_draw_widget_cache,widgets,windows,lastcheck,topbase
  
  ;; Check cache contents first.
  
  IF n_elements(widgets) GT 0 THEN BEGIN
     ix = where(windows EQ window,count)
     FOR i = count-1,0L,-1L DO BEGIN
        ;; If it's still alive, it's the one..
        IF widget_info(widgets(ix(i)),/valid_id) THEN return,widgets(ix(i))
     ENDFOR
  END
  
  ;; Ok - couldn't find it in the current cache.
  ;; Update cache with the latest widgets, and check again.
  
  ;; First purge any deceased widgets.
  IF n_elements(widgets) GT 0L THEN BEGIN 
     validix = where(widget_info(widgets,/valid_id))
     IF validix(0) EQ -1L THEN BEGIN
        dummy = temporary(widgets)
        dummy = temporary(windows)
     END ELSE BEGIN
        widgets = widgets(validix)
        windows = windows(validix)
     END
  END
  
  ;; It turns out that creating and destroying a child base inside an existing
  ;; top level base is about 3 times faster than creating and destroying a top
  ;; level base. Not deleting the child base would save another factor of two,
  ;; at the expense of gradual memory leakage (though curable by
  ;; WIDGET_CONTROL,/RESET)
  
  IF n_elements(topbase) NE 1 THEN BEGIN
     topbase = widget_base()
     nextwid = topbase
  END ELSE BEGIN
     IF NOT widget_info(topbase,/valid) THEN BEGIN
        topbase = widget_base()
        nextwid = topbase
     END ELSE BEGIN
        nextwid = widget_base(topbase)
        widget_control,nextwid,/destroy
     END
  END
  
  IF n_elements(lastcheck) EQ 0 THEN lastcheck = -1L
    
  FOR i = lastcheck+1,nextwid-1 DO BEGIN
     IF widget_info(i,/valid_id) THEN BEGIN
        IF widget_info(i,/type) EQ 4 THEN BEGIN
           widget_control,i,get_value=thiswindow
           IF n_elements(widgets) EQ 0 THEN BEGIN
              widgets = [i] & windows = [window]
           END ELSE BEGIN
              widgets = [widgets,i] & windows = [windows,thiswindow]
           END
        END
     END
  END
  
  ;; Now we've checked this far..
  lastcheck = nextwid
  
  IF n_elements(widgets) GT 0 THEN BEGIN
     ix = where(windows EQ window,count)
     IF count GT 0 THEN return,widgets(ix(count-1))
  END

  return,-1L
END

