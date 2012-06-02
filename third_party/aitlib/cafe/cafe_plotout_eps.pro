PRO cafe_plotout_eps, env, file,                      $
                      color=color,                    $
                      landscape=landscape,            $
                      a4=a4,                          $
                      apj1col=apj1col,aa1col=aa1col,  $
                      aa2col=aa2col,aa14cm=aa14cm,    $
                      times=times,                    $
                      fontsize=fontsize,              $
                      xsize=xsize,ysize=ysize,        $
                      aspect=aspect,scale=scale,      $
                      open=open, close=close,         $
                      help=help, shorthelp=shorthelp
;+
; NAME:
;           eps
;
; PURPOSE:
;           Plot out to encapsulated postscript file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           plotout
;
; PLOT FORMAT:
;           Uses current plot settings to print out to encapsulated
;           postscript file. Start color will be set at 0, so
;           foreground color will become black, because background
;           usually is white.  
;
;
; KEYWORDS:
;             fontsize  - Size of font to use (in pt).
;             xsize     - Size in X-direction in cm.
;             ysize     - Size in Y-direction in cm.
;             aspect    - ratio of y/x. Default is 0.75.
;             scale     - Plots could be scaled up. Default is 1.
;             
; OPTIONS:
;             color     - plot out colorized.
;             landscape - plot out in landscape instead portrait
;                         format.
;             a4        - Plot ut in DIN A4 format. Landscape only.
;             apj1col   - Plot out for 1 column of ApJ. 
;             aa1col    - Plot out for 1 column of A&A. 
;             aa2col    - Plot out for 2 columns of A&A. 
;             aa14cm    - Plot out for full field of  A&A. 
;             times     - Use times font. Default is helvetia. 
;             
;               
; SIDE EFFECTS:
;           Plots current view into postscript file.
;
;           If the file is not changed multiple plot images are saved
;           into a numbered files. 
;
; EXAMPLE:
;
;               > plotout, graph.eps[color]
;               -> plots to file "graph.eps", using standard postscript
;               format, and colors. Repeating plotout will yield
;               "graph.eps", "graph1.eps", "graph2.eps"....
;
; HISTORY:
;           $Id: cafe_plotout_eps.pro,v 1.1 2003/03/11 14:36:56 goehler Exp $
;             
;-
;
; $Log: cafe_plotout_eps.pro,v $
; Revision 1.1  2003/03/11 14:36:56  goehler
; initial version for plotout of eps files (to different files)
;
;

    ;; command name of this source (needed for automatic help)
    name="plotout_eps"

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
        print, "eps      - encapsulated postscript plot driver"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    fileitems=stregex(file,               $
                      "^((.*/)?"+         $ ; optional path
                      "[^.]+)"+           $ ; file name
                      "(\.([a-zA-Z]+))?", $
                      /extract,/subexpr)
    filechunk = fileitems[1]
    fileext   = fileitems[3]


    ;; ------------------------------------------------------------
    ;; CLOSE FILE - NOTHING TO DO
    ;; ------------------------------------------------------------

    IF keyword_set(close) THEN return 
    

    ;; ------------------------------------------------------------
    ;; OPEN FILE - REMOVE FORMER SET
    ;; ------------------------------------------------------------

    IF keyword_set(open) THEN BEGIN ;; remove former list of files:

        ;; list of filename plus number:
        filelst1 = findfile(filechunk+"???"+fileext)

        ;; file existing -> must delete it:
        IF (findfile(file))[0] NE "" THEN BEGIN 
            IF filelst1[0] NE "" THEN   $ ; also numbered files found ->
              filelst = [file,filelst1] $ ; add them to list
            ELSE                        $
              filelst = file              ; otherwise sole filename
        ENDIF ELSE BEGIN                  ; file not found -> use numbered files only
            filelst = filelst1
        ENDELSE 

        ;; some found -> delete them:
        IF filelst[0]  NE "" THEN BEGIN 
            file_delete, filelst
        ENDIF 
    ENDIF         


    ;; ------------------------------------------------------------
    ;; CREATE FILE NAME 
    ;; ------------------------------------------------------------

    ;; create nominal file:
    filestr = file

    ;; create new file name:
    i = 0
    WHILE (findfile(filestr))[0] NE "" DO BEGIN 
        filestr = filechunk+string(i,format="(I3.3)")+fileext
        i = i+1
    ENDWHILE

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------


    ;; save current plot options:
    plotstore=(*env).plot

    ;; save current font:
    savefont = !P.FONT

    ;; save current device:
    savedevice = !D.NAME
    
    ;; set default first color -> 0:
    cafe_setplot,env,"startcolor=0"
    
    ;; no color option -> do not change anything:
    IF NOT keyword_set(color) THEN cafe_setplot,env,"deltacolor=0"

    ;; must unset landscape explizitely to avoid strange features:
    IF NOT keyword_set(landscape) THEN landscape=0


    ;; default x size:
    IF (n_elements(xsize) EQ 0) THEN BEGIN 
        xsize=17.78 ;; idl default value
        
        ;; default y size:
        IF (n_elements(ysize) EQ 0 AND n_elements(aspect) EQ 0) THEN BEGIN 
            aspect=12.700/17.780 ;; default IDL value
        ENDIF 
    ENDIF 

    ;; default scaling is 1:1
    IF (n_elements(scale) EQ 0) THEN scale=1.

    ;; a4 is tricky -> must set explizitely:
    IF (keyword_set(a4)) THEN BEGIN 
        
        ;; compute absolute size of a4:
        a4_xsize=29.8 
        aspect=21.1/a4_xsize

        ;; always landscape (?)
        landscape=1

        ;; add margins:
        margin = 2.             ;cm
        xsize = a4_xsize - 2.*margin      

        ;; shift this properly (IDL can't do it itself)
        xoffset=aspect*margin
        yoffset= a4_xsize-margin ;-)      
    ENDIF 
    
    ;; default aspect ratio is almost 1:sqrt(2)
    IF (n_elements(aspect) EQ 0) THEN aspect=0.75

    ;; default font size -> 12 pt:
    IF (n_elements(fontsize) EQ 0) THEN fontsize=12.

    ;; default font is helvetica:
    IF NOT keyword_set(times) THEN helvetica=1

    ;; settings for apj single column:
    IF (keyword_set(apj1col)) THEN BEGIN 
        xsize=8 & times=1
        fontsize=10.
        scale=xsize*12./fontsize
    ENDIF 

    ;; A&A, 1column
    IF (keyword_set(aa1col)) THEN BEGIN 
        xsize=8.8 & times=1
        fontsize=9. ;; same size as caption

        scale=12./fontsize
    ENDIF 

    ;; A&A, 2column
    IF (keyword_set(aa2col)) THEN BEGIN 
        xsize=17. & times=1
        fontsize=9.
        
        scale=12./fontsize
    ENDIF 

    ;; A&A 14cm wide plot, caption at low right corner
    IF (keyword_set(aa14cm)) THEN BEGIN 
        xsize=14. & times=1
        fontsize=9.
        scale=12./fontsize
    ENDIF 
    
    
    ;; ------------------------------------------------------------
    ;; OPEN PLOT DEVICE
    ;; ------------------------------------------------------------


    ;; write to postscript file anyway:
    set_plot,'PS'               


    ;; adjust device:
    device,landscape=landscape, color=color,                 $
           xsize=scale*xsize,ysize=scale*aspect*xsize,            $
           bits_per_pixel=8,                                      $
           filename=filestr,times=times,inches=0,helvet=helvetica,   $
           xoffset=xoffset, yoffset=yoffset,font_size=fontsize,   $
           /encapsulated
    
    
    ;; set iso latin character set -> allow angstroem etc. 
    device,/isolatin1
           
    ;; use system font (helvetica or times)
    !p.font=0
    

    ;; ------------------------------------------------------------
    ;; PERFORM PLOTTING 
    ;; ------------------------------------------------------------
    
    ;; plot out what is shown
    cafe_plot,env,/quiet
        

    ;; ------------------------------------------------------------
    ;; RESTORE FORMER STATE 
    ;; ------------------------------------------------------------
    
    set_plot,'PS'               
    device,/close

    ;; now use former device
    set_plot, savedevice
    
    ;; restore plot options:
    (*env).plot = plotstore
        
    ;; restore font:
    !P.FONT=savefont

    ;; ------------------------------------------------------------
    ;; INFORMATION
    ;; ------------------------------------------------------------

    cafereport,env, "Saved plot in: "+filestr
END 

