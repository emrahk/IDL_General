PRO cafe_idle, env, prompt, help=help, shorthelp=shorthelp
;+
; NAME:
;           idle
;
; PURPOSE:
;           Suspend command line for window event processing
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           idle
;
; INPUTS:
;           none
;
; EXPLANATION:
;           This command is related to the wplot command. If wplot is
;           called with the option /idle the command line may be
;           used as before. The problem is that on the other hand
;           wplot buttons can not be used because cafe could not
;           support processing of widget events (like button click
;           etc.).
;           This is the job for the idle command. When executing, the
;           command line is suspended but the wplot window may be
;           used.
;
; QUITTING:
;           Press any key to stop the IDLE command.
;           
; SIDE EFFECTS:
;           Polls for widget events.
;
; EXAMPLE:
;             > fit
;             > wplot, /idle
;             > idle
;              -> now wplot buttons can be used
;              <q>
;              -> now wplot could no more be used>
;             > chpar,2,0
;             > plot
;             > idle ....
;
; HISTORY:
;           $Id: cafe_idle.pro,v 1.3 2003/04/15 09:27:36 goehler Exp $
;-
;
; $Log: cafe_idle.pro,v $
; Revision 1.3  2003/04/15 09:27:36  goehler
; short help pretty print
;
; Revision 1.2  2003/03/17 14:11:29  goehler
; review/documentation updated.
;
; Revision 1.1  2003/03/05 10:42:02  goehler
; added idle command to support widget processing
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="idle"

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
    cafereport,env, "idle     - process wplot widget events"
    return
  ENDIF


  ;; wplot window name:
  WINNAME="cafe_wplot"	

  ;; remark
  cafereport,env, "Press any key to continue"



  ;; reading loop
  REPEAT  BEGIN  

      ;; process events (bypass xmanager)
      tmp=widget_event(/nowait)
      
      ;; wait to avoid load
      wait, 0.1             

      ;; check whether wplot still running:
      IF XREGISTERED(WINNAME) EQ 0 THEN break

        ;; stop when enter pressed:
    ENDREP UNTIL  get_kbrd(0) NE ""

  RETURN  
END

