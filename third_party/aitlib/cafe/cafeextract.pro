PRO  cafeextract, env, x, y, err, range, subgroup, group
;+
; NAME:
;           cafeextract
;
; PURPOSE:
;           extracts data arrays according given range/subgroup/group
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;         cafeextract,env, x, y, err, range, subgroup, group
;
; INPUTS:
;
;           env      - Cafe environment to get data from.
;
;           range    - (optional) Defines range of data points to fold. This can
;                      be either:
;                       - Data point range, denoted by the data point number:
;                         <n1>[-<n2>], while <n1>, <n2> are positive
;                         numbers. Data point numbers start from zero. 
;                         Open intervals can be represented with a 
;                         "*" instead of the number.
;                         If only one number is given, a single
;                         data point will be modified. 
;                         If <val2> is less than <val1> all but the
;                         interval <val2>..<val1> is modified.  
; 
;                       - X value range, denoted by float point numbers:
;                         <val1>-<val2>,
;                         while <val1>, <val2> represents X values
;                         defining the interval to modify. Open
;                         intervals can be represented with a *
;                         instead of the value. If <val2> is less than
;                         <val1> all but the interval <val2>..<val1>
;                         is modified.
;
;                       - The "selected" identifier: This will take all
;                         data points which are marked as selected (with
;                         wplot/select command).
;                         
;                       - Boolean expressions with X/Y values. All
;                         values for which this expression is true are
;                         modified. The expression may contain
;                         algebraic formulas combined with comparison
;                         operators LT, LE, EQ, GT, GE as used in IDL
;                         comparisons. For data use the keywords "X"
;                         and "Y" to represent the x/y values.
;
;                      Default is the entire data set to fold.
;                      
;           subgroup - (optional) The data set (subgroup) for which the model
;                      should be applied. This can be either the
;                      subgroup number or the file name representing
;                      the data set. It is possible to set more than
;                      one subgroup, either with numbers in brackets
;                      ([]) separated with ","; or denoting filenames
;                      with wildcards ("*"). 
;                      Default are all subgroups in currently used
;                      group.                                                     
;                                                   
;
;           group    - (optional) The data group for which folding
;                      should applied.
;                      Default is the current group. Must be in
;                      range [0..29].                      
;
;                      
;                      
; OUTPUT:
;                  x - combined x value according
;                      range/def/subgroup/group specification.
;                      
;                  y - combined y value according
;                      range/def/subgroup/group specification.
;                      
;                 err- combined error value according
;                      range/def/subgroup/group specification.
;                      If subgroup does not contain error this
;                      variable remains undefined.
;
; SIDE EFFECTS:
;           None. 
;
; EXAMPLE:
;           > cafeextract,x,y,err
;           > pfold,x,y,profile
;
; HISTORY:
;           $Id: cafeextract.pro,v 1.3 2003/05/08 10:05:48 goehler Exp $
;-
;
; $Log: cafeextract.pro,v $
; Revision 1.3  2003/05/08 10:05:48  goehler
; fix: recognize error existence properly
;
; Revision 1.2  2003/05/06 16:20:06  goehler
; bug fix: extract defined points only
;
; Revision 1.1  2003/05/06 13:19:01  goehler
; initial version of extractor function which returns for given range/subgroup/group
; a full data list.
;
;
;
;


    ;; ------------------------------------------------------------
    ;; SET GROUP/SUBGROUP 
    ;; ------------------------------------------------------------


    ;; define default group
    IF n_elements(group) EQ 0 THEN group = (*env).def_grp

    ;; check boundary:
    IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid group number"
        return
    ENDIF


    ;; define default subgroup -> all subgroups
    IF n_elements(subgroup) EQ 0 THEN subgroup = "*"


    ;; subgroup given as string -> look for matching file:
    IF ((SIZE(subgroup))[0] EQ 0 ) AND ((SIZE(subgroup))[1] EQ 7) THEN BEGIN  

        ;; look for subgroups containing this string:
        subgroup = where(strmatch((*env).groups[group].data[*].file,subgroup))

        IF subgroup[0] EQ  -1 THEN BEGIN 
            cafereport,env, "Error: No subgroup file found"
            return
        ENDIF        
    ENDIF         
    
    ;; check boundary:
    IF (where(subgroup GE n_elements((*env).groups[group].data) $
              OR (subgroup LT 0)))[0] NE -1  THEN BEGIN 
        cafereport,env, "Error: invalid subgroup(s)"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; MAKE SHURE RANGE IS STRING (may be integer/float):
    ;; ------------------------------------------------------------

    IF n_elements(range) EQ 0 THEN range = "*"

    range=strtrim(string(range),2)
    


    ;; ------------------------------------------------------------
    ;; FOR EACH SUBGROUP -> SUM UP DATA POINTS
    ;; ------------------------------------------------------------


    ;; dummy input values
    x = 0.D0
    y = 0.D0
    error=0.D0

    ;; for each subgroup:
    FOR i =0,n_elements(subgroup)-1 DO BEGIN 

        ;; select subgroup:
        sg = subgroup[i]

        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE        
          

        ;; index of selected range:
        index = caferange(env,range,group,sg)

        ;; next if no data points:
        IF index[0] EQ -1 THEN CONTINUE

        ;; index of defined data points:
        defindex = where((*(*env).groups[group].data[sg].def)[index])

        ;; next if no data points:
        IF defindex[0] EQ -1 THEN CONTINUE

        ;; index of defined range:
        index = index[defindex]

        ;; next if no data points:
        IF index[0] EQ -1 THEN CONTINUE

        ;; print subgroup information:
        cafereport,env, "Subgroup "+strtrim(string(sg),2)$
                     +"  ["+(*env).groups[group].data[sg].file+"]:"
        
        ;; build data arrays
        x = [x,(*(*env).groups[group].data[sg].x)[index]]
        y = [y,(*(*env).groups[group].data[sg].y)[index]]

        IF ptr_valid((*env).groups[group].data[sg].err) THEN $
          error = [error,(*(*env).groups[group].data[sg].err)[index]]        
    ENDFOR    

    ;; remove dummy element:
    IF n_elements(y) GT 1 THEN BEGIN 
        x = x[1:*]
        y = y[1:*]
    ENDIF 

    ;; look for number of error/y data points:
    IF n_elements(error) GT  n_elements(y) THEN err=error[1:*]
END 
