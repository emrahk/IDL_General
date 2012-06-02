pro merge_katja,indir,outdir,merge

spawn,'pwd',pwd
spawn,'cp -fr '+indir+' '+outdir,/sh
spawn,'rm '+outdir+'/light/fourier/high/merged/*',/sh
spawn,'rm '+outdir+'/light/fourier/high/onelength/*',/sh
spawn,'rm '+outdir+'/light/fourier/high/plots/*',/sh
cd,outdir+'/light/processed/'
spawn,'gunzip *'
spawn,'ls -1 *seg.xdrlc',segfile

xdrlc_r,segfile,time,rate, $
            select=select,history=history, $
            gaps=gaps,nogap=nogap,dseg=dseg, $
            nt=nt,nch=nch,bt=bt,first=first,last=last,$         
            chatty=chatty


num_eband=n_elements(merge)
nel=n_elements(time)

newrate = fltarr(nel,2)

for i=0,num_eband-1 do newrate(*,0) = newrate(*,0) + rate(*,merge(i))
newrate(*,1)=newrate(*,0)

rate = newrate

xdrlc_w,segfile,time,rate, $
            history=history, $
            gaps=gaps,dseg=dseg,chatty=chatty,/gzip

;seg finished

spawn,'ls -1 *sync.xdrlc',syncfile

xdrlc_r,syncfile,time,rate, $
            select=select,history=history, $
            gaps=gaps,nogap=nogap,dseg=dseg, $
            nt=nt,nch=nch,bt=bt,first=first,last=last,$         
            chatty=chatty


nel=n_elements(time)

newrate = fltarr(nel,2)

for i=0,num_eband-1 do newrate(*,0) = newrate(*,0) + rate(*,merge(i))
newrate(*,1)=newrate(*,0)

rate = newrate

xdrlc_w,syncfile,time,rate, $
            history=history, $
            gaps=gaps,dseg=dseg,chatty=chatty,/gzip


spawn,'rm *.xdrlc',/sh
cd,pwd
end
