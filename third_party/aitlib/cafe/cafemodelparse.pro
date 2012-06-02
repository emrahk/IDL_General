FUNCTION  cafemodelparse, modelstr, group, modnum
;+
; NAME:
;           cafemodelparse
;
; PURPOSE:
;           parses a model, returns a model string which contains
;           additional items by equip each model with the environment
;           identifier ("env"), the group and the input variabe ("x").
;
; CATEGORY:
;           CAFE
;
; SYNTAX:
;           model=CAFEMODELPARSE(modelstr, group, modnum)
;
; INPUTS:
;           modelstr - model string to transform to complete model
;           group    - group to compute model for
;           modnum   - current used model number (will increase for
;                      each model)
;
; OUTPUT:
;           A model string for which each model contains
;           - parentheses if not already present
;           - the environment identifier ("env")
;           - the group number
;           - the input variable if not already present
;
; REMARKS:
;           This procedure is called recursively and gets tokens from
;           modelstr which will change by subtracting the model tokens
;           (models, operators etc).
;           THE modelstr WILL BE EMPTY AFTER CALLING THIS FUNCTION!!!
;
; HISTORY:
;           $Id: cafemodelparse.pro,v 1.9 2003/04/30 15:02:05 goehler Exp $
;             
;
;
; $Log: cafemodelparse.pro,v $
; Revision 1.9  2003/04/30 15:02:05  goehler
; changed model behavior: all built in model components must be lower case.
; This allows simple use of built in IDL functions/constants which must be
; upper case.
;
; Revision 1.8  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2002/11/05 17:43:44  goehler
; bug fix: model identifier must start with a letter
;
; Revision 1.6  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.5  2002/09/09 17:36:20  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; file name prefix for all models:
    MODEL_PREFIX="cafe_model_"

    model = ""

    REPEAT BEGIN

        ;; get next token
        token = cafemodelscan(modelstr)

        ;; model identifier found
        IF stregex(token, "^[a-z][a-z0-9_]*$",/boolean) THEN BEGIN 

            ;; append prefix + model to modelstring 
            model = model + MODEL_PREFIX+token

            ;; get next token
            token = cafemodelscan(modelstr)

            ;; function contains other functions -> chaining
            IF token EQ "(" THEN BEGIN 

                ;; store current model number,
                ;; increase model for next parse call
                mn = modnum
                modnum = modnum + 1

                model = model                                    $
                  +"("                                           $ ; other function
                  + cafemodelparse(modelstr,group,modnum)      $ ; called recursively
                  +",(*env).parameter[*,"                           $ ; parameter array 
                  + strtrim(string(mn),2)                        $ ; with given model number
                  +", "+strtrim(string(group),2)                 $ ; and group number
                  +"].value,env=env)" 
                
            ENDIF ELSE BEGIN

                ;; no chaining -> append x variable:
                model = model                                    $
                  +"(x,"                                         $ ; x value
                  +"(*env).parameter[*,"                            $ ; parameter array 
                  + strtrim(string(modnum),2)                    $ ; with given model number
                  +", "+strtrim(string(group),2)                 $ ; and group number
                  +"].value,env=env)" 

                modnum = modnum + 1

                  ;; push token back:
                modelstr = token+modelstr
            ENDELSE  



            CONTINUE 
        ENDIF ; model found

        ;; open parenthese -> nested call
        IF token EQ "(" THEN BEGIN
            model=model+"("+cafemodelparse(modelstr,group,modnum)+")"
            continue
        ENDIF 


        ;; close parenthese -> return immediately
        IF token EQ ")" THEN BEGIN 
            return, model
        ENDIF 
        

        ;; simple character -> append
        IF token NE "" THEN model = model + token

        
    ENDREP UNTIL token EQ ""


    return, model

END 
