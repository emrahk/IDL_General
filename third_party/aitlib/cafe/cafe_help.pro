PRO  cafe_help, env, topic, subtopic,shorthelp=shorthelp
;+
; NAME:
;           help
;
; PURPOSE:
;           prints help of a standard command/model. 
;
; CATEGORY:
;           cafe 
;
; SYNTAX:
;           help, [topic][,subtopic]
;
; INPUT:
;           command/model - the command/model to get help for
;
; 
; SIDE EFFECTS:
;           None. 
;
;
; HISTORY:
;           $Id: cafe_help.pro,v 1.5 2003/03/03 11:18:22 goehler Exp $
;-
;
; $Log: cafe_help.pro,v $
; Revision 1.5  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2003/02/19 07:29:09  goehler
; allow non-IDL files to be subtopics (tutorial scripts)
;
; Revision 1.3  2003/02/18 16:48:47  goehler
; added tutorial command. For this the tutorial should be given as a
; script with interspearsed (IDL) commands. exec is now able to execute a single line
; and to disable echo with the "#" prefix.
;
; Revision 1.2  2002/09/09 17:36:03  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; ------------------------------------------------------------
    ;; SPECIAL TOPIC LIST
    ;; ------------------------------------------------------------

    ;; these topics must appear in this order:
    special_topic = ["cafe", "syntax", "maintenance"]


    ;; ------------------------------------------------------------
    ;; SHORT HELP
    ;; ------------------------------------------------------------
    IF keyword_set(shorthelp) THEN BEGIN  
        cafereport,env, "help     - print command information"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------
    
    ;; define subtopic to nothing as "":
    IF n_elements(subtopic) EQ 0 THEN $ ; no subtopic -> empty string
      subtopic =""               
    
    ;; ------------------------------------------------------------
    ;; HELP FOR ALL TOPICS:
    ;; ------------------------------------------------------------

    IF n_elements(topic) EQ 0 THEN BEGIN 

        ;; general remarks
        print, "'help' without commands lists all commands/topics available."
        print, "These topics are:" 

        
        commandlist = ""
        directory=$             ; look for file cafe.pro, extract path
                  (stregex(file_which((*env).name+".pro"),$
                           "(.*)("+(*env).name+".pro)",/extract,/subexpr))[1]
        
        ;; then: look for all files starting with "foo_",
        ;; and cut following command which will be displayed 
        commands=findfile(directory+(*env).praefix+"*.pro")

        ;; cut command itself (without pbath or extension)
        commands=stregex(commands,".*/([a-zA-Z]+_[a-zA-Z]+)\.pro",$
                         /extract,/subexpr)
        commands=commands[1,*]

        commands = commands[where(commands NE "")]

        ;; sort commands:
        commands=commands[sort(commands)]

        ;; resort special commands:
        ;; remove special topics              
        FOR i = 0, n_elements(special_topic)-1 DO $          
          commands = commands[where(strmatch(commands, (*env).praefix+special_topic[i]) EQ 0)]

        ;; prepend special topic commands:
        commands = [(*env).praefix+special_topic,commands]

        ;; call each command with its shorthelp flag:
        FOR i = 0, n_elements(commands)-1 DO BEGIN  
            call_procedure,commands[i],env,/shorthelp 
        ENDFOR

        print,""
        print, "Type 'help, <command>' to get more information" 
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; HELP FOR ALL SUBTOPICS:
    ;; ------------------------------------------------------------

    IF subtopic EQ "all" THEN BEGIN 

        ;; general remarks
        print, "'help, "+topic+ $
               ", all' lists all "+topic+"s"+" available."
        print, "These are:" 

        
        subtopiclist = ""
        directory=$             ; look for file cafe.pro, extract path
                  (stregex(file_which((*env).name+".pro"),$
                           "(.*)("+(*env).name+".pro)",/extract,/subexpr))[1]
        
        ;; then: look for all files starting with "foo_",
        ;; and cut following topic which will be displayed 
        subtopics=findfile(directory+(*env).praefix+"*.*")


        ;; cut all subtopics found above, under current topic:
        ;; topics/subtopics are separated by "_"
        ;; e.g. cafe_model_lin.pro -> topic model, subtopic lin
        subtopics=stregex(subtopics, $
                          ".*/"+(*env).praefix+topic+"_([a-zA-Z]+).*",$
                         /extract,/subexpr)
        subtopics=subtopics[1,*]


        index = where(subtopics NE "")

        ;; check for existence
        IF index[0] EQ -1 THEN BEGIN 
            cafereport,env, "Error: no subtopics for "+topic+" available"
            return
        ENDIF 

        subtopics = subtopics[index]


        ;; sort subtopics:
        subtopics=subtopics[sort(subtopics)]

        ;; list all subtopics (do not call shorthelp because
        ;; it is not clear whether subtopics are procedures or
        ;; functions) 
        FOR i = 0, n_elements(subtopics)-1 DO BEGIN  
            print,subtopics[i]
        ENDFOR

        print,""
        print, "Type 'help, "+topic+",<subtopic>' to get more information" 
        return
    ENDIF




  ;; ------------------------------------------------------------
  ;; HELP FOR SPECIFIC TOPIC/SUBTOPIC
  ;; ------------------------------------------------------------    


    IF subtopic NE "" THEN $   ; subtopic given  -> add "_" as separator
      subtopic ="_"+subtopic               
    
    ;; set the filename:
    filename = (*env).name+"_"+topic+subtopic+".*"


    ;; print the specification of a certain command/model with given name, 
    ;; without comment chars.
    ;; This will allow maintain these files easier by only changing the
    ;; header but nothing else and keep the help up to date. 
    ;; Thus do not change the code below but only the header.  
    helpfile=file_which(filename)   ; look for help source file

    ;; no helpfile given -> error
    IF helpfile EQ "" THEN BEGIN
        cafereport,env, "Error: "+topic+subtopic+" not found"
        return
    ENDIF

    ;; read in command file, display header:
    get_lun,helpfile_lun        ; open it 
    openr, helpfile_lun, helpfile
    s = ""
    CAFEREPORT,ENV,"" ; empty line
    WHILE NOT eof(helpfile_lun) AND NOT (s EQ ";-") DO BEGIN  ; for each line
        readf, helpfile_lun, s                                 
        IF stregex(s,"^;([^+-].*)?$",/boolean) THEN $             ; look for ";"
          CAFEREPORT,ENV, strmid(s,1)    ; but not ";+", ";-"
    ENDWHILE                               ; print this line
    CLOSE,helpfile_lun

  RETURN  
END



