xdrfu_r1,'0004096_signormpsd_corr.xdrfu',f1s,p1s,history=hist
xdrfu_r1,'0004096_errnormpsd_corr.xdrfu',f1s,p1se
;xdrfu_r1,'0016384_errnormpsd_corr.xdrfu',f4s,p4se
;xdrfu_r1,'0016384_signormpsd_corr.xdrfu',f4s,p4s
xdrfu_r1,'0524288_signormpsd_corr.xdrfu',f128s,p128s
xdrfu_r1,'0524288_errnormpsd_corr.xdrfu',f128s,p128se

fx=f1s
px=p1s(*,0)
pxe=p1se(*,0)
;rebin_geo,1.05,fx,px,pxe

fy=f128s
py=p128s(*,0)
pye=p128se(*,0)
;rebin_geo,1.05,fy,py,pye

fz=f4s
pz=p4s(*,0)
pze=p4se(*,0)
;rebin_geo,1.05,fz,pz,pze

;ploterror,fy,py,pye,/xlog,/ylog,psym=10,/nohat,xrange=[10,100],yrange=[1e-5,1e-3]
;ploterror,fx,px,pxe,/xlog,/ylog,psym=10,/nohat,xrange=[10,1000],yrange=[1e-5,1e-3]
;ploterror,fz,pz,pze,/xlog,/ylog,psym=10,/nohat,xrange=[10,1000],yrange=[1e-5,1e-3]

end
