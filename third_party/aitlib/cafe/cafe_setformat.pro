PRO cafe_setformat, env, item, help=help, shorthelp=shorthelp
;+
; NAME:
;           setformat
;
; PURPOSE:
;           Change print format for print/parameters
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           setformat, format_id=code
;
; INPUTS:
;           format_id - The format identifier defining which format
;                       should be changed. This may be one of the
;                       following identifier:
;                         x     - the x axis print format
;                         y     - the y axis print format
;                         error - the error axis print format
;                         parval- parameter value format
;                         parerr- parameter error format
;                        
;             code   -  The format code to set. This may be a IDL float
;                       point value format code which has following syntax:
;                       <CODE><width>[.<prec>] with
;                       CODE - defining the format code, as there are:
;                              F - float proint number
;                              E - float point number in exponential
;                                  form
;                              G - float point number like either as F
;                                  or G depending on value.
;                      width - Number defining the overal width of
;                              the number string.
;                       prec - Number defining the number of positions
;                              after the decimal point.                      
;
; SIDE EFFECTS:
;           Changes format definitions in environment.
;
; EXAMPLE:
;
;             > setformat, x=F10.5
;              -> x axis printout will be 10 characters wide, 5 post
;                   digit positions.
;
; HISTORY:
;           $Id: cafe_setformat.pro,v 1.5 2003/05/09 14:50:08 goehler Exp $
;-
;
; $Log: cafe_setformat.pro,v $
; Revision 1.5  2003/05/09 14:50:08  goehler
;
; updated documentation in version 4.1
;
; Revision 1.4  2003/03/17 14:11:35  goehler
; review/documentation updated.
;
; Revision 1.3  2003/03/03 11:18:25  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.2  2002/09/09 17:36:11  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="setformat"

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
    cafereport,env, "setformat- change print format"
    return
  ENDIF

  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; no item given -> exit
  IF n_elements(item) EQ 0 THEN return


  ;; split into id/code of format
  itempart = strsplit(item,"=",/extract)

  id = itempart[0]
  code = itempart[1]
  
  
  ;; ------------------------------------------------------------
  ;; STORE FORMAT
  ;; ------------------------------------------------------------

  CASE id OF 
      "x" : (*env).format.xformat = code
      "y" : (*env).format.yformat = code
      "error" : (*env).format.errformat = code
      "parval" : (*env).format.paramvalformat = code
      "parerr" : (*env).format.paramerrformat = code
      ELSE:      cafereport,e,"Error: invalid format identifier"
  ENDCASE 

  RETURN  
END

