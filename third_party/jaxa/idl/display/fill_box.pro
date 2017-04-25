;+
; Project     : SOHO - CDS     
;                   
; Name        : FILL_BOX
;               
; Purpose     : To fill a plot box with one of a selection of patterns.
;               
; Explanation : In a line plot fill column from x-bin/2 to x+bin/2 and 
;               from y=0 to y with the selected pattern.
;               
; Use         : IDL> fill_box,x,y,bin [,patt, /border, ymin=ymin, /bstyle]
;    
;               
; Inputs      : x    -  the x-axis location of the box
;               y    -  the maximum y-axis extent of the box
;               bin  -  the width of the box on x-axis
;
; Opt. Inputs : patt -      0:  solid (default)
;                           1:  hatch backward
;                           2:  hatch forward
;                           3:  vertical
;                           4:  horizontal
;                           5:  grid
;                           6:  cross hatch
;                           7:  empty
;                     
;
; Outputs     : None
;               
; Opt. Outputs: None
;               
; Keywords    : border  - if present a border is drawn around the filled box.
;               ymin    - if present the box is filled from ymin to y otherwise
;                         from 0 to y.
;               bstyle  - sets line style for border or if requested
;
; Calls       : None
;               
; Restrictions: Plot must have been performed before call to this routine.
;               
; Side effects: None
;               
; Category    : Utilities, Plotting
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 10-May-1993
;               
; Modified    : Added ymin keyword.  CDP 21-Apr-94
;               Add empty possibility, add bstyle/outline keywords. 
;                                    CDP 14-Jul-94
;               Temporarily suspend X-windows mode.  CDP, 18-Jul-94
;               (It was crashing my Alpha)
;
; Version     : Version 3, 14-Jul-94
;-            

pro fill_box,x,y,bin,patt,border=border,ymin=ymin, bstyle=bstyle,$
    outline=outline


;
;  see if minimum y value set, otherwise use 0.0
;
if keyword_set(ymin) then y0 = ymin else y0 = 0.0

;
;  if pattern not defined then assume solid fill
;
if n_params() lt 4 then patt = 0

;
;  set up start and end x-axis limits
;
x1 = x - bin/2. &  x2 = x + bin/2.


;
;  different actions for different graphics device types
;
if !d.name eq 'Nonsense' then begin

;
;  set up basic pattern array for this device
;
   parr = bytarr(100,100)

   case patt of
      1:  for i=0,9999,11 do parr(i) = 255
      2:  begin
             for i=0,9999,11 do parr(i) = 255 
             parr = rotate(parr,1) 
          end
      3:  for i=0,9999,10 do parr(i) = 255
      4:  begin
             for i=0,9999,10 do parr(i) = 255 
             parr = rotate(parr,1) 
          end
      5:  begin
             for i=0,9999,10 do parr(i) = 255
             parr = rotate(parr,1)
             for i=0,9999,10 do parr(i) = 255
          end
      6:  begin
             for i=0,9999,11 do parr(i) = 255
             parr = rotate(parr,1)
             for i=0,9999,11 do parr(i) = 255
          end
      7:  parr(*) = 0
      else:  parr(*) = 255
   endcase
;
;  and fill area
;
   polyfill,[x1,x1,x2,x2],[y0,y,y,y0],pattern=parr

endif else begin
  
;
;  else achieve same effect with line drawing
;
   case patt of
     1: polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=45
     2: polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=135
     3: polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=90
     4: polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=0
     5: begin
           polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=0
           polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=90
        end
     6: begin
           polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=45
           polyfill,[x1,x1,x2,x2],[y0,y,y,y0],/line_fill,spacing=0.2,orient=135
        end
     7:
     else: polyfill,[x1,x1,x2,x2],[y0,y,y,y0]
   endcase
       
endelse   

;
;  if wanted, draw border
;
if not keyword_set(bstyle) then bstyle=0 
if keyword_set(border) then oplot,[x1,x2,x2,x1,x1],[y0,y0,y,y,y0],line=bstyle



end
