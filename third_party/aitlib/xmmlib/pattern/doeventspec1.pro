PRO doeventspec1,eventlist,eind,pcount,penergy,parpat
   
;+
; NAME:            
;                  doeventspec1
;
;
; PURPOSE:
;		   Rekursive pattern search, checking for edges  
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  
;
; 
; INPUTS:
;                  eventlist: data struct array with data from one frame
;                  eind: index of pixel to work on in the array
;                  pcount: number of pixels in this pattern so far
;                  penergy: sum of energy of the pixels in this pattern
;                           so far
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
;                  parpat: set to 1 if pattern touches one of the edges
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
;                  check if current pixel is at one of the edges,
;                  add energy of pixel to penergy, remove pixel from
;                  eventlist, look for next neighbor pixels 
;                  see code for details
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 22.03.00  T. Clauss initial version: added parpat to doeventspec.pro   
;-
   
   IF ((eventlist(eind).column EQ 0) OR (eventlist(eind).column EQ 63) OR $
       (eventlist(eind).line EQ 0) OR (eventlist(eind).line EQ 199)) THEN parpat=1
   
   penergy=penergy+eventlist(eind).energy
   eventlist(eind).energy=0
   pcount=pcount+1
   
   ind=where((eventlist.line EQ eventlist(eind).line+1) AND $
             (eventlist.column EQ eventlist(eind).column))
   IF (n_elements(ind) GT 1) THEN BEGIN
       print,'% doevent: mehrere Pixel an der gleichen Position!'
       eventlist(ind).energy=0
       return
   ENDIF
   IF (ind(0) NE -1) THEN BEGIN  
       IF (eventlist(ind(0)).energy GT 0.0) THEN BEGIN
           doeventspec1,eventlist,ind,pcount,penergy,parpat
       ENDIF  
   ENDIF 
       
   ind=where((eventlist.line EQ eventlist(eind).line) AND $
             (eventlist.column EQ eventlist(eind).column+1))
   IF (n_elements(ind) GT 1) THEN BEGIN
       print,'% doevent: mehrere Pixel an der gleichen Position!'
       eventlist(ind).energy=0
       return
   ENDIF
   IF (ind(0) NE -1) THEN BEGIN  
       IF (eventlist(ind(0)).energy GT 0.0) THEN BEGIN
           doeventspec1,eventlist,ind,pcount,penergy,parpat
       ENDIF  
   ENDIF 
   
   ind=where((eventlist.line EQ eventlist(eind).line-1) AND $
             (eventlist.column EQ eventlist(eind).column))
   IF (n_elements(ind) GT 1) THEN BEGIN
       print,'% doevent: mehrere Pixel an der gleichen Position!'
       eventlist(ind).energy=0
       return
   ENDIF
   IF (ind(0) NE -1) THEN BEGIN  
       IF (eventlist(ind(0)).energy GT 0.0) THEN BEGIN
           doeventspec1,eventlist,ind,pcount,penergy,parpat
       ENDIF  
   ENDIF
   
   ind=where((eventlist.line EQ eventlist(eind).line) AND $
             (eventlist.column EQ eventlist(eind).column-1))
   IF (n_elements(ind) GT 1) THEN BEGIN
       print,'% doevent: mehrere Pixel an der gleichen Position!'
       eventlist(ind).energy=0
       return
   ENDIF
   IF (ind(0) NE -1) THEN BEGIN  
       IF (eventlist(ind(0)).energy GT 0.0) THEN BEGIN
           doeventspec1,eventlist,ind,pcount,penergy,parpat 
       ENDIF  
   ENDIF

END
