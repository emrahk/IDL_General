;+
; Project     : SOHO-CDS
;
; Name        : SCOPE_CURSOR
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
; Syntax      : scope_cursor,coord
;
; Outputs     : CORDS= [xstart,ystart,xend,yend] or
;                      [xcenter,ycenter,radius]
;
; Opt. Outputs:
;
; Keywords    : WID = window where box is drawn. (!D.Window by default.)
;               DATA = set for box coordinates returned as DATA coordinates.
;               NORMAL = set for box coordinates returned as NORMAL coordinates.
;               BOX = set to draw box instead of circle
;               SIZE = initial box width and height
;               INITIALXY = initial circle center
;               FIXED = set to inhibit resizing, but permit dragging
;               RADIUS = initial input radius of circle
;               WIDTH,HEIGHT = output box width and height
;               MAG = magnification factor if zooming with /BOX
;               NOSCALE = set to not bytescale image when zooming
;               KEEP = keep last cursor position
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written: D. Fanning (Coyote Software) -- originally DRAWBOX
;               Modified: D. Zarro, 28-Oct-98 (SMA/GSFC) - added circle option
;               Modified: K. Tolbert 29-Oct-98 (RSTX) - added initial location option
;               Modified: K. Tolbert 29-Oct-98 (RSTX) -  for circle option, return center and radius
;               Modified: D. Zarro 20-Jan-99 (SMA/GSFC) -  added magnify option
;		Modified: K. Tolbert 10-Jul-01 (Raytheon) - correct magnify for 16- or 24-bit color
; Contact     : dzarro@solar.stanford.edu
;-

;----------------------------------------------------------------------------
;
;- utility routines

pro last_draw,lx,ly,rx,ry,last
 p=nint(lx,/long) & q=nint(ly,/long)
 w=abs(nint(lx-rx,/long)) & h=abs(nint(ly-ry,/long))
 nx=!d.x_vsize & ny=!d.y_vsize
 p0 = 0 > p < (nx-1)
 q0=  0 > q < (ny-1)
 p1 = 0 > (p +w-1) < (nx-1)
 q1 = 0 > (q +h-1) < (ny-1)
 xsize= 0 > (p1-p0+1) < w
 ysize= 0 > (q1-q0+1) < h
 last={p0:p0,q0:q0,xsize:xsize,ysize:ysize,p:p,q:q,w:w,h:h}
 return
end

;----------------------------------------------------------------------------

pro circle_draw,cx,cy,dx,dy,rad=rad,last=last,_extra=extra
 if exist(dx) and exist(dy) then begin
  rad=sqrt((cx-dx)^2 + (cy-dy)^2)
 endif
 rad=float(rad)
 circum=2*!dtor*findgen(181)
 xlimb = cx+(rad-2.)*sin(circum)  &  ylimb = cy+(rad-2.)*cos(circum)
 plots,xlimb,ylimb,/device,_extra=extra
 lx=cx-rad & ly=cy-rad
 rx=cx+rad & ry=cy+rad
 last_draw,lx,ly,rx,ry,last
 return
end

;-------------------------------------------------------------------------

pro box_draw,cx,cy,dx,dy,width=width,height=height,$
    mag=mag,noscale=noscale,last=last,_extra=extra,truecolor=truecolor


 ; if 16 or 24 bit color, then have to call tvrd with /true, it will return (3,nx,ny),
 ; and have to call tv or tvscl with /true

 if not exist(truecolor) then truecolor=0b

 if truecolor then ncdim = 3 else ncdim = 1

 if exist(dx) and exist(dy) then begin
  width=2.*(dx-cx) & height=2.*(dy-cy)
 endif
 width=float(abs(width)) & height=float(abs(height))
 lx=cx-width/2. & ly=cy-height/2.
 rx=cx+width/2. & ry=cy+height/2.

 last_draw,lx,ly,rx,ry,last

 do_it=!mouse.button eq 1
 if (last.xsize gt 0) and (last.ysize gt 0) and exist(mag) and do_it then begin
  xsize=last.xsize & ysize=last.ysize
  w=last.w & h=last.h
  p=last.p & q=last.q
  p0=last.p0 & q0=last.q0
  a=tvrd(p0,q0,xsize,ysize,true=truecolor)
  b=bytarr(ncdim,w,h,/nozero)
  p2= 0 > (p0-p) < (w-1)
  q2= 0 > (q0-q) < (h-1)
  p3= 0 > (p2+xsize-1) < (w-1)
  q3= 0 > (q2+ysize-1) < (h-1)

  if truecolor then b(*,p2:p3,q2:q3)=temporary(a(*,0:p3-p2,0:q3-q2)) else $
  	b(*,p2:p3,q2:q3)=temporary(a(0:p3-p2,0:q3-q2))
  nwidth=w*nint(mag,/long) & nheight=h*nint(mag,/long)
  b=rebin(temporary(b),ncdim,nwidth,nheight,/sample)
  ncx=nwidth/2. & ncy=nheight/2.
  nlx=(ncx-width/2.)  & nly=(ncy-height/2.)
  nrx=(ncx+width/2.)  & nry=(ncy+height/2.)
  if 1-keyword_set(noscale) then $
   tvscl,b(*,nlx+1:nrx-1,nly+1:nry-1),nint(lx),nint(ly),true=truecolor else $
    tv,b(*,nlx+1:nrx-1,nly+1:nry-1),nint(lx),nint(ly),true=truecolor
 endif
 plots, [rx-1, rx-1, lx+1, lx+1, rx-1], [ry-1, ly+1, ly+1, ry-1, ry-1], $
       /Device,_extra=extra

 return
end

;-------------------------------------------------------------------------

pro scope_cursor,cords, wid=wid, Data=data, Normal=normal,fixed=fixed,radius=radius,$
   box=box, initialxy=initialxy,size=bsize,width=width,$
   height=height,mag=mag,noscale=noscale,keep=keep,_extra=extra

;-- Catch possible errors here.

cords=[0,0,1,1]
Catch, error
IF error NE 0 then BEGIN
 ok = Widget_Message(!Err_String)
 RETURN
endif

;-- Check for parameters.

IF not exist(wid) then wid = !D.Window > 0

box=keyword_set(box)
circle=1-box

;-- Make current window active.

WSet, wid
xsize = float(!D.X_VSize)
ysize = float(!D.Y_VSize)

;-- Create a pixmap for erasing the box. Copy window
;   contents into it.


Window, /Pixmap, /Free, XSize=xsize, YSize=ysize
pixid = !D.Window
Device, Copy=[0, 0, xsize, ysize, 0, 0, wid]

WSet, wid
wshow,wid

;-- center initial box corner or circle center

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
 circle_draw,cx,cy,dx,dy,last=last,_extra=extra
endif else begin
 cx=sx+abs(dx-sx)/2.
 cy=sy+abs(dy-sy)/2.
 box_draw,cx,cy,dx,dy,mag=mag,noscale=noscale,last=last,_extra=extra
endelse

;-- Go into a loop.

last_cx=cx & last_cy=cy & last_rad=sqrt((dx-cx)^2 + (dy-cy)^2)
last_width=2.*(dx-cx) & last_height=2.*(dy-cy)
dragging=0 & count1=0 & count2=0

;-- check for true color display

if idl_release(lower=5.2, /inclusive) then begin
 device, get_visual_depth=depth
 truecolor = depth gt 8
endif else truecolor = 0

if truecolor then begin 
 device, get_decomposed=decomp_save
 device, decomposed=1
endif

repeat begin

;-- Drag by pressing middle or left button

;  if exist(mag) then cursor,px,py,/down,/device else $
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

   if exist(last) then begin
    p0=last.p0 & q0=last.q0
    ps=1 > last.xsize
    qs=1 > last.ysize
    device,copy=[p0,q0,ps,qs,p0,q0,pixid]
   endif else device, Copy=[0, 0, xsize, ysize, 0, 0, pixid]

;-- Draw circle

   if circle then begin
    if not dragging then rad=sqrt((cx-dx)^2+(cy-dy)^2) else rad=last_rad
    if (count1 eq 0) and (count2 eq 1) then rad=last_rad
    circle_draw,cx,cy,rad=rad,last=last,_extra=extra
   endif else begin

;-- Draw the box.

    if not dragging then begin
     width=2.*(dx-cx) & height=2.*(dy-cy)
    endif else begin
     width=last_width & height=last_height
    endelse
    if (count1 eq 0) and (count2 eq 1) then begin
     width=last_width & height=last_height
    endif
    box_draw,cx,cy,width=width,height=height,truecolor=truecolor,$
     mag=mag,noscale=noscale,last=last,_extra=extra

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

if truecolor then device,decomposed=decomp_save

;-- Erase the final box.

if (1-keyword_set(keep)) then device, Copy=[ 0, 0, xsize, ysize, 0, 0, pixid]

;-- Delete the pixmaps

wDelete, pixid

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

IF Keyword_Set(data) then coords =  Convert_Coord([sx, dx], [sy, dy], /Device, /To_Data)

IF Keyword_Set(normal) then coords =  Convert_Coord([sx, dx], [sy, dy], /Device, /To_Normal)

;-- Return device coordinates, otherwise.

if circle then begin
 c = coords
 cords= [c(0,0), c(1,0), sqrt((c(0,1)-c(0,0))^2 + (c(1,1)-c(1,0))^2)]
endif else cords= [coords(0,0), coords(1,0), coords(0,1), coords(1,1)]

return & end

