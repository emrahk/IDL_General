pro readxuld_b,gtifile,hkfile,gxuld,gtime

start=loadcol(gtifile,'START')
stop=loadcol(gtifile,'STOP')
szint=size(start)
xuld0=loadcol(hkfile,'CTXULDD0')
xuld1=loadcol(hkfile,'CTXULDD1')
xuld2=loadcol(hkfile,'CTXULDD2')
xuld3=loadcol(hkfile,'CTXULDD3')
time=loadcol(hkfile,'TIME')
sz=size(time)
xuld=(xuld0+xuld1+xuld2)/3.

ind=where((time gt start(0)) AND (time lt stop(0)))
gxuld=xuld(ind)
gtime=time(ind)
dblch=size(szint)
if dblch(1) gt 3 then begin
  for i=1,szint(1)-1 do begin
    ind=where((time gt start(i)) AND (time lt stop(i)))
    gxuld=[gxuld,xuld(ind)]
    gtime=[gtime,time(ind)]
  endfor
endif
end
