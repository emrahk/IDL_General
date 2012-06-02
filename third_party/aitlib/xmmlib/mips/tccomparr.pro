FUNCTION tccomparr,arr1,arr2,indarr1=indarr1,indarr2=indarr2
   
  
;+
; NAME:            tccomparr
;
;
;
; PURPOSE:
;		   Find positions of all entries in two arrays that
;		   are the same;
;                  resp. check if elements of one array are elements
;                  of another array, too
;
;
; CATEGORY:
;                  
;
;
; CALLING SEQUENCE:
;                  result=tccomparr,arr1,arr2,indarr1=indarr1,indarr2=indarr2
;
; 
; INPUTS:
;                  arr1, arr2: two arrays of the same type
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
;                  0 if no elements are found that are the same, 1 if 
;                  such elements are found
;
;
; OPTIONAL OUTPUTS:
;		   indarr1, indarr2: position of the same elements in
;		   arr1 and arr2  
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
    
   
   ;; find positions of all entries that are the same in two arrays
   ;; used by tcreemcheck
   
   l1=n_elements(arr1)
   l2=n_elements(arr2)
   indarr1=0l
   indarr2=0l
   
   found=0
   
   IF l2 GE l1 THEN BEGIN
       FOR i=0,l1-1 DO BEGIN
           pos=where(arr2 EQ arr1(i))
           IF pos(0) NE -1 THEN BEGIN
               found=1
               indarr1=[indarr1,i]
               indarr2=[indarr2,pos]
           ENDIF
       ENDFOR
       IF n_elements(indarr1) GT 1 THEN BEGIN
           indarr1=indarr1(1:*)
           indarr2=indarr2(1:*)
           indarr2=indarr2(sort(indarr2))
           indarr2=indarr2(uniq(indarr2))
       ENDIF ELSE BEGIN
           indarr1=-1
           indarr2=-1
       ENDELSE  
   ENDIF ELSE BEGIN
       FOR i=0,l2-1 DO BEGIN
           pos=where(arr1 EQ arr2(i))
           IF pos(0) NE -1 THEN BEGIN
               found=1
               indarr2=[indarr2,i]
               indarr1=[indarr1,pos]
           ENDIF
       ENDFOR
       IF n_elements(indarr2) GT 1 THEN BEGIN
           indarr2=indarr2(1:*)
           indarr1=indarr1(1:*)
           indarr1=indarr1(sort(indarr1))
           indarr1=indarr1(uniq(indarr1))
       ENDIF ELSE BEGIN
           indarr1=-1
           indarr2=-1
       ENDELSE 
   ENDELSE
   return, found
END

   
