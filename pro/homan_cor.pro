;pro homan rel.

loadct,2
f=[280.,284.,282.,273.,208.,178.,187.,123.,102.65]
hc=[5*1e-3+[14.,12.,14.,21.,26.,38.,38.,51.,64.]*0.005/17.,0.03]
sc=[0.2+[6.,10.,12.,10.,25,38.,38.,42.,51.]*0.1/23.,0.2]

a = findgen(32)*(!pi*2.0/32.0)
usersym, 1.*cos(a), 1.*sin(a), /fill
usym = 8

kk=1
if (kk eq 1) then begin
   set_plot, 'ps'
   device, filename = 'traxx.ps'
   device, yoffset = 2.0
   device, ysize = 14.0
   ;device, xsize = 12.0
   !p.font=0
   device,/times
endif


plot,hc,sc,psym=8,xrange=[5e-3,0.1],yrange=[0.1,1.],/xlog,$
/ylog,/xstyle,xtitle='Hard Color',ytitle='Soft Color',/ystyle,$
charsize=1.3,color=220
oplot,[0.081,0.03],[0.9,0.15],color=100,psym=8

xyouts,0.032,0.194,'HFQPOs in 98 outburst',size=1.2
xyouts,0.032,0.145,'The 65 Hz QPO',size=1.2
oplot,[0.0075,0.01],[0.21,0.21]
arrow,0.0086,0.21,0.0086,0.18,/data
xyouts,0.0078,0.165,'~280',size=1.3
arrow,0.0113,0.235,0.0116,0.21,/data
xyouts,0.0111,0.193,'273',size=1.3
arrow,0.0126,0.325,0.0126,0.37,/data
xyouts,0.0116,0.38,'208',size=1.3

arrow,0.0161,0.35,0.0161,0.31,/data
xyouts,0.0147,0.28,'182',size=1.3

arrow,0.02,0.4,0.02,0.46,/data
xyouts,0.018,0.48,'123',size=1.3

arrow,0.0238,0.404,0.0238,0.35,/data
xyouts,0.022,0.32,'102',size=1.3

arrow,0.081,0.86,0.081,0.75,/data
xyouts,0.076,0.68,'65',size=1.3

if kk eq 1 then device,/close
end
