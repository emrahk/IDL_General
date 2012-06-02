PRO readasm,time,rate,error,filename,mjd=mjd,    $
            tstart=tstart,tend=tend,chi2=chi2,   $
            ra_obj=ra_obj,dec_obj=dec_obj,       $
            maxchi2=maxchi2,minchi2=minchi2,     $
            exptime=exptime,ssc_n=ssc_n,         $
            color=color,time_col=time_col,       $
            ratea=ratea,errora=errora,chia=chia, $
            rateb=rateb,errorb=errorb,chib=chib, $
            ratec=ratec,errorc=errorc,chic=chic
;+
; NAME:
;           readasm
;
;
; PURPOSE:
;           Read an ASM 1dwell lightcurve, bin to a desired
;           temporal resolution...
;
;
; CATEGORY:
;           RXTE tools
;
;
; CALLING SEQUENCE:
;           readasm,time,rate,error,filename,mjd=mjd,tstart=tstart, $
;              tend=tend,chi2=chi2,ra_obj=ra_obj,dec_obj=dec_obj,  $
;              maxchi2=maxchi2,color=color,time_col=time_col, $
;              ratea=ratea,errora=errora,chia=chia, $
;              rateb=rateb,errorb=errorb,chib=chib, $
;              ratec=ratec,errorc=errorc,chic=chic
; 
; INPUTS:
;           filename: name of the file to be read, WITHOUT THE SUFFIX
;                     (.lc or .col)
;
;
; OPTIONAL INPUTS:
;           none
;
;	
; KEYWORD PARAMETERS:
;           mjd   : if set, return time as a MJD (=JD-2400000.5)
;           tstart: start of time-interval to be read
;           tend  : end of time-interval
;           units of tstart and tend are either MET
;           (in days), or MJD, if the MJD switch is set.
;           maxchi2: set maxchi2 to the maximum reduced chi^2 value
;                   you still want to accept
;           minchi2: set minchi2 to the minimum reduced chi^2 value
;                   you still want to accept
;           exptime: set exptime to select only dwells with a complete
;                    exposure time of 90 sec. (only for the case
;                    color=0, see below) 
;           ssc_n:  selec ssc number (0,1 or 2) (only for the case
;                   color=0, see below)
;           color  : select ASM color.
;                        0: total  band (...d1.lc files)
;                      for the ...d1.col files, the follwing bands are 
;                      possible:
;                        1: ASM channel  410...1188 1.3 -- 3.0keV
;                        2: ASM channel 1189...1860 3.0 -- 5.0keV
;                        3: ASM channel 1861...4750 5.0 --12.2keV
;                        4: Three ASM colors plus total, from separate
;                           files (total in main time, rate, etc.)
;
;
; OUTPUTS:
;           time  : time of each time-bin (mid of interval)
;           rate  : ASM count-rate (1-10 keV)
;           error : uncertainty
;
; OPTIONAL OUTPUTS:
;           chi2     : reduced chi^2 values for the returned lightcurve
;           ra_obj   : Object right ascension in degrees 
;           dec_obj  : Object declination in degrees
;           time_col : time for separate colors
;           ratea..c : rates for separate colors
;           errora..c: errors for separate colors
;           chia..c  : reduced chi^2 values for separate colors
;
;
;
; COMMON BLOCKS:
;           none
;
;
; SIDE EFFECTS:
;           none
;
;
; RESTRICTIONS:
;           hopefully none; tend has to be larger than tstart
;
;
; PROCEDURE:
;           see code
;
;
; EXAMPLE:
;           readasm,time,rate,error,'xa_herx1_d1',/mjd
;
;           ...read all available  ASM data on Her X-1, return time as
;           MJD
;
; MODIFICATION HISTORY:
;           Version 1.0, 1997/10/06, Joern Wilms
;           Version 1.1, 1998/07/07, Joern Wilms / Sara Benlloch:
;             * added maxchi2 keyword and chi2 optional output.
;             * removed dt keyword (no internal rebinning is done)
;           Version 2.0, 1999/08/14, Joern Wilms:
;             * added option to select for ASM color
;           Version 2.1, 1999/09/22, Michael Nowak:
;             * added screening to make sure color files have either 3
;               or 6 legitimate colors only at any given time, to
;               remove spurious points
;             * added option to output 3 colors simultaneously
;             * maxchi2 applies to all 3 channels simultaneously,
;               equally
;            Version 2.2, 1999/10/19, Michael Nowak
;             * color=4 now outputs 3 colors plus total
;             * changed color lightcurve screening to compare to total
;               integrated lightcurve, and screen for specific,
;               acceptable channel patterns
;            Version 2.3, 1999/11/04, Joern Wilms
;             * integated back into aitlib, changed small typo in the
;               color selection.
;            Version 2.4, 1999/11/16, Sara Benlloch   
;             * added filename_end variable to avoid mistakes with the
;               definition of the filenames.
;            Version 2.5, 1999/11/29, Sara Benlloch
;             * added option ra_obj and dec_obj to output
;            Version 2.6, 2000/11/28, Sara Benlloch (IAAT),
;             * added keywords; minchi2,exptime,ssc_n  
;            Version 2.7, 2001/04/19, Katja Pottschmidt (IAAT), 
;             * changed loop variable nt to long, substituted color suffix
;               b for c in two places where necessary            
;-            
   
   
   ;; Preset Keywords
   IF (n_elements(color) EQ 0) THEN color=0
   
   ;; Define filenames
   filename_end = strmid(filename,strlen(filename)-3,3)
   IF filename_end EQ '.lc' THEN BEGIN 
       filename_lc = filename 
       filename_col = strmid(filename,0,strlen(filename)-3)+'.col'
   ENDIF ELSE BEGIN  
       filename_lc = filename +'.lc'
       filename_col = filename+'.col'
   ENDELSE     
   
   ;;
   ;; Read main lightcurve file
   ;;
   tab=readfits(filename_lc,h,/exten_no,/no_unsigned)
   time=tbget(h,tab,'TIME') 
   rate=tbget(h,tab,'RATE')
   error=tbget(h,tab,'ERROR')
   chi2=tbget(h,tab,'RDCHI_SQ')
   minchan=tbget(h,tab,'MINCHAN')
   maxchan=tbget(h,tab,'MAXCHAN')
   expt=tbget(h,tab,'TIMEDEL')
   ssc=tbget(h,tab,'SSC_NUMBER')
   
   ;; color selection
   mi=[ 410, 410,1189,1861]
   ma=[4750,1188,1860,4750]
   
   ;; This is horrendously slow, and possibly horrendously stupid
   IF (color GT 0) THEN BEGIN 
       ;;
       ;; Read color lightcurve file
       ;;
       tab_c=readfits(filename_col,h,/exten_no,/no_unsigned)
       time_c=tbget(h,tab_c,'TIME') 
       rate_c=tbget(h,tab_c,'RATE')
       error_c=tbget(h,tab_c,'ERROR')
       chi2_c=tbget(h,tab_c,'RDCHI_SQ')
       minchan_c=tbget(h,tab_c,'MINCHAN')
       maxchan_c=tbget(h,tab_c,'MAXCHAN')
       ;;
       nt = n_elements(time) - 1
       ;;       
       ;; Temporary holding arrays for filtered color files
       ;;
       time_h = fltarr(nt+1)
       ;;       
       ratea = fltarr(nt+1)
       errora = fltarr(nt+1)
       chia = fltarr(nt+1)
       ;;       
       rateb = fltarr(nt+1)
       errorb = fltarr(nt+1)
       chib = fltarr(nt+1)
       ;;       
       ratec = fltarr(nt+1)
       errorc = fltarr(nt+1)
       chic = fltarr(nt+1)       
       ;;
       FOR i=0L,nt DO BEGIN 
           ;;
           nwt = where(time_c EQ time(i))
           IF (nwt[0] NE -1) THEN BEGIN 
               newt = n_elements(where(time EQ time(i)))
               ;;
               naw = where(time_c EQ time(i) AND $
                           minchan_c EQ mi[1] AND maxchan_c EQ ma[1],na)
               nbw = where(time_c EQ time(i) AND $
                           minchan_c EQ mi[2] AND maxchan_c EQ ma[2],nb)
               ncw = where(time_c EQ time(i) AND $
                           minchan_c EQ mi[3] AND maxchan_c EQ ma[3],nc)
               ;;
               ;;  There can be one or two (two detectors) identical 
               ;; times. Allow 6 cases of channel patterns.
               ;;
               ;; CASE 1
               IF (newt EQ 1 AND na EQ 1 AND nb EQ 1 AND nc EQ 1) THEN BEGIN 
                   ichk = where(minchan_c(nwt) NE [mi[1],mi[2],mi[3]])
                   IF (ichk[0] EQ -1) THEN BEGIN 
                       ;;
                       time_h(i) = time_c(nwt[0])
                       ratea(i) = rate_c(naw)
                       errora(i) = error_c(naw)
                       chia(i) = chi2_c(naw)
                       ;;
                       rateb(i) = rate_c(nbw)
                       errorb(i) = error_c(nbw)
                       chib(i) = chi2_c(nbw)
                       ;;
                       ratec(i) = rate_c(ncw)
                       errorc(i) = error_c(ncw)
                       chic(i) = chi2_c(ncw)
                       ;;
                   ENDIF 
               ENDIF 
               ;;
               ;; CASE 2    
               ;;
               IF (newt EQ 2 AND na EQ 2 AND nb EQ 2 AND nc EQ 2) THEN BEGIN 
                   ichk = where(minchan_c(nwt) NE $
                                [mi[1],mi[2],mi[3],mi[1],mi[2],mi[3]])
                   IF (ichk[0] EQ -1) THEN BEGIN 
                       ;;
                       time_h(i:i+1) = [time_c(nwt[0]),time_c(nwt[0])]
                       ratea(i:i+1) = rate_c(naw)
                       errora(i:i+1) = error_c(naw)
                       chia(i:i+1) = chi2_c(naw)
                       ;;
                       rateb(i:i+1) = rate_c(nbw)
                       errorb(i:i+1) = error_c(nbw)
                       chib(i:i+1) = chi2_c(nbw)
                       ;;
                       ratec(i:i+1) = rate_c(ncw)
                       errorc(i:i+1) = error_c(ncw)
                       chic(i:i+1) = chi2_c(ncw)
                   ENDIF
               ENDIF
               ;;
               ;; CASE 3
               ;;
               IF (newt EQ 1 AND na NE 1 AND nb NE 0 AND nc NE 0) THEN BEGIN 
                   ;;
                   ;; The expected (wrong) pattern is
                   ;; [ch1,ch2,ch1,ch2,ch3].
                   ;; If it ain't, throw it out completely!  
                   ;; If it is, keep the last three,
                   ;; which *seems* to agree with Ron Remillards files. 
                   ;;
                   IF ((na+nb+nc) EQ 5) THEN BEGIN 
                       ichk=where(minchan_c(nwt) NE $
                                  [mi[1],mi[2],mi[1],mi[2],mi[3]])
                       IF (ichk[0] EQ -1) THEN BEGIN 
                           ;;
                           time_h(i) = time_c(nwt[0])
                           ratea(i) = rate_c(naw[1])
                           errora(i) = error_c(naw[1])
                           chia(i) = chi2_c(naw[1])
                           ;;
                           rateb(i) = rate_c(nbw[1])
                           errorb(i) = error_c(nbw[1])
                           chib(i) = chi2_c(nbw[1])
                           ;;
                           ratec(i) = rate_c(ncw)
                           errorc(i) = error_c(ncw)
                           chic(i) = chi2_c(ncw)
                           ;;
                       ENDIF 
                   ENDIF
                   ;;
               ENDIF
               
               IF (newt EQ 2 AND na NE 2 AND naw[0] NE -1 $
                   AND nbw[0] NE -1 AND ncw[0] NE -1) THEN BEGIN
                   ;;
                   IF ((na+nb+nc) EQ 8) THEN BEGIN 
                       ichk=where(minchan_c(nwt) NE $
                                  [mi[1],mi[2],$
                                   mi[1],mi[2],mi[3], $
                                   mi[1],mi[2],mi[3]])
                       ;; CASE 4
                       IF (ichk[0] EQ -1) THEN BEGIN 
                           ;;
                           time_h(i:i+1) = [time_c(nwt[0]),time_c(nwt[0])]
                           ratea(i:i+1) = [rate_c(naw[1]),rate_c(naw[2])]
                           errora(i:i+1) = [error_c(naw[1]),error_c(naw[2])]
                           chia(i:i+1) = [chi2_c(naw[1]),chi2_c(naw[2])]
                           ;;
                           rateb(i:i+1) = [rate_c(nbw[1]),rate_c(nbw[2])]
                           errorb(i:i+1) = [error_c(nbw[1]),error_c(nbw[2])]
                           chib(i:i+1) = [chi2_c(nbw[1]),chi2_c(nbw[2])]
                           ;;
                           ratec(i:i+1) = [rate_c(ncw[0]),rate_c(ncw[1])]
                           errorc(i:i+1) = [error_c(ncw[0]),error_c(ncw[1])]
                           chic(i:i+1) = [chi2_c(ncw[0]),chi2_c(ncw[1])]
                       ENDIF 
                       ;;
                       ichk=where(minchan_c(nwt) NE $
                            [mi[1],mi[2],mi[3],mi[1],mi[2],mi[1],mi[2],mi[3]])
                       ;; CASE 5
                       IF (ichk[0] EQ -1) THEN BEGIN 
                           ;;
                           time_h(i:i+1) = [time_c(nwt[0]),time_c(nwt[0])]
                           ratea(i:i+1) = [rate_c(naw[0]),rate_c(naw[2])]
                           errora(i:i+1) = [error_c(naw[0]),error_c(naw[2])]
                           chia(i:i+1) = [chi2_c(naw[0]),chi2_c(naw[2])]
                           ;;
                           rateb(i:i+1) = [rate_c(nbw[0]),rate_c(nbw[2])]
                           errorb(i:i+1) = [error_c(nbw[0]),error_c(nbw[2])]
                           chib(i:i+1) = [chi2_c(nbw[0]),chi2_c(nbw[2])]
                           ;;
                           ratec(i:i+1) = [rate_c(ncw[0]),rate_c(ncw[1])]
                           errorc(i:i+1) = [error_c(ncw[0]),error_c(ncw[1])]
                           chic(i:i+1) = [chi2_c(ncw[0]),chi2_c(ncw[1])]
                           ;;
                       ENDIF 
                   ENDIF ELSE IF ((na+nb+nc) EQ 10) THEN BEGIN 
                       ichk=where(minchan_c(nwt) NE $
                                  [mi[1],mi[2], $
                                   mi[1],mi[2],mi[3],$
                                   mi[1],mi[2],$
                                   mi[1],mi[2],mi[3]])
                       ;; CASE 6
                       IF (ichk[0] EQ -1) THEN BEGIN 
                           ;;
                           time_h(i:i+1) = [time_c(nwt[0]),time_c(nwt[0])]
                           ratea(i:i+1) = [rate_c(naw[1]),rate_c(naw[3])]
                           errora(i:i+1) = [error_c(naw[1]),error_c(naw[3])]
                           chia(i:i+1) = [chi2_c(naw[1]),chi2_c(naw[3])]
                           ;;
                           rateb(i:i+1) = [rate_c(nbw[1]),rate_c(nbw[3])]
                           errorb(i:i+1) = [error_c(nbw[1]),error_c(nbw[3])]
                           chib(i:i+1) = [chi2_c(nbw[1]),chi2_c(nbw[3])]
                           ;;
                           ratec(i:i+1) = [rate_c(ncw[0]),rate_c(ncw[1])]
                           errorc(i:i+1) = [error_c(ncw[0]),error_c(ncw[1])]
                           chic(i:i+1) = [chi2_c(ncw[0]),chi2_c(ncw[1])]
                           ;;
                       ENDIF 
                       ;;
                   ENDIF  
                   ;;
               ENDIF 
               ;;
               time_c(nwt) = -1.
           ENDIF 
           ;;
       ENDFOR 
   ENDIF 
   ;;
   ndx=where(minchan EQ mi[0] AND maxchan EQ ma[0])
   IF (ndx[0] EQ -1) THEN BEGIN 
       message, $
         'No matching color found, are you reading the correct file?'
   END ELSE BEGIN 
       time = time(ndx)
       rate = rate(ndx)
       error = error(ndx)
       chi2 = chi2(ndx)
       expt=expt(ndx)
       ssc=ssc(ndx)
   ENDELSE
   ;;
   IF (color GT 0) THEN BEGIN 
       time_col = time_h
   ENDIF 
   ;;
   IF (color EQ 1) THEN BEGIN 
       time = time_col
       rate = ratea
       error = errora
       chi2 = chia
   ENDIF 
   IF (color EQ 2) THEN BEGIN 
       time = time_col
       rate = rateb
       error = errorb
       chi2 = chib
   ENDIF 
   IF (color EQ 3) THEN BEGIN 
       time = time_col
       rate = ratec
       error = errorc
       chi2 = chic
   ENDIF 
   ;;
   ;; reset arrays
   minchan=0
   maxchan=0
   
   ;;
   ;; Select dwells for max. chi^2 value
   ;;
   IF (n_elements(maxchi2) NE 0) THEN BEGIN 
       IF (color NE 4) THEN BEGIN 
           ndx=where(chi2 LE maxchi2)
           IF (ndx[0] NE -1) THEN BEGIN 
               time=time(ndx)
               rate=rate(ndx)
               error=error(ndx)
               chi2=chi2(ndx)
               expt=expt(ndx)
               ssc=ssc(ndx)
           ENDIF ELSE BEGIN 
               message,'No solutions better than maxchi2 found'
           ENDELSE 
       ENDIF ELSE BEGIN 
           ndx=where(chi2 LE maxchi2)
           IF (ndx[0] NE -1) THEN BEGIN 
               time=time(ndx)
               rate=rate(ndx)
               error=error(ndx)
               chi2=chi2(ndx)
           ENDIF ELSE BEGIN 
               message,'No (total) solutions better than maxchi2 found'
           ENDELSE 
           ndx=where(chia LE maxchi2 and chib LE maxchi2 and chic LE maxchi2)
           IF (ndx[0] NE -1) THEN BEGIN 
               time_col=time_col(ndx)
               ;;     
               ratea=ratea(ndx)
               errora=errora(ndx)
               chia=chia(ndx)
               ;; 
               rateb=rateb(ndx)
               errorb=errorb(ndx)
               chib=chib(ndx)
               ;; 
               ratec=ratec(ndx)
               errorc=errorc(ndx)
               chic=chic(ndx)
               ;;
           ENDIF ELSE BEGIN 
               message,'No (color) solutions better than maxchi2 found'
           ENDELSE 
       ENDELSE 
   ENDIF  
   ;;
   ;; Select dwells for min. chi^2 value
   ;;
   IF (n_elements(minchi2) NE 0) THEN BEGIN 
       IF (color NE 4) THEN BEGIN 
           ndx=where(chi2 GE minchi2)
           IF (ndx[0] NE -1) THEN BEGIN 
               time=time(ndx)
               rate=rate(ndx)
               error=error(ndx)
               chi2=chi2(ndx)
               expt=expt(ndx)
               ssc=ssc(ndx)
           ENDIF ELSE BEGIN 
               message,'No solutions better than minchi2 found'
           ENDELSE 
       ENDIF ELSE BEGIN 
           ndx=where(chi2 GE minchi2)
           IF (ndx[0] NE -1) THEN BEGIN 
               time=time(ndx)
               rate=rate(ndx)
               error=error(ndx)
               chi2=chi2(ndx)
           ENDIF ELSE BEGIN 
               message,'No (total) solutions better than minchi2 found'
           ENDELSE 
           ndx=where(chia GE minchi2 and chib GE minchi2 and chic GE minchi2)
           IF (ndx[0] NE -1) THEN BEGIN 
               time_col=time_col(ndx)
               ;;     
               ratea=ratea(ndx)
               errora=errora(ndx)
               chia=chia(ndx)
               ;; 
               rateb=rateb(ndx)
               errorb=errorb(ndx)
               chib=chib(ndx)
               ;; 
               ratec=ratec(ndx)
               errorc=errorc(ndx)
               chic=chic(ndx)
               ;;
           ENDIF ELSE BEGIN 
               message,'No (color) solutions better than maxchi2 found'
           ENDELSE 
       ENDELSE 
   ENDIF  
   ;;
   ;; Select dwells for exp. time (only for color=0)
   ;;
   IF (n_elements(exptime) NE 0) THEN BEGIN 
       IF (color EQ 0) THEN BEGIN 
           ndx=where( expt EQ 90.)
           IF (ndx[0] NE -1) THEN BEGIN 
               time=time(ndx)
               rate=rate(ndx)
               error=error(ndx)
               chi2=chi2(ndx)
               expt=expt(ndx)
               ssc=ssc(ndx)
           ENDIF ELSE BEGIN 
               message,'No solutions better than maxchi2 found'
           ENDELSE 
       ENDIF 
   ENDIF  
   ;;
   ;; Select dwells for ssc number (only for color=0)
   ;;
   IF (n_elements(ssc_n) NE 0) THEN BEGIN 
       IF (color EQ 0) THEN BEGIN 
           ndx=where( ssc EQ ssc_n)
           IF (ndx[0] NE -1) THEN BEGIN 
               time=time(ndx)
               rate=rate(ndx)
               error=error(ndx)
               chi2=chi2(ndx)
               expt=expt(ndx)
               ssc=ssc(ndx)
           ENDIF ELSE BEGIN 
               message,'No solutions better than maxchi2 found'
           ENDELSE 
       ENDIF 
   ENDIF  

   ;;
   ;; Object right ascension and declination in degrees
   ;;
   head=headfits(filename_lc)
   ra_obj  = 0.
   dec_obj = 0.
   getpar,head,'RA_OBJ',ra_obj
   getpar,head,'DEC_OBJ',dec_obj
   
   ;;
   ;; Return date as MJD
   ;;
   IF (keyword_set(mjd)) THEN BEGIN 
       mjdrefi=0.d0
       mjdreff=0.d0
       head=headfits(filename_lc)
       getpar,head,'MJDREFI',mjdrefi
       getpar,head,'MJDREFF',mjdreff
       getpar,head,'RA_OBJ',ra_degrees
       getpar,head,'DEC_OBJ',dec_degrees
       time = time+double(mjdreff)
       time = time+double(mjdrefi)
       IF (color EQ 4) THEN BEGIN 
           time_col = time_col+double(mjdreff)
           time_col = time_col+double(mjdrefi)
       ENDIF 
   ENDIF 
   
  
   ;;
   ;; Perform light-curve selection if desired
   ;;
   IF (n_elements(tstart) EQ 0) THEN tstart=min(time)
   IF (n_elements(tend) EQ 0) THEN tend=max(time)
   
   ndx=where(time GE tstart AND time LE tend)
   time=time(ndx)
   rate=rate(ndx)
   error=error(ndx)
   chi2=chi2(ndx)
   expt=expt(ndx)

   IF (color EQ 4) THEN BEGIN 
       ndx=where(time_col GE tstart AND time_col LE tend)
       time_col = time_col(ndx)
       ;;
       ratea=ratea(ndx)
       errora=errora(ndx)
       chia=chia(ndx)
       ;; 
       rateb=rateb(ndx)
       errorb=errorb(ndx)
       chib=chib(ndx)
       ;; 
       ratec=ratec(ndx)
       errorc=errorc(ndx)
       chic=chic(ndx)
       ;; 
   ENDIF 
             
END 




