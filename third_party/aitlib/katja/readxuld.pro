pro readxuld,gtifile,hkfile,gxuld,gtime,cluster_a=cluster_a,cluster_b=cluster_b

; Note: Emrah kalemci 2001/10/04 cluster_a and cluster_b keywords added...

sum=cluster_a+cluster_b
IF (sum EQ 0) THEN cluster_a=1
IF (sum GE 2) THEN message,'psdcorr_hexte: Only one cluster can be specified'

start=loadcol(gtifile,'START')
stop=loadcol(gtifile,'STOP')
szint=size(start)
xuld0=loadcol(hkfile,'CTXULDD0')
xuld1=loadcol(hkfile,'CTXULDD1')
xuld2=loadcol(hkfile,'CTXULDD2')
xuld3=loadcol(hkfile,'CTXULDD3')
time=loadcol(hkfile,'TIME')
sz=size(time)

IF keyword_set(cluster_a) THEN BEGIN    
   xuld=(xuld0+xuld1+xuld2+xuld3)/4.
ENDIF ELSE BEGIN
   xuld=(xuld0+xuld1+xuld3)/3.
ENDELSE

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
