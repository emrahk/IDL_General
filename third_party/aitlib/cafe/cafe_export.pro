PRO cafe_export, env, filename, filetype, help=help, shorthelp=shorthelp, clobber=clobber
;+
; NAME:
;           export
;
; PURPOSE:
;           Write out data set to ascii/fits file.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           export, filename["["parameter"]"][:group][,filetype][,/clobber]
;
; INPUTS:
;           filename - string containing the file to save into the
;                      data. If file is not in current working
;                      directory a path must be added.
;                      
;           parameter- (optional) Passes parameters to the file type
;                      processor defined either explicitely or via
;                      extension. These parameter usually define
;                      closer some descriptions.
;                      Parameters within the brackets are separated
;                      with ",". 
;           
;           group    - (optional) Define the data group to add the
;                      data to (to support joint fitting). Default is
;                      the primary group 0. Must be in range [0..29].
;                      
;           filetype - (optional) The file type to defining the method
;                      how to save the file. Usually derived from file
;                      extension, but this option overrides the
;                      file type of the extension.                     
;                      
;                      To get help about valid file types enter
;                      > help, export,all (for list of supported file types)
;                      and
;                      > help,export,<type> (for specific file type)
; OPTIONS:
;            clobber - If file exists it will be overridden without question.  
;
; SIDE EFFECTS:
;           Saves data into file.
;
; EXAMPLE:
;           > export, test.dat:1
;               -> saves data to ascii file test.dat (type dat is
;                  ascii file) from group 1. 
;
; HISTORY:
;           $Id: cafe_export.pro,v 1.1 2003/04/15 09:27:10 goehler Exp $
;             
;-
;
; $Log: cafe_export.pro,v $
; Revision 1.1  2003/04/15 09:27:10  goehler
; new facility to write data to file
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="export"

    ;; prefix for all data types:
    EXPORT_PREFIX = "cafe_export_"

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
        print, "export   - write data to file"
        return
    ENDIF
    


    ;; ------------------------------------------------------------
    ;; GET GROUP:
    ;; ------------------------------------------------------------
    
    ;; define default group
    group = (*env).def_grp
    
    fileitems=stregex(filename,           $
                       "^((.*/)?"+          $   ; optional path
                       "[^.:]+)"+        $   ; file name
                      "(\.([a-zA-Z]+)" +  $   ; optional file type
                       "(\[(.+)\])?"   +  $   ; optional file type parameter
                      ")?"+               $ 
                      "(:([0-9]+))?$",    $   ; group number 
                      /extract,/subexpr)

  
    ;; filename = name+extension, no filetype information
    filename = fileitems[1]+"."+fileitems[4]

    
    ;; group = number after ":"
    IF fileitems[8] NE "" THEN group = fix(fileitems[8])
    
    ;; check boundary:
    IF (group GT n_elements((*env).groups[*])-1) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid group number"
        return
    ENDIF
      


    ;; ------------------------------------------------------------
    ;; DEFINE FILE TYPE/FILE TYPE OPTIONS:
    ;; ------------------------------------------------------------

    ;; type = extension without dot (if not defined separately)
    IF n_elements(filetype) EQ 0 THEN BEGIN 
        filetype = fileitems[4]
    ENDIF
        
    ;; file type parameter    
    filetypeparam = fileitems[6]
        

    ;; check file type:
    IF n_elements(filetype) EQ 0 THEN BEGIN 
        cafereport,env, "Error: undefined file type"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; CHECK FOR EXISTENCE
    ;; ------------------------------------------------------------

    dummy = findfile(filename,count=filenum)

    IF filenum NE 0 AND NOT keyword_set(clobber) THEN BEGIN 
        input = ""
        cafereport,env, "Warning: File "+filename+" already exists."
        caferead,env,input,prompt="Override? "
        IF strupcase(input) EQ 'N' THEN RETURN 
    ENDIF 


    ;; ------------------------------------------------------------
    ;; SAVE FILE
    ;; ------------------------------------------------------------



    CALL_PROCEDURE, EXPORT_PREFIX+filetype,env, filename, $
      group, filetypeparam
  


    RETURN  
END

