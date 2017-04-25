;+
; Project     : SDAC
;
; Name        : GET_CENT_OFF
;
; Purpose     : determine pixel offsets for centering widget bases
;
; Use         : OFFSETS=GET_CENT_OFF(WBASE)
;
; Inputs      : WBASE = widget base id
;
; Opt. Inputs : GROUP = ID of group widget relative to which the
;                       offset values are calculated
;
; Outputs     : OFFSETS=[XOFF,YOFF]
;
; Opt. Outputs: None.
;
; Keywords    : VALID = 1 if valid offsets found, 0 otherwise
;               WSIZE = [xsize,ysize] of WBASE
;               SCREEN = center relative to main screen
;
; Explanation :
;               Useful for centering pop up text widgets.
;               For example:
;               if group base is defined as w1, then
;               widget_control,w2,/realize,tlb_set_xoff=xoff,tlb_set_yoff=yoff
;               will center w2 within w1.
;
; Restrictions: WBASE must be valid otherwise [-1,-1] is returned
;
; Category    : Widgets
;
; Written     : Zarro (ARC/GSFC) 17 April 1995
; Modified    : Sandhia Bansal 05-Aug-2004.  Added a new 'nomap' keyword to delay
;               the display of widget until later.
; Modified    : Zarro (L-3Com/GSFC) 13 August 2005 - Added CATCH
;-

function get_cent_off,wbase,group,valid=valid,wsize=wsize,screen=screen,nomap=nomap

valid=0
offsets=[-1,-1]
if (!d.name ne 'X') and (!d.name ne 'WIN') then return,offsets

screen=keyword_set(screen)

if not xalive(wbase) then return,offsets

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return,offsets
endif

if xalive(group) and (not screen) then $
 widget_control,group,tlb_get_offset=goff,tlb_get_size=gsize else $
  device,get_screen_size = gsize

; use nomap keyword to determine whether or not to display the widget yet - Sandhia 08/05/04

map=1-keyword_set(nomap)

; do this in two steps to keep the widget from flickering when nomap flag is on

widget_control,wbase,map=map
widget_control,wbase,tlb_get_size=wsize,/realize

xoff=((gsize[0]-wsize[0])/2) > 0.
yoff=((gsize[1]-wsize[1])/2) > 0.

if n_elements(goff) ne 0 then begin
 xoff=(goff[0]+xoff)
 yoff=(goff[1]+yoff)
endif

valid=1

return,[xoff,yoff] & end
