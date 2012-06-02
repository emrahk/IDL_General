PRO cafe_data, env, filename, filetype,        $
               help=help, shorthelp=shorthelp, $
               interactive=interactive
;+
; NAME:
;           data
;
; PURPOSE:
;           Read in data set from fits/ascii file.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           data, filename["["parameter"]"][:group][,filetype][,/interactive]
;
; INPUTS:
;           filename - string containing the file to load into the
;                      program. If file is not at current working
;                      directory a path must be added.
;                      If the filename contains wildcards ("*", "?")
;                      it is possible to load more than one file at
;                      once. 
;                      
;           parameter- (optional) Passes parameters to the file type
;                      subtask defined either explicitely or via
;                      extension. These parameter usually define
;                      closer which columns to load. Parameters within
;                      the brackets are separated with ",".
;           
;           group    - (optional) Define the data group to add the
;                      data to (to support joint fitting). Default is
;                      the primary group 0. Must be in range [0..29].
;                      
;           filetype - (optional) The file type to defining the method
;                      (subtask) how to load the file. Usually derived
;                      from file extension, but this option overrides
;                      the file type of the extension.                      
;                      
;                      To get help about available file types enter
;                      > help, data,all (for list of supported file types)
;                      and
;                      > help,data,<type> (for specific file type)
; OPTIONS:
;        interactive - If multiple files given (wildcarded), ask
;                      before loading. 
;
; SIDE EFFECTS:
;           Loads file data to group/subgroup
;
; EXAMPLE:
;           > data, test.dat:1
;               -> loads in data from ascii file test.dat (type dat is
;                  ascii file) into group 1. 
;           > data, foo[time;rate]:5, fits
;               -> loads fits file foo (without extension) into group 5.
;                  Parameters are the column names time/rate.
;
; HISTORY:
;           $Id: cafe_data.pro,v 1.13 2003/04/25 07:32:57 goehler Exp $
;             
;-
;
; $Log: cafe_data.pro,v $
; Revision 1.13  2003/04/25 07:32:57  goehler
; updated documentation
;
; Revision 1.12  2003/04/15 07:43:57  goehler
; small fix: keyword ask -> interactive
;
; Revision 1.11  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.10  2003/03/13 08:49:15  goehler
; changed parameter handling (bound to filename)
;
; Revision 1.9  2003/03/04 16:45:28  goehler
; interactive question for multiple files added.
;
; Revision 1.8  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2003/02/27 09:45:26  goehler
; replaced fixed max group number by variable one
;
; Revision 1.6  2002/09/20 09:52:45  goehler
; - data now handles more than one file
; - file type dat now faster
; - added 2-d data input types
;
; Revision 1.5  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="data"

    ;; prefix for all data types:
    DATA_PREFIX = "cafe_data_"

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
        print, "data     - read in data from file"
        return
    ENDIF
    


    ;; ------------------------------------------------------------
    ;; GET GROUP/SUBGROUP:
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
    ;; CREATE FILE LIST AND CHECK EXISTENCE
    ;; ------------------------------------------------------------

    filelist = findfile(filename,count=filenum)

    IF filenum EQ 0 THEN BEGIN 
        cafereport,env, "Error: No file(s) found"
        return
    ENDIF 


    ;; ------------------------------------------------------------
    ;; LOAD FILES
    ;; ------------------------------------------------------------

    FOR i = 0, filenum-1 DO BEGIN 

        ;; ------------------------------------------------------------
        ;; ASK IF MORE THAN ONE TO LOAD
        ;; ------------------------------------------------------------
        input=""       
        IF filenum GT 1 AND  keyword_set(interactive) THEN BEGIN 
            caferead,env,input,prompt="Load file: "+ filelist[i]+"? "
            
            ;; skip?
            IF strupcase(input) EQ 'N' THEN CONTINUE             
        ENDIF 

        ;; ------------------------------------------------------------
        ;; LOOK FOR NEXT FREE SUBGROUP
        ;; ------------------------------------------------------------

        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO $
          IF NOT PTR_VALID((*env).groups[group].data[subgroup].x)  THEN BREAK

        IF subgroup GE n_elements((*env).groups[group].data) THEN BEGIN 
            cafereport,env, "Error: maximal subgroup number expired"
            return
        ENDIF

        ;; ------------------------------------------------------------
        ;; USE FILE TYPE TO LOAD DATA
        ;; ------------------------------------------------------------

        CALL_PROCEDURE, DATA_PREFIX+filetype,env, filelist[i], $
                        group, subgroup,    filetypeparam
  
    ENDFOR 

    RETURN  
END

