;+
; Project     : SOHO - CDS     
;                   
; Name        : CLIPBOX
;               
; Purpose     : To draw a box around the outside of the clip box
;               
; Explanation : PLOTS is used to draw a box on the outside of clip box.
;               
; Use         : CLIPBOX,THICK
;    
; Inputs      : None necessary.
;               
; Opt. Inputs : THICK : Thickness of the line. Default 1
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : 
;               
; Prev. Hist. : None.
;
; Written     : SVHH, 26 May 1994
;               
; Modified    : 
;
; Version     : 1 - 26 May 1994
;-            

FUNCTION cceil,a ; Fix IDL v 3.0
  IF a eq fix(a) THEN return,a
  return,fix(a)+1
END

FUNCTION cround,a
  return,fix(a+.5d)
END


PRO clipbox,thick
  
  
  IF N_elements(thick) eq 0 THEN thick=1.0
  
  thick	= cround(thick)
  
  c = !P.clip +	[-cceil((thick)/2.0),-cceil((thick+1)/2.0),$
		  cceil((thick+1)/2.0),	cceil(thick/2.0)]

  plots,[c(0),c(2),c(2),c(0),c(0)],$
	[c(1),c(1),c(3),c(3),c(1)],/DEVICE,thick=thick
  
END

