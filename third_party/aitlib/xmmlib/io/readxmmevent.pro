PRO readxmmevent,files,events,debug=debug,data=data,fracexp=fracexp
;+
; NAME:
;        readxmmevent
;
;
; PURPOSE:
;        read XMM SAS produced event lists and return concatenated event list 
;
; CATEGORY:
;        XMM Newton software
;
;
; CALLING SEQUENCE:
;        readxmmevent,files,data,debug=debug
;
;
; INPUTS:
;        files: array of event files (...Events.ds)
;   
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;         debug: return debugging information if set
;         data : read data extension (default)
;         fracexp: read fractional exposure times
;
;
; OUTPUTS:
;         events: big array containing the contents of the events extension
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;        ... are evil
;
;
; SIDE EFFECTS:
;        might use LOTS of memory
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;         trivial, the only problem is that struct_assign has to be
;         used since mrdfits returns anonymous structures, and the
;         structure tags are different between subsequent invocations
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;         Version 0.1: Joern Wilms
;         Version 0.2: Joern Wilms, 2001/05/07, added fracexp keyword
;           and handling of fractional exposure times
;         CVS Initial version, 2001.05.23, JW
;-

    IF (NOT keyword_set(fracexp)) THEN data=1

    IF (keyword_set(data)) THEN extn=1    ;; events header
    IF (keyword_set(fracexp)) THEN extn=2 ;; deadtime header

    IF (keyword_set(debug)) THEN print,'Reading Data'
 
    FOR i=0,n_elements(files)-1 DO BEGIN 
        IF (keyword_set(debug)) THEN print,'  ',files[i]
        tmpdata=mrdfits(files[i],extn,header)
        IF i GT 0 THEN BEGIN 
            ;;
            ;; append data in tmpdata to events
            ;; 

            ;; ... new array for the data
            newdat=replicate(events[0],n_elements(tmpdata))
            ;; ... copy the newly read data, using a relaxed
            ;; ... structure assignment to get the same structure id
            ;; NOTE: temporary(tmpdata) does NOT work here!
            struct_assign,tmpdata,newdat
            ;; ... and append
            events=[events,newdat]
        ENDIF ELSE BEGIN 
            events=temporary(tmpdata)
        ENDELSE
    ENDFOR 

END 
