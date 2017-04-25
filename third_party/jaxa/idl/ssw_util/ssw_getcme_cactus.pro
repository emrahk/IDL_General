function ssw_getcme_cactus, time0, time1, quicklook=quicklook, $
   mission=mission, search=search , refresh=refresh, keep_overlap=keep_overlap
;
;+
;
;   Name: ssw_getcme_cactus
;
;   Purpose: provide ssw client interface to SIDC/CACTUS CME dbase 
;
;   Input Parameters:
;      time0, time1 - desired time range (see restriction..)
;
;   Output:
;      Function returns vector of cme structures, one per CME w/ssw times
;
;   Keyword Paramters:
;      quicklook (switch) - if set, most recent detections, not archive 
;      keep_overlap (switch) - if set, keep events which are located in 
;                              preceding or subsequent months
;
;   Calling Sequence:
;      ccmes=ssw_getcme_cactus(/quicklook) ; most recent "few" days
;      NOTE: for time/parameter searching, use ssw_getcme_list wrapper:
;      ccmes=ssw_getcme_list(time0,time1,search=['lspeed>1000,width>180'],/CACTUS)
;
;
;   History:
;      7-Feb-2006 - S.L.Freeland (see ssw_getcme_list.pro)
;      INPUT Dbase Courtesy SIDC CACTUS project  , David Berghmans et al.
;      http://www.sidc.be/cactus/about/index.html
;     10-Feb-2006 - S.L.Freeland - permit archival/catalog access  
;                  and /GENERATE option (restricted..)
;     26-feb-2006 - S.L.Freeland - documentation;
;      3-mar-2006 - S.L.Freeland - eliminate events in "adjacent" months
;                   (CACTUS scan ranges overlap a few days in preceding and
;                    subsequent months so this should eliminate false dupes. 
;                    Add /KEEP_OVERLAP (overrides the 3-mar default)
;      3-mar-2006 - protect against undefined MONTH when /QUICKLOOK set
;     16-mar-2006 - protect against ZERO quicklook events...
;     27-mar-2006 - SIDC server change; sidc.oma.be -> www.sidc.be
;      
;   Restrictions:
;      call this from ssw_getcme_list.pro which also provides
;         access to the cdaw.nasa.gsfc.list by Gopalswamy & Yashiro etal
;-
;   
common ssw_getcme_cactus_blk,cmestr_mission_cactus 
common ssw_getcme_cactus_blk1, strtemp

if n_params() gt 0 or keyword_set(search) then begin 
   return,ssw_getcme_list(time0,time1,search=search) ; early exist...
endif

if n_elements(strtemp) eq 0 then $  
   strtemp={anytim_dobs:0.d, mjd:0l, time:0l, cpa:0, width:0, $
     lspeed:0,minspeed:0, maxspeed:0, duration:0, cmeurl:''}

if n_elements(time0) eq 0 then time0=reltime(days=-30,out='ecs')
if n_elements(time1) eq 0 then time1=reltime(/now,out='ecs')
quicklook=keyword_set(quicklook) or ssw_deltat(time0,reltime(/now),/days) le 5

refreshql=n_elements(qlindex) eq 0 or keyword_set(refresh)
refresharc=n_elements(arcindex) eq 0 or keyword_set(refresh)
cacttop='http://www.sidc.be/cactus/out/'
case 1 of 
   quicklook: begin 
      qltop=cacttop+'latestCMEs.html'
      sock_list,qltop,qlindex
       movies=strtrim(strextract(qlindex,'diffmovie','.html',/inc),2)
       ssok=where(movies ne '' and strpos(qlindex,'marginal') eq -1,ccnt)
       if ccnt gt 0 then begin 
       movies=movies(ssok) ; (urls to "non-marginal" CME detections)
       table=str2cols(qlindex(ssok),'|',/trim) ; 2D paramter table parse 
       strtab2vect,table,xx,time,dt0,pa,da,v,dv,minv,maxv,halo ; 2D->n1D
       endif  else begin 
          box_message,'NO CACTUS QUICKLOOK EVENTS...'
          return,-1
       endelse
   endcase

   else: begin 
     arctop='http://www.sidc.be/cactus/scan/output/'
     mission=1 ; 26-feb-2006 made forced this (and point users->ssw_getcme_list(/CACTUS)
     if keyword_set(mission) then begin ; times from SIDC availability
        time0=anytim('1-jan-1996',/ecs)
        mgrid=timegrid('1-dec-2004',reltime(/now),out='ecs',/month)
        mindex=arctop+strmid(mgrid,0,8) + 'latestCMEs.html'
        ii=0
        sock_list,mindex(ii),index
        ss=where(strpos(index,'cme00') ne -1,sscnt)
        while sscnt gt 0 and ii lt n_elements(mindex)-1 do begin 
           ii=ii+1
           sock_list,mindex(ii),index
           ss=where(strpos(index,'cme00') ne -1,sscnt)
        endwhile
        time1=mgrid(ii)
     endif
     if (anytim(time0,/ex))(5) eq (anytim(time1,/ex))(5) and $
        ssw_deltat(time1,ref=time0,/days) lt 30 then $
        mtimes=time0  else mtimes=timegrid(time0,time1,/month)
     mgrid=strmid(anytim(mtimes,/ecs),0,8)
     arcurls=arctop+mgrid+'latestCMEs.html'
     for i=0,n_elements(mgrid)-1 do begin 
        box_message,'Checking> ' + arcurls(i)
        sock_list,arcurls(i),qlindex
        moviesx	=strtrim(strextract(qlindex,'cme','png',/inc),2) 
        ssok=where(moviesx ne '' and strpos(qlindex,'marginal') eq -1 $
                   and strpos(qlindex,'detectionmap') eq -1,ccnt)
        if ccnt gt 0 then begin
           vindex=qlindex(ssok) + ' | ' + mgrid(i) ; append month
           if n_elements(allindex) eq 0 then allindex=vindex else $
               allindex=[allindex,vindex] 
           if n_elements(movies) eq 0 then movies=temporary(moviesx(ssok)) else $
                movies=[temporary(movies),moviesx(ssok)]
        endif
     endfor
     allindex=strarrcompress(allindex)
     table=str2cols(allindex,'|',/trim) ; 2D paramter table parse 
     strtab2vect,table,xx,time,dt0,pa,da,v,dv,minv,maxv,halo,month ; 2D->n1D
   endcase
endcase
ncme=n_elements(time)
if ncme eq 0 then begin 
   box_message,'No CMES parsed??'
endif else begin 
retval=replicate(strtemp,ncme)	; 1 per valid event
retval.anytim_dobs=anytim(time)                 ; Onset time 'anytim' 
utcint=anytim(retval.anytim_dobs,/utc_int)      ;      
retval.mjd=utcint.mjd                           ; same in UTC (utplot ready)
retval.time=utcint.time
retval.duration=str2number(dt0)  		; duration in HOURs
retval.cpa=str2number(pa)                       ; principle angle CCW from N.
retval.width=str2number(da)                     ; angular width DEGREES
retval.lspeed=str2number(v)                     ; median velocit (km/s)
retval.minspeed=str2number(minv)                ; minimum velocity over width
retval.maxspeed=str2number(maxv)                ; maximum velocity over width
case 1 of
   quicklook: retval.cmeurl=cacttop+movies      ; /oma/cactus cme url summary 
   else: retval.cmeurl=arctop+strmid(time,0,8)+movies
endcase
;
; By default, remove events which are in different month scans
; (SIDC/CACTUS lists expand time windows to adjacent months)
; This should eliminate false duplicates
if not quicklook then begin 
ssvalid=where(month eq strmid(time,0,8))   ; where scan month=event month 
if not keyword_set(keep_overlap) then begin 
   box_message,'Eliminating month overlaps...
   retval=temporary(retval(ssvalid))
endif
endif
; time sort
retval=temporary(retval(sort(retval.anytim_dobs)))
if keyword_set(refresh) or n_elements(cmestr_mission_cactus) eq 0 then $
   cmestr_mission_cactus=retval
endelse


return,retval
end


