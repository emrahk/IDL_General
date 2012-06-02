PRO cafe_plotout_ps, env, file,                      $
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
;           ps
;
; PURPOSE:
;           Plot out to postscript file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           plotout
;
; PLOT FORMAT:
;           Uses current plot settings to print out to postscript
;           file. Start color will be set at 0, so foreground color
;           will become black, because background usually is white. 
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
;           into a single file. 
;
; EXAMPLE:
;
;               > plotout, view.ps[color]
;               -> plots to file "view.ps", using standard postscript
;               format, and colors. 
;
; HISTORY:
;           $Id: cafe_plotout_ps.pro,v 1.5 2003/03/17 14:11:34 goehler Exp $
;             
;-
;
; $Log: cafe_plotout_ps.pro,v $
; Revision 1.5  2003/03/17 14:11:34  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/11 14:35:38  goehler
; updated plotout for multiple plots. tested.
;
; Revision 1.3  2003/03/10 16:43:17  goehler
; change of plotout: use own version of open_print.
; future change: multiple prints into single file. Still not working.
;
; Revision 1.2  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.1  2002/09/10 16:42:37  goehler
; plotout enhancement by adding subtask functionality
;

    ;; command name of this source (needed for automatic help)
    name="plotout_ps"

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
        print, "ps       - postscript plot driver"
        return
    ENDIF


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
    ;; CLOSE PLOT FILE ON REQUEST AND LEAVE
    ;; ------------------------------------------------------------

    IF keyword_set(close) THEN BEGIN ;  must close device -> do so    

        ;; disable postscript device:
        set_plot,'PS'               
        device,/close

        ;; restore former device:
        set_plot,savedevice

        ;; restore plot options:
        (*env).plot = plotstore

        ;; leave now!
        return
    ENDIF         



    
    ;; ------------------------------------------------------------
    ;; OPEN PLOT DEVICE
    ;; ------------------------------------------------------------


    ;; write to postscript file anyway:
    set_plot,'PS'               

    ;; actually open plot file:
    IF keyword_set(open) THEN BEGIN       

        ;; adjust device:
        device,landscape=landscape, encapsulated=0, color=color, $
          xsize=scale*xsize,ysize=scale*aspect*xsize,            $
          bits_per_pixel=8,                                      $
          filename=file,times=times,inches=0,helvet=helvetica,   $
          xoffset=xoffset, yoffset=yoffset,font_size=fontsize                      
    
        ;; set iso latin character set -> allow angstroem etc. 
        device,/isolatin1
        
    ENDIF 

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
   
    ;; now use former device
    set_plot, savedevice
    
    ;; restore plot options:
    (*env).plot = plotstore
        
    ;; restore font:
    !P.FONT=savefont

    ;; ------------------------------------------------------------
    ;; INFORMATION ABOUT PLOT WHEN APPENDED
    ;; ------------------------------------------------------------
    IF NOT keyword_set(open) THEN $
      cafereport,env, "Append plot at: "+file
END 



