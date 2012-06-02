FUNCTION cafesetparam, item, list
;+
; NAME:
;           cafesetparam
;
; PURPOSE:
;
;           Change list of set items
;
; CATEGORY:
;
;           cafe
;
; SUBCATEGORY:
;
;           parameter change
;
; SYNTAX:
;
;           cafesetparam, item, list
;
; INPUTS:
;
;           item - string defining the appearance of the upper
;                  panel. The syntax defines first the item to change,
;                  then the value at what to change, separated with
;                  "=". Item names must be alphabetic+number, but are
;                  case insensitive. 
;
;           list - Current list of items (string). May be empty
;                  string. Each item is separated by a newline
;                  character (STRING(10B).
;
; OUTPUT:
;           Returns: New list with given item inserted/removed
;           
; SIDE EFFECTS:
;           None. (Auxiliary routine only).
;
;
; HISTORY:
;
;           $Id: cafesetparam.pro,v 1.1 2003/05/06 13:16:21 goehler Exp $
;
;
; $Log: cafesetparam.pro,v $
; Revision 1.1  2003/05/06 13:16:21  goehler
; moved read/write of settings into separate procedures/functions.
; these also will be used for global settings.
;
;
;
;

    ;; ------------------------------------------------------------
    ;; SEPARATOR FOR ITEMS (newline)
    ;; ------------------------------------------------------------

    itemsep = String(10B)

    ;; ------------------------------------------------------------
    ;; SEPARATE NAME/VALUE OF ITEM
    ;; ------------------------------------------------------------

    itemparts = strsplit(item,"=",/extract,/preserve_null)

    ;; add empty value if missing
    IF n_elements(itemparts) LT 2 THEN itemparts=[itemparts,""] 

    ;; ------------------------------------------------------------
    ;; LOOKUP ITEM
    ;; ------------------------------------------------------------
    
    itemlist = strsplit(list,itemsep,/extract)
    
    ;; look for existing entry:
    index = where(stregex(itemlist,"^"+itemparts[0],/boolean))
    
    ;; nothing found -> add item
    IF index[0] EQ -1 THEN BEGIN 
        itemlist = [itemlist,""]
        index = n_elements(itemlist)-1
    ENDIF 
    

    ;; ------------------------------------------------------------
    ;; SET ITEM VALUE
    ;; ------------------------------------------------------------

    ;; no value defined -> mark as deleted item
    IF itemparts[1] EQ "" THEN BEGIN

        ;; get parts of  items found (or not found)
        cur_value = (stregex(itemlist[index],"(.*)=(.*)",/extract,/subexpr))[2]
        
        ;; unset if set or explizitely deleted:
        IF cur_value NE "" OR $                                     ; item set 
          stregex(item,"=",/boolean) THEN  itemlist[index] = "" $ ; or assignment given
          ;; set if unset and not to be deleted:                              
        ELSE itemlist[index] = itemparts[0]+"=1"

        ;; set top item keyword:
    ENDIF  ELSE BEGIN 
        
        ;; add quotations if not number/already quoted:
        IF stregex(itemparts[1],                 $
                   '^('                          $
                   +'(-?[0-9]+\.?[0-9]*[eE]?[0-9]*)'$ ; number
                   +'|(".*")'                    $ ; string
                   +'|(\(.*\))'                  $ ; numeric expression
                   +'|(\[.*\])'                  $ ; array
                   +')$',/boolean) EQ 0 THEN         $
          itemparts[1] = "'"+itemparts[1]+"'" 
          
        ;; store value
        itemlist[index] = itemparts[0]+"="+itemparts[1]
    ENDELSE 

    ;; ------------------------------------------------------------
    ;; BUILD NEW ITEM LIST
    ;; ------------------------------------------------------------

    ;; look for empty entries:
    index = where(itemlist NE "")
    
    ;; remove them:
    IF index[0] NE -1 THEN itemlist=itemlist[index]

    ;; return new list:
    return, strjoin(itemlist,itemsep,/single)

END 


