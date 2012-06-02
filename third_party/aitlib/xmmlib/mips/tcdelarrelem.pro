FUNCTION tcdelarrelem,arr,delind
   
;+
; NAME:            tcdelarrelem
;
;
;
; PURPOSE:
;		   delete all elements indexed in delind from array arr
;
;
; CATEGORY:
;                  used by tcreemcheck.pro
;
;
; CALLING SEQUENCE:
;                  result=tcdelarrelem,arr,delind
;
; 
; INPUTS:
;                  arr1: array
;                  delind: index of elements that are to be deleted
;                          from array
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
;                  -1 if an error occurs (esp. if array and index
;                  don't fit), 0 if no elements are deleted, 1 if some
;                  elements are deleted
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
;                  
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 07.09.00 T. Clauss first version
;-
   
   
   narr=n_elements(arr)
   nind=n_elements(delind)
   
   IF ((max(delind) GT narr-1) OR (min(delind) LT 0)) THEN BEGIN
       print,'%TCDELARRELEM: incorrect element indices. Returning...'
       return,-1
   ENDIF
          
   ind=lindgen(narr)
   
   FOR i=0,nind-1 DO ind(delind(i))=-1
   
   dind=where(ind NE -1)
   
   IF dind(0) NE -1 THEN BEGIN 
       ind=ind(dind)
       arr=arr(ind)
       res=1
   ENDIF ELSE BEGIN
       arr=0
       res=0
   ENDELSE 
   return,res
END












