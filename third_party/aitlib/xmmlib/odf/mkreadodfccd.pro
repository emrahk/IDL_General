PRO mkreadodfccd,file,data,auxfile=auxfile,header=header,count=count,chatty=chatty
;+
; NAME:
;       MKREADODFCCD
;
;
; PURPOSE:
;       Read XMM-ODF data
;
;
; CATEGORY:
;       ODF, FITS
;
;
; CALLING SEQUENCE:
;       mkreadodfccd,file,data,auxfile=auxfile,header=header,/chatty
; 
;  
; INPUTS:
;       file: Name of odf file to be read
;       
;
; OPTIONAL INPUTS:
;       auxfile: Name of auxiliary file with time information
;
;	
; KEYWORD PARAMETERS:
;       chatty: print more information on what is going on
;
;   
; OUTPUTS:
;       data: data struct array of the form:  
;   
;       data={data,line:long(0),column:long(0),energy:double(0),sec:double(0),$
;         secbruch:double(0),ccd:byte(0),split:long(0),time:double(0),frame:long(0)}
;   
;
; OPTIONAL OUTPUTS:
;       header: header information from odf file
;
;
; RESTRICTIONS:
;       The frame number given in data.frame is just counting the
;       frames containing events. For "real" frame numbers
;       (also considering empty frames) use tcaddrframeinfo on data
;       (e.g. data=tcaddframeinfo(data,'mode',/framedatastruct) )
;   
;   
; PROCEDURE: 
;
;
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
; V1.0 mkreadodfccd.pro written 2000 by Markus Kuster, IAAT  
; V1.1 15.05.00 M. Kuster added keyword header
; V2.0 13.09.00 T. Clauss : use MRDFITS routine for reading fits files  
; V2.1 25.10.00 M. Kuster removed some bugs
; V2.2 23.11.00 M. Kuster works with aux files containing time
;                         information of more than one CCD, now.
;-   
    
   on_error,2                   ; Return to caller if an error occurs

   IF (n_elements(count) EQ 0) THEN BEGIN 
       readcount=0 
   ENDIF ELSE BEGIN 
       readcount=1
   ENDELSE 

   modes=['ext. Full Frame','Full Frame','Large Window','Small Window','Timing','Burst']
   
   data={data,line:long(0),column:long(0),energy:double(0),sec:double(0),$
         secbruch:double(0),ccd:byte(0),split:long(0),time:double(0),frame:long(0)}
   
   print,'% MKREADODFCCD: Opening file: '+file
   
   datastruct=MRDFITS(file,1,header)
   
   IF (n_elements(datastruct) GT 1) THEN BEGIN 
       ;; Extract header-information
       quadrant=fxpar(header,'QUADRANT')
       ccd=fxpar(header,'CCDID')
       instrument=fxpar(header,'INSTRUME')
       mode=fxpar(header,'CCDMODE')
       ccdnew=fix(quadrant AND '00000003'xl)*3+(fix(ccd) AND '00000003'xl)
       
       IF (keyword_set(chatty)) THEN BEGIN
           print,'% MKREADODFCCD: Observation mode was ',modes(mode)
           print,'% MKREADODFCCD: Read data of quadrant: '+string(format='(I2)',quadrant)
           print,'% MKREADODFCCD: and CCD: '+string(format='(I2)',ccd)
           print,'% MKREADODFCCD: This is equal to CCD (official notation): '+$
             string(format='(I2)',ccdnew+1) 
       ENDIF 
       
       ;; read data
       numev=n_elements(datastruct)
       data=replicate(data,numev)
       
       data.energy=datastruct.energy
       data.line=datastruct.rawy
       data.column=datastruct.rawx
       data.frame=datastruct.frame
       data.time=datastruct.frame
       
       datastruct=0
       
       data(*).ccd=ccdnew
       data(*).sec=-1
       data(*).secbruch=-1
       data(*).split=-1
   
       IF keyword_set(auxfile) THEN BEGIN
           
           IF (keyword_set(chatty)) THEN BEGIN
               print,'% MKREADODFCCD: Opening file: '+auxfile
               print,'% MKREADODFCCD: Reading aux-data ...'
           ENDIF 
           
           auxdatastruct=MRDFITS(auxfile,1)
           
           ;; get auxdata for the specific CCD and Quadrant
           ind = where((auxdatastruct.ccdid EQ ccd) AND (auxdatastruct.quadrant EQ quadrant))
           auxdatastruct=auxdatastruct(ind)

           IF (n_elements(auxdatastruct) LT 1) THEN BEGIN 
               print,'% MKREADODFCCD: Aux file does not contain data for this CCD'
               data=-1
               return
           ENDIF 
           
           dframe=data(0).frame-auxdatastruct(0).frame
           
           IF dframe LT 0 THEN BEGIN 
               print,'% MKREADODFCCD: Frame numbering in data file and aux file does not fit!'
               print,'% MKREADODFCCD: The time values probably are not correct !!!'
               dframe=0
           ENDIF
           
           data.time=data.time-data(0).time+dframe
           data.sec=auxdatastruct(data.time).ftcoarse
           data.secbruch=auxdatastruct(data.time).ftfine
           
           auxdatastruct=0
           
           fr = 25000000d0    
           zeiteinheit=fr/512d0
           data.time=data.sec+data.secbruch*1d0/zeiteinheit
       ENDIF
       IF (readcount EQ 1) THEN BEGIN 
           IF (keyword_set(chatty)) THEN BEGIN
               print,'% MKREADODFCCD: Opening file: '+auxfile
               print,'% MKREADODFCCD: Reading count-data ...'
           ENDIF 
           
           ;; read counter information DSLIN,MCM,ATHRC,EPDH,FIFO-READ
           IF (readcount EQ 1) THEN BEGIN 
               count=MRDFITS(auxfile,2)
             ;; get counter-data for the specific CCD and Quadrant
             ind = where(count.quadrant EQ quadrant)
             count=count(ind)
         ENDIF 
     ENDIF 
       
   ENDIF ELSE BEGIN 
       print,'% MKREADODFCCD: ERROR No data found !!! '
   ENDELSE 
END 



