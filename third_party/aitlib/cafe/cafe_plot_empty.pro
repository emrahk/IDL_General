PRO  cafe_plot_empty, env, group, position=position,     $
                        color=color, distinct=distinct, range=range,quiet=quiet, $ $
                        _EXTRA=ex,                         $
                        help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_empty
;
; PURPOSE:
;           do not plot anything
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
;                      Default is the primary group 0. Must be in
;                      range [0..9].
;           distinct - (optional) Plot frame in different color if
;                      some plot types are add in a single pane. 
;
; PLOT OUTPUT:
;
;           empty   - Do not plot. Useful for frame creation as placeholder.
;                     Range is taken from valid data set.
;
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > plot, empty, model
;                -> nothing above, but model below.
;
; HISTORY:
;           $Id: cafe_plot_empty.pro,v 1.5 2003/03/03 11:18:23 goehler Exp $
;-
;
; $Log: cafe_plot_empty.pro,v $
; Revision 1.5  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:08  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_empty"

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
        cafereport,env, "ratio    - plot empty frame"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

    IF n_elements(range) NE 0 THEN BEGIN 

        ;; check range for all subgroups:
        FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
            
            ;; skip empty groups:
            IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 

            ;; use only defined datapoints properly:
            def_index = where(*(*env).groups[group].data[i].def)
            
            ;; skip datasets without valid points:
            IF def_index[0] EQ -1 THEN CONTINUE

            x = (*(*env).groups[group].data[i].x)[def_index]
            y = (*(*env).groups[group].data[i].y)[def_index]
            err = (*(*env).groups[group].data[i].err)[def_index]

            ;; get ratio between data points and model:
            ratio = y/(cafemodel(env,x,group) > 1.D-30)


            range[0] = range[0] < min(x)
            range[1] = range[1] > max(x)
            range[2] = range[2] < min(ratio)
            range[3] = range[3] > max(ratio)
        ENDFOR
    ENDIF 

    ;; nothing to plot -> thats it. 
END
