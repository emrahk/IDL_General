;+
; Project     : SOHO_CDS
;
; Name        : PLOT_MAP_WHITE
;
; Purpose     : Utility routine to white-out "over the edge
;               pixels" in postscript plots
;
; Category    : imaging
;
; Inputs      : XB_DEV, YB_DEV, XR_DEV, YR_DEV = device pixels
;
; Keywords    : BACKGROUND = background color
;
; History     : Written, 1-Jan-2007, Zarro(ADNET) 
;               Modified, 28-Jan-2009, Zarro (ADNET)
;                - ensured that max color in color table is really "white"
;
; Contact     : dzarro@solar.stanford.edu
;-

pro plot_map_white,xb_dev,yb_dev,xr_dev,yr_dev,background=background

;-- utility routine to white-out "over the edge pixels" in postscript plots

;-- save current color table and load black and white.

 if is_number(background) then begin
  white=  0 > nint(background) < (!d.table_size-1)
 endif else begin
  tvlct,rsave,gsave,bsave,/get
  loadct,0
  white=!d.table_size-1
 endelse
 white_out=bytarr(2,2)+byte(white)
 left_x=min(xb_dev)
 right_x=max(xb_dev)
 bot_y=min(yb_dev)
 top_y=max(yb_dev)
 lx=min(xr_dev)
 rx=max(xr_dev)
 ty=max(yr_dev)
 by=min(yr_dev)

 if ((lx-left_x) ge 1) then $
  tv,white_out,left_x,bot_y,xsize=lx-left_x+1,ysize=top_y-bot_y+1,/device
 if ((right_x-rx) ge 1) then $
  tv,white_out,rx,bot_y,xsize=right_x-rx+1,ysize=top_y-bot_y+1,/device
 if ((by-bot_y) ge 1) then $
  tv,white_out,lx,bot_y,xsize=rx-lx+1,ysize=by-bot_y+1,/device
 if ((top_y-ty) ge 1) then $
  tv,white_out,lx,ty,xsize=rx-lx+1,ysize=top_y-ty+1,/device

 if exist(rsave) then tvlct,rsave,gsave,bsave

 return & end

