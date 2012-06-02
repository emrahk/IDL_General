pro pixellate, data, angx

;using the multiple events structure, this propgram pixellates the
;event position distribution, simplifying solution before FULL model

dataml=data

num=n_elements(dataml)
angx=fltarr(num)

xlis=30.36/64.
ylis=15.64/32.
xlpic=30.36/32.
ylpic=15.64/16.

for i=0L,long(num)-1L do begin
  if ((dataml[i].dete[0]) lt 8) then begin
     x1=floor((dataml[i].pos(0,0)/xlis)*xlis)+(xlis/2.)  
     y1=floor((dataml[i].pos(1,0)/ylis)*ylis)+(ylis/2.)
     x2=floor((dataml[i].pos(0,1)/xlpic)*xlpic)+(xlpic/2.)  
     y2=floor((dataml[i].pos(1,1)/ylpic)*ylpic)+(ylpic/2.)
   endif else begin
     x1=floor((dataml[i].pos(0,0)/xlpic)*xlpic)+(xlpic/2.) 
     y1=floor((dataml[i].pos(1,0)/ylpic)*ylpic)+(ylpic/2.)
     x2=floor((dataml[i].pos(0,1)/xlis)*xlis)+(xlis/2.) 
     y2=floor((dataml[i].pos(1,1)/ylis)*ylis)+(ylis/2.)
   endelse

 x=(x2-x1)
 y=(y2-y1)

 if x eq 0 then x=x+1e-8
 ang=atan(y/x)*180./!PI
 angx[i]=ang
 if ((x lt 0) and (y ge 0)) then angx[i]=180+ang
 if ((x le 0) and (y lt 0)) then angx[i]=180+ang
 ;if ((x eq 0) and (y lt 0)) then angx=+ang
 if ((x ge 0) and (y lt 0)) then angx[i]=360+ang

endfor

 end
