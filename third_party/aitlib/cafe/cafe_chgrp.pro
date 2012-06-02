PRO cafe_chgrp, env, group, help=help, shorthelp=shorthelp
;+
; NAME:
;           chgrp
;
; PURPOSE:
;           Change default group
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           chgrp, <group>
;
; INPUTS:
;           group - Number identifying the group to change to for all
;                   default cases. Must not exceed maximal group
;                   number [0..29]. 
;                   The group may also be one of the two strings:
;                    - "next" - increase the group number by one
;                    - "prev" - decrease the group number by one
;                    (in both cases ranges will be checked).
;
; SIDE EFFECTS:
;           Changes default group.
;
; EXAMPLE:
;           > chgrp, 7
;               -> new default group: 7
;
; HISTORY:
;           $Id: cafe_chgrp.pro,v 1.4 2003/03/17 14:11:27 goehler Exp $
;-
;
; $Log: cafe_chgrp.pro,v $
; Revision 1.4  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.3  2003/03/03 11:18:21  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.2  2002/09/09 17:36:01  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="chgrp"

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
      cafereport,env, "chgrp    - change default group"
      return
  ENDIF


  ;; ------------------------------------------------------------
  ;; INCREMENT/DECREMENT SUPPORT
  ;; ------------------------------------------------------------
  
  IF strtrim(string(group),2) EQ "next" THEN BEGIN
      group = ((*env).def_grp+1) < (n_elements((*env).groups)-1)
  ENDIF 

  IF strtrim(string(group),2) EQ "prev" THEN BEGIN
      group = ((*env).def_grp-1) > 0
  ENDIF 

  ;; ------------------------------------------------------------
  ;; CHECK BOUNDARY
  ;; ------------------------------------------------------------

  IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
      cafereport,env, "Error: invalid group number"
      return
  ENDIF


  ;; ------------------------------------------------------------
  ;; CHANGE GROUP
  ;; ------------------------------------------------------------
  
  (*env).def_grp = group

  cafereport,env, "NEW GROUP: "+ strtrim(string(group),2)

  RETURN  
END

