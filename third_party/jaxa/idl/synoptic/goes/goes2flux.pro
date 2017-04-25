;+
; Project     : SOHO - CDS     
;                   
; Name        : GOES2FLUX()
;               
; Purpose     : Convert GOES class to flux.
;               
; Explanation : Translates string giving GOES class of a flare to flux
;               in watts/sq m.
;               
; Use         : IDL> Flux = goes2flux(class)
;    
; Inputs      : class  -  (string array) GOES class, 
;                          eg 'M3.2' or ['M3.2','C1.4']
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns flux in watts/sq m.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 17-oct-94
;               
; Modified    : 
;
; Version     : Version 1, 17-Oct-94
;-            

function goes2flux,class

;
;  size of input
;
num = fltarr(n_elements(class))

;
;  safety
;
class = strupcase(class)

;
;  do each class separately
;
n = where(strmid(class,0,1) eq 'A')
if n(0) ge 0 then num(n) = float(strmid(class(n),1,3)) * 1.0e-8

n = where(strmid(class,0,1) eq 'B')
if n(0) ge 0 then num(n) = float(strmid(class(n),1,3)) * 1.0e-7

n = where(strmid(class,0,1) eq 'C')
if n(0) ge 0 then num(n) = float(strmid(class(n),1,3)) * 1.0e-6

n = where(strmid(class,0,1) eq 'M')
if n(0) ge 0 then num(n) = float(strmid(class(n),1,3)) * 1.0e-5

n = where(strmid(class,0,1) eq 'X')
if n(0) ge 0 then num(n) = float(strmid(class(n),1,3)) * 1.0e-4

;
;  scalar out if scalar in
;
if n_elements(class) eq 1 then num = num(0)

return,num

end
