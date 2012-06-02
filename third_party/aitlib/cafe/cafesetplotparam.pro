PRO cafesetplotparam, env, item, panel
;+
; NAME:
;           cafesetplotparam
;           setplotparam
;
; PURPOSE:
;
;           Change common plot appearence
;
; CATEGORY:
;
;           cafe
;
; SUBCATEGORY:
;
;           setplot
;
; SYNTAX:
;
;           cafesetplotparam, env, item, 
;
; INPUTS:
;
;           item - string defining the appearance of the upper
;                  panel. The syntax defines first the item to change,
;                  then the value at what to change, separated with
;                  "=". Item names may be all valid IDL graphic
;                  keywords.
;                  Care must be taken for
;                        - X/YRANGE (computed explicitely)
;                        - NOERASE  (is used to allow several panel plot)
;                        - POSITION (is used to plot at defined positions)
;                  These keywords are used internally as described. 
;
;           panel - panel number
;           
; SIDE EFFECTS:
;
;           Changes environment in respect of plot appearance.
;
;
; HISTORY:
;
;           $Id: cafesetplotparam.pro,v 1.12 2003/05/06 13:16:21 goehler Exp $
;
;
; $Log: cafesetplotparam.pro,v $
; Revision 1.12  2003/05/06 13:16:21  goehler
; moved read/write of settings into separate procedures/functions.
; these also will be used for global settings.
;
; Revision 1.11  2003/04/14 07:41:13  goehler
; fix: setplot parameters were separated with "," which collides within [a,b]
;      replaced with "\n"
;
; Revision 1.10  2003/04/11 07:35:38  goehler
; minor fixes: avoid separation with ";" for plot parameters
;
; Revision 1.9  2003/03/03 20:22:50  goehler
; fix: allow explizite deletion of setplot entries with <name>=""
;
; Revision 1.8  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2002/09/10 13:24:36  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.6  2002/09/10 13:06:48  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.5  2002/09/09 17:36:21  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
    
    ;; store entries as a joint string:
    (*env).plot.plotparams[panel] = cafesetparam(item, (*env).plot.plotparams[panel])
    
END 


