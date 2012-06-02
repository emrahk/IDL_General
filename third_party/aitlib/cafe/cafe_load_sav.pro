PRO cafe_load_sav, env1, filename,                    $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           load_sav
;
; PURPOSE:
;           Loads environment from IDL SAV file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           load
;
; DATA FORMAT:
;           Uses IDL restore command. Refer documentation. 
;
;               
; SIDE EFFECTS:
;           Overrides current environment.
;
; REMARK:
;           Problems will arise if the environment was saved with
;           a different version from the environment in which a
;           structure element was defined which now is lost. The
;           other case that new elements were added will be
;           handled with the restore command.
;           The load procedure tries to handle these cases by
;           performing structure assignment with
;           /RELAXED_STRUCTURE_ASSIGNMENT.
;           Loading environments saved with a different IDL version
;           does i.g. not work. 
;
; EXAMPLE:
;           > load, weekly.sav
;               -> loads environment from file "weekly.sav"
;
; HISTORY:
;           $Id: cafe_load_sav.pro,v 1.7 2003/04/30 12:46:18 goehler Exp $
;             
;-
;
; $Log: cafe_load_sav.pro,v $
; Revision 1.7  2003/04/30 12:46:18  goehler
; unset log file lun/command file lun/plotout info when restoring
; to avoid problems with not open files
;
; Revision 1.6  2003/03/17 14:11:30  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/04 16:47:42  goehler
; allow schema evolution when environment structure changes
;
; Revision 1.4  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:04  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="load_sav"

    ;; ------------------------------------------------------------
    ;; HELP
    ;; ------------------------------------------------------------
    ;; if help given -> print the specification above (from this file)
    IF keyword_set(help) THEN BEGIN
        cafe_help,env1, name
        return
    ENDIF 


    ;; ------------------------------------------------------------
    ;; SHORT HELP
    ;; ------------------------------------------------------------
    IF keyword_set(shorthelp) THEN BEGIN  
        print, "sav      - load IDL save file type"
        return
    ENDIF


 
    ;; this is the main job. 
    restore, filename=filename,/RELAXED_STRUCTURE_ASSIGNMENT

    ;; copy to value to restore:
    struct_assign,*env,*env1,/verbose

    ;; unset temporary hardware settings
    (*env1).logfile_lun = 0
    (*env1).cmdfile_lun = 0
    (*env1).plot.plotoutfile = ""
    (*env1).plot.plotouttype = ""
END 
