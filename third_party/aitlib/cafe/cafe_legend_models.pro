PRO cafe_legend_models, env, group, pos,                          $
                     help=help, shorthelp=shorthelp,              $
                     _EXTRA=ex
;+
; NAME:
;           legend_models
;
; PURPOSE:
;           Writes currently used models as legend in plot window.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           legend
;
; LEGEND OUTPUT:
;           Writes out all models defined. The output resembles the
;           one used for show,model

;               
; SIDE EFFECTS:
;           Changes plot window.
;
;
; EXAMPLE:
;               > fit
;               > plot, data+model
;               > legend, models+result
;               -> creates legend with the last fit results plus
;               models applied.
;
; HISTORY:
;           $Id: cafe_legend_models.pro,v 1.1 2003/05/05 16:46:59 goehler Exp $
;             
;-
;
; $Log: cafe_legend_models.pro,v $
; Revision 1.1  2003/05/05 16:46:59  goehler
; initial version of model legend display
;
;
;

    ;; command name of this source (needed for automatic help)
    name="legend_models"

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
        print, "models   - legend of models using"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SHOW MODELS
    ;; ------------------------------------------------------------

    ;; upper border:
    pos[1]=pos[1] - 0.007

    FOR group = 0, n_elements((*env).groups)-1 DO BEGIN 
        
        ;; SKIP EMPTY MODELS
        IF (*env).groups[group].model EQ "" THEN CONTINUE 

        ;; display model:
        cafe_legend_string,env,group,pos,                                    $
          str=(*ENV).GROUPS[GROUP].MODEL+"["+string(group,format="(I0)")+"]"
                      
    ENDFOR

    ;; lower border:
    pos[1]=pos[1] - 0.003

END 

