PRO cafe_reset, env, help=help, shorthelp=shorthelp
;+
; NAME:
;           reset
;
; PURPOSE:
;           Resets environment into initial state. Usefull for
;           testing. 
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           reset
;
;
; SIDE EFFECTS:
;           Removes all stored data (!).
;
; EXAMPLE:
;
;               > model,lin*const:5
;               > reset
;               -> all files/models/data/settings will be deleted. 
;
; HISTORY:
;           $Id: cafe_reset.pro,v 1.3 2002/09/09 17:36:10 goehler Exp $
;             
;-
;
; $Log: cafe_reset.pro,v $
; Revision 1.3  2002/09/09 17:36:10  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="reset"

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
      cafereport,env, "reset    - deletes all data from internal storage"
      return
  ENDIF


  ;; remove current settings
  cafeenv__cleanup,env

  ;; initialize new
  env=cafeenv__define()


  RETURN  
END

