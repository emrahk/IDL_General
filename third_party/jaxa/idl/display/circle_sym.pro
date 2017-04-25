;+
; Project     : SOHO - CDS     
;                   
; Name        : CIRCLE_SYM
;               
; Purpose     : Define (part of) a circle as the user plotting symbol.
;               
; Explanation : Calls usersym to define an circle as the user symbol
;               to be used when psym=8 is specified in (o)plot. The symbol
;               will be filled if requested.
;               
; Use         : IDL> circle_sym, quad, thick=2, /fill
;               IDL> plot,indgen(10),psym=8
;    
; Inputs      : quad  - defines which quadrant of the circle to plot.
;                       zero or undefined means use full circle.
;               
; Opt. Inputs : None
;               
; Outputs     : None
;               
; Opt. Outputs: None
;               
; Keywords    : thick   = the thickness of the perimeter line
;               fill    = means fill the symbol
;		symsize = the size of the symbol
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, plotting
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 21-Apr-94
;               
; Modified    : Version 2, 16-Aug-1999, William Thompson, GSFC
;			Added keyword SYMSIZE
;
; Version     : Version 2, 16-Aug-1999
;-            

pro circle_sym,quad,thick=thick,fill=fill,symsize=k_symsize

;
;  check keyword existence
;
if keyword_set(thick) then t = thick else t = 1
if keyword_set(fill) then f = 1 else f = 0

;
;  check parameter existence and value
;
if n_params() eq 0 then quad = 0
if quad gt 4 then quad = 0

;
;  plot the QUADth quadrant
;
case quad of
  0: a = findgen(49)  * (!PI*2/48.) 
  1: a = (findgen(13))    *  (!PI*2/49.) 
  2: a = (findgen(13)+12.)*  (!PI*2/49.) 
  3: a = (findgen(13)+25.)*  (!PI*2/49.) 
  4: a = (findgen(13)+37.)*  (!PI*2/49.) 
  else: return
endcase

;
;  Determine the symbol size
;
if n_elements(k_symsize) eq 1 then symsize=k_symsize else symsize=1
;
;  set up the user symbol
;
if quad gt 0 then begin
   usersym,[0,sin(a),0]*symsize,[0,cos(a),0]*symsize,thick=t,fill=f
endif else begin
   usersym,sin(a)*symsize,cos(a)*symsize,thick=t,fill=f
endelse

end
