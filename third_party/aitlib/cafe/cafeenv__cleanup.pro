PRO cafeenv__cleanup, env
; NAME:
;           cafeenv__cleanup
;
; 
; PURPOSE:
;       Cleans up resources needed from environment structure
;       definition of the CAFE program. This procedure should be
;       changed to maintain environment defining/destroying (s.a.) 
;
;
; CATEGORY:
;       CAFE
;
;
; CALLING SEQUENCE:
;       This procedure is called from cafe when leaving.
;       Usually this procedure should not be called from outside.
;
;
; SIDE EFFECTS:
;       Releases pointer/logical unit numbers etc. 
;
;
; RESTRICTIONS:
;       Should not be called when environment structure
;       still is needed.
;
;
; MAINTAINANCE:
;       If a command of the CAFE program needs some
;       environment parameter which require some external
;       resources (heap allocation etc), it must add a
;       resource freeing handler in this procedure.
;
;
; EXAMPLE:
;
;
;
;
; MODIFICATION HISTORY:
;
;
;-
;
; $Log: cafeenv__cleanup.pro,v $
; Revision 1.8  2003/04/24 09:34:34  goehler
; close wplot window if open
;
; Revision 1.7  2003/03/11 14:35:38  goehler
; updated plotout for multiple plots. tested.
;
; Revision 1.6  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2003/02/18 08:02:32  goehler
; change of steppar/contour:
; use free group 9 to put contour plot at
;
; Revision 1.4  2002/09/10 13:24:34  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:18  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; close open plotout devices:
    cafe_plotout,env,"none"

    ;; close log file handler:
    IF (*env).logfile_lun NE 0 THEN BEGIN 
        close, (*env).logfile_lun
        free_lun, (*env).logfile_lun
    ENDIF 

    ;; close wplot window:
    IF  XREGISTERED("cafe_wplot") GT 0 THEN BEGIN 
        widget_control, (*env).widgets.baseID, /destroy
    ENDIF 


    ;; free pointer of data:
    PTR_FREE, (*env).groups[*].data[*].x
    PTR_FREE, (*env).groups[*].data[*].y 
    PTR_FREE, (*env).groups[*].data[*].err 
    PTR_FREE, (*env).groups[*].data[*].def 

    ;; free pointer of environment
    PTR_FREE, env

END 
