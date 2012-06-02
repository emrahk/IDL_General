PRO  cafe_syntax, env,shorthelp=shorthelp
;+
; NAME:
;           cafe - syntax
;
; PURPOSE:
;           Describe command line syntax
;
; CATEGORY:
;           cafe 
;
; DESCRIPTION:
;
; In cafe commands have the general form:
;    > command,param1,..paramn [,/option1][,/option2]...[,/option42]
;
; This line consists of a command name ('command') and some required
; parameters, sometimes the group to which the command should applied
; to, and some optional flags. These optional flags always start with "/".
; All parameters/options are separated by ','. The brackets ("[..]")
; above denote optional parameters.  
;
; In general it is not necessary to quote strings (as for example file
; names). Quoting with "" should be done if
;  - the string looks like a number
;  - the string starts with a '/' (e.g. absolute path). Otherwise the
;    string will be interpreted as an option.
;  - The string is enclosed in parentheses () or [].
;  - White spaces in the string are important.
;
;  If a parameter should be a number most times it is sufficient to
;  write the number as usual in the format:
;      digits[.digits E digits]
;  with digits representing 0..9. If complex expressions are
;  used they should be enclosed in parentheses (..) to avoid implicit
;  string quoting. For example numbers in expressions should be placed
;  in (). 
;  
; CONVENTIONS:
;
;  The parameter syntax follows some conventions:
;   - A command may access several subtasks to perform its goal. These
;     are defined with string identifier. Often it is possible to
;     combine these subtasks; this will be done with a "+".
;     Example:
;       The plot command could be used with different plot styles
;       (these are executed by the subtasks) which may be combined
;       with "+":
;         > plot, data+model
;           -> plot data AND model in a single plot panel.
;     Help for these subtasks can be get with
;         > help, <command>, <subtask>.
;      
;   - If a subtask refers to a certain group, the group will be
;     specified with ":" + group number.
;     Example:
;         > plot, data:1
;           -> plot data of group 1.
;        
;   - If a subtask needs some special parameters they will be passed
;     in brackets "[]". 
;     Example:
;         > data, lc.fits[time,rate]
;           -> load data with column time=x, rate=y.
;                                       
;   - Setting of internal state parameters is done with the syntax:
;        identifier=value
;     while the identifier is a string defining what parameter to set
;     and value defines at which value to set the parameter.
;     Example:
;         > setplot, xtitle=time
;           -> sets internal parameter xtitle at string value "time".
;
; COMMENTS:
;
;  A command line which does not start with a alphabetic value or a
;  "!", "@", "#" (s.b.) is interpreted as a comment and does nothing.
;  For convenience it is advised to denote comments with a semicolon
;  as used in IDL (";").
;
; BATCH-PROCESSING:
;    If the command line starts with a "@" the following word is
;    interpreted as a file name from which cafe commands are read.
;    Example:
;      cafe> @ test.cmd
;        -> read and execute commands from test.cmd
;    If an command needs some user input the input will be read from
;    the batch file. Lines starting with ";" are ignored in this case
;    (see comments above). 
;
; ACCESSING IDL:
;
;    If the command line starts with a "!" the following will be
;    interpreted as an IDL command.
;    This has two purposes:
;      1.) To run a separate IDL process (e.g. compute print,2+2)
;      2.) To access the cafe inner state for either debugging
;          purposes or to run cafe commands directly without syntax
;          bypassing by the cafe environment.
;          The main interesting part would probably be the cafe
;          environment, stored in the struct called "env".
;
; SILENT PROCESSING:
;    If the command line starts with a "#" the command will not be
;    echoed into the log file.
;
; PROCESSING OF SHELL COMMANDS:
;    Non existing cafe commands will be interpreted as shell
;    commands. This allows easy access to the environment.
;    Example:
;        cafe> ls -l
;         -> Execute shell command: ls -l
;          > -rw-r--r--    1 eckart   users        3718 Mär 16 14:37 cafe_cafe.pro
;          > -rw-r--r--    1 eckart   users        2831 Mär 16 14:45 cafe_chgrp.pro
;          > -rw-r--r--    1 eckart   users        6559 Mär 16 14:46 cafe_chpar.pro
;          > -rw-r--r--    1 eckart   users        5695 Mär 16 14:48 cafe_clean.pro
;
; HISTORY:
;           $Id: cafe_syntax.pro,v 1.8 2003/04/25 07:32:58 goehler Exp $
;-
;
; $Log: cafe_syntax.pro,v $
; Revision 1.8  2003/04/25 07:32:58  goehler
; updated documentation
;
; Revision 1.7  2003/03/17 14:11:37  goehler
; review/documentation updated.
;
; Revision 1.6  2003/02/17 17:30:33  goehler
; Change: now really parsing the input line (avoid ";")
;
; Revision 1.5  2002/09/19 14:02:38  goehler
; documentized
;
; Revision 1.4  2002/09/10 13:24:33  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:14  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
;; this file is for documentation only - it contains no vital
;;                                       procedure.

    print, "syntax   - command line syntax information"
    return
END 
