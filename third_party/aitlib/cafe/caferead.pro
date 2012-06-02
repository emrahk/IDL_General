PRO  caferead, env, input, prompt=prompt, nolog=nolog, _EXTRA=extra
;+
; NAME:
;           caferead
;
; PURPOSE:
;           reads a string/values from command line, reports it to log file, if given
;
; CATEGORY:
;           CAFE
;
; SYNTAX:
;           caferead, env, input, prompt=prompt
;
; INPUTS:
;
;           env      - The fit environment as defined in
;                      cafeenv__define. Needed for log file information.
;           input    - The (string) input to read
;
; OPTIONS:
;           nolog    - do not write input into log file. 
;
; OUTPUT:
;           Write string to log file, if open; report input value, if
;           given. 
;
; HISTORY:
;           $Id: caferead.pro,v 1.7 2003/04/30 08:58:39 goehler Exp $
;             
;
;
; $Log: caferead.pro,v $
; Revision 1.7  2003/04/30 08:58:39  goehler
; added nolog option for: changed log file handling
; - batch processes are not commented
;
; Revision 1.6  2003/04/24 09:47:28  goehler
; change of report: commentize all entries in log file if not the new option
; /nocomment is used or we are interactive.
; This allows to recall log files as batch files
;
; Revision 1.5  2003/03/05 10:41:34  goehler
; simplified widget event processing: will be performed with "idle" command.
; reason: editing features with get_kbrd() function too complex.
;
; Revision 1.4  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/10 13:06:48  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.2  2002/09/09 17:36:21  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


  ;; ------------------------------------------------------------
  ;; ENTER STRING
  ;; ------------------------------------------------------------

    IF (*env).cmdfile_lun EQ 0 THEN BEGIN 
        read,input,prompt=prompt,_EXTRA=extra
    ENDIF ELSE BEGIN 
        REPEAT BEGIN 
            READF,  (*env).cmdfile_lun, input, _EXTRA=extra
        ENDREP UNTIL NOT stregex(input,"^;",/boolean)
    ENDELSE 

    ;; print string to logfile:
    IF (*env).logfile_lun NE 0 AND NOT keyword_set(nolog)THEN BEGIN 
        printf,(*env).logfile_lun , "; ", prompt,_EXTRA=extra
        printf,(*env).logfile_lun , input,_EXTRA=extra
    ENDIF 

    RETURN
END
