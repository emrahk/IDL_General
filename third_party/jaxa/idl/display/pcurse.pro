;+
; NAME:
;      pcurse
; PURPOSE:
;      user cursor to select points from plot
; CALLING SEQUENCE:
;      pcurse,x,y
; INPUTS:
;      none
; OUTPUTS:           
;      x,y = vector of selected points
; KEYWORDS:
;      npoints (in,out) = # of points to select or selected
;      newlabel (in)    = message label to override def message
;      cross (in)       = plot cross at selected points
;      xl,yl (in)       = normalized position coordinates of message label
; MODIFICATION HISTORY:     
;      Jun'94, DMZ (ARC) -- written.
;-                                 

pro pcurse,x,y,npoints=npoints,newlabel=newlabel,cross=cross,xl=xl,yl=yl

on_error,1

; Get x and y window limits.

l = !x.window(0)
r = !x.window(1)
b = !y.window(0)
t = !y.window(1)
if n_elements(xl) eq 0 then xl=l+.02
if n_elements(yl) eq 0 then yl=t-.06

empty

tek_label='Press ''F'' to exit'
x_label='Press Right Button to exit'
if n_elements(newlabel) ne 0 then label=newlabel else begin
 if (!d.name eq 'X') or (!d.name eq 'WIN') then label=x_label else label=tek_label
endelse

;-- check device

case !d.name of 
   'TEK': begin
      print,string(29b)
      device,gin_char=6 
     end
   'X':wshow
   'WIN':wshow
   else: message,'graphics device not supported'
 endcase
 ys=yl
 for i=0,n_elements(label)-1 do begin
  xyouts,xl,ys,label(i),/normal,charsize=1.2
  ys=ys-.05
 endfor

 if n_elements(npoints) eq 0 then npoints=1.e30
 x=0 & y=0
 choice='N'
 ncurr=0

;-- start looping

 linestyle=1
 repeat begin 
  !err = 0
  cursor,xdat,ydat,/data,/down
  case !d.name of
      'X': if !err eq 4 then choice='F'
     'WIN': if !err eq 4 then choice='F'
    'TEK': choice=strupcase (byte(!err)) 
  endcase

;-- new point selected

  
  if choice ne 'F' then begin
   x=[x,xdat] & y=[y,ydat] & ncurr=ncurr+1
   if keyword_set(cross) then plots,[xdat,xdat],[ydat,ydat],psym=1 else $
    oplot,[xdat,xdat],!y.crange,linestyle=linestyle,/noclip
  endif
  if linestyle eq 1 then linestyle=2 else linestyle=1

 endrep until (choice eq 'F') or (ncurr eq npoints)

;-- all done

 if ncurr ge 1 then begin
  x=x(1:*) & y=y(1:*) 
 endif
 npoints=ncurr

 empty
 return & end

