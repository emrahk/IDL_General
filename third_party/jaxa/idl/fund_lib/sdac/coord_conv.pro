;+
; PROJECT: 
;	SDAC
;
; NAME: 
;	COORD_CONV
;
; PURPOSE:
;	This procedure computes the data, normal, and device coordinates for an input point that
; 	is any of the three types, and returns the 3 types in xout and yout in
; 	that order.
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;	COORD_CONV, X, Y,  Xout, Yout
; CALLS:
;	none
;
; INPUTS:
; 
; Default type for input point is data.  Otherwise specified by keywords DATA,NORMAL, DEVICE.
;       x: xaxis coordinate, must be scalar
;	y: yaxis coordinate, must be scalar
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Xout: the input coordinate converted to [DATA, NORMAL, DEVICE ] units as a vector
;	Yout: the input coordinate converted to [DATA, NORMAL, DEVICE ] units as a vector
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	DATA:   If set, input is in DATA coordinates
;	NORMAL: If set, input is in NORMAL coordinates
;	DEVICE: If set, input is in DEVICE coordinates
;	
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;
; Kim Tolbert 11/26/91
;-
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

pro coord_conv, x, y, xout, yout, data=data, normal=normal, device=device
;
vx = !d.x_size * 1.
vy = !d.y_size * 1.
xs = !x.s
ys = !y.s
;
xout = fltarr(3) & yout = fltarr(3)
;
if keyword_set(normal) then begin  ; x and y are in normal coords.
   ; normal coordinates
   xout(1) = x
   yout(1) = y
   ; device coordinates
   xout(2) = x * vx
   yout(2) = y * vy
   ; data coordinates
   case !x.type of
      0: xout(0) = (x - xs(0)) / xs(1)
      1: xout(0) = 10. ^ ((x-xs(0))/xs(1))
   endcase
   case !y.type of
      0: yout(0) = (y - ys(0)) / ys(1)
      1: yout(0) = 10. ^ ((y-ys(0))/ys(1))
   endcase
   goto, getout
endif
;
if keyword_set(device) then begin  ; x and y are in device coords.
   ; device coordinates
   xout(2) = x
   yout(2) = y
   xout(1) = x / vx
   yout(1) = y / vy
   case !x.type of
      0: xout(0) = (x/vx - xs(0)) / xs(1)
      1: xout(0) = 10. ^ ((x/vx-xs(0))/xs(1))
   endcase
   case !y.type of
      0: yout(0) = (y/vy - ys(0)) / ys(1)
      1: yout(0) = 10. ^ ((y/vy-ys(0))/ys(1))
   endcase
   goto,getout
endif
;
; x and y are in data coords.
xout(0) = x
yout(0) = y
; normal and device coordinates
case !x.type of
   0: begin
      xout(1) = xs(0) + xs(1)*x
      xout(2) = vx * (xs(0) + xs(1)*x)
   end
   1: begin
      xout(1) = xs(0) + xs(1)*alog10(x)
      xout(2) = vx * (xs(0) + xs(1) * alog10(x))
   end
endcase
case !y.type of
   0: begin
      yout(1) = ys(0) + ys(1)*y
      yout(2) = vy * (ys(0) + ys(1)*y)
   end
   1: begin
      yout(1) = ys(0) + ys(1)*alog10(y)
      yout(2) = vy * (ys(0) + ys(1) * alog10(y))
   end
endcase
;
getout:
end
