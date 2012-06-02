FUNCTION  cafegetplotparam, env, item, panel, default
;+
; NAME:
;           cafegetplotparam
;
; PURPOSE:
;           retrieve plot parameter
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           setplot/plot/contour
;
; SYNTAX:
;           param=cafegetplotparam( env, item, default)
;
; INPUTS:
;           item    - string defining the plot parameter.
;           panel   - panel number to get plot parameter from 
;           default - default value if item not found.
;
; OUTPUT:
;           Returns value according item name, if in environment
;           found, otherwise default value will be returned.
;           Return type always is a string.
;           
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafegetplotparam.pro,v 1.10 2003/05/06 13:16:21 goehler Exp $
;
;
; $Log: cafegetplotparam.pro,v $
; Revision 1.10  2003/05/06 13:16:21  goehler
; moved read/write of settings into separate procedures/functions.
; these also will be used for global settings.
;
; Revision 1.9  2003/04/14 07:41:13  goehler
; fix: setplot parameters were separated with "," which collides within [a,b]
;      replaced with "\n"
;
; Revision 1.8  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2002/09/10 13:24:36  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.6  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.5  2002/09/09 17:36:19  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
    return, string(cafegetparam(item, (*env).plot.plotparams[panel], default))
      
END 
