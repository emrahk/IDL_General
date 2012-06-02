PRO cafe_legend_string, env, group, pos,                          $
                     str=str, spacing=spacing, charsize=charsize, $
                     help=help, shorthelp=shorthelp,              $
                     _EXTRA=ex
;+
; NAME:
;           legend_string
;
; PURPOSE:
;           Writes legend text in plot window.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           legend
;
; LEGEND OUTPUT:
;           Writes string given as parameter 
;
;               
; SIDE EFFECTS:
;           Changes plot window.
;
;
; EXAMPLE:
;               > plot, data+model
;               > legend, string[Special model]
;               -> creates legend with the text "Special model"
;
; HISTORY:
;           $Id: cafe_legend_string.pro,v 1.2 2003/05/05 09:26:07 goehler Exp $
;             
;-
;
; $Log: cafe_legend_string.pro,v $
; Revision 1.2  2003/05/05 09:26:07  goehler
; first working version of legend. Allocation a bit hand-made.
;
; Revision 1.1  2003/04/11 07:49:57  goehler
; legend command in alpha state
;

    ;; command name of this source (needed for automatic help)
    name="legend_string"

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
        print, "string   - descriptive string"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; nothing to do
    IF n_elements(str) EQ 0 THEN return

    if n_elements(spacing) eq 0 then spacing = 1.2
    if n_elements(charsize) eq 0 then charsize = !p.charsize

    delta_y = !d.y_ch_size/float(!d.y_size) * (spacing > charsize)


    ;; ------------------------------------------------------------
    ;; PLOT LEGEND
    ;; ------------------------------------------------------------
    
    xyouts,pos[0]+0.007,pos[1]-(convert_coord(0,!d.y_ch_size,/device,/to_normal))[1],$
           str,/normal,_EXTRA=ex

    pos[1] = pos[1] - delta_y
END 
