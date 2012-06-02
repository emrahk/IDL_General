PRO cafe_load, env, filename, filetype, help=help, shorthelp=shorthelp
;+
; NAME:
;           load
;
; PURPOSE:
;           Loads environment from file which was created with the
;           "save" command. 
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           load, filename[,filetype]
;
; INPUTS:
;           filename - (optional) String containing the file to load environment
;                      from. If file should not be loaded from the
;                      current working directory a path must be added.
;                      Default is "cafe.sav" (IDL save file)
;                                            
;           filetype - (optional) The file type to defining the method
;                      how to load the file. Usually derived from file
;                      extension, but this option overrides the
;                      file type of the extension.                     
;                      
;                      To get help about valid file types enter
;                      > help, load, all (for list of supported file types)
;                      and
;                      > help,load,<type> (for specific file type)
;
; SIDE EFFECTS:
;           Overwrites (!) all data/settings in current environment
;           without warning.
;
; EXAMPLE:
;           > load, session5.sav
;               -> loads environment data from IDL load file
;               "session5.sav" into current environment, using file type
;               "sav".  
;
; HISTORY:
;           $Id: cafe_load.pro,v 1.5 2003/03/17 14:11:30 goehler Exp $
;             
;-
;
; $Log: cafe_load.pro,v $
; Revision 1.5  2003/03/17 14:11:30  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/04 16:47:09  goehler
; - added file existence check
; - do not destroy entire environment to allow sloppy assignment.
;
; Revision 1.3  2002/09/09 17:36:04  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="load"

    ;; prefix for all data types:
    LOAD_PREFIX = "cafe_load_"

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
        print, "load     - store current state into file"
        return
    ENDIF    


    ;; ------------------------------------------------------------
    ;; SET DEFAULT FILE NAME
    ;; ------------------------------------------------------------


    IF n_elements(filename) EQ 0 THEN BEGIN 
        filename = "cafe.sav"
        cafereport,env, "Loading from: "+filename
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
    ;; CREATE FILE LIST AND CHECK EXISTENCE
    ;; ------------------------------------------------------------

    filelist = findfile(filename,count=filenum)

    ;; none found:
    IF filenum EQ 0 THEN BEGIN 
        cafereport,env, "Error: No file(s) found"
        return
    ENDIF 

    IF filenum GT 1 THEN BEGIN 
        cafereport,env, "Error: More than one matching file found"
        return
    ENDIF 

    ;; copy to file name:
    filename=filelist[0]


    ;; ------------------------------------------------------------
    ;; CLEAN UP CURRENT ENVIRONMENT
    ;; ------------------------------------------------------------

    cafe_reset,env


    ;; ------------------------------------------------------------
    ;; USE FILE TYPE TO FOR LOADING
    ;; ------------------------------------------------------------

    call_procedure, LOAD_PREFIX+filetype, env, filename
  

    RETURN  
END 
