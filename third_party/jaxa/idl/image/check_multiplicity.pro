function check_multiplicity,clnmap,flevel,PLOT=plot
;+
; PURPOSE:
;   Returns the number of distinct contours of clnmap at level flevel
;
; METHOD:
;   Uses the structure produced by keyword PATH_INFO in IDL's contour

; INPUTS:
;  clnmap = 2D array (possibly representing a clean map)
;  flevel = scalar defining the level selected for defining a source
;  /plot to get a plot showing the contours at level=flevel
;
; OUTPUTS:
;    ncontours = number of contours at or above level flevel
;
; EXAMPLE:
;  xx=(findgen(64)-32)#replicate(1,64)
;  yy=transpose(xx)
;  a=5 & b=4.
;  z=2.^(-(xx/a)^2-(yy/b)^2)
;
;  z2=shift(z,15,20)
;  clnmap=z + z2
;  ch=check_multiplicity(clnmap,0.5,/plot)
;  print,ch,' contours'

; VERSION HISTORY
; ejs FEB 2003, schmahl@hessi.gsfc.nasa.gov;-
;-

if (flevel LE 0 OR flevel GE 1.0) then message,'flevel out of range'

CONTOUR, clnmap, level=[flevel]*max(clnmap),PATH_XY=xy, PATH_INFO=info
ncontours=n_elements(info)

if keyword_set(PLOT) then begin
  erase
  FOR I = 0, (N_ELEMENTS(info) - 1 ) DO BEGIN
   S = [INDGEN(info(I).N), 0]
;  Plot the closed paths:
   PLOTS, xy(*,INFO(I).OFFSET + S ), /NORM
  ENDFOR
endif

return,ncontours

end

; TEST

;wait,1
;
;
;z2=shift(z,5,6)
;clnmap=z+z2
;ch=check_multiplicity(clnmap,0.5,/plot)
;print,ch,' contours'
;wait,1
;
;z2=shift(z,6,7)
;clnmap=z+z2
;ch=check_multiplicity(clnmap,0.5,/plot)
;print,ch,' contours'
;wait,1
;
;z2=shift(z,7,8)
;clnmap=z+z2
;ch=check_multiplicity(clnmap,0.5,/plot)
;print,ch,' contours'
;wait,1
;
;z2=shift(z,8,9)
;clnmap=z+z2
;ch=check_multiplicity(clnmap,0.5,/plot)
;print,ch,' contours'
;wait,1
;
;z2=shift(z,9,10)
;clnmap=z+z2
;ch=check_multiplicity(clnmap,0.5,/plot)
;print,ch,' contours'
;wait,1
;
;z2=shift(z,10,11)
;clnmap=z+z2
;ch=check_multiplicity(clnmap,0.5,/plot)
;print,ch,' contours'
;
;end
;
;
