
PRO writewdata,filename,x,dx,data,blockndx=blockndx,serr=serr,terr=terr
   
;+
; NAME: writewdata
;
;
;
; PURPOSE: write files similar to those written by the pgplot wdata command (which can
;    be accessed, e.g., with the iplot command in XSPEC); these files
;    are also called "qdp"-files.
;
;
;
; CATEGORY: general data tools
;
;
;
; CALLING SEQUENCE: writewdata,filename,x,dx,data,blockndx=blockndx,serr=serr,terr=terr
;
;
;
; INPUTS:
;	filename:  name of the file to be written
;	       x:  Array containing the X-values of the qdp file (i.e the
;		   first column of the data
;	      dx:  Width of each x bin	    
;	    data:  array containing all other data to be written 
;	
;   
; OPTIONAL INPUTS:
;	blockndx:  array giving end positions after which
;		   data is to be divided into blocks.   
;           serr:  Array to tell QDP/PLT which vectors have symmetric
;                  errors. (which are listed in the column after the
;                  indicated vector)
;           terr:  Array to tell QDP/PLT which vectors have two-sided
;                  errors. Then (in the dataset) the first column is the
;                  central value, the second column (which must be
;                  positive) specifies the upper bound, and the third
;                  column (which must be negative or zero) specifies
;                  the lower bound.  
;   
; OUTPUTS:
;      a file named "filename.qdp"
; 
;   
; MODIFICATION HISTORY:
;	   Version 1.0: Kolja Giedke, IAA Tuebingen, Astronomie,
;	   May 10, 2000
; 
;-
   openw,unit,filename+'.qdp',/get_lun
   
   
   IF (n_elements(blockndx) EQ 0) THEN BEGIN
       blockndx = -5
   ENDIF 
   
   ;;
   ;; Write header
   ;;
   IF (n_elements(serr) NE 0) THEN BEGIN 
       printf,unit,'READ Serr ',+strtrim(string(serr),1)
   ENDIF 
   IF (n_elements(terr) NE 0) THEN BEGIN 
       printf,unit,'READ Terr ',+strtrim(string(terr),1)
   ENDIF 
   
   printf,unit,'!'
   
   j=0				;block-counter
   FOR	i = 0, n_elements(x)-1 DO BEGIN
     IF i EQ	blockndx[j] THEN BEGIN
                                ;if a new block begins
         j=j+1
         
         IF j GT n_elements(blockndx)-1 THEN BEGIN
             j = n_elements(blockndx)-1
         ENDIF
         
         IF x[i] GT x[i-1] THEN BEGIN 
             printf,unit,'NO NO NO'
         ENDIF 
     ENDIF 
     
     a=strtrim(string(x[i]),1)
     a=a+' '+strtrim(string(dx[i]),1)
     FOR k = 0, n_elements(data[0,*])-1 DO BEGIN
         a = a+' '+strtrim(string(data[i,k]),1)    
     ENDFOR 
     WHILE strlen(a) GT 80 DO BEGIN 
                                ; stimmt diese zahl 80 ????
         printf,unit,strmid(a,0,79)+'-'
         a=strmid(a,80,strlen(a))
     ENDWHILE 
     printf,unit,a
 ENDFOR
 
 free_lun,unit
END 












