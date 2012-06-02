pro relat,m,a

G = 6.67e-8
c = 2.998e10
Ms = 1.989e33



;a=1.
;m=6.

;r=6.
r=findgen(50000)/1000.+0.000001


ro=g*m*Ms/c^2

fo=c^3/(G*m*Ms*2.*!PI)


;Kepplerian
K=fo*(r^1.5+a)^(-1)
;Epicyclic (radial)
E=Sqrt(K^2*(1-(6/r)+(8*a/r^1.5)-(3*a^2/r^2)))
;Epicyclic (vertical)
V=Sqrt(K^2*(1-(4*a/r^1.5)+(3*a^2/r^2)))
;Lense Thirring
L=fo*2*a/r^3.
;L=2*a/r^3.

;set_plot,'ps'


tit='M='+string(m)+',   a='+string(a)

;device,filename=strcompress(string(m)+string(a)+'.ps',/remove_all)
plot,r,K,/ylog,thick=2,xtitle='R (GM/c^2)',ytitle='Freq. (Hz)',$
xrange=[0,50],title=tit,/xstyle,yrange=[10,1000],/ystyle
oplot,r,E,line=1
oplot,r,V,line=2
oplot,r,L
oplot,[30,35],[400,400],thick=2
xyouts,36,380,'Kepplerian',size=1.5

oplot,[30,35],[500,500],line=1
xyouts,36,480,'Epicyclic Radial',size=1.5

oplot,[30,35],[600,600],line=2
xyouts,36,580,'Epicyclic Vertical',size=1.5

oplot,[30,35],[700,700]
xyouts,36,680,'Lense Thirring',size=1.5
oplot,[0,50],[72,72]
oplot,[0,50],[280,280]

;device,/close

;$lp -d crmlj5 idl.ps
end
