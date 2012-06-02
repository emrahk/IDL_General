PRO  cafe_quit, env,shorthelp=shorthelp
;+
; NAME:
;           quit
;
; PURPOSE:
;           exit cafe program
;
; CATEGORY:
;           cafe 
;
; SYNTAX:
;           quit
; 
; SIDE EFFECTS:
;           Destroys all stored variables.
;           Warning ! No questions will be asked!
;           (our lordship wants to quit - obey!)
;
;
; HISTORY:
;           $Id: cafe_quit.pro,v 1.3 2003/03/17 14:11:35 goehler Exp $
;-
;
; $Log: cafe_quit.pro,v $
; Revision 1.3  2003/03/17 14:11:35  goehler
; review/documentation updated.
;
; Revision 1.2  2002/09/09 17:36:10  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
;; this file is for documentation only - it contains no vital
;;                                       procedure.

    print, "quit     - leave program"
    return
END 

