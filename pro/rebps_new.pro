; rebin power spec

;set_plot,'ps'
;device,filename='/rocky/ek/bckg_biff/ps3.ps'
sz=2000
fbs=64
bf=16
;avgd=tot_idfs
i=1
j=1
psp=p
rbpspec=psp(0)
rbf=f(0)
;rbsg=psp(0)/sqrt(avgd)

nue=0
nub=1

while(nue LE sz) do begin
      tmp_ps=rebin(psp(nub:(i*fbs)),bf)
      tmp_f =rebin(f(nub:(i*fbs)),bf)
      ;tmp_sg=tmp_ps/sqrt(bf*j)/sqrt(avgd)
      rbpspec=[rbpspec,tmp_ps]
      rbf= [rbf,tmp_f]
      ;rbsg = [rbsg, tmp_sg]
      nub=i*fbs+1
      i=i+2.^j
      j=j+1
      nue=i*fbs
      print,j,i,nub,nue
endwhile
;ploterr,rbf,rbpspec,rbsg,itype=2


plot_oi,rbf,rbpspec/128.,xrange=[0.02,512],psym=10,/xstyle,/ystyle,$
title='biff_bckg,det:3,par:16',xtitle='f',ytitle='power'
oplot,[0.02,512],[2.0,2.0],line=2

fr=findgen(5000)/10.+0.1
;oplot,fr,2.+2.*80.*ro*sin(!PI*2.5e-3*fr)^2/(!PI*!PI*fr*fr),psym=3
;device,/close
end
