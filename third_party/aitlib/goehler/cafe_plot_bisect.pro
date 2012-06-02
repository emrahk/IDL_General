PRO  cafe_plot_bisect, env, group, position=position,      $
                       color=color, distinct=distinct,     $
                       range=range, quiet=quiet,           $
                       undef=undef,                        $
                       gaps=gaps,                          $
                       gaptol=gaptol,                      $
                       _EXTRA=ex,                          $
                       help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_bisect
;
; PURPOSE:
;           plot data as bisectors, i.e. x1= start, x2= stop, y horizontal
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
;                      Default is current group. Must be in
;                      range [0..29]. 
;
; PLOT OUTPUT:
;
;           bisect   - plots the data as bisector of group given . X/Y ranges are
;                      kept. Undefined points are plot but not
;                      connected. 
;                      
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;                      
;           undef    - Plot undefined data points. Useful for
;                      closer inspection.                      
;
;           distinct - Plot each subgroup file with a
;                      different color.
;
;                      
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > plot, bisect:3
;                -> data in group 3 displayed as bisectors. 
;
; HISTORY:
;           $Id: cafe_plot_bisect.pro,v 1.1 2003/04/14 17:41:14 goehler Exp $
;-
;
; $Log: cafe_plot_bisect.pro,v $
; Revision 1.1  2003/04/14 17:41:14  goehler
; style to plot bisector lines
;
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_bisect"

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
        cafereport,env, "bisect   - plot bisectors"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; COLORS
    ;; ------------------------------------------------------------

    
    ;; set default color
    IF n_elements(color) EQ 0 THEN color = 255

    ;; define color delta
    IF n_elements(deltacolor) EQ 0  THEN deltacolor=23


    ;; color used for undefined datapoints:
    undef_color = 50

    ;; color used for selected datapoints:
    select_color = 100


    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 
        

    ;; ------------------------------------------------------------
    ;; PLOT BISECT DATA
    ;; ------------------------------------------------------------
    
    ;; plot all subgroups:
    FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        ;; skip empty subgroups:
        IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 
        
        ;; plot only defined datapoints properly:
        def_index = where(*(*env).groups[group].data[i].def)


        undef_index = where(*(*env).groups[group].data[i].def EQ 0)

        
        ;; points defined:
        IF def_index[0] NE -1 THEN BEGIN 

            ;; extract data setzt:
            x1 = (*(*env).groups[group].data[i].x)[def_index,0]
            x2 = (*(*env).groups[group].data[i].x)[def_index,1]
            y = (*(*env).groups[group].data[i].y)[def_index]
            
            ;; plot bisectors for test:
            FOR j = 0, n_elements(y)-1 DO BEGIN 
                oplot,[x1[j],x2[j]], [y[j],y[j]], $
                  psym=-4, color=color, _EXTRA=ex
            ENDFOR             
        ENDIF 
                
        
        ;; change color if some given:
        IF keyword_set(distinct) THEN color = color - deltacolor

        ;; wrap around if too much colors:
        IF color LT 0 THEN  color = color + 255

    ENDFOR
        
END





