function ssw_fov_context, index, data , goes=goes, $
			      _extra=_extra, full_type=full_type, $
			      all_fov=all_fov, zbuffer=zbuffer, $
			      xsize=xsize, ysize=ysize, debug=debug, $
                              l1q=l1q, $
                              sxt_sscfiles=sxt_sscfiles, $
			      minframes=minframes, composite=composite, $
                              fdmap=fdmap, fd_type=fd_type,rr,gg,bb, $
			      fov=fov, pad_fov=pad_fov, center=center, $
			      rotate=rotate, oplotnar=oplotnar, offset=offset, $
			      xmargin=xmargin, ymargin=ymargin, $
			      extremes=extremes, midpoint=midpoint, ss=ss, $
                              tw_percent=tw_percent, eit_l1files=eit_l1files, $
                              nar_color=nar_color, nar_size=nar_size
;+
;   Name: ssw_fov_context
;
;   Purpose: generate a 'context' image for a reduced FOV or movie sequence
;
;   Input Parameters:
;      structure - index (of index,data pairings)
;      data  - the data cube (if index,data input)
;
;   Output:
;      Function returns the context image (overlay, GOES LC...)
;
;   Keyword Parameters:
;      fdmap - optional context map for overlays - if not passed, generated
;      fd_type - type of context map - default = 'eit171'
;                {'eit304','eit195','eit284','eit171'}  - EIT options
;                { 171,195}                             - TRACE options  
;                { sxt }                                - SXT optioins
;
;      fov - arcminutes FOV of full disk to include in composite
;            default is derived from [dXCEN, dYCEN]+pad
;
;      center - FOV center of full disk
;               defaults: FOV(index; ie, subfield) if only one FOV
;                         Sun Center if
;      oplotnar - if set, overplot NOAA AR
;      offset   - per OFFSET parameter in oplot_nar.pro 
;                 [offset the AR# from the location to see the action]
;      midpoint - if set, only overplot middle FOV (say)
;      extremes - if set, only overplot 1st and last
;      ss       - user supplied subset of fovs to overplot
;  
;   Calling Sequence:
;       IDL> context_image=ssw_fov_context(index, data [keywords] )
;
;   Calling Example:
;      IDL> context=ssw_fov_context(tindex,tdata,fdtype='eit284',/l1q, $
;                      xsize=1024,grid=15,fov=20)
;  
;   History:
;       1-Jan-1999 - (Circa) - S.L.Freeland
;      14-Apr-1999 - S.L.Freeland add /OPLOTNAR and OFFSET keywords
;      25-May-1999 - S.L.Freeland add /MIDPOINT and SS keyword and function
;       5-Oct-2001 - S.L.Freeland add SSCFILES 
;      13-Feb-2002 - S.L.Freeland - for recent data, hook for $SSWDB EIT_L1Q
;      17-mar-2003 - S.L.Freeland - rotate NAR if oplot_nar set (via drot_nar)
;       7-Oct-2003 - S.L.Freeland - add NAR_COLOR and NAR_SIZE keyword ( -> oplot_nar)
;      16-apr-2007 - S.L.Freeland - enabled /EXTREMES keyword&function
;
;   Method:
;      Use mapping SW for FOV overlay on FD image, optionally GOES/event
;
;   Calls:
;    SSW usual suspects (eit,sxt,trace)
;    index2fov, plot_map, drot_map, oplot_nar
;
;   Restrictions:
;      assumes desired context FD dbase online (eit, trace mosaics or SXT SFM)
;      (gsfc/lmsal/medoc/???)
;
;-
 
if n_params() lt 2 or (1-data_chk(index,/struct)) then begin 
        box_message,['Need "index,data" pair(s)', $
		     'IDL> img=ssw_fov_context(index,data [options] )']
        return,-1
endif	

dtemp=!d.name
debug=keyword_set(debug)
zbuffer=keyword_set(zbuffer) or get_logenv('ssw_batch') ne ''
oplotnar=keyword_set(oplotnar)
if n_elements(tw_percent) eq 0 then tw_percent=20.
if not keyword_set(xsize) then xsize=750
if not keyword_set(ysize) then ysize=xsize
l1q=keyword_set(l1q)
if data_chk(sscfiles,/string) then sxt_sscfiles=sscfiles
if data_chk(sxt_sscfiles,/string) then fd_type='sxt'
if not keyword_set(fd_type) then fd_type='eit171'      ; default
fdt=strlowcase(fd_type)
wave=str2number(fd_type)
if wave eq 0 then wave=171                             ; default is EIT 171
eit=strpos(fdt,'eit') ne -1 or data_chk(eit_l1files,/string)
sxt=strpos(fdt,'sxt') ne -1
goes=keyword_set(goes)
tvlct,rr,gg,bb,/get

; -------------- get a context image --------------------------
case 1 of
  data_chk(fdmap,/struct):                ; user directly passed context map
  eit: begin
        ref=index(n_elements(index)/2)
     if l1q or data_chk(eit_l1files,/string) then begin 
        if l1q then begin 
           fdf=sswdb_files(ref,/eit,/l1q,pat='_'+strtrim(wave,2)+'_')
        endif else begin 
           ssclose=tim2dset(file2time(eit_l1files,out='int'), ref)
           fdf=eit_l1files(ssclose(0)) 
        endelse
         if fdf(0) eq '' then begin 
            box_message,'No matching EIT L1 files'
            return,-1
         endif else begin 
            read_eit,fdf,fdindex,edata
            wave=gt_tagval(fdindex,/wavelnth) 
            ;fddata=bytscl(do_eit_scaling(edata>40<2000,index=fdindex,/no_prep,/log) )
            fddata=ssw_sigscale(fdindex,edata,/log,/corner)

         endelse 
     endif else begin 
        time_window,index,time0,time1,day=2,/yohkoh
        estat=execute('fdf=eit_files(time0,time1,/full,wave=wave)')
        if fdf(0) eq '' then begin
           box_message,'No EIT context image close in time...'
	   return,-1
         endif 	
         fdf=last_nelem(fdf)
         read_eit,fdf,eindex,edata
         eit_prep, eindex, data=edata, fdindex, fddata
         fddata=sobel_scale(fdindex,fddata,hi=2000,sobel_weight=.05,minper=5)
      endelse
      box_message,'Using EIT , Wave: ' + strtrim(wave,2) + ' context image'
  endcase
  sxt: begin
    box_message,'Using SXT context image'
    midtime=timegrid(index(0), $
	    hour=ssw_deltat(index(0),last_nelem(index),/hour)/2.)
    delvarx,findex,fdata
    estat=execute('get_ssc_best, midtime, filt=3, /half, sscfiles=sxt_sscfiles, fdindex, fddata')
    if data_chk(fdindex,/struct) then begin 
       box_message,'using SSC/SSS data base'
       if max(fddata) gt 256 then fddata=safe_log10(fddata,/byte)
    endif else begin 
       estat=execute('sfile=sxt_files(midtime,/sfd)')
       if sfile(0) ne '' then begin
          rd_xda,sfile,-1,index
          ss=tim2dset(index,midtime)
          rd_xda,sfile,ss(0),fdindex,fddata
       endif else get_sfm, midtime, fdindex, fddata
     endelse;
  endcase    
  else: begin
     estat=execute('fdf=trace_files(index(0),/synop,wave=wave)')
     read_trace,fdf,-1,fdindex,fddata
  endcase
endcase

fdindex=last_nelem(fdindex)                       ; assure only one
if data_chk(fddata,/nimage) gt 1 then fddata=last_nelem(fddata)

; make a full disk map object if not passed in
if not data_chk(fdmap,/struct) then index2map, fdindex, fddata, fdmap
wdef, zz, xsize,ysize, /zbuff
set_plot,'z'

if n_elements(charsize) eq 0 then $
    charsize=(([1.2,1.])(zbuffer)*(float(xsize)/1024)) + .2

; determine which fov(s) to overplot
nufov=n_elements(index)
if n_elements(ss) eq 0 then ss=lindgen(nufov)                           ; default =ALL
case 1 of
   keyword_set(midpoint): ss=nufov/2             ; ~middle of seqence
   keyword_set(extremes): ss=[0,last_nelem(ss)]
   keyword_set(ss): fovss=ss                     ; user supplied
   else:                                         ; take default
endcase   

; --- get the FOV extremes / parameters based on all index ( "macro" FOV)

index2fov,index,east,west,north,south,/extreme, $   ; index -> FOV and size
     center_fov=center_fov, size_fov=size_fov

; --------- FOV size in arcminutes -------------
if n_elements(fov) eq 0 then begin                            ; use "macro" 
   if n_elements(pad_fov) eq 0 then pad_fov=max(2.*size_fov)  ; FOV
   fov=(size_fov+pad_fov)/60.         
endif 

; ------- where to center context ----------------------
if n_elements(center) eq 0 then center=center_fov             ; use "macro"
                                                              ; center
plot_map, fdmap, xsize=xsize, ysize=ysize, _extra=_extra,/no16,$
         charsize=charsize, center=center, fov=fov, xmargin=xmargin, ymargin=ymargin
;if oplotnar then oplot_nar,anytim(fdmap.time,/ecs),offset=offset

rotate=keyword_set(rotate)

; ------- -now overplot/composite subfields ----------------------
if n_elements(composite) eq 0 then composite=2        ; type of FD/FOV composite
comptemp=composite
nss=n_elements(ss)
for i=0,nss-1 do begin
   print,'Processing index >> ' + $
	  get_infox(index(ss(i)),'wave_len,naxis1,naxis2,xcen,ycen',fmt_tim='ecs')
   index2map, index(ss(i)), data(*,*,ss(i)), fovmap
   nmap=grid_map(fovmap,256,256)
   if rotate then begin
      message,/info,"rotating sub field with respect to context image"
      rotdur=ssw_deltat(nmap.time,fdmap.time,/hour)
      print,'fdt,fovt,dT(hours)',fdmap.time,nmap.time,rotdur
      nmap=drot_map(nmap,rotdur,/fast)
   endif     
   composite=comptemp
   plot_map, fovmap, composite=composite,border=border, /no16, _extra=_extra
   if oplotnar and (i eq nss-1) then begin
      nar=get_nar(anytim(nmap.time,/ecs),/uniq)
      rnar=nar
      dmax=4
      dnn=1
      while (1-data_chk(nar,/struct)) and dnn lt dmax do begin 
         time_window,anytim(nmap.time,/ecs),t0,t1,out='ecs',days=dnn
         nar=get_nar(t0,t1)
         dnn=dnn+1
      endwhile
      if data_chk(nar,/struct) then begin 
         rnar=drot_nar(nar,anytim(nmap.time,/ecs))  ; rotate NAR->fd time
         oplot_nar,rnar, offset=offset, color=nar_color, size=nar_size
      endif else box_message,'No NAR dbase in within ' + strtrim(dmax,2)
   endif
endfor  
out=tvrd()

; -------- optionally include goes lightcurve context --------
if keyword_set(goes) then begin
   wdef,xx,data_chk(out,/nx),data_chk(out,/nx)/4.,/zbuffer
   set_plot,'z'
   erase
   time_window, index, t0 , t1, percent=tw_percent             ; expand time range
   fmt_timer,index
   ascii=(ssw_deltat(t0,ref='15-dec-2002',/day) gt 0)
   plot_goes,t0, t1, $
	      gcolor=20, color=130, gdata=gdata, charsize=charsize, $
	      ymargin=ymargin, xmargin=[5,.5], ncolor=40 , ascii=ascii,/goes11
   if data_chk(gdata,/struct) then begin 
      if data_chk(all_fov,/struct) then begin 
         evt_grid,all_fov,ticklen=.05, color=100, tickpos=.85,thick=1,linestyle=0
         midtime=anytim((anytim(all_fov(0)) + $
            anytim(last_nelem(all_fov)))/2,/ecs)
       evt_grid, midtime, $
            label="(Similar frames)", align=.5,/noarrow, labpos=.8, labsize=.6,ticklen=.0001,tickpos=.9
 
      endif
      evt_grid,index,ticklen=.1,tickpos=.7,color=150,thick=2,linestyle=0
      gout=!p.color-tvrd()
      out=[[gout],[out]]
   endif else message,/info,'NO GOES data between ' + t0 + ' and ' + t1
endif

set_plot,dtemp
return,out
end
