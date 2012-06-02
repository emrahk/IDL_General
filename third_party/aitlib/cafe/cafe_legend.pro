PRO  cafe_legend, env,                                    $
                  legends,                                $
                  pos,                                    $        
                  left=left, right=right,                 $
                  top=top, bottom=bottom,                 $ 
                  nobox=nobox,                            $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           legends
;
; PURPOSE:
;           draws legend information for plots
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           legend, legitem1["["param"]"]] + legitem2["["param"]"]]+....
;                   [,pos][,/left][,/right][,/top][,/bottom]
;
; INPUT:
;           legitem - What legend information should be drawn. These
;                     items are given as separate subtasks.
;                     These can be e.g.:
;                     - data:  Information about data displayed in
;                              current plot. Draws line/color
;                              according lines. 
;                     - fit:   Information about last fit result.
;                     - param: Information about (selected)
;                              parameters of fit.
;                     - model: Information about current model(s)
;                              used. 
;                     Available legend items may be shown with
;                      > help, legend, all
;
; OPTIONAL INPUT:
;           param    - Allow to send some parameters to the legend plotting
;                      handler.
;
;           pos      - Position (in normal coordinates) of legend to
;                      plot at. This must be a 2 component float
;                      vektor with [xpos, ypos] being the coordinates
;                      of the upper left corner. 
;
; OPTIONS:
;           top      - Plot at top position.
;           bottom   - Plot at bottom position.
;           left     - Plot at left position.
;           right    - Plot at right position.
;           nobox    - Do not plot a box frame around all legend items.
;
; SIDE EFFECTS:
;           Changes plot drawn. 
;
; EXAMPLE:
;               > plot, data,delchi, 2
;               > legend, data,/left
;                -> plot data information on plot at left side.
;
; HISTORY:
;           $Id: cafe_legend.pro,v 1.5 2003/05/05 09:26:07 goehler Exp $
;-
;
; $Log: cafe_legend.pro,v $
; Revision 1.5  2003/05/05 09:26:07  goehler
; first working version of legend. Allocation a bit hand-made.
;
; Revision 1.4  2003/04/28 07:38:15  goehler
; moved parameter determination into separate function cafequotestr
;
; Revision 1.3  2003/04/24 17:09:59  goehler
; streamlined documentation
;
; Revision 1.2  2003/04/15 09:27:36  goehler
; short help pretty print
;
; Revision 1.1  2003/04/11 07:49:57  goehler
; legend command in alpha state
;
;
;

    ;; command name of this source (needed for automatic help)
    name="legend"

    ;; prefix for all driver types:
    LEGEND_PREFIX = "cafe_legend_"

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
        cafereport,env, "legend   - draws legend information"
        return
    ENDIF
    
    ;; ------------------------------------------------------------
    ;; SETUP 
    ;; ------------------------------------------------------------

    ;; define default group
    IF n_elements(group) EQ 0 THEN group = (*env).def_grp
    

    ;; ------------------------------------------------------------
    ;; POSITION DETERMINATION
    ;; ------------------------------------------------------------

    IF n_elements(pos) EQ 0 THEN pos = [1.,1.]
    

    IF keyword_set(top)    THEN pos=[pos[0],0.]
    IF keyword_set(bottom) THEN pos=[pos[0],1.]
    IF keyword_set(left)   THEN pos=[0.,pos[1]]
    IF keyword_set(right)  THEN pos=[1.,pos[1]]

    ;; adjust margins
    IF pos[0] GT 0.75 THEN pos[0] = 0.75
    IF pos[0] LT 0.11 THEN pos[0] = 0.11
    IF pos[1] GT 0.93 THEN pos[1] = 0.93
    IF pos[1] LT 0.11 THEN pos[1] = 0.11


    startpos = pos
   
    ;; ------------------------------------------------------------
    ;; LEGEND ITEM DETERMINATION
    ;; ------------------------------------------------------------

    ;; separate different legend types:
    legendlist = strsplit(legends,'+',/extract)

    ;; list of groups for each legend type:
    groups = intarr(n_elements(legendlist))

    ;; list of parameter for each plot type:
    legendparamlist = strarr(n_elements(legendlist))

    ;; for each plot type extract group number:
    FOR i = 0, n_elements(legendlist)-1 DO BEGIN           
      
        ;; extended syntax: legendtype:group -> extract group, if any
        legenditem=stregex(legendlist[i],'([a-zA-Z0-9]+)(\[(.*)\])?(:([0-9]*))?',$
                         /extract,/subexpr)
          
        legendlist[i] = legenditem[1] ; store legend type without group

        ;; legend group found -> extract new legend type and group number
        IF legenditem[5] NE "" THEN groups[i] = fix(legenditem[5]) $        
        ELSE groups[i] = group ;; otherwise use default group:

        ;; store quoted legend parameter with following ",":
        IF legenditem[3] NE "" THEN BEGIN 
            legendparamlist[i] = cafequotestr(legenditem[3],/keyvalpair) + ','
        ENDIF      
    ENDFOR

    ;; ------------------------------------------------------------
    ;; DEFINE RANGES FROM LEGEND TYPES
    ;; ------------------------------------------------------------


    
    ;; legend (quiet) each type get range:
    FOR i = 0, n_elements(legendlist)-1 DO BEGIN               

        ;; get the ranges by quiet legendting:
        IF NOT execute(LEGEND_PREFIX+legendlist[i]  $
                        +",env, groups[i],pos,"     $
                        + legendparamlist[i]        $
                        +"_EXTRA=ex") THEN BEGIN 
            cafereport,env,"Error:"+!ERR_STRING ; plotting failed
            return 
        ENDIF         
    ENDFOR  

    ;; ------------------------------------------------------------
    ;; DRAW BOX IF NOT EXCLUDED
    ;; ------------------------------------------------------------

    IF NOT keyword_set(nobox) THEN BEGIN
        x = [pos[0],     pos[0]+0.15,pos[0]+0.15, pos[0], pos[0]]
        y = [startpos[1],startpos[1],pos[1],      pos[1], startpos[1]]
        plots,x,y,/normal
    ENDIF 


END 



