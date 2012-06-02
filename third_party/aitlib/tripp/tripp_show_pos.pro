PRO TRIPP_SHOW_POS, logname,stop=stop
;+
; NAME:     
;           TRIPP_SHOW_POS
;
;
; PURPOSE:  
;           Display contents of pos file and edit if desired
;
;
;
;
;
; CATEGORY:
;       Astronomical Photometry.
;
; CALLING SEQUENCE:
;       TRIPP_SHOW_POS, logname
;
; INPUTS:
;       Old pos file
; OUTPUTS:
;       New pos file
;
; REVISION HISTORY:
;
;       Version 1.0, 2000/11   , Sonja L. Schuh
;                    2001/02   , SLS, added interactivity            
;                    2001/02   , SLS, added messages
;                    2001/05   , SLS, switched to 
;                                tripp_read/write_pos 
;-
   
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs

  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_POS:  No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_POS:        The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_SHOW_POS:        Using Logfile ', logname 
    ENDIF
  ENDELSE

   ;; ---------------------------------------------------------
   ;; --- READ IN LOG FILE ---
   ;;
   TRIPP_READ_IMAGE_LOG, logName, log
   
   ;; ---------------------------------------------------------
   ;; --- READ POSITION REFERENCE FILE ---
   ;;
   TRIPP_READ_POS, log, files, rx, ry, start, silent=silent
   
   ;; --- find and print out problematic position points
   ind = WHERE(rx EQ -1. OR ry EQ -1.)
   IF n_elements(ind) GT 1  THEN BEGIN
       index=9999
       print,"% TRIPP_SHOW_POS: Position equals -1.00000 in ",$
         STRTRIM(STRING(n_elements(ind)),2)," cases:"
       print,ind+log.offset+1
   ENDIF ELSE BEGIN
       index=ind(0)
       IF (index NE -1.) THEN  BEGIN
           print,"% TRIPP_SHOW_POS: Position equals -1.00000 in ",$ 
             STRTRIM(STRING(n_elements(ind)),2)," case:"
           print,index+log.offset+1
       ENDIF ELSE print,"% TRIPP_SHOW_POS: No positions equals -1.00000 found, "
                  print,"                  but you may want to do some editing anyways ..."
   ENDELSE
   
   
   
   ;; ---------------------------------------------------------
   ;; --- CHANGE POSITION REFERENCE FILE ---
   ;;
   
   ;; --- first plot
   loadct,39
   WINDOW,0,title="Reference star positions"
   xrange=[min(rx)-(max(rx)-min(rx))/4.,max(rx)+(max(rx)-min(rx))/4.]
   yrange=[min(ry)-(max(ry)-min(ry))/4.,max(ry)+(max(ry)-min(ry))/4.]
   plot,rx,ry,psym=1,xstyle=1,ystyle=1,xrange=xrange,yrange=yrange
   IF (index NE -1.) THEN  xyouts,0,0,n_elements(ind),/data
   
   ;; --- stop if desired
   IF KEYWORD_SET(stop) THEN BEGIN
       PRINT, ''
       PRINT, '% TRIPP_SHOW_POS: Type ".cont " to proceed to interactive positioning,' 
       PRINT, '                  or   "return" to return to $MAIN$ level'
       PRINT, ''
       stop
   ENDIF
   
   ;; --- begin editing loop
   PRINT, ''
   PRINT, '% TRIPP_SHOW_POS: Grab point to move to new position:     click left' 
   PRINT, '% TRIPP_SHOW_POS: or Exit                           :     click right' 
   cursor,xx,yy,/data
   wait,0.5
   mouse=!mouse.button
   
   WHILE mouse EQ 1 DO BEGIN       
       
       ;; --- nearest point (choose one)
       diff = ((rx-xx)/xx)^2 + ((ry-yy)/yy)^2
       grab=where(diff EQ min(diff))
       grabbed=intarr(1)
       grabbed[0]=grab[0]
       
       ;; --- mark grabbed point in plot
       plot,rx,ry,psym=1,xstyle=1,ystyle=1,xrange=xrange,yrange=yrange
       IF (index NE -1.) THEN  xyouts,0,0,n_elements(ind),/data
       oplot,rx[grabbed],ry[grabbed],psym=1,symsize=3,color=60
       oplot,rx[grabbed-1],ry[grabbed-1],psym=4,symsize=2,color=120
       oplot,rx[grabbed+1],ry[grabbed+1],psym=4,symsize=2,color=120
       
       PRINT, ''
       PRINT, ''
       PRINT, ''
       PRINT, ''
       PRINT, ''
       PRINT, ''
       PRINT, ' Grabbed point is # '+strtrim(string(grabbed+log.offset+1),2)+'               '+$
              '                    +'
       PRINT, ''
       PRINT, '                  # '+strtrim(string(grabbed-1+log.offset+1),2)+$
         ' is at  '+strtrim(string(rx[grabbed-1]),2)+'   '+strtrim(string(ry[grabbed-1]),2)+$
         '      /\'
       PRINT, '                  # '+strtrim(string(grabbed+1+log.offset+1),2)+$
         ' is at  '+strtrim(string(rx[grabbed+1]),2)+'   '+strtrim(string(ry[grabbed+1]),2)+$
         '      \/'
       PRINT, ''
       PRINT, ''
       PRINT, '% TRIPP_SHOW_POS: Drop grabbed point at new position:     click left' 
       PRINT, '% TRIPP_SHOW_POS: or Abort but try again            :     click middle'  
       PRINT, '% TRIPP_SHOW_POS: or Exit                           :     click right' 
       cursor,xx,yy,/data
       wait,0.5
       mouse=!mouse.button
       
       CASE mouse OF
           1: BEGIN
               rx[grabbed]=xx
               ry[grabbed]=yy
               ind = WHERE(rx EQ -1. OR ry EQ -1.) ;new
               IF ind(0) EQ -1 THEN BEGIN
                   index=-1.
               ENDIF
               xrange=[min(rx)-(max(rx)-min(rx))/4.,max(rx)+(max(rx)-min(rx))/4.]
               yrange=[min(ry)-(max(ry)-min(ry))/4.,max(ry)+(max(ry)-min(ry))/4.]

               
               ;; --- make new plot after point has been dropped 
               plot,rx,ry,psym=1,xstyle=1,ystyle=1,xrange=xrange,yrange=yrange
               IF (index NE -1.) THEN  xyouts,0,0,n_elements(ind),/data
               oplot,rx[grabbed],ry[grabbed],psym=1,symsize=3,color=60
               
               PRINT, ''
               PRINT, ''
               PRINT, ''
               PRINT, ''
               PRINT, ''
               PRINT, ''
               PRINT, '% TRIPP_SHOW_POS: Grab point to move to new position:     click left' 
               PRINT, '% TRIPP_SHOW_POS: or Exit                           :     click right' 
               cursor,xx,yy,/data
               wait,0.5
               mouse=!mouse.button
           END
           4:  BEGIN
               PRINT, ''
               PRINT, '% TRIPP_SHOW_POS: exiting ...'
           END   
           2: BEGIN
               plot,rx,ry,psym=1,xstyle=1,ystyle=1,xrange=xrange,yrange=yrange
               IF (index NE -1.) THEN  xyouts,0,0,n_elements(ind),/data
               PRINT, ''
               PRINT, '% TRIPP_SHOW_POS: Grab point to move to new position:     click left' 
               PRINT, '% TRIPP_SHOW_POS: or Exit                           :     click right' 
               cursor,xx,yy,/data
               wait,0.5
               mouse=!mouse.button
           END   
       ENDCASE
       
   END
   
   ;; --- stop if desired
   IF KEYWORD_SET(stop) THEN BEGIN
       PRINT, ''
       PRINT, '% TRIPP_SHOW_POS: Type ".cont " to save the current data to the position file,' 
       PRINT, '                  or   "return" to return to $MAIN$ level'
       PRINT, ''
       stop
   ENDIF
   
   ;; ---------------------------------------------------------
   ;; --- WRITE NEW POSITION REFERENCE FILE ---
   ;;
   TRIPP_WRITE_POS, log, files, rx, ry, posfile, silent=silent
   
   PRINT, ' '
   PRINT, '% TRIPP_SHOW_POS: Reference star positions saved in ', posFile
   PRINT, '% ==========================================================================================='
PRINT, ' '

wdelete

END







