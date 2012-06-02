pro hexte_screen,id=id,cl=cl,obsid=obsid,fullpath=fullpath,psfile=psfile,name=name



!p.multi=[0,1,3]
 savefont=!p.font
       print,'Plotting to PS-File ',psfile
       set_plot,'PS'
       device,/portrait,filename=psfile,$
         yoffset=1.5,xoffset=1.5,xsize=18,ysize=25,/times
       stretch=0.5
       !p.font=0
title=id+'  Cluster '+cl


if cl eq 'a' then hkf=fullpath+obsid+'/hexte/FH53*.gz'
if cl eq 'b' then hkf=fullpath+obsid+'/hexte/FH59*.gz'


gtf=fullpath+id+'/filter/good_hexte.gti'

timehkf=loadcol(hkf,'TIME')
xuld0=loadcol(hkf,'ctXuldD0')
dtob=headfits(fullpath+id+'/filter/FP*')
dobs=fxpar(dtob,'DATE-OBS')
obser=fxpar(dtob,'OBSERVER')
obj=fxpar(dtob,'OBJECT')

foku,fullpath+id+'/hexte/hexte-'+cl+'_src.lc',t,r,tmin
t=t+tmin

plot,timehkf,xuld0,xrange=[min(t),max(t)],/xstyle,xtickname=replicate(' ',20), $
ytitle='XULD0 Counts/s',position=[0.1,0.6,0.95,0.9],charsize=1.5


gtimestart=loadcol(gtf,'START')
gtimestop=loadcol(gtf,'STOP')


tot_time=0.0
for i=0,n_elements(gtimestart)-1 do begin
     oplot,[gtimestart(i),gtimestart(i)],[0,max(xuld0)]
     oplot,[gtimestop(i),gtimestop(i)],[0,max(xuld0)]
     oplot,[gtimestart(i),gtimestop(i)],[max(xuld0),max(xuld0)]
tot_time=tot_time+(gtimestop(i)-gtimestart(i))
endfor

saai=loadcol(hkf,'SaaInternal')
saae=loadcol(hkf,'SaaExternal')

saat=intarr(n_elements(timehkf))
for j=0,n_elements(timehkf)-1 do if saai(j)+saae(j) gt 0 then saat(j)=1

plot,timehkf,saat*0.7,xrange=[min(t),max(t)],/xstyle,yrange=[-0.1,0.9],$
/ystyle,position=[0.1,0.5,0.95,0.6],xtickname=replicate(' ',20),$
ytickname=replicate(' ',20),ytitle='SAA',charsize=2.0,psym=10,yticklen=0.0001
xyouts,min(t),0.05,'OUT OF SAA'
xyouts,min(t),0.75,'IN SAA'

plot,t,r,xrange=[min(t),max(t)],/xstyle,ytitle=' (Good) Counts/s',$
xtitle='Time',position=[0.1,0.3,0.95,0.5],charsize=1.5
for i=0,n_elements(gtimestart)-1 do begin
     oplot,[gtimestart(i),gtimestart(i)],[0,max(r)]
     oplot,[gtimestop(i),gtimestop(i)],[0,max(r)]
     oplot,[gtimestart(i),gtimestop(i)],[max(r),max(r)]
endfor
spawn,'date',date

xyouts,(0.1+0.95)/2.,0.96,title,alignment=0.5,/normal,size=1.6
xyouts,(0.1+0.95)/2.,0.12,name,alignment=0.5,/normal,size=1.
xyouts,(0.1+0.95)/2.,0.08,date,alignment=0.5,/normal,size=1.

xyouts,(0.1+0.95)/2.,0.22,'Obs_id: '+obsid,alignment=0.5,/normal,size=1.2
xyouts,(0.1+0.95)/2.,0.20,'Object: '+obj,alignment=0.5,/normal,size=1.2
xyouts,(0.1+0.95)/2.,0.18,'Date of Observation: '+dobs,alignment=0.5,/normal,$
size=1.2
xyouts,(0.1+0.95)/2.,0.16,'Total good time (s) : ',alignment=0.5,/normal,$
size=1.2
xyouts,(0.1+1.30)/2.,0.16,tot_time,alignment=0.5,/normal,size=1.2

device,/close

set_plot,'X'
!p.font=savefont

end
