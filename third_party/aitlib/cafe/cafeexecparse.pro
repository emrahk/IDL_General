FUNCTION  cafeexecparse, str
;+
; NAME:
;           cafeexecparse
;
; PURPOSE:
;           parses a command line, returns a string list which contains
;           all items of a command line, usually separated with ",".
;
; CATEGORY:
;           CAFE
;
; SYNTAX:
;           execlist=CAFEEXECPARSE(execstr)
;
; INPUTS:
;           execstr -  string to split into its components. Will be
;                     empty after call. 
;
; OUTPUT:
;           A exec string list of items which are logically
;           separated (usually via "," as the IDL command line syntax).
;           Thus this function works like STRSPLIT(execstr,",") but 
;           parentheses and string marks are acknowledged. 
;
; REMARKS:
;           This procedure is called recursively and gets tokens from
;           str which will change by subtracting the model tokens
;           (models, operators etc).
;           THE execstr WILL BE EMPTY AFTER CALLING THIS FUNCTION!!!
;
; HISTORY:
;           $Id: cafeexecparse.pro,v 1.1 2003/02/17 17:26:09 goehler Exp $
;             
;
;
; $Log: cafeexecparse.pro,v $
; Revision 1.1  2003/02/17 17:26:09  goehler
; Change: now really parsing the input line (avoid ";")
;
;

; exprlist = expr "," expr  | expr;
; expr     = item
;            | "(" exprlist ")" 
;            | '"' string    '"'
;            | "[" exprlist "]";
; item     = item CHAR | EMPTY ;
; string   = ANYNONSTRINGCHAR string | EMPTY;

    execlist = ""
    execstr  = ""
    

    REPEAT BEGIN

        ;; get next token
        token = cafeexecscan(str)


        ;; non-special char found -> process it
        IF stregex(token,'^(\(|\)|\"|\[|\]|,)')  EQ -1 THEN BEGIN 
            execstr = execstr + token
        ENDIF 

        ;; explicite string 
        IF token EQ '"' THEN BEGIN
            execstr = execstr + '"'
            token = cafeexecscan(str)
            WHILE((token NE "") AND (token NE '"')) DO BEGIN 
                execstr = execstr + token
                token = cafeexecscan(str)
            ENDWHILE  
            execstr = execstr + '"'
        ENDIF 

        ;; () braces:
        IF token EQ '(' THEN BEGIN 
            execstr = execstr + '('+strjoin(cafeexecparse(str),",")+')'
        ENDIF 

        IF token EQ ')' THEN BEGIN 
            execlist = [execlist,execstr]
            execlist = execlist[1:n_elements(execlist)-1]
            return, execlist
        ENDIF 

        ;; [] braces:
        IF token EQ '[' THEN BEGIN 
            execstr = execstr + '['+strjoin(cafeexecparse(str),",")+']'
        ENDIF 

        IF token EQ ']' THEN BEGIN 
            execlist = [execlist,execstr]
            execlist = execlist[1:n_elements(execlist)-1]
            return, execlist
        ENDIF 

        ;; comma:
        IF (token EQ ',')THEN BEGIN 
            execlist = [execlist,execstr]
            execstr = ''
        ENDIF         
    ENDREP UNTIL token EQ ""

    execlist = [execlist,execstr]
    execlist = execlist[1:n_elements(execlist)-1]

    return, execlist

END 
