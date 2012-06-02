;+
; NAME:
;           wplot_zoomin
;
; PURPOSE:
;           Button to enlarge view of data
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +zoomin+
;
; SUBCATEGORY:
;           wplot button
;
; BUTTON LABEL:
;           "zoom in"
;
; DESCRIPTION:
;           This buttons action will narrow the displayed
;           x-range. It will be assured that the range is either
;           1,2,5 times a power of 10.
;           Example: The xrange is 5*10^4 -> zoom in will set the
;           x range at 2*10^4.
;           This allows an almost equal scaled plot for different
;           data sets.
;           
; PARAMETER:
;           /t3d - zoom the y axis as well as the x axis (affects yrange also when
;                  t3d selected).
;               
; SIDE EFFECTS:
;           Changes xrange of displayed plot.
;
;
; HISTORY :
;           $Id: cafe_wplot_zoomin.pro,v 1.13 2003/04/28 07:45:12 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_zoomin.pro,v $
; Revision 1.13  2003/04/28 07:45:12  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.12  2003/04/24 09:55:11  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.11  2003/04/03 10:03:00  goehler
; do not plot when setplot is performed
;
; Revision 1.10  2003/03/17 14:11:44  goehler
; review/documentation updated.
;
; Revision 1.9  2003/03/03 11:18:31  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.8  2003/02/14 16:40:34  goehler
; documentized
;
; Revision 1.7  2003/02/13 17:05:07  goehler
; added 3-dim option for selection/zooming.
; still not working properly after resize
;
; Revision 1.6  2002/09/10 13:24:34  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:18  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;







;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_zoominevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env

    
    ;; decrease range in units of 2,5,10
    ;; the logarithmic formulae returns the range 1..10,
    ;; truncating postcoma digits
    CASE round(10.D^(alog10((*env).plot.xwidth)$
                   -floor(alog10((*env).plot.xwidth)))) OF 
        1 : (*env).plot.xwidth = (*env).plot.xwidth / 2.D0
        2 : (*env).plot.xwidth = (*env).plot.xwidth / 2.D0
        5 : (*env).plot.xwidth = (*env).plot.xwidth / 5.D0 * 2.D0
        ELSE: (*env).plot.xwidth = $
          10.D^floor(alog10((*env).plot.xwidth)) ;; for safety
    ENDCASE

    ;; set current range:
    xrange=[(*env).plot.xpos-(*env).plot.xwidth/2.D0, $
            (*env).plot.xpos+(*env).plot.xwidth/2.D0]

    ;; store it:
    cafe_setplot,env,"xrange=["+string(xrange[0])+","+ $
      string(xrange[1])+"]",/quiet,/report


    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet
END  



;; ------------------------------------------------------------
;; CAFE_WPLOT_ZOOMIN3D --- EVENT PROCEDURE FOR 3-DIM zooming
;; ------------------------------------------------------------

PRO cafe_wplot_zoominevent3d, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env


    
    ;; ------------------------------------------------------------
    ;; X RANGE
    ;; ------------------------------------------------------------
    
    ;; decrease range in units of 2,5,10
    ;; the logarithmic formulae returns the range 1..10,
    ;; truncating postcoma digits
    CASE round(10.D^(alog10((*env).plot.xwidth)$
                   -floor(alog10((*env).plot.xwidth)))) OF 
        1 : (*env).plot.xwidth = (*env).plot.xwidth / 2.D0
        2 : (*env).plot.xwidth = (*env).plot.xwidth / 2.D0
        5 : (*env).plot.xwidth = (*env).plot.xwidth / 5.D0 * 2.D0
        ELSE: (*env).plot.xwidth = $
          10.D^floor(alog10((*env).plot.xwidth)) ;; for safety
    ENDCASE

    ;; set current range:
    xrange=[(*env).plot.xpos-(*env).plot.xwidth/2.D0, $
            (*env).plot.xpos+(*env).plot.xwidth/2.D0]

    ;; store it:
    cafe_setplot,env,"xrange=["+string(xrange[0])+","+ $
      string(xrange[1])+"]",/quiet,/report


    ;; ------------------------------------------------------------
    ;; Y RANGE
    ;; ------------------------------------------------------------
    
    ;; decrease range in units of 2,5,10
    ;; the logarithmic formulae returns the range 1..10,
    ;; truncating postcoma digits
    CASE round(10.D^(alog10((*env).plot.ywidth)$
                   -floor(alog10((*env).plot.ywidth)))) OF 
        1 : (*env).plot.ywidth = (*env).plot.ywidth / 2.D0
        2 : (*env).plot.ywidth = (*env).plot.ywidth / 2.D0
        5 : (*env).plot.ywidth = (*env).plot.ywidth / 5.D0 * 2.D0
        ELSE: (*env).plot.ywidth = $
          10.D^floor(alog10((*env).plot.ywidth)) ;; for safety
    ENDCASE

    ;; set current range:
    yrange=[(*env).plot.ypos-(*env).plot.ywidth/2.D0, $
            (*env).plot.ypos+(*env).plot.ywidth/2.D0]

    ;; store it:
    cafe_setplot,env,"yrange=["+string(yrange[0])+","+ $
      string(yrange[1])+"]",/quiet,/report


    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet
END  


;; ------------------------------------------------------------
;; ZOOMIN - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_zoomin,env,  baseID, t3d=t3d,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_zoomin"
    
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
        print, "zoomin   - zoom into button"
        return
    ENDIF


    ;; setup parameter:
    IF n_elements(param) EQ 0 THEN param = ""


    IF keyword_set(t3d) THEN BEGIN 
        buttonID= widget_button(baseID, value="zoom in", $
                                event_pro="cafe_wplot_zoominevent3d")
    ENDIF ELSE BEGIN 
        buttonID= widget_button(baseID, value="zoom in", $
                                event_pro="cafe_wplot_zoominevent")
    ENDELSE 

END   
