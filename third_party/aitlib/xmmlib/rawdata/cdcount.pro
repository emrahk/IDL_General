PRO cdcount,files=files,inpath=inpath,prefix=prefix,outpath=outpath,$
            standard=standard,ps=ps
;+
; NAME: cdcount
;
;
;
; PURPOSE:          
;                   Extract count info data from calibration
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
;                   cdcount
;
;
; 
; INPUTS:
;                   none
;
;
; OPTIONAL INPUTS:
;                   files:   a string or vector of strings containing the
;                            names of the files to read in, without leading
;                            path !!!
;                   inpath:  a string containing the path where to read the
;                            the 'files' from. Default is the path '/cdrom/'
;                   outpath: a string containing the outputpath for the
;                            error log-file. Default is the path './'.      
;                   prefix:  the procedure cdcount can search for files to
;                            be read in according to a given
;                            prefix. e.g. prefix='hk' and inpath='/cdrom/',
;                            cdcount will search for all filenames in
;                            /cdrom/ starting with 'hk'. The keyword prefix
;                            can not be used together with the keyword
;                            files. Default is the string 'HK'.
;
;      
; KEYWORD PARAMETERS:
;
;                   ps:       print to ps-files no output to screen
;                   standard: use the standard directory tree for
;                             data-screening  ;
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
;                   cdcount,files=filenames,inpath='/cdrom/hk/',outpath='./',/ps
; 
;
; MODIFICATION HISTORY:
; V1.0 01.03.99 M. Kuster
; V1.1 14.03.99 M. Kuster it's no longer necessary to give a string vector
;                         of filenames because cdcount is searching for
;                         files to work on now.
;                         'files' is no longer a parameter, it's a keyword
;                          now !!
; V1.2 28.06.99 M. Kuster added keyword 'standard'
;-
   IF (NOT keyword_set(prefix)) THEN BEGIN
       prefix='HK'
   ENDIF
   
   IF (NOT keyword_set(inpath)) THEN BEGIN
       inpath='/cdrom/'
   ENDIF
   
   IF (NOT keyword_set(outpath)) THEN BEGIN
       outpath='./'
   END   
   
   IF (keyword_set(standard)) THEN std=1 ELSE std=0

   IF (NOT keyword_set(files)) THEN BEGIN
      temp=findfile(inpath+prefix+'*',count=nobs)
      IF (nobs EQ 0) THEN print,'% CDCOUNT: ERROR No Files '+inpath+prefix+'*'+$
      ' found !!'
      FOR i=0, nobs-1 DO BEGIN ; separate filenames out of complete path
          t=STR_SEP(temp(i),'/')
          numstr=n_elements(t)
          temp(i)=t(numstr-1)
      ENDFOR
      files=temp ; files contains only the files no more path information
   ENDIF

   nobs=n_elements(files)
   rates=fltarr(4,nobs)
   
   IF (keyword_set(ps)) THEN BEGIN
       ps=1
   END ELSE BEGIN
       ps=0
   END
   
   FOR i=0, nobs-1 DO BEGIN
       file=inpath+files(i)
       path=''
       ;; for standard analysis of calibration cds only !!!
       IF (std EQ 1) THEN path='../'+files(i)+'/countinfo/' ELSE path=outpath
       
       ;; quadrant 0
       readrawdata,file,q0=rawdata,/chatty
       getcountinfo,rawdata,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
         messcount=mess,mcm=mcm,/chatty
       IF (ps EQ 0) THEN BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,0,/chatty,/errorfile,/msmooth
       END ELSE BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,0,/chatty,/errorfile,/ps,/msmooth
       END
       ;; quadrant 1      
       readrawdata,file,q1=rawdata,/chatty
       getcountinfo,rawdata,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
         messcount=mess,mcm=mcm,/chatty
       IF (ps EQ 0) THEN BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,1,/chatty,/errorfile,/msmooth
       END ELSE BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,1,/chatty,/errorfile,/ps,/msmooth
       END
       ;; quadrant 2      
       readrawdata,file,q2=rawdata,/chatty
       getcountinfo,rawdata,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
         messcount=mess,mcm=mcm,/chatty
       IF (ps EQ 0) THEN BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,2,/chatty,/errorfile,/msmooth
       END ELSE BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,2,/chatty,/errorfile,/ps,/msmooth
       END
       ;; quadrant 3
       readrawdata,file,q3=rawdata,/chatty
       getcountinfo,rawdata,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
         messcount=mess,mcm=mcm,/chatty
       IF (ps EQ 0) THEN BEGIN           
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,3,/chatty,/errorfile,/msmooth
       END ELSE BEGIN
           plotcount,files(i),outpath=path,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,$
             mcm=mcm,mess,3,/chatty,/errorfile,/ps,/msmooth
       END
   ENDFOR
   print,'% CDCOUNT: ################# FINISHED #################'
END






