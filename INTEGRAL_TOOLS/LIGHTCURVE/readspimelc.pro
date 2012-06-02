pro readspimelc,time,pha,dete,timeall

fileraw='/home/integral/REP/scw/0052/005200550010.000/spi/raw/spi_raw_oper.fits.gz' ; raw data from pha and detector number
fileprp='/home/integral/REP/scw/0052/005200550010.000/spi/prp/spi_prp_oper.fits.gz' ; prepared data for times
gtifile='/home/integral/grb/obs/030320_cor/spi/gti.fits' ; I need the gti file 
; to limit the times


timem=loadcol(fileprp,'OB_TIME',ext=4)  ; times from SE
szm=size(timem)
pham=loadcol(fileraw,'PHA',ext=4)
detem=loadcol(fileraw,'DETE',ext=4)

timm=dblarr(long(szm(2)))

for i=0L,long(szm(2))-1L do timm(i)=timeconv(timem(*,i))

;gti

tstart=loadcol(gtifile,'OBT_START',ext=1)
tend=loadcol(gtifile,'OBT_END',ext=1)

tst=timeconv(tstart(*,0))
tnd=timeconv(tend(*,0))
xx=where((timm ge tst) and (timm le tnd))

timetfg=timm(xx)

timeg=timetfg-tst

timeall=timm
time=timeg
pha=pham(*,xx)-16384.
dete=detem(*,xx)


end
