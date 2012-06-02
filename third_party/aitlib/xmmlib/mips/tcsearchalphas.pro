FUNCTION tcsearchalphas,fdat1,fdat2,f1ind
   
;+
; NAME:            tcsearchalphas
;
;
;
; PURPOSE:
;		   check for traces of highly ionizing particles 
;
;
; CATEGORY:
;                  used by tcmiptracecorr.pro
;
;
; CALLING SEQUENCE:
;                  index=tcsearchalphas,frame1data,frame2data,frame1index
;
; 
; INPUTS:
;                  fdat1: data struct array of data in the frame to be searched
;                  fdat2: data struct array of data in following frame
;                  f1ind: index of elements in fdat1 that are to be
;                         checked for highly ionizing particles 
;   
;
; OPTIONAL INPUTS:
;                  none
;   
;
; KEYWORD PARAMETERS:
;                  none
;
;
; OUTPUTS:
;                  index of all elements in fdat1 that fullfill the
;                  criteria for highly ionizing particles (see below),
;                  -1, if there is no such element
;
;
; OPTIONAL OUTPUTS:
;		   none
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  none
;
;
; PROCEDURE:
;                  check each element of fdat1 that is indexed in
;                    f1ind for fullfilling at least one of the following criteria:
;                     - there is an event in the next line in the same column
;                     - there is another event from f1ind in the same
;                       line in one of the adjoining columns which is
;                       followed by any event in the next line in the
;                       same column 
;                  if the event is in line 199, then check data in
;                    next frame (not yet realized) 
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 11.09.00 T. Clauss first version
;-
   ind1=f1ind
   
   result=-1
   
   FOR i=0,n_elements(ind1)-1 DO BEGIN
       IF ind1(0) NE -1 THEN BEGIN
           col=fdat1(ind1(i)).column
           line=fdat1(ind1(i)).line
           IF line LT 199 THEN BEGIN
               ;; check for event in same column
               ind=where((fdat1.column EQ col) AND (fdat1.line EQ line+1))
               IF ind(0) EQ -1 THEN BEGIN 
                   ;; check for high energy event in first neighbor column
                   ind=where((fdat1(ind1).column EQ col+1) AND (fdat1(ind1).line EQ line))
                   IF ind(0) EQ -1 THEN BEGIN
                       ;; check for high energy event in second neighbor column
                       ind=where((fdat1(ind1).column EQ col-1) AND (fdat1(ind1).line EQ line))
                       IF ind(0) EQ -1 THEN BEGIN 
                           ind1(i)=-1
                       ENDIF ELSE BEGIN
                           ;; check for event in same column
                           ind=where((fdat1.column EQ col-1) AND (fdat1.line EQ line+1))
                           IF ind(0) EQ -1 THEN ind1(i)=-1
                       ENDELSE 
                   ENDIF ELSE BEGIN
                       ;; check for event in same column
                       ind=where((fdat1.column EQ col+1) AND (fdat1.line EQ line+1))
                       IF ind(0) EQ -1 THEN ind1(i)=-1
                   ENDELSE
               ENDIF 
           ENDIF ELSE BEGIN
               ;; check next frame: tbd, until then assume alpha
               ; ind=where((fdat2.column EQ col) AND (fdat2.line EQ line+1-200))
               ; IF ind(0) EQ -1 THEN ind1(i)=-1
           ENDELSE
       ENDIF
   ENDFOR
   
   ind=where(ind1 NE -1)
   
   IF ind(0) NE -1 THEN BEGIN
       result=ind1(ind)
   ENDIF ELSE BEGIN
       result=-1
   ENDELSE
   
   return,result
   
END
