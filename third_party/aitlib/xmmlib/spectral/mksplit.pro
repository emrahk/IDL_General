FUNCTION mksplit,data,singles=singles,splits=splits,chatty=chatty
;+
; NAME:            mksplit
;
;
;
; PURPOSE:
;                  Apply split-event correction to a given data set
;                  and mark single-events with 0 and split-events with
;                  1.
;
;
; CATEGORY:
;                  XMM-Data analysis
;
;
; CALLING SEQUENCE:
;                  newdata=mksplit(data,/chatty)
;
; 
; INPUTS:
;                  data:   Data-array containing the line, column,
;                          time, ccd and energy information as a seven
;                          dimensional array e.g. as returned by
;                          mkreadquad.pro.
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;                  /chatty : Give more information on what's going
;                            on;
;
;
; OUTPUTS: 
;                            A seven dimensional array where the last
;                            dimension contains the information wether
;                            the event was a splitted one (1) or a
;                            single-event (0).
;
;
; OPTIONAL OUTPUTS:
;                  none
;
;
;
; COMMON BLOCKS:
;                  none
;
;
;
; SIDE EFFECTS:
;                  none
;
;
;
; RESTRICTIONS:
;                  none
;
;
;
; PROCEDURE:
;                  see code
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; V1.0 06.06.99 M. Kuster first initial version
; V1.1 12.08.99 M. Kuster Changed data format to structure 'data'
; V1.2 06.06.00 T. Clauss added (indccd) where noted
; V1.3 05.07.00 T. Clauss added verification that n_elements(indccd) gt 1
;   
;-
   IF (keyword_set(chatty)) THEN print,'% MKSPLIT: Working on split-event correction ...'
   
   FOR i=0,11 DO BEGIN 
       print,'% MKSPLIT: Applying split-event correction for CCD '+STRTRIM(i)
       indccd=where(data.ccd EQ i)
       IF (indccd[0] NE -1) THEN BEGIN 
           IF n_elements(indccd) GE 2 THEN BEGIN   ;; TC 
               er=n_elements(data(indccd).line)
               ;; search for events within one readout frame
               splid=where(shift(data(indccd).secbruch,-1)-data(indccd).secbruch,splnr)
               
               IF splnr GT 2 THEN BEGIN 
                   splid=[splid(0:splnr-2),er-1]
                   for ii=0l,splnr-2l DO data((indccd)(splid(ii)+1:splid(ii+1))).split=ii+1  ;; TC added (indccd)
               ENDIF 
               
               ;; search for splits in column direction
               spl1=data(indccd).line*65+data(indccd).column+data(indccd).split*13000
               spl1=where(spl1+1-shift(spl1,-1) EQ 0, spch1)
               sspl=lonarr(er+1)
               IF spch1 GT 0 THEN sspl([spl1,spl1+1])=1
               
               ;; search for splits in line direction
               spl2=data(indccd).column*201+data(indccd).line+data(indccd).split*12864
               spl3=sort(spl2)
               spl4=where(spl2(spl3)+1-shift(spl2(spl3),-1) EQ 0, spch2)
               IF spch2 GT 0 THEN sspl([spl3(spl4),spl3(spl4+1)])=1
               sspl=sspl(0:er-1)
               data(indccd).split=sspl
               IF (spch1 GT 0) AND (spch2 GT 0) AND keyword_set(chatty) THEN BEGIN 
                   print,'% MKSPLIT: Anteil der Splits nach oben: ',$
                     float(spch2)/(spch1+spch2)   
               ENDIF 
           ENDIF
       ENDIF
   ENDFOR 
   singles=data(where(data.split EQ 0))
   splits=data(where(data.split EQ 1))
   return,data
END 
