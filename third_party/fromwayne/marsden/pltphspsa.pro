pro pltphapsa,plt,opt,det,idfs,idfe,rate,strtbin,stpbin,xoplot,yoplot
;********************************************************************
; Program plots pha psa arrays including surface plots
; Variables are:
; 	plt................plotting option
;       opt................accumulation option
;       det................detector display option
;      idfs................starting idf
;      idfe................ending idf
;      rate................countrate to plot
;     xoplt................x variable to oplot
;     yoplt................y variable to oplot
;   strtbin................start bin of fit
;    stpbin................stop bin of fit
;*******************************************************************
!p.multi = 0
case opt of
   1 : opt_str = ' NET ON'
   2 : opt_str = ' NET OFF'
   3 : opt_str = ' OFF+'
   4 : opt_str = ' OFF-'
   5 : opt_str = ' ON SRC'
endcase 
if (plt lt 2)then begin
   xtle = 'PSA CHANNEL'
   ytle = 'PHA CHANNEL'
   ztle = 'COUNTS/SEC'
endif
if (plt eq 2)then begin
   xtle = 'PHA CHANNEL'
   ytle = 'COUNTS/SEC'
endif
if (plt eq 3)then begin
   xtle = 'PSA CHANNEL'
   ytle = 'COUNTS/SEC'
endif
if (disp eq 0)then begin
   num_spec_str = '1 IDF'
endif else begin
   num_spec_str = ' ACCUM. '
endelse
if (plt gt 1)then ytle = 'COUNTS/SEC' else ytle = 'PHA CHANNEL'
det_str = ['DET1','DET2','DET3','DET4','SUM (ALL DETECTORS)',$
          'SHOW ALL']
tle = strcompress(det_str(det-1) + ',' + num_spec_str + ',' + opt_str)
if (disp eq 1)then stle = 'IDFS:'+string(idfs)+' TO '+string(idfe) $
 else stle = 'IDF '+ string(idfe)
!x.style = 1 & !y.style = 1 & !z.style = 1
if (det eq 6)then begin
   num_psa = n_elements(rate(0,*,0))
   num_pha = n_elements(rate(0,0,*))
   num_dets = n_elements(rate(*,0,0))
endif else begin
   num_pha = n_elements(rate(0,*))
   num_psa = n_elements(rate(*,0))
endelse
if (ks(strtbin))then begin
   if (plt eq 2)then num_pha = stpbin - strtbin + 1
   if (plt eq 3)then num_psa = stpbin - strbin + 1 
endif else begin
   strtbin = 0
   if (plt eq 2)then stpbin = num_pha - 1 
   if (plt eq 3)then stpbin = num_psa - 1
endelse
if (det eq 6)then begin
   !p.multi = [0,1,4,0]
   ptr = 0
   for i = 0,num_dets-1 do begin
     if(i eq 0 and ptr mod 4 eq 0)then begin
        tle = strcompress('ALL DETECTORS, ' + num_spec_str + ',' + opt_str)
        stle = stle
     endif else begin
        tle = ''
     endelse
     ptr = ptr + 1
     case plt of
     0 : shade_surf,rate(i,*,*),charsize=2,title=tle,$
         xtitle=xtle,ytitle=ytle,ztitle=ztle   
     1 : surface,rate(i,*,*),charsize=2,title=tle,$
         xtitle=xtle,ytitle=ytle,ztitle=ztle
     2 : plot,findgen(num_pha),rate(i,chn_slice-1,strbin:stpbin),$
         title=tle,xtitle=xtle,ytitle=ytle
     3 : plot,findgen(num_psa),rate(i,strtbin:stpbin,chn_slice-1),$
         title=tle,xtitle=xtle,ytitle=ytle
     endcase
     if (n_elements(where(rate ne 0.)) eq 1)then begin
        xyouts,180,205,'NO DATA',/device,$
         charsize = 2,alignment=.5,color = !p.background
        xyouts,185,180,'FOR THIS SELECTION',/device,$
         charsize = 2,alignment=.5,color = !p.background
        xyouts,185,155,'(TRY AGAIN)',/device,$
         charsize = 2,alignment=.5,color = !p.background
        print,string(7b)
     endif
   endfor
endif else begin
     case plt of
     0 : shade_surf,rate,charsize=2,title=tle,$
         xtitle=xtle,ytitle=ytle,ztitle=ztle   
     1 : surface,rate,charsize=2,title=tle,$
         xtitle=xtle,ytitle=ytle,ztitle=ztle
     2 : plot,findgen(num_pha),rate(chn_slice-1,strtbin:stpbin),$
         title=tle,xtitle=xtle,ytitle=ytle
     3 : plot,findgen(num_psa),rate(strtbin:stpbin,chn_slice-1),$
         title=tle,xtitle=xtle,ytitle=ytle
     endcase
     if (plt gt 1 and ks(yoplot))then $
     oplot,xoplt,yoplt,color = !p.background 
     if (n_elements(where(rate ne 0.)) eq 1)then begin
        xyouts,180,205,'NO DATA',/device,$
         charsize = 2,alignment=.5,color = !p.background
        xyouts,185,180,'FOR THIS SELECTION',/device,$
         charsize = 2,alignment=.5,color = !p.background
        xyouts,185,155,'(TRY AGAIN)',/device,$
         charsize = 2,alignment=.5,color = !p.background
        print,string(7b)
     endif
endelse
;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
