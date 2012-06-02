newcts=lonarr(4,112l*1024l)
fazla=lonarr(4,14l*1024l)
for i=0,3 do begin
    newcts(i,*)=[cts(0,i,0,50l*1024l:78l*1024l-1),cts(1,i,0,114l*1024l:$
142l*1024l-1),cts(2,i,0,18l*1024l:46l*1024l-1),cts(2,i,0,82l*1024l:$
110l*1024l-1)]
fazla(i)=cts(2,i,0,146l*1024l:160l*1024l-1)
endfor
end
