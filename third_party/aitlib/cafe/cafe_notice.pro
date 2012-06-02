PRO  cafe_notice, env, $
                  range, subgroup, group, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           notice
;
; PURPOSE:
;           explicitely allow data points for fit
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           notice, range [,subgroup][,group]
;
; INPUTS:
;           range    - Defines range of data points to notice. This can
;                      be either:
;                       - Data point range, denoted by the data point number:
;                         <n1>[-<n2>], while <n1>, <n2> are positive
;                         numbers. Data point numbers start from zero. 
;                         Open intervals can be represented with a 
;                         "*" instead of the number.
;                         If only one number is given, a single
;                         data point will be noticed. 
;                         If <val2> is less than <val1> all but the
;                         interval <val2>..<val1> is noticed.  
;                         Examples:
;                               > notice, 2
;                                -> notice data point 2 (the 3-rd)
;                               > notice, 5-22
;                                -> notice data points 5..22 (starting from 0)
;                               > notice 46-*
;                                -> notice all data points upwards
;                                from point 47.
;
;                       - X value range, denoted by float point numbers:
;                         <val1>-<val2>,
;                         while <val1>, <val2> represents X values
;                         defining the interval to notice. Open
;                         intervals can be represented with a *
;                         instead of the value. If <val2> is less than
;                         <val1> all but the interval <val2>..<val1>
;                         is noticed.
;                         Examples:
;                               > notice, 2.2-5.7
;                                -> notice all data points from x=2.2 to 5.7
;                               > notice, *-0.2
;                                -> notice all data points up to x=0.2
;                               > notice, 0.5-0.2
;                                -> notice all data points except those in 0.2..0.5.
;
;                       - The "selected" identifier: This will take all
;                         data points which are marked as selected (with
;                         wplot/select command).
;                         
;                       - Boolean expressions with X/Y values. All
;                         values for which this expression is true are
;                         noticed. The expression may contain
;                         algebraic formulas combined with comparison
;                         operators LT, LE, EQ, GT, GE as used in IDL
;                         comparisons. For data use the keywords "X"
;                         and "Y" to represent the x/y values.
;                         
;                         Multi dimensions are supported with "X1" for
;                         first column, "X2" with second and "X3" with
;                         third column. 
;                         Example:
;                               notice, Y LT 0.5
;                                -> notice all data points with
;                                    Y-values less than 0.5.                                                 
;           subgroup - (optional) The data set (subgroup) for which the model
;                      should be applied. This can be either the
;                      subgroup number or the file name representing
;                      the data set. 
;                      It is possible to set more than one subgroup,
;                      either with numbers in brackets ([]) or
;                      denoting filenames with wildcards ("*").  
;                      Default are all subgroups in current used
;                      group.                                                    
;
;           group    - (optional) The data group for which the model
;                      should be applied.
;                      Default is the primary group 0. Must be in
;                      range [0..29].                      
;
;
; SIDE EFFECTS:
;           Changes information about data points used for
;           fitting. Data points are not excluded. 
;
; EXAMPLE:
;           > notice, 0.2-7.5, 3, "test.dat"
;                 -> notice all x values between 0.2 and 7.5 from
;                    group 3, subgroup represented by file "test.dat"
;
; HISTORY:
;           $Id: cafe_notice.pro,v 1.7 2003/03/17 14:11:32 goehler Exp $
;-
;
; $Log: cafe_notice.pro,v $
; Revision 1.7  2003/03/17 14:11:32  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/19 14:02:38  goehler
; documentized
;
; Revision 1.4  2002/09/09 17:36:07  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="notice"

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
        cafereport,env, "notice   - allow datapoints for fitting"
        return
    ENDIF



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

    ;; define default subgroup -> first valid subgroup
    IF n_elements(subgroup) EQ 0 THEN BEGIN 
        subgroup = where((*env).groups[group].data[*].file NE "")
        subgroup = subgroup[0]
    ENDIF 


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



    ;; ------------------------------------------------------------
    ;; MAKE SHURE RANGE IS STRING (may be integer/float):
    ;; ------------------------------------------------------------

    range=strtrim(string(range),2)


    ;; ------------------------------------------------------------
    ;; NOTICE DATAPOINTS FOR EACH SUBGROUP
    ;; ------------------------------------------------------------

    ;; for each subgroup:
    FOR i =0,n_elements(subgroup)-1 DO BEGIN 
        
        ;; select subgroup:
        sg = subgroup[i]
        
        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE
        
        ;; print subgroup information:
        cafereport,env, "Subgroup "+strtrim(string(sg),2)$
                     +"  ["+(*env).groups[group].data[sg].file+"]:"
        
        index = caferange(env,range,group,sg)

        IF index[0] NE -1 THEN BEGIN 
            cafereport,env, " Allowing "                      $
                         +strtrim(string(n_elements(index)),2)  $
                         +" datapoints"
            cafereport,env, " from "                          $
                         +strtrim(string(index[0]),2)           $
                         +" to "                                $
                         +strtrim(string(index[n_elements(index)-1]),2)
            
            (*(*env).groups[group].data[sg].def)[index] = 1
            
        ENDIF ELSE BEGIN 
            cafereport,env, "No Datapoints found"
        ENDELSE 
    ENDFOR             
END

