PRO parse_cpix,header,binning
;+
; NAME:
;       parse_cpix
;
;
; PURPOSE:
;       Decode the information contained in the CPIX keyword of the
;       PHA-II data header
;
; CATEGORY:
;       FITS
;
; CALLING SEQUENCE:
;       parse_cpix,header,binning
; 
; INPUTS:
;       header : FITS header as returned from fxbopen
;
; OPTIONAL INPUTS:
;       none
;
; KEYWORD PARAMETERS:
;       none
;
; OUTPUTS:
;       binning : array[2,N] of channel boundaries
;
; OPTIONAL OUTPUTS:
;       none
;
; COMMON BLOCKS:
;       none
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       none
;
; PROCEDURE:
;       TBW
;
; EXAMPLE:
;       see CALLING SEQUENCE
;
;
; MODIFICATION HISTORY:
;       Version 1.0: 1999/11/12 PK
;                    first version
;       Version 1.1: 2000/02/01 PK
;                    Recognize CPIX statement like 0:255
;-

    line=0
    ;; Jump over preceding strings
    WHILE ((line LT n_elements(header)) AND $
           strpos(header(line),'CPIX') EQ -1) DO line=line+1
    
    IF (line GE n_elements(header)) THEN BEGIN
        print,'parse_cpix error: no CPIX keyword found'
        RETURN
    ENDIF

    ;;
    ;; build up one very long string to parse
    ;; and clean out all the clutter
    ;;
    parseline = ''
    REPEAT BEGIN
        addline=header(line)
        first=strpos(addline,"'")
        last=strpos(addline,"&")
        IF (last EQ -1) THEN last=strpos(header(line),"'",first+1)
        IF (last EQ -1) THEN BEGIN
            print,'parse_cpix error: can not parse this header'
            RETURN
        ENDIF
        addline=strmid(addline,first+1,last-first-1)
        parseline=parseline+addline
        line=line+1
    ENDREP UNTIL (strpos(header(line),'CONTINUE') EQ -1)


    ;; set up binning
    binning = replicate(-1,2,512)
    nbin = 0
    
    ;; if the parseline is something like 0:255 don't do anything fancy
    ;; just set the boundaries to [0,0],[1,1],...
    ;; otherwise scan the whole line carefully
    colon=strpos(parseline,":",0)

    IF (colon NE -1) THEN BEGIN
        last=strpos(parseline," ",first+1)
        IF (last EQ -1) THEN BEGIN
            last=strlen(parseline)
        ENDIF
        part=strmid(parseline,0,last)
	before = fix(strmid(part,0,colon))
	after  = fix(strmid(part,colon+1,strlen(part)-colon-1))
	nbin = after-before+1
	FOR i=before,after DO BEGIN
            binning(*,i) = [i,i]
        ENDFOR
    ENDIF ELSE BEGIN 
        ;;
        ;; work from comma to comma, 
        ;; if we run out of commas use "&" or the "'" at the end of the string
        ;;
        first=0
        no_more_commas = 0
        REPEAT BEGIN
            last=strpos(parseline,",",first+1)
            IF (last EQ -1) THEN BEGIN
                no_more_commas = 1
                last=strlen(parseline)
            ENDIF
            part=strmid(parseline,first,last-first)
            ;;
            ;; see if we find a "~" or ":"
            ;; if yes then the number before goes to binning(0,n)
            ;;             and the number after to binning(1,n)
            ;; if no then the number gets repeated
            tilde = strpos(part,"~")
            IF (tilde EQ -1) THEN BEGIN
                binning(*,nbin) = [fix(part),fix(part)]
            ENDIF ELSE BEGIN
                before = fix(strmid(part,0,tilde))
                after  = fix(strmid(part,tilde+1,strlen(part)-tilde-1))
                binning(*,nbin) = [before,after]
            ENDELSE
            first=last+1
            nbin=nbin+1
        ENDREP UNTIL no_more_commas 
    ENDELSE

    ;; limit to actually used bins
    binning=binning(*,0:nbin-1)

    RETURN
END
