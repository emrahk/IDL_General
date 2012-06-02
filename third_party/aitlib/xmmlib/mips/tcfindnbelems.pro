FUNCTION tcfindnbelems,arr,indelem,range=range
   
    
;+
; NAME:            tcfindnbelements
;
;
;
; PURPOSE:
;		   find all adjoining elements in arr that differ by
;		   less than +- range from one another, starting from indelem
;
;
; CATEGORY:
;                  used by tcreemcheck
;
;
; CALLING SEQUENCE:
;                  index=tcfindnbelems,arr,indelem,range=range
;
; 
; INPUTS:
;                  arr: array
;                  indelem: index of element to start with
;   
;
; OPTIONAL INPUTS:
;                  range: range for adjoining elements (default: 1.0)
;   
;
; KEYWORD PARAMETERS:
;                  none
;
;
; OUTPUTS:
;                  index of all adjoining elements in arr that differ by
;		   less than +- range from one another, starting from indelem
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
; V1.0 06.09.00 T. Clauss first version
;-
   
   
   IF NOT keyword_set(range) THEN range=1.0
   
   resind=indelem
   
   FOR i=0,n_elements(indelem)-1 DO BEGIN 
   
       elem=arr(indelem(i))              
       ind=indelem(i)
       ind1=where((arr LE elem+range) AND (arr GE elem-range))
       
       WHILE n_elements(ind) NE n_elements(ind1) DO BEGIN 
           ind=ind1
           maxelem=max(arr(ind))
           minelem=min(arr(ind))
           ind1=where((arr LE maxelem+range) AND (arr GE minelem-range))
       ENDWHILE
       
       resind=[resind,ind]
       
   ENDFOR 
   
   resind=resind(sort(resind))
   resind=resind(uniq(resind))
   
   return,resind
   
END
