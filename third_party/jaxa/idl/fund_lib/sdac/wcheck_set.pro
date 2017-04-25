;+
; Project     : SDAC
;                   
; Name        : WCHECK_SET
;               
; Purpose     : 
;		Checks whether a window has been created (window_in variable exists)
; 		and if so, sets the active window to that index.
;               
; Category    : GRAPHICS
;               
; Explanation : 
; 		Checks whether a window has been created (window_in variable exists)
; 		and if so, sets the active window to that index.  If not, creates a window
; 		with an unused index and returns that index in window_in.
;               
; Use         : wcheck_set, window_in, title=title, retain=retain, $
;                xpos=xpos, ypos=ypos, xsize=xsize, ysize=ysize
;
; Examples    :
;	 	wcheck_set, goes_window, title='GOES Plot', retain=2
;   
; Inputs      : Window_in - window index to check.
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : 
;		These keywords  have the same meaning as in the WINDOW procedure
;		title
;		retain
;		xpos
;		ypos
;		xsize
;		ysize
;
;
; Calls	      :
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  :
; Kim Tolbert   5/1/92
;
; Modified    : 
;		documented, richard.schwartz@gsfc.nasa.gov, 8-sep-1997.
;-            
;==============================================================================

pro wcheck_set, window_in, title=title, retain=retain, $
                xpos=xpos, ypos=ypos, xsize=xsize, ysize=ysize

@winup_common
checkvar, title, ' '
checkvar, retain, 2
checkvar, xpos, 620
checkvar, ypos, 512
checkvar, xsize, 640
checkvar, ysize, 512

s = size(window_in)
if s(1) eq 0 then goto, newwin

device, window=w
if w(window_in) eq 1 then begin
   q = where (windows_index eq window_in, count)
   if count eq 0 then goto,newwin
   if windows_title(q(0)) ne title then goto, newwin
   wset, window_in
   goto, getout
endif

newwin:
window, /free, title=title, retain=retain, xpos=xpos, ypos=ypos, $
        xsize = xsize, ysize=ysize
window_in = !d.window
winup, window_in, /add, title=title

getout:
return & end
