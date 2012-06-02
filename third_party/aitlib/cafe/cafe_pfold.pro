PRO  cafe_pfold, env, range, subgroup, group, $
                  help=help, shorthelp=shorthelp
;+
; NAME:
;           pfold
;
; PURPOSE:
;           folds data set(s) with certain period.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;         pfold[,range] [,subgroup][,group]
;
; INPUTS:
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
; SETUP:
;          period    - The period to fold the data with. Should be
;                      initialized with the set command.  If not
;                      defined the user will be prompted for.
;          nbins     - Number of bins to use for folding. Default: 20.
;          time0     - Use this instead of first x value as start time.
;          dt        - Width of each time bin. Default is difference
;                      between first two x values.
;          tolerance - parameter defining the lower limit for the gap
;                      length; the reference is the time difference
;                      between the first and second entry in the time
;                      array; tolerance defines the maximum allowed relative
;                      deviation from this reference bin length;
;                      default: 1e-8; this parameter is passed to timegap
;                      (see timgap.pro for further explanation).
;                      
; OUTPUT:
;           All data points given as input are summed up within a
;           histogram according their x value modulo a period. The
;           period must be set before. 
;
; SIDE EFFECTS:
;           Creates/Overrides first subgroup in the result group. 
;
; EXAMPLE:
;           > set, period=2000.
;           > pfold
;           -> fold all data in current group with a period of 2000.
;
; HISTORY:
;           $Id: cafe_pfold.pro,v 1.1 2003/05/07 08:11:57 goehler Exp $
;-
;
; $Log: cafe_pfold.pro,v $
; Revision 1.1  2003/05/07 08:11:57  goehler
; pfold transformation wrapper
;
;
;
;


    ;; command name of this source (needed for automatic help)
    name="pfold"

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
        cafereport,env, "pfold  - periodic folding of data points"
        return
    ENDIF


    ;; extract x/y/error:
    cafeextract,env, x,y,err,range,subgroup,group

    ;; look for result group:
    cafe_chres,env

    ;; run command:
    pfold, x, y, profile,                                        $
      raterr = err,                                              $
      period = cafegetparam("period",(*env).setup,1.,/double),    $
      nbins  = cafegetparam("nbins",(*env).setup,20,/int),       $
      time0  = cafegetparam("time0",(*env).setup,dummy1,/double), $ ;use undefined varable as default
      dt     = cafegetparam("dt",(*env).setup,dummy2,/double),    $ 
      nogap  = cafegetparam("nogap",(*env).setup,dummy3,/int),    $  
    tolerance= cafegetparam("tolerance",(*env).setup,dummy3,/int),    $  
      phbin  = phbin,                                             $ ; output: phase
      proferr= proferr

    ;; remove former values:
    PTR_FREE, (*env).groups[(*env).res_grp].data[*].x
    PTR_FREE, (*env).groups[(*env).res_grp].data[*].y
    PTR_FREE, (*env).groups[(*env).res_grp].data[*].err
    PTR_FREE, (*env).groups[(*env).res_grp].data[*].def

    ;; store new values:
    (*env).groups[(*env).res_grp].data[0].x = ptr_new(phbin)
    (*env).groups[(*env).res_grp].data[0].y = ptr_new(profile)
    (*env).groups[(*env).res_grp].data[0].def =  $
      ptr_new(make_array(n_elements(profile),/byte,value=1))
    (*env).groups[(*env).res_grp].data[0].selected = $
      ptr_new(make_array(n_elements(profile),/byte,value=0))

    IF n_elements(err) NE 0 AND n_elements(proferr) NE 0 THEN  $
      (*env).groups[(*env).res_grp].data[0].err = ptr_new(proferr)

    ;; data file name:
    (*env).groups[(*env).res_grp].data[0].file = "-PFOLD-"

END
