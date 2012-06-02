PRO plotcount,filename,outpath=outpath,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
              mcm=mcm,messcount,quadrant,obsend=obsend,titles=titles,$
              smooth=smooth,msmooth=msmooth,comment=comment,ps=ps,ghost=ghost,$
              mimcm=mimcm,mamcm=mamcm,errorfile=errorfile,chatty=chatty
;+
; NAME:           plotcount
;
;
;
; PURPOSE: 
;                 Plotting of Count-Info-Data to a ps-file or to
;                 screen 
;
;
;
; CATEGORY: 
;                 Data-Analysis
;
;
;
; CALLING SEQUENCE:  
;                 plotcount,filename,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,mcm=mcm,$
;                           messcount,quadrant,comment=comment,$
;                           ghost=ghost,chatty=chatty
;
; 
; INPUTS: 
;                 filename  : name of the data-file, will be printed in
;                             the header
;                 athr      : vector containing the values of the above
;                             threshold counter
;                 fifr      : vector containing the values of the fifo 
;                             read counter
;                 epdh      : vector containing the values of the epdh 
;                             counter
;                 dslin     : vector containing the values of the discarded
;                             line counter
;                 mcm       : vector containing the values of the mean 
;                             common mode
;                 messcount : number of events in the data file
;                 quadrant  : Quadrant id
;
;
; OPTIONAL INPUTS:
;                 obsend    : Vector containing the position of the
;                             end of an observation and the beginning
;                             of the next one
;                 titles    : Titles of the different observations

;                 comment   : optional comment to be printed on the
;                             ps-plot
;      
; KEYWORD PARAMETERS:
;                 smooth    : Smooth all plots by an boxcar average;
;                             do not use together with msmooth
;                 msmooth   : Smooth only MCM plot; do not use
;                             together with smooth
;                 errorfile : if an error occurs in the data, a
;                             message will be written in an errorfile
;                 ps        : plot to ps-file not to screen
;                 ghost     : show ps output-file in ghostview; works
;                             only together with /ps
;                 chatty    : give additional information on whats
;                             going on
;
;
; OUTPUTS:
;                 a ps file is generated with the name
;                 filename+'+quadrantid+'.ps'
;
;
; OPTIONAL OUTPUTS:
;                 none
;
;
; COMMON BLOCKS:
;                 none
;
;
; SIDE EFFECTS:
;                 none
;
;
; RESTRICTIONS:
;                 none
; 
;
; PROCEDURE:
;                 see code
;     
;
; EXAMPLE:
;                 plotcount,files(i),athr0,fifr0,epdh0,dslin0,mcm0,mess0,0,/chatty           
;
;
; MODIFICATION HISTORY:
; V1.0 E. Bihler 
; V2.0 26.11.98 M. Kuster separated from flag.pro to work as stand-
;                         alone procedure
; V2.1 27.11.98 M. Kuster added error handling, e.g. no counters in
; athr
; V2.20  7.01.99 M. Kuster added possibility to plot more than one
;                          observation separated by a marker
; V2.21  8.01.99 M. Kuster print a title for each observation ; not yet tested
; V2.22  2.02.99 M. Kuster fixed bug with ghostview when /ps is not selected
; V2.23  3.02.99 M. Kuster added some more information in postscript output
; V2.3  11.02.99 M. Kuster added possibility to generate an error file
;                          for automatic data screening 
; V2.4  22.02.99 M. Kuster cleared bug that only q3 errors are written
;                          to file
;-
   OPENFILE=0
   
   IF (keyword_set(chatty)) THEN BEGIN 
       chatty=1
   END ELSE BEGIN 
       chatty =0 
   END 
   
   IF (keyword_set(ps)) THEN BEGIN 
       ps =1
   END ELSE BEGIN 
       ps =0 
   END 
   IF (keyword_set(smooth)) THEN BEGIN 
       smooth =1
   END ELSE BEGIN 
       smooth =0 
   END 
   IF (keyword_set(msmooth)) THEN BEGIN 
       msmooth =1
   END ELSE BEGIN 
       msmooth =0 
   END    
   
   numofplots=5
   IF (NOT keyword_set(athr)) THEN BEGIN
       athr=-1
   END
   IF (NOT keyword_set(fifr)) THEN BEGIN
       fifr=-1
   END
   IF (NOT keyword_set(epdh)) THEN BEGIN
       epdh=-1
   END
   IF (NOT keyword_set(dslin)) THEN BEGIN
       dslin=-1
   END
   IF (NOT keyword_set(mcm)) THEN BEGIN
       mcm=-1
   END

   IF (NOT keyword_set(obsend)) THEN BEGIN
       obsend=n_elements(messcount)+1 ;one after last countinfo
   END

   IF (keyword_set(errorfile)) THEN BEGIN
       errorf=1
   END ELSE BEGIN 
       errorf=0
   END
   
   IF (chatty EQ 1) THEN BEGIN
       IF (((athr[0] eq -1) AND (n_elements(athr) EQ 1)) OR $
          (n_elements(athr) LE 2)) THEN BEGIN 
           print,'% PLOTCOUNT: WARNING no athr count-info data available !!!!!!'
           numofplots=numofplots-1	
       END
       
       IF (((fifr[0] eq -1) AND (n_elements(fifr) EQ 1)) OR $
          (n_elements(fifr) LE 2)) THEN BEGIN 
           print,'% PLOTCOUNT: WARNING no fifr count-info data available !!!!!!'
           numofplots=numofplots-1
       END
   
       IF (((epdh[0] eq -1) AND (n_elements(epdh) EQ 1)) OR $
          (n_elements(epdh) LE 2)) THEN BEGIN 
           print,'% PLOTCOUNT: WARNING no epdh count-info data available !!!!!!'
           numofplots=numofplots-1
       END
       
       IF (((dslin[0] eq -1) AND (n_elements(dslin) EQ 1)) OR $
          (n_elements(dslin) LE 2)) THEN BEGIN 
           print,'% PLOTCOUNT: WARNING no dslin count-info data available !!!!!!'
           numofplots=numofplots-1
       END   
       
       IF (((mcm[0] eq -1) AND (n_elements(mcm) EQ 1)) OR $
          (n_elements(mcm) LE 2)) THEN BEGIN 
           print,'% PLOTCOUNT: WARNING no mcm count-info data available !!!!!!'
           numofplots=numofplots-1
       END
   END 
   

   IF (chatty EQ 1) THEN BEGIN 
       print,'% PLOTCOUNT: Working on Count-Info plot for Quadrant ',quadrant,' ...'
   END 
   
   IF (ps eq 1) THEN BEGIN   
       set_plot,'ps'
       IF (NOT keyword_set(outpath)) THEN outpath=''
       plotfile=outpath+filename+'_cQ'+STRTRIM(quadrant, 2)+'.ps'
       print,'% PLOTCOUNT: Printing to file: ',plotfile
       spawn,"date '+%d %b %Y  %H:%M:%S'",date ; get system date
       user=getenv('USER')      ; get username
       host=getenv('HOST')      ; get hostname       
       device,xsize=26.5,ysize=17,/landscape,/color,yoffset=27,xoffset=1, $
         file=plotfile,set_font='Times',/TT_FONT
       loadct,13
   END ELSE BEGIN
       set_plot,'x'
       loadct,12
   END
;   print,n_elements(athr)
;   print,n_elements(fifr)
;   print,n_elements(epdh)
;   print,n_elements(dslin)
;   print,n_elements(mcm)
   
   IF (((athr[0] EQ -1) OR  (n_elements(athr) LE 2)) AND $
       ((fifr[0] EQ -1) OR  (n_elements(fifr) LE 2)) AND $
       ((epdh[0] EQ -1) OR  (n_elements(epdh) LE 2)) AND $
       ((dslin[0] EQ -1) OR  (n_elements(dslin) LE 2)) AND $
       ((mcm[0] EQ -1) OR  (n_elements(mcm) LE 2)) ) THEN BEGIN 
       xyouts,16000,11000,'No Count Info Data in this file',/device,alignment=1,charsize=2.1,charthick=10.
   ENDIF ELSE BEGIN 
       !p.multi=[0,1,numofplots]
       
       mi=0
       ma=n_elements(messcount)-1
       ;; ---------------- plot athr ------------------
       IF (NOT ((athr[0] EQ -1) AND (n_elements(athr) EQ 1)) ) THEN BEGIN
           miathr=min(athr)
           maathr=max(athr) 
           athrs=athr     
           IF ((n_elements(athr) LT 51) OR (smooth EQ 0)) THEN BEGIN
               plot,athr,title=textoidl('Above Threshold Counter (athr - Red: athr-fifr)'),psym=10,xtitle=$
                 'Counter No.',ytitle='No. of Events',xrange=[mi,ma],yrange=[miathr,maathr],$
                 charsize=1.5,/ystyle,/xstyle
           END ELSE BEGIN
               athr=smooth(athr,9,/edge_truncate)
               plot,athr,$
                 title=textoidl('Above Threshold Counter (athr - Red: athr-fifr),Boxcar 10'),$
                 psym=10,xtitle=$
                 'Counter No.',ytitle='No. of Events',$
                 xrange=[mi,ma],yrange=[miathr,maathr],charsize=1.5,/ystyle,/xstyle           
           END
           ;; plot separators and titles for different observations
           IF (keyword_set(obsend)) THEN BEGIN 
               FOR i=0,n_elements(obsend)-2 DO BEGIN 
                   oplot,[obsend(i),obsend(i)],[miathr,maathr],color=25,thick=2
                   IF (keyword_set(titles)) THEN BEGIN 
                       xyouts,obsend(i)+120,maathr*0.1,titles(i),$
                         alignment=1,charsize=1.,charthick=1.
                   END
               END 
           END
           ;; calculate difference between athr and fifr
           IF (NOT( (fifr[0] EQ -1) AND (n_elements(fifr) EQ 1)) AND (smooth EQ 0)) THEN BEGIN		
               abw1=athr(mi:ma)-fifr(mi:ma)
               IF min(abw1)+max(abw1)+abw1(0) NE 0 THEN BEGIN 
                   abw11=(abw1-(min(abw1)+max(abw1))/2.)*$
                     (max(athr(mi:ma))-min(athr(mi:ma)))/(max(abw1)-min(abw1))+$
                     (min(athr(mi:ma))+max(athr(mi:ma)))/2. 
               END ELSE BEGIN 
                   abw11=replicate((min(athr(mi:ma))+max(athr(mi:ma)))/2.,ma-mi+1)
               END
               IF (errorf EQ 1) THEN BEGIN 
                   errind=where(abw1 NE 0)
                   IF (errind[0] NE -1) THEN BEGIN 
                       openw,unit,outpath+filename+'_Q'+STRTRIM(quadrant, 2)+'_cerr.log',/get_lun
                       OPENFILE=1
                       print,'% PLOTCOUNT: ERROR in athr-fifr'
                       printf,unit,'% PLOTCOUNT: ERROR athr-fifr is not equal to 0 in file '+filename
                   END
               END
               oplot,indgen(ma-mi+1)+mi,abw11,color=250,thick=2,psym=10   
               xyouts,-0.045*(ma-mi)+mi,abw11(0),strtrim(long(abw1(0)),2), color=250,$
                 charsize=1.1,/data,charthick=1.5
           END 
           athr=athrs           ; restore values of athr
       END 
       ;; ---------------- end plot athr ---------------
       
       ;; ---------------- plot fifr ------------------
       IF (NOT( (fifr[0] EQ -1) AND (n_elements(fifr) EQ 1)) ) THEN BEGIN
           mififr=min(fifr)
           mafifr=max(fifr)             
           IF ((n_elements(athr) LT 51) OR (smooth EQ 0)) THEN BEGIN
               plot,fifr,title=textoidl('FIFO read Counter (fifr - Red: fifr-epdh)'),xtitle='Counter No.',$
                 ytitle='No. of Events',xrange=[mi,ma],yrange=[mififr,mafifr],$
                 charsize=1.5,psym=10,/ystyle,/xstyle
           END ELSE BEGIN 
               plot,smooth(fifr,9,/edge_truncate),$
                 title=textoidl('FIFO read Counter (fifr - Red: fifr-epdh)'),xtitle='Counter No.',$
                 ytitle='No. of Events',xrange=[mi,ma],yrange=[mififr,mafifr],$
                 charsize=1.5,psym=10,/ystyle,/xstyle              
           END 
           ;; plot separators for different observations
           FOR i=0,n_elements(obsend)-1 DO oplot,[obsend(i),obsend(i)],[mififr,mafifr],color=25,thick=2
           
           ;; calculate difference between epdh and fifr
           IF ((NOT (epdh[0] EQ -1 AND n_elements(epdh))) AND (smooth EQ 0)) THEN BEGIN
               abw2=fifr(mi:ma)-epdh(mi:ma)
               
               IF (min(abw2)+max(abw2)+abw2(0) NE 0) THEN BEGIN 
                   abw22=(abw2-(min(abw2)+max(abw2))/2.)*$
                     (max(fifr(mi:ma))-min(fifr(mi:ma)))/(max(abw2)-min(abw2))+$
                     (min(fifr(mi:ma))+max(fifr(mi:ma)))/2. 
               END ELSE BEGIN 
                   abw22=replicate((min(fifr(mi:ma))+max(fifr(mi:ma)))/2.,ma-mi+1)
               END
               IF (errorf EQ 1) THEN BEGIN 
                   errind=where(abw2 NE 0)
                   IF (errind[0] NE -1) THEN BEGIN
                       IF (OPENFILE EQ 0) THEN BEGIN 
                           openw,unit,outpath+filename+'_cerr.log',/get_lun
                           OPENFILE=1
                       END 
                       print,'% PLOTCOUNT: ERROR in fifr-epdh'
                       printf,unit,'% PLOTCOUNT: ERROR fifr-epdh is not equal to 0 in file '+filename
                   END 
               END
               oplot,indgen(ma-mi+1)+mi,abw22,color=250,thick=2,psym=10
               xyouts,-0.045*(ma-mi)+mi,abw22(0),strtrim(abw2(0),2), color=250,$
                 charsize=1.1,/data,charthick=1.5
           END 
       END 
       ;; ---------------- end plot fifr ---------------
       
       ;; ---------------- plot epdh  ------------------
       IF (NOT( (epdh[0] EQ -1) AND (n_elements(epdh) EQ 1)) ) THEN BEGIN 
           miepdh=min(epdh)
           maepdh=max(epdh)
           IF ((n_elements(athr) LT 51) OR (smooth EQ 0)) THEN BEGIN           
               plot,epdh,title=textoidl('Sent Data Counter (epdh - Red: Abbreviation from Data)'),$
                 psym=10,/ystyle,xtitle='Counter No.',ytitle='No. of Events',xrange=[mi,ma],$
                 yrange=[miepdh,maepdh],$
                 charsize=1.5,/xstyle
           END ELSE BEGIN 
               plot,smooth(epdh,9,/edge_truncate),$
                 title=textoidl('Sent Data Counter (epdh - Red: Abbreviation from Data) Boxcar 10'),$
                 psym=10,/ystyle,xtitle='Counter No.',ytitle='No. of Events',xrange=[mi,ma],$
                 yrange=[miepdh,maepdh],charsize=1.5,/xstyle               
           END 
           ;; plot separators for different observations
           for i=0,n_elements(obsend)-1 do oplot,[obsend(i),obsend(i)],[miepdh,maepdh],color=25,thick=2           
           
           ;; calculate difference between measured data and epdh
           IF ((NOT (messcount[0] EQ -1 AND n_elements(messcount))) AND (smooth EQ 0)) THEN BEGIN
               abw3=epdh(mi:ma)-messcount(mi:ma)
           
               IF (min(abw3)+max(abw3)+abw3(0) NE 0) THEN BEGIN 
                   abw33=(abw3-(min(abw3)+max(abw3))/2.)*(max(epdh(mi:ma))-min(epdh(mi:ma)))/$
                     (max(abw3)-min(abw3))+(min(epdh(mi:ma))+max(epdh(mi:ma)))/2. 
               END ELSE BEGIN 
                   abw33=replicate((min(epdh(mi:ma))+max(epdh(mi:ma)))/2.,ma-mi+1)
               END
               IF (errorf EQ 1) THEN BEGIN 
                   errind=where(abw3 NE 0)              
                   IF (errind[0] NE -1) THEN BEGIN
                       IF (OPENFILE EQ 0) THEN BEGIN 
                           openw,unit,outpath+filename+'_cerr.log',/get_lun
                           OPENFILE=1
                       END
                       print,'% PLOTCOUNT: ERROR in epdh-data'
                       printf,unit,'% PLOTCOUNT: ERROR epdh-data is not equal to 0 in file '+filename
                   END
               END 
               oplot,indgen(ma-mi+1)+mi,abw33,color=250,thick=2,psym=10
               xyouts,-0.045*(ma-mi)+mi,abw33(0),strtrim(abw3(0),2), color=250,$
                 charsize=1.1,/data,charthick=1.5
           END
       END 
       ;; ---------------- end plot epdh  ---------------
       
       ;; ---------------- plot dslin  ------------------
       IF (NOT( (dslin[0] EQ -1) AND (n_elements(dslin) EQ 1))) THEN BEGIN 
           midslin=min(dslin)
           madslin=max(dslin)   
           IF (((n_elements(dslin) LT 51) OR (smooth EQ 0))) THEN BEGIN 
               plot,dslin,title=textoidl('Discarded Line Counter (dslin)'),xtitle='Counter No.',psym=$
                 10,ytitle='No. of Lines',xrange=[mi,ma],yrange=[midslin,madslin],$
                 charsize=1.5,/ystyle,/xstyle
           END ELSE BEGIN 
               plot,smooth(dslin,9,/edge_truncate),$
                 title=textoidl('Discarded Line Counter (dslin) Boxcar 10'),xtitle='Counter No.',psym=$
                 10,ytitle='No. of Lines',xrange=[mi,ma],yrange=[midslin,madslin],charsize=1.5,$
                 /ystyle,/xstyle
          END 
          
          ;; plot separators for different observations
          for i=0,n_elements(obsend)-1 do oplot,[obsend(i),obsend(i)],[midslin,madslin],color=25,thick=2           
       END 
       ;; ---------------- end plot dslin  --------------
       
       ;; ---------------- plot mcm --------------
       IF (NOT( (mcm[0] EQ -1) AND (n_elements(mcm) EQ 1))) THEN BEGIN 
           medium=mean(mcm/200.) ; calculate the mean of plotdata
           sdev=stddev(mcm/200.) ; calculate the standart deviation of plotdata
           IF (keyword_set(mimcm)) THEN BEGIN
               mimcm=mimcm
           END ELSE BEGIN                   
               mimcm=medium-3*sdev ; ranges from +3*sigma to -3*sigma
           END
           IF (keyword_set(mamcm)) THEN BEGIN
               mamcm=mamcm
           END ELSE BEGIN
               mamcm=medium+3*sdev              
           END
           
           IF ( (n_elements(mcm) GT 51) AND (msmooth EQ 1)) THEN BEGIN
               plot,smooth(mcm/200.,9,/edge_truncate),$
                 xtitle='Counter No.',psym=10,ytitle='ADC',xrange=[mi,ma],yrange=[mimcm,mamcm],$
                 charsize=1.5,$
                 title='Common Mode per Line (mcm/200), Boxcar 10',$
                 /ystyle,/xstyle
           END ELSE BEGIN 
               IF (n_elements(mcm) LT 51) OR (smooth EQ 0)  THEN BEGIN 
                   plot,mcm/200.,xtitle='Counter No.',psym=10,$
                     ytitle='ADC',xrange=[mi,ma],yrange=[mimcm,mamcm],title=textoidl('Common Mode per Line (mcm/200)')$
                     ,charsize=1.5,/xstyle,/ystyle
               END ELSE BEGIN 
                   plot,smooth(mcm/200.,9,/edge_truncate),$
                     xtitle='Counter No.',psym=10,ytitle='ADC',xrange=[mi,ma],yrange=[mimcm,mamcm],charsize=1.5,$
                     title=textoidl('Common Mode per Line (mcm/200), Boxcar 10'),$
                     /ystyle,/xstyle
               END
           END
           ;; plot separators for different observations
           FOR i=0,n_elements(obsend)-1 DO oplot,[obsend(i),obsend(i)],[mimcm,mamcm],color=25,thick=2           
       END 
       ;; ---------------- end plot mcm --------------
       
   ENDELSE 
   
   xyouts,26000,19000,'Count Info Data of File '+filename,/device,alignment=1,charsize=2.1,charthick=10.
;   xyouts,500,19000,'File: '+plotfile,/device,charsize=1.1,charthick=2.5
   
   IF (keyword_set(comment)) THEN BEGIN 
       xyouts,500,18500,'Comments : '+comment,/device,charsize=1.1
   END 
   
   IF ( ps EQ 1) THEN BEGIN
       xyouts,500,18000,'Quadrant : '+STRTRIM(quadrant, 2),/device,charsize=1.1
       xyouts,500,17500,'Number of Count Info Data : '+STRTRIM(n_elements(athr), 2),/device,charsize=1.1
       xyouts,18600,100  ,'IAAT by '+user+'@'+host+' '+date,/device,charsize=0.9
   END 
   
   IF (ps EQ 1) THEN BEGIN      ; close ps device if neccessary
      device,/close
       set_plot,'x'
   END

   IF (keyword_set(ghost) AND (ps EQ 1)) THEN BEGIN 
       spawn, 'ghostview -swap -a4 '+plotfile,/sh
   ENDIF 
   
   IF ((errorf EQ 1) AND (OPENFILE EQ 1)) THEN BEGIN
       free_lun,unit
   END
   !p.multi=0
END 




