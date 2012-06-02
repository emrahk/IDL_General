;+
; NAME:
;           wplot_bisect
;
; PURPOSE:
;           Create data points of a dipping structure bisected with
;           horizontal lines. 
;
; CATEGORY:
;           cafe/dips
;
; SUBCATEGORY:
;           wplot button
;
; BUTTON LABEL:
;           "bisect"
;
; DESCRIPTION:
;           Use dip_bisect procedure, store data points found in new group.
;               
; SIDE EFFECTS:
;           Creates new data points
;
;
; HISTORY:
;           $Id: cafe_wplot_bisect.pro,v 1.2 2003/04/14 16:36:56 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_bisect.pro,v $
; Revision 1.2  2003/04/14 16:36:56  goehler
; save real bisector values also. Usefull for plotting
;
; Revision 1.1  2003/04/14 15:28:56  goehler
; moved from cafe here. persional extension.
;
; Revision 1.2  2003/04/14 10:58:49  goehler
; - Works now
; - Store data directly (!)
;
; Revision 1.1  2003/04/14 07:42:22  goehler
; special function to evaluate dips. alpha state
;
;
;







;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_bisectevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env


    ;; define new x position by searching next data point on left:
    group = (*env).def_grp ; default group

    ;; where the result has to be stored at:
    result_group = group+1


    ;; dummy startup values:
    x=0.D0
    y=0.D0
    
    ;; check all subgroups, build x/y array
    FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        ;; skip not defined data sets (subgroups)
        IF NOT PTR_VALID((*env).groups[group].data[subgroup].x)  THEN CONTINUE

        ;; index for defined and selected values:
        def_index = where(*(*env).groups[group].data[subgroup].def AND $
                          *(*env).groups[group].data[subgroup].selected)

        ;; no index found -> next data set
        IF def_index[0] EQ -1 THEN CONTINUE 
            
        x = [x,(*(*env).groups[group].data[subgroup].x)[def_index]]
        y = [y,(*(*env).groups[group].data[subgroup].y)[def_index]]            
    ENDFOR 

    ;; remove first dummy point
    x = x[1:*]
    y = y[1:*]

    ;; lookup bisectors:
    dip_bisect, x,y, (max(x)+min(x))/2.D0, min(y), $ ; x, y, pivots
                bisectors,fitval=fitval
    

    ;; remove former data:
    PTR_FREE,(*env).groups[result_group].data[0].x
    PTR_FREE,(*env).groups[result_group].data[0].y
    PTR_FREE,(*env).groups[result_group].data[0].err
    PTR_FREE,(*env).groups[result_group].data[0].def

    ;; store result
    (*env).groups[result_group].data[0].x = $
      PTR_NEW((reform(bisectors[0,*]+bisectors[1,*]))/2.D0) 
    (*env).groups[result_group].data[0].y = PTR_NEW(reform(bisectors[2,*])) 
    (*env).groups[result_group].data[0].file = "BISECT"

    ;; allocate defined measure point array (default all defined):
    (*env).groups[result_group].data[0].def = $
      PTR_NEW(bytarr(n_elements(bisectors[0,*]),/nozero)) 
    (*(*env).groups[result_group].data[0].def)[*]=1

    ;; allocate selected point array (none selected):
    (*env).groups[result_group].data[0].selected = $
      PTR_NEW(bytarr(n_elements(bisectors[0,*]),/nozero)) 
    (*(*env).groups[result_group].data[0].selected)[*]=0
;    cafe_import,env, (reform(bisectors[0,*]+bisectors[1,*]))/2.D0, $
;      reform(bisectors[2,*]), undef, "BISECT", result_group

    ;; report best fit value:
    cafereport,env, "Best fit: "+ string(fitval, format="(F18.10)")

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; display result
    cafe_plot,env,/quiet


    ;; save bisector values in following group:
    cafe_remove,env,"*",result_group+1
    cafe_import,env,transpose(bisectors[0:1,*]), reform(bisectors[2,*]), $
      noerror,"BISECTVAL", result_group+1

    ;; plot transitory bisectors for test:
    FOR i = 0, n_elements(bisectors[0,*])-1 DO BEGIN 
        oplot,bisectors[0:1,i], [bisectors[2,i], bisectors[2,i]], $
          color=200
    ENDFOR 
END  


;; ------------------------------------------------------------
;; BISECT - THE MAIN FUNCTION WHICH PERFORMS BISECTION
;; ------------------------------------------------------------

PRO cafe_wplot_bisect,env, baseID, param,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_bisect"
    
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
        print, "bisect   - analyze dip"
        return
    ENDIF


    buttonID= widget_button(baseID, value="bisect", $
                            event_pro="cafe_wplot_bisectevent")

END   



