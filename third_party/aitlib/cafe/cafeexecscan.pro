FUNCTION  cafeexecscan, str
;+
; NAME:
;           cafeexecscan
;
; PURPOSE:
;           scans exec string into token
;           A token is a substring, being either
;           - a comma
;           - open/close parentheses ()
;           - open/close brackets []
;           - open/close string (")
;           - some other characters
;           - empty string if nothing matching found
;
; CATEGORY:
;           CAFE
;
; SYNTAX:
;           token=CAFEEXECSCAN(str)
;
; INPUTS:
;           str - exec string to split into tokens
;
; OUTPUT:
;           Returns a token string. If no more token found the string
;           is empty. The input string str will be changed by removing the
;           token found.
;
; HISTORY:
;           $Id: cafeexecscan.pro,v 1.1 2003/02/17 17:26:10 goehler Exp $
;             
;
;
; $Log: cafeexecscan.pro,v $
; Revision 1.1  2003/02/17 17:26:10  goehler
; Change: now really parsing the input line (avoid ";")
;
;

    ;; empty -> return emptry string:
    IF strlen(str) EQ 0 THEN return,''
    
    ;; return first char:
    token = strmid(str, 0,1)
    str = strmid(str,1)
    return, token

END 

