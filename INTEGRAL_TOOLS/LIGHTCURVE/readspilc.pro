pro readspilc,time,pha,dete,timeall,gaps,gpcor,ext=ext

fileraw='/home/integral/REP/scw/0052/005200550010.000/spi/raw/spi_raw_oper.fits.gz' ; raw data from pha and detector number
fileprp='/home/integral/REP/scw/0052/005200550010.000/spi/prp/spi_prp_oper.fits.gz' ; prepared data for times
gtifile='/home/integral/grb/obs/030320_cor/spi/gti.fits' ; I need the gti file 
; to limit the times

if (NOT keyword_set(ext)) THEN ext=0  ; default is SE+PE

times=loadcol(fileprp,'OB_TIME',ext=1)  ; times from SE
timep=loadcol(fileprp,'OB_TIME',ext=2)  ; times from PE
szs=size(times)
szp=size(timep)


if ((ext eq 0) or (ext eq 1)) then begin
  phas=loadcol(fileraw,'PHA',ext=1)
  detes=loadcol(fileraw,'DETE',ext=1)
endif 

if ((ext eq 0) or (ext eq 2)) then begin
  phap=loadcol(fileraw,'PHA',ext=2)
  detep=loadcol(fileraw,'DETE',ext=2)
endif 

tims=dblarr(long(szs(2)))
timp=dblarr(long(szp(2)))

for i=0L,long(szs(2))-1L do tims(i)=timeconv(times(*,i))
for i=0L,long(szp(2))-1L do timp(i)=timeconv(timep(*,i))

timebefsort=[tims,timp]
srt=sort(timebefsort)
timesp=timebefsort(srt)

;gti

tstart=loadcol(gtifile,'OBT_START',ext=1)
tend=loadcol(gtifile,'OBT_END',ext=1)

tst=timeconv(tstart(*,0))
tnd=timeconv(tend(*,0))
xx=where((timesp ge tst) and (timesp le tnd))

timetfg=timesp(xx)

timeg=timetfg-tst

gaps=fltarr(2,n_elements(timeg))

j=0

for i=1L, long(n_elements(timeg))-1L do begin
  if timeg(i)-timeg(i-1) ge 0.1 then begin
     gaps(0,j)=i
     gaps(1,j)=timeg(i)-timeg(i-1)
     j=j+1
  endif
endfor
gaps=gaps(*,0:j-1)

gpbin=fltarr(n_elements(timeg))

for j=0,(n_elements(gaps)/2)-1 do begin

  ch1=floor(timeg(gaps(0,j)-1))
  ch2=floor(timeg(gaps(0,j)))
  
  if ch1 eq ch2 then gpbin(ch1)=gpbin(ch1)+gaps(1,j)
  if ch2 gt ch1 then begin 
      gpbin(ch1)=gpbin(ch1)+ch2-timeg(gaps(0,j)-1)
      gpbin(ch2)=gpbin(ch2)-ch2+timeg(gaps(0,j))
  endif     
endfor

gpcor=gpbin

case ext of 
0: begin
 timeall=timesp
 time=timeg
 phabfsort=[phas,phap]
 phasp=phabfsort(srt)-16384.
 pha=phasp(xx)
 detebfsort=[detes,detep]
 detesp=detebfsort(srt)
 dete=detesp(xx)
end

1: begin
 timeall=times
 xx=where((times ge tst) and (times le tnd))
 time=times(xx)-tst
 pha=phas(xx)-16384.
 dete=detes(xx)
end

2: begin
 timeall=timep
 xx=where((timep ge tst) and (timep le tnd))
 time=timep(xx)-tst
 pha=phap(xx)-16384.
 dete=detep(xx)
end

endcase

end
