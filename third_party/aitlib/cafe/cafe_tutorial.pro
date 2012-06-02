PRO  cafe_tutorial, env, tutorial,shorthelp=shorthelp
;+
; NAME:
;           tutorial
;
; PURPOSE:
;           runs a (more or less) interactive tutorial. 
;
; CATEGORY:
;           cafe 
;
; SYNTAX:
;           tutorial, [tour]
;
; INPUT:
;           tour - the tutorial to run. Use
;                  cafe> help,tutorial,all
;                  to display available tutorials.
;                  The default tour is "intro".
;           
;
; 
; SIDE EFFECTS:
;           Running a tutorial usually changes the environment
;           according the commands used in the tutorial. It is not
;           recomended to run a tutorial in-between a evaluation
;           session. 
;
;
; HISTORY:
;           $Id: cafe_tutorial.pro,v 1.3 2003/05/02 07:38:17 goehler Exp $
;-
;
; $Log: cafe_tutorial.pro,v $
; Revision 1.3  2003/05/02 07:38:17  goehler
; fix: apply /fullbatch option when executing tutorial files
;
; Revision 1.2  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.1  2003/02/18 16:48:47  goehler
; added tutorial command. For this the tutorial should be given as a
; script with interspearsed (IDL) commands. exec is now able to execute a single line
; and to disable echo with the "#" prefix.
;
;

    ;; name of this source (needed for automatic help)
    NAME="tutorial"

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
        cafereport,env, "tutorial - run a tutorial session"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------
    
    ;; tutorial-extension:
    extension=".cmd"

    ;; default tutorial
    IF n_elements(tutorial) EQ 0 THEN tutorial = "intro"

    t_file=file_which((*env).name+"_"+name+"_"+tutorial+extension)

    IF t_file EQ "" THEN BEGIN
        cafereport,env, "Error: tutorial file "+tutorial+" not found"
        return
    ENDIF 


    ;; ------------------------------------------------------------
    ;; RUN THE TUTORIAL
    ;; ------------------------------------------------------------

    cafe_exec,env,t_file,/fullbatch

  RETURN  
END



