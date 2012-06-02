;pro crab

idfr=[6353027,6353093]
infile='dat/20804-01-01-010.c1.dat'
dtfile='dat/20804-01-01-010.c1.cor2'
tres=1.D/512.d
eband=[16,100]
print,tres
get_accum,infile,cts,lvt,mode="m",idfrange=idfr,edgs=eband,uldfile=dtfile,$
iarr=idflvt,tres=tres

end

