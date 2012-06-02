PRO  cafe_plot_selection, env, group, position=position,      $
                       select_color=select_color,             $
                       undef_color=undef_color,               $
                       delta_color=delta_color,               $
                       color=color, distinct=distinct,        $
                       range=range, quiet=quiet,              $
                       noerror=noerror,                       $
                       undefined=undefined,                   $
                       noselect=noselect,                     $
                       _EXTRA=ex,                             $
                       help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_selection
;
; PURPOSE:
;           plot selected data
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
;           selection- plots selected datapoints. X/Y ranges are
;                      kept. Undefined points are plot not plot.
;                      
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:                      
;                      
;           undefined- Plot undefined data points. Useful for
;                      closer inspection.
;                      
;           distinct - Plot each subgroup file with a
;                      different color.
;                      
;       delta_color  - Color difference for distinct data sets.
;       select_color - Color for selected data points.
;       undef_color  - Color for undefined data points.
;
;                      
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > plot, data+selection
;                -> plot data plus their selected datapoints. 
;
; HISTORY:
;           $Id: cafe_plot_selection.pro,v 1.7 2003/05/08 09:20:13 goehler Exp $
;-
;
; $Log: cafe_plot_selection.pro,v $
; Revision 1.7  2003/05/08 09:20:13  goehler
; renamed color setting keywords/undefined (avoid name clash)
;
; Revision 1.6  2003/05/07 07:44:13  goehler
; fixes: psym/linestyle change allowed here also.
;
; Revision 1.5  2003/03/17 14:11:34  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.2  2002/09/09 17:36:09  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_selection"

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
        cafereport,env, "selection- plot selected data points"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; COLORS
    ;; ------------------------------------------------------------

    
    ;; set default color
    IF n_elements(color) EQ 0 THEN color = 255

    ;; define color delta
    IF n_elements(delta_color) EQ 0 THEN delta_color = 23

    ;; color used for undefined datapoints:
    IF n_elements(undef_color) EQ 0 THEN undef_color = 80

    ;; color used for selected datapoints:
    IF n_elements(select_color) EQ 0 THEN select_color = 100


    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

    IF n_elements(range) NE 0 THEN BEGIN 

        ;; for all subgroups:
        FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
            
            ;; skip empty subgroups:
            IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 
            
            ;; look only for defined datapoints:
            def_index = where(*(*env).groups[group].data[i].def)
            
            ;; skip undefined datasets
            IF def_index[0] EQ -1 THEN continue
            

            ;; replace range by superior value:
            IF def_index[0] NE -1 THEN BEGIN 
                range[0] = range[0] < min((*(*env).groups[group].data[i].x)[def_index])
                range[1] = range[1] > max((*(*env).groups[group].data[i].x)[def_index])
                range[2] = range[2] < min((*(*env).groups[group].data[i].y)[def_index])
                range[3] = range[3] > max((*(*env).groups[group].data[i].y)[def_index])
            ENDIF
        ENDFOR
    ENDIF 


    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 
        

    ;; ------------------------------------------------------------
    ;; PLOT SELECTED DATAPOINTS
    ;; ------------------------------------------------------------
    
    ;; plot all subgroups:
    FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        ;; skip empty subgroups:
        IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 
        
        ;; plot only defined/selected datapoints:
        def_index = where(*(*env).groups[group].data[i].selected $
                             AND *(*env).groups[group].data[i].def)

        undef_index = where(*(*env).groups[group].data[i].selected $
                             AND (*(*env).groups[group].data[i].def EQ 0))


        ;; define selected color by adding 100, regarding wrap around:
        used_color = (color + select_color) MOD 256
        
        IF def_index[0] NE -1 THEN                        $
          oplot, (*(*env).groups[group].data[i].x)[def_index], $
          (*(*env).groups[group].data[i].y)[def_index], $
           color=used_color, _EXTRA=ex
                
        ;; add undefined measure points, but do not connect with lines
        ;; if requested
        IF (undef_index[0] NE -1) AND                           $
          keyword_set(undef) THEN                               $
          oplot, (*(*env).groups[group].data[i].x)[undef_index],   $
          (*(*env).groups[group].data[i].y)[undef_index],          $
          psym=4, color = undef_color, _EXTRA=ex
        
        ;; change color if some given:
        IF keyword_set(distinct) THEN color = color - delta_color

        ;; wrap around if too much colors:
        IF color LT 0 THEN  color = color + 255

    ENDFOR
        
END





