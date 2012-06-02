PRO cafe_log, env, logfile, help=help, shorthelp=shorthelp
;+
; NAME:
;           log
;
; PURPOSE:
;           Set/Change log file for cafe environment
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           log, logfilename[,/clobber]
;
; INPUTS:
;           logfilename - string defining log file. If empty existing
;                         log file will be closed. 
;           
; OPTIONS:
;           clobber   - Do not ask when overwriting existing files.
;          
;
; SIDE EFFECTS:
;           Closes existing log file and opens new one. 
;
;
; EXAMPLE:
;           cafe
;             cafe> log, foo.log
;             -> log file reporting all steps in "foo.log"
;
; HISTORY:
;           $Id: cafe_log.pro,v 1.2 2003/04/24 17:10:39 goehler Exp $
;-
;
; $Log: cafe_log.pro,v $
; Revision 1.2  2003/04/24 17:10:39  goehler
; fix: do not look for files which are not given. log without parameter closes log file.
;
; Revision 1.1  2003/04/23 13:57:04  goehler
; initial version
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="log"

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
        cafereport,env, "log      - set/change log file"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; CLOBBER
    ;; ------------------------------------------------------------

    IF n_elements(logfile) NE 0 THEN BEGIN     
        IF (findfile(logfile))[0] NE "" AND NOT keyword_set(clobber) THEN BEGIN 
            
            input=""
            caferead,env,  input, prompt="Warning: Log file exists. Overwrite? [y/n]:"
            IF input EQ "n" THEN BEGIN 
                cafereport,env, "Log setting aborted."            
                RETURN
            ENDIF 
        ENDIF 
    ENDIF 


    ;; ------------------------------------------------------------
    ;; CLOSE CURRENT LOG FILE:
    ;; ------------------------------------------------------------
    
    IF (*env).logfile_lun NE 0 THEN BEGIN 
        close, (*env).logfile_lun
        free_lun, (*env).logfile_lun
        (*env).logfile_lun = 0
        cafereport,env, "Current log file closed."
    ENDIF 


    ;; ------------------------------------------------------------
    ;; CREATE NEW LOG FILE:
    ;; ------------------------------------------------------------

    IF n_elements(logfile) NE 0 THEN BEGIN     
        get_lun, lun
        (*env).logfile_lun = lun
        openw, (*env).logfile_lun, logfile
        cafereport,env, "New log file: "+ logfile
    ENDIF


  RETURN  
END





