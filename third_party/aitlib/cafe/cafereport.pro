PRO  cafereport, env, s1, s2, _EXTRA=extra,silent=silent, nocomment=nocomment
;+
; NAME:
;           cafereport
;
; PURPOSE:
;           reports a string/values to command output and log file, if given
;
; CATEGORY:
;           CAFE
;
; SUBCATEGORY:
;           AUXILIARY ROUTINE
;
; SYNTAX:
;           cafereport,env, string
;
; INPUTS:
;
;           env      - The fit environment as defined in
;                      cafeenv__define. Needed for log file information.
;           s1,s2    - The (string) value to report
;           silent   - do not print on standard out but log only. 
;           nocomment- do not print comment sign (";") before output
;                      in log file.
;
; OUTPUT:
;           Write string to standard output and log file, if open.
;
; HISTORY:
;           $Id: cafereport.pro,v 1.6 2003/04/24 09:47:28 goehler Exp $
;             
;
;
; $Log: cafereport.pro,v $
; Revision 1.6  2003/04/24 09:47:28  goehler
; change of report: commentize all entries in log file if not the new option
; /nocomment is used or we are interactive.
; This allows to recall log files as batch files
;
; Revision 1.5  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:06:48  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.3  2002/09/09 17:36:21  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    IF n_elements(s2) EQ 0 THEN s2 = ""

    IF keyword_set(nocomment) THEN $
      commentchar=""               $
    ELSE                           $
      commentchar="; "

    ;; print string itself
    IF NOT keyword_set(silent) THEN print, s1,s2,_EXTRA=extra

    ;; print string to logfile:
    IF (*env).logfile_lun NE 0 THEN BEGIN 
        printf,(*env).logfile_lun , commentchar, format="(A,$)"
        printf,(*env).logfile_lun , s1,s2,_EXTRA=extra
    ENDIF 

    RETURN
END
