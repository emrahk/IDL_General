PRO  cafe_plot, env,                               $
                top,bottom,                        $
                quiet=quiet,                       $
                noerase=noerase,                   $
                help=help,shorthelp=shorthelp
;+
; NAME:
;           plot
;
; PURPOSE:
;           plots data/model of fit
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           plot, [,top][,bottom|panelnum][,/quiet][,/noerase]
;
; INPUTS:
;           top      - (optional) Defines the plot type to draw in the upper
;                      part of the plot window. 
;           bottom   - (optional) Defines the plot type to draw in the lower
;                      part of the plot window.
;
;           panelnum - If instead of bottom a integer number is given
;                      the panel with this number is set (starting
;                      from 0).           
;
; PLOT TYPES:
;           The plots to be inserted in the top/bottom
;                      panels are defined with plot types defining
;                      what to plot. There are some plot types
;                      available (and could be extended just as in
;                      case of fit models).
;                      
;                      Syntax:
;                               [+|-]<plot type>["[parameter]"][:group]...
;                               ...[+<plot type>["[parameter]"][:group]]
;                      With:
;                           - add/remove:If the plot type is prepended
;                                        with "+" the new plot types
;                                        are added to the current
;                                        ones.
;
;                                        If the plot type is prepended
;                                        with "-" this plot type is
;                                        removed. For this case
;                                        wildcards are allowed to
;                                        remove more than one plot
;                                        type.
;                                        Example:
;                                        > plot,data+model
;                                        > plot,-mod*
;                                        -> remove the model plot type. 
;                                        
;                           - plot type: defining what to plot (refer below)
;                           
;                           - parameter: defining special options to
;                                        be passed to the plot type
;                                        driver. These are usually
;                                        those accepted by the IDL
;                                        oplot command, e.g. linestyle.
;                                        The format is:
;                                        keyword=value. It is possible
;                                        to define several such
;                                        parameters which must be
;                                        separated by ";".
;                                        If the assignment "=value" is
;                                        not given the value =1 will
;                                        be used (setting flags).
;                                        Example:
;                                          plot, data[linestyle=3;psym=-4;noerror]
;                                        Remark: Options set with
;                                        setplot override these parameters.
;                                        
;                            - group:    Defines for the plot type
;                                        which data group to use. This
;                                        allows to plot several groups
;                                        in a single plot window. 
;                               
;                      Examples:
;                               > plot, data+model...
;                                 -> Draw data and model in the same
;                                    panel.
;                                  
;                               > plot, data:2+data:3
;                                 -> Draw data from group 2,3 to panel.
;
;                               > plot, data[linestyle=3;psym=-3]+model
;                                 -> Draw data plus underlying model,
;                                    which is formated with different symbol/linestyle.
;                                    
;                      Description:         
;                      The "+" adds several plot types in the same
;                      panel. In this case each will be drawn in a
;                      different color (refer also to the plot types
;                      itself).
;                      The optional ":<group>" defines the group for
;                      the specific plot type to look data/model for.
;                      
;                      Common plot types are
;                            "data" - draw the data as is
;                            "model"- draw the computed model with
;                                     current parameters
;                             "res" - Residuum between data/model
;                             "delchi" - Same but in units of 1 sigma
;                             
;                      Available plot types can be listed with the
;                      command
;                               help,plot,all
;                               
;                      while a specific plot type can be shown with
;                      the command
;                               help,plot,<plot type>.
;                            
;
; OPTIONS:
;           /quiet    - Do not print plot informations. 
;           /noeraase - Do not delete window (useful for plotting as
;                       a client procedure)
;
; SETPLOT KEYWORDS:
;                      Plotting may be influenced by some general plot
;                      parameters set with the setplot command. For all
;                      plot styles following setplot identifier will be
;                      applicable (and must be defined for plot panel 0): 
;             weight  - A integer number which defines how  the
;                       height should be distributed among different
;                       panels. For this all weights are summed up;
;                       and each panel gets a share according its
;                       weight from the total sum. For example with
;                       top panel of weight 2 and bottom panel of
;                       weight 1 will set 2/3 of the available height
;                       at top panel and 1/3 at bottom panel (this is
;                       the default). 
;             topsep  - Floating number between 0..1 defining margin
;                       of plot to top (either frame or plot above).
;                       This must include sufficient place for
;                       title/subtitle text.
;                       Default is 0.05.
;          bottomsep  - Floating number between 0..1 defining margin
;                       of plot to bottom (either frame or plot below).
;                       This must include sufficient space for x-axis
;                       text/sub-text. 
;                       Default is 0.1.                       
;            rmargin  - Floating number between 0..1 defining margin
;                       of plot to right side.
;                       This must include sufficient space for right y-axis
;                       text (if any). 
;                       Default is 0.05.                       
;            lmargin  - Floating number between 0..1 defining margin
;                       of plot to left side.
;                       This must include sufficient space for left y-axis
;                       text/tick labels. 
;                       Default is 0.1.                       
;            xfree    - Flag (0/1). If set the x-range is computed
;                       independent for each panel (not recommended for
;                       interactive plot tools, e.g. iplot/wplot).
;                       Default is off (0).
;
;          background - The background color for all plots. This is
;                       common for all panels and can not be set
;                       separately :-<
;
;          startcolor - First color number used to plot
;                       frame/data. Must be adapted to currently used
;                       color table. Default: 255.
;
;          deltacolor - Decrease of color to apply for distinct plot
;                       types/data sets. Default: 23.
;
;      startlinestyle - First line style used to plot frame/data. Default: 0.
;                       Must not exceed 5.
;
;      deltalinestyle - Increase of line styles for distinct plot
;                       types/data sets. May be positive or negative
;                       integer number. Default: 0 (no change).
;                       
;           startpsym - First point symbol used to plot frame/data. Default: -4.
;                       Should not exceed -7..7. If psym is negative
;                       lines are drawn, if positive, not (refer IDL
;                       PLOT command).
;                       Userdefined symbols (8) are not supported.
;
;           deltapsym - Increase of point symbols for distinct plot
;                       types/data sets. May be positive or negative
;                       integer number. Default: 0 (no change).
;
;                       If psym exceeds -7..7 during plot different
;                       plot types it will be set at 0 (no symbol). Therefore
;                       plotting all data sets with lines it is
;                       recomended to set deltapsym at a negative
;                       value (to decrease and restart from 0). 
;
;
;          zbuff      - Use the Z Buffer device for plot
;                       production. The practical use is for 3-dim
;                       plots. The Z Buffer device essentially is able
;                       to check which object (even axis lines, text
;                       or data) is behind another object and must not
;                       be drawn. This is especially usefull when:
;                        - Combining several shaded objects, possibly
;                          with surface or contour.
;                        - Generating high quality plot 3-dim plot
;                          images.
;                          
;                       The drawback is that the generated
;                       (postscript) images are pixelated, i.e. the
;                       quality depends on the resolution/image size.
;                       Also fonts are not always drawn properly.
;                       
;                       This means: If one prints zbuffer generated
;                       plots into a file she has to look
;                        - reasonable resolution (s.b.)
;                        - A proper line thickness (setplot keywords
;                          thick, xthick,ythick,zthick).
;                        - A scaleable font. System fonts usually look
;                          poor. It is recomended to use the setplot
;                          keyword font=1.
;                          
;           maxres    - Using the Z Buffer device with this keyword defines
;                       the maximal number of pixels in X
;                       direction. Default are 5000. The pixel in Y 
;                       direction are set according the plot aspect
;                       ratio. 
;
; SIDE EFFECTS:
;           Last plot ranges/plot type will be stored if no new is
;           given. 
;
; EXAMPLE:
;           > plot, data,delchi, 2
;                -> plot data and chi difference of group 2
;
; HISTORY:
;           $Id: cafe_plot.pro,v 1.17 2003/05/07 08:18:57 goehler Exp $
;-
;
; $Log: cafe_plot.pro,v $
; Revision 1.17  2003/05/07 08:18:57  goehler
; fixes:
; - addition of models simplified
; - x ranges now bound together
;
; Revision 1.16  2003/05/05 09:22:59  goehler
; changed scheme of representing pannels:
; - /add deleted
; - added possibility to set each panel via number
; - added +add/-remove facility
; - added linestyle/psym change facility for different lines
;
; Revision 1.15  2003/04/14 07:41:13  goehler
; fix: setplot parameters were separated with "," which collides within [a,b]
;      replaced with "\n"
;
; Revision 1.14  2003/04/11 07:35:38  goehler
; minor fixes: avoid separation with ";" for plot parameters
;
; Revision 1.13  2003/03/20 17:22:33  goehler
; - added z buffer setplot keyword for enhanced/deteriorated plotting.
; - added background option.
;
; Revision 1.12  2003/03/17 14:11:32  goehler
; review/documentation updated.
;
; Revision 1.11  2003/03/11 08:16:41  goehler
; - removed distinct keyword (may be set with setplot)
; - updated documentation
;
; Revision 1.10  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.9  2002/09/09 17:36:07  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="plot"

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
    cafereport,env, "plot     - plot data/fit model"
    return
  ENDIF



  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; separator for plot items (newline)
  itemsep = String(10B)

  ;; prefix for all plot types:
  PLOT_PREFIX = "cafe_plot_"


  ; define default group
  IF n_elements(group) EQ 0 THEN group = (*env).def_grp

  ;; check boundary:
  IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
      cafereport,env, "Error: invalid group number"
      return
  ENDIF

  ;; define z buffer device
  zbuff = fix(cafegetplotparam(env,"zbuff",0,0))


  ;; maximum pixel resolution; must restrict for ps devices....
  max_resolution = fix(cafegetplotparam(env,"maxres",0,5000))

  ;; ------------------------------------------------------------
  ;; RANGE SETUP
  ;; ------------------------------------------------------------


  ;; range array contains:
  ;; 0 - xmin
  ;; 1 - xmax
  ;; 2 - ymin
  ;; 3 - ymax
  ;; 4 - zmin  (for 3-d plots only)
  ;; 5 - zmax  (for 3-d plots only)
  range=dblarr(6) 
  

  range[0]=!values.d_infinity
  range[1]=-!values.d_infinity
  range[2]=!values.d_infinity
  range[3]=-!values.d_infinity
  range[4]=!values.d_infinity
  range[5]=-!values.d_infinity
  
  ;; ------------------------------------------------------------
  ;; STORE PLOT TYPES
  ;; ------------------------------------------------------------

  ;; store only when any plot type given:
  IF n_elements(top) NE 0 THEN BEGIN 

      ;; default panel number:
      panelnum = 0

      ;; check if bottom is given:
      IF (n_elements(bottom) EQ 0) THEN bottom = ""

      ;; make shure bottom is string: 
      bottom =strtrim(string(bottom))

      ;; check if top and no bottom given -> remove former plot types
      ;; (except first one)
      IF ((top NE "")    AND           $
          (bottom EQ ""))              $
        THEN (*env).plot.panels[1:*]=""

      ;; check if bottom is panel number -> no bottom expression given
      IF stregex(bottom, "^ *[0-9]+",/boolean) THEN BEGIN
          panelnum = fix(bottom)
          bottom = ""
      ENDIF 

      ;; panel number exceeding maximum
      IF panelnum GE n_elements((*env).plot.panels) THEN BEGIN 
          cafereport,env, "Error: panel number too large"
          return
      ENDIF

      ;; add/remove top panel plot types:
      IF stregex(top,"^ *\+",/boolean) THEN BEGIN 
          top = (*env).plot.panels[panelnum]+top 
      ENDIF 
      IF stregex(top,"^ *\-",/boolean) THEN BEGIN 

          expr = strmid(top,1) ; remove leading "-"

          ;; extract plot items
          plotitems = strsplit((*env).plot.panels[panelnum],"+",/extract) 

          ;; index of plot types to be kept
          index  = where(strmatch(plotitems,expr,/fold_case) EQ 0) 
          
          ; if any -> remove
          IF index[0] NE -1 THEN  top = strjoin(plotitems[index],"+") $ 
          ELSE top = ""     ; no plot type left
      ENDIF 
       
      ;; store plot panel:
      (*env).plot.panels[panelnum] = top 

      ;; increase panel number
      panelnum = panelnum + 1

      ;; store bottom type if given:
      IF bottom NE "" THEN BEGIN 

          ;; add/remove bottom panel plot types:
          IF stregex(bottom,"^ *\+",/boolean) THEN BEGIN 
              bottom = (*env).plot.panels[panelnum]+top 
          ENDIF 
          IF stregex(bottom,"^ *\-",/boolean) THEN BEGIN 

              expr = strmid(bottom,1) ; remove leading "-"

              ;; extract plot items
              plotitems = strsplit((*env).plot.panels[panelnum],"+",/extract) 

              ;; index of plot types to be kept
              index  = where(strmatch(plotitems,expr,/fold_case) EQ 0) 
          
                                ; if any -> remove
              IF index[0] NE -1 THEN  top = strjoin(plotitems[index],"+") $ 
              ELSE bottom = ""  ; no plot type left
          ENDIF 
          
          ;; store bottom plot panel:
          (*env).plot.panels[panelnum] = bottom

      ENDIF 
  ENDIF 

  ;; ------------------------------------------------------------
  ;; DEFINE WEIGHTED PLOT POSITIONS
  ;; ------------------------------------------------------------

  
  ;; positions, one for each panel:
  positions = dblarr(n_elements((*env).plot.panels),4) 
  
  ;; number of panels defined:
  validpanels=where((*env).plot.panels NE "", n_panels)

  ;; weight height according their priority
  ;; This is done by summing up the plot heights multiplied by their weight
  nominal_height = 0
  FOR i = 0, n_panels-1 DO BEGIN 
      ;; set default weight according panel number
      IF i EQ 0 THEN defweight = 2 ELSE defweight = 1

      ;; sum up panel weights:
      nominal_height=nominal_height+$
        fix(cafegetplotparam(env,"weight",validpanels[i],defweight))
  ENDFOR 

  ;; sum up margins:
  margins=0.
  FOR i = 0, n_panels-1 DO BEGIN 

      ;; default settings apply a top/bottom margin 
      IF i EQ 0 THEN firstsep = 0.05 ELSE  firstsep = 0.
      IF i EQ n_panels-1 THEN lastsep = 0.1 ELSE lastsep = 0.
      
      ;; margins = all top+bottoms:
      margins = margins                                              $
                +double(cafegetplotparam(env,"topsep",validpanels[i],firstsep))   $
                +double(cafegetplotparam(env,"bottomsep",validpanels[i],lastsep))
  ENDFOR  


  ;; correct nominal height by neglecting margins:
  nominal_height = nominal_height / (1.-margins)


  ;; increasing height:
  height = 0.

  ;; for each panel -> define panel width/height/position
  ;; while default first panel should have header, while last should
  ;; have bottom margins
  FOR i = 0, n_panels-1 DO BEGIN 

      ;; default settings apply a top/bottom margin and a higher
      ;; weight for the first panel:
      IF i EQ 0 THEN BEGIN 
          firstsep = 0.05 
          defweight = 2
      ENDIF  ELSE BEGIN 
          firstsep = 0.
          defweight = 1
      ENDELSE 
      ;; last panel default margin
      IF i EQ n_panels-1 THEN lastsep = 0.1 ELSE lastsep = 0.
      
      ;; define margins
      rmargin = double(cafegetplotparam(env,"rmargin",validpanels[i],0.05))
      lmargin = double(cafegetplotparam(env,"lmargin",validpanels[i],0.1))
      topsep  = double(cafegetplotparam(env,"topsep",validpanels[i],firstsep))
      bottomsep  = double(cafegetplotparam(env,"bottomsep",validpanels[i],lastsep))

      ;; set panel heigth according weight/number of panels:
      panel_height = double(cafegetplotparam(env,"weight",validpanels[i],defweight))$
        / nominal_height +topsep+bottomsep

      positions[validpanels[i], *] =               $
        [lmargin,                                  $ ; x_0
         1.-height-panel_height+bottomsep,         $ ; y_0
         1.-rmargin,                               $ ; x_1
         1.-topsep-height                          $ ; y_1
        ]

      ;; add height of pannel:
      height = height + panel_height
  ENDFOR  

  ;; ------------------------------------------------------------
  ;; DEFINE PLOT RANGE:
  ;; ------------------------------------------------------------

  ;; list of all ranges for each plot panel:
  ranges = make_array(6,n_elements((*env).plot.panels),$
                     value=!values.d_infinity)

  ;; plot panels if given:
  FOR i=0,n_panels-1 DO BEGIN 
      
      panel = validpanels[i]
      
      ;; set plot parameter:
      plotparam = strepex((*env).plot.plotparams[panel],itemsep, ",",/all)
      IF plotparam NE "" THEN plotparam = ","+plotparam  

      ;; reset y/z ranges (which may differ for different panels):
      range[2]=!values.d_infinity
      range[3]=-!values.d_infinity
      range[4]=!values.d_infinity
      range[5]=-!values.d_infinity
      
      ;; call plot panel function via execute to support plot
      ;; parameter string plotpar retrieved from environment
      IF NOT execute("cafeplotpanel,env,panel,"              $
                     +"group,"                               $
                     +"position=positions[panel,*], "        $
                     +"range=range,/quiet"                   $
                     +plotparam) THEN BEGIN 
          cafereport,env, !ERR_STRING ; plotting failed
          return
      ENDIF 

      ;; store range if range should be kept free:
      IF fix(cafegetplotparam(env,"xfree",panel,0)) THEN  BEGIN 
          ranges[0:1,panel] = range[0:1]
      ENDIF 

      ;; store y/z range:
      ranges[2:5,panel]  = range[2:5]
  ENDFOR 


  ;; set x range for all panels which still do not have a valid x
  ;; range:
  ind = where(NOT finite(ranges[0,*])) ;; left value
  IF ind[0] NE -1 THEN ranges[0,ind] = range[0]
  ind = where(NOT finite(ranges[1,*])) ;; right value
  IF ind[0] NE -1 THEN ranges[1,ind] = range[1]
  
  ;; store common range to display
  (*env).plot.range=range
  
  

  ;; ------------------------------------------------------------
  ;; USE ZBUFF DEVICE IF REQUESTED:
  ;; ------------------------------------------------------------

  IF keyword_set(zbuff) THEN BEGIN 

      ;; store previous device (X/Postscript)
      previous_device=!D.NAME
      
      ;; store printing settings (fore/background color etc overridden
      ;; from Z device:
      printsetup = !p

      ;; set resolution, restrict size!
      resolution=[(max_resolution < !D.X_VSIZE),!D.Y_VSIZE]

      ;; keep aspect ratio:
      resolution[1] = resolution[0] * !D.Y_VSIZE / !D.X_VSIZE

      ;; adjust character size:
      charsize=[!D.X_CH_SIZE,!D.Y_CH_SIZE]*double(resolution[0])/!D.X_VSIZE

      ;; enter z device:
      set_plot,"Z"

      ;; set resolution/character size of z buffer 
      device,set_resolution=resolution,set_character_size=charsize

      ;; restore former printing settings (tough!):
      !p = printsetup
  ENDIF 

  
  ;; ------------------------------------------------------------
  ;; CLEAR WINDOW WITH BACKGROUND COLOR
  ;; ------------------------------------------------------------

  ;; save background
  current_background = !p.background

  ;; set new background:
  !p.background = cafegetplotparam(env,"background",0,!p.background)
  
  ;; erase window:
  IF NOT keyword_set(noerase) THEN erase


  ;; ------------------------------------------------------------
  ;; PLOT PANELS
  ;; ------------------------------------------------------------

  ;; plot panels if given:
  FOR i=0,n_panels-1 DO BEGIN 

      panel = validpanels[i]

      ;; do not plot if range infinite
      IF NOT finite(max(ranges[0:3,panel])) THEN continue
      
      ;; set plot parameter:
      plotparam = strepex((*env).plot.plotparams[panel],itemsep, ",",/all)
      IF plotparam NE "" THEN plotparam = ","+plotparam  

      
      ;; call plot panel function via execute to support plot
      ;; parameter string plotpar retrieved from environment
      IF NOT execute("cafeplotpanel,env,panel,"              $
                     +"group,"                               $
                     +"position=positions[panel,*], "        $
                     +"range=ranges[*,panel]"               $
                     +plotparam) THEN                        $ 
        cafereport,env, !ERR_STRING ; plotting failed

      ;; report plot style used:
      IF NOT keyword_set(quiet) THEN $
        cafereport,env, "Plot panel "+strtrim(string(panel),2)+":", $
        (*env).plot.panels[panel]

  ENDFOR 

  ;; ------------------------------------------------------------
  ;; COPY ZBUFF TO CURRENT DEVICE IF REQUESTED:
  ;; ------------------------------------------------------------

  IF keyword_set(zbuff) THEN BEGIN 

      img = TVRD()

      ;; restore previous device (X/Postscript)
      set_plot,previous_device

      ;; draw the z buffer image:
      TV,img
  ENDIF 

  ;; restore background:
  !p.background = current_background
      
  RETURN  
END


