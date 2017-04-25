;+
; Project     : SOHO - CDS     
;                   
; Name        : GAUSS_PUT()
;               
; Purpose     : Load a 1-d or 2-d Gaussian into an array.
;               
; Explanation : Creates an array or image with a Gaussian profile in it.
;               
; Use         : IDL>  array = gauss_put(nx,ny,ht,xcen,sigx [,ycen,sigy,back])
;    
; Inputs      : nx, ny  -  size of output array. NY must be set to zero
;                          to obtain a 1-d array
;               ht      -  central intensity of gaussian
;               xcen    -  x location of centre of profile
;               sigx    -  standard deviation in x direction
;      
;               
; Opt. Inputs : ycen    -  y location of centre of profile
;               sigy    -  standard deviation in y direction
;               
; Outputs     : Function returns vector or array 
;               
; Opt. Outputs: None
;               
; Keywords    : BACKGROUND    -  background level to be added
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Utility, numerical
;               
; Prev. Hist. : I presume everyone has one!
;
; Written     : C D Pike, RAL, 3-Jul-95
;               
; Modified    : Fix 1-d bug (no background).  CDP, 07-Sep-95
;
; Version     : Version 2, 07-Sep-95
;-            

function gauss_put, nx, ny, ht, x0, sigx, y0, sigy, background=background

if not keyword_set(background) then background = 0

;
;  require minimum of parameters
;
if n_params() lt 5 then begin
   print,'Use: IDL>  array = gauss_put(nx,ny,ht,xcen,sigx [,ycen,sigy,back=b])'
   return,0
endif

 
;
;  calculate x direction at least
;
if n_elements(nx) gt 1 then begin
   tempx = nx  - x0
endif else begin
   tempx = findgen(nx)-x0   
endelse
tempx = ht*exp(-tempx*tempx/(2.0*sigx*sigx))

;
;  if no y dimension then that's all
;
if ny eq 0 then return,tempx + background


;
;  wanted 2-d array so do y direction
;
tempy = findgen(ny)-y0
tempy = exp(-tempy*tempy/(2.0*sigy*sigy))

;
;  multiply x and y profiles and return
;

return, (tempx#tempy) + background
end
