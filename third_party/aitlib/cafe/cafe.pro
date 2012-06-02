PRO cafe, logfile
;+
; NAME:
;       cafe 
;
;
;
; PURPOSE:
;       Interactive fit environment suplying a frontend for
;       reading/fitting/plotting/analysing data
;
;
;
; CATEGORY:
;       cafe
;
;
;
; CALLING SEQUENCE:
;       cafe, logfile=logfile
;
;
;
; INPUTS:
;      No explicite. Must be get interactively from internal command
;      line. 
;
;
;
;
; OPTIONAL INPUTS:
;       logfile - file name where to write commands/result
;                            of cafe into. No log will be performed
;                            if this command is not given.
;
;
;
; KEYWORD PARAMETERS:
;       None
;
;
;
; OUTPUTS:
;       No explicite. Will be written to file from internal command
;       line. 
;
;
;
;
; OPTIONAL OUTPUTS:
;       None. 
;
;
;
;
; COMMON BLOCKS:
;       None except the one used by mpfit. 
;
;
;
;
; SIDE EFFECTS:
;       None. If not crashing. 
;
;
;
;
; RESTRICTIONS:
;       CAFE is intended for interactive use; therefore
;       this program should not be called from a script (if
;       not this script performs interactive processes itself).
;
;
; PROCEDURE:
;       CAFE shows a prompt and allows to enter several
;       commands to perform a fitting cycle. Each command
;       follows a nearly IDL-like syntax:
;             command> {parameters,}{<opt_parameter>=<value>,}{/,<keyword>,}
;             
;       Most important commands:
;           -  help [<command>] : prints list of available
;                                commands, or of a single command
;                                given. 
;           - quit : exit the environment. Do not interrupt for
;                    the environment uses pointer objects which must be
;                    freed after processing.
;
; EXAMPLE:
;       cafe
;            > data, test.dat, /ascii
;            > model, sinus * exp
;            > fit, 100
;            > plot
;            > error
;            > quit
;
; DISCLAIMER:
;       This environment was built at the Institute for
;       Astronomy and Astrophysic Tuebingen (IAAT),
;       http://astro.uni-tuebingen.de).
;       Design, structure and basic commands are
;       created by Eckart Goehler, 2002.
;             
;       The software may be copied and distributed for free
;       following the terms of the free software foundation. 
;
; MODIFICATION HISTORY:
;       $Id: cafe.pro,v 1.10 2003/05/09 14:50:07 goehler Exp $
;
;-
;
; $Log: cafe.pro,v $
; Revision 1.10  2003/05/09 14:50:07  goehler
;
; updated documentation in version 4.1
;
; Revision 1.9  2003/03/04 16:45:00  goehler
;  bug fix: pointer to environment not dereferenced with (*env).
;
; Revision 1.8  2003/03/03 11:18:21  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2003/02/19 07:41:36  goehler
; version 3.1: - 2dim fitting
;              - improved syntax in exec
;
; Revision 1.6  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:01  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; top version of this environment
    version = '4.1'

    ;; stop idl messsage output (disturbs when running)
    !QUIET=1
 
    ;; allocate environment structure:
    env = cafeenv__define()


    ;; the command line to read in:
    cmdline = ""

    ;; create log file for writing when needed:
    IF n_elements(logfile) NE 0 THEN BEGIN
     
        get_lun, lun
        (*env).logfilE_LUN = LUN
        OPENW, (*ENV).LOGFILE_LUN, LOGFILE
    ENDIF


    ;; ------------------------------------------------------------
    ;; GREETINGS
    ;; ------------------------------------------------------------
    
    PRINT, "          THIS IS CAFE - AN INTERACTIVE FIT ENVIRONMENT"
    PRINT, "                           VERSION: ", VERSION
    PRINT, "Type 'help'  for further information."
    PRINT, "Type 'quit' to leave."

    ;; ------------------------------------------------------------
    ;; MAIN LOOP IN CAFE_EXEC:
    ;; ------------------------------------------------------------
    cafe_exec,env,/interactive
    

    ;; CLEAN UP:
    cafeenv__cleanup, env

    ;; final message:
    print, "CAFE FINISHED"
    RETURN
END

