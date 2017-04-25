;+
; $Id: scalebar.pro,v 1.2 2006/08/10 18:47:21 thernis Exp $
;
; PURPOSE:
;  Display a color scale bar
;
; CATEGORY:
;  Visualization
;
; CALLING SEQUENCE:
;
; INPUTS:
;  screen : output window
;
; INPUT KEYWORD:
;  keywords relative to plot function such ytitle, /ylog, ...
;
; HISTORY:
;	V1.0 defined by A.Thernisien on 24/10/2001
; CVSLOG:
;  Revision 1.2  2002/07/11 07:24:13  arnaud
;  Insertion of the Log in each header
;
;-
pro scalebar,screen,_EXTRA=e

bar=findgen(256)##replicate(1,50)

if n_elements(screen) eq 0 then $
  dispim,bar,xticklen=0,yticklen=-0.02,/erase,xrange=[0,1],xticks=1,posxy=[60,60],charsize=1.5,xtickname=[' ',' '],fitwin=screen,_EXTRA=e else $
  dispim,bar,xticklen=0,yticklen=-0.02,xrange=[0,1],xticks=1,xtickname=[' ',' '],_EXTRA=e

return
end
