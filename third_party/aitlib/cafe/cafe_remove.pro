PRO cafe_remove, env, subgroup, group, help=help, shorthelp=shorthelp
;+
; NAME:
;           remove
;
; PURPOSE:
;           Removes data set in group/subgroup
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           remove, subgroup [, group]
;
; INPUTS:
;           subgroup - Defines the subgroup to remove. This can be
;                      either the subgroup number, a list of subgroups
;                      within brackets ([]) or the file name of
;                      the subgroup. Wildcards ("*") for file names are
;                      allowed to remove more than one subgroup.
;
;           group    - (optional) Define the data group to remove the
;                      data from. Default is the primary group 0. Must
;                      be in range [0..29]. 

;
; SIDE EFFECTS:
;           Removes all stored data for given subgroup. 
;
; EXAMPLE:
;
;               > remove, "test.dat", 1
;               -> removes data from file "test.dat" from internal storage.
;
; HISTORY:
;           $Id: cafe_remove.pro,v 1.6 2003/03/17 14:11:35 goehler Exp $
;             
;-
;
; $Log: cafe_remove.pro,v $
; Revision 1.6  2003/03/17 14:11:35  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2003/02/27 09:45:26  goehler
; replaced fixed max group number by variable one
;
; Revision 1.3  2002/09/09 17:36:10  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="remove"

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
      cafereport,env, "remove   - removes data from internal storage"
      return
  ENDIF



  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; define default group
  IF n_elements(group) EQ 0 THEN group = (*env).def_grp

  ;; check boundary:
  IF (group GT n_elements((*env).groups[*])-1) OR (group LT 0)  THEN BEGIN 
      cafereport,env, "Error: invalid group number"
      return
  ENDIF


  ;; define default subgroup(s) -> all subgroups
  IF n_elements(subgroup) EQ 0 THEN $
    subgroup = indgen(n_elements((*env).groups[group].data))


  ;; subgroup given as string -> look for matching file:
  IF ((SIZE(subgroup))[0] EQ 0 ) AND ((SIZE(subgroup))[1] EQ 7) THEN BEGIN  
      
      ;; look for subgroups containing this string:
      subgroup = where(strmatch((*env).groups[group].data[*].file,subgroup))

      IF subgroup[0] EQ  -1 THEN BEGIN 
          cafereport,env, "Error: Subgroup file not found"
          return
      ENDIF
        
  ENDIF         
    
  ;; check boundary:
  IF (where(subgroup GE n_elements((*env).groups[group].data) $
            OR (subgroup LT 0)))[0] NE -1  THEN BEGIN 
      cafereport,env, "Error: invalid subgroup(s)"
      return
  ENDIF



  ;; put this array in heap:
  FOR i = 0, n_elements(subgroup)-1 DO BEGIN

      ;; select subgroup:
      sg = subgroup[i]


      ;; free data:
      PTR_FREE, (*env).groups[group].data[sg].x
      PTR_FREE, (*env).groups[group].data[sg].y 
      PTR_FREE, (*env).groups[group].data[sg].err 
      PTR_FREE, (*env).groups[group].data[sg].def 
      
      ;; remove title
      (*env).groups[group].data[sg].file = ""

  ENDFOR 


  RETURN  
END

