function img_wt_sum,img1,wt1,img2,wt2 
;+ 
; NAME: 
;                       IMG_WT_SUM 
; 
; PURPOSE: 
;                       This function routine performs a weighted sum 
;                       of two images. 
; 
; CATEGORY: 
;                       ANALYSIS 
; 
; CALLING SEQUENCE: 
;                       Result = IMG_WT_SUM (Img1,Wt1,Img2,Wt2) 
; 
; INPUTS: 
;                       Img1:   Array containing image #1 
;                       Wt1:            Array containing the weights for 
;                                       image #1 
;                       Img2:   Array containing image #2  
;                       Wt2:            Array containing the weights for 
;                                       image #2 
; 
; OPTIONAL INPUTS: 
;        
; KEYWORD PARAMETERS: 
; 
; OUTPUTS: 
;                       Result: The sum of the two input images if 
;                                       the operation is successful or -1 
;                                       if it is not. 
; 
; OPTIONAL OUTPUTS: 
; 
; COMMON BLOCKS: 
;                       None 
; 
; SIDE EFFECTS: 
;                       None 
; 
; RESTRICTIONS: 
;                       The size of all of the arrays must be the 
;                       same or the routine will exit and set result 
;                       to be -1. 
; 
; PROCEDURE: 
;                       The size of the arrays is verified to be the  
;                       same. 
;                       The weights are set to zero where the image  
;                       values are zero. 
;                       The normalizing factor is computed and set to  
;                       1 where the factor is 0. 
;                       Then the routine forms the weighted sum. 
;  
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
;       Written by:     RA Howard, NRL, 27 November 1995 
; 
;	@(#)img_wt_sum.pro	1.1 10/04/96 LASCO IDL LIBRARY
;- 
; 
;   Check all the input arrays to make sure they have 
;   the same size 
; 
s1 = size(img1) 
s  = size(img2) 
if ((s1(1) ne s(1)) or (s1(2) ne s(2))) then return,-1 
s  = size(wt1) 
if ((s1(1) ne s(1)) or (s1(2) ne s(2))) then return,-1 
s  = size(wt2) 
if ((s1(1) ne s(1)) or (s1(2) ne s(2))) then return,-1 
; 
;   Set the weight value to zero where the image is zero 
; 
w = where (img1 eq 0)
sw = size(w)
if (sw(0) ne 0) then wt1(w) = 0 
w = where (img2 eq 0)
sw = size(w)
if (sw(0) ne 0) then wt2(w) = 0 
; 
;   Compute the normalizing factor 
; 
sum_wt = wt1+wt2 
w = where(sum_wt eq 0)
sw = size(w)
if (sw(0) ne 0) then sum_wt(w) = 1 
sum_wt = 1.0/sum_wt 
; 
;  now do the weighted sum 
; 
return,(wt1*img1+wt2*img2)*sum_wt 
end 
 
