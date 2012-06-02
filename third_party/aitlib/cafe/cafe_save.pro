PRO cafe_save, env, filename, filetype, clobber=clobber, help=help, shorthelp=shorthelp
;+
; NAME:
;           save
;
; PURPOSE:
;           Saves environment into file.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           save, filename[,filetype][,/clobber]
;
; INPUTS:
;           filename - (optional) String containing the file to save environment
;                      into. If file should not be saved into the
;                      current working directory a path must be added.
;                      Default is "cafe.sav" (IDL save file)
;                                            
;           filetype - (optional) The file type to defining the method
;                      how to save the file. Usually derived from file
;                      extension, but this option overrides the
;                      file type of the extension.                     
;                      
;                      To get help about valid file types enter
;                      > help, save, all (for list of supported file types)
;                      and
;                      > help,save,<type> (for specific file type)
;
; OPTIONS:
;          clobber   - Do not ask when overwriting existing files.
;          
;
; SIDE EFFECTS:
;           Saves all data into file.
;
; EXAMPLE:
;
;               > save,daily.sav
;               -> saves environment data into IDL save file
;               "daily.sav", using file type "sav". 
;
; HISTORY:
;           $Id: cafe_save.pro,v 1.9 2003/04/24 09:48:24 goehler Exp $
;             
;-
;
; $Log: cafe_save.pro,v $
; Revision 1.9  2003/04/24 09:48:24  goehler
; moved saving report to driver procedures
;
; Revision 1.8  2003/03/10 09:56:26  goehler
; clobber must alse be set in procedure definition
;
; Revision 1.7  2003/03/10 09:55:24  goehler
; noclobber->clobber (inverted semantic!)
;
; Revision 1.6  2003/02/18 16:46:12  goehler
; added noclobber keyword
;
; Revision 1.5  2003/02/18 08:01:39  goehler
; bug fix: failed when override question
;
; Revision 1.4  2002/09/09 17:36:10  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="save"

    ;; prefix for all data types:
    SAVE_PREFIX = "cafe_save_"

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
        print, "save     - store current state into file"
        return
    ENDIF    


    ;; ------------------------------------------------------------
    ;; SET DEFAULT FILE NAME
    ;; ------------------------------------------------------------


    IF n_elements(filename) EQ 0 THEN filename = "cafe.sav"

    IF n_elements(filename) EQ 0 THEN BEGIN 
        filename = "cafe.sav"
        cafereport,env, "Saving to: "+filename
    ENDIF 


    ;; ------------------------------------------------------------
    ;; CLOBBER
    ;; ------------------------------------------------------------

    IF (findfile(filename))[0] NE "" AND NOT keyword_set(clobber) THEN BEGIN 

        input=""
        caferead,env,  input, prompt="Warning: File exists. Overwrite? [y/n]:"
        IF input EQ "n" THEN BEGIN 
            cafereport,env, "Saving aborted."            
            RETURN
        ENDIF 
    ENDIF 

    ;; ------------------------------------------------------------
    ;; SET FILE TYPE
    ;; ------------------------------------------------------------

    fileitems=stregex(filename,           $
                      "^((.*/)?"+         $ ; optional path
                      "[^.]+)"+           $ ; file name
                      "(\.([a-zA-Z]+))?", $ ; file type 
                      /extract,/subexpr)

    ;; type = extension without dot (if not defined separately)
    IF n_elements(filetype) EQ 0 THEN filetype = fileitems[4]
        
    IF (n_elements(filetype) EQ 0) OR (filetype EQ "")  THEN BEGIN 
        cafereport,env, "Error: undefined file type"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; USE FILE TYPE TO FOR SAVING
    ;; ------------------------------------------------------------

    call_procedure, SAVE_PREFIX+filetype, env, filename

    RETURN  
END 
