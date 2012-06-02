PRO  cafe_plot_model2, env, group, position=position,      $
                       range=range, quiet=quiet,           $
                       select_color=select_color,          $
                       undefined=undefined,                $
                       selected=selected,                  $
                       norange=norange,                    $
                       surf=surf,                          $
                       shade=shade,                        $
                       contour=contour,                    $
                       isolines=isolines,                  $
                       _EXTRA=ex,                          $
                       help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_model2
;
; PURPOSE:
;           plot 2-d model over existing data 
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
; PLOT OUTPUT:
;
;           model2   - plots the data of group given . X/Y ranges are
;                      kept. Undefined points are not plotted by default.
;                      No subgroup distinction will be performed (the
;                      data points are plotted together). 
;                      
; SETPLOT KEYWORDS:
;           Apart from IDL shade_surf/surface keywords following special
;                      are defined:
;           shade    - Plot a shaded surface instead surface mesh.
;                      USING THIS OPTION WILL CLEAR ALL FORMER
;                      DRAWINGS!
;                      
;           surf     - Plot a surface mesh. (default)
;
;           contour  - Plot a contour plot.
;           
;           isolines - Plot on shade/surface isolevel contour lines
;                                        
;           undefined- Plot model for undefined data points also. Useful for
;                      closer inspection. (No color distinction to
;                      defined data points)
;                      
;           selected - Plot model for selected datapoints only.
;
;           norange  - Do not compute range (auxiliary data). Should
;                      not be used if single plot type.
;                      
;       select_color - Color for selected data points.
;
;                      
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > data, bla.dat,dat2
;           > plot, model2
;                -> 2-dim data is displayed as shaded. 
;
; HISTORY:
;           $Id: cafe_plot_model2.pro,v 1.7 2003/05/08 09:20:13 goehler Exp $
;-
;
; $Log: cafe_plot_model2.pro,v $
; Revision 1.7  2003/05/08 09:20:13  goehler
; renamed color setting keywords/undefined (avoid name clash)
;
; Revision 1.6  2003/03/17 14:11:33  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2003/02/18 13:56:22  goehler
; added isolines option for z-varying contour levels
; improved model2
;
; Revision 1.3  2003/02/12 12:45:22  goehler
; surf->shade; added contour keyword
;
; Revision 1.2  2003/02/11 17:25:59  goehler
; improved axis display
;
; Revision 1.1  2003/02/11 15:03:35  goehler
; added gauss model, and method to plot models.
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_model2"

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
        cafereport,env, "model2   - plot 2-d model"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; define default plotting: surface:
    IF NOT keyword_set(shade) AND $
      NOT keyword_set(surf)  AND $
      NOT keyword_set(contour)  THEN surf=1

    ;; default z value for contour plot. Not desired for isolines
    IF NOT keyword_set(isolines) THEN zvalue = 1.0

    ;; set contour to enable iso lines
    IF keyword_set(isolines) THEN contour=1

    ;; ------------------------------------------------------------
    ;; COLORS
    ;; ------------------------------------------------------------

    
    ;; set default color
    IF n_elements(color) EQ 0 THEN color = 255

    ;; color used for undefined datapoints:
    IF n_elements(undef_color) EQ 0 THEN undef_color = 50

    ;; color used for selected datapoints:
    IF n_elements(select_color) EQ 0 THEN select_color = 100


    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

   
    IF (n_elements(range) NE 0) AND (keyword_set(modelrange) EQ 0) THEN BEGIN 

        ;; for all subgroups:
        FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
            
            ;; skip empty subgroups:
            IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 
            
            ;; look only for defined datapoints:
            def_index = where(*(*env).groups[group].data[i].def)
            
            ;; skip undefined datasets
            IF def_index[0] EQ -1 THEN continue
            

            ;; replace range by superior value:
            IF def_index[0] NE -1 THEN BEGIN 
                range[0] = range[0] < min((*(*env).groups[group].data[i].x)[def_index,0])
                range[1] = range[1] > max((*(*env).groups[group].data[i].x)[def_index,0])
                range[2] = range[2] < min((*(*env).groups[group].data[i].x)[def_index,1])
                range[3] = range[3] > max((*(*env).groups[group].data[i].x)[def_index,1])
                
                x = (*(*env).groups[group].data[i].x)[def_index,*]
                z = cafemodel(env,x,group)

                range[4] = range[4] < min(z)
                range[5] = range[5] > max(z)

            ENDIF
        ENDFOR
    ENDIF 


    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 
        

    ;; ------------------------------------------------------------
    ;; COLLECT DATA
    ;; ------------------------------------------------------------

    ;; data to collect:
    x=0.D0
    y=0.D0
    z=0.D0
    
    
    ;; plot all subgroups:
    FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        ;; skip empty subgroups:
        IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 
        
        ;; plot only defined/selected datapoints:
        IF NOT keyword_set(selected) THEN $
          def_index = where(*(*env).groups[group].data[i].def) $
        ELSE                                                $
          def_index = where(*(*env).groups[group].data[i].selected) 

        ;; check which data are not defined:
        undef_index = where(*(*env).groups[group].data[i].def EQ 0)

        x = [x,(*(*env).groups[group].data[i].x)[def_index,0]]
        y = [y,(*(*env).groups[group].data[i].x)[def_index,1]]
        z = [z,cafemodel(env,(*(*env).groups[group].data[i].x)[def_index,*],group)]
        
        ;; add undefined measure points
        ;; if requested
        IF (undef_index[0] NE -1) AND                           $
          keyword_set(undef) THEN BEGIN
            x = [x,(*(*env).groups[group].data[i].x)[undef_index,0]]
            y = [y,(*(*env).groups[group].data[i].x)[undef_index,1]]
            z = [z,cafemodel(env,(*(*env).groups[group].data[i].x)[undef_index,*],group)]
        ENDIF 

    ENDFOR

    ;; remove first dummy element:
    IF n_elements(x) GT 1 THEN BEGIN 
        x =x[1:n_elements(x)-1]
        y =y[1:n_elements(y)-1]
        z =z[1:n_elements(z)-1]
    ENDIF 

    ;; ------------------------------------------------------------
    ;; PLOT DATA
    ;; ------------------------------------------------------------

    ;; create triangulated list
    triangulate,x,y,tr,b

    ;; value for undefined grid points:
    IF n_elements(missing) EQ 0 THEN missing = min(z)

    ;; create interpolated grid:
    dat=trigrid(x,y,z,tr,xgrid=xgrid,ygrid=ygrid,$
                extrapolate=b,missing=missing,_EXTRA=ex)


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

        contour,dat,xgrid,ygrid,/t3d, zvalue=zvalue,        $
          /noerase,position=position,                       $
          xrange=xrange,yrange=yrange,zrange=zrange,        $
          _EXTRA=ex
    ENDIF 

END





