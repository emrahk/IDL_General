
;+
; Project     : SDAC
;                   
; Name        : XY0
;               
; Purpose     : This procedure resets the x and y axes defaults.
;               
; Category    : GRAPHICS
;               
; Explanation : XY0 sets input x axis range and y axis range to [0,0] for autoscaling.
;
; Use         : XY0
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls       :
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  : akt, 1989
;
; Modified    : 
;	richard.schwartz@gsfc.nasa.gov
;-            
;==============================================================================
PRO XY0
!X.RANGE = 0
!Y.RANGE = 0
END
