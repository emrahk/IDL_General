pro cal_lagcohgen,info,mcoh,mlag,ilag

num=n_elements(info.path)
mlag=fltarr(num,2)
mcoh=fltarr(num,2)
ilag=fltarr(num,2)



for i=0,num-1 do begin

xdrfu_r2,info.path[i]+'lag.xdrfu.gz',f,lag
xdrfu_r2,info.path[i]+'errlag.xdrfu.gz',f,lager

ix=where((f ge info.frange(0)) and (f lt info.frange(1)))
lagx=lag[ix,0,1]
lagxer=lager[ix,0,1]

wemean,lagx,lagxer,mean,error

print,i,'mean lag:',mean,error
mlag(i,0)=mean
mlag(i,1)=error

tot=0.
tote=0.
for j=0,n_elements(ix)-1 do begin
   tot=tot+(lagx(j)*(f(ix(1)+j)-f(ix(0)+j)))
   tote=tote+((lagx(j)+lagxer(j))*(f(ix(1)+j)-f(ix(0)+j)))
endfor
toter=(tote-tot)/sqrt(20.)

print,i, 'integrated lag:',tot,toter

ilag(i,0)=tot
ilag(i,1)=toter


xdrfu_r2,info.path[i]+'cof.xdrfu.gz',f,cof
xdrfu_r2,info.path[i]+'errcof.xdrfu.gz',f,cofer

cofx=cof[ix,0,1]
cofxer=cofer[ix,0,1]

;xx=where(cofx gt 1.)
;cofx(xx) = 1.

wemean,cofx,cofxer,mean,error

print,i,'mean coh:',mean,error

mcoh(i,0)=mean
mcoh(i,1)=error

endfor



end
