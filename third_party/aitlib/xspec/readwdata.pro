;;
;; Take care of wrapped lines
;;
PRO readxspecline,unit,line
   a=''
   readf,unit,a
   while (strmid(a,strlen(a)-1,1) EQ '-') DO BEGIN 
       a1=''
       readf,unit,a1
       a=strmid(a,0,strlen(a)-1)+strmid(a1,1,strlen(a1)-1)
   ENDWHILE 
   line=a
END 


PRO readwdata,filename,x,dx,y,block=block,angstrom=angstrom
;+
; NAME: readwdata
;
;
;
; PURPOSE: read files written by the pgplot wdata command (which can
;    be accessed, e.g., with the iplot command in XSPEC); these files
;    are also called "qdp"-files.
;
;
;
; CATEGORY: general data tools
;
;
;
; CALLING SEQUENCE: readwdata,filename,x,dx,y,block=block[, /angstrom]
;
;
;
; INPUTS:
;       filename: name of the file to be read
;
;
; OPTIONAL INPUTS:
;       block: one qdp-file can contain data from several sources, e.g.,
;              measurements from several detectors. each of these
;              data are called a "block", set block=1 to get data
;              from the first instrument, block=2 to get data from
;              the second, and so on. The "blocks" are defined either
;              by a pgplot NO NO NO line, or by a non-increasing
;              x-value
;       angstrom: set this flag if you have a qdp file for which the x
;              value decreases from one line to the next.  Tis is the
;              case, for example, in spectra plotted vesus
;              "wavelength"
;
;
; OUTPUTS:
;       x:     Array containing the X-values of the qdp file (i.e.,
;              the first column of the data
;      dx:     Width of each x bin
;       y:     All other columns. Typically, for xspec, y[0,*] is the model,
;              y[1,*] the unfolded data point, y[2,*] its
;              uncertainty. The higher y contain the individual
;              additive models.
;
; MODIFICATION HISTORY:
;          Version 1.0: Joern Wilms, IAA Tuebingen, Astronomie,
;               sometime in 1996
;          Version 1.1: JW 2000.02.11: now read last line correctly 
;
;          Version 1.2: Biff 2001.03.28:  added /angstrom options for
;               cases where x values DECREASE from line to line
;               set /angstrom if this is the case (e.g. plots vs
;               wavelength)
;
;          Version 1.3: JW 2001.06.18: now angstrom works also for
;               block>1
;          Version 1.4: JW 2001.09.09: now more than one continuation
;               line possible (change to readxspecline)
;
;;
;-
   openr,unit,filename,/get_lun

   IF (n_elements(block) EQ 0) THEN block=1
   IF (block LE 0) THEN BEGIN 
       message,'block has to be greater than 0'
   END 
   ;;
   ;; Skip header
   ;;
   a=''
   readxspecline,unit,a
   readxspecline,unit,a
   readxspecline,unit,a
   
   ;;
   ;; Figure out number of columns
   ;;
   readxspecline,unit,a

   num=1
   asav=a
   WHILE strpos(asav,' ') GT 0 DO BEGIN 
       pos=strpos(asav,' ')
       asav=strmid(asav,pos+1,strlen(asav))
       num=num+1
   ENDWHILE 
   
   ;;
   ;; Find correct block to read
   ;;
   iblock=1
   lasten=-1E10
   IF (keyword_set(angstrom)) THEN lasten=1E10
   WHILE (iblock NE block) DO BEGIN 
       readxspecline,unit,a
       IF (strmid(a,0,2) EQ 'NO') THEN BEGIN 
           iblock=iblock+1
           readxspecline,unit,a
           lasten=-1E10 ;; Re-initialize lasten
           IF (keyword_set(angstrom)) THEN lasten=1E10
       END ELSE BEGIN 
           newen=double(a)
           IF (keyword_set(angstrom)) THEN BEGIN 
               IF (newen GT lasten) THEN iblock=iblock+1
           ENDIF ELSE BEGIN 
               IF (newen LT lasten) THEN iblock=iblock+1
           ENDELSE 
           lasten=newen
       END 
   ENDWHILE 

   ;;
   ;; Start reading the block and converting to numbers
   ;;
   maxchan=1000
   x=fltarr(maxchan)
   dx=fltarr(maxchan)
   y=fltarr(num-2,maxchan); Let's assume that maxchan channels is enough
   stop=0
   j=0
   REPEAT BEGIN 
       IF (eof(unit)) THEN stop=1
       ;;
       ;; Increase buffer if necessary
       ;;
       IF (j EQ maxchan) THEN BEGIN 
           maxchan2=maxchan*2
           xx=fltarr(maxchan2)
           ddx=fltarr(maxchan2)
           yy=fltarr(num-2,maxchan2)

           xx(0:maxchan-1)=x(0:maxchan-1)
           ddx(0:maxchan-1)=dx(0:maxchan-1)
           FOR kk=0,num-3 DO BEGIN 
               yy(kk,0:maxchan-1)=y(kk,0:maxchan-1)
           ENDFOR 
           
           x=xx
           dx=ddx
           y=yy
           xx=0
           ddx=0
           yy=0

           maxchan=maxchan2
       ENDIF 

       ;;
       ;; Break down current line
       ;;
       FOR i=0,num-1 DO BEGIN
           number=0
           IF (strmid(a,0,1) NE 'N') THEN number=float(a)
           IF (i EQ 0) THEN x(j)=number
           IF (i EQ 1) THEN dx(j)=number
           IF (i GE 2) THEN y(i-2,j)=number
           pos=strpos(a,' ')
           a=strmid(a,pos+1,strlen(a))
       ENDFOR 
       ;; make sure x is monotonic: increasing for energy,
       ;; decreasing for wavelength
       IF (j GT 0) THEN BEGIN 
           IF ( keyword_set(angstrom)  ) THEN BEGIN 
               ;; decreasing x (=angstroms)
               IF (x(j) GT x(j-1)) THEN BEGIN 
                   stop=1
                   j=j-1
               ENDIF 
           ENDIF ELSE BEGIN 
               ;; normal energy
               IF (x(j) LT x(j-1)) THEN BEGIN 
                   stop=1
                   j=j-1
               ENDIF 
           ENDELSE 
       ENDIF 

       j=j+1
       IF (stop NE 1) THEN readxspecline,unit,a
       IF (strmid(a,0,2) EQ 'NO') THEN stop=1
   END UNTIL (stop EQ 1)

   y=y(0:num-3,0:j-1)
   x=x(0:j-1)
   dx=dx(0:j-1)

   free_lun,unit
END 

