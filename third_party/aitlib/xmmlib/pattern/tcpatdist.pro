PRO tcpatdist,file,quad,ccd,data=data,gain=gain,emin=emin,$
              minline=minline,maxline=maxline,mincol=mincol,maxcol=maxcol,$
              plot=plot,save=save,stop=stop
;+
; NAME:            
;                  tcpatdist
;
;
; PURPOSE:
;		   Determination of pattern distribution
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                   
;
; 
; INPUTS:
;                  file   : filename of hk-file
;                  quad   : the quadrant number (0..3)   
;                  ccd    : the ccdid of the desired ccd (0..11)   
;
;
; OPTIONAL INPUTS:
;                  data : data struct array, used instead of data from hk-file
;                  emin : lower threshold for energy
;		   minline, maxline, mincol, maxcol: area on ccd from which data is 
;		                              		to be taken   
;
;
; KEYWORD PARAMETERS:
;                  gain : do gain correction
;                  plot : show each frame
;                  save : save result in file HK??????_???_pat.dat   
;                  stop : stop before the end of the program   
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
;                  for gain correction, a gain file named
;                  Gain_xx_HK??????_???.dat must exist in the same directory
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
; V1.0 22.02.00 T. Clauss Initial version   
; V1.1 04.04.00 T. Clauss Added possibility for gain correction, emin   
   
   IF (NOT keyword_set(minline)) THEN minline=0
   IF (NOT keyword_set(maxline)) THEN maxline=199
   IF (NOT keyword_set(mincol)) THEN mincol=0
   IF (NOT keyword_set(maxcol)) THEN maxcol=63
   
   print,'% TCPATDIST: Reading data'
   IF (NOT keyword_set(data)) THEN BEGIN
       mkreadquad,file,quad,data=dat
       IF keyword_set(gain) THEN BEGIN
           print,'% TCPATDIST: Gain correction'
           dat=tcgain(dat,ccd,hkfile=file)
       ENDIF
   ENDIF ELSE BEGIN
       dat=data
   ENDELSE
   
   IF keyword_set(emin) THEN BEGIN 
       ind=where(dat.energy GE emin)
       IF (min(dat.energy) GT emin) THEN $
         print,'% TCPATDIST: min(energy) larger than emin!'    
   ENDIF ELSE BEGIN
       ind=where(dat.energy GT 0.0)
       emin=0
   ENDELSE
   
   dat=dat(ind)
   
   indx=where((dat.line GE minline) AND (dat.line LE maxline) AND $
              (dat.column GE mincol) AND (dat.column LE maxcol))
   dat=dat(indx)
   
   frame=dat.time-shift(dat.time,-1)
   frameind=where(frame NE 0)
   numframes=n_elements(frameind)
   
   nrcount=lonarr(101)
   nrcount(*)=0
   patdist=0
   dircount=intarr(4)  ; not (yet) used
   dircount(*)=0
   
   print,'% TCPATDIST: Searching for patterns'
   
   framedat=dat(0:frameind(0))
   ind=where(framedat.energy GT 0.0)
   
   IF keyword_set(plot) THEN BEGIN 
       plotdat=framedat
       mkplotintens1,plotdat,ccd,zoom=4
   ENDIF
   
  WHILE (ind(0) NE -1) DO BEGIN
      pcount=0
      doevent,framedat,ind(0),pcount,dircount
      IF (pcount LT 100) THEN BEGIN
          nrcount(pcount)=nrcount(pcount)+1
      ENDIF ELSE BEGIN
          nrcount(100)=nrcount(100)+1
      ENDELSE
      ind=where(framedat.energy GT 0.0)
  ENDWHILE
  
  IF keyword_set(plot) THEN stop
  
  FOR i=1L,numframes-1,1 DO BEGIN
      framedat=dat(frameind(i-1)+1:frameind(i))
      ind=where(framedat.energy GT 0.0)
      IF keyword_set(plot) THEN BEGIN 
          plotdat=framedat
          mkplotintens1,plotdat,ccd,zoom=4
      ENDIF
      WHILE (ind(0) NE -1) DO BEGIN
          pcount=0
          doevent,framedat,ind(0),pcount,dircount
          IF (pcount LT 100) THEN BEGIN
              nrcount(pcount)=nrcount(pcount)+1
          ENDIF ELSE BEGIN
              nrcount(100)=nrcount(100)+1
          ENDELSE
          ind=where(framedat.energy GT 0.0)
      ENDWHILE
      IF keyword_set(plot) THEN stop
  ENDFOR
  
  nrcount1=lonarr(101)
  for i=1,100 do nrcount1(i)=nrcount(i)*i
  numev=total(nrcount1,/double)
  numpat=total(nrcount,/double)
    
  IF keyword_set(save) THEN BEGIN
      print,'% TCPATDIST: Saving to file'
      IF (strlen(file) GT 13) THEN BEGIN
          ofile=strmid(file,strlen(file)-12,strlen(file)-4)+'_'+$
            strmid(file,strlen(file)-3,3)+'_pat.dat'
      ENDIF ELSE BEGIN
          ofile=strmid(file,0,strlen(file)-4)+'_'+$
            strmid(file,strlen(file)-3,3)+'_pat.dat'
      ENDELSE
      openw,unit,ofile,/get_lun
      printf,unit,'In ',file
      printf,unit,'  with emin = ',strtrim(emin,2),' , ',$
        'lines ',strtrim(minline,2),'..',strtrim(maxline,2),' , ',$      
        'cols ',strtrim(mincol,2),'..',strtrim(maxcol,2),' : '      
      printf,unit,'  '      
      printf,unit,'  Number of events: ',n_elements(dat)
      printf,unit,'  Number of counted events: ',long(numev)
      printf,unit,'  Number of frames: ',numframes
      printf,unit,'  Number of patterns: ',long(numpat)
      printf,unit,' '
      printf,unit,' Pattern distribution:'
      printf,unit,'   Size of patterns: ',strtrim(min(where(nrcount NE 0)),2),$
        '..',strtrim(max(where(nrcount NE 0)),2),' Pixels'
      printf,unit,' '
      printf,unit,'   Size:          # of patterns:          # of events:'
      FOR i=1,10 DO BEGIN 
          printf,unit,' ',strtrim(i,0),'     ',strtrim(nrcount(i),0),$
            '            ',strtrim(nrcount1(i),0)
      ENDFOR
      printf,unit,'     > 10     ',strtrim(long(total(nrcount(11:100))),0),$
        '            ',strtrim(long(total(nrcount1(11:100))),0)
      printf,unit,' '
      printf,unit,' '
      printf,unit,' '
      free_lun,unit   
  ENDIF 
  
  IF keyword_set(stop) THEN stop
  
END 
