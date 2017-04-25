;+
; Project     :	SDAC
;
; Name        : EPLOT
;
; Purpose     : Overplot x and y error bars on a previously drawn plot.
;
; Use         : EPLOT,X,Y, EX=EX,EY=EY
;
; Inputs      : X,Y = vectors values 
;
; Opt. Inputs : None.
;
; Outputs     : None.
;
; Opt. Outputs: None.
;
; Keywords    :
;            	EX = error in x 
;               EY = error in y
;               [2-d array where 1st column is + error, 2nd column is - error]
;               /UPPER = plot positive errors only
;               /LOWER = plot negative errors only
;               COLOR = color for error bars
;               NOCLIP = set to not clip off at plot boundaries
; Explanation : 
;           	Error bars are drawn for each element.
;               If input errors are 1-d, then they are concatanated to 2-d 
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: 
;              Initial call to plot must be made to establish scaling
;
; Side effects: None.
;
; Category    : Graphics
;
; Prev. Hist. : 
;              Jan'91, DMZ, (ARC) -- written
;              Sep'93, DMZ  -- added Yohkoh index option for x input
;              Oct'93, DMZ  -- added option for entering single vectors
;              Mar'98, DMZ  -- added UTPLOT keyword
;
; Version:     1
;-

pro eplot,x,y,ex=ex,ey=ey,bar=bar,noclip=noclip,upper=upper,lower=lower,$
    color=color,utplot=utplot

on_error,1

if n_params() eq 0 then begin
 chkarg,'eplot'
 return
endif

if n_elements(color) eq 0 then color=!p.color

if not keyword_set(noclip) then noclip=0

if (not keyword_set(ex)) and (not keyword_set(ey)) then $
  message,'enter error arrays as keywords ex=[values] or ey=[values]'

;-- check if x is a structure

index=(datatype(x,2) eq 8) or keyword_set(utplot)

;-- single vector input?

if n_params() eq 1 then begin
 yb=x
 xb=indgen(n_elements(yb))
endif else begin
 xb=x & yb=y 
endelse

nx=n_elements(xb) & ny=n_elements(yb)

;-- determine nature of input errors

;if nx ne ny then message,'X-Y arrays have different nos. of elements'
  
;-- determine if in histogram mode 

sx=size(ex) & sy=size(ey)
if (nx eq 2*sx(1)) or (ny eq 2*sy(1)) then begin
 xb=rebin(xb,nx/2) & yb=rebin(yb,ny/2) 
endif
nb=(n_elements(xb) < n_elements(yb))

if keyword_set(ex) then begin
 if sx(0) lt 1 then message,'X-errors must be array'
; if sx(1) ne nb then message,'data and X-errors have incompatible array sizes'
 dx=ex & if sx(0) eq 1 then dx=[[dx],[dx]]
endif
 
if keyword_set(ey) then begin
 if sy(0) lt 1 then message,'Y-errors must be array'
; if sy(1) ne nb then message,'data and Y-errors have incompatible array sizes'
 dy=ey & if sy(0) eq 1 then dy=[[dy],[dy]]
endif

if keyword_set(ey) then begin
 for i=0l,nb-1 do begin
  xvec=[xb(i),xb(i)] 
  up=yb(i)+dy(i,1) & down=yb(i)-dy(i,0)
  if keyword_set(upper) then down=yb(i)
  if keyword_set(lower) then up=yb(i)
  yvec=[down,up]
  if index then $
   outplot,xvec,yvec,psym=0,linestyle=0,noclip=noclip,color=color else $
    oplot,xvec,yvec,psym=0,linestyle=0,noclip=noclip,color=color
 endfor
 endif

if keyword_set(ex) then begin
 for i=0l,nb-1 do begin
  xvec=[xb(i)-dx(i,0),xb(i)+dx(i,1)] 
  yvec=[yb(i),yb(i)]
  if index then $
   outplot,xvec,yvec,psym=0,linestyle=0,noclip=noclip,color=color else $
    oplot,xvec,yvec,psym=0,linestyle=0,noclip=noclip,color=color
 endfor
endif


return & end

