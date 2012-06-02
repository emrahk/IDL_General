FUNCTION cafequotestr, str, keyvalpair=keyvalpair
;+
; NAME:
;           cafequotestr
;
; PURPOSE:
;           Adds string quotation marks if required.
;
; CATEGORY:
;           cafe
; 
; SUBCATEGORY:
;           Tasks/Subtasks with parameters.
;
; SYNTAX:
;           newarg = cafequotestr, str
;
; INPUTS:
;           str - String containing comma separated arguments
;                 which are to be processed.
;                 
;                 Each item which is not a number, an option (/foo) or
;                 enclosed in parentheses "()" will be enveloped with
;                 string marks.
;                 For this the string will be parsed with cafeparse()
;                 to be separated properly in its items.
;
;                 If str is a string array its arguments will be
;                 checked for quotation but no further splitting will
;                 be performed. The return 
;                 
; OPTIONS:  
;           keyvalpair - all string items are given as key/value pairs
;                        which have the form key=value. In this case
;                        the value only has to be quoted. If the value
;                        is missing the key will be set at 1.
;
;                        This option is needed for subtask
;                        parameters. 
; OUTPUT:
;           Returns string containing the same arguments as the input
;           but with proper quoting.
;
;           If the input is a string array also a string array with
;           the same dimensions as the input will be returned. 
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafequotestr.pro,v 1.1 2003/04/28 07:38:16 goehler Exp $
;
;
; $Log: cafequotestr.pro,v $
; Revision 1.1  2003/04/28 07:38:16  goehler
; moved parameter determination into separate function cafequotestr
;
;-

    ;; must split -> parse it:
    IF n_elements(str) EQ 1 THEN BEGIN 

        parsestr = str[0]   ;; string to parse -> will be deleted. 
                                 ;; Make shure it is not a degenerated array. 
        items= cafeexecparse(parsestr)
        items = strtrim(items,2) ; remove leading/trailing spaces

    ENDIF                            $
    ELSE items = str             ;; no further splitting required.
    

    IF keyword_set(keyvalpair) THEN BEGIN 

        ;; extract name/values:
        itemparts = stregex(items,"([^=]*)=?([^=]*)",/extract,/subexpr)

        ;; set undefined values at 1:
        ind = where(itemparts[2,*] EQ "")
        IF ind[0] NE -1 THEN itemparts[2,ind]='1'

        ;; copy to items:
        items = itemparts[2,*]
    ENDIF 

    ;; add quotations for obvious strings (no quote/number/slash):
    strindex=where(1-stregex(items,                      $ ; no quote for:
                           '^('                          $
                           +'(-?[0-9]+\.?[0-9]*[eE]?[0-9]*)'$ ; number
                           +'|(".*")'                    $ ; string
                           +'|(/.*)'                     $ ; option
                           +'|(\(.*\))'                  $ ; numeric expression
                           +'|(\[.*\])'                  $ ; array/vector
                           +')$',/boolean))


    ;; add quotes for strings, check string index
    IF strindex[0] NE -1 THEN          $ 
      items[strindex] = "'"            $ 
      + items[strindex] + "'"  ;

    ;; rebuild key/value pairs:
    IF keyword_set(keyvalpair) THEN BEGIN 

        itemparts[2,*]= items

        ;; reconstruct parameter items
        items=strjoin(itemparts[1:2,*],"=")
    ENDIF 


    ;; rebuild entire string:
    IF n_elements(str) EQ 1 THEN return, strjoin(items, ",") $
    ELSE                         return, items

END 



