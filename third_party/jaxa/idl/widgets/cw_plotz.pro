;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_PLOTZ()
;               
; Purpose     : One-window compound widget plot zoom
;               
; Explanation : CW_PLOTZ is a general purpose plotting widget that lets the
;               user zoom in and out on an (alterable) plotted array.
;
;               The widget is crated in much the same way as a standard
;               widget_draw window, although a number of extra keywords are
;               used in order to control the appearance of the display
;               (display window size, title, subtitle, etc.).
;
;      SETTING THE ARRAY TO BE PLOTTED
;
;               can be done through the VALUE keyword of CW_PLOTZ or through
;               the WIDGET_CONTROL SET_VALUE mechanism. The latter should only
;               be done after the widget hierarchy has been /realized. Setting
;               the value is done by:
;               
;               widget_control,CW_ID,set_value=array
;
;               where "array" is either:
;
;                    a one-dimensional array to be plotted (no x scale
;                    information)
;                or:
;                    a two-dimensional array (N,2) with the X values in
;                    (*,0) and the Y values in (*,1).
;                    
;               The display is refreshed each time the array is changed.
;
;      CONTROLLING THE COMPOUND WIDGET BEHAVIOUR
;               
;               The appearance and behaviour of this compound widget is
;               controlled by numerous status variables. The status variables
;               can be set either through the use of keywords in the
;               CW_PLOTZ() call, or by using e.g.:
;
;                    WIDGET_CONTROL,CW_ID,SET_VALUE = STRUCT
;
;               where CW_ID is the compound widget ID and STRUCT is a
;               structure with one or more tags corresponding to display
;               attributes to be altered. To set e.g., the plot TITLE to be
;               used:
;
;                   WIDGET_CONTROL,CW_ID,SET_VALUE = {TITLE:'Zoomable plot'}
;
;               See the "KEYWORD DEFAULTS/EXPLANATIONS" section in the main
;               procedure for an updated list of all the status variables that
;               may be set through the use of keywords. If a keyword is not
;               marked with a "*" in the comment section, then it is also
;               possible to set this status variable through the SET_VALUE
;               mechanism.
;
;               If the status variable CLING is set to 1, the actual
;               data coordinate values of a user button press are ignored,
;               and the (x,y) values of the closest data point is used.
;               Otherwise, the status variables XFOCUS and YFOCUS are used
;               to mark the spot where the user pressed (and where the
;               focus point symbol is drawn).
;
;               The status variable ZOOM controls the zoom factor, and is
;               initialized to one. Zoom = 1 means all data is visible.
;               
;               The status variables REPLOT and REPLOT_FOCUS are "write
;               sensitive":
;
;               REPLOT  : Setting this to 1 causes the display to
;                         be refreshed.
;               REPLOT_FOCUS : Setting this to 1 causes the focus point to
;                              be redrawn, without redisplaying the image.
;
;               NO REFRESH IS PERFORMED by set_value when altering
;               attributes WITHOUT setting THE REPLOT ATTRIBUTE
;
;      EVENT HANDLING
; 
;               CW_PLOTZ can be used in a "dumb" mode through the use of the
;               /AUTONOMOUS keyword when creating the widget.  This causes the
;               widget to self-acknowledge all zooming/refocusing events,
;               refreshing the display without passing on events to the parent
;               base.
;               
;               Unless the /AUTONOMOUS keyword is set, all WIDGET_DRAW event
;               are processed in the event handler into an "action string", by
;               default:
;
;               "ZOOM-" for ev.press eq 1 (left button)
;               "ZOOMP" for ev.press eq 2 (middle button)
;               "ZOOM+" for ev.press eq 4 (right button)
;
;               and
;               
;               "IGNORE" for any other widget_draw event.
;
;               The status variable IGNORE_ACTION contains a string with
;               a list of action texts to ignore, in the format:
;
;                   "(IGNORE)(MOTION)(RELEASE1)(RELEASE2)(RELEASE3)"
;
;               If an event is translated into an action string that appears
;               in the IGNORE_ACTION list, the event is gobbled up and
;               ignored.
;
;               If you'd like the user to be in control of (and to be able to
;               see) what buttons to use, you can use a CW_MOUSE widget (see
;               keyword CW_MOUSE, and the documentation of CW_MOUSE()).  The
;               CW_MOUSE actions recognized by CW_PLOTZ are:
;
;               "ZOOM+" for zooming in (no repointing)
;               "ZOOM-" for zooming out (no repointing)
;               "ZOOMP" for repointing (or anything else not on the
;                       IGNORE_ACTION list)
;
;               For ZOOM+/ZOOM- actions, the new ZOOM factor is calculated,
;               but the coordinates of the button press is ignored.  For any
;               other action not to be ignored, the event coordinates are
;               converted into data coordinates (new XFOCUS/YFOCUS, values are
;               taken from the nearest datat point if CLING is set).
;
;               After this, a {CW_PLOTZ_EVENT} structure is created, and
;               passed on to the owner of the compound widget. Note that NO
;               SCREEN OR STATUS UPDATES have been done at this stage (see
;               "acknowledging events" below).
;
;               The event structure {CW_PLOTZ_EVENT} generated by CW_PZOOM
;               consists of the following tags:
;
;               ID       : Widget ID of cw_plotz
;               TOP      : Top widget ID.
;               HANDLER  : Handler widget ID
;
;               SET      : A structure with new information generated
;                          by the user pressing a mouse button. The
;                          tags of this structure {CW_PLOTZ_SET} are:
;
;                   XFOCUS : X data coordinate of draw event
;                   YFOCUS : Y data coordinate of draw event
;                   FOCUSI : The index of the nearest plot point
;                   ZOOM   : The new/current zoom factor.
;                   REPLOT : Always has a value of 1
;
;               OLD      : Contains the same tags as SET, but with
;                          the old (currently displayed) values.
;
;               PLOTREG : The Plot Region that has been used to
;                         display the image. Useful for overplotting
;                         after executing PRESTORE,EVENT.PLOTREG etc.
;
;               EVENT   : The original WIDGET_DRAW event, or if you use an
;                         XPLOTSCALE object to let the user control the plot
;                         scaling, it could also be an XPLOTSCALE event.
;
; 
;      ACKNOWLEDGING EVENTS
;
;               In order to acknowledge the event to make the user changes
;               effective, all that has to be done is to use:
;
;                    WIDGET_CONTROL,EV.ID,SET_VALUE=EV.SET
;
;               this is in fact all that is done when the autonomous mode is
;               used.
;
;      OVERPLOTTING THE DISPLAY
;
;               Since the acknowledgement of a zoom/repointing event, or
;               changing the displayed data causes the display to be updated,
;               overplotting should be done AFTER setting the focus and/or
;               zoom values with replot set to 1. Replotting changes the
;               current data coordinate system, so overplotting may be done in
;               data coordinates.
;
;               Useful entities for overplotting can be retrieved through a
;               call to WIDGET_CONTROL,CW_ID,GET_VALUE=STATUS, where CW_ID is
;               the CW_PLOTZ widget ID, and STATUS will be returned as a
;               structure with the following tags {CW_PLOTZ_VALUE}:
;
;               VALUE  : HANDLE that points to the data in the form of
;                        an array with (N,2) elements.
;                        Note that the data must not be removed or
;                        altered directly!
;               XFOCUS : X data coordinate of focus point
;               YFOCUS : Y data coordinate of focus point
;               FOCUSI : Index of the current focus point
;               PLOTREG: The plot region used to display the image.
;
;               A note on XTICKS:
;               
;               The use of XTICKS is somewhat tricky. The standard IDL way of
;               interpreting this keyword normally gives nonsensical results,
;               so CW_PZOOM tries to make the tickmarks fall on the center of
;               the pixels (which looks good for _some_ types of data). It is
;               also possible to use the function TICK_VEC by setting XTICKS
;               to a negative value. TICK_VEC tries to do a decent job of
;               placing UP TO the given number of tickmarks on the
;               display. Try it.
;               
; Use         : PZOOM = CW_PLOTZ(BASE [,KEYWORDS])
;    
; Inputs      : BASE : The base to put the draw window on.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns the widget ID of the compound widget.
;               
; Opt. Outputs: None.
;               
; Keywords    : Too many to justify updating a separate list here. See the
;               KEYWORD DEFAULTS section inside the routine.
;
; Calls       : COPY_TAG_VALUES, CW_TMOUSE(), DATATYPE(), DEFAULT,
;               HANDLE_CREATE(), PARCHECK, PCONVERT(), PFIND(), PRESTORE,
;               PSTORE(), TICK_VEC(), TYP(), WIDGET_BASE()
;
; Common      : None.
;               
; Restrictions: Surely some.
;               
; Side effects: Updating the !P,!X,!Y system variables when refreshing the
;               display.
;               
; Category    : Utility, Display
;               
; Prev. Hist. : Basically identical to CW_PZOOM.
;
; Written     : Stein Vidar Hagfors Haugan, UiO, 3 June 1996
;               
; Modified    : Version 2, SVHH, 13 June 1996
;                       Added X/YTYPE for logarithmic plots.
;               Version 3, SVHH, 28 June 1996
;                       Added fix for yrange when all points are equal.
;               Version 4, SVHH, 1 July 1996
;                       Added /CLEAN switch to PSTORE(), to delete any
;                       previous use of the same window number.
;               Version 5, 19 August 1996
;                       Modified handling of initial VALUE keyword.
;               Version 6, 21 January 1997
;                       Added possibility of XPLOTSCALE handling of plotting
;                       range.
;                       
; Version     : 6, 21 January 1997
;-            

PRO cw_plotz_plot,info
  
  ;; KEEP !X, !Y, !P
  OLD_X = !X
  OLD_Y = !Y
  OLD_P = !P
  
  handle_value,info.value,value,/no_copy
  
  ;;
  ;; Calculate abscissa range
  ;;
  min_abscissa = MIN(value(*,0))
  max_abscissa = MAX(value(*,0))
  mid_abscissa = (min_abscissa+max_abscissa)*0.5D
  
  half_range = (max_abscissa-min_abscissa)/(info.ext.zoom*2)
  
  glued = info.ext.zoom le 1.0 
  
  ;; Finding the grab box
  startx = info.ext.xfocus-half_range
  
  IF info.ext.zoom LE 1.0 THEN BEGIN
     startx = mid_abscissa - half_range
  END ELSE IF info.ext.zoom EQ 2 THEN BEGIN
     ;; A compromize between glued/focus-centered position
     startx = (2.0*startx + (mid_abscissa-half_range))/3.0
  END
  
  xrange = [startx,startx+2*half_range]
  
  IF info.ext.xplotscale NE -1 THEN BEGIN
     scale = xplotscale(info.ext.xplotscale,value,xrange,missing=missing)
     info.ext.missing = missing
     info.ext.ytype = scale(2)
     scale = scale(0:1)
  END ELSE BEGIN
     missing = info.ext.missing
  END
  
  
  good = value(*,1) NE missing
  goodix = where(good,ngood)
  
  ;;
  ;; Drop further work if no good points
  ;;
  IF ngood EQ 0 THEN BEGIN
     handle_value,info.value,value,/set,/no_copy
     IF !D.name NE 'PS' THEN BEGIN
        wset,info.int.tv
        erase
     END
     RETURN
  END
  
  min_ordinate = MIN(value(goodix,1))
  max_ordinate = MAX(value(goodix,1))
  
  ;; Renormalizing focus coordinates (just checking)
  info.ext.xfocus = (info.ext.xfocus > min_abscissa) < max_abscissa
  info.ext.yfocus = (info.ext.yfocus > min_ordinate) < max_ordinate
  
  
  IF info.ext.replot THEN BEGIN
     !X.range = xrange
     IF n_elements(scale) EQ 0 THEN BEGIN
        yrange = [MIN(value(goodix,1)),MAX(value(goodix,1))]
        IF yrange(0) EQ yrange(1) THEN yrange = ext_range(yrange,10)
        IF NOT info.ext.ytype THEN !Y.range = yrange $
        ELSE BEGIN
        
           ;;  Idl's not very good at coping without this:
           
           yrange = [10^FIX(alog10(abs(yrange(0)))), $
                     10^(FIX(alog10(abs(yrange(1)))+0.9999999))]
        END
     END ELSE BEGIN
        yrange = scale
     END
     
     !Y.range = yrange
     
     position = [info.ext.origo,info.ext.origo + info.int.dsize-1]+0.00001
     
     IF !d.name EQ 'PS' THEN BEGIN
        !P.noerase = 1
        position = [!P.clip(0),!p.clip(1),!P.clip(2),!P.clip(3)]
        xsize = !P.clip(2)-!P.clip(0)
        ysize = !P.clip(3)-!P.clip(1)
        origo = !P.clip(0:1)
     END ELSE BEGIN
        xsize = 0
        ysize = 0
        wset,info.int.tv
     END
     
     blank = STRING(255b)
     
     ;; Shorthand
     e = info.ext
     
     IF e.background NE -1L THEN !P.background = e.background
     IF e.charsize NE -1.0 THEN !P.charsize = e.charsize
     IF e.xcharsize NE -1.0 THEN !X.charsize = e.xcharsize
     IF e.ycharsize NE -1.0 THEN !Y.charsize = e.ycharsize
     IF e.charthick NE -1.0 THEN !P.charthick = e.charthick
     IF e.color NE -1L THEN !P.color = e.color
     IF e.font NE -2L THEN !P.font = e.font
     IF e.xgridstyle NE -1L THEN !X.gridstyle = e.xgridstyle
     IF e.ygridstyle NE -1L THEN !Y.gridstyle = e.ygridstyle
     IF e.linestyle NE -1L THEN !P.linestyle = e.linestyle
     IF e.psym NE -10L THEN !P.psym = e.psym
     IF e.xstyle NE -1L THEN !X.style = e.xstyle
     IF e.ystyle NE -1L THEN !Y.style = e.ystyle
     IF e.subtitle NE blank THEN !P.subtitle = e.subtitle
     IF e.symsize NE -1.0 THEN !P.symsize = e.symsize
     IF e.thick NE -1.0 THEN !P.thick = e.thick
     IF e.xthick NE -1.0 THEN !X.thick = e.xthick
     IF e.ythick NE -1.0 THEN !Y.thick = e.ythick
     IF e.xtickformat NE blank THEN !X.tickformat = e.xtickformat
     IF e.ytickformat NE blank THEN !Y.tickformat = e.ytickformat
     IF e.xticks GE 0 THEN !X.ticks = e.xticks ; ****
     IF e.yticks NE 0 THEN !Y.ticks = e.yticks
     IF e.ticklen NE 0.0 THEN !P.ticklen = e.ticklen
     IF e.xticklen NE 0.0 THEN !X.ticklen = e.xticklen
     IF e.yticklen NE 0.0 THEN !Y.ticklen = e.yticklen
     IF e.title NE blank THEN !P.title = e.title
     IF e.xtitle NE blank THEN !X.title = e.xtitle
     IF e.ytitle NE blank THEN !Y.title = e.ytitle
     
     ;; Any points inside the range?
     
     valix = WHERE(good AND value(*,0) GE xrange(0)  $
                   AND value(*,0) LE xrange(1),nvalid)
     IF nvalid EQ 0 THEN BEGIN
        handle_value,info.value,value,/set,/no_copy
        IF !D.name NE 'PS' THEN BEGIN
           wset,info.int.tv
           erase
        END
        RETURN
     END
     
     
     ;; Xticks are special
     IF info.ext.xticks LT 0 THEN BEGIN
        xtickv = tick_vec(-info.ext.xticks, $
                          xrange(0),xrange(1), $
                          subticks=xminor)
        !x.ticks = N_ELEMENTS(xtickv)-1
        !X.tickv = xtickv
        !X.minor = xminor
     END ELSE IF info.ext.xticks GT 0 THEN BEGIN
        xticks = info.ext.xticks
        !X.ticks = info.ext.xticks
     END
     
     !X.style = 1 OR !X.style
     
     !Y.style = 1 OR !Y.style
     
     IF NOT e.ytype AND info.ext.xplotscale EQ -1 THEN !y.style = 2 OR !y.style
     
     ;; Plotting
     ;;
     CASE e.xtype*2 + e.ytype OF 
        0: plot,value(goodix,0),value(goodix,1),position=position,/DEVICE
        1: plot_io,value(goodix,0),value(goodix,1),position=position,/DEVICE
        2: plot_oi,value(goodix,0),value(goodix,1),position=position,/DEVICE
        3: plot_oo,value(goodix,0),value(goodix,1),position=position,/DEVICE
        ELSE:plot,value(goodix,0),value(goodix,1),position=position,/DEVICE
     END
        
     ;; Store coordinate system etc.
     ;;
     OLD_P.clip = !P.clip
     OLD_P.position = !P.position
     
     OLD_X.window = !X.window
     OLD_X.type = !X.type
     OLD_X.crange = !X.crange
     OLD_X.s = !X.s
     
     OLD_Y.window = !Y.window
     OLD_Y.type = !Y.type
     OLD_Y.crange = !Y.crange
     OLD_Y.s = !Y.s
     
     !P = OLD_P
     !X = OLD_X
     !Y = OLD_Y
     
     dummy = pstore(1,nvalid,1,/clean)
     
     IF !D.name NE 'PS' THEN info.int.preg = dummy
     
     info.ext.replot_focus = 1
  END ELSE BEGIN
     dummy = info.int.preg ;; Replot FOCUS?
  END

  prestore,dummy
  
  ;; Plot focus point
  ;;
  xx = pconvert(dummy,info.ext.xfocus,$
                /data,/to_device)
  yy = pconvert(dummy,info.ext.yfocus,$
                /data,/to_device,/Y)
  
  IF info.ext.replot_focus AND info.ext.focus_size NE 0.0 THEN BEGIN
     focus_size = info.ext.focus_size
     IF !D.name NE 'PS' THEN BEGIN
        DEVICE,get_graphics_function=oldgraph
        DEVICE,set_graphics_function=info.ext.focus_graph
     END ELSE BEGIN
        ;; Expand focus /DEVICE size corresponding to the change
        ;; in device clip size for POSTSCRIPT output
        focus_size = focus_size* $
           MIN([(!P.clip(2)-!P.clip(0))/FLOAT(info.int.dsize(0)), $
                (!P.clip(3)-!P.clip(1))/FLOAT(info.int.dsize(1))])
     END
     color = info.ext.focus_color
     IF color EQ -1L THEN color = info.ext.color
     IF color EQ -1L THEN color = !P.color
     IF info.ext.focus_type eq 0 THEN BEGIN
        PLOTS,[xx,xx],yy+focus_size*[-1,1],/DEVICE,color=color
        PLOTS,xx+focus_size*[-1,1],[yy,yy],/DEVICE,color=color
     END ELSE BEGIN
        PLOTS,[xx],[yy],psym=info.ext.focus_type,/DEVICE,color=color,$
           symsize=info.ext.focus_size
     END
     
     IF !D.name NE 'PS' THEN BEGIN
        DEVICE,set_graphics_function=oldgraph
     END
  END
  
  handle_value,info.value,value,/set,/no_copy
  info.ext.replot = 0
  info.ext.replot_focus = 0
  
  ;; KEEP !X, !Y, !P
  !x = OLD_X
  !Y = OLD_Y
  !P = OLD_P
END


;; Get info structure and free the data handle
;;
PRO cw_plotz_clean,id
  WIDGET_CONTROL,id,get_uvalue=info,/no_copy
  IF datatype(info) EQ 'STC' THEN handle_free,info.value
END


;; Setting the compound widget value.
;;
PRO cw_plotz_setv,ID,VALUE
  
  store = WIDGET_INFO(id,/child)
  WIDGET_CONTROL,store,get_uvalue=info,/no_copy
  
  IF datatype(value) NE 'STC' THEN BEGIN
     ;; Get old value
     handle_value,info.value,oldvalue,/no_copy
     ;;
     ;; Check the new value we got, turn fltarr(n) into fltarr(n,2)
     ;;
     IF total((SIZE(value))(0) EQ [1,2]) EQ 0 THEN  $
        MESSAGE,"CW_PLOTZ value must be a one- or two-dimensional array"
     
     IF (SIZE(value))(0) EQ 1 THEN $
        ivalue = [[DINDGEN(N_ELEMENTS(value))],[value]] $
     ELSE $
        ivalue = value
     
     IF (SIZE(ivalue))(2) NE 2 THEN $
        MESSAGE,"CW_PLOTZ needs an array of the form (N,2)"
     
     HANDLE_VALUE,info.value,ivalue,/set
     
     NP = (SIZE(ivalue))(1)
     
     IF info.ext.focusi EQ -1 THEN BEGIN
        info.ext.focusi = NP/2
     END
     
     ;; Keeping focusi within the bounds
     
     info.ext.focusi = (info.ext.focusi > 0) < (NP-1)
     
     ;; Keeping FOCUSX/Y on the right spot.
     
     IF info.ext.cling THEN BEGIN
        info.ext.xfocus = ivalue(info.ext.focusi,0)
        info.ext.yfocus = ivalue(info.ext.focusi,1)
     END
     
     info.ext.replot = 1
  END ELSE BEGIN
     ext = info.ext
     ;;
     ;; Copy values from the supplied structure.
     ;; 
     copy_tag_values,ext,value
     info.ext = ext
     tags = tag_names(value)
     ;;
     ;; Keep focusx/y on the right spot
     ;; 
     IF total(tags EQ "FOCUSI") NE 0 AND info.ext.cling THEN BEGIN
        handle_value,info.value,val,/no_copy
        IF value.focusi LT (size(val))(1) THEN BEGIN
           info.ext.xfocus = val(value.focusi,0)
           info.ext.yfocus = val(value.focusi,1)
        END ELSE BEGIN
           IF info.ext.replot GT 0 OR info.ext.replot_focus GT 0 THEN $
              message,"Cannot replot with FOCUSI out of bounds"
        END
        handle_value,info.value,val,/no_copy,/set
     END
  END
  ;;
  ;; Replot if necessary
  ;; 
  IF info.ext.replot GT 0 OR info.ext.replot_focus GT 0 THEN  $
     cw_plotz_plot,info
  WIDGET_CONTROL,store,set_uvalue=info,/no_copy
END


;
; Return some useful values
;
FUNCTION cw_plotz_getv,ID
  
  store = WIDGET_INFO(id,/child)
  WIDGET_CONTROL,store,get_uvalue=info,/no_copy
  
  value = {CW_PLOTZ_VALUE,$
           VALUE  : info.value,$
           XFOCUS : info.ext.xfocus,$
           YFOCUS : info.ext.yfocus,$
           FOCUSI : info.ext.focusi,$
           PLOTREG: info.int.preg}
  
  WIDGET_CONTROL,store,set_uvalue=info,/no_copy
  
  RETURN,value
END
  

;
; EVENT handling.
;
FUNCTION cw_plotz_event,ev
  ;;
  ;; Default place to find the info structure
  ;; 
  STORAGE = EV.ID
  WIDGET_CONTROL,STORAGE,get_uvalue=info,/no_copy
  handle_value,info.value,value,/no_copy
  
  ;; Handy values
  min_abscissa = MIN(value(*,0))
  max_abscissa = MAX(value(*,0))
  min_ordinate = MIN(value(*,1))
  max_ordinate = MAX(value(*,1))
  
  evtype = tag_names(ev,/structure_name)
  
  IF evtype EQ "XPLOTSCALE_EVENT" THEN BEGIN
     xpix = info.ext.xfocus
     zoom = info.ext.zoom
     GOTO,make_event
  END
  
  Npoints = N_ELEMENTS(value(*,0))

  IF info.int.cw_mouse NE -1 THEN BEGIN
     action = cw_tmouse(info.int.cw_mouse,ev)
  END ELSE $
     CASE ev.press OF 
     1: action = 'ZOOM-'
     2: action = 'ZOOMP'
     4: action = 'ZOOM+'
     ELSE: action = ''
  END
  
  ;;
  ;; Current values:
  ;; 
  xpix = info.ext.xfocus
  ypix = info.ext.yfocus
  zoom = info.ext.zoom
  
  ;;
  ;; Default reaction
  ;; 
  
  evnt = 0
  auto = 0
  
  ;;
  ;; If the action is on the ignore_action list we should (guess what)
  ;; ignore it.
  ;;
  IF STRPOS(info.ext.ignore_action,'('+action+')') GT -1 THEN GOTO,NO_EVENT
  
  CASE action OF 
     
     'ZOOM-': BEGIN
        IF zoom EQ info.ext.minzoom THEN GOTO,NO_EVENT
        zoom = (zoom/2) > info.ext.minzoom
        IF zoom GE 1 THEN zoom = round(zoom)
     END
     
     'ZOOM+': BEGIN
        maxzoom = info.ext.maxzoom
        IF zoom EQ maxzoom THEN GOTO,NO_EVENT
        IF maxzoom EQ 0 THEN maxzoom = zoom*2
        zoom = (zoom*2) < maxzoom 
        IF zoom GE 1 THEN zoom = round(zoom)
     END
     
     ELSE: BEGIN
        preg = pfind(ev,found)
        IF NOT found THEN BEGIN
           prestore,info.int.preg
           xp = info.ext.focusi
           IF ev.x LT !P.clip(0) THEN xp = xp - 1
           IF ev.x GT !P.clip(2) THEN xp = xp + 1
           xp = (xp > 0) < (Npoints-1)
           xpix = value(xp,0)
        END ELSE BEGIN
           xpix = pconvert(preg,ev.x,/dev,/to_data)
           ypix = pconvert(preg,ev.y,/dev,/to_data,/Y)
        END
     END
     
  ENDCASE 
  
  
MAKE_EVENT:
  
  ;;
  ;; Find nearest point
  ;; 
  x2 = (xpix-value(*,0))^2
  nearest = (WHERE(x2 EQ MIN(x2)))(0)
  
  ;;
  ;; Make focusx/y stick to the plot if cling is set.
  ;;
  IF info.ext.cling THEN BEGIN
     ypix = value(nearest,1)
     xpix = value(nearest,0)
  END
  
  preg = info.int.preg
  set = {CW_PLOTZ_SET,$
         XFOCUS : xpix,$
         YFOCUS : ypix,$
         FOCUSI : nearest,$
         ZOOM   : FLOAT(zoom),$
         REPLOT : 1}
  
  old = {CW_PLOTZ_SET,$
         XFOCUS : info.ext.xfocus,$
         YFOCUS : info.ext.yfocus,$
         FOCUSI : info.ext.focusi,$
         ZOOM   : info.ext.zoom,$
         REPLOT : 0}
  

  evnt = { $ ; CW_PLOTZ_EVENT
           ID:ev.handler,$
           TOP:ev.top,$
           HANDLER:0L,$
           SET : set,$
           OLD : old,$
           PLOTREG:PREG,$
           EVENT:EV}
  
  IF evtype EQ "XPLOTSCALE_EVENT" THEN $
     evnt = create_struct(evnt,name='CW_PLOTZ_XPLOTSCALE') $
  ELSE evnt = create_struct(evnt,name='CW_PLOTZ_EVENT')
  
  evnt.set.xfocus = (evnt.set.xfocus > min_abscissa) < max_abscissa
  evnt.set.yfocus = (evnt.set.yfocus > min_ordinate) < max_ordinate
  
  auto = info.int.auto
  
NO_EVENT:
  
  ;; NO replotting so far.
  
  handle_value,info.value,value,/set,/no_copy
  WIDGET_CONTROL,STORAGE,set_uvalue=info,/no_copy

  IF auto AND datatype(evnt) EQ 'STC' THEN BEGIN
     WIDGET_CONTROL,ev.handler,set_value=evnt.set
     RETURN,0
  END
  
  RETURN,evnt
END


;; This routine is called once, upon realization of the widget
;; If we have some data, plot it. If  not, make som dummy data.

PRO cw_plotz_realize,ID
  
  STORAGE = WIDGET_INFO(ID,/CHILD) 
  WIDGET_CONTROL,STORAGE,get_uvalue = info,/no_copy
  
  WIDGET_CONTROL,info.int.draw,get_value = tv
  info.int.tv = tv
  handle_value,info.value,value,/no_copy
  
  IF N_ELEMENTS(value) EQ 0 OR (SIZE(VALUE))(0) NE 2 OR $
     datatype(value) EQ 'COM' OR datatype(value) EQ 'STC' THEN BEGIN
     value = [ [0,1],$
               [0,1]]
  END
  
  WIDGET_CONTROL,storage,set_uvalue=info,/no_copy
  
  ;; Force a redisplay
  WIDGET_CONTROL,id,set_value = value
END


;; 50 keywords...!

FUNCTION cw_plotz,on_base,  $
                  value=value, $
                  xwsize=xwsize, ywsize=ywsize,$
                  xdsize=xdsize, ydsize=ydsize, origo=origo,$
                  uvalue=uvalue, no_copy=no_copy, $
                  cw_mouse=cw_mouse,motion_events=motion_events,$
                  $
                  $;; PLOT  keywords:                
                  $
                  background=background, charsize=charsize, $
                  xcharsize=xcharsize, ycharsize=ycharsize, $
                  charthick=charthick, color=color, font=font, $
                  xgridstyle=xgridstyle, ygridstyle=ygridstyle, $ 
                  linestyle=linestyle, psym=psym, $
                  xstyle=xstyle, ystyle=ystyle, subtitle=subtitle, $
                  symsize=symsize, thick=thick,xthick=xthick,ythick=ythick, $
                  xtickformat=xtickformat, ytickformat=ytickformat, $
                  xticks=xticks, yticks=yticks, ticklen=ticklen,  $
                  xticklen=xticklen, yticklen=yticklen, title=title, $
                  xtitle=xtitle, ytitle=ytitle, $
                  xtype=xtype, ytype=ytype,$
                  $
                  xplotscale=xplotscale,$
                  $
                  $;; Missing values
                  $
                  missing=missing,$
                  $
                  $;; Limitations
                  $
                  maxzoom=maxzoom,minzoom=minzoom,$
                  $
                  $;; Focus Symbol
                  $
                  focus_size=focus_size,focus_color=focus_color, $
                  focus_graph=focus_graph,focus_type=focus_type,$
                  $
                  $;; Miscellaneous
                  $
                  autonomous=autonomous,  $
                  ignore_action=ignore_action, $
                  focusi=focusi,zoom=zoom
  
;+  
;
; KEYWORD DEFAULTS/EXPLANATIONS
;
; All keywords not marked with * may be altered after widget creation
; through the
;   WIDGET_CONTROL,CW_ID,SET_VALUE={<KEYWORD_NAME>:<keyword_value>}
; mechanism.
  
; Widgety things
  
  default,xwsize,200            ;* Widget_draw xsize
  default,ywsize,200            ;* Widget_draw ysize
  default,xdsize,xwsize-60      ;* Display area xsize
  default,ydsize,ywsize-60      ;* Display area ysize
  default,origo,[50,40]         ; Origin of display area (pixels)
  default,uvalue,'CW_PLOTZ'
  default,no_copy,0             ;* For setting uvalue of this Compound widget
  default,CW_MOUSE,-1L          ;* Compound widget mouse control box. 
  default,motion_events,0       ;* Make the WIDGET_DRAW return motion events
  
;
; Standard PLOT keywords
;
  blank = STRING(255b)
  
  default,background,-1L        ; Use !P.background
  default,charsize,-1.0         ; Use !P.charsize
  default,xcharsize,-1.0        ; Use !X.charsize
  default,ycharsize,-1.0        ; Use !Y.charsize
  default,charthick,-1.0        ; Use !P.charthick
  default,color,-1L             ; Use !P.color
  default,font,-2L              ; Use !P.font
  default,xgridstyle,-1L        ; Use !X.gridstyle
  default,ygridstyle,-1L        ; Use !Y.gridstyle
  default,linestyle,-1L         ; Use !P.linestyle
  default,psym,-10L             ; Use !P.psym
  default,xstyle,-1L            ; Use !X.style
  default,ystyle,-1L            ; Use !Y.style
  default,subtitle,blank        ; Use !P.subtitle
  default,symsize,-1.0          ; Use !P.symsize
  default,thick,-1.0            ; Use !P.thick
  default,xthick,-1.0           ; Use !X.thick
  default,ythick,-1.0           ; Use !Y.thick
  default,xtickformat,blank     ; Use !X.tickformat
  default,ytickformat,blank     ; Use !Y.tickformat
  default,xticks,0              ; Use !X.ticks
  default,yticks,0              ; Use !Y.ticks
  default,ticklen,0.0           ; Use !P.ticklen
  default,xticklen,0.0          ; Use !X.ticklen
  default,yticklen,0.0          ; Use !Y.ticklen
  default,title,blank           ; Use !P.title
  default,xtitle,blank          ; Use !X.title
  default,ytitle,blank          ; Use !Y.title
  default,xtype,0               ; Linear (1 = logarithmic x axis)
  default,ytype,0               ; Linear (1 = logarithmic y axis)

  
; Missing value
  default,missing,-1.0D         ; Missing value, not plotted.
  default,xplotscale,-1L        ; Plot range scaler
  
; Limitations
  default,maxzoom,0             ; Max. zoom, 0 means the sensible limit.
  default,minzoom,0.5           ; Min. zoom -how much overwiew could you want!
  
; Focus Symbol
  default,focus_type,2          ; Focus Symbol psym, 0 means crosshair
  default,focus_size,1.0        ; Focus Symbol symsize/pixelsize of crosshair
  default,focus_color,-1L       ; Focus Symbol color
  default,focus_graph,3         ; Focus Symbol graphics function
  default,cling,1               ; Make focus symbol cling to the plot

; Miscellaneous
  default,autonomous,0          ;* Auto-redisplay.
  default,focusi,-1             ; Replace with N_ELEMENTS(value(*,0))/2
                                ; at first opportunity
  default,zoom,1.0
  
  
; Ignore these ACTIONs:
  default,ignore_action,'()(MOTION)(RELEASE1)(RELEASE2)(RELEASE3)'
  
;-
  
;;
;; Once more: Check variable types
;;
  keyword = 0
  scalar = 0
  real = typ(/rea)
  natural = typ(/nat)
  strng = typ(/str)
  lng = typ(/lon)
  
; Widgety things
  parcheck,xwsize,       keyword, real,   scalar,'XWSIZE'
  parcheck,ywsize,       keyword, real,   scalar,'YWSIZE'
  parcheck,xdsize,       keyword, real,   scalar,'XDSIZE'
  parcheck,ydsize,       keyword, real,   scalar,'YDSIZE'
  parcheck,origo,        keyword, natural,     1,'ORIGO'
  no_copy = KEYWORD_SET(no_copy)
  parcheck,cw_mouse,     keyword, lng,    scalar,'CW_MOUSE'
  motion_events = KEYWORD_SET(motion_events)
  
; PLOT keywords:  
  parcheck,background,   keyword, natural,scalar,'BACKGROUND'
  parcheck,charsize,     keyword, real,   scalar,'CHARSIZE'
  parcheck,xcharsize,    keyword, real,   scalar,'XCHARSIZE'
  parcheck,ycharsize,    keyword, real,   scalar,'YCHARSIZE'
  parcheck,charthick,    keyword, real,   scalar,'CHARTHICK'
  parcheck,color,        keyword, natural,scalar,'COLOR'
  parcheck,font,         keyword, natural,scalar,'FONT'
  parcheck,xgridstyle,   keyword, natural,scalar,'XGRIDSTYLE'
  parcheck,ygridstyle,   keyword, natural,scalar,'YGRIDSTYLE'
  parcheck,linestyle,    keyword, natural,scalar,'LINESTYLE'
  parcheck,psym,         keyword, natural,scalar,'PSYM'
  parcheck,xstyle,       keyword, natural,scalar,'XSTYLE'
  parcheck,ystyle,       keyword, natural,scalar,'YSTYLE'
  parcheck,subtitle,     keyword, strng,  scalar,'SUBTITLE'
  parcheck,symsize,      keyword, real,   scalar,'SYMSIZE'
  parcheck,thick,        keyword, real,   scalar,'THICK'
  parcheck,xthick,       keyword, real,   scalar,'XTHICK'
  parcheck,ythick,       keyword, real,   scalar,'YTHICK'
  parcheck,xtickformat,  keyword, strng,  scalar,'XTICKFORMAT'
  parcheck,ytickformat,  keyword, strng,  scalar,'YTICKFORMAT'
  parcheck,xticks,       keyword, natural,scalar,'XTICKS'
  parcheck,yticks,       keyword, natural,scalar,'YTICKS'
  parcheck,ticklen,      keyword, real,   scalar,'TICKLEN'
  parcheck,xticklen,     keyword, real,   scalar,'XTICKLEN'
  parcheck,yticklen,     keyword, real,   scalar,'YTICKLEN'
  parcheck,title,        keyword, strng,  scalar,'TITLE'
  parcheck,xtitle,       keyword, strng,  scalar,'XTITLE'
  parcheck,ytitle,       keyword, strng,  scalar,'YTITLE'
  parcheck,xtype,        keyword, natural,scalar,'XTYPE'
  parcheck,ytype,        keyword, natural,scalar,'YTYPE'
  
; Missing value
  parcheck,missing,      keyword,real,   scalar,'MISSING'
  parcheck,xplotscale,   keyword,lng,    scalar,'XPLOTSCALE'
  
; Limitations
  parcheck,maxzoom,      keyword,real,   scalar,'MAXZOOM'
  parcheck,minzoom,      keyword,real,   scalar,'MINZOOM'
  
; Focus Symbol
  parcheck,focus_type,   keyword,natural,scalar,'FOCUS_TYPE'
  parcheck,focus_size,   keyword,   real,scalar,'FOCUS_SIZE'
  parcheck,focus_color,  keyword,natural,scalar,'FOCUS_COLOR'
  parcheck,focus_graph,  keyword,natural,scalar,'FOCUS_GRAPH'
  
; Miscellaneous
  autonomous = KEYWORD_SET(autonomous)
  
  parcheck,focusi,       keyword,natural,scalar,'FOCUSI'
  parcheck,zoom,         keyword,   real,scalar,'ZOOM'
  
; Ignore actions
  parcheck,ignore_action,keyword,strng,  scalar,'IGNORE_ACTION'
  
; N_ELEMENTS check on origo
  IF N_ELEMENTS(origo) NE 2 THEN $
     MESSAGE,"Keyword ORIGO in CW_PLOTZ must have two elements"
;
; That's all!
; 
  
  wsize = [xwsize,ywsize]
  dsize = [xdsize,ydsize]
  
  base = WIDGET_BASE(on_base, space=0, xpad=0, ypad=0,$
                     uvalue=uvalue,no_copy=no_copy, $
                     event_func='cw_plotz_event', $
                     func_get_value='cw_plotz_getv', $
                     pro_set_value='cw_plotz_setv', $
                     notify_realize='cw_plotz_realize')
  
  draw = WIDGET_DRAW(base, $
                     xsize=wsize(0),ysize=wsize(1), $
                     /button_events,motion_events=motion_events,$
                     kill_notify='cw_plotz_clean')
  
  default,value,[0.,1.]
  
  IF focusi EQ -1 AND N_ELEMENTS(value) NE 0 THEN $
     focusi = N_ELEMENTS(value(*,0))/2
  
  IF (SIZE(value))(0) EQ 1 THEN BEGIN
     value = [[DINDGEN(N_ELEMENTS(value))],[VALUE]]
  END
  
  IF focusi NE -1 THEN BEGIN
     IF (SIZE(value))(0) EQ 2 THEN BEGIN
        xfocus = value(focusi,0)
        yfocus = value(focusi,1)
     END ELSE BEGIN
        xfocus = FLOAT(focusi)
        yfocus = value(focusi)
     END
  END
  
  ;; External values
  ;; These can be set by the user "on the fly"
  
  ext = $
     { $ ;; cw_plotz_disp,$
       origo   : origo,$        ; Origin of viewing area
       $
       $;; PLOT keywords:
       $
       background       : LONG(BACKGROUND), $
       charsize         : FLOAT(CHARSIZE), $
       xcharsize        : FLOAT(XCHARSIZE), $
       ycharsize        : FLOAT(YCHARSIZE), $
       charthick        : FLOAT(CHARTHICK), $
       color            : LONG(COLOR), $
       font             : LONG(FONT), $
       xgridstyle       : LONG(XGRIDSTYLE), $
       ygridstyle       : LONG(YGRIDSTYLE), $
       linestyle        : LONG(LINESTYLE), $
       psym             : LONG(PSYM), $
       xstyle           : LONG(XSTYLE), $
       ystyle           : LONG(YSTYLE), $
       subtitle         : SUBTITLE, $
       symsize          : FLOAT(SYMSIZE), $
       thick            : FLOAT(THICK), $
       xthick           : FLOAT(XTHICK), $
       ythick           : FLOAT(YTHICK), $
       xtickformat      : XTICKFORMAT, $
       ytickformat      : YTICKFORMAT, $
       xticks           : LONG(XTICKS), $
       yticks           : LONG(YTICKS), $
       ticklen          : FLOAT(TICKLEN), $
       xticklen         : FLOAT(XTICKLEN), $
       yticklen         : FLOAT(YTICKLEN), $
       title            : TITLE, $
       xtitle           : XTITLE, $
       ytitle           : YTITLE, $
       Xtype            : XTYPE, $
       ytype            : YTYPE, $
       $
       $;; Missing
       $
       missing : missing, $
       xplotscale : xplotscale, $ 
       $
       $;; Limitations
       $
       maxzoom : FLOAT(maxzoom),$
       minzoom : FLOAT(minzoom),$
       $
       $;; Focus Symbol
       $
       focus_type  : FIX(focus_type),$
       focus_size  : FLOAT(focus_size),$
       focus_color : focus_color,$
       focus_graph : focus_graph,$
       cling       : cling, $ ; Cling to the plotted line?
       $
       $;; Miscellaneous 
       $
       ignore_action  : ignore_action, $ ; What kind of actions to ignore
       $
       $;; State/action variables
       $
       XFOCUS  : FLOAT(xfocus),$ ; Cannot be set by keyword values.
       YFOCUS  : FLOAT(yfocus),$ ; 
       FOCUSI  : focusi,$
       zoom    : zoom,$         ;
       REPLOT  : 0,$            ;
       REPLOT_FOCUS : 0 $       ; 
     }
  
  ;; Internal values
  ;; These are fixed for the lifetime of the compound widget
  int = $
     { $ ;; cw_plotz_int,$
       WSIZE  : wsize,$         ; Window size (total)
       DSIZE  : dsize,$         ; Display size (size of viewing area).
       auto   : autonomous,$    ; Block events?
       DRAW   : draw,$
       preg   : 0L,$
       CW_MOUSE : CW_MOUSE,$
       tv     : -1L}
  
  info = $
     { $ ;;cw_plotz_info,$
       value : handle_create(),$
       ext  : ext,$
       int: int}
  
  IF N_ELEMENTS(value) GT 0 THEN handle_value,info.value,value,/set
  
  WIDGET_CONTROL,draw,set_uvalue=info,/no_copy
  
  IF xplotscale NE -1 THEN dummy = xplotscale(xplotscale,signal=draw)
  RETURN,base
END


; Test program
;-----------------
;PRO tplotz_event,ev
  
;  COMMON TPLOTZ_EVENT_PRINTSET,setup
  
;  WIDGET_CONTROL,ev.id,get_uvalue=uvalue
  
;  CASE uvalue OF 
     
;  'QUIT' :BEGIN
;     WIDGET_CONTROL,ev.top,/destroy
;     ENDCASE
     
;  'PRINT':BEGIN
;     IF datatype(setup) NE 'STC' THEN BEGIN
;        xps_setup,setup,/initial
;        setup.printer = getenv("PSLASER")
;        IF setup.printer EQ '' THEN setup.printer = getenv("PSCOLOR")
;        IF setup.printer EQ '' THEN setup.printer = getenv("PRINTER")
;        IF setup.printer EQ '' THEN setup.printer = 'lp0'
;        setup.hard = 0
;     END
;     xps_setup,setup,status=status,group=ev.top
;     IF NOT status THEN RETURN
     
     
;     ps,setup.filename,encapsulated=setup.encapsulated, $
;        portrait=setup.portrait,color=setup.color, $
;        copy=setup.copy,interpolate=setup.interpolate
     
;     multi = !P.multi 
;     !P.multi = [0,1,2]
;     plot,FINDGEN(10),/nodata,xstyle=4,ystyle=4 ;; Fixes CLIP
     
;     WIDGET_CONTROL,ev.top,get_uvalue=cw_id
;     WIDGET_CONTROL,CW_ID,set_value={replot:1}
;     IF setup.hard THEN BEGIN
;        psplot,delete=setup.delete,queue=setup.printer,color=setup.color
;     END ELSE BEGIN
;        psclose
;     END
;     !P.multi = multi
;     cleanplot
;     ENDCASE
     
;  END
  

;END


;PRO Tplotz

;  base = WIDGET_BASE(/column)
  
;  quit = WIDGET_BUTTON(base,value='Quit',uvalue='QUIT')
;  prnt = WIDGET_BUTTON(base,value='Print',uvalue='PRINT')
  
;  x = FINDGEN(1000)
;  y = sin((x/10))
  
;  cw_id = cw_plotz(base,uvalue='PLOTZ',value=[[x],[y]],/autonomous,$
;                   psym = 10,xticks=-5,xwsize=500,ywsize=200)
  
;  WIDGET_CONTROL,base,/realize
;  WIDGET_CONTROL,base,set_uvalue=cw_id
  
;  XMANAGER,'tplotz',base,/modal
  
;END


