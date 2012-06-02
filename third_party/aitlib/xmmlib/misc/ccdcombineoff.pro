function ccdcombineoff,ccds,noise=noise
;+
; NAME: ccdcombineoff
;
;
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;               Do not use getcountinfo just before this function
;               Do not use for offset, noise or dslin maps
;               Not split event correction
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
   IF (keyword_set(noise)) THEN array=fltarr(389,401) ELSE array=intarr(389,401) ; total ccd array

   array(*,*)=0
   ccd0=reverse(reverse(transpose(reform(ccds(0,*,*))),2),1)
   ccd1=reverse(reverse(transpose(reform(ccds(1,*,*))),2),1)
   ccd2=reverse(reverse(transpose(reform(ccds(2,*,*))),2),1)
   ccd3=reverse(reverse(transpose(reform(ccds(3,*,*))),2),1)
   ccd4=reverse(reverse(transpose(reform(ccds(4,*,*))),2),1)
   ccd5=reverse(reverse(transpose(reform(ccds(5,*,*))),2),1)
   ccd6=reverse(reverse(transpose(reform(ccds(6,*,*))),1),1)
   ccd7=reverse(reverse(transpose(reform(ccds(7,*,*))),1),1)
   ccd8=reverse(reverse(transpose(reform(ccds(8,*,*))),1),1)
   ccd9=reverse(reverse(transpose(reform(ccds(9,*,*))),1),1)
   ccd10=reverse(reverse(transpose(reform(ccds(10,*,*))),1),1)
   ccd11=reverse(reverse(transpose(reform(ccds(11,*,*))),1),1)
 
;; Quadrant 0  
   array(130:193,201:400)=ccd0
   array( 65:128,201:400)=ccd1
   array(  0: 63,201:400)=ccd2
;; Quadrant 1
   array(195:258,201:400)=ccd3
   array(260:323,201:400)=ccd4
   array(325:388,201:400)=ccd5
;; Quadrant 3
   array(195:258,  0:199)=ccd6
   array(260:323,  0:199)=ccd7
   array(325:388,  0:199)=ccd8
;; Quadrant 4
   array(130:193,  0:199)=ccd9
   array( 65:128,  0:199)=ccd10
   array(  0: 63,  0:199)=ccd11  
   return,array
END



