FUNCTION  cafemodelscan, modelstr
;+
; NAME:
;           cafemodelscan
;
; PURPOSE:
;           scans fit model string into token
;           A token is a substring, being either
;           - an identifier (characters)
;           - open/close parentheses
;           - some other character
;           - empty string if nothing matching found
;
; CATEGORY:
;           CAFE
;
; SYNTAX:
;           token=CAFEMODELSCAN(modelstr)
;
; INPUTS:
;           modelstr - model string to split into tokens
;
; OUTPUT:
;           Returns a token string. If no more token found the string
;           is empty. The model string will be changed by removing the
;           token found.
;
; HISTORY:
;           $Id: cafemodelscan.pro,v 1.8 2003/05/08 10:06:51 goehler Exp $
;             
;
;
; $Log: cafemodelscan.pro,v $
; Revision 1.8  2003/05/08 10:06:51  goehler
; - improved version of range determination
; - scan does not ignore spaces which are needed in some cases (boolean expressions)
;
; Revision 1.7  2003/04/30 15:01:57  goehler
; changed model behavior: all built in model components must be lower case.
; This allows simple use of built in IDL functions/constants which must be
; upper case.
;
; Revision 1.6  2002/11/05 17:43:44  goehler
; bug fix: model identifier must start with a letter
;
; Revision 1.5  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.4  2002/09/09 17:36:20  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
    

    
    ;; model found => return it
    index  = stregex(modelstr,"^[a-z][a-z0-9_]*",length=len) 
    IF index NE -1  THEN BEGIN 
        token = strmid(modelstr, index,len)
        modelstr=strmid(modelstr, index+len)
        return, token 
    ENDIF 

    ;; parenthese found -> return it
    index  = stregex(modelstr,"^(\(|\))",length=len) 
    IF index NE -1  THEN BEGIN 
        token = strmid(modelstr, index,len)
        modelstr=strmid(modelstr, index+len)
        return, token 
    ENDIF 

    ;; some character found -> return it
    IF modelstr NE ''  THEN BEGIN 
        token = strmid(modelstr, 0,1);; return first char
        modelstr=strmid(modelstr, 1) ;; remove char
        return, token 
    ENDIF 

    ;; nothing found -> return empty string
    return, ''
END 

