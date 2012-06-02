PRO  cafe_plotout, env,                                    $
                   file,                                 $
                   driver,                               $
                   clobber=clobber,                      $
                   _EXTRA=ex,                            $                     
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           plotout
;
; PURPOSE:
;           creates hardcopy of last plot 
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           plotout, [file["["param"]"]], [,filetype][,/clobber]
;
; INPUT:
;           file     - the file name the plot will be sent to. From its
;                      extension the filetype will be derived.
;                      
;                      If no file given either the last file will be
;                      used as plot file. In this case it will be
;                      tried to "append" the plots.
;                      If there is no former file the default
;                      "cafe.ps" will be used.
;
;                      If the file name is "none" the last file will
;                      be closed (so there could not be appended
;                      anything). 
;
;           filetype - Possibility to coerce a certain file
;                      type. Available file types may be shown with
;                      > help, plotout, all
;
; OPTIONAL INPUT:
;           param    - Allow to send some parameters to the filetype
;                      handler.
;
; OPTIONS:
;          clobber   - Do not ask when overriding an existing plot file.
; 
;
; SIDE EFFECTS:
;           Switches device but restores window one. 
;
; EXAMPLE:
;               > plot, data,delchi, 2
;               > plotout, graph.ps, eps
;                -> plot data and chi of group 2 into eps file "graph.ps".
;
; HISTORY:
;           $Id: cafe_plotout.pro,v 1.10 2003/04/28 07:38:15 goehler Exp $
;-
;
; $Log: cafe_plotout.pro,v $
; Revision 1.10  2003/04/28 07:38:15  goehler
; moved parameter determination into separate function cafequotestr
;
; Revision 1.9  2003/03/17 14:11:34  goehler
; review/documentation updated.
;
; Revision 1.8  2003/03/11 14:35:38  goehler
; updated plotout for multiple plots. tested.
;
; Revision 1.7  2003/03/10 16:43:17  goehler
; change of plotout: use own version of open_print.
; future change: multiple prints into single file. Still not working.
;
; Revision 1.6  2003/03/10 09:02:06  goehler
; updated documentation
;
; Revision 1.5  2002/09/10 16:42:37  goehler
; plotout enhancement by adding subtask functionality
;
; Revision 1.4  2002/09/09 17:36:09  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="plotout"

    ;; prefix for all driver types:
    PLOT_PREFIX = "cafe_plotout_"

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
        cafereport,env, "plotout  - creates hardcopy of plot result"
        return
    ENDIF
    
    ;; ------------------------------------------------------------
    ;; SETUP OF OPEN/CLOSE
    ;; ------------------------------------------------------------
    
    ;; open file by default:
    open=1
    
    ;; do not close file when needed later:
    close = 0
    
    
    ;; ------------------------------------------------------------
    ;; LAST FILE/DEFAULT FILE IF NONE GIVEN:
    ;; ------------------------------------------------------------

    IF  n_elements(file) EQ 0 THEN BEGIN 
        
        ;; if still none given -> use "cafe.ps"
        IF (*env).plot.plotoutfile EQ "" THEN BEGIN 
            cafereport,env, "Using default file: cafe.ps"
            file = "cafe.ps"
        ENDIF ELSE BEGIN           
            open=0              ; already open
            file   = (*env).plot.plotoutfile ; use existing file/
            driver = (*env).plot.plotouttype ; driver
        ENDELSE 
    ENDIF ELSE BEGIN 
      
        ;; file given -> close last one:
        IF (*env).plot.plotoutfile NE "" THEN $
          close = 1       
    ENDELSE 
    
    
    ;; ------------------------------------------------------------
    ;; NONE FILE HANDLING:
    ;; ------------------------------------------------------------

    ;; close open files if "none" selected:
    IF file  EQ "none" THEN BEGIN 
        
        ;; nothing to close
        IF (*env).plot.plotoutfile EQ "" THEN  return 

        ;; otherwise -> mark as close action of last plotout type:
        close = 1
        
        ;; use last plotout type:
        driver = (*env).plot.plotouttype

        cafereport,env, "Plotting to file closed"
    ENDIF 


    ;; ------------------------------------------------------------
    ;; SET DRIVER
    ;; ------------------------------------------------------------

    ;; store full file string:
    filestr = file

    ;; extract parts of file:
    fileitems=stregex(file,               $
                      "^((.*/)?"+         $ ; optional path
                      "[^.]+)"+           $ ; file name
                      "(\.([a-zA-Z]+))?"+ $
                      "(\[(.+)\])?",      $ ; optional plot parameter
                      /extract,/subexpr)
        
    ;; file = path+file name:
    file = fileitems[1]+fileitems[3]
    
    ;; driver = extension without dot (if not defined separately)
    IF n_elements(driver) EQ 0 THEN driver = fileitems[4]
    
    IF driver EQ ""  THEN BEGIN 
        cafereport,env, "Error: undefined plot driver"
        return
    ENDIF
    


    ;; ------------------------------------------------------------
    ;; CLOSE PLOTTING USING DRIVER
    ;; ------------------------------------------------------------

    ;; close current file if needed:
    IF keyword_set(close) THEN BEGIN
        call_procedure,PLOT_PREFIX+driver,env, file,/close
    ENDIF  


    ;; nothing to plot -> quit now!
    IF file  EQ "none" THEN BEGIN 
        ;; delete plot file
        (*env).plot.plotoutfile = ""
        
        ;; that's it. Nothing to execute.
        return
    ENDIF 




    ;; ------------------------------------------------------------
    ;; CLOBBER
    ;; ------------------------------------------------------------

    IF (findfile(file))[0] NE ""              $ ;; file exists
      AND keyword_set(open)                   $ ;; and want to  open
      AND NOT keyword_set(clobber) THEN BEGIN   ;; and no automatic override ->
        ;; warning!
        input=""                    
        caferead,env,  input, prompt="Warning: File exists. Overwrite? [y/n]:"
        IF input EQ "n" THEN BEGIN 
            cafereport,env, "Plotting aborted."            
            RETURN
        ENDIF 
    ENDIF 
    

    ;; ------------------------------------------------------------
    ;; SAVE CURRENT FILE
    ;; ------------------------------------------------------------

    ;; save this file as last one
    (*env).plot.plotoutfile  = filestr    
    (*env).plot.plotouttype  = driver

    ;; ------------------------------------------------------------
    ;; PROCESS PLOT PARAMETERS
    ;; ------------------------------------------------------------


    ;; parameter = arguments in brackets
    plotparam = fileitems[6]
    
    ;; quote parameter strings:
    IF plotparam NE "" THEN BEGIN 
        plotparam =  ','+cafequotestr(plotparam,/keyvalpair)
    ENDIF 

;    debug only:
;    IF keyword_set(close) THEN print, "Closed"
;    IF keyword_set(open) THEN print, "Open"


    
    ;; ------------------------------------------------------------
    ;; PERFORM PLOTTING USING DRIVER
    ;; ------------------------------------------------------------

    IF NOT execute(  PLOT_PREFIX+driver +",env, file" $
                     +plotparam+",open=open") THEN BEGIN 
        cafereport,env,"Error:"+!ERR_STRING ; plotting failed
    ENDIF 
END 



