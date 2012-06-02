PRO cafe_save_sav, env, filename,                    $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           save_sav
;
; PURPOSE:
;           Saves environment into IDL SAV file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           save
;
; DATA FORMAT:
;           Uses IDL save command. Refer documentation. 
;
;               
; SIDE EFFECTS:
;
;
; EXAMPLE:
;
;               > save, weekly.sav
;               -> saves environment into file "weekly.sav"
;
; HISTORY:
;           $Id: cafe_save_sav.pro,v 1.4 2003/04/24 09:48:24 goehler Exp $
;             
;-
;
; $Log: cafe_save_sav.pro,v $
; Revision 1.4  2003/04/24 09:48:24  goehler
; moved saving report to driver procedures
;
; Revision 1.3  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.2  2002/09/09 17:36:10  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="save_sav"

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
        print, "sav      - IDL save type"
        return
    ENDIF


    ;; this is the main job. 
    save, env, filename=filename


    ;; report
    cafereport,env, "Saved environment in "+filename
END 
