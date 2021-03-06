pro cleanup,data,hkdata,tracer,hktracer,prange=prange,det=det

if (NOT keyword_set(det)) then det=0

!p.multi=[0,1,5]

;limit the pointing range
if prange[0] eq 0 then begin
   subtr=[0,total(hktracer[0:prange[1]].nel)-1L]
   subd=[0,total(hkdata[0:prange[1]].nel)-1L]
endif else begin
   subtr=[total(hktracer[0:prange[0]-1].nel),$
	   total(hktracer[0:prange[1]].nel)-1L]
   subd=[total(hktracer[0:prange[0]-1].nel),$
	 total(hkdata[0:prange[1]].nel)-1L]
endelse

;newdata=data[subd[0]:subd[1]]
newtracer=tracer[subtr[0]:subtr[1]]

;cleanup criteria ?
;1. deadtime

plot,newtracer.time,newtracer.dt[det],yr=[0.1,0.15],$
/ystyle,/xstyle,ytitle='DT'

  oplot,[newtracer[0].time,newtracer[0].time],[0.,.15]
  for i=0,(prange[1]-prange[0]) do begin

     xyouts,newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time-1000.,0.14,strtrim(string(prange[0]+i),1)
     oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time],$
           [0.1,.15]
    if i ne prange[1]-prange[0] then oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time],$
           [0.1,.15]
  endfor  

;2. geds

plot,newtracer.time,newtracer.geds[det],yr=[100,300],$
/ystyle,/xstyle,ytitle='geds'

  oplot,[newtracer[0].time,newtracer[0].time],[100.,300.]
  for i=0,(prange[1]-prange[0]) do begin
    oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time],$
           [100.,300.]
    if i ne prange[1]-prange[0] then oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time],$
           [100.,300.]
  endfor  

;3. acsab

plot,newtracer.time,newtracer.acs_ab,yr=[5000,8000],$
/ystyle,/xstyle,ytitle='acs_ab'

  oplot,[newtracer[0].time,newtracer[0].time],[5000.,8000.]
  for i=0,(prange[1]-prange[0]) do begin
    oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time],$
           [5000.,8000.]
    if i ne prange[1]-prange[0] then oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time],$
           [5000.,8000.]
  endfor  

;4. acs_bw

plot,newtracer.time,newtracer.acs_bw,yr=[50000,80000],$
/ystyle,/xstyle,ytitle='acs_bw'

  oplot,[newtracer[0].time,newtracer[0].time],[50000.,80000.]
  for i=0,(prange[1]-prange[0]) do begin
    oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time],$
           [50000.,80000.]
    if i ne prange[1]-prange[0] then oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time],$
           [50000.,80000.]
  endfor  

;5. acsd ??

plot,newtracer.time,newtracer.acsd,yr=[0.06,0.1],$
/ystyle,/xstyle,ytitle='acsd'

  oplot,[newtracer[0].time,newtracer[0].time],[0.06,0.1]
  for i=0,(prange[1]-prange[0]) do begin
    oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))-1L].time],$
           [0.06,.1]
    if i ne prange[1]-prange[0] then oplot,[newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time,$
           newtracer[long(total(hktracer[prange[0]:prange[0]+i].nel))].time],$
           [.06,.1]
  endfor  

end
