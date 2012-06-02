PRO  cafe_modify, env, expression,        $
                  range, subgroup, group, $
                  help=help, shorthelp=shorthelp
;+
; NAME:
;           modify
;
; PURPOSE:
;           modifies data point values (x/y/error)
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           modify, x|y|error=expression, [,range] [,subgroup][,group]
;
; INPUTS:
;          x,y,error - The column to modify (select one). 
; 
;         expression - Defines how to modify. This may be any IDL
;                      expression.  Following variables have special meaning:
;                      x     - the x column.
;                      y     - the y column.
;                      error - the error
;
;                      Case is important. When using external functions
;                      containing x/y/err it is recomended to give
;                      these functions upper case. 
;
;                      The variables may be appended with ":<group>"
;                      to import the variables from different groups,
;                      same subgroup. 
;
;                      The expression either must define an array which has
;                      as much elements as the column to modify, or
;                      contain scalar values.
;                      It is possible to select array elements with
;                      "[index]" but care must be taken when ranges
;                      are used; the index refers to the range restricted array.
;                      
;           range    - (optional) Defines range of data points to modify. This can
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
;                      Default is the entire data set to modify. 
;                                                   
;           subgroup - (optional) The data set (subgroup) for which the model
;                      should be applied. This can be either the
;                      subgroup number or the file name representing
;                      the data set. It is possible to set more than
;                      one subgroup, either with numbers in brackets
;                      ([]) separated with ","; or denoting filenames
;                      with wildcards ("*"). 
;                      Default is the first valid subgroup in current used
;                      group.                                                     
;
;           group    - (optional) The data group for which the model
;                      should be applied.
;                      Default is the primary group 0. Must be in
;                      range [0..29].                      
;
;
; SIDE EFFECTS:
;           Changes data point values (no possibility to recover
;           except reload!)
;
; EXAMPLE:
;           > modify, y=2*x+0.5,0-100,0,1
;                 -> modify all y values for data points 0..100, 
;                 group 1, subgroup 0 at linear x values. 
;
; HISTORY:
;           $Id: cafe_modify.pro,v 1.14 2003/05/05 13:48:24 goehler Exp $
;-
;
; $Log: cafe_modify.pro,v $
; Revision 1.14  2003/05/05 13:48:24  goehler
; allow spaces before assignment "="
;
; Revision 1.13  2003/04/30 12:44:56  goehler
; fix/update of documentation concerning case dependency/error handling
;
; Revision 1.12  2003/04/25 18:00:58  goehler
; added internal error report
;
; Revision 1.11  2003/03/17 14:11:32  goehler
; review/documentation updated.
;
; Revision 1.10  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.9  2003/02/24 14:42:18  goehler
; distinguish between idl functions (lower case) and built-in variables (upper case)
;
; Revision 1.8  2003/02/19 07:31:13  goehler
; allow array selectors (x[])
;
; Revision 1.7  2002/09/19 14:02:38  goehler
; documentized
;
; Revision 1.6  2002/09/09 17:36:07  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="modify"

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
        cafereport,env, "modify   - modify datapoint"
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

    IF n_elements(range) EQ 0 THEN range = "*"

    range=strtrim(string(range),2)
    


    ;; ------------------------------------------------------------
    ;; FOR EACH SUBGROUP -> LOOK TO MODIFY
    ;; ------------------------------------------------------------

    ;; for each subgroup:
    FOR i =0,n_elements(subgroup)-1 DO BEGIN 

        ;; select subgroup:
        sg = subgroup[i]

        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE        

        ;; ------------------------------------------------------------
        ;; BUILD MODIFY EXPRESSION:
        ;; ------------------------------------------------------------
        
        ;; copy of expression to avoid change:
        modexpr = expression

        ;; replace error -> err:
        modexpr=  strepex(modexpr,"error","err",/all)

        ;; replace x/y/error with full names: (using strepex in aitlib/misc)
        ;; 1.) (x|y|err):group -> (*env).groups[group]....(x|y)
        modexpr=  strepex(modexpr,"(x|y|err)(:([0-9]+))?", $ ;
                          "((*(*env).groups[&2].data[sg].&0)[index])",/all) 

        ;; 2.) insert default group (left empty above):
        modexpr=strepex(modexpr,"groups\[\]","groups[group]",/all)

        ;; 3.) strip left hand value from parentheses:
        modexpr=strepex(modexpr,"^\((.*)\) *=","&0=")        

        ;; create error column if needed:
        IF NOT ptr_valid((*env).groups[group].data[sg].err) AND $
          stregex(expression,"^ *error=", /boolean,/fold_case) THEN   BEGIN 
            ;; create array with same size as y column:
            (*env).groups[group].data[sg].err = $
              ptr_new(dblarr(n_elements(*(*env).groups[group].data[sg].y)))
        ENDIF 
        
          

        ;; print subgroup information:
        cafereport,env, "Subgroup "+strtrim(string(sg),2)$
                     +"  ["+(*env).groups[group].data[sg].file+"]:"

        index = caferange(env,range,group,sg)

        IF index[0] NE -1 THEN BEGIN 
            cafereport,env, " Modifying "                      $
                         +strtrim(string(n_elements(index)),2)  $
                         +" datapoints"
            cafereport,env, " from "                          $
                         +strtrim(string(index[0]),2)           $
                         +" to "                                $
                         +strtrim(string(index[n_elements(index)-1]),2)            

            ;; -----------------------------------------------------
            ;; PERFORM MODIFICATION:
            ;; -----------------------------------------------------

            IF NOT execute(modexpr) THEN BEGIN 
                cafereport,env,"Error: "+!ERR_STRING
                cafereport,env,"Internal: "+modexpr
                return
            ENDIF                           

        ENDIF ELSE BEGIN 
            cafereport,env, "No Datapoints modified"
        ENDELSE 
    ENDFOR             
END
