PRO  cafe_show, env,                              $
                  topic, transient=transient,       $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show
;
; PURPOSE:
;           displays fit results/general status of environment
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           show [,topic[...+topic]] 
;
; INPUT:
;           topics- String which describes what to show. A topic is an
;                   identifier referring to a subtask. It is possible
;                   to add several topics with "+".
;                   If no topic is given the last topic(s) shown will
;                   be displayed. 
;                   A complete list of topics is given with
;                   > help, show,all
;
;                   General topics are:
;                     data   - shows data sets loaded. 
;                     result - shows fit results - parameter and statistics
;                     model  - show models defined (for all groups) 
;                     files  - show data files using
;                     free   - show free parameters
;                     
; OPTIONS:
;           transient - do not store topic for future show calls.
; 
; DESCRIPTION:
;           Show mainly lists fit results. It also can be used to
;           get information about the current system state (models
;           used, parameters defined with the actual parameter
;           number, files used etc.)
;
; SIDE EFFECTS:
;           None
;
; EXAMPLE:
;
;               > show, result+files
;
; HISTORY:
;           $Id: cafe_show.pro,v 1.5 2003/03/17 14:11:35 goehler Exp $
;-
;
; $Log: cafe_show.pro,v $
; Revision 1.5  2003/03/17 14:11:35  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:26  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:11  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show"


    ;; prefix for all topics:
    SHOW_PREFIX = "cafe_show_"

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
        cafereport,env, "show     - shows fit results/general information"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; GET ALL TOPICS
    ;; ------------------------------------------------------------
    

    alltopiclist = ""
    directory=$                 ; look for file cafe.pro, extract path
              (stregex(file_which((*env).name+".pro"),$
                       "(.*)("+(*env).name+".pro)",/extract,/subexpr))[1]
    
    ;; then: look for all files starting with "foo_",
    ;; and cut following topic which will be displayed 
    subtopics=findfile(directory+(*env).praefix+"*.pro")
    

    ;; cut all subtopics found above, under current topic:
    ;; topics/subtopics are separated by "_"
    ;; e.g. cafe_model_lin.pro -> topic model, subtopic lin
    subtopics=stregex(subtopics, $
                      ".*/"+SHOW_PREFIX+"([a-zA-Z]+).pro",$
                         /extract,/subexpr)
    subtopics=subtopics[1,*]
        
    index = where(subtopics NE "")
        
    subtopics = subtopics[index]
    
    
    ;; sort subtopics:
    subtopics=subtopics[sort(subtopics)]
    all_topics=strjoin(subtopics,"+",/single)
    
    ;; ------------------------------------------------------------
    ;; EXTRACT TOPICS
    ;; ------------------------------------------------------------

    ;; set default when not defined
    IF n_elements(topic) EQ 0 THEN BEGIN 
        topic = (*env).show.topic
        cafereport,env, "Show: "+topic
    ENDIF 

    IF topic EQ "all" THEN topic = all_topics

    ;; store topic if not transient
    IF NOT keyword_set(transient) THEN (*env).show.topic = topic

    topiclist = strsplit(topic,'+',/extract)


    ;; ------------------------------------------------------------
    ;; RUN TOPICS
    ;; ------------------------------------------------------------

    FOR i = 0, n_elements(topiclist)-1 DO BEGIN               
        call_procedure, SHOW_PREFIX+topiclist[i],env
    ENDFOR 



  RETURN  
END


