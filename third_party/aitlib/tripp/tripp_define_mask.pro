PRO TRIPP_DEFINE_MASK, logname, no_cntrd=no_cntrd, cut=cut, no_intup=no_intup
;+
; NAME:
;	TRIPP_DEFINE_MASK 
;
; PURPOSE:   
;	Create and store aperture pattern for automatic CCD
;	time series reduction. Aperture file is used in TRIPP_EXTRACT_FLUX.
;	Click on same position reference source as used in TRIPP_REDUCTION.
;       For each source selected, six background regions will be defined.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	TRIPP_DEFINE_MASK, logname
;
; INPUTS:
;       logName : Name of reduction log file
;   
; OPTIONAL KEYWORDS:
;           no_cntrd : prevent centering of reference star
;           cut      : defines rejection of background fields
;           intup    : uses intup image from previous an previous run
;                      instead of first image
;
; OUTPUTS:
;	Aperture mask, saved in <mask_name>
;
; REVISION HISTORY:
;       Version 1.0, 1996      , Ralf Geckeler -- CCD_MASK
;       Version 2.0, 1999/02/06, Jochen Deetjen
;       Version 2.1  1999/12   , Stefan Dreizler no_cntrd and 
;                                  selected rejection of background fields added
;       Version 2.1  2001/01   , S.L. Schuh, change image to
;                                  long(image) after READFITS
;       Version 2.2  2001/01   , S.L. Schuh, background fields may now
;                                  be moved around by mouse clicks;
;                                  affilated fields are being
;                                  identified through color encoding
;       Version 2.2  2001/02   , S.L. Schuh, extraction radii are
;                                  being, shown, too 
;                    2001/02   , SLS, added messages
;                    2001/02   , SLS, added no_intup keyword
;                    2001/05   , SLS, force consistency with existing
;                                pos file
;                                undone: SLS, enable display of image with
;                                negative values
;                    2001/05   , SLS, switched to tripp_read_pos  
;        Version 2.3 2001/07   , EG,  replaced background mask definition 
;                                      algorithm with a more user friendly one.
;        Version 2.4 2001/07   , SLS, obsoleted call to CCD_APP
;
;
;-
  
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs

  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_DEFINE_MASK:     No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_DEFINE_MASK:     The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_DEFINE_MASK:     Using Logfile ', logname 
    ENDIF
  ENDELSE

IF NOT EXIST(no_cntrd) THEN no_cntrd = 0
IF NOT EXIST(cut)      THEN cut      = 'top'
IF NOT EXIST(no_intup) THEN intup=1 ELSE intup=0
   
;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log


;; ---------------------------------------------------------
;; --- DEFINITIONS ---
;;
hside     = FIX( log.mask_bw /2.0d0 )

sx        = FLTARR(log.mask_nrs)
sy        = FLTARR(log.mask_nrs)
sname     = STRARR(log.mask_nrs)
bx        = FLTARR(log.mask_nrs,6)
by        = FLTARR(log.mask_nrs,6)
back_posx = FLTARR(8)
back_posy = FLTARR(8)
back_sum  = FLTARR(8)


;; ---------------------------------------------------------
;; --- GET POSITION REFERENCE STAR
;;
PRINT, ' '
PRINT, '%==========================================================================================='
PRINT, '% TRIPP_DEFINE_MASK: Definition of extraction Mask'
PRINT, ' '
maskFile = STRTRIM( log.in_path, 2 ) + '/' + STRTRIM( log.first, 2 )
IF KEYWORD_SET(intup) THEN BEGIN
  testFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM(log.block, 2 )+'_intup.fits'
  result2  = findfile(testFile,count=count2)
  IF count2 EQ 1 THEN maskFile=testfile
ENDIF
PRINT, '% TRIPP_DEFINE_MASK: Reading reference image '+maskFile
image    = READFITS( maskFile, header )
image    = long(image)

TRIPP_TV, image, xmax=700, ymax=700, title="Definition of the extraction mask"
PRINT, ' '
PRINT, '% TRIPP_DEFINE_MASK: FIRST SOURCE IS THE POSITION REFERENCE STAR!'


;; --- get image size
;;
isize  = SIZE(image)
ixl    = 0
ixh    = isize[1] -1 
iyl    = 0
iyh    = isize[2] -1

;; ---------------------------------------------------------
;; --- READ POSITION REFERENCE FILE IF IT EXISTS
;;
posfile=STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.pos, 2 )
result=findfile(posfile,count=count)
IF count NE 0 THEN BEGIN
  TRIPP_READ_POS, log, files, rx, ry, start, silent=silent
  xpos = rx[0]
  ypos = ry[0]
  oplot, [xpos+0.5],[ypos+0.5], psym=1, symsize=5, color=0
  xyouts,xpos,ypos,'  Ref 1',color=100, CHARSIZE=2, CHARTHICK=3
ENDIF


;; ---------------------------------------------------------
;; --- GET POSITION OF ALL SOURCES
;;
PRINT, ' '
PRINT, '% TRIPP_DEFINE_MASK: Get position of all sources'
PRINT, '% TRIPP_DEFINE_MASK: Left mouse click   : Find source'
PRINT, '% TRIPP_DEFINE_MASK: Middle mouse click : Accept source'

FOR i = 0, log.mask_nrs-1 DO BEGIN
    
    ;; --- ECHO SOURCE NUMBER
    ;;
    PRINT, " "
    PRINT, "% TRIPP_DEFINE_MASK: Source #" + STRTRIM( STRING(i+1),2 )
    
    
    ;; --- GET SOURCE POSITION
    ;;
    REPEAT BEGIN
        cursor, x, y, /DATA
        mouse = !err
        wait,0.5
        IF (mouse EQ 1) THEN BEGIN  
            ;; --- +0.5 -> pixel center
            IF no_cntrd EQ 0 THEN   $
              CCD_CNTRD, image, x, y, xcen, ycen, log.mask_sr
            IF no_cntrd NE 0 THEN BEGIN
                xcen = x
                ycen = y
            ENDIF
            oplot, [xcen+0.5],[ycen+0.5], psym=1, symsize=5, color=0
        ENDIF
        
        ;; --- PRINT maximal intensitiy of selected source
        ;;
        PRINT, "% TRIPP_DEFINE_MASK: Maximal intensity of selected source: ", $
          STRTRIM( STRING(image(xcen,ycen)),2 )
        
    ENDREP UNTIL ((xcen NE -1) AND (mouse EQ 2))

    sx[i]    = xcen
    sy[i]    = ycen
    sname[i] = "Ref " + STRTRIM( STRING(i+1),2 )
    

    ;; --- CALCULATE AND PLOT EXTRACTION RADII
    ;;
    rad    = DOUBLE( log.extr_minr ) + $
      DINDGEN( log.extr_nrr ) / DOUBLE( log.extr_nrr ) * $
      (DOUBLE( log.extr_maxr ) - DOUBLE( log.extr_minr ))
    FOR r = 0, log.extr_nrr-1 DO BEGIN
      IF float(rad[r]) EQ float(log.relflx_sr) THEN BEGIN
        thick=3
        color=0
      ENDIF ELSE BEGIN
        thick=1
        color=100
      ENDELSE
      TRIPP_QUAD, rad[r], sx[i], sy[i],/circ, thick=thick, color=color
    ENDFOR
    
    ;; --- PLOT SOURCE NAME
    ;;
    XYOUTS, sx[i], sy[i], '  ' + sname[i], $
      charsize=2, charthick=3

    ;; --- CALCULATE 8 BACKGROUND REGIONS AROUND EACH SOURCE ---
    ;; --- THEY ARE ARRANGED CLOCKWISE AROUND EACH SOURCE
    ;;
    FOR j = 0, 7 DO BEGIN
        
        sph     = [45.0*j, log.mask_dist]
        rect    = CV_COORD( from_polar=sph, /to_rect, /degrees)  
        back_posx[j] = FIX(xcen + rect[0])
        back_posy[J] = FIX(ycen + rect[1])
        
        IF ( (back_posx[j]-hside) LT ixl ) THEN back_posx(j) = FIX(hside+2)
        IF ( (back_posx[j]+hside) GT ixh ) THEN back_posx(j) = FIX(ixh-hside-2)
        IF ( (back_posy[j]-hside) LT iyl ) THEN back_posy(j) = FIX(hside+2)
        IF ( (back_posy[j]+hside) GT iyh ) THEN back_posy(j) = FIX(iyh-hside-2)
        
        back_sum[j] = TOTAL( image[ back_posx[j]-hside:back_posx[j]+hside, $
                                    back_posy[j]-hside:back_posy[j]+hside ] )
        
    ENDFOR
    
    ;; --- SELECT 6 OF 8 BACKGROUNDS FOR FINAL REDUCTION ---
    ;; --- CRITERIA: LOW INTENSITY --> REJECT FIELDS CONTAINING A STAR ---
    ;;
    bidx      = SORT( back_sum )
    back_sum  = back_sum[bidx]
    back_posx = back_posx[bidx]
    back_posy = back_posy[bidx]
    

    CASE 1 OF
       CUT EQ 'top':    BEGIN
                          jlow =0
                          jhigh=5
                          joffset=0
                          PRINT, "% TRIPP_DEFINE_MASK: Reject highes two background fields"
                        END
       CUT EQ 'mid':    BEGIN
                          jlow =1
                          jhigh=6
                          joffset=1
                          PRINT, "% TRIPP_DEFINE_MASK: Reject highes and lowest background field"
                        END
       CUT EQ 'bottom': BEGIN
                          jlow =2
                          jhigh=7
                          joffset=2
                          PRINT, "% TRIPP_DEFINE_MASK: Reject lowes two background fields"
                        END
       ELSE:            BEGIN
                          PRINT, "% TRIPP_DEFINE_MASK: Keyword '",CUT,$
                            "' not allowed for parameter cut" 
                          RETURN
                          stop
                        END
    ENDCASE
    FOR j = jlow, jhigh DO BEGIN
        bx[i,j-joffset] = back_posx[j]    
        by[i,j-joffset] = back_posy[j] 
        CCD_QUAD, hside, bx[i,j-joffset], by[i,j-joffset]
    ENDFOR
    
ENDFOR


;; ---------------------------------------------------------
;; --- CHANGE BACKGROUND FIELDS ---
;;
;; implementation: 
;; - store fix image in variable by reading from window
;; - loop and wait till right mouse button pressed. 
;; - if rectangle selected (left mouse button) and moved, remove rectangle
;;   by applying stored fix image (background image) and repainting 
;;   all rectangles, even the new one at current position.
;; - store this position which at next change becomes last position of 
;;   selected rectangle
;;   eg, 23-07-2001


PRINT, ''
PRINT, ''
PRINT, "% TRIPP_DEFINE_MASK: You may now move individual background fields."
PRINT, ''

;; NUR bx, by KOENNEN ANGEFASST WERDEN!

PRINT, ''
PRINT, '% TRIPP_DEFINE_MASK: Move background field :     click left' 
PRINT, '% TRIPP_DEFINE_MASK: or exit               :     click right' 
PRINT, ''

; plot image as is:
TRIPP_TV, image, xmax=700, ymax=700, /nowin

; plot circles/description of objects:
FOR i = 0, log.mask_nrs-1 DO BEGIN
  FOR r = 0, log.extr_nrr-1 DO BEGIN
        IF float(rad[r]) EQ float(log.relflx_sr) THEN BEGIN
          thick=3
          color=0
        ENDIF ELSE BEGIN
          thick=1
          color=100
        ENDELSE
        TRIPP_QUAD, rad[r], sx[i], sy[i],/circ, thick=thick, color=color
      ENDFOR
      XYOUTS, sx[i], sy[i], '  ' + sname[i], $
         charsize=2, charthick=3
ENDFOR


; read image of currentd displayed (used for restoring changes)
baseimg=TVRD()


 ; draw all rectangular masks
FOR i = 0, log.mask_nrs-1 DO BEGIN
    FOR j = jlow, jhigh DO  BEGIN
       thick=1
       color=100

       ; display submask:
       TRIPP_QUAD, hside,bx[i,j],by[i,j], thick=thick, color=color
    ENDFOR
ENDFOR


; get first cursor position:
CURSOR,xx,yy,/data,/nowait

; state: moving mask rectangle(1), don't moving it (0)
DRAGGING=0; disabled


; rectangle size converted to device coordinates:
device_hx=(CONVERT_COORD(2*hside+10,2*hside+10,/DATA,/TO_DEVICE))[0]
device_hy=(CONVERT_COORD(2*hside+10,2*hside+10,/DATA,/TO_DEVICE))[1]


; last position of selected rectangle, to restore image when
; mouse is moved. 
; starting at lower left
last_x=device_hx
last_y=device_hy


; loop till right mouse button pressed:
WHILE !mouse.button LT 4 DO BEGIN      

  ; left mouse button pressed to start drag:
  IF !mouse.button EQ 1 AND NOT DRAGGING THEN BEGIN
  
      ; look for closest mask/submask:
      diff = ((bx-xx)/xx)^2 + ((by-yy)/yy)^2
      grabbed=WHERE(diff EQ min(diff))

      ; compute mask/submask index:
      j_coord=FIX(grabbed[0]/log.mask_nrs)
      i_coord=grabbed[0] - log.mask_nrs*(j_coord)

      ; mark start of dragging:
      DRAGGING=1
  ENDIF
	   
  ; check end of dragging: 
  ; left mouse button released
  IF !mouse.button NE 1 THEN  DRAGGING=0     
  
  
  ; when dragging -> redraw image with correct masks
  IF DRAGGING THEN BEGIN
  
     ; delete last mask rectangle:
     ; 1.) Convert last cursor position to lower left coordinate by
     ;     subtracting half of rectangle size 
     last_x=(0 > (last_x - device_hx/2))    $ ; avoid 
              < (n_elements(baseimg[*,0])   $ ; boundary exceeding errors
                - device_hx -1)
     last_y=(0 > (last_y - device_hy/2) )   $ ; for x and y position
              < (n_elements(baseimg[0,*])   $
                 - device_hy -1)
    
     ; 2.) overplot last rectangle with starting image:
     TV, baseimg[last_x:last_x+device_hx, $
                 last_y:last_y+device_hy ],last_x,last_y
     
     ; 3.) store current position -> last position, 
     ;     convert to device coordinates (pixel)
     last=CONVERT_COORD(XX,YY,/DATA,/TO_DEVICE)
     last_x=last[0]
     last_y=last[1]
     
    
     ; store current mask/submask position
     bx[grabbed]=xx
     by[grabbed]=yy        
          
     ; draw all rectangles according selected/not selected state: 
     FOR i = 0, log.mask_nrs-1 DO BEGIN
        FOR j = jlow, jhigh DO  BEGIN
    
           ; set color according selected mask group
           IF  i EQ i_coord THEN BEGIN    ; mask i was selected
              IF j EQ j_coord THEN BEGIN  ; submask j is selected:
                    thick=3
                    color=200
              ENDIF ELSE BEGIN            ; mask i selected, but not submask:
                    thick=1
                    color=0
              ENDELSE
           ENDIF ELSE BEGIN               ; mask not selected:
                    thick=1
                    color=100
           ENDELSE
    
           ; display mask/submask:
           TRIPP_QUAD, hside,bx[i,j],by[i,j], thick=thick, color=color
    
        ENDFOR
       ENDFOR    
  ENDIF ; in dragging mode
  
  ; wait for next mouse change, get x/y position in plot-units
  CURSOR,xx,yy,2,/data
      
ENDWHILE ; right mouse button not pressed



 ; Change finished -> draw all rectangular masks in a 
 ; unique manner:
TV,baseimg ; restore original image

 ; draw all rectangles: 
FOR i = 0, log.mask_nrs-1 DO BEGIN
    FOR j = jlow, jhigh DO  BEGIN
       thick=1
       color=100

       ; display submask:
       TRIPP_QUAD, hside,bx[i,j],by[i,j], thick=thick, color=color
    ENDFOR
ENDFOR
    
;; ---------------------------------------------------------
;; --- DEFINITION OF OVERSCAN AREA
;;
;;------------- is done automatically in tripp_reduction
;;
;     IF log.zero_corr EQ 'overscan' OR log.zero_corr EQ 'OVERSCAN' OR log.zero_corr EQ 'Overscan' THEN BEGIN 
;       PRINT, " "
;       PRINT, "% TRIPP_DEFINE_MASK: Sorry, the definition of the overscan area has not been implemented yet!"
;       PRINT, " "
;     ENDIF
    

;; ---------------------------------------------------------
;; --- GENERARTE POSTSCRIPT PLOT
;;
maskFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.mask, 2 )
;old:   CCD_APP(maskFile,app='mask',ext='ps')
CCD_SCREEN, STRTRIM( log.out_path, 2 ) + '/' + STRTRIM(log.block, 2 )+"_mask.ps" 



;; ---------------------------------------------------------
;; --- WARNING IN CASE OF INCONSISTENCIES WITH POS FILE 
;;
;; FORCE : test

IF count NE 0 THEN BEGIN
  xoffset=xpos-sx[0]
  yoffset=ypos-sy[0]
  IF abs(xoffset) GT 2 OR abs(yoffset) GT 2 THEN BEGIN
    PRINT, ' '
    PRINT, '% TRIPP_DEFINE_MASK: WARNING:' 
    PRINT, '                     The reference stars position differs from '
    PRINT, '                     the one for which the posfile has been written.'
    PRINT, '                     Forcing consistency; carefully check the results!'
    PRINT, ' '
  ENDIF
  FOR k = 0, log.mask_nrs-1 DO BEGIN
    sx[k]=sx[k] + xoffset
    sy[k]=sy[k] + yoffset
    bx[k,*] = bx[k,*] + xoffset 
    by[k,*] = by[k,*] + yoffset
  ENDFOR
ENDIF

;; **** end test area

;; ---------------------------------------------------------
;; --- TRANSFORM COORDINATES
;; --- source coordinates are relative to position reference star
;; --- background coordinates are relative to source itself
;;
; PRINT, " "
; PRINT, "% TRIPP_DEFINE_MASK: Transform absolute source coordinates into"
; PRINT, "% TRIPP_DEFINE_MASK: coordinates relativ to the position reference star"

FOR k = 0, log.mask_nrs-1 DO BEGIN
    
    bx[k,*] = bx[k,*] - sx[k]
    by[k,*] = by[k,*] - sy[k]
    
ENDFOR

ref_x = sx[0]
ref_y = sy[0]
sx = sx - sx[0]
sy = sy - sy[0]


;; ---------------------------------------------------------
;; --- SAVE RESULT
;;
SAVE, filename=maskFile, ref_x, ref_y, sx, sy, bx, by, sname

PRINT, ' '
PRINT, '% TRIPP_DEFINE_MASK: Extraction mask saved in ', maskFile
PRINT, '%==========================================================================================='
PRINT, ' '


;; ---------------------------------------------------------
;; --- END ---

END

;; ----------------------------------------
