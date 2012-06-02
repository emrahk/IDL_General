PRO cafe_set, env, item, report=report, $
                  help=help, shorthelp=shorthelp
;+
; NAME:
;           set
;
; PURPOSE:
;           Change common setup parameter
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           set [, param[=value]][,/report]
;
; INPUTS:
;           param- The parameter to change. The parameter may be used
;                  by other commands as a predefined setup. 
;                        
;         value   - The value to set. This may be a number, a
;                   string (need not be enclosed in "") or a vector
;                   in brackets ([a,b,c]).
;                       
;                   Former settings of values will be overridden. 
;
;                   If the value is an empty string the entry will
;                   be deleted.  (e.g. set, nogap="" deletes the
;                   nogap entry). 
;                   If no value is given ("="  must be omitted) an existing
;                   parameter is removed from the setup list. If
;                   for missing values the parameter is not defined
;                   it will be set at 1.This allows simple settings of
;                   flags.
;                   Example:
;                      > set, nogap
;                       -> equals set,nogap=1 provided the setting
;                       "nogap" was still not defined.  
;                      
; OPTIONS:
;            /report - Report setting performed (usefull for log file).
;
;
; SIDE EFFECTS:
;           Changes setup string in environment.
;
; EXAMPLE:
;
;             > set, period=12100
;             > pfold
;              -> fold data set in current group with 12100.
;
; HISTORY:
;           $Id: cafe_set.pro,v 1.1 2003/05/06 13:17:39 goehler Exp $
;-
;
; $Log: cafe_set.pro,v $
; Revision 1.1  2003/05/06 13:17:39  goehler
; - added result group which can be set with chres
; - added global setup information which can be used by certain
;   data processing commands.
;
;
;

    ;; command name of this source (needed for automatic help)
    name="set"

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
    cafereport,env, "set     - change common setup"
    return
  ENDIF


  ;; no item given -> exit
  IF n_elements(item) EQ 0 THEN return



  ;; ------------------------------------------------------------
  ;; STORE ITEM
  ;; ------------------------------------------------------------


  (*env).setup = cafesetparam(item, (*env).setup)


  ;; report setting:
  IF keyword_set(report) THEN BEGIN 
      cafereport, env, "set, "+item,/nocomment,/silent
  ENDIF 



  RETURN  
END

