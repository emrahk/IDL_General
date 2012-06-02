PRO cafe_prompt, env, prompt, help=help, shorthelp=shorthelp
;+
; NAME:
;           prompt
;
; PURPOSE:
;           Change prompt of cafe program
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           prompt, <text>
;
; INPUTS:
;           text - string of containing new command line prompt.
;                  Following expressions are replaced:
;                  %g - Current group.
;
; SIDE EFFECTS:
;           Changes appearance of command line.
;
; REMARK:
;           This command is quite useless. But it may be used as a
;           template for own commands. 
;
; EXAMPLE:
;           cafe
;             > prompt, "% "
;             % 
;             % quit
;
; HISTORY:
;           $Id: cafe_prompt.pro,v 1.6 2003/05/02 07:17:49 goehler Exp $
;-
;
; $Log: cafe_prompt.pro,v $
; Revision 1.6  2003/05/02 07:17:49  goehler
; information about %g = dynamic group information.
;
; Revision 1.5  2003/03/17 14:11:34  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:10  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="prompt"

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
    cafereport,env, "prompt   - change command line prompt"
    return
  ENDIF


  ;; ------------------------------------------------------------
  ;; CHANGE PROMPT
  ;; ------------------------------------------------------------

  (*env).prompt = prompt

  RETURN  
END

