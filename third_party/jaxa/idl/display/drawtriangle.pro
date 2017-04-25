
;+
; NAME
;
;     DRAWTRIANGLE()
;
; EXPLANATION
;
;     Draws a "rubberband" isosceles triangle. Designed for use with 
;     SPEC_GAUSS_WIDGET.
;
; INPUTS
;
;     WID    ID of window where the triangle is drawn. (!D.Window by default.)
;
; INTERACTIVE INPUTS
;
;     By clicking-and-holding the left mouse button (LMB), a triangle will 
;     appear on the plot window. Moving the mouse will change the size 
;     of the triangle. When the box is in the right position, let go of the 
;     LMB.
;
; OPTIONAL INPUTS
;
;     COLOR  The color index of the triangle. (!D.N_Colors-1 by default.)
;
; KEYWORDS
;
;     DATA   Coordinates returned in DATA coordinates.
;
;     NORMAL Coordinates returned in NORMAL coordinates.
;
; OUTPUT
;
;     The function returns the a 3 element array [X,Y,DX] where [X,Y] is the 
;     apex of the triangel, and DX is the length of the baseline.
;
; PREVIOUS HISTORY
;
;     This is a modified version of the routine drawbox.pro that is 
;     available from
;
;     http://www.dfanning.com/documents/tips.html
;
; HISTORY
;
;     Ver.1, 18-Jul-2003, Peter Young
;-


Function DrawTriangle, $
   wid, $         ; ID of window where box is drawn. (!D.Window by default.)
   Color=color, $ ; The color index of the box. (!D.N_Colors-1 by default.)
   Data=data, $   ; Box coordinates returned as DATA coordinates.
   Normal=normal  ; Box coordinates returned as NORMAL coordinates.

   ; Catch possible errors here.
   
Catch, error
IF error NE 0 THEN BEGIN
   ok = Widget_Message(!Err_String)
   RETURN, [0,0,1,1]
ENDIF

   ; Check for parameters.

IF N_Params() EQ 0 THEN wid = !D.Window > 0
IF N_Elements(color) EQ 0 THEN color = (!D.N_Colors - 1) < 255

   ; Make current window active.

WSet, wid
xsize = !D.X_VSize
ysize = !D.Y_VSize

   ; Create a pixmap for erasing the box. Copy window
   ; contents into it.

Window, /Pixmap, /Free, XSize=xsize, YSize=ysize
pixID = !D.Window
Device, Copy=[0, 0, xsize, ysize, 0, 0, wid]

   ; Get the first location in the window. This is the
   ; static corner of the box.

WSet, wid
Cursor, sx, sy, /Down, /Device

   ; Go into a loop. Stay in loop until button is released.

REPEAT BEGIN

      ; Get the new cursor location (dynamic corner of box).

;   Cursor, dx, dy, /Change, /Device
  cursor, dx, dy, /nowait, /device

      ; Erase the old box.

   Device, Copy=[0, 0, xsize, ysize, 0, 0, pixID]

      ; Draw the new box.

plots,[sx,dx,sx-(dx-sx),sx],[sy,dy,dy,sy],/device,color=color
;   PlotS, [sx, sx, dx, dx, sx], [sy, dy, dy, sy, sy], $
;      /Device, Color=color

ENDREP UNTIL !Mouse.Button EQ 0

   ; Erase the final box.

Device, Copy=[ 0, 0, xsize, ysize, 0, 0, pixID]

   ; Delete the pixmap.

WDelete, pixID

   ; Order the box coordinates and return.

;sx = Min([sx,dx], Max=dx)
;sy = Min([sy,dy], Max=dy)

   ; Need coordinates in another coordinate system?

IF Keyword_Set(data) THEN BEGIN
   coords =  Convert_Coord([sx, dx], [sy, dy], /Device, /To_Data)
   return,[coords[0,0],coords[1,0],abs(coords[0,1]-coords[0,0])*2.]
ENDIF

IF Keyword_Set(normal) THEN BEGIN
   coords =  Convert_Coord([sx, dx], [sy, dy], /Device, /To_Normal)
   return,[coords[0,0],coords[1,0],abs(coords[0,1]-coords[0,0])*2.]
ENDIF

   ; Return device coordinates, otherwise.

RETURN, [sx, sy, abs(dx-sx)*2.]
END
