pro plot_ace, pt0, pt1, acedata, _extra=_extra, ytype=ytype, $
  electrons_only=electrons_only, protons_only=protons_only, $
  nowindow=nowindow, nolegend=nolegend, zbuffer=zbuffer, $
  linear=linear, log=log, $
  debug=debug, swepam=swepam, epam=epam, mag=mag, sis=sis, $
  daily=daily, monthly=monthly, tag=tag   , units=units, $
  xsize=xsize, ysize=ysize, $ 
  multi=multi, particles=particles, wind=wind, $
  status=status, use_data=use_data, clear_legend=clear_legend
;+
;   Name: plot_ace
;
;   Purpose: plot ACE timeseries for user selected time/instrument
;
;   Input Parameters:
;      pt0, pt1 - time range (any SSW formats)
;
;   Keyword Parameters:
;      /EPAM, /SWEPAM, /SIS, /MAG - which ACE instrument to plot
;
;      ytype - rsi standard ( /YTYPE <=> YTYPE=1 <=> log plot )
;
;      protons_only - if set, only plot protons (EPAM only)
;      electrons_only - if set, only plot electrons (EPAM only)
;      particles - if set, particle summary (EPAM e, p, + SIS) stack 
;      wind      - if set, SWEPAM (wind/density/temp) + MAG-Bz stack
;      status (output) - return zero (0) if no data in range, 1 if data found
;      use_data (input) - user/caller supplied vector of acedata
;                         (used in recusively to avoid re-reads of multi-channel data 
;                          in multi-plot modes like /PARTICLE and /WIND) 
;
;   History:
;      19-October-2001 - S.L.Freeland 
;      11-Nov-2002 - S.L.Freeland - add some options 
;                    (TAG,/PARTICLES,/WIND)
;       5-Dec-2002 - add USE_DATA keyword and function
;       1-jun-2003 - S.L.Freeland - add /CLEAR_LEGEND (-> legend.pro,/CLEAR)
;
;   Calls:
;      get_acedata, reltime, usual ssw suspects
;
;-
particles=keyword_set(particles)
wind=keyword_set(wind)

ssx=get_tag_index(_extra , 'XSIZE')
ssy=get_tag_index(_extra , 'YSIZE')

if ssx(0) ne -1 then xsize=gt_tagval(_extra,/XSIZE)
if ssy(0) ne -1 then ysize=gt_tagval(_extra,/YSIZE)

if not keyword_set(xsize) then xsize=768
if not keyword_set(ysize) then ysize=512


case n_params() of 
   0: begin 
         t1=reltime(/now, out_style='vms')
         t0=reltime(days=-1, /day_only,out_style='vms')
   endcase
   1: begin 
        t0=reltime(pt0,/day_only,out_style='vms')
        t1=reltime(pt0,days=1,out_style='vms',/day_only)
   endcase
   else: begin 
      t0=anytim(pt0,/vms)
      t1=anytim(pt1,/vms)
   endcase
endcase

first_daily='7-aug-2001'             ; for auto daily<->monthly
daily=keyword_set(daily)
monthly=keyword_set(monthly)
case 1 of 
   daily or monthly: 
   else: begin
      daily=ssw_deltat(t0,ref=first_daily,/day) ge 0
      monthly=1-daily
      box_message,'Auto select; Using ' + (['monthly','daily'])(daily) + ' ACE dbase'
   endelse
endcase 

daily=ssw_deltat(t0, ref=reltime(/now),/day) gt -31

help,swepam,epam,sis,mag 
if data_chk(use_data,/struct) then acedata=use_data else $
   acedata=get_acedata(t0,t1,daily=daily,monthly=monthly, $
      swepam=swepam, epam=epam, sis=sis, mag=mag)
status=data_chk(acedata,/struct)
if not status then begin 
   box_message,'No ACE data for time range: '  + anytim([t0,t1],/vms,/trunc)
   return
endif

tn=tag_names(acedata)
npc=total(strmid(tn,0,1) eq 'P')>0
nec=total(strmid(tn,0,1) eq 'E')>0

if not exist(ytype) then ytype=0
; ---------- set switch states ----------------
protons_only=keyword_set(protons_only)
electrons_only=keyword_set(electrons_only)
reverse=keyword_set(reverse)
nodefcolors=keyword_set(nodefcolors) or reverse
debug=keyword_set(debug)
nolegend=keyword_set(nolegend)
nowindow=keyword_set(nowindow)
zbuffer=keyword_set(zbuffer)
log=keyword_set(log) or (ytype and '1'x)   ; need this for later...
linear=keyword_set(linear) 
ytype=ytype or log
; ---------------------------------------------

; ------------- define channel subsets of interest --------------

case 1 of 
   npc eq 0: 
   n_elements(pchannels) eq 0: pchannels=indgen(npc)
   else: pchannels=pchannels>0<(npc-1)
endcase

case 1 of 
   nec eq 0:
   n_elements(echannels) eq 0: echannels=indgen(nec)
   else: echannels=ehannels>0<(nec-1)
endcase

dtemp=!d.name                              ; dont clobber plot device


if not keyword_set(nodefcolors) then begin 
  linecolors                                           ; load 'fancy' colors
   goodcolors=[4,5,7,9,2,4]                            ; linecolors subset
   pcolors=goodcolors                        ; proton colors
   ecolors=(shift(goodcolors,-2));                      ; electron (shift)
   background=11
   maincolor=!p.color
endif else begin 
   pcolors=replicate(([!p.color,0])(reverse),npc)
   ecolors=replicate(([!p.color,0])(reverse),nec)
   background=([0,!p.color])(reverse)
   maincolor=!p.color-background
endelse


; ----------- scale plot to maximum (P/E) --------------------

if data_chk(tag,/string) then init=tag
sweptags=str2arr('B_SPEED,P_DENSITY,ION_TEMP')

multi=particles or wind                   ; summary stack plot requested?
help,particles,wind
print,'>>>>',!p.multi
if multi then begin 
     
   if particles then begin 
      !p.multi=[0,1,3]
       plot_ace,pt0,pt1, acedata, _extra=_extra,/epam,/protons, nowindow=nowindow, $
          xsize=768, ysize=768, charsize=1.5,symsize=.4
       plot_ace,pt0,pt1,acedata, _extra=_extra,/epam,/electrons,/nowindow, $
           charsize=1.5,symsize=.4, use_data=acedata
       plot_ace,pt0,pt1,_extra=_extra,/sis,/nowindow, charsize=1.5,symsize=.4
   endif else begin 
   !p.multi=[0,1,4]
   delvarx,acedata
   for i=0,n_elements(sweptags)-1 do plot_ace,pt0,pt1,_extra=_extra,   $
                  tag=sweptags(i),nowindow=(i ne 0), color=7, $
                  xsize=768,ysize=768,charsize=1.5,symsize=.4, use_data=acedata
   plot_ace,pt0,pt1,/mag,tag='BZ', _extra=_extra, /nowindow, color=7 , $ 
        charsize=1.5,symsize=.4
   endelse
   ;restsys,/aplot,/init
   !p.multi=0

   return
endif 

case 1 of
   nowindow and zbuffer: set_plot,'Z'
   nowindow:
   else: wdef,xx,xsize,ysize, zbuffer=zbuffer, title='ACE' ; <<<< TODO
endcase

case 1 of 
   required_tags(acedata,'P_DENSITY,B_SPEED,ION_TEMP'): begin 
      mtitle='ACE/SWEPAM'
      if n_elements(init) eq 0 then begin 
         init='B_SPEED' 
   ;      units='Bulk Speed (Km/Sec)'
      endif
      p0max=max(gt_tagval(acedata,init))
      plabels='Bulk Speed'
      ptags=init
      etags=init
      protons_only=1
   endcase
   required_tags(acedata, 'E38_53,P112_187'): begin  
      mtitle='ACE/EPAM'
      init=(['P112_187','E38_53'])(electrons_only)
      poma=max(gt_tagval(acedata,init))
   ;   units='Differential Flux/cm2-s-ster-MeV'
      tn=tag_names(acedata)
      ptags=tn(where(strmid(tn,0,1) eq 'P'))
      etags=tn(where(strmid(tn,0,1) eq 'E')) 
      p0=ssw_strsplit(ptags,'_',/head,tail=p1)
      e0=ssw_strsplit(etags,'_',/head,tail=e1)
      plabels='Prot: ' + strjustify(strtrim(str2number(p0),2)) + $
              ' - ' + strjustify(strtrim(str2number(p1),2))
      elabels='Elec: ' + strjustify(strtrim(str2number(e0),2)) + ' - ' + $
                         strjustify(strtrim(str2number(e1),2))

   endcase
   required_tags(acedata,'P_GT10MEV,P_GT30MEV'): begin 
      mtitle='ACE/SIS Protons'
   ;   units='Proton flux p/cs2-sec-ster'
      protons_only=1
      init='P_GT10MEV'
      plabels=['Protons > 10MeV','Protons > 30 MeV']
      elabels=''
      ptags=['P_GT10MEV','P_GT30MEV']
   endcase
   required_tags(acedata,'BZ'): begin 
      mtitle='ACE/MAGNETOMETER'
      protons_only=1
      init='Bz'
      ptags=init
      plabels='Bz'
      pchannels=0
      elables=''
   ;   units='nT'
   endcase
      
   else: begin
      box_message,'Sorry, EPAM, SWEPAM or SIS only..'
      return
   endcase

endcase

dbinfo=ssw_dbase_info(init,units=units,autolog=autolog) 
help,init,units,autolog
log=autolog and (1-linear)
ytype=log
init=init+(['','>.01'])(log)                     ; log protect

; ------------- initialize the plot ----------------
if data_chk(units,/string) then ytitle=units


initcmd='utplot, acedata, acedata.'+init + $
  ',ytype=ytype,title=mtitle,ytitle=ytitle,' +  $
   '/nodata,_extra=_extra,background=background'
estat=execute(initcmd)

npc=n_elements(pchannels)
nec=n_elements(echannels)
if electrons_only then npc=0
if protons_only   then nec=0

if debug then stop,'npc'

if get_tag_index(_extra,'SYMSIZE') eq -1 then symsize=.5

if get_tag_index(_extra,'PSYM') eq -1 then begin 
   ppsym=-1           
   epsym=-4
endif else begin 
   ppsym=gt_tagval(_extra,/psym)
   epsym=gt_tagval(_extra,/psym)
endelse

for i=0, npc-1 do begin  
  print,ptags(i)
  outplot,acedata,acedata.(tag_index(acedata,ptags(i))), color=pcolors(i), psym=ppsym, $
     _extra=_extra, symsize=symsize
endfor

for i=0,nec-1 do $
   outplot,acedata,acedata.(tag_index(acedata,etags(i))),color=ecolors(i), psym=epsym, $
      _extra=_extra, symsize=symsize


; ----------------- add a legend ---------------------------------------
if not keyword_set(nolegend) and (npc gt 1) or (nec gt 1) then begin            ; build legend info
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
      legend2,llabs(1:*), psym=lpsym(1:*), colors=lcols(1:*), $
         background=background*keyword_set(clear_legend), $
         clear=keyword_set(clear_legend), $
         charsize=.5, textcolors=!p.color-background ; add legend
   endif
endif


if debug then stop,'debug...'

set_plot,dtemp                                      ; restore users plot device

return
end
