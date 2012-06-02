PRO tcpatspec,file,quad,ccd,minpat=minpat,maxpat=maxpat,$
              gainfile=gainfile,bin=bin,ps=ps,stop=stop
   
;+
; NAME:            
;                  tcpatspec
;
;
; PURPOSE:
;		   Calculate original spectrum from multi-pixel events  
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  tcpatspec,"HK000214.000",0,9
;
; 
; INPUTS:
;                  file :  name of HK file
;                  quad :  quadrant of ccd containing the data (0..3)
;                  ccd :   number of ccd containing the data (0..11)
;
;
; OPTIONAL INPUTS:
;                  maxpat :  maximal size of patterns used for spectrum
;                  minpat :  minimal size of patterns used for spectrum
;                  gainfile :  file with gain values for gain correction
;   
;
; KEYWORD PARAMETERS:
;                  bin :  gainfile in binary format 
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
;                  find patterns, sum energy of whole pattern   
;                  see code for more details
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 14.01.00  T. Clauss initial version
; V1.1 14.03.00  T. Clauss added gain correction  
;-
   
   
  maxenergy=50000 
  IF (NOT keyword_set(maxpat)) THEN maxpat=100
  IF (NOT keyword_set(minpat)) THEN minpat=1
  
  print,'% TCPATSPEC: Reading data'
  mkreadquad,file,quad,data=dat
  
  IF keyword_set(gainfile) THEN BEGIN
      print,'% TCPATSPEC: Doing gain correction'
      dat=tcgain(dat,ccd,gainfile=gainfile,bin=bin)      
  ENDIF
  
  ind=where(dat.energy GT 0.0)
  dat=dat(ind)

  frame=dat.time-shift(dat.time,-1)
  frameind=where(frame NE 0)
  numframes=n_elements(frameind)
  
  nrcount=lonarr(101)
  nrcount(*)=0
  patdist=0

  energycnt=lonarr(maxenergy)
  energycnt(*)=0
  
  print,'% TCPATSPEC: Searching for patterns'
  
  framedat=dat(0:frameind(0))
  ind=where(framedat.energy GT 0.0)
  IF keyword_set(plot) THEN BEGIN 
      plotdat=framedat
      mkplotintens,plotdat,ccd,zoom=4
  ENDIF
  WHILE (ind(0) NE -1) DO BEGIN
      pcount=0
      penergy=0
      doeventspec,framedat,ind(0),pcount,penergy
      IF (pcount LT 100) THEN BEGIN
          nrcount(pcount)=nrcount(pcount)+1
      ENDIF ELSE BEGIN
          nrcount(100)=nrcount(100)+1
      ENDELSE
      IF (pcount GE minpat) THEN BEGIN 
          IF (pcount LE maxpat) THEN BEGIN 
              IF (penergy LT maxenergy-1) THEN BEGIN
                  energycnt(penergy)=energycnt(penergy)+1
              ENDIF ELSE BEGIN
                  energycnt(maxenergy-1)=energycnt(maxenergy-1)+1
              ENDELSE      
          ENDIF 
      ENDIF
      ind=where(framedat.energy GT 0.0)
  ENDWHILE
  
  IF keyword_set(plot) THEN stop
  
  FOR i=1,numframes-1,1 DO BEGIN
      framedat=dat(frameind(i-1)+1:frameind(i))
      ind=where(framedat.energy GT 0.0)
      IF keyword_set(plot) THEN BEGIN 
          plotdat=framedat
          mkplotintens,plotdat,ccd,zoom=4
      ENDIF
      WHILE (ind(0) NE -1) DO BEGIN
          pcount=0
          penergy=0
          doeventspec,framedat,ind(0),pcount,penergy
          IF (pcount LT 100) THEN BEGIN
              nrcount(pcount)=nrcount(pcount)+1
          ENDIF ELSE BEGIN
              nrcount(100)=nrcount(100)+1
          ENDELSE
          IF (pcount GE minpat) THEN BEGIN
              IF (pcount LE maxpat) THEN BEGIN 
                  IF (penergy LT maxenergy-1) THEN BEGIN
                      energycnt(penergy)=energycnt(penergy)+1
                  ENDIF ELSE BEGIN
                      energycnt(maxenergy-1)=energycnt(maxenergy-1)+1
                  ENDELSE      
              ENDIF
          ENDIF  
          ind=where(framedat.energy GT 0.0)
      ENDWHILE
      IF keyword_set(plot) THEN stop
  ENDFOR
   
  nrcount1=lonarr(101)
  for i=1,100 do nrcount1(i)=nrcount(i)*i
  numev=total(nrcount1)
  numpat=total(nrcount)
    
  plot,energycnt,xrange=[0,5000],title=file,xtitle='Energy [ADU]',ytitle='Counts',psym=10
  
  IF keyword_set(ps) THEN BEGIN
      set_plot,'ps'
      IF (strlen(file) GT 13) THEN BEGIN
          ofile=strmid(file,strlen(file)-12,strlen(file)-4)+'_'+$
            strmid(file,strlen(file)-3,3)+'_patspec.ps'
      ENDIF ELSE BEGIN
          ofile=strmid(file,0,strlen(file)-4)+'_'+$
            strmid(file,strlen(file)-3,3)+'_patspec.ps'
      ENDELSE
      device,file=ofile,/landscape, xsize=25.0,ysize=15.0,$
        set_font='Times',font_size=18  
 
      plot,energycnt,xrange=[0,5000],title=file,xtitle='Energy [ADU]',ytitle='Counts',psym=10
      
      device,/close
      set_plot,'x'  
  ENDIF 
  
  IF keyword_set(stop) THEN stop
  
END 
