PRO  cafe_plot_model, env, group, position=position,       $
                           color=color, distinct=distinct, $
                           range=range, quiet=quiet,       $  
                           _REF_EXTRA=ex,                  $
                            modelrange=modelrange,         $
                            help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_model
;
; PURPOSE:
;           plot model 
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
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;        modelrange  - Perform range determination for model size also
;                      (if range is not required anyway because still
;                      not defined). 
;
; PLOT OUTPUT:
;
;           model    - plots the model for group given with current parameters. 
;                      X/Y ranges are kept. 
;
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > plot, data+model
;                -> data + model in single window is displayed. 
;
; HISTORY:
;           $Id: cafe_plot_model.pro,v 1.13 2003/04/03 10:02:59 goehler Exp $
;-
;
; $Log: cafe_plot_model.pro,v $
; Revision 1.13  2003/04/03 10:02:59  goehler
; do not plot when setplot is performed
;
; Revision 1.12  2003/03/17 14:11:33  goehler
; review/documentation updated.
;
; Revision 1.11  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.10  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.9  2002/09/09 17:36:09  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_model"

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
    ;; CHECK
    ;; ------------------------------------------------------------

    ;; check model existence, abort if missing:
    IF (*env).groups[group].model EQ "" THEN RETURN

    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

    IF keyword_set(modelrange) THEN BEGIN 

        ;; check range for all subgroups:
        FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
        
            ;; skip empty groups:
            IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 


            def_index = where(*(*env).groups[group].data[i].def)
            

            ;; skip undefined datasets
            IF def_index[0] EQ -1 THEN continue

            x = (*(*env).groups[group].data[i].x)[def_index]
            y = cafemodel(env,x,group)

            range[0] = range[0] < min(x)
            range[1] = range[1] > max(x)
            range[2] = range[2] < min(y)
            range[3] = range[3] > max(y)
        ENDFOR
    ENDIF 


    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 

        

    ;; ------------------------------------------------------------
    ;; PLOT MODEL
    ;; ------------------------------------------------------------

    ;; set xrange according displayed range
    ;; which will be used to define range of data points:
    xrange=[(convert_coord(0,0.5,/normal,/to_data))[0], $
            (convert_coord(1.,0.5,/normal,/to_data))[0]]

    ;; set default color
    IF n_elements(color) EQ 0 THEN color = (*env).plot.color


    ;; check model existence:
    IF (*env).groups[group].model EQ "" THEN BEGIN 
        cafereport,env, "Error: No model given"
        return
    ENDIF

      
    ;; plot for a set of  x-values:
    ;; create x -values, y through model:
    x = indgen(1000,/double)*(xrange[1]-xrange[0])/1000.D0 + xrange[0]
    
    ;; plot model. But pass all but no psym (symbols do not look good for model!)
    oplot, x,cafemodel(env,x,group), color=color,$
      _EXTRA=["linestyle","clip","min_value", "max_value","polar","thick"]
        
END









