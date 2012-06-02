pro create_shadow, datasin, shadis, shadpic, ecut=ecut

;using the single events structure, this propgram plots the shadowgram
; FOR NOW, pixels include Aliminum, later it will be converted into full-model

if (NOT keyword_set(ecut)) then ecut=0.

xx=where(datasin.en ge ecut)
datasinecut=datasin(xx)

isg=where(datasinecut.flag eq 'isgr')
pic=where(datasinecut.flag eq 'picsit')
posisg=datasinecut[isg].pos
pospic=datasinecut[pic].pos

shadis=lonarr(128,128)
shadpic=lonarr(64,64)

num=n_elements(isg)

for i=0L,long(num)-1L do begin
  x=floor((posisg(0,i)+30.36)*64./30.36)  
  y=floor((posisg(1,i)+31.28)*32./15.64)
  shadis(x,y)=shadis(x,y)+1L
endfor

num=n_elements(pic)

for i=0L,long(num)-1L do begin
  x=floor((pospic(0,i)+30.36)*32./30.36)  
  y=floor((pospic(1,i)+31.28)*16./15.64)
  shadpic(x,y)=shadpic(x,y)+1L
endfor

plot,[0.,0.],[0.,0.],xr=[0.,65.],yr=[0.,65.],/xstyle,/ystyle

xlis=30.36/64.
ylis=15.64/32.
shadnorm=floor(shadis*255./max(shadis))



for i=0,127 do for j=0,127 do begin
   boxc, i*xlis, j*ylis, (i+1)*xlis, (j+1)*ylis, shadnorm(i,j)   
endfor



end
