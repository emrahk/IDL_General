PRO cafe_import, env, x, y, err, importname, group, help=help, shorthelp=shorthelp
;+
; NAME:
;           import
;
; PURPOSE:
;           Imports data from IDL variables.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           import, (x), (y) [,(error)][,importname][,group]
;
; INPUTS:
;           x   - Variable name for the independent values. Should be an array
;                 of double.
;           y   - Variable name for the dependent values. Should be an array
;                 of double.
;         error - Variable name for error values. Should be an array
;                 of double. If not given the error is set at 1.           
;                 
;          All Variables should have the same number of elements
;          because they represent a tuple for the measure points.
;
;    importname  - (optional) Defines a name to store the data in
;                  (used instead of a  filename). Default is "<import>".
;
;          group - (optional) Defines the group to load data into.
;
; DESCRIPTIONS:
;
;          Import is mainly intended as an interface to import data
;          from IDL or to read data which is not structured as a
;          simple file.
;          To use this command IDL variables must be defined
;          before. This could only be done by executing a IDL command
;          within the fit environment (because the environment runs in
;          a procedure which passes no variables).
;          These IDL commands must be preceded with a "!".
;
;          The parentheses are necessary because otherwise the
;          variables are taken as strings. 
;
; SIDE EFFECTS:
;           Loads data to group/subgroup
;
; EXAMPLE:
;
;               > ! time = readfits("time.fits")
;               > ! rate = readfits("rate.fits")
;               > ! error= sqrt(rate)
;               > import,(time),(rate),(error),test,2 -> loads data into group 2,
;                                             next free subgroup.
;
; HISTORY:
;           $Id: cafe_import.pro,v 1.11 2003/05/09 14:50:08 goehler Exp $
;             
;-
;
; $Log: cafe_import.pro,v $
; Revision 1.11  2003/05/09 14:50:08  goehler
;
; updated documentation in version 4.1
;
; Revision 1.10  2003/03/17 14:11:29  goehler
; review/documentation updated.
;
; Revision 1.9  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.8  2003/02/19 07:30:33  goehler
; updated documentation
;
; Revision 1.7  2003/02/11 07:35:42  goehler
; allow multi-dimension import also
;
; Revision 1.6  2002/09/09 17:36:04  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="import"


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
        print, "import   - read in data from IDL"
        return
    ENDIF
    


    ;; ------------------------------------------------------------
    ;; GET GROUP/SUBGROUP:
    ;; ------------------------------------------------------------
    
    ;; define default group
    IF n_elements(group) EQ 0 THEN group = (*env).def_grp
        
    ;; check boundary:
    IF (group GT n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid group number"
        return
    ENDIF
      

    ;; look for next free subgroup:
    FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO $
      IF NOT PTR_VALID((*env).groups[group].data[subgroup].x)  THEN BREAK

    IF subgroup GE n_elements((*env).groups[group].data) THEN BEGIN 
        cafereport,env, "Error: maximal subgroup number expired"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; CHECK
    ;; ------------------------------------------------------------

    ;; set up sizes:
    n_x = n_elements(x)
    n_y = n_elements(y)
    n_err = n_elements(err)

    ;; check existence:
    IF (n_x EQ 0) OR (n_y EQ 0) THEN BEGIN 
        cafereport,env, "Error: no x/y data supplied"
        return
    ENDIF 


    ;; check size:
    IF (n_x NE n_y)   THEN BEGIN 
        cafereport,env, "Warning: Data sizes differ."
    ENDIF 

    ;; define name to be set:
    IF n_elements(importname) EQ 0 THEN importname = '<imported>'


    ;; ------------------------------------------------------------
    ;; IMPORT DATA
    ;; ------------------------------------------------------------

    sort_index=sort(x[*,0])
      
    (*env).groups[group].data[subgroup].x = PTR_NEW(x[sort_index,*]) 
    (*env).groups[group].data[subgroup].y = PTR_NEW(y[sort_index]) 

    ;; add error if existing
    IF (n_elements(err) NE 0) THEN $
      IF strtrim(string(err[0]),2) NE "" THEN $ 
      (*env).groups[group].data[subgroup].err = PTR_NEW(err[sort_index]) 

    (*env).groups[group].data[subgroup].file = importname

    ;; allocate defined measure point array (default all defined):
    (*env).groups[group].data[subgroup].def = $
      PTR_NEW(bytarr(n_elements(sort_index),/nozero)) 
    (*(*env).groups[group].data[subgroup].def)[*]=1

    ;; allocate selected point array (none selected):
    (*env).groups[group].data[subgroup].selected = PTR_NEW(bytarr(n_elements(sort_index),/nozero)) 
    (*(*env).groups[group].data[subgroup].selected)[*]=0

    ;; ------------------------------------------------------------
    ;; STATUS REPORT
    ;; ------------------------------------------------------------
    
    cafereport,env,"  Group:    "+strtrim(string(group),2) 
    cafereport,env,"  Subgroup: "+strtrim(string(subgroup),2) 
    cafereport,env,"  Datapoints: " +strtrim(string(n_elements(x)),2)
    RETURN  
END





