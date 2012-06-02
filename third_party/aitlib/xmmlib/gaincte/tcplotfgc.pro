PRO tcplotfgc,file,cte=cte,gain=gain,bin=bin,errf=errf,peakf=peakf,$
              dfile=dfile,derrf=derrf,comment=comment,ps=ps,stop=stop
	   
;+
; NAME:            
;                  tcplotfgc
;
;
; PURPOSE:
;		   Read and plot CTE or gain data from file
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  tcplotfgc
;
; 
; INPUTS:
;                  file: Name of file with CTE, gain or peak position data
;
;
; OPTIONAL INPUTS:
;                  errf : file with error values
;                  peakf : file with cte data and peak positions, for
;                          valid file cte curve for every column is plotted
;                  dfile : second gain or cte file, if valid file is
;                          given, the difference values are plotted 
;                  derrf : error values of the second file
;                  comment : comment for plot
;   
;
; KEYWORD PARAMETERS:
;                  cte : plot cte
;                  gain : plot gain
;                  bin : file is in binary format
;                  ps : plot to file tc_xxx.ps with xxx = cte, gain or cte_peaks
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;		   none   
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  none
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 05.01.00 T. Clauss, initial version
; V1.1 19.04.00 T. Clauss, added errf and peakf  
; V1.2 02.05.00 T. Clauss, added dfile   
;-
   
   
   IF (keyword_set(ps)) THEN printing=1 ELSE printing=0
   
   comment1=' '
   
   IF (keyword_set(cte) OR keyword_set(gain)) THEN BEGIN 
       
       IF (NOT keyword_set(bin)) THEN BEGIN
           openr,unit,file,ERROR=err,/get_lun
           IF (err NE 0) THEN BEGIN 
               print,'% TCPLOTFGC: ERROR opening File: '+file
               print,'% TCPLOTFGC: '+ !ERR_STRING
               return
           ENDIF ELSE BEGIN 
               dat = FLTARR(64)
               readf,unit,dat
               comment1=strarr(5)
               readf,unit,comment1
               free_lun,unit
           ENDELSE
       ENDIF ELSE BEGIN
           openr,unit,file,/XDR,ERROR=err,/get_lun
           IF (err NE 0) THEN BEGIN 
               print,'% TCPLOTFGC: ERROR opening File: '+file
               print,'% TCPLOTFGC: '+ !ERR_STRING
               return
           ENDIF ELSE BEGIN 
               dat = FLTARR(64)
               readu,unit,dat
               free_lun,unit
           ENDELSE
       ENDELSE 
       
       IF keyword_set(dfile) THEN BEGIN
           IF (NOT keyword_set(bin)) THEN BEGIN
               openr,unit,dfile,ERROR=err,/get_lun
               IF (err NE 0) THEN BEGIN 
                   print,'% TCPLOTFGC: ERROR opening File: '+dfile
                   print,'% TCPLOTFGC: '+ !ERR_STRING
                   return
               ENDIF ELSE BEGIN 
                   ddat = FLTARR(64)
                   readf,unit,ddat
                   free_lun,unit
               ENDELSE
           ENDIF ELSE BEGIN
               openr,unit,dfile,/XDR,ERROR=err,/get_lun
               IF (err NE 0) THEN BEGIN 
                   print,'% TCPLOTFGC: ERROR opening File: '+dfile
                   print,'% TCPLOTFGC: '+ !ERR_STRING
                   return
               ENDIF ELSE BEGIN 
                   ddat = FLTARR(64)
                   readu,unit,ddat
                   free_lun,unit
               ENDELSE
           ENDELSE  
       ENDIF
       
   ENDIF 
      
   IF keyword_set(peakf) THEN BEGIN
       openr,unit,file,ERROR=err,/get_lun
       IF (err NE 0) THEN BEGIN 
           print,'% TCPLOTFGC: ERROR opening File: '+file
           print,'% TCPLOTFGC: '+ !ERR_STRING
       ENDIF ELSE BEGIN 
           readf,unit,numline
           xpeaks=intarr(numline)
           readf,unit,xpeaks
           col=intarr(1)
           tpeaks=fltarr(3)
           peaks=fltarr(64,numline)
           sigmap=fltarr(64,numline)
           chisqp=fltarr(64,numline)
           tctes=fltarr(3)
           ctes=fltarr(64)
           sigmac=fltarr(64)
           pos0=fltarr(64)
           FOR i=0,63 DO BEGIN 
               readf,unit,col
               FOR j=0,numline-1 DO BEGIN
                   readf,unit,tpeaks
                   peaks(i,j)=tpeaks(0)
                   sigmap(i,j)=tpeaks(1)
                   chisqp(i,j)=tpeaks(2)
               ENDFOR
               readf,unit,tctes
               ctes(i)=tctes(0)
               sigmac(i)=tctes(1)
               pos0(i)=tctes(2)
           ENDFOR
           free_lun,unit
       ENDELSE
   ENDIF  
                
       daterr=-1
       ddaterr=-1
       
       IF keyword_set(errf) THEN BEGIN
           openr,unit,errf,ERROR=err,/get_lun
           IF (err NE 0) THEN BEGIN 
               print,'% TCPLOTFGC: ERROR opening File: '+file
               print,'% TCPLOTFGC: '+ !ERR_STRING
           ENDIF ELSE BEGIN 
               daterr = FLTARR(64)
               readf,unit,daterr
               free_lun,unit
           ENDELSE
           
           IF keyword_set(derrf) THEN BEGIN 
               openr,unit,derrf,ERROR=err,/get_lun
               IF (err NE 0) THEN BEGIN 
                   print,'% TCPLOTFGC: ERROR opening File: '+derrf
                   print,'% TCPLOTFGC: '+ !ERR_STRING
               ENDIF ELSE BEGIN 
                   ddaterr = FLTARR(64)
                   readf,unit,ddaterr
                   free_lun,unit
               ENDELSE           
           ENDIF
           
       ENDIF
       
   
   IF (NOT keyword_set(comment)) THEN comment=comment1 
   
   xcols=INDGEN(64)
   
   IF (keyword_set(cte)) THEN BEGIN
       
       title=strtrim(file,2)
       yrange=[0.9993,0.9997]
       
       IF keyword_set(dfile) THEN BEGIN
           dat=dat-ddat
           IF keyword_set(derrf) THEN daterr=sqrt(daterr^2+ddaterr^2)
           title=title+' - '+strtrim(dfile,2)
           yrange=[-0.0002,0.0002]
       ENDIF
                  
       plot,xcols,dat,xtitle='Column #',ytitle='CTE',$
         title=title,xrange=[-1,64],yrange=yrange,psym=10,/xstyle
       
       IF (daterr(0) NE -1) THEN oploterr,xcols,dat,daterr,3
       
       xyouts,0.10,0.0,'Comment: '+comment,alignment=0.,charsize=0.7,/normal  
              
       IF (printing EQ 1) THEN BEGIN
           set_plot,'ps'
           device,file='tc_cte.ps',/landscape, xsize=25.0,ysize=15.0,$
             set_font='Times',font_size=18  
           
           plot,xcols,dat,xtitle='Column #',ytitle='CTE',$
             title=title,xrange=[-1,64],yrange=yrange,psym=10,/xstyle
           IF (daterr(0) NE -1) THEN oploterr,xcols,dat,daterr,3
           xyouts,0.10,0.0,'Comment: '+comment,alignment=0.,charsize=0.7,/normal  
           
           device,/close
           set_plot,'x'  
       ENDIF
   ENDIF ELSE BEGIN
       IF (keyword_set(gain)) THEN BEGIN
           
           title=strtrim(file,2)
           yrange=[0.975,1.025]
           
           dat=1/dat
           IF (daterr(0) NE -1) THEN daterr=dat^2*daterr
           
           IF keyword_set(dfile) THEN BEGIN
               ddat=1/ddat
               IF (ddaterr(0) NE -1) THEN ddaterr=ddat^2*ddaterr
               dat=dat-ddat
               IF keyword_set(derrf) THEN daterr=sqrt(daterr^2+ddaterr^2)
               title=title+' - '+strtrim(dfile,2)
               yrange=[-0.01,0.01]
           ENDIF 
         
           plot,xcols,dat,xtitle='Column #',ytitle='1/Gain',$
             title=title,xrange=[-1,64],yrange=yrange,psym=10,/xstyle,/ystyle          
           xyouts,0.10,0.0,'Comment: '+comment,alignment=0.,charsize=0.7,/normal  
           
           IF (daterr(0) NE -1) THEN oploterr,xcols,dat,daterr,3
           
           IF (printing EQ 1) THEN BEGIN
               set_plot,'ps'
               device,file='tc_gain.ps',/landscape, xsize=25.0,ysize=15.0,$
                 set_font='Times',font_size=18  
               
               plot,xcols,dat,xtitle='Column #',ytitle='1/Gain',$
                 title=title,xrange=[-1,64],yrange=yrange,psym=10,/xstyle,/ystyle          
               xyouts,0.10,0.0,'Comment: '+comment,alignment=0.,charsize=0.7,/normal  
               
               IF (daterr(0) NE -1) THEN oploterr,xcols,dat,daterr,3
             
               device,/close
               set_plot,'x'  
           ENDIF
       ENDIF ELSE BEGIN
           IF keyword_set(peakf) THEN BEGIN
               nr=0
               noticks=[' ',' ',' ',' ',' ',' ',' ',' ']
               FOR z=0,15 DO BEGIN
                   FOR s=0,3 DO BEGIN
                       pos=[0.02+s*0.24,0.98-(z+1)*0.06,0.02+(s+1)*0.24,0.98-z*0.06]
                       IF ((where(alog(peaks(nr,*)) GE 0))(0) NE -1) THEN BEGIN 
                           plot,xpeaks,alog(peaks(nr,*)),position=pos,psym=1,$
                             xtickname=noticks,ytickname=noticks,yrange=[7.1,7.25],ystyle=5,/noerase
                           axis,yaxis=0,yrange=exp(!y.crange),/ystyle,ytickname=noticks
                           IF (z eq 15) THEN plot,xpeaks,alog(peaks(nr,*)),position=pos,psym=1,$
                             ytickname=noticks,yrange=[7.1,7.25],ystyle=5,/noerase
                           IF (s EQ 0) THEN axis,yaxis=0,yrange=exp(!y.crange),/ystyle
                           IF (s EQ 3) THEN axis,yaxis=1,yrange=exp(!y.crange),/ystyle,ytickname=noticks
                           oplot,[0,200],[alog(pos0(nr)),alog(pos0(nr))+alog(ctes(nr))*200],color=42
                       ENDIF ELSE BEGIN
                           plot,[0,1],/nodata,position=pos,/noerase,ystyle=8,xstyle=8,$
                             ytickname=noticks,xtickname=noticks
                       ENDELSE
                       xyouts,pos(2)-0.08,pos(3)-0.025,nr,/normal
                       nr=nr+1
                   ENDFOR
               ENDFOR
               
               IF (printing EQ 1) THEN BEGIN
                  set_plot,'ps'
                   device,file='tc_cte_peaks.ps',/portrait,xsize=19.0,ysize=25.0,xoffset=1,yoffset=0.5,$
                     set_font='Times',font_size=10
                   xyouts,0.2,1.0,file
                   nr=0
                   FOR z=0,15 DO BEGIN
                       FOR s=0,3 DO BEGIN
                           pos=[0.02+s*0.24,0.98-(z+1)*0.06,0.02+(s+1)*0.24,0.98-z*0.06]
                           IF ((where(alog(peaks(nr,*)) GE 0))(0) NE -1) THEN BEGIN 
                               plot,xpeaks,alog(peaks(nr,*)),position=pos,psym=1,$
                                 xtickname=noticks,ytickname=noticks,yrange=[7.1,7.25],ystyle=5,/noerase
                               axis,yaxis=0,yrange=exp(!y.crange),/ystyle,ytickname=noticks
                               IF (z eq 15) THEN plot,xpeaks,alog(peaks(nr,*)),position=pos,psym=1,$
                                 ytickname=noticks,yrange=[7.1,7.25],ystyle=5,/noerase
                               IF (s EQ 0) THEN axis,yaxis=0,yrange=exp(!y.crange),/ystyle
                               IF (s EQ 3) THEN axis,yaxis=1,yrange=exp(!y.crange),/ystyle,ytickname=noticks
                               oplot,[0,200],[alog(pos0(nr)),alog(pos0(nr))+alog(ctes(nr))*200],color=42
                           ENDIF ELSE BEGIN
                               plot,[0,1],/nodata,position=pos,/noerase,ystyle=8,xstyle=8,$
                                 ytickname=noticks,xtickname=noticks
                           ENDELSE
                           xyouts,pos(2)-0.08,pos(3)-0.02,nr,/normal
                           nr=nr+1
                       ENDFOR
                   ENDFOR
                   device,/close
                   set_plot,'x'  
               ENDIF
                
           ENDIF ELSE BEGIN
               
               plot,xcols,dat,xtitle='Column #',title=file,xrange=[0,63],psym=10,/xstyle
               xyouts,0.10,0.0,'Comment: '+comment,alignment=0.,charsize=0.7,/normal  
                    
               IF (printing EQ 1) THEN BEGIN
                   set_plot,'ps'
                   device,file='tc_gain.ps',/landscape, xsize=25.0,ysize=15.0,$
                     set_font='Times',font_size=18  
                   
                   plot,xcols,cte,xtitle='Column #',title=file,xrange=[0,63],psym=10,/xstyle
                   xyouts,0.10,0.0,'Comment: '+comment,alignment=0.,charsize=0.7,/normal  
                   
                   device,/close
                   set_plot,'x'  
               ENDIF
           ENDELSE
       ENDELSE
   ENDELSE
   IF keyword_set(stop) THEN stop
END 




















































































































