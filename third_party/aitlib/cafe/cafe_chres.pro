PRO cafe_chres, env, group, help=help, shorthelp=shorthelp
;+
; NAME:
;           chres
;
; PURPOSE:
;           Change group for results
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           chres, [<group>]
;
; INPUTS:
;           group - Number identifying the group to where
;                   transformation results are stored at.
;                   Must not exceed maximal group number (29).
;                   The result group may also be one of the two strings:
;                    - "next" - increase the group number by one
;                    - "prev" - decrease the group number by one
;                    (in both cases ranges will be checked).
;
;                    If the group number is negative or not given the next free
;                    group will be used. 
;
; SIDE EFFECTS:
;           Changes result group.
;
; EXAMPLE:
;           > chgres, 7
;               -> new result group: 7
;
; HISTORY:
;           $Id: cafe_chres.pro,v 1.1 2003/05/06 13:17:38 goehler Exp $
;-
;
; $Log: cafe_chres.pro,v $
; Revision 1.1  2003/05/06 13:17:38  goehler
; - added result group which can be set with chres
; - added global setup information which can be used by certain
;   data processing commands.
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="chres"

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
      cafereport,env, "chres    - change result group"
      return
  ENDIF

  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; set group if none given. We change the group when the former one
  ;; was negative.
  IF n_elements(group) EQ 0 THEN group = (*env).res_grp

  ;; ------------------------------------------------------------
  ;; DYNAMIC GROUP SEARCH: USE NEXT FREE GROUP
  ;; ------------------------------------------------------------


  ;; negative group -> look for next free:
  IF group LT 0 THEN BEGIN 

      FOR group=0, n_elements((*env).groups)-1 DO BEGIN 
          
          ;; skip groups with model:
          IF (*env).groups[group].model NE "" THEN CONTINUE
          
          ;; check all subgroups, build y/error array
          FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 
              
              ;; break if data subgroup found -> group is not free
              IF PTR_VALID((*env).groups[group].data[subgroup].y)  THEN BREAK
          ENDFOR 

          ;; no subgroup found -> we finished search.
          IF  subgroup EQ n_elements((*env).groups[group].data) THEN BREAK 
      ENDFOR
  ENDIF 



  ;; ------------------------------------------------------------
  ;; INCREMENT/DECREMENT SUPPORT
  ;; ------------------------------------------------------------
  
  IF strtrim(string(group),2) EQ "next" THEN BEGIN
      group = ((*env).res_grp+1) < (n_elements((*env).groups)-1)
  ENDIF 

  IF strtrim(string(group),2) EQ "prev" THEN BEGIN
      group = ((*env).res_grp-1) > 0
  ENDIF 

  ;; ------------------------------------------------------------
  ;; CHECK BOUNDARY
  ;; ------------------------------------------------------------

  IF group GE n_elements((*env).groups)  THEN BEGIN 
      cafereport,env, "Error: invalid group number"
      return
  ENDIF


  ;; ------------------------------------------------------------
  ;; CHANGE GROUP
  ;; ------------------------------------------------------------
  
  (*env).res_grp = group

  cafereport,env, "RESULT GROUP: "+ strtrim(string(group),2)

  RETURN  
END

