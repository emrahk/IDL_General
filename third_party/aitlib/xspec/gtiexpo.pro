FUNCTION gtiexpo,gti,smallwin=smallwin,tstart=tstart,tstop=tstop
;+
; NAME:
;
;
;
; PURPOSE:
; Compute the effective exposure time for an observation made from
; events measured between tstart and tstop that have been 
; preprocessed with gti-information in gti
;
; CATEGORY:
; X-ray data analysis
;
;
; CALLING SEQUENCE:
;  gtiexpo(gti,tstart=tstart,tstop=tstop)
;
;
; INPUTS:
;  gti: 2D array containing the gti times
;
;
; OPTIONAL INPUTS:
;  tstart, tstop: extraction was only performed for times between
;       tstart and tstop (default: min and max values of gti)
;
;
;
; KEYWORD PARAMETERS:
;   smallwin: if set, apply 71% lifetime of XMM-pn small window mode
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;     implicit assumption: gti is non-overlapping
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;   Version 0.1: 2001.05.08, Joern Wilms
;
;-

    IF (n_elements(tstart) EQ 0) THEN tstart=min(gti)
    IF (n_elements(tstart) EQ 0) THEN tstop=max(gti)


    expo=0.
    FOR i=0,n_elements(gti[0,*])-1 DO BEGIN 
       
        ;; pick GTI interval
        t1=gti[0,i] & t2=gti[1,i]
       
        ;; We need overlap between [tstart,tstop] and [t1,t2]
        IF (NOT ( (t2 LE tstart) OR (t1 GE tstop) )) THEN BEGIN 
            ;; Shrink GTI interval into overlap range
            IF (t1 LT tstart) THEN t1=tstart
            IF (t2 GT tstop) THEN t2=tstop
            ;; and add
            expo=expo+(t2-t1)
        ENDIF  
    ENDFOR 


    ;; NOT REALLY CORRECT...
    IF (keyword_set(smallwin)) then expo=expo*0.71


    return,expo
END 
