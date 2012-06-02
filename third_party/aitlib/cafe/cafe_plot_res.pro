PRO  cafe_plot_res, env, group, position=position,        $
                      color=color, distinct=distinct,     $
                      range=range, quiet=quiet,           $
                      noerror=noerror,                    $
                      selected=selected,                  $  
                      _EXTRA=ex,                          $ 
                      help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_res
;
; PURPOSE:
;           plot residuum
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
;           res      - plots the difference between data y values and
;                      model for group given with current parameters.  
;                      X range is kept, Y range is adapted to maximal values.
;
;
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;           noerror  - Do not plot error bars. This is useful for
;                      tight data sets.
;                      
;           selected - Display selected datapoints only.Usefull
;                      when fitting selected datapoints.
;                      
;           distinct - Plot data for different subgroups in different color.
;
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > plot, data, res
;                -> data + residuum is displayed. 
;
; HISTORY:
;           $Id: cafe_plot_res.pro,v 1.13 2003/05/09 14:50:08 goehler Exp $
;-
;
; $Log: cafe_plot_res.pro,v $
; Revision 1.13  2003/05/09 14:50:08  goehler
;
; updated documentation in version 4.1
;
; Revision 1.12  2003/05/07 07:44:13  goehler
; fixes: psym/linestyle change allowed here also.
;
; Revision 1.11  2003/03/17 14:11:33  goehler
; review/documentation updated.
;
; Revision 1.10  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.9  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.8  2002/09/09 17:36:09  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_res"

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
        cafereport,env, "model    - plot fit model"
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
    ;; DEFINE  RANGE
    ;; ------------------------------------------------------------
    
    IF n_elements(range) NE 0 THEN BEGIN 

        ;; check range for all subgroups:
        FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
            
            ;; skip empty groups:
            IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 

            ;; use only defined/selected datapoints:
            def_index = where(*(*env).groups[group].data[i].def AND $
                              (NOT keyword_set(selected) OR      $
                               *(*env).groups[group].data[i].selected))
            
            ;; skip datasets without valid points:
            IF def_index[0] EQ -1 THEN CONTINUE

            x = (*(*env).groups[group].data[i].x)[def_index]
            y = (*(*env).groups[group].data[i].y)[def_index]

            ;; get difference between data points and model:
            res = y-cafemodel(env,x,group)

            range[0] = range[0] < min(x)
            range[1] = range[1] > max(x)
            range[2] = range[2] < min(res)
            range[3] = range[3] > max(res)
        ENDFOR
    ENDIF 

    ;; Do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 



    ;; ------------------------------------------------------------
    ;; PLOT RESIDUUM
    ;; ------------------------------------------------------------



    ;; set default color
    IF n_elements(color) EQ 0 THEN color = (*env).plot.color



    ;; plot all valid subgroups:
    FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE

        
        ;; defined index contains all defined and selected datapoints,
        ;; the latter if selected-keyword is used.
        def_index = where(*(*env).groups[group].data[i].def AND $
                          (NOT keyword_set(selected) OR      $
                           *(*env).groups[group].data[i].selected))        

        
        ;; skip datasets without valid points:
        IF def_index[0] EQ -1 THEN CONTINUE

        x = (*(*env).groups[group].data[i].x)[def_index]
        y = (*(*env).groups[group].data[i].y)[def_index]


        ;; plot difference between data points and model:
        oplot, x, y-cafemodel(env,x,group), color=color, _EXTRA=ex

        ;; plot error for difference between data points and model (if
        ;; not inhibited):
        IF (keyword_set(noerror) EQ 0) AND              $         ; not inhibited
          PTR_VALID((*env).groups[group].data[i].err) THEN BEGIN     ; and error column exists

            err = (*(*env).groups[group].data[i].err)[def_index]

            jwoploterr, x, y-cafemodel(env,x,group), err, $
              color=color,psym=-4, _EXTRA=ex
        ENDIF 


        ;; show selected measure points, but do not connect with lines
        IF keyword_set(selected) THEN BEGIN 

            ;; plot selected points:
            oplot, x, y-cafemodel(env,x,group),                  $
                   psym=4, color = select_color, _EXTRA=ex
        ENDIF 

        ;; change color if some given:
        IF keyword_set(distinct) THEN color = color - deltacolor

    ENDFOR        
END



