pro plthst,num_spec,disp,det,rate,idfs,idfe,int,opt_str,trate,strtbn,$
           stpbn,xoplt,yoplt,det_str,prs=prs
;********************************************************************
; Routine draws the counts histogram
; Variables are:
;   num_spec..............number of spectra
;        int..............integration to plot
;       disp..............display option (0=1 IDF,1 = ACCUM)
;        det..............detector choice
;       rate..............count rate array to plot
;  idfs,idfe..............start and stop idf #s
;    opt_str..............option string
;      xoplt..............x variable to oplot
;      yoplt..............y variable to oplot
;     strtbn..............start bin of fit
;      stpbn..............stop bin of fit
;      trate..............total count rate for detector
;    det_str..............detector label string
;        prs..............phase resolved spectroscopy flag
;********************************************************************
!p.multi = 0
if (opt_str eq ' NET ON' or opt_str eq ' NET OFF')then $
fstr = ' CTS CM!E-2!N S!E-1!N' else fstr = ' CTS S!E-1!N'
if (not(ks(det_str)))then det_str = ''
if (det eq 6)then num_chns = n_elements(rate(0,*))$
else num_chns = n_elements(rate)
if (ks(strtbn))then begin
   num_chns = stpbn - strtbn + 1 
endif else begin
   strtbn = 0 & stpbn = num_chns - 1   
endelse
low= findgen(num_chns) + strtbn & high = low + 1
xtle = 'PHA CHANNELS'
if (keyword_set(strtbn) eq 0)then strtbn = 0
if (disp eq 0)then begin
   if (num_spec eq 0) then num_spec_str = '' $
   else begin
     if (ks(prs) eq 0)then num_spec_str = ' INT. '+ string(int) $
     else num_spec_str = ' PHZ. '+string(int)
   endelse
endif else begin
   if (ks(prs) eq 0)then num_spec_str = ' ACCUM. ' $
   else num_spec_str = ' PHZ. '+ string(int) + ', ACCUM.'
endelse
ytle = fstr
if (det_str(0) eq '')then begin
   det_str = ['DET 1','DET 2','DET 3','DET 4','SUM (ALL DETECTORS)',$
          'SHOW ALL'] 
endif
tle = strcompress(det_str(det-1) + ',' + num_spec_str + opt_str)
;if (disp eq 1)then stle = 'IDFS:'+string(idfs)+' TO '+string(idfe) $
; else stle = 'IDF '+ string(idfe)
stle = ''
!x.style = 1 & !y.style = 1
rate_save = rate
if (det eq 6)then begin 
   !p.multi = [0,1,4,0]
   ptr = 0
   for i = 0,3 do begin
     rt = rate(i,strtbn:stpbn)
     if(i eq 0 and ptr mod 4 eq 0)then begin
        tle = strcompress('ALL DETECTORS, ' + num_spec_str + ',' + opt_str)
     endif else begin
        tle = ''
     endelse
     if (trate(0,0) ne 'n')then begin
        trate_sign = -1.*(trate(0,i) lt 0.) + 1.*(trate(0,i) ge 0.)
        temp = trate_sign*.0001*long(abs(trate)*10000. + .5)
        temp0 = temp(0,i) & temp1 = temp(1,i)
        temp0 = strmid(temp0,0,strpos(temp0,'.')+5)
        temp1 = strmid(temp1,0,strpos(temp1,'.')+5)
        stle1 = stle + 'TRATE = ' + temp0 + ' +/- ' + $
                temp1 + fstr
     endif else begin
        stle1 = stle
     endelse
     stle1 = strcompress(stle1)
     ptr = ptr + 1
     xrnge = [min(low),max(high)]
     if (min(rt) lt 0.)then begin
        mxrt = max([abs(min(rt)),abs(max(rt))])
        yrnge = [-1.1*mxrt,1.1*mxrt]
     endif else begin
        yrnge = [0.,1.1*max(rt)]
     endelse
     hstplot,low,high,rt,xtle,ytle,tl=tle,st=stle,xr=xrnge,yr=yrnge
     if (keyword_set(yoplt) ne 0)then $
     oplot,xoplt+.5,yoplt,color=!p.background 
   endfor
endif else begin
   if (trate(0) ne 'n')then begin 
     trate_sign = -1.*(trate(0) lt 0.) + 1.*(trate(0) ge 0.)
     temp = trate_sign*.0001*long(abs(trate)*10000. + .5)
     temp0 = temp(0) & temp1 = temp(1)
     temp0 = strmid(temp0,0,strpos(temp0,'.')+5)
     temp1 = strmid(temp1,0,strpos(temp1,'.')+5 )
     stle1 = stle + 'TRATE = ' + temp0 + ' +/- ' + $
              temp1 + fstr
   endif else begin
      stle1 = stle
   endelse
   stle1 = strcompress(stle1)
   mxrt = max(rate)
   xrnge = [min(low),max(high)]
   if (min(rate) lt 0.)then begin     
      mxrt = max([abs(min(rate)),abs(max(rate))])
      yrnge = [-1.1*mxrt,1.1*mxrt]
   endif else begin
      yrnge = [0.,1.1*max(rate)]
   endelse
   hstplot,low,high,rate,xtle,ytle,tl=tle,st=stle1,xr=xrnge,yr=yrnge
   if (keyword_set(yoplt) ne 0)then $
   oplot,xoplt+.5,yoplt,color=!p.background
   if (n_elements(where(rate ne 0.)) eq 1)then begin
      xyouts,200,205,'NO DATA',/device,$
      charsize = 2,alignment=.5,color = !p.background
      xyouts,205,180,'FOR THIS SELECTION',/device,$
      charsize = 2,alignment=.5,color = !p.background
      xyouts,205,155,'(TRY AGAIN)',/device,$
      charsize = 2,alignment=.5,color = !p.background
      print,string(7b)
   endif
endelse
rate = rate_save
;****************************************************************
; Thats all ffolks
;****************************************************************
return
end
