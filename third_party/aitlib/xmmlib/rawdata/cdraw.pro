PRO cdraw,files=files,inpath=inpath,prefix=prefix,outpath=outpath,info=info,$
          standard=standard,ps=ps
;+
; NAME: cdraw
;
;
;
; PURPOSE:          
;                   Extract raw data from calibration
;                   data-files and plot it. 
;
;
; CATEGORY: 
;                   Data-Screening
;
;
;
; CALLING SEQUENCE: 
;                   cdraw
;
;
; 
; INPUTS:
;                   none
;
;
; OPTIONAL INPUTS:
;                   files  : a string or vector of strings containing the
;                            names of the files to read in, without leading
;                            path !!!
;                   inpath:  a string containing the path where to read the
;                            the 'files' from. Default is the path '/cdrom/'
;                   outpath: a string containing the outputpath for the
;                            error log-file. Default is the path './'.      
;                   prefix:  the procedure cdraw can search for files to
;                            be read in, according to a given
;                            prefix. e.g. prefix='hk' and inpath='/cdrom/',
;                            cdraw will search for all filenames in
;                            /cdrom/ starting with 'hk'. The keyword prefix
;                            can not be used together with the keyword
;                            files. Default is the string 'HK'.
;      
; KEYWORD PARAMETERS:
;                   info    : write error information to error-files
;                   standard: use the standard directory tree for
;                              data-screening   
;
;
; OUTPUTS:
;                   ps-files with raw data plots
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
;                   cdraw,files=filenames,inpath='/cdrom/hk/',outpath='./',/ps
; 
;
; MODIFICATION HISTORY:
; V1.0 18.11.98 M. Kuster
; V1.2 18.12.98 M. Kuster added statistics and new way of
;                         geteventdata and plotraw
; V1.3 14.03.99 M. Kuster it's no longer necessary to give a string vector
;                         of filenames because cdraw is searching for
;                         files to work on now.
;                         'files' is no longer a parameter, it's a keyword
;                         now !!
;                         added keyword 'outpath' to be compatible with
;                         cdcount 
; V1.4 15.03.99 M. Kuster fixed bug: when reading files with no events
;                         plotraw and geteventdata crashed
; V1.5 28.06.99 M. Kuster added keyword 'standard'   
; V1.6 13.12.99 M. Kuster changed fileio from fixed luns to dynamic luns   
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
      IF (nobs EQ 0) THEN print,'% CDRAW: ERROR No Files '+inpath+prefix+'*'+$
      ' found !!'
      FOR i=0, nobs-1 DO BEGIN ; separate filenames out of complete path
          t=STR_SEP(temp(i),'/')
          numstr=n_elements(t)
          temp(i)=t(numstr-1)
      ENDFOR
      files=temp ; files containes only the files no more path information
   ENDIF

   IF (keyword_set(info)) THEN BEGIN 
       info=1
   END ELSE BEGIN  
       info=0
   END 
   
   IF (keyword_set(ps)) THEN BEGIN
       ps=1
   END ELSE BEGIN
       ps=0
   END
   
   nobs=n_elements(files)
   rates=fltarr(4,nobs)
   
   FOR i=0, nobs-1 DO BEGIN
       allti=0
       allco=0
       numti=0 & numco=0
       file=inpath+files(i)
       ;; for satndart analysis of kalibration cds only !!!
       IF (std EQ 1) THEN outfile='../'+files(i)+'/rawdata/'+files(i) ELSE outfile=outpath+files(i)
       IF ( info EQ 1) THEN BEGIN 
           openw,KURZINFO,outfile+'_info',/get_lun
           readrawdata,file,q0=rawdata0,q1=rawdata1,q2=rawdata2,q3=rawdata3,ids=id,idhis=rahmenstat,$
             /chatty,/stat,stream=KURZINFO
       END ELSE BEGIN 
           readrawdata,file,q0=rawdata0,q1=rawdata1,q2=rawdata2,q3=rawdata3,ids=id,idhis=rahmenstat,$
             /chatty
       END 
       
       print,'% CDRAW: Working on Quadrant 0 ...'
       geteventdata,rawdata0,256,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
         sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
         numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
         enbit=enbit,/chatty
       IF (ps EQ 1) THEN BEGIN
           plotraw,rawdata0,outfile,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout,/ps
       END ELSE BEGIN
           plotraw,rawdata0,outfile,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout
       END
       allti=numti
       allco=numco
       
       print,'% CDRAW: Working on Quadrant 1 ...'
       geteventdata,rawdata1,256,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
         sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
         numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
         enbit=enbit,/chatty     
       IF (ps EQ 1) THEN BEGIN
           plotraw,rawdata1,outfile,1,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout,/ps
       END ELSE BEGIN
           plotraw,rawdata1,outfile,1,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout
       END

       allti=allti+numti
       allco=allco+numco
       
       print,'% CDRAW: Working on Quadrant 2 ...'
       geteventdata,rawdata2,256,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
         sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
         numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
         enbit=enbit,/chatty      
       IF (ps EQ 1) THEN BEGIN
           plotraw,rawdata2,outfile,2,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout,/ps
       END ELSE BEGIN
           plotraw,rawdata2,outfile,2,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout
       END
       
       anzti=allti+numti
       anzco=allco+numco
       
       print,'% CDRAW: Working on Quadrant 3 ...'
       geteventdata,rawdata3,256,0,energie=energie,zeile=zeile,spalte=spalte,time=time,$
         sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
         numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
         enbit=enbit,/chatty       
       IF (ps EQ 1) THEN BEGIN
           plotraw,rawdata3,outfile,3,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout,/ps
       END ELSE BEGIN 
           plotraw,rawdata3,outfile,3,energie=energie,zeile=zeile,spalte=spalte,time=time,$
             sekunde=sekunde,sekbruch=sekbruch,count=count,numco=numco,rawcount=rawcount,$
             numti=numti,eventpos=eventpos,events=events,ccd=ccd,rate=rate,$
             enbit=enbit,/chatty,/fileout
       END
       
       allti=allti+numti
       allco=allco+numco
       
       print,'% CDRAW: Number of Timewords: '+STRTRIM(allti,2)
       print,'% CDRAW: Number of Counters: '+STRTRIM(allco,2)  
       
       IF (info EQ 1) THEN BEGIN
           printf,KURZINFO,'Number if Timewords: '+STRTRIM(allti,2)
           printf,KURZINFO,'Number of Counters: '+STRTRIM(allco,2)   
           free_lun,KURZINFO
       END

   ENDFOR
   print,'% CDRAW: ################# FINISHED #################'
END






