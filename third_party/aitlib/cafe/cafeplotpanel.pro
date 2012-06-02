PRO  cafeplotpanel, env,                                   $
                      panel,  group,                       $
                      position=position,                   $
                      xrange=xrange, yrange=yrange,        $ 
                      zrange=zrange,                       $
                      range=range,                         $
                      quiet=quiet,                         $
                      _EXTRA=ex
;+
; NAME:
;           cafeplotpanel
;
; PURPOSE:
;           plots data/model of fit in single panel
;
; CATEGORY:
;           cafe
; 
; SUBCATEGORY:
;           plot
;
; SYNTAX:
;           cafeplotpanel, panel ,group,position=position,/add
;
; INPUTS:
;           panel    - Defines the panel number from environment to
;                      draw in current window.
;
;           group    - Define the data group to plot.
;                      Must be in range [0..9].
;                      
;           position - 4-vector containing edge coordinates
;                      of panel to plot. Coordinates are values
;                      between 0..1.
;                      
;           xrange   - Range to plot x values between. Must be
;                      2-element vector of double, containing
;                      start/stop values of x range. 
;           yrange   - Range to plot y values between. Must be
;                      2-element vector of double, containing
;                      start/stop values of y range.
;           zrange   - Range to plot z values between. Must be
;                      2-element vector of double, containing
;                      start/stop values of z range.
;           _extra   - This will be used to pass by any valid plot
;                      keywords defined with setplot.
;                      
; OUTPUT:
;           range    - 6-dim double array. It defines best matching
;                      ranges for data/values to display. The elements
;                      are defined as follow:
;                          0 - xmin
;                          1 - xmax
;                          2 - ymin
;                          3 - ymax
;                          4 - zmin  (for 3-d plots only)
;                          5 - zmax  (for 3-d plots only)
;                      This range is necessary to export a common
;                      range for different panels (usually the x-range
;                      must be the same for stacked plots).
;                      From this range the x/y/z ranges are taken if
;                      not defined with inputs above.
;                      The elements should be preset with values
;                      [infty,-infty].
;
; PLOT TYPES:
;           The plots to be inserted in panels are defined
;           with plot types defining what to plot. There
;           are some plot types available (and could be
;           extended just as in case of fit models).  
;           Syntax:
;                 <plot type>:group...+<plot type>:group
;           Examples:
;                 > cafeplotpanel, data+model...
;                   -> Draw data and model in the same panel.
;                 > cafeplotpanel,data:2+data:3
;                   -> Draw data from group 2,3 to panel.
;                 The "+" adds several plot types in the same
;                 panel. In this case each will be drawn in a
;                 different color (refer also to the plot types
;                 itself).
;                 The optional ":<group>" defines the group for
;                 the specific plot type to look data/model for.
;                      
;                 Common plot types are
;                  "data" - draw the data as is
;                  "model"- draw the computed model with
;                            current parameters
;                   "res" - Residuum between data/model
;                "delchi" - Same but in units of 1 sigma
; OPTIONS:
;           quiet - do not plot but determine range only. 
; 
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafeplotpanel.pro,v 1.23 2003/05/07 08:18:57 goehler Exp $
;
;
; $Log: cafeplotpanel.pro,v $
; Revision 1.23  2003/05/07 08:18:57  goehler
; fixes:
; - addition of models simplified
; - x ranges now bound together
;
; Revision 1.22  2003/05/05 09:22:59  goehler
; changed scheme of representing pannels:
; - /add deleted
; - added possibility to set each panel via number
; - added +add/-remove facility
; - added linestyle/psym change facility for different lines
;
; Revision 1.21  2003/04/28 07:38:15  goehler
; moved parameter determination into separate function cafequotestr
;
; Revision 1.20  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.19  2003/02/12 12:44:42  goehler
; added proper range setting
;
; Revision 1.18  2003/02/11 17:25:59  goehler
; improved axis display
;
; Revision 1.17  2003/02/11 15:54:02  goehler
; removed debug print
;
; Revision 1.16  2003/02/11 15:03:35  goehler
; added gauss model, and method to plot models.
;
; Revision 1.15  2002/09/19 14:02:38  goehler
; documentized
;
; Revision 1.14  2002/09/10 13:24:36  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.13  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.12  2002/09/09 17:36:20  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; prefix for all plot types:
    PLOT_PREFIX = "cafe_plot_"


    ;; define first color/color increase:
    color = fix(cafegetplotparam(env,"startcolor",panel,255))
    deltacolor = fix(cafegetplotparam(env,"deltacolor",panel,23))

    ;; define first line style/line style increase:
    linestyle=fix(cafegetplotparam(env,"startlinestyle",panel,0))
    deltalinestyle=fix(cafegetplotparam(env,"deltalinestyle",panel,0))

    ;; define first point symbol/point symbol increase:
    psym=fix(cafegetplotparam(env,"startpsym",panel,-4))
    deltapsym=fix(cafegetplotparam(env,"deltapsym",panel,0))

    ;; ------------------------------------------------------------
    ;; COMPUTE PLOT TYPE LIST + GROUPS
    ;; ------------------------------------------------------------


    ;; separate different plot types:
    plotlist = strsplit((*env).plot.panels[panel],'+',/extract)

    ;; list of groups for each plot type:
    groups = intarr(n_elements(plotlist))

    ;; list of parameter for each plot type:
    plotparamlist = strarr(n_elements(plotlist))

    ;; for each plot type extract group number:
    FOR i = 0, n_elements(plotlist)-1 DO BEGIN           
      
        ;; extended syntax: plottype[group] -> extract group, if any
        plotitem=stregex(plotlist[i],'([a-zA-Z0-9]+)(\[(.*)\])?(:([0-9]*))?',$
                         /extract,/subexpr)
          
        plotlist[i] = plotitem[1] ; store plot type without group

        ;; plot group found -> extract new plot type and group number
        IF plotitem[5] NE "" THEN groups[i] = fix(plotitem[5]) $        
        ELSE groups[i] = group ;; otherwise use default group:

        ;; store plot parameter with following ',':
        IF plotitem[3] NE "" THEN BEGIN 
            plotparamlist[i] = cafequotestr(plotitem[3],/keyvalpair) + ','
        ENDIF

        ;; add color keyword, if not set already:
        IF NOT strmatch(plotparamlist[i],"*color=*",/fold_case) THEN $
          plotparamlist[i] = plotparamlist[i] + "color=color,"

        ;; add linestyle keyword, if not set already:
        IF NOT strmatch(plotparamlist[i],"*linestyle=*",/fold_case) THEN $
          plotparamlist[i] = plotparamlist[i] + "linestyle=linestyle,"

        ;; add psym keyword, if not set already:
        IF NOT strmatch(plotparamlist[i],"*psym=*",/fold_case) THEN $
          plotparamlist[i] = plotparamlist[i] + "psym=psym,"
      
    ENDFOR




    ;; ------------------------------------------------------------
    ;; DEFINE RANGES FROM PLOT TYPES
    ;; ------------------------------------------------------------


    IF keyword_set(quiet) THEN BEGIN     
        ;; plot (quiet) each type get range:
        FOR i = 0, n_elements(plotlist)-1 DO BEGIN               

            ;; get the ranges by quiet plotting:
            IF NOT execute( PLOT_PREFIX+plotlist[i]   $
                            +",env, groups[i],"       $
                            + plotparamlist[i]        $
                            +"range=range, /quiet"    $
                            +",_EXTRA=ex") THEN BEGIN 
                cafereport,env,"Error:"+!ERR_STRING ; plotting failed
                return  
            ENDIF         
        ENDFOR  
        return 
    ENDIF 


    ;; set ranges if not given already (which would skip computations
    ;; above): 
    IF n_elements(xrange) EQ 0 THEN xrange=range[0:1]
    IF n_elements(yrange) EQ 0 THEN yrange=range[2:3]
    IF n_elements(zrange) EQ 0 THEN zrange=range[4:5]


    ;; ------------------------------------------------------------
    ;; PLOT FRAME ACCORDING PLOT PARAMETER
    ;; ------------------------------------------------------------


    ;; plot frame if z-range not given:
    IF NOT finite(max(range[4:5])) THEN BEGIN 
        IF NOT execute("plot, xrange,"        $ ; plot dummy xrange/yrange
                       +"yrange,/nodata,"     $ ; to create frame.
                       +"xrange=xrange,"      $ ; use xrange, yrange
                       +"yrange=yrange,"      $
                       +"zrange=zrange,"      $
                       +"position=position,"  $ ; plot at given position
                       +"/noerase,"           $ ; do not destroy former plots
                       +'_EXTRA=ex') THEN     $
          cafereport,env,"Error:"+!ERR_STRING ; plotting failed      
    ENDIF ELSE BEGIN 

        ;; 2 dim -> plot surface without data:
        IF NOT execute("surface, indgen(2,2),"        $ ; plot dummy xrange/yrange
                       +"/nodata,/save,"      $ ; to create frame and save current 3d viewport.
                       +"xrange=xrange,"      $ ; use xrange, yrange
                       +"yrange=yrange,"      $
                       +"zrange=zrange,"      $
                       +"position=position,"  $ ; plot at given position
                       +"/noerase,"           $ ; do not destroy former plots
                       +'_EXTRA=ex') THEN     $
          cafereport,env,"Error:"+!ERR_STRING ; plotting failed      

    ENDELSE  
                  

    ;; ------------------------------------------------------------
    ;; PLOT PANEL
    ;; ------------------------------------------------------------
    



    ;; plot each type with different color:
    FOR i = 0, n_elements(plotlist)-1 DO BEGIN               

        ;; DO THE ACTUAL PLOT:
        IF NOT execute( PLOT_PREFIX+plotlist[i] +  $
          ",env, groups[i] ,position=position," +  $
          "xrange=xrange,"                      +  $ ; use xrange, yrange
          "yrange=yrange,"                      +  $
          "zrange=zrange,"                      +  $
          "range=range,"                        +  $
          plotparamlist[i]                      +  $
          "_EXTRA=ex") THEN                        $
        cafereport,env,"Error:"+!ERR_STRING ; plotting failed
        
        ;; change color for next plot type:
        color = color - deltacolor
        
        ;; wrap around if too much colors:
        IF color LT 0 THEN color = color + 255 

        ;; set line style:
        linestyle = linestyle + deltalinestyle

        ;; wrap around line style:
        IF linestyle GT 5  THEN linestyle = 0
        IF linestyle LT 0  THEN linestyle = 5

        ;; set psym:
        psym = psym + deltapsym

        ;; wrap around psym, respecting negative psym with lines:
        IF abs(psym) GT 7 THEN psym = 0
      
    ENDFOR  

  return   
END 
