FUNCTION   caferange, env, range, group, subgroup
;+
; NAME:
;           caferange
;
; PURPOSE:
;           converts range string to an index for a group/subgroup
;
; CATEGORY:
;           CAFE
;
; SUBCATEGORY:
;           AUXILIARY ROUTINE
;
; SYNTAX:
;           index=caferange(env, range, group,subgroup)
;
; INPUTS:
;
;           env      - The fit environment as defined in
;                      cafeenv__define. Contains data to be
;                      considered in range expression.
;           range    - String which defines range of data points to
;                      return. This can be either:
;                       - Data point range, denoted by the data
;                         point number: 
;                         <n1>[-<n2>], while <n1>, <n2> are positive
;                         numbers. Data point numbers start from zero. 
;                         Open intervals can be represented with a 
;                         "*" instead of the number.
;                         If only one number is given, a single
;                         data point will be returned as index. 
;                         If <val2> is less than <val1> all but the
;                         interval <val2>..<val1> are taken into account.  
;                       - X value range, denoted by float point numbers:
;                         <val1>-<val2>,
;                         while <val1>, <val2> represents X values
;                         defining the interval to return. Open
;                         intervals can be represented with a *
;                         instead of the value. If <val2> is less than
;                         <val1> all but the interval <val2>..<val1>
;                         is returned.
;                       - Boolean expressions with X/Y values. All
;                         values for which this expression is true are
;                         returned as index. The expression may contain
;                         algebraic formulas combined with comparison
;                         operators LT, LE, EQ, GT, GE as used in IDL
;                         comparisons. For data use the keywords "X"
;                         and "Y" to represent the x/y values.
;                         It is also possible to use the keywords
;                         "ERROR" (for the error column) and
;                         "SELECTED" (for the select flags).
;                         Multi dimensions are supported with "X1" for
;                         first column, "X2" with second and "X3" with
;                         third column. 
;                       - The word "selected": This will use all
;                         selected data points (selected with
;                         wplot/select command).
;                       - The word "DEF": This will use all
;                         defined data points.
;                         
;                      If range contains not data points -1 is returned. 
;                                                   
;           subgroup - Integer number defining the data set (subgroup)
;                      for which the range index is returned. Must be
;                      in 0..9.
;
;           group    - Integer number defining the data group for
;                      which the range index is returned. Must be in 0..9.
;
; OUTPUT:
;           Returns index array referring a range  in
;           (*env).groups[group].data[subgroup].
;           Returns -1 if range not applicable.
;
; HISTORY:
;           $Id: caferange.pro,v 1.12 2003/05/08 10:06:51 goehler Exp $
;             
;
;
; $Log: caferange.pro,v $
; Revision 1.12  2003/05/08 10:06:51  goehler
; - improved version of range determination
; - scan does not ignore spaces which are needed in some cases (boolean expressions)
;
; Revision 1.11  2003/04/25 12:32:45  goehler
; fix: must join expression string after error replacement.
;
; Revision 1.10  2003/04/16 15:46:24  goehler
; added DEF expression keyword
;
; Revision 1.9  2003/03/17 14:11:44  goehler
; review/documentation updated.
;
; Revision 1.8  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2003/02/11 17:25:43  goehler
; added multi dimension selection
;
; Revision 1.6  2002/09/10 13:06:48  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.5  2002/09/09 17:36:21  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; ------------------------------------------------------------
    ;;  INTEGER DATAPOINT NUMBERS
    ;; ------------------------------------------------------------

    IF stregex(range, '^([0-9]+|\*)(-([0-9]+|\*))?$',/boolean) THEN BEGIN 

        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[subgroup].def) THEN RETURN,-1

        ;; split string:
        expr=stregex(range, '^([0-9*]+)-?([0-9*]+)?$',/extract,/subexpr)

        ;; compute left side index:
        IF expr[1] EQ "*" THEN $
          l_index = 0          $
        ELSE                   $
          l_index = fix(expr[1])
        
        ;; no right side index => equals left side index:
        IF expr[2] EQ "" THEN expr[2] = expr[1]
        

        ;; compute right side index:
        IF expr[2] EQ "*" THEN BEGIN 
            r_index = n_elements(*(*env).groups[group].data[subgroup].def)-1 
        ENDIF ELSE BEGIN 
            r_index = abs(fix(expr[2]))
        END

        ;; restrict to valid range:
        data_points = n_elements(*(*env).groups[group].data[subgroup].def)-1

        r_index = r_index < data_points
        l_index = l_index < data_points
        r_index = r_index > 0
        l_index = l_index > 0

        ;; create index list:
        index = indgen(n_elements(*(*env).groups[group].data[subgroup].def))

        ;; index set for closed interval range
        IF l_index LE r_index THEN BEGIN 

            ;; index ranges from left to right:
            return, index[l_index:r_index]

        ;; index set for open interval range 
        ENDIF ELSE BEGIN 

            ;; open interval ranges from 0..rindex-1 or l_index+1..end
            index = where((index LT r_index) OR index GT l_index)
            
            ;; this is the desired index
            return, index
        ENDELSE
    ENDIF ;; integer range index definition
  


    ;; ------------------------------------------------------------
    ;;  X-VALUES OF  DATAPOINTS
    ;; ------------------------------------------------------------

    IF stregex(range, '^(-?[0-9]+\.[0-9Ee]*|\*)(-(-?[0-9]+\.[0-9Ee]*|\*))?$',$
               /boolean) THEN BEGIN 

            ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[subgroup].def)  THEN $
          return, -1
         
        ;; split string:
        expr=stregex(range, '^(-?[0-9*.eE]+)-?(-?[-0-9*.eE]+)?$',$
                     /extract,/subexpr)

        ;; compute left side index:
        IF expr[1] EQ "*" THEN $
          l_index = -!values.d_infinity   $ ;; lowest possible limit
        ELSE                   $
          l_index = double(expr[1])


        ;; no right side index -> equals left side index
        IF expr[2] EQ "" THEN    expr[2] = expr[1]


        ;; compute rigth side index:
        IF expr[2] EQ "*" THEN $
          r_index = !values.d_infinity   $ ;; highest possible limit
        ELSE                   $
          r_index = double(expr[2])

        ;; set for closed interval range defined flag at 0
        IF l_index LE r_index THEN BEGIN 

            index = where((*(*env).groups[group].data[subgroup].x GE l_index) $
                          AND (*(*env).groups[group].data[subgroup].x LE r_index))

        ;; set for open interval range defined flag at 0
        ENDIF ELSE BEGIN 

            index = where((*(*env).groups[group].data[subgroup].x GT l_index)  $
                          OR (*(*env).groups[group].data[supgroup].x LT r_index))
            
        ENDELSE

        ;; index computed. finish.
        return, index
    ENDIF ;; x range definition



    ;; ------------------------------------------------------------
    ;;   DATAPOINTS ACCORDING EXPRESSION
    ;; ------------------------------------------------------------

    ;; check data set existence:
    IF NOT PTR_VALID((*env).groups[group].data[subgroup].def)  THEN $
      return, -1


    
    ;; copy expression string which may change:
    inputexpr = range

    ;; resulting expression
    rangeexpr = ""

    REPEAT BEGIN 

        ;; use model expression scanner (which also performs
        ;; expression scanning):
        token = cafemodelscan(inputexpr)
        CASE token OF
            "x": rangeexpr = rangeexpr + "(*(*env).groups[group].data[subgroup].x)"
           "x1": rangeexpr = rangeexpr + "(*(*env).groups[group].data[subgroup].x[*,0])"
           "x2": rangeexpr = rangeexpr + "(*(*env).groups[group].data[subgroup].x[*,1])"
           "x3": rangeexpr = rangeexpr + "(*(*env).groups[group].data[subgroup].x[*,2])"
            "y": rangeexpr = rangeexpr + "*(*env).groups[group].data[subgroup].y"
        "error": rangeexpr = rangeexpr + "*(*env).groups[group].data[subgroup].err"
        "def"  : rangeexpr = rangeexpr +"*(*env).groups[group].data[subgroup].def"
     "selected": rangeexpr = rangeexpr +"*(*env).groups[group].data[subgroup].selected"
        "model": BEGIN 
                     rangeexpr = rangeexpr + "cafemodel(env,(*(*env).groups[group].data[subgroup].x),"
                     token = cafemodelscan(inputexpr)
                     IF token EQ ":" THEN BEGIN               ;; group number given
                         rangeexpr = rangeexpr+cafemodelscan(inputexpr)+")" ;; add it
                     ENDIF ELSE BEGIN                     ;; no group -> 
                         inputexpr = token + inputexpr    ;; push token back 
                         rangeexpr = rangeexpr + "group)" ;; use current group 
                     ENDELSE 
                 END 
        ELSE:    rangeexpr = rangeexpr+token          ;; add the other tokens
        ENDCASE        
    ENDREP UNTIL inputexpr EQ  "" ;; input empty -> finished

    
    ;; apply range expression in where statement:
    IF NOT execute('index=where('+rangeexpr+')') THEN BEGIN
        cafereport,env,"Error: Invalid range"
        return,-1
    ENDIF            
          
    ;; return index range computed in expression
    return, index 

END

