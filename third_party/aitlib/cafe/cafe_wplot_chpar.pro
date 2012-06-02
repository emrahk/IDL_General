;+
; NAME:
;           wplot_chpar
;
; PURPOSE:
;           Button to change parameter value
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +chpar[param,step]+
;
; SUBCATEGORY:
;           wplot button
;           
; BUTTON LABEL:
;           "[par->val]"
;
;
; DESCRIPTION:
;           Supplies button which allows interactive change of a parameter
;           
; PARAMETER:
;           param - the parameter(s) which may be changed with the slider.
;                   This may be a parameter definition as in chpar.
;                   Default is first parameter (0).           
;           step  - Value to add to current parameter(s). May be
;                   negative for decrease. 
;               
; SIDE EFFECTS:
;           Changes parameter value.
;
;
; HISTORY:
;           $Id: cafe_wplot_chpar.pro,v 1.1 2003/04/29 12:09:24 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_chpar.pro,v $
; Revision 1.1  2003/04/29 12:09:24  goehler
; new button to change parameter
;
;
;






;; ------------------------------------------------------------
;; CAFE_WPLOT_CHPAREVENT --- EVENT PROCEDURE WHEN PARAM-SLIDER MOVED
;; ------------------------------------------------------------

PRO cafe_wplot_chparevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=value

    ;; get user value:
    widget_control,ev.id, get_uvalue=payload

    ;; set new parameter value:
    cafe_chpar, env, payload.param, $
                     payload.step, /add

    ;; report command:
    cafereport,env,'chpar,'+strtrim(string(payload.param),2) +     $
      ", "+strtrim(string(payload.step),2)+",/add",/nocomment

    ;; plot on pixmap:
    wset, (*env).widgets.pixID
    cafe_plot,env,/quiet

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID    

    ;; copy pixmap -> window
    device,copy=[0,0,(*env).widgets.xsize, $
                 (*env).widgets.ysize,0,0,$
                 (*env).widgets.pixID]

END 


;; ------------------------------------------------------------
;; SLIDERPARAM - THE MAIN FUNCTION WHICH ALLOCATES A NEW SLIDER
;; ------------------------------------------------------------

PRO cafe_wplot_chpar,env,  baseID, param, step,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_chpar"
    
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
        print, "chpar   - change parameter"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; defaults:
    IF n_elements(step) EQ 0 THEN step = 1
    IF n_elements(param) EQ 0 THEN param = 0
    

    ;; ------------------------------------------------------------
    ;; INIT WIDGET
    ;; ------------------------------------------------------------

        buttonID= widget_button(baseID, value="["+$
                                strtrim(string(param),2)+"->"+$
                                strtrim(string(step),2)+"]", $
                                event_pro="cafe_wplot_chparevent", $
                                uvalue = {param:param, step:step})
END   
