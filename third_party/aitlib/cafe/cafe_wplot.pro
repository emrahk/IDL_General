;+
; NAME:
;           wplot
;
; PURPOSE:
;           interactively plots data/model of fit in separate window
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           wplot [,[+/-]add_on_button+...+add_on_button]
;                 [,[+/-]add_on_slider+...+add_on_slider]
;                 [,/idle][,/copy][,/t3d]
;
; INPUT:
;           add_on_button - (optional) Defines to display a button
;                           which is not used in the default set
;                           described below. These buttons perform
;                           special actions and may be defined by
;                           users own procedure. For a template refer
;                           the default button procedure.
;
;                           A list of available add-on-buttons (and
;                           the default buttons) may be get with
;                           "help, wplot,all".
;                           Closer description will be get with
;                           "help,wplot,<button>"
;
;                           Prefixing the button expression with a "+"
;                           adds this expression to the existing
;                           button list.
;
;                           Prefixing the button expression with a "-"
;                           excludes all buttons from the list which
;                           match this expression (wildcards "*" and
;                           "?" are allowed). 
;                           
;           add_on_slider - (optional) Defines list of sliders to be
;                           allocated vertically stacked below the
;                           (add-on) buttons.
;                           Formally there is no difference between
;                           buttons and sliders (they may be used
;                           equally) but using this slot grants more
;                           freedom for the slider bars.
;
;                           Slider expressions also may be prefixed
;                           with "+" and "-" as the button
;                           expression. 
;
; OPTIONS:
;           t3d         - Support 3-dimensional display set. There is
;                         no different plotting but the mouse
;                         behaviour (selecting data points) is more
;                         3-d appropriate, and the default slider/buttons are
;                         different: 
;                         - 3 sliders to move the data object to x/y/z
;                           direction.
;                         - zoom in/out will be applied in
;                           3-dimensional manner.
;                         - 2 sliders are available to rotate the data
;                           around the x and z axis.
;
;                         In general it is safe not to use the /t3d
;                         option (displaying 2-dim data sets with /t3d
;                         may fail), but using /t3d is more convenient
;                         for 3-dimensional data sets.
;                         
;           copy        - Copy the environment (but not the data!) to
;                         be used with wplot. This is necessary if
;                         running multiple instances ("windows") of
;                         wplot (when using the /idle option),
;                         or to avoid setplot range settings being
;                         persistent.                          
;
;          idle         - Do not block the command line when wplot widget is
;                         shown. This has the effect that no wplot buttons
;                         may be used till the command "idle" is
;                         entered. On the other hand it is possible to
;                         run wplot/command line in parallel. 

;
; DESCRIPTION:
;
;               WPLOT is intended as a mean to control data selection
;               and plotting of restricted ranges. It runs in a
;               separate window and is controlled via graphical
;               buttons.
;               Before wplot could be used properly a plot style must
;               be defined with the plot command. The displayed plot image
;               may differ from the one created with the plot command
;               because:
;               - plotting is set at exact axis range (this is
;                 necessary that shift/zoom works properly) with the
;                 IDL xstyle=1 input.
;               - The selected zoom factor must fit into the 1,2,5
;                 rule (that is: the range must be a power of ten
;                 times either 1,2 or 5 so the zoomed window always
;                 has a well defined scaling factor).
;
;               The slider defines the center of the displayed
;               x-axis. It may be used for tuning/selecting the
;               displayed window part. 
;
;               With add-on buttons mentioned above additional
;               button-commands can be loaded. Last loaded buttons 
;               will be used as default if none are specified.
;
;               Data point Selection:
;               Main part of wplot is the possibility to select data
;               points. This is done by pressing the left mouse button
;               and drag the cursor which selects a certain
;               range. The selected range may be used for further
;               processing with add-on buttons.
;               Pressing the right mouse button will deselect a
;               range.
;
; REMARK:
;               The selection will be done for data in current
;               group only. WPLOT is intended to process a single
;               group (though it is possible to display more than one
;               group, of course). 
;
;
; BUTTONS:
;
;               Wplot defines a set of default buttons. These are (if
;               the /t3d option is not set): 
;               ZOOM IN  - narrow visible range. This will be done in
;                          steps as 10, 5, 2, 1, 0.5, 0.2, 0.1...
;               ZOOM OUT - enlarge visible range This will be done in
;                          steps as 1, 2, 5, 10, 20, 50...
;               <<       - move left 75%
;               <|       - move left 10%
;               |>       - move right 10%
;               >>       - move right 75%
;               EXIT     - leave WPLOT
; 
; MOUSE:
;           Left button click will center the plot in x-range at
;           data at mouse position. 
;
; SIDE EFFECTS:
;           Changes xrange/yrange in setplot environment domain. These
;           settings will be deleted when leaving wplot.
;           All plots will be sent into the wplot window instead of
;           the usual plot window (which will be closed when running wplot).
;
; EXAMPLE:
;
;               > plot, data+model,res
;               > wplot,seekleft+seekright
;                -> uses wplot to show data, model plus residuum. Two
;                additional buttons for selective shift are set.
;
; HISTORY:
;           $Id: cafe_wplot.pro,v 1.34 2003/05/09 14:50:09 goehler Exp $
;-
;
; $Log: cafe_wplot.pro,v $
; Revision 1.34  2003/05/09 14:50:09  goehler
;
; updated documentation in version 4.1
;
; Revision 1.33  2003/04/29 13:05:03  goehler
; added possibility to add/remove buttons/sliders
;
; Revision 1.32  2003/04/28 14:37:54  goehler
; added possibility to add full-width sliders
;
; Revision 1.31  2003/04/28 07:44:16  goehler
;  new parameter setting scheme: via quoted parameter/EXECUTE procedure
;
; Revision 1.30  2003/04/24 09:54:23  goehler
; report selection of data points. This allows recalling log files.
;
; Revision 1.29  2003/04/03 10:02:59  goehler
; do not plot when setplot is performed
;
; Revision 1.28  2003/03/18 08:47:06  goehler
; Report of Buttons used
;
; Revision 1.27  2003/03/17 14:11:38  goehler
; review/documentation updated.
;
; Revision 1.26  2003/03/05 10:41:34  goehler
; simplified widget event processing: will be performed with "idle" command.
; reason: editing features with get_kbrd() function too complex.
;
; Revision 1.25  2003/03/04 16:46:15  goehler
; bug fix: do not use y range when not finite
;
; Revision 1.24  2003/03/03 21:37:27  goehler
; added copy/block options to allow multiple instances/disable command line
;
; Revision 1.23  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.22  2003/02/21 20:48:37  goehler
; bug fix: store safely add-on button information (lost when keeprange set)
;
; Revision 1.21  2003/02/14 18:31:01  goehler
; fix of t3d-wplot bug. must use device coordinates, not normal one...
;
; Revision 1.20  2003/02/14 16:40:33  goehler
; documentized
;
; Revision 1.19  2003/02/13 17:05:07  goehler
; added 3-dim option for selection/zooming.
; still not working properly after resize
;
; Revision 1.18  2003/02/13 14:44:48  goehler
; added slider for wplot (may be added as buttons)
;
; Revision 1.17  2003/02/11 07:36:21  goehler
; typos
;
; Revision 1.16  2002/09/09 17:36:15  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


;; ------------------------------------------------------------
;; CAFE_WPLOT_EXITEVENT --- EVENT PROCEDURE WHEN EXIT BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_exitevent, ev


    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    cafe_setplot,env,"xrange=",/quiet
    cafe_setplot,env,"yrange=",/quiet
    cafe_setplot,env,"zrange=",/quiet

    ;; close application:
    widget_control, ev.top, /destroy
END 




;; ------------------------------------------------------------
;; CAFE_WPLOT_MOUSEEVENT --- EVENT PROCEDURE OF A MOUSE CLICK
;; ------------------------------------------------------------

PRO cafe_wplot_mouseevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; get window ID to draw at:
    widget_control,(*env).widgets.drawID,get_value=winID
    wset,winID


    ;; get type+position:
    event_type = ev.type
    coord = Convert_Coord(ev.x, ev.y, /Device, /To_Normal,/double)
    x = coord[0]
    y = coord[1]

    ;; define set/unset state:
    selectit = (ev.release EQ 1)


    ;; -----------------------------
    ;; EVENT: button pressed:
    IF event_type EQ 0 THEN BEGIN         

        ;; 1.)  set pixmap window:
        wset, (*env).widgets.pixID


        ;; store plot in picture:      
        ;; 2.) copy window -> pixmap
        device,copy=[0,0,(*env).widgets.xsize, (*env).widgets.ysize,0,0,winID]

        ;; using area:
        (*env).widgets.in_area = 1

        ;; save start points:
        (*env).widgets.xstart = x
        (*env).widgets.ystart = y

    ENDIF 

    ;; -----------------------------
    ;; EVENT: button released:
    IF event_type EQ 1 THEN BEGIN 

        ;; restore plot
        device,copy=[0,0,(*env).widgets.xsize, $
                         (*env).widgets.ysize,0,0,$
                     (*env).widgets.pixID]

        ;; no more using area:
        (*env).widgets.in_area = 0
        
        ;; START ACTION: 
        ;; --------------------------------------------------------
        ;; MARK SELECTED:

        ;; plot to get proper coordinate system:
        cafe_plot,env,/quiet        

        ;; select range:
        xrange = [(Convert_Coord((*env).widgets.xstart,0.D5, $
                                /Normal, /To_Data))[0],        $
                  (Convert_Coord(x,0.D5,      /Normal, /To_Data))[0] $
                 ]
        ;; check range ordered:
        IF xrange[1] LT xrange[0] THEN xrange=reverse(xrange)


        ;; use default group:
        group = (*env).def_grp 

        ;; for all values within xrange set selected tick:
        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; skip empty subgroups:
            IF NOT PTR_VALID((*env).groups[group].data[subgroup].x)  THEN CONTINUE 
            
            index = where((*(*env).groups[group].data[subgroup].x GE xrange[0]) $
                          AND (*(*env).groups[group].data[subgroup].x LE xrange[1]))
            IF index[0] NE  -1 THEN BEGIN 
              (*(*env).groups[group].data[subgroup].selected)[index] $
              = selectit

              ;; report select/unselect action:
              IF selectit THEN select_cmd = "select" ELSE select_cmd = "unselect"

              cafereport,env,select_cmd+","+ $
                string(index[0], "-",    $
                       index[n_elements(index)-1], $
                       format="(I0,A,I0)")+        $
                ","+                              $
                string(subgroup,format="(I0)")+","+$
                string(group,format="(I0)"),       $
                /nocomment
          ENDIF 



        ENDFOR 

        ;; plot final result:
        cafe_plot,env,/quiet        

        ;; END ACTION: 
        ;; --------------------------------------------------------

    ENDIF ;; mouse up event


    ;; -----------------------------
    ;; EVENT: mouse moved
    IF event_type EQ 2 THEN BEGIN 

        IF (*env).widgets.in_area THEN BEGIN 

            ;; restore plot: pixmap -> window
            device,copy=[0,0,(*env).widgets.xsize, $
                             (*env).widgets.ysize,0,0,$
                         (*env).widgets.pixID]

            ;; draw range with arrow (taken from zplot, by D. Fanning)
            x1 = (*env).widgets.xstart
            y1 = (*env).widgets.ystart
            x2 = x
            y2 = y
            
            Arrow, x1, y1, x2, y1, Color=100, /Solid, HSize=12,/normalized
            PlotS, [x1, x1], [0., 1.], Color=100,/normal
            PlotS, [x2, x2], [0., 1.], Color=100,/normal
            
        ENDIF 
    ENDIF 


    ;; -----------------------------
    ;; update label positions:
    ;; -----------------------------

    ;; define position
    mousepos=Convert_Coord(ev.x, ev.y, /Device, /To_Data)

    ;; set values:
    widget_control,(*env).widgets.xlabelID,set_value=$
      " X Pos: "+strtrim(string(mousepos[0]),2)

    widget_control,(*env).widgets.ylabelID,set_value=$
      " Y Pos: "+strtrim(string(mousepos[1]),2)
END 



;; ------------------------------------------------------------
;; CAFE_WPLOT_MOUSEEVENT3D --- EVENT PROCEDURE OF A MOUSE CLICK FOR
;;                             3-dimensional support
;; ------------------------------------------------------------

PRO cafe_wplot_mouseevent3d, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; get window ID to draw at:
    widget_control,(*env).widgets.drawID,get_value=winID
    wset,winID


    ;; get type+position:
    event_type = ev.type
    x = ev.x
    y = ev.y

    ;; define set/unset state:
    selectit = (ev.release EQ 1)


    ;; -----------------------------
    ;; EVENT: button pressed:
    IF event_type EQ 0 THEN BEGIN         

        ;; 1.)  set pixmap window:
        wset, (*env).widgets.pixID


        ;; store plot in picture:      
        ;; 2.) copy window -> pixmap
        device,copy=[0,0,(*env).widgets.xsize, (*env).widgets.ysize,0,0,winID]

        ;; using area:
        (*env).widgets.in_area = 1

        ;; save start points:
        (*env).widgets.xstart = x
        (*env).widgets.ystart = y

    ENDIF 

    ;; -----------------------------
    ;; EVENT: button released:
    IF event_type EQ 1 THEN BEGIN 

        ;; no more using area:
        (*env).widgets.in_area = 0
        
        ;; START ACTION: 
        ;; --------------------------------------------------------
        ;; MARK SELECTED:

        ;; plot to get proper coordinate system:
        cafe_plot,env,/quiet        

        ;; create x-range in device coordinates:
        xrange=[(*env).widgets.xstart,x]

        ;; check order:
        IF xrange[1] LT xrange[0] THEN xrange=reverse(xrange)


        ;; use default group:
        group = (*env).def_grp 

        ;; for allowed_trans( values within xrange set selected tick:
        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; skip empty subgroups:
            IF NOT PTR_VALID((*env).groups[group].data[subgroup].x)  THEN CONTINUE 

            ;; get coordinates of all data:
            xconv = [[*(*env).groups[group].data[subgroup].x],$
                     [*(*env).groups[group].data[subgroup].y]]

            ;; convert to device in 2-dim space via rotation:
            xconv = convert_coord(transpose(xconv),/t3d,/data,/to_device,/double)

            ;; check which data points lay within device x range:
            index = where((xconv[0,*] GE xrange[0]) $
                          AND (xconv[0,*] LE xrange[1]))

            ;; and mark as selected/unselected:
            IF index[0] NE  -1 THEN BEGIN                                       
                (*(*env).groups[group].data[subgroup].selected)[index] $
                  = selectit

                ;; report select/unselect action:
                IF selectit THEN select_cmd = "select" ELSE select_cmd = "unselect"
                
                cafereport,env,select_cmd+","+ $
                  string(index[0], "-",    $
                         index[n_elements(index)-1], $
                         format="(I0,A,I0)")+        $
                  ","+                              $
                  string(subgroup,format="(I0)")+","+$
                  string(group,format="(I0)"),       $
                  /nocomment
            ENDIF 

        ENDFOR 

        ;; plot final result:
        cafe_plot,env,/quiet        

        ;; END ACTION: 
        ;; --------------------------------------------------------

    ENDIF ;; mouse up event


    ;; -----------------------------
    ;; EVENT: mouse moved
    IF event_type EQ 2 THEN BEGIN 

        IF (*env).widgets.in_area THEN BEGIN 

            ;; restore plot: pixmap -> window
            device,copy=[0,0,(*env).widgets.xsize, $
                             (*env).widgets.ysize,0,0,$
                         (*env).widgets.pixID]

            ;; draw range with arrow (taken from zplot, by D. Fanning)
            x1 = (*env).widgets.xstart
            y1 = (*env).widgets.ystart
            x2 = x
            y2 = y
            
            Arrow, x1, y1, x2, y1, Color=100, /Solid, HSize=12

            nx=convert_coord([x1,x2],[y1,y2],/device,/to_normal)
            PlotS, [nx[0,0], nx[0,0]], [0., 1.], Color=100,/norm
            PlotS, [nx[0,1], nx[0,1]], [0., 1.], Color=100,/norm
            
        ENDIF 
    ENDIF 


    ;; -----------------------------
    ;; update label positions:
    ;; (tricky in 3d)
    ;; -----------------------------

END 



;; ------------------------------------------------------------
;; CAFE_WPLOT_RESIZEEVENT --- EVENT PROCEDURE WHEN RESIZE OCCURS
;; ------------------------------------------------------------

PRO cafe_wplot_resizeevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; update window size (with hard coded button sizes(?):
    Widget_Control, (*env).widgets.drawID,      $
      Draw_XSize=ev.x, Draw_YSize=((ev.y -160) > 160)

    (*env).widgets.xsize = ev.x
    (*env).widgets.ysize = ((ev.y -160) > 160)

    ;; redraw:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID
    cafe_plot,env,/quiet


    ;; 1.)  delete former picture
    wdelete,(*env).widgets.pixID
    
    ;; 2.) create pixmap window (with size like original):
    window, xsize=(*env).widgets.xsize, $
            ysize=(*env).widgets.ysize,/free, /pixmap    

    ;; 3.) save ID of pixmap
    (*env).widgets.pixID = !D.window

END 



;; ------------------------------------------------------------
;; CAFE_WPLOT --- MAIN PROCEDURE
;; ------------------------------------------------------------
PRO  CAFE_WPLOT, env,buttons, sliders,               $
                 copy=copy,                         $
                 idle=idle,                         $
                 t3d=t3d,                           $
                 help=help,shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot"

    ;; ------------------------------------------------------------
    ;; HELP
    ;; ------------------------------------------------------------
    ;; if help given -> print the specification above (from this file)
    IF keyword_set(help) THEN BEGIN
        cafe_help,env, name
        return
    ENDIF 


  ;; ------------------------------------------------------------
  ;; SHORT HELP
  ;; ------------------------------------------------------------
  IF keyword_set(shorthelp) THEN BEGIN  
    cafereport,env, "wplot    - interactive widget plot"
    return
  ENDIF


  ;; ------------------------------------------------------------
  ;; PRIMARY PLOT FOR RANGE SETTING
  ;; ------------------------------------------------------------


  cafe_plot,env,/quiet


  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; copy environment if needed:
  IF keyword_set(copy) THEN $
    wplot_env = ptr_new(*env) $
  ELSE                        $
    wplot_env = env

  ;; name of window:
  WINNAME="cafe_wplot"	

  ;; check: is there already an instance running:
  IF NOT keyword_set(copy) AND $
    XREGISTERED(WINNAME) GT 0 THEN BEGIN 
      cafereport,env,"Error: could not run multiple instances of wplot"
      return
  ENDIF 

  ;; translate idle keyword:
  IF keyword_set(idle) THEN BEGIN 
      no_block = 1    
      cafereport,env,'Remark: You have to enter the command "idle" to  work within the wplot window'
  ENDIF  ELSE        $
    no_block = 0
 


  ;; define prefix of button procedures:
  ADD_ON_PREFIX = "cafe_wplot_"


  ;; close default window:
  wdelete

  ;; define default x/y size of plot window (pixel)
  IF N_Elements(xsize) EQ 0 THEN xsize = 400
  IF N_Elements(ysize) EQ 0 THEN ysize = 400

  (*wplot_env).widgets.xsize = 400
  (*wplot_env).widgets.ysize = 400

  ;; 1.) create pixmap window (with size like original):
  window, xsize=(*wplot_env).widgets.xsize, $
          ysize=(*wplot_env).widgets.ysize,/free, /pixmap


  ;; 2.) save ID of pixmap
  (*wplot_env).widgets.pixID = !D.window

  
  ;; ------------------------------------------------------------
  ;; DEFINE X-RANGE
  ;; ------------------------------------------------------------


  ;; reset if undefined:
  IF NOT finite((*wplot_env).plot.xwidth) THEN (*wplot_env).plot.xwidth = 0
  IF NOT finite((*wplot_env).plot.xpos)   THEN (*wplot_env).plot.xpos = 0

  ;; initial width of displayed data. 
  IF ((*wplot_env).plot.xwidth EQ 0) THEN $
    (*wplot_env).plot.xwidth = ((*wplot_env).plot.range[1]-  $
                                (*wplot_env).plot.range[0])

  
  ;; center position of displayed data. Use mid of currently displayed
  ;; data if outside: 
  IF ((*wplot_env).plot.xpos LT (*wplot_env).plot.range[0])        $
    OR ((*wplot_env).plot.xpos GT (*wplot_env).plot.range[1]) THEN $
    (*wplot_env).plot.xpos   = ((*wplot_env).plot.range[1] +       $
                                (*wplot_env).plot.range[0])*0.5


  ;; set current range:
  xrange=[(*wplot_env).plot.xpos-(*wplot_env).plot.xwidth/2.D0, $
          (*wplot_env).plot.xpos+(*wplot_env).plot.xwidth/2.D0]

  ;; store it:
  cafe_setplot,env,"xrange=["+string(xrange[0])+","+ $
    string(xrange[1])+"]",/quiet

  ;; set exact x-axis range (stepping is easier):
  cafe_setplot,env,"xstyle=1",/quiet

  
  ;; ------------------------------------------------------------
  ;; DEFINE Y-RANGE
  ;; ------------------------------------------------------------

  IF finite(max((*wplot_env).plot.range[4:5])) THEN BEGIN 

      ;; initial width of displayed data. 
      IF (*wplot_env).plot.ywidth EQ 0 THEN $
        (*wplot_env).plot.ywidth = ( (*wplot_env).plot.range[3]-(*wplot_env).plot.range[2])

  
      ;; center position of displayed data. Use mid of currently displayed
      ;; data if outside: 
      IF ((*wplot_env).plot.ypos LT (*wplot_env).plot.range[2])        $
        OR ((*wplot_env).plot.ypos GT (*wplot_env).plot.range[3]) THEN $
        (*wplot_env).plot.ypos   = ((*wplot_env).plot.range[3] + (*wplot_env).plot.range[2])*0.5


      ;; set current range:
      yrange=[(*wplot_env).plot.ypos-(*wplot_env).plot.ywidth/2.D0, $
              (*wplot_env).plot.ypos+(*wplot_env).plot.ywidth/2.D0]

  ENDIF 

  ;; ------------------------------------------------------------
  ;; DEFINE Z-RANGE IF DEFINED
  ;; ------------------------------------------------------------

  IF finite(max((*wplot_env).plot.range[4:5])) THEN BEGIN 

      ;; initial width of displayed data. 
      IF (*wplot_env).plot.zwidth EQ 0 THEN $
        (*wplot_env).plot.zwidth = ( (*wplot_env).plot.range[5]-(*wplot_env).plot.range[4])
      
  
      ;; center position of displayed data. Use mid of currently displayed
      ;; data if outside: 
      IF ((*wplot_env).plot.zpos LT (*wplot_env).plot.range[4])        $
        OR ((*wplot_env).plot.zpos GT (*wplot_env).plot.range[5]) THEN $
        (*wplot_env).plot.zpos   = ((*wplot_env).plot.range[5] + (*wplot_env).plot.range[4])*0.5
      
      
      ;; set current range:
      zrange=[(*wplot_env).plot.zpos-(*wplot_env).plot.zwidth/2.D0, $
              (*wplot_env).plot.zpos+(*wplot_env).plot.zwidth/2.D0]      
  ENDIF 

  ;; ------------------------------------------------------------
  ;; CREATE BASE WIDGETS
  ;; ------------------------------------------------------------

  ;; allocate window:
  mainwID = widget_base(title="WPLOT",/column,/tlb_size_events)

  ;; store its ID:
  (*wplot_env).widgets.baseID = mainwID


  ;; select mouse event handler:
  IF keyword_set(t3d) THEN $
    mouseevent="cafe_wplot_mouseevent3d" $ ;; 3-dim mouse event handler
  ELSE                                   $
    mouseevent="cafe_wplot_mouseevent"     ;; standard mouse event handler

  drawID  = widget_draw(mainwID, xsize=xsize, ysize=ysize,$
                        /button_events, /motion_events, event_pro=mouseevent) 

  ;; save the draw ID -> wee need it for plotting
  (*wplot_env).widgets.drawID = drawID

  ;; ------------------------------------------------------------
  ;; CREATE X-SLIDER
  ;; ------------------------------------------------------------

  IF NOT keyword_set(t3d) THEN            $
    cafe_wplot_sliderx,env,mainwID $  ; one is sufficient for x range
  ELSE BEGIN 
      cafe_wplot_sliderx,env,mainwID  ; Three slider
      cafe_wplot_slidery,env,mainwID  ; For x, y and z
      cafe_wplot_sliderz,env,mainwID  ; 
  ENDELSE 

  ;; ------------------------------------------------------------
  ;; CREATE BUTTON BASE WIDGETS
  ;; ------------------------------------------------------------


  controlframeID  = widget_base(mainwID, /row, /align_left,frame=0)
  buttonframeID  = widget_base(controlframeID, /column, /align_left,frame=1)
  buttonbaseID  = widget_base(buttonframeID, /row, /align_left,frame=0)
  buttonaddonsID= widget_base(buttonframeID, /row, /align_left,frame=0)

  ;; label field:
  labelframeID   = widget_base(controlframeID, /column, /align_left,frame=1)


  ;; ------------------------------------------------------------
  ;; CREATE DEFAULT BUTTONS WITH THEIR FUNCTIONS:
  ;; ------------------------------------------------------------
  
  ;; 2-dim setting: default:
  IF NOT keyword_set(t3d) THEN BEGIN
      cafe_wplot_zoomin,env,buttonbaseID
      cafe_wplot_zoomout,env,buttonbaseID
      cafe_wplot_shiftleft,env,buttonbaseID
      cafe_wplot_stepleft,env,buttonbaseID
      cafe_wplot_stepright,env,buttonbaseID
      cafe_wplot_shiftright,env,buttonbaseID
  ENDIF ELSE BEGIN 
      cafe_wplot_zoomin,env,buttonbaseID,/t3d
      cafe_wplot_zoomout,env,buttonbaseID,/t3d
      cafe_wplot_sliderrotx,env,buttonbaseID  ; x axis slider
      cafe_wplot_sliderrotz,env,buttonbaseID  ; z axis slider
  ENDELSE 

  ;; here defined event procedure -> EXIT MUST EXIST:
  exitbuttonID = widget_button(buttonbaseID, value="Exit",$
                               event_pro="cafe_wplot_exitevent")

  ;; ------------------------------------------------------------
  ;; CREATE POSITION LABELS
  ;; ------------------------------------------------------------


  xlabelID   = widget_label(labelframeID, /align_left,value="X Pos:            ")
  ylabelID   = widget_label(labelframeID,/align_left,value="Y Pos:            ")


  ;; save labels:
  (*wplot_env).widgets.xlabelID = xlabelID
  (*wplot_env).widgets.ylabelID = ylabelID

  ;; ------------------------------------------------------------
  ;; CREATE ADD-ON BUTTONS
  ;; ------------------------------------------------------------

  ;; use already set buttons if not defined:
  IF n_elements(buttons) EQ 0 THEN BEGIN 
      buttons = (*wplot_env).widgets.addon_buttons
      cafereport,env,"Buttons: "+buttons
  ENDIF 


  ;; +button: add buttons to existing one:
  IF stregex(buttons,"^ *\+",/boolean) THEN BEGIN 
      buttons = (*wplot_env).widgets.addon_buttons + buttons
      cafereport,env,"Buttons: "+buttons
  ENDIF 


  ;; -button: remove buttons from existing one:
  IF stregex(buttons,"^\-",/boolean) THEN BEGIN 
      expr = strmid(buttons,1)                              ; remove leading "-"
      buttonitems = strsplit($                              ; extract button items
            (*wplot_env).widgets.addon_buttons,"+",/extract) 
      index  = where(strmatch(buttonitems,expr,/fold_case) EQ 0) ; index of buttons to be kept
      IF index[0] NE -1 THEN buttons = strjoin(buttonitems[index],"+") $ ; if any -> remove
      ELSE buttons = ""                                                  ; no button left
      cafereport,env,"Buttons: "+buttons
  ENDIF 

  ;; if add-ons desired:
  IF buttons NE "" THEN BEGIN 
      
      ;; split them into button parts:
      buttonlist=strsplit(buttons,"+",/extract)

      
      FOR button=0,n_elements(buttonlist)-1 DO BEGIN 
          ;; check that name not empty:
          IF buttonlist[button] NE "" THEN BEGIN 

              ;; extract button parameters (in brackets):
              buttonitem=stregex(buttonlist[button],$
                                     "([a-zA-Z]+)(\[(.*)\])?",/extract,/subexpr)

              param=buttonitem[3]
              buttontitle=buttonitem[1]

              IF param NE "" THEN BEGIN 
                  param= ","+cafequotestr(param)
              ENDIF 

              ;; call their init procedures:
              IF NOT execute(  ADD_ON_PREFIX+buttontitle+$
                            ",env,buttonaddonsID"+param) THEN BEGIN 
                  cafereport,env,"Error:"+!ERR_STRING ; add-on failed
              ENDIF 
          ENDIF 
      ENDFOR  
  ENDIF 
      

  ;; save it for next call:
  (*env).widgets.addon_buttons = buttons

  ;; ------------------------------------------------------------
  ;; CREATE ADD-ON SLIDERS
  ;; ------------------------------------------------------------

  IF n_elements(sliders) EQ 0 THEN BEGIN 
      sliders = (*wplot_env).widgets.addon_sliders
      cafereport,env,"Sliders: "+sliders
  ENDIF 


  ;; +sliders: add sliders to existing one:
  IF stregex(sliders,"^ *\+",/boolean) THEN BEGIN 
      sliders = (*wplot_env).widgets.addon_sliders + sliders
      cafereport,env,"Sliders: "+sliders
  ENDIF 


  ;; -slider: remove sliders from existing one:
  IF stregex(sliders,"^\-",/boolean) THEN BEGIN 
      expr = strmid(sliders,1)                              ; remove leading "-"
      slideritems = strsplit($                              ; extract slider items
            (*wplot_env).widgets.addon_sliders,"+",/extract) 
      index  = where(strmatch(slideritems,expr,/fold_case) EQ 0) ; index of sliders to be kept
      IF index[0] NE -1 THEN sliders = strjoin(slideritems[index],"+") $ ; if any -> remove
      ELSE sliders = ""                                                  ; no slider left
      cafereport,env,"Sliders: "+sliders
  ENDIF 


  ;; if add-ons desired:
  IF sliders NE "" THEN BEGIN 
      
      ;; split them into slider parts:
      sliderlist=strsplit(sliders,"+",/extract)

      
      FOR slider=0,n_elements(sliderlist)-1 DO BEGIN 
          ;; check that name not empty:
          IF sliderlist[slider] NE "" THEN BEGIN 

              ;; extract slider parameters (in brackets):
              slideritem=stregex(sliderlist[slider],$
                                     "([a-zA-Z]+)(\[(.*)\])?",/extract,/subexpr)

              param=slideritem[3]
              slidertitle=slideritem[1]

              IF param NE "" THEN BEGIN 
                  param= ","+cafequotestr(param)
              ENDIF 

              ;; call their init procedures:
              IF NOT execute(  ADD_ON_PREFIX+slidertitle+$
                            ",env,mainwID"+param) THEN BEGIN 
                  cafereport,env,"Error:"+!ERR_STRING ; add-on failed
              ENDIF 
          ENDIF 
      ENDFOR  
  ENDIF 
      

  ;; save it for next call:
  (*env).widgets.addon_sliders = sliders



  ;; ------------------------------------------------------------
  ;; PERFORM WIDGET INIT STUFF
  ;; ------------------------------------------------------------
  

  ;; make environment public:
  widget_control,mainwID, set_uvalue=wplot_env

  ;; display it:
  widget_control,mainwID,/realize

  ;; perform initial draw:
  widget_control,drawID,get_value=winId
  wset, winID
  cafe_plot,env,/quiet

  ;; save current matrix (debug only)
  (*wplot_env).plot.t3d = !p.t

  xmanager,WINNAME, mainwID, event_handler="cafe_wplot_resizeevent",$
    no_block=no_block; block if not inhibited
  
END 

