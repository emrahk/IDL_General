PRO  cafe_plot_steppar2, env, group, position=position,    $
                        color=color,                       $
                        range=range,quiet=quiet,           $ 
                        deviation=deviation,               $
                        shade=shade,                       $
                        surf=surf,                         $
                        contour=contour,                   $
                        isolines=isolines,                 $
                        gridnum=gridnum,                   $
                        nofancy=nofancy,                   $
                        xtitle=xtitle,ytitle=ytitle,       $                        
                        _EXTRA=ex,                         $
                        help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_steppar2
;
; PURPOSE:
;           plot 3-dim steppar values computed with the steppar command
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           plot type
;
; INPUTS:
;
;          There group is always the last available one. Subgroup is
;          always the first one.
;
; PLOT OUTPUT:
;
;           steppar2 - Plot the steppar values of last call with "steppar".
;                      This will be a 3-d contour plot provided the
;                      "steppar"-command was run with 2 parameters.
;                      If not an error will be raised. 
;
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;          shade    -  Plot a shaded surface instead surface mesh.
;                      USING THIS OPTION WILL CLEAR ALL FORMER
;                      DRAWINGS!
;
;          surf     -  Plot a surface mesh.
;
;          contour  -  Plot a contour plot (default)
;          
;          isolines -  Plot on shade/surface isolevel contour lines
;                      (disable contour zvalue).
;                     
;           gridnum  - Number of grid elements to be used for shading polygons.
;                      Default: 50.
;
;          deviation - Flag. If true (=1) the parameter values are
;                      measured in deviation from the best-fit
;                      parameter value.
;
;          nofancy   - Flag which disables plotting of significance
;                      levels, labels etc. 
;                      
; SIDE EFFECTS:
;           Plots in current window. 
;
; EXAMPLE:
;           > model,parabel
;               > fit
;               steppar, 1,2
;               plot, steppar2 -> displays contour of parameter 1/2 
;
; HISTORY:
;           $Id: cafe_plot_steppar2.pro,v 1.7 2003/04/03 16:12:22 goehler Exp $
;-
;
; $Log: cafe_plot_steppar2.pro,v $
; Revision 1.7  2003/04/03 16:12:22  goehler
; fix of "sloppy border bug": define grid size ezplizitely for TRIGRID.
;
; Revision 1.6  2003/03/17 14:11:34  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2003/02/27 09:46:15  goehler
; - Check whether last group is occupied
; - No group selection available for steppar displays
;
; Revision 1.3  2003/02/26 17:56:27  goehler
; Fix: select free group for last available instead of 9
;
; Revision 1.2  2003/02/18 13:56:22  goehler
; added isolines option for z-varying contour levels
; improved model2
;
; Revision 1.1  2003/02/18 08:02:32  goehler
; change of steppar/contour:
; use free group 9 to put contour plot at
;
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_contour"

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
        cafereport,env, "contour    - plot contour computed before"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP 
    ;; ------------------------------------------------------------

    ;; define group for resulting steppar values:
    result_group=n_elements((*env).groups[*])-1 


    ;; define default plotting: contour:
    IF NOT keyword_set(shade) AND $
       NOT keyword_set(surf)  AND $
       NOT keyword_set(contour)  THEN surf=1

    ;; default z value for contour plot. Not desired for isolines
    IF NOT keyword_set(isolines) THEN zvalue = 1.0

    ;; set contour to enable iso lines
    IF keyword_set(isolines) THEN contour=1

    ;; set default numbers of grid:
    IF n_elements(gridnum) EQ 0 THEN gridnum = 50.D0

    ;; ------------------------------------------------------------
    ;; CHECK EXISTENCE OF CONTOUR COMPUTATION
    ;; ------------------------------------------------------------
    IF NOT ptr_valid((*env).groups[result_group].data[0].x) THEN BEGIN  

        cafereport,env, 'Error: missing steppar values. Must call command "steppar" before'
        range=[0,0,0,0]         ; dummy range
        return
    ENDIF

    IF (size(*(*env).groups[result_group].data[0].x))[0] NE 2 THEN BEGIN  
        cafereport,env, 'Error: steppar values not 2-dimensional'
        cafereport,env,  'Must call command "steppar" with 2 parameters'
        range=[0,0,0,0]         ; dummy range
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP FOR CONVENIENCE
    ;; ------------------------------------------------------------

    ;; the parameter values:
    param1 = (*env).steppar.param1
    param2 = (*env).steppar.param2

    ;; the values:
    p1   = (*(*env).groups[result_group].data[0].x)[*,0]
    p2   = (*(*env).groups[result_group].data[0].x)[*,1]
    chi2 = *(*env).groups[result_group].data[0].y

    ;; best norm is fit result
    bestnorm = cafegetchisq(env,selected=(*env).fitresult.selected)    


    ;; default x/y title:
    IF n_elements(xtitle) EQ 0 THEN xtitle=param1.parname
    IF n_elements(ytitle) EQ 0 THEN ytitle=param2.parname

    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

    ;; offset -> parameter value when deviation required
    IF keyword_set(deviation) THEN BEGIN 
        offset1=param1.value 
        offset2=param2.value 
    ENDIF ELSE BEGIN 
        offset1=0.
        offset2=0.
    ENDELSE 
    
    ;; simple: use already determined parameter/chi2 values:
    IF n_elements(range) NE 0 THEN BEGIN 

        range[0] = range[0] < (min(p1)-offset1)
        range[1] = range[1] > (max(p1)-offset1)
        range[2] = range[2] < (min(p2)-offset2)
        range[3] = range[3] > (max(p2)-offset2)
        range[4] = range[4] < min(chi2)
        range[5] = range[5] > max(chi2)
    ENDIF 

    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 

    ;; ------------------------------------------------------------
    ;; PLOTTING STUFF
    ;; TAKEN FROM MPSTEPPAR (J.Wilms)
    ;; ------------------------------------------------------------



    ;; ------------------------------------------------------------
    ;; CREATE GRID
    ;; ------------------------------------------------------------

    ;; create triangulated list
    triangulate,p1-offset1,p2-offset2,tr,b

    ;; define irregular datapoint values:
    IF n_elements(missing) EQ 0 THEN missing = min(chi2)


    ;; create interpolated grid:
    dat=trigrid(p1-offset1,p2-offset2,chi2,tr,xgrid=xgrid,ygrid=ygrid,$
                nx=gridnum,ny=gridnum,                                $
                extrapolate=b,missing=missing, _EXTRA=ex)




    ;; set ranges:
    IF n_elements(xrange) EQ 0 THEN xrange=range[0:1]
    IF n_elements(yrange) EQ 0 THEN yrange=range[2:3]
    IF n_elements(zrange) EQ 0 THEN zrange=range[4:5]

    ;; make shure styles present:
    IF n_elements(xstyle) EQ 0 THEN xstyle=0
    IF n_elements(ystyle) EQ 0 THEN ystyle=0
    IF n_elements(zstyle) EQ 0 THEN zstyle=0


    ;; ------------------------------------------------------------
    ;; PLOT SHADED
    ;; ------------------------------------------------------------

    IF keyword_set(shade) THEN BEGIN

        ;; shaded drawing
        shade_surf,dat,xgrid,ygrid, /noerase,position=position,/save,$
                   xrange=xrange,yrange=yrange,zrange=zrange,_EXTRA=ex

    ENDIF 

    ;; ------------------------------------------------------------
    ;; PLOT SURFACE MESH
    ;; ------------------------------------------------------------

    IF keyword_set(surf) THEN BEGIN

        ;; surface drawing:
        ;; disable axis:
        xstyle=xstyle OR 4
        ystyle=ystyle OR 4
        zstyle=zstyle OR 4

        surface,dat,xgrid,ygrid, /noerase, position=position,/save,$
          xrange=xrange,yrange=yrange,zrange=zrange,         $
          xstyle=xstyle,ystyle=ystyle,zstyle=zstyle,         $
          _EXTRA=ex

    ENDIF

    ;; ------------------------------------------------------------
    ;; PLOT CONTOUR
    ;; ------------------------------------------------------------


    IF keyword_set(contour) THEN BEGIN

        ;; define 1sigma, 90%, and 99% contours
        levels=bestnorm+[2.2789,4.6052,9.2104]

        ;; label contours:
        IF NOT keyword_set(nofancy) THEN BEGIN 
            c_labels=[1,1,1]
            c_annotation=['1!7r!X','90%','99%']
        ENDIF 

        contour,dat,xgrid,ygrid,/t3d,zvalue=zvalue,               $
                /noerase,position=position,                       $
                levels=levels,                                    $
                c_labels=c_labels, c_annotation=c_annotation,     $
                xrange=xrange,yrange=yrange,zrange=zrange,        $
                _EXTRA=ex


        ;; plot additional stuff if not excluded
        IF NOT keyword_set(nofancy) THEN BEGIN 

            ;; setup min/max displayed parameter values which must extend
            ;; the ranges to reach the frame border:

            ;; hesse matrix
            oplot,param1.value+[-param1.error,+param1.error]-offset1, $
                  [param2.value,param2.value]-offset2,linestyle=2,zvalue=zvalue,/t3d,_extra=ex
            
            oplot,[param1.value,param1.value]-offset1,                 $
                  param2.value+[-param2.error,+param2.error]-offset2,  $
                  linestyle=2,zvalue=zvalue,/t3d,_extra=ex
        
            ;; dashed lines outside, x direction
            oplot,[range[0],param1.value-param1.error-offset1], $
                  [param2.value,param2.value]-offset2,linestyle=1,$
                  zvalue=zvalue,/t3d,_extra=ex
            
            oplot,[param1.value+param1.error-offset1,range[1]], $
                  [param2.value,param2.value]-offset2,linestyle=1,$
                  zvalue=zvalue,/t3d,_extra=ex
            
            ;; dashed lines outside, y direction
            oplot,[param1.value,param1.value]-offset1, $
                  [range[2],param2.value-param2.error-offset2], $
                  linestyle=1, zvalue=zvalue, /t3d,_extra=ex
            oplot,[param1.value,param1.value]-offset1, $
                  [param2.value+param2.error-offset2,range[3]], $
                  linestyle=1,zvalue=zvalue,/t3d,_extra=ex
        ENDIF 
    ENDIF 
END



