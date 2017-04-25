pro ssw_last_event_summary,path

phttp='/net/diapason/www1/htdocs/solarsoft'
set_logenv,'path_http',phttp
set_logenv,'top_http','http://www.lmsal.com/solarsoft'

if n_elements(path) eq 0 then path=concat_dir(phttp,'last_events')

cat=file_list(path,'*geny')
if cat(0) eq '' then begin 
   box_message,'No catalog available'
   return
endif

restgenx,file=cat(0),floc

ss=where(floc.lfiles ne '',gcnt)
floc=floc(ss)
time_window,floc.date_obs,t0x,t1x,out='vms',hour=2

set_plot,'z'
wdef,xx,1280,700,/zbuffer
linecolors
savesys,/aplot
!p.multi=[0,1,3]

!p.charsize=1.2
plot_goes,t0x,t1x,timerange=[t0x,t1x],back=11,color=7, xstyle=1, $
   ymargin=[2,3],xmargin=[8,0],/nolabel
evt_grid,anytim(floc.date_obs,/int),color=4,label=floc.helio,$
   labpos=stag_lab(floc.helio,min=.88,max=.98,sep=.03),labsize=.9, $
   labcolor=4
evt_grid,anytim(floc.date_obs,/int),labcolor=9,label=strtrim(indgen(gcnt)+1,2), $
    labpos=stag_lab(floc.helio,min=.895,max=.995,sep=.03), labsize=.9,/noline, $
    /imap,imagemap_coord=imc,/imcircle

plot_goesp, t0x, t1x,  xstyle=1, /nowindow, /log, $
   ymargin=[2,3], xmargin=[8,0], /proton_only,timerange=[t0x,t1x], $
   yrange=[1,10e4],/ystyle,/nolabel 

acedata=get_acedata(t0x,t1x,/daily,/swepam)
utplot,acedata,acedata.b_speed,title='ACE/SWEPAM',ytitle='Bulk Speed (Km/Hr)', $
   ymargin=[4,2], xmargin=[8,0],timerange=[t0x,t1x], xstyle=1, /ynozero,color=7

summary='summary_plot.png'
plot_summ=concat_dir(path,summary)

zbuff2file2,plot_summ
restsys,/aplot  


; generate top page
nevt=n_elements(floc)
epngs=concat_dir(path,floc.ename+'.png')
hpngs=str_replace(epngs,'png','html')
break_file,epngs,ll,pp,ff,ee,vv
relepng=ff+ee+vv
;
; Generate HTML table
table=get_infox(floc,'ename,fstart,fstop,fpeak,class,helio',header=header)
table=strjustify(strtrim(sindgen(nevt)+1,2)) + ' ' + table
tcols=str2cols(table)

; Eliminate extraneous date information 
tcols(2,0)=tcols(2,*) + tcols(3,*)
tcols(3,*)=''
tcols(4,*)=''
tcols(6,*)=''
tcols=strarrcompress(tcols,/col)

header=str2arr('Event#,EName,Start,Stop,Peak,GOES Class, Derived Position (EIT 195)') 
htable=[[header],[tcols]] 


; Generate a page for each event 
for i=0,nevt-1 do begin
   html_doc,hpngs(i),/header
   file_append,hpngs(i),strtab2html(htable(*,[0,i+1]),/row0)
   file_append,hpngs(i),$
       strtab2html('<IMG SRC="'+ relepng(i)+'">')
   html_doc,hpngs(i),/trailer
endfor
html_linklist,hpngs,insert='sundiv.gif'         ; link-list the event html files  
index=concat_dir(path,'index.html')
enames=strtrim(reform(tcols(1,*)),2)
tcols(1,*)=str2html(enames+'.html',link=enames,/nopar)

; Generete the index
html_doc,index,/header
;file_append,index,strtab2html('<IMG SRC="'+summary+'">')
imaphtml=ssw_imapcoord2html(summary,imc,enames+'.html',target='_blank')
file_append,index,'<h3> Click on Event# (Blue) for event summary page</h3>'
file_append,index,imaphtml
file_append,index,strtab2html([[header],[tcols]],/row0,cellpad=5,cellspac=2,border=2)
html_doc,index,/trailer


return
end
