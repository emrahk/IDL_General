;+
; NAME:
;           wplot_sliderparam
;
; PURPOSE:
;           Slider to change parameter value
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +sliderparam[param,min,max,step]+
;
; SUBCATEGORY:
;           wplot slider
;
;
; DESCRIPTION:
;           Supplies slider which allows interactive change  of a parameter
;           
; PARAMETER:
;           param - the parameter(s) which may be changed with the slider.
;                   This may be a parameter definition as in chpar.
;                   Default is first parameter (0).
;           min   - Minimum parameter value. Must be integer. Default: 0.
;           max   - Maximum parameter value. Must be integer. Default: 100.
;           step  - Minimum parameter step value. Default: 1.
;               
; SIDE EFFECTS:
;           Changes parameter value.
;
;
; HISTORY:
;           $Id: cafe_wplot_sliderparam.pro,v 1.3 2003/04/30 16:19:05 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_sliderparam.pro,v $
; Revision 1.3  2003/04/30 16:19:05  goehler
; bug fix: missing parenthese in report statement
;
; Revision 1.2  2003/04/29 12:08:16  goehler
; - fix of value settings
; - report command
;
; Revision 1.1  2003/04/29 08:01:26  goehler
; slider which allows to change parameters interactively
;
;






;; ------------------------------------------------------------
;; CAFE_WPLOT_SLIDERPARAMEVENT --- EVENT PROCEDURE WHEN PARAM-SLIDER MOVED
;; ------------------------------------------------------------

PRO cafe_wplot_sliderparamevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=value

    ;; get user value:
    widget_control,ev.id, get_uvalue=payload

    ;; set new parameter value:
    cafe_chpar, env, payload.param, $
                value * payload.step, /quiet

    ;; report command:
    cafereport,env,'chpar,'+strtrim(string(payload.param),2) +$
      ", "+strtrim(string(value * payload.step),2),/nocomment

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

PRO cafe_wplot_sliderparam,env,  baseID, param, min, max, step,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_sliderparam"
    
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
        print, "sliderparam   - slider for parameter change"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; defaults:
    IF n_elements(min) EQ 0 THEN min = 0
    IF n_elements(max) EQ 0 THEN max = 100
    IF n_elements(step) EQ 0 THEN step = 1
    IF n_elements(param) EQ 0 THEN param = 0
    

    ;; ------------------------------------------------------------
    ;; INIT WIDGET
    ;; ------------------------------------------------------------

    ParamsliderID=widget_slider(baseID, $
                                event_PRO="cafe_wplot_sliderparamevent",$
                                maximum=max/step,                       $
                                minimum=min/step,                       $
                                /drag,value=(max+min)/2,                $
                                uvalue={min:min, max:max, step:step,param:param},$
                                /suppress_value)
END   
