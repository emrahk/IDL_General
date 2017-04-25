;+
; Project     : SDAC
;                   
; Name        : SPS
;               
; Purpose     : Set the graphic device to Postscript and use machine fonts.
;               
; Category    : SPEX, GRAPHICS
;               
; Explanation : Uses set_plot,'ps' and !p.font=0
;               
; Use         : SET_PS [,/LAND] [,/PORTRAIT] [,/FULLPORTRAIT]
;    
; Inputs      : 
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : 
;	/landscape - default landscape orientation
;	/portrait - default portrait orientation
;	/fullportrait - full page portrait orientation
;	/color    - set up for color postscript
;	/encaps   - encapsulated postscript
;
; Calls       :
;
; Common      : FCOLOR_PS, FENCAPS_PS
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  : Was PS.PRO changed because of ssw conflict.
;
; Modified    : Version 1, RAS, 12-apr-1997
;
;-            
pro sps, fullportrait=fullportrait, landscape=landscape, portrait=portrait, $
	encapsulated=encaps, color=color

common fcolor_ps, pscolor
common fencaps_ps, psencaps

set_plot,'ps' 
!p.font=0

if keyword_set(fullportrait) then DEVICE,YSIZ=22.7,YOFF=2.7,/portrait
if keyword_set(landscape) then device, /landscape
if keyword_set(portrait) then begin
	device,/landscape
	device,/portrait
endif
if n_elements(color) eq 1 then begin
 if color then device,/color,bits=8 else device,color=0, bits=4
 pscolor = color
endif
if n_elements(encaps) eq 1 then begin
 device, encaps=encaps
 psencaps = encaps
endif

end
