;+
; Project     : SOHO-CDS
;
; Name        : DRAWBOX
;
; Purpose     : Draw a rubber-band box (or circle)
;
; Category    : imaging
;
; Explanation : This function draws a rubberband box (or circle) in the 
;               window specified by the positional parameter 
;                (or the current graphics window, by default). 
;               The coordinates of the final box are returned by the
;               function. Move the cursor to draw, press the left button
;               to drag, and press the right button to exit.
;
;
; Syntax      : coord=drawbox()
;
; Examples    :
;
; Inputs      : WID = window where box is drawn. (!D.Window by default.)
;                
;
; Opt. Inputs : None
;
; Outputs     : COORD= [xstart,ystart,xend,yend] or
;                      [xcenter,ycenter,radius]
;
; Opt. Outputs: 
;
; Keywords    : DATA = set for box coordinates returned as DATA coordinates.
;               NORMAL = set for box coordinates returned as NORMAL coordinates.
;               CIRCLE = set to draw circle instead of box
;               SIZE = initial box width and height 
;               INITIALXY = initial circle center
;               FIXED = set to inhibit resizing, but permit dragging
;               RADIUS = initial radius of circle
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written: D. Fanning (Coyote Software)
;               Modified: D. Zarro, 28-Oct-98 (SMA/GSC) - added circle option
;               Modified: K. Tolbert 29-Oct-98 (RSTX) - added initial location option
;               Modified: K. Tolbert 29-Oct-98 (RSTX) -  for circle option, return center and radius
;
; Contact     : dzarro@solar.stanford.edu
;-

;----------------------------------------------------------------------------
;- utility routines

pro circle_draw,cx,cy,dx,dy,rad=rad,_extra=extra
 if exist(dx) and exist(dy) then begin
  rad=sqrt((cx-dx)^2 + (cy-dy)^2)
 endif
 circum=2*!dtor*findgen(181)
 xlimb = cx+rad*sin(circum)  &  ylimb = cy+rad*cos(circum)
 plots,xlimb,ylimb,/device,_extra=extra
 return 
end

pro box_draw,cx,cy,dx,dy,width=width,height=height,_extra=extra
 if exist(dx) and exist(dy) then begin
   width=2.*(dx-cx) & height=2.*(dy-cy)
 endif
 width=abs(width) & height=abs(height)
 rx=cx-width/2. & ry=cy-height/2.
 lx=cx+width/2. & ly=cy+height/2.
 plots, [rx, rx, lx, lx, rx], [ry, ly, ly, ry, ry], $
       /Device,_extra=extra
 return
end

;-------------------------------------------------------------------------

Function DrawBox, wid, Data=data, Normal=normal,fixed=fixed,radius=radius,$
   circle=circle, initialxy=initialxy,size=bsize,_extra=extra

;-- Catch possible errors here.

Catch, error
IF error NE 0 THEN BEGIN
   ok = Widget_Message(!Err_String)
   RETURN, [0,0,1,1]
ENDIF

;-- Check for parameters.

IF N_Params() EQ 0 THEN wid = !D.Window > 0

circle=keyword_set(circle)
box=1-circle

;-- Make current window active.

WSet, wid
xsize = float(!D.X_VSize)
ysize = float(!D.Y_VSize)

;-- Create a pixmap for erasing the box. Copy window
;   contents into it.

Window, /Pixmap, /Free, XSize=xsize, YSize=ysize
pixID = !D.Window
Device, Copy=[0, 0, xsize, ysize, 0, 0, wid]


WSet, wid
wshow,wid

;-- intial box corner or circle center

sx=xsize/2. & sy=ysize/2.

if n_elements(initialxy) eq 2 then begin
 sx = float(initialxy(0)) & sy = float(initialxy(1))
 coords = [sx, sy]
 if keyword_set(data) then coords = convert_coord(sx, sy, /data, /to_device)
 if keyword_set(normal) then coords = convert_coord(sx, sy, /normal, /to_device)
 sx = coords(0) & sy = coords(1)
endif

;-- initial box or circle size

dx=sx+xsize/8. & dy=sy+ysize/8.

if circle and exist(radius) then begin
 icoords=[sx,sy]
 if keyword_set(data) then icoords = convert_coord(sx, sy, /device, /to_data)
 if keyword_set(normal) then icoords = convert_coord(sx, sy, /device, /to_normal)
 dx=icoords(0)+float(radius) & dy=icoords(1)
 coords = [dx, dy]
 if keyword_set(data) then coords = convert_coord(dx, dy, /data, /to_device)
 if keyword_set(normal) then coords = convert_coord(dx, dy, /normal, /to_device)
 dx = coords(0) & dy = coords(1) 
endif

if box and (n_elements(bsize) eq 2) then begin
 gsize=float(abs(bsize))
 icoords=[sx,sy]
 if keyword_set(data) then icoords = convert_coord(sx, sy, /device, /to_data)
 if keyword_set(normal) then icoords = convert_coord(sx, sy, /device, /to_normal)
 dx = icoords(0)+gsize(0) & dy = icoords(1)+gsize(1)
 coords = [dx, dy]
 if keyword_set(data) then coords = convert_coord(dx, dy, /data, /to_device)
 if keyword_set(normal) then coords = convert_coord(dx, dy, /normal, /to_device)
 dx = coords(0) & dy = coords(1) 
endif

;-- draw starting shape

if circle then begin
 cx=sx & cy=sy
 circle_draw,cx,cy,dx,dy,_extra=extra
endif else begin
 cx=sx+abs(dx-sx)/2.
 cy=sy+abs(dy-sy)/2.
 box_draw,cx,cy,dx,dy,_extra=extra
endelse

;-- Go into a loop.
 
last_cx=cx & last_cy=cy & last_rad=sqrt((dx-cx)^2 + (dy-cy)^2)
last_width=2.*(dx-cx) & last_height=2.*(dy-cy)
dragging=0 & count1=0 & count2=0


REPEAT BEGIN

;-- Drag by pressing middle or left button   
     
  cursor,px,py,/change,/device

  skip= (px gt xsize) or (px lt 1) or (py gt ysize) or (py lt 1)
  if not skip then begin
   dragging =(!mouse.button eq 1) or (!mouse.button eq 2)
   px=float(px) & py=float(py)

;-- the following kluge is necessary to ensure that after we drag,
;   the box or circle position doesn't change erratically

   if keyword_set(fixed) then dragging=1
   if dragging then begin
    count2=0 
    count1=count1+1    
    if count1 gt 2 then begin     
     cx=px & cy=py
    endif else tvcrs,last_cx,last_cy
   endif else begin
    count1=0 & count2=count2+1
;    help,count2
    if count2 gt 1 then begin
     dx=px & dy=py
    endif else begin
     if circle then begin
      nx=last_cx+last_rad & ny=last_cy
     endif else begin
      nx=last_cx-abs(last_width)/2. & ny=last_cy-abs(last_height)/2.
     endelse
     tvcrs,(1 > nx < xsize), (1 > ny < ysize)
    endelse
   endelse
    
;-- Erase the old box.

   Device, Copy=[0, 0, xsize, ysize, 0, 0, pixID]

;-- Draw circle

   if circle then begin
    if not dragging then rad=sqrt((cx-dx)^2+(cy-dy)^2) else rad=last_rad
    circle_draw,cx,cy,rad=rad,_extra=extra
   endif else begin

;-- Draw the box.

    if not dragging then begin
     width=2.*(dx-cx) & height=2.*(dy-cy)
    endif else begin
     width=last_width & height=last_height
    endelse            
    box_draw,cx,cy,width=width,height=height,_extra=extra
   endelse

;-- record last coordinates (for dragging)

   if not dragging then begin
    last_rad=sqrt((cx-dx)^2+(cy-dy)^2)                           
    last_width=2.*(dx-cx) & last_height=2.*(dy-cy)
   endif else begin
    last_cx=cx & last_cy=cy
   endelse   

  endif

endrep until !mouse.button eq 4

;-- Erase the final box.

;Device, Copy=[ 0, 0, xsize, ysize, 0, 0, pixID]

;-- Delete the pixmap.

WDelete, pixID

;-- Order the box coordinates and return.

if not circle then begin
 sx = cx-abs(width)/2.
 dx = cx+abs(width)/2.
 sy = cy-abs(height)/2.
 dy = cy+abs(height)/2.
endif else begin
 sx=cx & sy=cy
 dx=cx+rad & dy=cy
endelse

coords = [[sx, sy], [dx, dy]]


;-- Need coordinates in another coordinate system?

IF Keyword_Set(data) THEN coords =  Convert_Coord([sx, dx], [sy, dy], /Device, /To_Data)

IF Keyword_Set(normal) THEN coords =  Convert_Coord([sx, dx], [sy, dy], /Device, /To_Normal)

;-- Return device coordinates, otherwise.

if circle then begin
 c = coords
 return, [c(0,0), c(1,0), sqrt((c(0,1)-c(0,0))^2 + (c(1,1)-c(1,0))^2)]
endif else RETURN, [coords(0,0), coords(1,0), coords(0,1), coords(1,1)]

END







