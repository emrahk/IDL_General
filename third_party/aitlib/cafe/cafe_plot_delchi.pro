PRO  cafe_plot_delchi, env, group, position=position,    $
                         color=color, distinct=distinct,   $
                         range=range,quiet=quiet,          $ 
                         noerror=noerror,                  $ 
                         selected=selected,                $ 
                         _EXTRA=ex,                        $
                         help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_delchi
;
; PURPOSE:
;           plot residuum in 1-sigma units
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           plot type
;
; INPUTS:
;
;           group    - (optional) Define the data group to plot.
;                      Default is the current group. Must be in
;                      range [0..29].
;
; PLOT OUTPUT:
;
;           delchi   - plots the difference between data y-values and
;                      model, in units of 1 sigma. This is: plot (y -
;                      model_y)/error
;                      X range is kept, Y range is adapted to maximal values.
;
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;           noerror  - Do not plot error bars. This is useful for
;                      tight data sets. 
;
;           selected - Define range from selected datapoints. Usefull
;                      when fitting selected datapoints only.
;
;           distinct - Plot each subgroup with a different color.
;
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > plot, data, delchi
;                -> data + residuum of chi is displayed. 
;
; HISTORY:
;           $Id: cafe_plot_delchi.pro,v 1.12 2003/05/07 07:44:12 goehler Exp $
;-
;
; $Log: cafe_plot_delchi.pro,v $
; Revision 1.12  2003/05/07 07:44:12  goehler
; fixes: psym/linestyle change allowed here also.
;
; Revision 1.11  2003/03/17 14:11:33  goehler
; review/documentation updated.
;
; Revision 1.10  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.9  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.8  2002/09/09 17:36:08  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_delchi"

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
        cafereport,env, "delchi    - plot difference of (data-model)/error"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; color used for selected datapoints:
    IF n_elements(select_color) EQ 0 THEN select_color = 100

    ;; define color delta
    IF n_elements(deltacolor) EQ 0  THEN deltacolor=23

    ;; check model existence, abort if missing:
    IF (*env).groups[group].model EQ "" THEN RETURN

    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

    IF n_elements(range) NE 0 THEN BEGIN 

        ;; check range for all subgroups:
        FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
            
            ;; skip empty groups:
            IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 

            ;; use only defined datapoints properly:
            def_index = where(*(*env).groups[group].data[i].def AND $
                              (NOT keyword_set(selected) OR      $
                               *(*env).groups[group].data[i].selected))
            
            ;; skip datasets without valid points:
            IF def_index[0] EQ -1 THEN CONTINUE

            ;; skip datasets without error
            IF NOT PTR_VALID((*env).groups[group].data[i].err) THEN CONTINUE 

            x = (*(*env).groups[group].data[i].x)[def_index]
            y = (*(*env).groups[group].data[i].y)[def_index]
            err = (*(*env).groups[group].data[i].err)[def_index]


            ;; get difference between data points and model:
            delchi = (y-cafemodel(env,x,group))/(err > 1.D-30)

            range[0] = range[0] < min(x)
            range[1] = range[1] > max(x)
            range[2] = range[2] < min(delchi)
            range[3] = range[3] > max(delchi)
        ENDFOR
    ENDIF 

    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 


    ;; ------------------------------------------------------------
    ;; PLOT DEL CHI
    ;; ------------------------------------------------------------


    ;; set default color
    IF n_elements(color) EQ 0 THEN color = (*env).plot.color   


    ;; plot all valid subgroups:
    FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE
        
        ;; plot only defined datapoints properly:
        def_index = where(*(*env).groups[group].data[i].def)


        ;; defined index contains all defined and selected datapoints,
        ;; the latter if selected-keyword is used.
        def_index = where(*(*env).groups[group].data[i].def AND $
                          (NOT keyword_set(selected) OR      $
                           *(*env).groups[group].data[i].selected))        
        
        ;; skip datasets without valid points:
        IF def_index[0] EQ -1 THEN CONTINUE

        ;; skip datasets without error
        IF NOT PTR_VALID((*env).groups[group].data[i].err) THEN CONTINUE 

        x = (*(*env).groups[group].data[i].x)[def_index]
        y = (*(*env).groups[group].data[i].y)[def_index]

        ;; plot difference between data points and model:
        delchi = (y-cafemodel(env,x,group))/(err > 1.D-30)

        ;; plot difference between data points and model, in 1 sigma units:
        oplot, x,delchi, color=color,  _EXTRA=ex
        
        err = dblarr(n_elements(y))
        err[*] = 1. ;; error is always 1 sigma

        ;; plot error for difference between data points and model (if
        ;; not inhibited):
        IF (keyword_set(noerror) EQ 0) THEN                $          
          jwoploterr, x, delchi, err,                      $
          color=color,psym=-4, _EXTRA=ex


        ;; show selected measure points, but do not connect with lines
        IF keyword_set(selected) THEN BEGIN 

            ;; plot selected points:
            oplot, x, delchi,                                    $
                   psym=4, color = select_color, _EXTRA=ex
        ENDIF 

        ;; change color if some given:
        IF keyword_set(distinct) THEN color = color - deltacolor

    ENDFOR        
END


