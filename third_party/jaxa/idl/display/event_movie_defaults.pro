pro event_movie_defaults, event_type, $
   zbuff=zbuff, goes=goes, $
   color=color, gcolor=gcolor, ncolor=ncolor, scolor=scolor, tcolor=tcolor
;+
;   Name: event_movie_defaults
;
;   Purpose: set some color "defaults" for event_movie.pro
;
;   Input Parameters:
;      event_type: - type of desired event/defaults (defaults=goes w/yohkoh fem)
;
;   Output Parameters:
;     NONE:
;
;   Keyword Parameters:
;     (all output)  
;      goes - if set, turn 'plot_goes' on
;      color - color for event lines
;      gcolor - (goes only - goes grid color)
;      ncolor - (fem only - color for night/day )
;      scolor - (fem only - color for SAA)
;
;   Calling Sequence:
; 
;   History:
;      12-Apr-1999 (S.L.Freeland) - broke some code out of event_movie_defaults
;
;-

if n_elements(event_type) eq 0 then event_type=0

case event_type of 
  0: begin 
       zbuff=1                         ; use Z buffer
       goes=1                          ; it's a goes plot
       color=2				; event line color
       tcolor=200			;tick color
       gcolor=10			; goes grid color
       scolor=4			; SAA color
       ncolor=9			; Night color
   endcase
   else: begin
      box_message,'event type not found..'
   endcase
endcase   

return
end
