;pro getbckg

idfr=[8604902,8604952]
infile='dat/30801-06-04-06.c1.dat'
dtfile='dat/30801-06-04-06.c1.cor2'
tres=1.D/1024.d
eband=[16,100]
get_accum,infile,cts,lvt,mode="m",idfrange=idfr,edgs=eband,uldfile=dtfile,$
iarr=idflvt,tres=tres

save,idfr,cts,filename='cnts3_idl.dat'
;delvar,cts,lvt,idflvt,idfr

idfr=[8605053,8605130]
infile='dat/30801-06-04-06.c1.dat'
dtfile='dat/30801-06-04-06.c1.cor2'
tres=1.D/1024.d
eband=[16,100]
get_accum,infile,cts,lvt,mode="m",idfrange=idfr,edgs=eband,uldfile=dtfile,$
iarr=idflvt,tres=tres

save,idfr,cts,filename='cnts6_idl.dat'
;delvar,cts,lvt,idflvt,idfr



end

