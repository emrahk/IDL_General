PRO TRIPP_MONITOR,filename,$
                  dt=dt,x=x,y=y,zrange=zrange,shade3=shade3,reduced=reduced, $
                  colortable=colortable, LO=lo, HI=hi, XMAX=xmax, YMAX=ymax, $
                  title=title, window=window, silent=silent, $
                  quicklook=quicklook, mouse=mouse, film=film
;+
; NAME:                  
;                        TRIPP_MONITOR
;
;
;
; PURPOSE:               
;                        monitor incoming frames (can handle original
;                        or reduced frames automatically, and may be
;                        started by specifying either the first image
;                        filename or a logFile as usual) 
;                        do a quick reduction if desired (see  restrictions)
;
;
; CATEGORY:              
;                        image display; waits for the subsequent image
;                        which may not exist yet
;
;
;
; CALLING SEQUENCE:      
;                        TRIPP_MONITOR,filename[,dt=dt,x=x,y=y,zrange=zrange,/shade3,/reduced,
;                                   colortable=colortable, LO=lo, HI=hi, XMAX=xmax, YMAX=ymax,
;                                   title=title,window=window,silent=silent,
;                                   quicklook=quicklook,mouse=mouse]
;                                   
;
;
;
; INPUTS:                
;                        filename: name of first image in a row of
;                                  frames to display subsequently,
;                                  HAS to include the correct path
;                                  information, OR
;                        filename: may also be the name of a logFile instead
;
;
;
; OPTIONAL INPUTS:       
;                        dt      : wait time between two checks for
;                                  new frames 
;                        x       : x coordinate for xyout of image
;                                  identifier 
;                        y       : y coordinate for xyout of image
;                                  identifier 
;                        zrange  : zrange to be displayed if /shade3
;                                  is set; else ignored
;                        colortable: value for colortable, defaulted
;                                  to 3 (Red temperature)
;                        several tripp_tv optional inputs (ignored if
;                                  /shade3 is set)
;                       
;
;
; KEYWORD PARAMETERS:    
;                        /shade3 : use tripp_shade3 routine for
;                                  display instead of ccd_tv 
;                        /reduced: necessary with use of LOGfile if         
;                                  reduced images are to be displayed;
;                                  ignored if first FITS file is
;                                  specified (reduced or not) 
;                        several tripp_tv keyword parameters (ignored if
;                                  /shade3 is set)
;                        /quicklook: starts a minimal reduction; a
;                                  logfile and a maskfile have to
;                                  exist for this; can only be called
;                                  with a logfile, not a filename 
;                        /window:  specifies the first window used,
;                                  quicklook adds one more if set 
;                        /silent:  handed down to tripp_tv
;                        /silent:  handed down to tripp_reduction but
;                                  NOT tripp_calc_relflux or
;                                  tripp_write_final  
;
;
;
;
; OUTPUTS:               
;                        display of the current image on the screen 
;
;
;
; OPTIONAL OUTPUTS:      
;                        results of the quicklook reduction
;                        (see tripp_reduction, tripp_extract_flux,
;                        tripp_calc_relflux, tripp_write_final) 
;
;
;
; COMMON BLOCKS:         
;                        none
;
;
;
; SIDE EFFECTS:          
;                        can only be stopped by ^C
;   
;                        stops whereever procedure has been
;                        interrupted, which is not in $MAIN$   
;                        * get back to $MAIN$ with RETALL *
;
;                        leaves the current window open,
;                        two if quicklook is set
;   
;
; RESTRICTIONS:          
;                        Filenames must be numbered subsequently and
;                        must be of the form
;                        imageidentifier_XXXX.fits                 or
;                        imageidentifier_XXXX_reduced.fits         or 
;                        imageidentifier_XXXX?.fits 
;
;                        filename may contain path information as well
;
;                        last image is never displayed
;
;                        quicklook only works with a logfile, and
;                        additionally a maskfile has to exist,too
;
; PROCEDURE:             
;                        TRIPP_SHADE3
;                        TRIPP_TV
;                        READFITS
;
;
; EXAMPLES:              
;                        tripp_monitor,'hs2201_0026.fits',/shade3,dt=2
;                        tripp_monitor,'../Nov01_reduced/hs2201_0026_reduced.fits'   
;                        tripp_monitor,'HS0233_Nov04.log'
;                        tripp_monitor,'HS0233_Nov04.log',/reduced
;
;
; MODIFICATION HISTORY:
;                        Version 1.0 1999/11 Stefan Dreizler and Sonja L. Schuh  
;                        Version 1.1 2001/01 SLS: merged several functionalities
;                                    2001/02 SLS: - colortable parameter added
;                                                   - added all tripp_tv keywords
;                                    2001/05 SLS: handling of BUSCA
;                                                 filenames, a few
;                                                 preparations for quicklook 
;                                    2001/05 SLS: quicklook is ready
;                        Version 1.8 2001/07 SLS: refinements to
;                                                 quicklook, including /mouse keyword
;                                                 and (NEW) internal recycling;
;                                                 crude version of film option
;-

;; ---------------------------------------------------------
;; --- DEFAULTS ---
;;
   
;   on_ioerror,io_error   ;; testing for type conversion fails if set!!!
   on_error,2

   IF NOT exist (dt) THEN dt = 10
   IF NOT exist (x)  THEN  x = 50
   IF NOT exist (y)  THEN  y = 50
   IF NOT exist (zrange) THEN  zrange = [0,50000]
   IF NOT exist (title)  THEN   title = 'TRIPP Monitor'
   IF NOT exist (window) THEN   window = 0 
   IF NOT EXIST(xmax) then xmax=700.0d0 else xmax=double(xmax)
   IF NOT EXIST(ymax) then ymax=700.0d0 else ymax=double(ymax)
   offset=4
   
;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
   punkt=strpos(strtrim(filename,2),'.log')
   IF punkt NE -1 THEN BEGIN
     logname=filename
     TRIPP_READ_IMAGE_LOG, filename, log
     IF log.instrument EQ "BUSCA" THEN offset=5
     filename=STRTRIM( log.in_path, 2 ) + '/' + STRTRIM( log.first, 2 )
     IF KEYWORD_SET(reduced) THEN BEGIN
       filename = STRTRIM( log.out_path, 2 ) + '/' + $
         STRMID(  log.first, 0, log.nr_pos +offset ) + '_reduced.fits'
     ENDIF
   ENDIF
   
;; ---------------------------------------------------------
;; --- EXTRACT THE PARTS OF THE FILENAME THAT WILL BE NEEDED
;;
   
   length = strlen(strtrim(filename,2))
   punkt = strpos(strtrim(filename,2),'.fits')
   reduced=strpos(strtrim(filename,2),'_reduced.fits')    
   IF reduced NE -1 THEN punkt=reduced
   IF punkt EQ -1 THEN BEGIN
     PRINT,'% TRIPP_MONITOR ERROR: Filename has to have either a ".fits" or a ".log" extension.'
     PRINT,'%                      Exiting program now.'       
     return
   ENDIF
   IF fix(STRMID( strtrim(filename,2),punkt-1,1 )) EQ 0 AND $
     strtrim(string(fix(STRMID( strtrim(filename,2),punkt-1,1 ))),2) NE $
     STRMID( strtrim(filename,2),punkt-1,1 ) THEN BEGIN
     offset=5
     inbetween=STRMID( strtrim(filename,2),punkt-1,1 )
   ENDIF ELSE inbetween=""
   nummer1 = fix(strmid(strtrim(filename,2),punkt-offset,4))
   nummer2 = nummer1 + 1
   prefix =strmid(strtrim(filename,2),0,length-5-offset)
   IF reduced NE -1 THEN prefix =strmid(strtrim(filename,2),0,length-13-offset)

;; ---------------------------------------------------------
;; --- BIG LOOP
;;
   REPEAT BEGIN
       cnummer1 = strtrim(string(nummer1),2)
       cnummer2 = strtrim(string(nummer2),2)
       lengthc1 = strlen(cnummer1)
       lengthc2 = strlen(cnummer2)

io_error:
       
       
       ;; --- original data files
       IF reduced EQ -1 THEN BEGIN
           CASE lengthc1 OF 
               1: filename1 = prefix+'000'+cnummer1+inbetween+'.fits'
               2: filename1 = prefix+'00' +cnummer1+inbetween+'.fits'
               3: filename1 = prefix+'0'  +cnummer1+inbetween+'.fits'
               4: filename1 = prefix      +cnummer1+inbetween+'.fits'
               ELSE: PRINT,'% TRIPP_MONITOR: Problem with counter ...'
           ENDCASE
           CASE lengthc2 OF 
               1: filename2 = prefix+'000'+cnummer2+inbetween+'.fits'
               2: filename2 = prefix+'00' +cnummer2+inbetween+'.fits'
               3: filename2 = prefix+'0'  +cnummer2+inbetween+'.fits'
               4: filename2 = prefix      +cnummer2+inbetween+'.fits'
               ELSE: PRINT,'% TRIPP_MONITOR: Problem with counter ...'
           ENDCASE
       ;; --- reduced data files
       ENDIF ELSE BEGIN
           CASE lengthc1 OF 
               1: filename1 = prefix+'000'+cnummer1+inbetween+'_reduced.fits'
               2: filename1 = prefix+'00' +cnummer1+inbetween+'_reduced.fits'
               3: filename1 = prefix+'0'  +cnummer1+inbetween+'_reduced.fits'
               4: filename1 = prefix      +cnummer1+inbetween+'_reduced.fits'
               ELSE: PRINT,'% TRIPP_MONITOR: Problem with counter ...'
           ENDCASE
           CASE lengthc2 OF 
               1: filename2 = prefix+'000'+cnummer2+inbetween+'_reduced.fits'
               2: filename2 = prefix+'00' +cnummer2+inbetween+'_reduced.fits'
               3: filename2 = prefix+'0'  +cnummer2+inbetween+'_reduced.fits'
               4: filename2 = prefix      +cnummer2+inbetween+'_reduced.fits'
               ELSE: PRINT,'% TRIPP_MONITOR: Problem with counter ...'
           ENDCASE
       ENDELSE
       

       
       ;; --- check whether subsequent frame exists
       result = findfile(filename2,count=count)
       
       slash_sep   = STR_SEP( STRTRIM( STRCOMPRESS(filename1),2),'/')
       filename1cut = slash_sep[n_elements(slash_sep)-1]

       ;; --- display subsequent frame or keep waiting
       IF (count eq 1) THEN BEGIN

         nummer1 = nummer1 + 1
         nummer2 = nummer2 + 1
         PRINT,'% TRIPP_MONITOR Image ready to display: ',filename1
         image = READFITS(filename1,h,silent=silent)
         ;; --- display first image differently
         IF NOT exist(testforfirstimage) THEN BEGIN
           IF NOT KEYWORD_SET(colortable) THEN colortable=3
           IF KEYWORD_SET(quicklook) THEN BEGIN
             window,window+1,xsize=xmax,ysize=ymax/2.,title='Lightcurve'
             wset,window
           ENDIF
           IF NOT keyword_set(shade3) THEN BEGIN
             tripp_tv,image,colortable=colortable, LO=lo, HI=hi, XMAX=xmax, YMAX=ymax, $ 
                  title=title, window=window, silent=silent
           ENDIF ELSE tripp_shade3,image,zrange=zrange,nlevels=10,ax=10
           loadct,colortable
           xyouts,x,y,filename1cut
         ENDIF
         testforfirstimage=1
         ;; --- TV image / shade_surf image
         wset,window
         IF NOT keyword_set(shade3) THEN BEGIN
           tripp_tv,image, /nowin, silent=silent
;           tripp_tv,image, silent=silent ;; may be necesssary for Calar Alto
         ENDIF ELSE tripp_shade3,image,zrange=zrange,nlevels=10,ax=10
         xyouts,x,y,filename1cut
         
         ;; ---------------------------------------------------------
         ;; --- "QUICKLOOK" OPTION
         ;;
         IF KEYWORD_SET(quicklook) THEN BEGIN
           IF EXIST(logname) THEN BEGIN
             oldnr=log.nr
             ;; --- new log.last 
             log.last = filename1cut
             ;; --- derive what is needed from log.last 
             lnumber  = STRMID( log.last, log.nr_pos, 4)
             log.nr   = lnumber - log.offset
             IF log.nr GE oldnr THEN BEGIN
               IF log.nr LT 1 THEN BEGIN
                 print,"                     "
                 print,"% TRIPP_MONITOR: Warning: The total number of images is less than 1," 
                 print,"                 maybe the filenames have a structure that TRIPP can't handle."
                 print,"                 Please think up something or TRIPP_REDUCTION will fail to work."
               ENDIF 
               ;; --- re-write logFile
               GET_LUN, unit
               OPENW, unit, logname
               FOR I = 0, N_TAGS(log) - 1 DO BEGIN
                 PRINTF, unit, log.(I)
               ENDFOR
               FREE_LUN, unit
               print,"% TRIPP_MONITOR: Logfile entries have been updated to include the current image."
             ENDIF ELSE TRIPP_READ_IMAGE_LOG, logname, log
             ;; --- do minimal reduction
             tripp_reduction,   logname,/silent,/recycle,mouse=mouse
             tripp_extract_flux,logname,/silent,/recycle
             tripp_calc_relflux,logname,/silent
             wset,window+1
             tripp_write_final, logname,/silent
             IF nummer1 LT (log.nr + log.offset + 1) THEN BEGIN  ;; NEW !!!
               nummer1 = log.nr + log.offset + 1 
               nummer2 = nummer1 + 1             
             ENDIF                                               ;; END NEW

           ENDIF ELSE BEGIN
             PRINT,'% TRIPP_MONITOR Sorry, quicklook option only works with a logfile!'
           ENDELSE
         ENDIF
         ;; --- END "QUICKLOOK" PART
         
       ENDIF ELSE BEGIN
         PRINT,'% TRIPP_MONITOR no new file: ',filename2
       ENDELSE
       
       ;; ---------------------------------------------------------
       ;; --- "FILM" OPTION
       ;;
;
;       additionally use _intup.fits for scaling ? 
;       problem: then also need position informations!
;
       IF KEYWORD_SET(film) THEN BEGIN
;           saveimage,filename1+".gif"
;           PRINT, "  "
;           PRINT, "Please run the following commands on console at the end: "
;           PRINT, "  "
;           PRINT, " nice -15 convert -delay 2 "+prefix+"*"+inbetween+"*.fits.gif "+$
;                                                prefix+"_"+inbetween+"_film.gif"
;           PRINT, " nice -15 \rm -f "+prefix+"*"+inbetween+"*.fits.gif "
;           PRINT, "  "
         PRINT, " FILM OPTION CURRENTLY NOT AVAILABLE! "
       ENDIF
;       
;
;      ;; --- Needs to be changed to png or something; however whether animated pngs
;             do exist at all and if so whether they can be produced with
;             convert will have to be investigated. In any case, the
;             FILM option is not necessary to run this program so that
;             can wait until someone really wants it. 

        wait,dt
       
     ENDREP UNTIL (1 EQ 0)


     
;; ---------------------------------------------------------
;; --- END
;;
     stop
END






