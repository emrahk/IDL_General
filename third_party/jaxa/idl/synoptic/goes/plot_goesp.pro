

pro plot_goesp, p0, p1, goesp, xray=xray, $
        nodefcolors=nodefcolors, nowindow=nowindow, $
        pchannels=pchannels, echannels=echannels, hour_window=hour_window, $
        proton_only=proton_only, electron_only=electron_only, zbuffer=zbuffer, $
        _extra=_extra, reverse=reverse, $
        goes8=goes8, goes9=goes9, goes10=goes10, goes11=goes11, goes12=goes12, $
        nolegend=nolegend, debug=debug, ytype=ytype, log=log, $
        clear_legend=clear_legend, legend_bottom=legend_bottom, $
        right=right, bottom=bottom, center=center

;+ 
;   Name: plot_goesp
;
;   Purpose: demo read & plot GOES proton/electron values
;
;   Input Parameters:
;      p0 - Tstart for  read/plot OR vector of GOES particle structures (rd_goesp_ascii output)
;      p1 - Tstop time for read/plot GOES particle structure.
;
;   Output Parameters:
;      goesp - optional output GOES particle records (if p0/p1 = time range)
;     
;   Keyword Parameters:
;      nodefcolors - (switch) - if set, dont use "fancy" colors
;      nowindow - (switch) - dont make a new window
;      reverse - (switch) - implies /NODEFCOLORS - true for white on black
;      pchannels - (optional) - array of Proton/Part channels to plot ( def=indgen(6) )
;      echannels - (optional) - array of Electron channesl to plot ( def=indgen(3) )
;      hour_window - optional time window (in hours) to plot (1 or 2 elem array)
;                    (ignored if time range or structure are input)
;      _extra - unrecognized keywords -> utplot via inheritance
;      proton_only - (switch) if set, only plot proton data
;      electron_only - (switch) if set, only plot electron data
;      ytype - (standard RSI definition - pass to utplot)
;      log   - sets ytype=1 (log plot)
;      goesN (where N in {8,9,10,12}) - desired GOES satellite
;
;   Calling Sequence:
;      IDL> plot_goesp, time0, time1 [,/xray] [,pchannels=parray] [,echannels=earray]
;
;   Calling Examples:
;      IDL> plot_goesp, time0, time1, [OPTIONS] ; user supplied time range  
;           -OR- 
;      IDL> plot_goesp, goesp         [OPTIONS] ; user supplied GOESP structures    
;                                               ; ( ie, rd_goesp_ascii output)
;
;           Plot all Proton and Electron channels, log (garish!)
;      IDL> plot_goesp,'14-jul-2000','17-jul-2000',/ytype  
;
;           Plot only 3 low proton channels , linear, to Zbuffer
;      IDL> plot_goesp,'14-jul-2000','17-jul-2000',pchan=[0,1,2],/proton,/zbuff
;
;           Plot only low electron channel in existing color table, reversed
;           Structure vector returned in GOESP (3rd parameter)
;      IDL> plot_goesp,'14-jul-2000','17-jul-2000',goesp,/electron,echan=0,/reverse
;                                                 | OUT |
;   Referenced Routines:
;      rd_goesp_ascii, rd_gxd, time_window, linecolors, wdef, 
;      utplot, required_tags, data_chk
;
;   History:
;      17-July-2000 - demo use of 'rd_goesp_ascii' and/or do some summary plots
;      19-Oct-2001  - allow no parameters (last ~24 hours)
;       9-apr-2003 - add /GOES10 + /GOES12 (-> rd_goesp_ascii) - GOES 8 off ~8-apr-2003
;       1-jun-2003 - add /CLEAR_LEGEND (-> legend,/CLEAR ) 
;      19-jun-2003 - add /GOES11 (-> rd_goesp_ascii) - GOES 11 parking but P+ Primary
;   
;   Side Effects:
;      May make an Xwindow (override via /ZBUFFER)
;      loads 'linecolors.pro' color table (override via /REVERSE or /NODEFCOL)
;-

; ----------- figure out user input (time range, etc) --------------------
if not keyword_set(hour_window) then hour_window=12        ; def= +/- 12 hours
case 1 of 
   required_tags(p0,'day,mjd,p,elec'): begin               ; user input goesp structs.
      goesp=p0                                             ; (rd_goesp_ascii output)
      rd_goesp_ascii, plabels=plabels, elabels=elabels, /labels_only ,/short_lab, _extra=_extra; get lables
   endcase
   n_params() eq 1: time_window,p0,t0,t1,hour=hour_window  ; 
   n_params() ge 2: time_window,strtrim([p0,p1],2),t0,t1              ; user input time range
   else: begin 
         t1=reltime(/now, out_style='vms')
         t0=reltime(days=-1, /day_only,out_style='vms')
   endcase
endcase

; ----------- read the GOES particle data base via 'rd_goesp_ascii'
; set time dependent GOES Sat# defaults (override with explicite keyword)
goes9= keyword_set(goes9)  or (ssw_deltat(t1,ref='25-jul-1998') lt 0)   ; def 9 before this
goes10=keyword_set(goes10) or ssw_deltat(t1,ref='8-apr-2003') gt 0      ; def 10 after this
goes8= keyword_set(goes8) or ((1-goes9) and (1-goes10))                 ; def  8 between
goes11=keyword_set(goes11) ; or (ssw_deltat(t1,ref='19-jun-2003') gt 0 and goes10)
goes10=goes10*(1-goes11) 
goes12=keyword_set(goes12)

satlist=''
if exist(t0) and exist(t1) then begin
   rd_goesp_ascii,t0, t1,goesp, plabels=plabels, elabels=elabels, /short_lab, $
      goes8=goes8, goes9=goes9, goes10=goes10, goes11=goes11, goes12=goes12, files=files,_extra=_extra
   satlist=$
    arr2str(strarrcompress(all_vals(strcompress(strextract(files,'G','part_')))),'/')
endif
help,t0,t1,satlist

if not required_tags(goesp,'time,mjd,p,elec') then begin 
   box_message,['Problem (missing?) GOES particle dbase',$
                'See: http://www.lmsal.com/solarsoft/sswdb_description.html']
   return
endif
   
if not exist(ytype) then ytype=0
; ---------- set switch states ----------------
proton_only=keyword_set(proton_only)
electron_only=keyword_set(electron_only)
reverse=keyword_set(reverse)
nodefcolors=keyword_set(nodefcolors) or reverse
debug=keyword_set(debug)
nolegend=keyword_set(nolegend)
nowindow=keyword_set(nowindow)
zbuffer=keyword_set(zbuffer)
log=keyword_set(log) or (ytype and '1'x)   ; need this for later...
ytype=ytype or log
; ---------------------------------------------

npc=data_chk(gt_tagval(goesp,/p),/nx)      ; number proton channels available
nec=data_chk(gt_tagval(goesp,/elec),/nx)   ; number electron channels available

; ------------- define channel subsets of interest --------------
if n_elements(pchannels) eq 0 then pchannels=indgen(npc) else pchannels=pchannels>0<(npc-1)
if n_elements(echannels) eq 0 then echannels=indgen(nec) else echannels=echannels>0<(nec-1)

dtemp=!d.name                              ; dont clobber plot device

case 1 of
   nowindow and zbuffer: set_plot,'Z'
   nowindow:
   else: wdef,xx,768,512, zbuffer=zbuffer, title='GOES '+satlist+ ' Particle Events' ; <<<< TODO
endcase

if not keyword_set(nodefcolors) then begin 
   linecolors                                           ; load 'fancy' colors
   goodcolors=[4,5,7,9,12,2]                            ; linecolors subset
   pcolors=(goodcolors)(0:npc-1)                        ; proton colors
   ecolors=(shift(goodcolors,-3))(0:nec-1)              ; electron (shift)
   background=11
   maincolor=!p.color
endif else begin 
   pcolors=replicate(([!p.color,0])(reverse),npc)
   ecolors=replicate(([!p.color,0])(reverse),nec)
   background=([0,!p.color])(reverse)
   maincolor=!p.color-background
endelse


; ----------- scale plot to maximum (P/E) --------------------
p0max=max((gt_tagval(goesp,/p))(0,*))
e0max=max((gt_tagval(goesp,/elec))(0,*))
case 1 of 
   proton_only:   begin
      init='p(0,*)'
      units="Protons/cm2-s-sr"
      mtitle="GOES Proton Events"
   endcase
   electron_only: begin
      init='elec(0,*)'
      units="Electrons/cm2-s-sr"
      mtitle="GOES Electron Events"
   endcase
   else:          begin
      init=(['elec(0,*)','p(0)'])(p0max ge e0max)
      units='Events/cm2-s-sr'
      mtitle="GOES Proton/Electron Events"
   endcase
endcase

mtitle=str_replace(mtitle,'GOES ','GOES ' + satlist + ' ')

estat=execute('ymax=max(goesp.'+init+')')
yrange=[([0,.0001])(log),ymax]

init=init+(['>0','>.0001'])(log)                     ; log protect

; ------------- initialize the plot ----------------
ytitle=units
if log and not exist(ytype) then ytype=log

initcmd='utplot, goesp, goesp.'+init + $
  ',ytype=ytype,title=mtitle,ytitle=ytitle,color=maincolor,background=background,/xstyle,/ystyle,/nodata,_extra=_extra,yrange=yrange'
estat=execute(initcmd)

if electron_only then npc=0
if proton_only   then nec=0

npc=npc<n_elements(pchannels)
nec=nec<n_elements(echannels)

ppsym=-1           
epsym=-4

for i=0, (npc-1) do $
   outplot,goesp,goesp.p(pchannels(i)), color=pcolors(i), $
      symsize=.5, psym=ppsym

for i=0,nec-1 do $
   outplot,goesp,reform(goesp.elec(echannels(i))),color=ecolors(i), $
      symsize=.5, psym=epsym


; ----------------- add a legend ---------------------------------------
if not keyword_set(nolegend) then begin            ; build legend info
   lcols=-1
   llabs=''
   lpsym=-1
   if npc gt 0 then begin                          ; add Proton info
      lcols=[lcols,pcolors(0:npc-1)]
      llabs=[llabs,plabels(0:npc-1)]
      lpsym=[lpsym,replicate(ppsym,npc)]
   endif     
   if nec gt 0 then begin                          ; add Electron info
      lcols=[lcols,ecolors(0:nec-1)]
      llabs=[llabs,elabels(0:nec-1)]
      lpsym=[lpsym,replicate(epsym,nec)]   
   endif

   if n_elements(lcols) gt 1 then begin 
      legend,llabs(1:*), psym=lpsym(1:*), colors=lcols(1:*), $
         background=background, $                 ; -> legend.pro
         bottom=(keyword_set(bottom) or keyword_set(legend_bottom)), right=right, center=center, $                      
         charsize=.7,textcolors=!p.color-background ; add legend
   endif
endif


if debug then stop,'debug...'

set_plot,dtemp                                      ; restore users plot device

return
end
