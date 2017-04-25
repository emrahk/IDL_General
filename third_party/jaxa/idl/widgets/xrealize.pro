;+
; Project     :	SOHO CDS/SUMER
;
; Name        : XREALIZE
;
; Purpose     : control placement of realized widgets
;
; Use         : XREALIZE,WBASE
;
; Inputs      : WBASE = widget base id
;
; Keywords    : XOFF, YOFF = user specified or computed offsets
;               GROUP = ID of group widget relative to which the
;                       offset values are calculated
;               SCREEN = center relative to main screen
;               CENTER = center relative to GROUP (if alive)
;
; Side effects: WBASE is realized at specified or computed offsets
;
; Category    : Widgets
;
; Written     :	Zarro (ARC/GSFC) 17 September 1996
;               Modified, 27 Feb 2007, Zarro (ADNET) - removed EXECUTE
;-

pro xrealize,wbase,xoff=xoff,yoff=yoff,group=group,screen=screen,center=center

if not xalive(wbase) then return

if (n_elements(xoff) eq 0) and (n_elements(yoff) eq 0) then begin
 if keyword_set(center) or keyword_set(screen) then begin
  offsets = get_cent_off(wbase, group, valid=valid,screen=screen)
  if valid then begin
   xoff = offsets[0] & yoff=offsets[1]
  endif
 endif
endif

widget_control, wbase,tlb_set_xoff=xoff,tlb_set_yoff=yoff,/map,/show,/realize

return & end

