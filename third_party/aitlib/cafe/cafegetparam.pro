FUNCTION  cafegetparam, item, list, default, int=int, double=double
;+
; NAME:
;           cafegetparam
;
; PURPOSE:
;           retrieve  parameter
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           parameter change
;
; SYNTAX:
;           param=cafegetparam( item, list, default[,/int][,/double])
;
; INPUTS:
;           item    - string (key) defining the parameter.
;           list    - newline separated list of items (the database).
;           default - default value if item not found.
;
; OPTIONS:
;           int     - Return value as integer (long).
;           double  - Return value as double precission float.
;
; OUTPUT:
;           Returns value according item name, if in environment
;           found, otherwise default value will be returned.           
;           
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafegetparam.pro,v 1.1 2003/05/06 13:16:21 goehler Exp $
;
;
; $Log: cafegetparam.pro,v $
; Revision 1.1  2003/05/06 13:16:21  goehler
; moved read/write of settings into separate procedures/functions.
; these also will be used for global settings.
;
;
;
;


    ;; ------------------------------------------------------------
    ;; SEPARATOR FOR  ITEMS (newline)
    ;; ------------------------------------------------------------

    itemsep = String(10B)

    ;; ------------------------------------------------------------
    ;; LOOKUP ITEM
    ;; ------------------------------------------------------------
    
    itemlist = strsplit(list,itemsep,/extract)
    
    ;; look for existing entry:
    index = (where(stregex(itemlist,"^"+item,/boolean,/fold_case)))[0]
    
    ;; nothing found -> return default value
    IF index EQ -1 THEN BEGIN 
        return, default
    ENDIF

    ;; lookup value as part after "=":
    value=(strsplit(itemlist[index],"=",/extract))[1]

    ;; conversions:
    IF keyword_set(int) THEN return,long(value)
    IF keyword_set(double) THEN return, double(value)

    ;; default type: string:
    return, value
      
END 
