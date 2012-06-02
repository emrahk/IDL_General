pro mesh

x=findgen(100)
y=findgen(100)
plot,x,y,xrange=[200.,300],ticklen=0,/noclip,$
xtickname=[' ',' ',' ',' ',' ',' '],ytickname=[' ',' ',' ',' ',' ',' '],$
posit=[0.08,0.08,0.51,0.886]
for i=0,3 do oplot,[220.+i*20,220.+i*20],[0.0,1.0],line=0
for i=0,3 do oplot,[200,300],[0.2+i*0.2,0.2+i*0.2],line=0
for i=0,23 do oplot,[204+i*4,204+i*4],[0.0,0.2],line=0
for i=0,4 do oplot,[200,300],[0.04+i*0.04,0.04+i*0.04],line=0
box,204,-0.02,216,0.0
box,224,-0.02,236,0.0
box,244,-0.02,256,0.0
box,264,-0.02,276,0.0
box,284,-0.02,296,0.0
box,200.,1.0,300.,1.02
;xyouts,241,0.62,'z0',size=2.0
;xyouts,241,0.82,'z0-1',size=1.8
;xyouts,241,0.42,'z0+1',size=1.8
oplot,[194.,200.],[0.6,0.6],line=0
end
