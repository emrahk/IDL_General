PRO  cafe_maintenance, env,shorthelp=shorthelp
;+
; NAME:
;           cafe - maintenance
;
; PURPOSE:
;           Describes how to support this environment
;
; CATEGORY:
;           cafe 
;
; DESIGN:
;
;      General:
;      This environment is not intended to be a single monument but
;      rather a collection of independent procedures which interact
;      via a common interface.
;      The interface will be a structure variable containing
;      all "state" informations necessary for interchange and user
;      manageability. This variable is further called the
;      "environment" of the cafe system.
;
;      The environment:
;      This environment variable is represented as a pointer to a
;      structure, which itself consists of other structures. Its name
;      is "env". The structure will be defined with the procedure
;      "cafeenv__define()". This is described in detail below.
;
;      User Front-end:
;      Main idea of a front-end is to keep the user away from
;      syntactic/semantic obstacles when entering commands.
;      This will be done with a main loop reading command lines,
;      interpreting them and letting them execute via the IDL execute
;      procedure.
;      This allows to bypass the environment to the command
;      procedure and to simplify the expressions. For example the user
;      does not need to enter quotation marks for strings which
;      clearly have string type. Also it is possible to support simple
;      scripting.
;      This will be done with a top loop procedure (cafe_execute). 
;
;      Groups/Subgroups:
;      To allow fitting of several data sets two concepts are considered:
;      1.) Similar data sets which are stored separately but are to be
;          fit with the same model.
;          These data are subsumed in several subgroups in a single
;          group.
;      2.) Data sets which are to be fit with different
;          models/parameters are to be stored in disjunct groups.
;      Summarizing:
;      - a group contains similar data
;      - each group contains one model+parameter.
;
;      Fit Model:
;      The fit model is represented by a function which has access to
;      the environment. It fetches from the environment all valid
;      (defined) data points and computes the model y values from
;      given x values. Procedure name shall be "cafefitfun".
;      For each group another function shall be  called which performs
;      the actual model evaluation. This function is called
;      "cafemodel".
;      
;      The model itself is a string consisting of an algebraic
;      expression which joins predefined model components. Each
;      component is another IDL function which knows which parameter
;      it needs.
;      This has the advantage that parameters easily could equipped
;      with meaningful names, and the model components perform a sort
;      of grouping of parameters. Also the user has not to manipulate
;      x/y variables.
;      The model string has to be parsed so parentheses are supported
;      properly. While doing parsing the model components are endorsed
;      with x values and parameters.
;
;      Parameters:
;      Parameters shall be stored in the environment as a large 3-dim
;      array reflecting their sorting into model components and groups
;      (and of course - one model component could have more than one
;      parameter).  The parameters are structures contains (according
;      mpfit procedure requirements):
;      - parameter name,
;      - value,
;      - error information,
;      - free flag (if not the parameter is fixed while fitting)
;      - tie expression (to link a parameter to another)
;      - some other components reasonable for fitting.
;
;      Selecting a parameter will be done with a special procedure
;      (cafeparam). 
; 
;      Driver Functions (Subtasks):      
;      Some commands have to perform tasks which may vary because the
;      command interfaces to the world outside. To support easy
;      maintenance and to keep the command procedure small the real
;      task should be done with a driver function/procedure which does
;      the hard interfacing/processing.
;      If doing so the fit environment easily could be adapted to user
;      needs which may change during time.
;      Examples are the loading of data for different file types
;      ("data"), the fit models mentioned above or plot styles for
;      data ("plot"), model or residuals.
;
;      There should be a common syntax how to access the subtasks and
;      how to pass parameters to the subtask. This is closer described
;      in the "syntax"-topic.
;
;      Print/Read:
;      The commands should not use the standard "print" or "read"
;      procedures but instead special procedures which use the
;      environment to report into log file also. (procedures
;      "cafereport" and "caferead"). 
; 
; COMMAND PROCEDURE CONVENTIONS:
;           
;      The commands in CAFE are implemented as external IDL procedures
;      which must follow some restrictions: 
;      1.) Each command must have the a first parameter "env", which is
;          a pointer to a structure containing all environment
;          information. If the procedure needs environment parameter
;          itself it must allocate its environment in the structure
;          definition in file  CAFEENV__DEFINE.PRO.  
;          If the structure allocates some external resources, it must
;          add the necessary cleanup statements in file
;          CAFEENV__CLEANUP.PRO. 
;          
;      2.) If the procedure should be visible for the global help it
;          must reside in the same directory where cafe.pro is loaded
;          from.
;          
;      3.) The procedure must at least support the option parameters
;          /help and /shorthelp. If the optional parameter /help is
;          given  the procedure must print out a description, if
;          /shorthelp is used the procedure must print out a single
;          line containing the command name and a short description.
;          
;      4.) The procedure should have a header starting with ";+" and
;          ending with ";-". This is used by the help command to
;          extract a description text.
;          This text must contain the name/purpose/category section
;          (capitalized, with ":" appended). Reasonable is a
;          syntax/input/output/sideeffect section. Desirable is a
;          version string section (modification history).
;         
;      5.) Parameter syntax should follow the remarks mentioned under
;          the "syntax"-topic. 
;
; FILE NAME CONVENTIONS:
;           
;      1.) All procedures/functions are located in files starting with
;          "cafe". There should be no more than one function/procedure
;          in a file. 
;      2.) The procedure defining a command "foo" must have the file name 
;          "cafe_foo.pro". Otherwise the command is not found by the
;          execution unit and the internal help command.
;      3.) If the procedure needs some auxiliary procedures/functions
;          "bar" then these should be put into files named
;          "cafefoobar.pro". There must be no underscore in the file
;          name because otherwise the files are considered as valid
;          command names by the help command.
;      4.) If a procedure foo calls a subtasks ("driver procedure")
;          bar these subtask file name should be
;          "cafe_foo_bar.pro". In this case the help command reports
;          the subtask information properly. 
;
; HISTORY:
;           $Id: cafe_maintenance.pro,v 1.6 2003/04/25 07:32:57 goehler Exp $
;-
;
; $Log: cafe_maintenance.pro,v $
; Revision 1.6  2003/04/25 07:32:57  goehler
; updated documentation
;
; Revision 1.5  2003/03/17 14:11:30  goehler
; review/documentation updated.
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
;; this file is for documentation only - it contains no vital
;;                                       procedure.

    print, "maintenance - how to support this environment"
    return
END 
