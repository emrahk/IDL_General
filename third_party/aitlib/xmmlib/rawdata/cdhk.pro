PRO cdhk,dirs=dirs,value=value,inpath=inpath,prefix=prefix,ps=ps,all=all
;+
; NAME: cdhk
;
;
;
; PURPOSE:          
;                   Extract hk info data from calibration
;                   data-files and plot it.
;
;
;
; CATEGORY: 
;                   Data-Screening
;
;
;
; CALLING SEQUENCE: 
;                   cdhk
;
;
; 
; INPUTS:
;                   none
;
;
; OPTIONAL INPUTS:
;                   none
;
;      
; KEYWORD PARAMETERS:
;                   ps: print to ps-files no output to screen
;
;
; OUTPUTS:
;                   ps-files with count info data
;
;
; OPTIONAL OUTPUTS:
;                   none
;
;
; COMMON BLOCKS:
;                   none
;
;
; SIDE EFFECTS:
;                   none
;
;
; RESTRICTIONS:
;                   none
;
;
; EXAMPLE:
;                   cdhk
; 
;
; MODIFICATION HISTORY:
; V1.0 14.01.99 M. Kuster
; V1.1 15.01.99 M. Kuster frame as parameter
; V2.0 01.03.99 M. Kuster path, directories, value, all as parameter
; V2.1 16.03.99 M. Kuster changed plottitle of housekeeping-plots
;-

   Inhalt=''
   lines=0
   IF (keyword_set(all)) THEN BEGIN
       all=1
   END ELSE BEGIN
       all=0
   END
   IF (NOT keyword_set(inpath)) THEN BEGIN
       inpath='./'
   ENDIF
   IF (NOT keyword_set(prefix)) THEN BEGIN
       prefix='HK'
   ENDIF
   
   IF ( (NOT keyword_set(value)) ) THEN BEGIN 
       value="CE_TTMPFPF"
       svalue=-1
   END 
   
   dirs=''
   IF (NOT keyword_set(dirs)) THEN BEGIN
       temp=findfile(inpath+prefix+'*.*',count=nobs)
       IF (nobs EQ 0) THEN print,'CDHK: ERROR No Directories '+inpath+prefix+'*'+$
         ' found !!'
       FOR i=0, nobs-1 DO BEGIN ; separate filenames out of temp
           IF (i MOD (9) EQ 0) THEN BEGIN
               t=STRPOS(temp(i),prefix)
               IF (t NE -1) THEN BEGIN
                   temp(i)=STRMID(temp(i),t,12)
               ENDIF 
               dirs=[dirs,temp(i)]
           ENDIF 
       ENDFOR
   ENDIF
   
   dirs=dirs[1:n_elements(dirs)-1]
   data=0 
   time=0
   obsend=0
   globdat=0

   IF (all EQ 1) THEN BEGIN
       gethk,inpath+dirs(0)+'/',value(0),hklist=hklist,/chatty ; first get hklist to know all in MonitorHK.par
                                ; defined parameters
       ;; plot all in MonitorHK.par file defined parameters
       frame=[value,hklist]         ; to plot all hk-parameters
       frame=STRMID(frame,0,10)
   END ELSE BEGIN
       frame=value
       frame=STRMID(frame,0,10)
   ENDELSE

   nobs=n_elements(dirs)
   nframe=n_elements(frame)
   
   IF (keyword_set(ps)) THEN BEGIN
       ps=1
   END ELSE BEGIN
       ps=0
   END

   FOR j=0, nframe-1 DO BEGIN
       FOR i=0, nobs-1 DO BEGIN
           path2=inpath+dirs(i)+'/' ; create path out of defined path and dirs
           gethk,path2,frame(j),data=dat,time=ti,/chatty ; read hk-values
           IF (dat[0] NE -1) THEN BEGIN 
               data=[data,dat]  ; append hk-values to array
               time=[time,ti]
           ENDIF 
           endpos=n_elements(data) ; determine last position of data-array
           obsend=[obsend,endpos] ; make vektor with number of elements in each observation
           ;; goto next observation i.e. next HK-file
       END
       data=data(1:n_elements(data)-1) ; remove first element equal to zero from data
       time=time(1:n_elements(time)-1)/64 ; time is given in fractions of 1/64 sec
       
       ;; plot hk-data on screen or to file
       IF ( ps EQ 1) THEN BEGIN ; plot to ps-file
           plotmk,data,frame(j),$
             plottitle='Housekeeping value '+STRTRIM(frame(j),2),$
             plotfile='../plots/'+STRTRIM(frame(j),2)+'.ps',titlex='n',$
             /ps,/autorange,/landscape
           spawn,"gzip "+'../plots/'+STRTRIM(frame(j),2)+'.ps',/noshell
       END ELSE BEGIN           ; plot on screen
           plotmk,data,frame(j),$
             plottitle='Housekeeping value '+STRTRIM(frame(j),2),$
             plotfile='../plots/'+STRTRIM(frame(j),2)+'.ps',titlex='n',$
             /autorange,/landscape
       END
       data=0
       obsend=0
       time=0
       ;; goto next hk-value
   END    
   print,'!!!!!!!!!!! FINISHED !!!!!!!!!!!!'
END





