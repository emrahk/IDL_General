;+
; Project     :	SOHO - CDS
;
; Name        :	GET_SCREEN
;
; Purpose     : 
;	return screen scaling parameters for controlling widget
;       sizing
; Explanation :
;
; Use         : GET_SCREEN, space,xpad,ypad,scx,scy
;
; Inputs      : None.
;
; Opt. Inputs : None.
;
; Outputs     : 
;       space = pixel spacing between children bases
;       xpad,ypad = horizontal and vertical pixel spacing being children 
;                   bases and edges of parent base.
;       scx,scy = pixel scale factors to rescale screen size in 
;                 X- and Y-directions
; Opt. Outputs: None.
;
; Keywords    : None.
;
; Procedure   :
;       The returned values were derived empirically by
;       experimenting with sizing widgets on a 1280 x 1024 pixel screen.
;       They can be used as keywords in WIDGET_CONTROL  to produce
;       "nice fitting" widgets. IDL can (and will likely) ignore them.
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
; Written     :	DMZ (ARC) Oct 1993
;
; Modified    :
;
; Version     :
;-
PRO get_screen,space,xpad,ypad,scx,scy

;-- get parameters for autosizing screen

   DEVICE, get_screen_size=sc
   space=.0144*sc(0)/4.
   xpad=.0195*sc(0)/4.
   ypad=.0195*sc(1)/4.
   scx=sc(0)/1280. & scy=sc(1)/1024.

   RETURN 
END

