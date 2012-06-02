FUNCTION  cafemodel, env, x, group
;+
; NAME:
;           cafemodel
;
; PURPOSE:
;           main model function 
;
; CATEGORY:
;           CAFE
;
; SYNTAX:
;           Y=CAFEMODEL(env, x, group)
;
; INPUTS:
;           group    - Defines the group in which the model is defined in.
;           x        - x values to apply model to
;           env      - The fit environment as defined in
;                      cafeenv__define. Contains all X/Y/error
;                      information and the group/subgroup information. 
;
; OUTPUT:
;           Returns a Y-value from X values according model and
;           parameters defined in environment. 
;
; HISTORY:
;           $Id: cafemodel.pro,v 1.5 2003/03/03 11:18:34 goehler Exp $
;             
;
;
; $Log: cafemodel.pro,v $
; Revision 1.5  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.3  2002/09/09 17:36:20  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    
    ;; ------------------------------------------------------------
    ;; BUILD MODEL EXPRESSION:
    ;; ------------------------------------------------------------
    
    ;; copy model string for parsing changes string content:
    model = (*env).groups[group].model
    
    ;; expression is the model endorsed with function call parameters,
    ;; starting with model number 0:
    expression = cafemodelparse(model,group, 0)


    ;; check model existence:
    IF expression EQ "" THEN BEGIN 
        cafereport,env, "Error: No valid model expression given"
        return,0
    ENDIF


    ;; ------------------------------------------------------------
    ;; CALL MODEL EXPRESSION:
    ;; ------------------------------------------------------------

    OK = EXECUTE("y="+expression)
        
    return, y  

END  

