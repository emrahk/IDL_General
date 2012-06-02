PRO  cafe_plot_data, env, group, position=position,       $
                       color=color,                        $
                       select_color=select_color,          $
                       undef_color=undef_color,            $
                       delta_color=delta_color,            $
                       distinct=distinct,                  $
                       range=range, quiet=quiet,           $
                       noerror=noerror,                    $
                       undefined=undefined,                $
                       noselect=noselect,                  $
                       norange=norange,                    $
                       gaps=gaps,                          $
                       gaptol=gaptol,                      $
                       _EXTRA=ex,                          $
                       help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_data
;
; PURPOSE:
;           plot data as is
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
;                      Default is current group. Must be in
;                      range [0..29]. 
;
; PLOT OUTPUT:
;
;           data     - plots the data of group given . X/Y ranges are
;                      kept. Undefined points are plot but not
;                      connected. Error bars also 
;                      will be drawn if not inhibited (s.b.). 
;                      
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;           noerror  - Do not plot error bars. This is useful for
;                      tight data sets.
;                      
;       undefined    - Plot undefined data points. Useful for
;                      closer inspection.
;                      
;           noselect - Do not mark selected data points. Useful for
;                      final plot.
;
;           norange  - Do not compute range (auxiliary data). Should
;                      not be used if single plot type.
;
;           gaps     - Do not connect datapoints which are gaps in
;                      respect of a regular x base. It is assumed that
;                      the periodicity is defined by x[1] - x[0]. 
;                      
;           gaptol   - Defines above which x difference gaps are
;                      recognized. Must be given in units of binning
;                      width=x[1] - x[0]. Default is 0.1 = 10%. 
;                      
;           distinct - Plot each subgroup file with a
;                      different color.
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
;           > plot, data
;                -> data displayed as is. 
;
; HISTORY:
;           $Id: cafe_plot_data.pro,v 1.17 2003/05/08 09:20:13 goehler Exp $
;-
;
; $Log: cafe_plot_data.pro,v $
; Revision 1.17  2003/05/08 09:20:13  goehler
; renamed color setting keywords/undefined (avoid name clash)
;
; Revision 1.16  2003/05/07 07:44:12  goehler
; fixes: psym/linestyle change allowed here also.
;
; Revision 1.15  2003/05/05 14:50:32  goehler
; do not interfere noerrors with gaps options (error command draw lines!)
;
; Revision 1.14  2003/05/05 09:24:46  goehler
; default undef/selected data properties may be changed via setplot
;
; Revision 1.13  2003/04/03 09:59:36  goehler
; added gaps/gaptol keywords which avoid connection of non-continuous data
;
; Revision 1.12  2003/03/17 14:11:32  goehler
; review/documentation updated.
;
; Revision 1.11  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.10  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.9  2002/09/09 17:36:08  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_data"

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
        cafereport,env, "data     - plot data as is"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------
    IF n_elements(gaptol) EQ 0 THEN BEGIN  ; how much the gap binning may vary
        gaptol = 0.1                         ; default: 10%       
    ENDIF 
    gaptol = gaptol+1.                     ; add 100% for binning

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
                range[0] = range[0] < min((*(*env).groups[group].data[i].x)[def_index])
                range[1] = range[1] > max((*(*env).groups[group].data[i].x)[def_index])
                range[2] = range[2] < min((*(*env).groups[group].data[i].y)[def_index])
                range[3] = range[3] > max((*(*env).groups[group].data[i].y)[def_index])
            ENDIF
        ENDFOR
    ENDIF 


    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 
        

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


        
        ;; points defined:
        IF def_index[0] NE -1 THEN BEGIN 

            ;; extract data sets:
            x = (*(*env).groups[group].data[i].x)[def_index]
            y = (*(*env).groups[group].data[i].y)[def_index]

            IF PTR_VALID((*env).groups[group].data[i].err) THEN $
              err = (*(*env).groups[group].data[i].err)[def_index]

            ;; default: no gaps -> start from index 0
            ;; gap_index stores the indices where a gap starts(!)
            ;; for convenience a gap start is added immediate after the last data
            ;; point 


            gap_index=[0]

            ;; check gaps -> compute difference, take binning into account
            IF KEYWORD_SET(gaps ) THEN BEGIN   
                binning   = (x[1]-x[0]) ; x binning 

                ;; define x gaps:
                ;; -> where x is not sequence of binning of time distance:
                gap_index   = where((x-[-!values.d_infinity,x]) GE binning*gaptol)      
            ENDIF 

            ;; add gap at last element (plus 1)
            gap_index=[gap_index,n_elements(x)]

            ;; for each item between gaps (possibly one):
            FOR g=0,n_elements(gap_index)-2 do BEGIN

                ;; perform plot:
                oplot,x[gap_index[g]:gap_index[g+1]-1],$
                      y[gap_index[g]:gap_index[g+1]-1],$
                   psym=psym, color=color, _EXTRA=ex

                ;; plot errors:
                IF NOT keyword_set(noerror) AND                      $ ; error should be shown
                   PTR_VALID((*env).groups[group].data[i].err) THEN  $ ; and error exists
                  jwoploterr,x[gap_index[g]:gap_index[g+1]-1],       $ ; plot error with J.W. style
                             y[gap_index[g]:gap_index[g+1]-1],       $ 
                             err[gap_index[g]:gap_index[g+1]-1],     $ ; and error
                  color=color, _EXTRA=ex
            ENDFOR         
        ENDIF ;; datapoints exist 
        
        ;; add undefined measure points, but do not connect with lines
        ;; if requested
        IF (undef_index[0] NE -1) AND                              $
          keyword_set(undefined) THEN                              $
          oplot, (*(*env).groups[group].data[i].x)[undef_index],   $
          (*(*env).groups[group].data[i].y)[undef_index],          $
          psym=4, color = undef_color, _EXTRA=ex

        ;; show selected measure points, but do not connect with lines
        ;; if not rejected
        IF (select_index[0] NE -1) AND                           $
          (NOT keyword_set(noselect)) THEN BEGIN 
            oplot, (*(*env).groups[group].data[i].x)[select_index],   $
              (*(*env).groups[group].data[i].y)[select_index],          $
              psym=4, color = select_color, _EXTRA=ex
        ENDIF 
        
        ;; change color if some given:
        IF keyword_set(distinct) THEN color = color - delta_color

        ;; wrap around if too much colors:
        IF color LT 0 THEN  color = color + 255

    ENDFOR
        
END





