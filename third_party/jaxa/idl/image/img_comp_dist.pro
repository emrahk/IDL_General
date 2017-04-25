function img_comp_dist,img1,img2,sun,r1,r2 
;+ 
; NAME: 
;                       IMG_COMP_DIST 
; 
; PURPOSE: 
;                       This function routine creates a composite  
;                       image from two images based on two radial  
;                       distances.   For radii less than R1, the  
;                       values from image #1 are used.  For radii  
;                       greater than R2, the values from image  #2  
;                       are used.  For radii between R1 and R2, the  
;                       values fade linearly from image #1 to #2. 
; 
; CATEGORY: 
;                       ANALYSIS 
; 
; CALLING SEQUENCE: 
;                       Result = IMG_COMP_DIST (Img1,Img2,Sun,R1,R2) 
; 
; INPUTS: 
;                       Img1:   Array containing image #1 
;                       Img2:   Array containing image #2 
;                       Sun:            A four element array containing the  
;                                       solar coordinates: 
;                                       Column of the center of the sun 
;                                       Row of the center of the sun 
;                                       Roll angle to solar north 
;                                       Plate scale in arc secs per pixel 
;                       R1:             Radius specifying the outer  
;                                       boundary of only Img1  
;                       R2:             Radius specifying the inner 
;                                       boundary of only Img2 
; 
; OPTIONAL INPUTS: 
;                       None 
;        
; KEYWORD PARAMETERS: 
;                       None 
; 
; OUTPUTS: 
;                       Result: The composite of the two input  
;                                       images if the operation is  
;                                       successful or -1 if it is not. 
; 
; OPTIONAL OUTPUTS: 
;                       None 
; 
; COMMON BLOCKS: 
;                       None 
; 
; SIDE EFFECTS: 
;                       None 
; 
; RESTRICTIONS: 
;                       The plate scale and sun center must be the 
;                       same for the two images prior to entering the  
;                       routine. 
;                       The size of both arrays must be the same or  
;                       the routine will exit and set result to be  
;                       -1. 
; 
; PROCEDURE: 
;                       The procedure, SUNDIST, is called to compute  
;                       the distance matrix from sun center. 
;                       The two weighting functions are computed. 
;                       Then the routine, IMG_WT_SUM, is called. 
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
;       Written by:     RA Howard, NRL, 27 November 1995 
; 
;	@(#)img_comp_dist.pro	1.1 10/04/96 LASCO IDL LIBRARY
;- 
; 
; 
;   generate an array, the same size as img1 
;   whose elements are the distance of that pixel from sun  
;   center 
; 
s = size(img1) 
sundist,sun,d,angle,xsize=s(1),ysize=s(2) 
; 
;   Compute the weights in the range [0,1] for the outer  
;   image.  Then set the values to be 1 if greater than R2 
;   and to be 0 if less than R1. 
; 
wt2 = ((d-r1)/(r2-r1))<1 
wt2 = wt2>0 
wt1 = 1-wt2 
return,img_wt_sum(img1,wt1,img2,wt2) 
end 
 
