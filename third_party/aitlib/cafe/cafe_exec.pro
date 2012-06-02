PRO  cafe_exec, env, filename,                            $
                p1,p2,p3,p4,p5,p6,p7,p8,p9,               $
                interactive=interactive,                  $
                single=single, silent=silent,             $ 
                fullbatch=fullbatch,                      $
                help=help,shorthelp=shorthelp
;+
; NAME:
;           exec
;
; PURPOSE:
;           executes commands defined in file.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           exec, filename,[p1,...,p9][/interactive][,/single][,/silent]
;
; INPUTS:
;           filename    - File to read commands from.
;                         The commands in this (ascii) file follow the
;                         syntax as on command line:
;                          - Comments start with ";" in first column.
;                          - IDL commands start with "!".
;                          - Batch execution (i.e. read commands from
;                            file) is given with the file name preceeded
;                            with "@".
;                            Parameters may be given by appending a
;                            comma separated expression list. Within
;                            the batch file the parameters may be
;                            accessed as p1..p9 (s.b.).
;                            Example:
;                              > @fitall,2,3
;                              -> sets within "fitall" the variable
;                                 "p1" at 2 and "p2" at 3. 
;                          - Commands starting with "#" are not echoed. 
;                         If single mode (s.b.) is selected the
;                         filename is interpreted as a cafe command
;                         string.
;
;           p1..p9      - (optional) Parameters which may be used when
;                         calling the exec command. These parameters
;                         may be referenced in a script. 
;
; OPTIONS:
;           interactive - Read commands from the command
;                         line. Possibly useful for command setup but
;                         usually not needed. (Internally used for
;                         main command loop).

;           single      - interprete the input file as a single
;                         command line to be executed.                         

;           silent      - Do not echo script commands.
;           
;           fullbatch   - Report each line of a batch file. Default is
;                         that only executable lines of batch file are
;                         shown (this allows easy logging
;
; SIDE EFFECTS:
;           Changes the environment according the commands executed.
;
; REMARK:
;           The exec-command can be abbreviated with "@" (s.a.).
;
; EXAMPLE:
;           > exec, startup.cmd
;
; HISTORY:
;           $Id: cafe_exec.pro,v 1.19 2003/05/02 08:58:30 goehler Exp $
;-
;
; $Log: cafe_exec.pro,v $
; Revision 1.19  2003/05/02 08:58:30  goehler
; display prompt on screen when running a batch file
;
; Revision 1.18  2003/05/02 07:37:40  goehler
; added /fullbatch option which displays entire batch file when executing.
;
; Revision 1.17  2003/05/02 07:15:59  goehler
; added facility to set dynamic prompt with group information
;
; Revision 1.16  2003/04/30 09:49:25  goehler
; fixes: batch parameter must be reported in log file
;
; Revision 1.15  2003/04/30 08:57:44  goehler
; changed log file handling:
; - batch processes are not commented
; - log files may be executed "as is" resulting in no difference to original
;   processing.
;
; Revision 1.14  2003/04/29 16:30:10  goehler
; exit in error case
;
; Revision 1.13  2003/04/29 16:19:50  goehler
; added parameters to set when calling batch processing
;
; Revision 1.12  2003/04/28 07:38:15  goehler
; moved parameter determination into separate function cafequotestr
;
; Revision 1.11  2003/04/24 09:51:55  goehler
; save command file LUN in environment. It will be needed to decide whether batch processing
; is working or not.
;
; Revision 1.10  2003/04/23 14:00:46  goehler
; fix: no double report in log file
;
; Revision 1.9  2003/03/17 14:11:28  goehler
; review/documentation updated.
;
; Revision 1.8  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2003/02/26 08:47:54  goehler
; allow non existing commands to be executed as shell commands (spawn)
;
; Revision 1.6  2003/02/18 16:48:46  goehler
; added tutorial command. For this the tutorial should be given as a
; script with interspearsed (IDL) commands. exec is now able to execute a single line
; and to disable echo with the "#" prefix.
;
; Revision 1.5  2003/02/17 17:26:09  goehler
; Change: now really parsing the input line (avoid ";")
;
; Revision 1.4  2002/09/09 17:36:03  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


;; constants:

    ;; name of this source (needed for automatic help)
    NAME="exec"
    
    ;; line number counter:
    line = 0

    ;; the command line to read in:
    cmdline = ""

    ;; file handle for command file:
    cmdfile_lun=0

    ;; file handle for current command file:
    previous_cmdfile_lun = (*env).cmdfile_lun

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
    cafereport,env, "exec     - execute commands from separate file"
    return
  ENDIF


  ;;------------------------------------------------------------
  ;; OPEN COMMAND FILE
  ;;------------------------------------------------------------

  IF NOT keyword_set(interactive) AND NOT keyword_set(single) THEN BEGIN 

      ;; check existence:
      dummy=findfile(filename,count=count)
      IF count EQ 0 THEN BEGIN 
          cafereport,env, "Error: command file "+filename+" not found"
          return
      ENDIF

      ;; open in cmdfile_lun:
      get_lun, cmdfile_lun
      openr, cmdfile_lun, filename
      (*env).cmdfile_lun = cmdfile_lun
  ENDIF



  ;;------------------------------------------------------------
  ;; REPORT PARAMETERS:
  ;;------------------------------------------------------------
  IF n_elements(p1) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p1="+strtrim(string(p1),2),/keyvalpair),/nocomment
  IF n_elements(p2) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p2="+string(p2),/keyvalpair),/nocomment
  IF n_elements(p3) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p3="+string(p3),/keyvalpair),/nocomment
  IF n_elements(p4) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p4="+string(p4),/keyvalpair),/nocomment
  IF n_elements(p5) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p5="+string(p5),/keyvalpair),/nocomment
  IF n_elements(p6) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p6="+string(p6),/keyvalpair),/nocomment
  IF n_elements(p7) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p7="+string(p7),/keyvalpair),/nocomment
  IF n_elements(p8) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p8="+string(p8),/keyvalpair),/nocomment
  IF n_elements(p9) NE 0 THEN $
    cafereport, env, "!"+cafequotestr("p9="+string(p9),/keyvalpair),/nocomment

  
  ;;------------------------------------------------------------
  ;; MAIN PROCESSING LOOP 
  ;;------------------------------------------------------------

  WHILE 1 DO BEGIN 

    ;; catch errors:
    CATCH, ERR_STATE, /CANCEL
    IF ERR_STATE NE 0 THEN BEGIN
        CAFEREPORT,ENV, "ERROR WHEN PROCESSING ", $
               cmdline,"["+ strtrim(string(line),2)+"]"+":"
        CAFEREPORT,ENV, !ERR_STRING
    ENDIF

    ;;------------------------------------------------------------
    ;; QUIT PROGRAM WHEN EOF: 
    ;;------------------------------------------------------------

    IF  NOT keyword_set(interactive) AND eof(cmdfile_lun) THEN BREAK 


    ;;------------------------------------------------------------
    ;; READ COMMAND LINE
    ;;------------------------------------------------------------

    IF NOT keyword_set(interactive) AND NOT keyword_set(single) THEN $
      READF, cmdfile_lun, cmdline        

    IF keyword_set(interactive) THEN     $
      CAFEREAD,env, cmdline,             $
      prompt=strepex((*env).prompt,"%g",strtrim(string((*env).def_grp),2)),/nolog

    IF keyword_set(single) THEN     $
      cmdline=filename
   

    ;;------------------------------------------------------------
    ;; QUIT PROGRAM 
    ;;------------------------------------------------------------
    ;; check for quit -> exit:
    IF strcmp(cmdline,"QUIT", /fold_case) THEN BREAK 



    ;;------------------------------------------------------------
    ;; ECHO COMMAND LINE
    ;;------------------------------------------------------------

    ;; define silent case with "#":
    IF stregex(cmdline,"^ *#" ,/boolean) THEN BEGIN 

        hushup = 1

        ;; remove silent hush-up sign:
        cmdline = strmid(strtrim(cmdline,2),1) ; remove "#"

    ENDIF ELSE BEGIN 
        hushup =  0
    ENDELSE 

       
    ;; no prompt:
    prompt = ""

    ;; exclude special case of batch/exec commands:
    IF stregex(cmdline,"^ *@" ,/boolean) OR $
      stregex(cmdline,"^ *exec *," ,/boolean,/fold_case) THEN BEGIN 

        cafereport,env, "---------------------------------------------------" 
        prompt = "; BATCH: "
    ENDIF 


    ;; report command line if valid command:
    IF stregex(cmdline,"^ *(@|[a-zA-Z]|!)" ,/boolean) $
      OR keyword_set(fullbatch)                       $
      OR keyword_set(interactive) THEN    BEGIN 

        ;; show prompt on screen: 
        IF NOT (keyword_set(interactive) OR hushup) THEN $
          print, strepex((*env).prompt,"%g",strtrim(string((*env).def_grp),2)), format="(A,$)"

        ;; write command line to log/screen
        cafereport,env,prompt+cmdline, /nocomment,      $ ; report without comment
          silent=(keyword_set(interactive) OR hushup) ; to logfile only if interactive/hushup
    ENDIF 


    ;;------------------------------------------------------------
    ;; EXECUTE IDL COMMANDS:
    ;;------------------------------------------------------------
    IF stregex(cmdline,"^ *!" ,/boolean) THEN BEGIN
        cmdline = strmid(strtrim(cmdline,2),1) ; remove "!"
        IF NOT execute(cmdline) THEN BEGIN              ; run command        
            cafereport,env, "Error:"+!ERR_STRING        
            IF NOT keyword_set(interactive) THEN BREAK  ; exit in error case
        ENDIF 
        CONTINUE 
    ENDIF


    ;;------------------------------------------------------------
    ;; EXECUTE BATCH COMMANDS (from file):
    ;;------------------------------------------------------------
    IF stregex(cmdline,"^ *@" ,/boolean) THEN BEGIN
        cmdline = strmid(strtrim(cmdline,2),1) ; remove "@"

        ;; quote string:
        cmdline = cafequotestr(cmdline)

        ;; run exec:
        IF NOT execute("cafe_exec,env,"+cmdline) THEN BEGIN ; call *this* routine 
            cafereport,env, "Error:"+!ERR_STRING            ; beg for no errors
            IF NOT keyword_set(interactive) THEN BREAK      ; exit in error case
        ENDIF 
        CONTINUE 
    ENDIF

    ;;------------------------------------------------------------
    ;; SKIP NO-COMMANDS
    ;;------------------------------------------------------------
    IF not stregex(cmdline,"^ *[a-zA-Z]+" ,/boolean) THEN CONTINUE



    ;;------------------------------------------------------------
    ;; BUILD COMMAND STRING LIST
    ;;------------------------------------------------------------

    parsestr = cmdline               ;; string to parse -> will be deleted
    command= cafeexecparse(parsestr)
    command = strtrim(command,2)  ; remove leading/trailing spaces

    ;;------------------------------------------------------------
    ;; CHECK EXISTENCE:
    ;;------------------------------------------------------------

    IF file_which((*env).praefix+command[0]+".pro") EQ "" THEN BEGIN 

      ;; no command -> execute in shell:
      cafereport,env, "Execute shell command: "+cmdline

      ;; actually run command
      spawn, cmdline

      CONTINUE 
    ENDIF 


    ;;------------------------------------------------------------
    ;; RUN MODULE COMMAND:
    ;;------------------------------------------------------------
    
    ;; build command with environment:
    command[0] = (*env).praefix+command[0]+",env"

    ;; quote arguments:
    IF n_elements(command) GT 1 THEN command[1:*] = cafequotestr(command[1:*])

    ;; build entire command:
    command=strjoin(command, ",")

    ;; RUN THE COMMAND
    IF NOT EXECUTE(command,1) THEN BEGIN 
        cafereport,env, "Error: "+!ERR_STRING    

        ; exit in error case
        IF NOT keyword_set(interactive) THEN BREAK
    ENDIF  

    ;; no loop in single command case:
    IF  keyword_set(single) THEN BREAK 

  ENDWHILE


  ;; close batch file:
  IF NOT keyword_set(interactive) AND NOT keyword_set(single) THEN BEGIN 

      ;; report: 
      cafereport,env, "END OF " + filename
      cafereport,env, "---------------------------------------------------" 
      close, cmdfile_lun
      free_lun,cmdfile_lun
      (*env).cmdfile_lun = previous_cmdfile_lun
  ENDIF 

  RETURN  
END
