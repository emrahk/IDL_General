PRO  cafe_plot_data2, env, group, position=position,      $
                       color=color, distinct=distinct,     $
                       range=range, quiet=quiet,           $
                       undefined=undefined,                $
                       noselect=noselect,                  $
                       select_color=select_color,          $
                       undef_color=undef_color,            $
                       delta_color=delta_color,            $
                       norange=norange,                    $
                       polyshade=polyshade,                $
                       shade=shade,                        $
                       surf=surf,                          $
                       contour=contour,                    $
                       isolines=isolines,                  $
                       gridnum=gridnum,                    $
                       _EXTRA=ex,                          $
                       help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_data2
;
; PURPOSE:
;           plot 2-d data as is
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
;           data2    - plots the data of group given . X/Y ranges are
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
;          polyshade - Plot a shaded surface. Instead of shade the data
;                      will be plot as polygons with their
;                      positions. Usefull for very irregulary gridded
;                      data. Uses polyshade internally.
;                      USING THIS OPTION WILL CLEAR ALL FORMER
;                      DRAWINGS!
;                      
;           surf     - Plot a surface mesh. (default)
;
;           contour  - Plot a contour plot.
;
;           isolines - Plot on shade/surface isolevel contour lines
;                      (disable contour zvalue).
;                      
;           gridnum  - Number of grid elements to be used for shading polygons.
;                      Default: 50.
;                                        
;           undefined- Plot undefined data points also. Useful for
;                      closer inspection.
;                      
;           noselect - Do not mark selected data points. Useful for
;                      final plot.
;
;           norange  - Do not compute range (auxiliary data). Should
;                      not be used if single plot type.
;                      
;       delta_color  - Color difference for distinct data sets.
;       select_color - Color for selected data points.
;       undef_color  - Color for undefined data points.
;
;                      
; SIDE EFFECTS:
;           None.
;
; EXAMPLE:
;           > data, bla.dat,dat2
;           > plot, data2
;                -> 2-dim data is displayed as shaded. 
;
; HISTORY:
;           $Id: cafe_plot_data2.pro,v 1.12 2003/05/08 09:20:13 goehler Exp $
;-
;
; $Log: cafe_plot_data2.pro,v $
; Revision 1.12  2003/05/08 09:20:13  goehler
; renamed color setting keywords/undefined (avoid name clash)
;
; Revision 1.11  2003/04/03 16:12:22  goehler
; fix of "sloppy border bug": define grid size ezplizitely for TRIGRID.
;
; Revision 1.10  2003/03/18 17:30:19  goehler
; added polyshade option
;
; Revision 1.9  2003/03/17 14:11:33  goehler
; review/documentation updated.
;
; Revision 1.8  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2003/02/18 13:56:22  goehler
; added isolines option for z-varying contour levels
; improved model2
;
; Revision 1.6  2003/02/18 07:59:08  goehler
; added keyword "surf"
; improved irregular grid plotting
;
; Revision 1.5  2003/02/12 13:36:27  goehler
; added point drawing for selected/undef data points
;
; Revision 1.4  2003/02/12 12:45:21  goehler
; surf->shade; added contour keyword
;
; Revision 1.3  2003/02/11 17:25:59  goehler
; improved axis display
;
; Revision 1.2  2003/02/11 15:02:11  goehler
; added position facility
;
; Revision 1.1  2003/02/11 07:39:38  goehler
; initial version of 2-dim plot
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_data2"

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
        cafereport,env, "data2    - plot 2-d data as is"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP 
    ;; ------------------------------------------------------------


    ;; define default plotting: surface:
    IF NOT keyword_set(shade)    AND $
      NOT keyword_set(surf)      AND $
      NOT keyword_set(polyshade) AND $
      NOT keyword_set(contour)   THEN surf=1


    ;; default z value for contour plot. Not desired for isolines
    IF NOT keyword_set(isolines) THEN zvalue = 1.0

    ;; set contour to enable iso lines
    IF keyword_set(isolines) THEN contour=1

    ;; set default numbers of grid:
    IF n_elements(gridnum) EQ 0 THEN gridnum = 50.D0
   

    ;; ------------------------------------------------------------
    ;; COLORS
    ;; ------------------------------------------------------------

    
    ;; set default color
    IF n_elements(color) EQ 0 THEN color = 255

    ;; define color delta
    IF n_elements(delta_color) EQ 0 THEN delta_color = 23

    ;; color used for undefined datapoints:
    IF n_elements(undef_color) EQ 0 THEN undef_color = 50

    ;; color used for selected datapoints:
    IF n_elements(select_color) EQ 0 THEN select_color = 100


    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

   
    IF (n_elements(range) NE 0) AND (keyword_set(norange) EQ 0) THEN BEGIN 

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
                range[4] = range[4] < min((*(*env).groups[group].data[i].y)[def_index])
                range[5] = range[5] > max((*(*env).groups[group].data[i].y)[def_index])
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
        
        ;; plot only defined datapoints:
        def_index = where(*(*env).groups[group].data[i].def) 

        ;; check which data are not defined:
        undef_index = where(*(*env).groups[group].data[i].def EQ 0)

        x = [x,(*(*env).groups[group].data[i].x)[def_index,0]]
        y = [y,(*(*env).groups[group].data[i].x)[def_index,1]]
        z = [z,(*(*env).groups[group].data[i].y)[def_index]]       
    ENDFOR

    ;; remove first dummy element:
    IF n_elements(x) GT 1 THEN BEGIN 
        x =x[1:n_elements(x)-1]
        y =y[1:n_elements(y)-1]
        z =z[1:n_elements(z)-1]
    ENDIF 

    ;; ------------------------------------------------------------
    ;; CREATE GRID
    ;; ------------------------------------------------------------

    ;; create triangulated list
    triangulate,x,y,tr,b


    IF n_elements(missing) EQ 0 THEN missing = min(z)

    ;; create interpolated grid:
    dat=trigrid(x,y,z,tr,                                          $
                xgrid=xgrid,ygrid=ygrid,nx=gridnum,ny=gridnum,     $
                extrapolate=b, missing=missing, _EXTRA=ex)



    IF n_elements(xrange) EQ 0 THEN xrange=range[0:1]
    IF n_elements(yrange) EQ 0 THEN yrange=range[2:3]
    IF n_elements(zrange) EQ 0 THEN zrange=range[4:5]

    ;; make shure styles present:
    IF n_elements(xstyle) EQ 0 THEN xstyle=0
    IF n_elements(ystyle) EQ 0 THEN ystyle=0
    IF n_elements(zstyle) EQ 0 THEN zstyle=0


    ;; ------------------------------------------------------------
    ;; PLOT POLYGON SHADED WITH IMPROVED OBJECT DISPLAY
    ;; ------------------------------------------------------------

    IF keyword_set(polyshade) THEN BEGIN

        ;; add number of vertices for triangles :-)
        tr1 = make_array(4,(size(tr))[2],value=3)
        tr1[1:3,*] = tr

        ;; create image and draw it:
        tvscl,polyshade(x,y,z,tr1,/t3d)

        ;; add axis
        surface,dat,xgrid,ygrid, /noerase, /nodata,          $
          position=position,/save,                           $
          xrange=xrange,yrange=yrange,zrange=zrange,         $
          xstyle=xstyle,ystyle=ystyle,zstyle=zstyle,         $
          _EXTRA=ex

    ENDIF 


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
    ;; PLOT DATA
    ;; ------------------------------------------------------------
    
    ;; plot all subgroups:
    FOR i = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        ;; skip empty subgroups:
        IF NOT PTR_VALID((*env).groups[group].data[i].x)  THEN CONTINUE 
        
        ;; plot only defined datapoints properly:
        def_index = where(*(*env).groups[group].data[i].def)


        undef_index = where(*(*env).groups[group].data[i].def EQ 0)

        select_index = where(*(*env).groups[group].data[i].selected $
                             AND *(*env).groups[group].data[i].def)
        
        
        ;; add undefined measure points, but do not connect with lines
        ;; if requested
        IF (undef_index[0] NE -1) AND                           $
          keyword_set(undef) THEN                               $
          plots, (*(*env).groups[group].data[i].x)[undef_index,0], $
                 (*(*env).groups[group].data[i].x)[undef_index,1], $
                   (*(*env).groups[group].data[i].y)[undef_index], $
          /t3d,psym=4, color = undef_color, _EXTRA=ex

        ;; show selected measure points, but do not connect with lines
        ;; if not rejected
        IF (select_index[0] NE -1) AND                           $
          (NOT keyword_set(noselect)) THEN BEGIN 
            plots, (*(*env).groups[group].data[i].x)[select_index,0],   $
                   (*(*env).groups[group].data[i].x)[select_index,1],   $
                   (*(*env).groups[group].data[i].y)[select_index],     $
              /t3d,psym=4, color = select_color, _EXTRA=ex
        ENDIF 
        
        ;; change color if some given:
        IF keyword_set(distinct) THEN color = color - delta_color

        ;; wrap around if too much colors:
        IF color LT 0 THEN  color = color + 255

    ENDFOR


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





