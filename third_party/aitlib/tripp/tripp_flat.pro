PRO TRIPP_FLAT, logname, nr_subframes=nr_subframes, no_norm=no_norm, $
                maxInt=maxInt, minInt=minInt,recover=recover
;+
; NAME:
;           TRIPP_FLAT
;
;
; PURPOSE:
;           combination of several flat images to one median flat image 
;           result = MEDIAN( flats - zero )
;
;
; INPUTS:
;           logName : Name of reduction log file
;
; OPTIONAL INPUTS:  
;           nr_subframes : divide each image in <nr_subframes>
;                          subimages (reduction of array size)    
;                          default = 1
;
; KEYWORD PARAMETERS:
;           /no_norm     : do not normalize subframes 
;             
;           /recover     : Tries to build the accepted flat field list 
;                          from already present 
;                          reduced flat images selected/generated
;                          at a former processing stage.  
;                          This option could be used when selection of
;                          images was done but flat field processing
;                          failed (eg. out of memory).  
;                          If only a subset of processed flat fields
;                          should be kept all unwanted flat field
;                          image files must be deleted in the target
;                          directory. 
;
;
; RESTRICTIONS:
;           file typ   : FITS
;           rule for image names: xyz0001.fits 
;                                 i.e. four digits - dot - extension 
;
;
; OUTPUTS:
;           fits file output: result = MEDIAN( flats - zero )
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1999/23/05, Jochen Deetjen & Thomas Rauch
;                        2000/20/12  SD, Keyword no_norm and handling added 
;                        2001/01     SLS, change zero to long(zero)
;                                    after readfits   
;                        2001/01     SD, print statement to follow progress   
;                        2001/02   , SLS: added minInt; do not set
;                                    minInt or maxInt defaults (will
;                                    be taken care of in tripp_display_frames)
;                        2001/02   , SLS, added messages
;                        2001/05   , SLS, slight change to handling of
;                                    no_norm keyword: does not need to
;                                    be set in the code, IF now relies on
;                                    keyword_set 
;                        2001/05   , SLS, use medarr procedure, not
;                                    active!
;           Version 2.0, 2001/01/10, Eckart Göhler: Replaced
;                                    processing approach by a less
;                                    memory consuming one (but also
;                                    slower one ;-<  ) while
;                                    reading each image one by one and
;                                    selecting it, then perform
;                                    processing in subframes. Call now
;                                    with TRIPP_PROCESS_IMAGES -> more
;                                    sophisticated than the
;                                    TRIPP_READ_FRAMES one. 
;           Version 2.1, 2001/01/12, SLS & SD: different output name
;                                    for processed images, else way too
;                                    dangerous. Not tested with
;                                    /recover yet.
;           Version 2.2, 2002/03/01, EG: Added RECOVER keyword which
;                                    allows recovering from already
;                                    selected files. 
;                                    Test runs ok.
;                            2002/03 SLS: call to tripp_process_images
;                                    had not transported the minInt
;                                    and maxInt keywords
;-

;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

;  on_error,2                    ;Return to caller if an error occurs

  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_FLAT:            No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_FLAT:            The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_FLAT:            Using Logfile ', logname 
    ENDIF
  ENDELSE


;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_FLAT_LOG, logName, log


;; ---------------------------------------------------------
;; --- DEFINITIONS ---
;;

;; color table:
red   = [0,1,1,0,0,1]
green = [0,1,0,1,0,1]
blue  = [0,1,0,0,1,0]

;; value for undefined pixel (keep care not reaching this value when
;; subtracting bias)
UNDEF_VAL = -1

IF ( n_elements(nr_subframes)  EQ 0) THEN nr_subframes = 1 

zero      = FLTARR(log.xsize,log.ysize) 
flat      = FLTARR(log.xsize,log.ysize) 

; allocate array for all flats to make shure memory sufficies
flats     = FLTARR( log.xsize, log.ysize/nr_subframes , log.nr )   

;; VARIABLE SETUP:
imageName  = log.first      ; input image name

flatlist = STRARR(log.nr)   ; string array containing flat field names. 
                            ; If image is not accepted string is per
                            ; definitionem empty 

startidx = 0                ; index where we start selecting. 
                            ; per default zero, except in reco

; ---------------------------------------------------------
;; --- INTRO ---
;;
PRINT, ' '
PRINT, '%==========================================================================================='
PRINT, "% TRIPP_FLAT: Reading in ", STRTRIM(log.nr,2), " Flats"
PRINT, "% TRIPP_FLAT: Splitting each image in ", STRTRIM(nr_subframes,2)," subframes"

    
;; ---------------------------------------------------------
;; --- READING ZERO ---
;;
IF STRUPCASE(log.zero) NE 'OVERSCAN' THEN BEGIN
  zeroFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.zero, 2 )
  PRINT, ' '
  PRINT, "TRIPP_FLAT: Reading zero image " + zeroFile
  zero     = READFITS( zeroFile, h )
  zero     = long(zero)    
ENDIF ELSE BEGIN
    PRINT, '% TRIPP_FLAT: Bias correction from overscan has not been implemented yet.'
    GOTO, EXIT
ENDELSE


;;; ---------------------------------------------------------
;; --- RECOVERY ACTION - GET SELECTED LIST                --- 
;;     FROM PRESENT REDUCED FLAT FIELD IMAGES             ---
;;; ---------------------------------------------------------
IF ( KEYWORD_SET(recover)  ) THEN BEGIN
    PRINT, "% TRIPP_FLAT: START RECOVER FLAT LIST"

    FOR idx = 0, log.nr -1 DO BEGIN ; go through list, look for files

        ; create output File as in standard case:
        ; 1.) define  image name:
        STRPUT, imageName,                               $ ; replace in image name 
          STRING(idx + 1 + log.offset,format="(I4.4)"),  $ ; number of current index + offset
          log.nr_pos                                       ; at defined string position

        ; 2.) create output file name:
        outputFile = STRTRIM( log.out_path, 2 ) +  $
          '/' + imageName + ".mod"

        IF FILE_EXIST(outputFile) THEN BEGIN    ; -> add to flat list
            PRINT, "% TRIPP_FLAT: RECOVER FOUND/ACCEPTED FILE:" + imageName
            flatlist[idx] = outputFile;
            startidx=idx+1                 ; set start index for selection at following image
        ENDIF        
    ENDFOR
    PRINT, "% TRIPP_FLAT: RECOVER FLAT LIST COMPLETED"
ENDIF




;;; ---------------------------------------------------------
;; --- SELECTING/PREPROCESSING FLATS ---
;;; ---------------------------------------------------------


; for each image -> read in, select image
FOR idx = startidx, log.nr -1 DO BEGIN  
        
    ; define input image name:
    STRPUT, imageName,                               $  ; replace in image name 
      STRING(idx + 1 + log.offset,format="(I4.4)"),  $  ; number of current index + offset
      log.nr_pos                                        ; at defined string position

    ; define input/output file = path + image:
    inputFile = STRTRIM( log.in_path, 2 ) +    $
      '/' + STRTRIM( imageName, 2 )

    outputFile = STRTRIM( log.out_path, 2 ) +  $
      '/' + imageName + ".mod"           ;               SLS and SD: added .mod 
                                         ;               to protect original data


    PRINT, ' '
    PRINT, '% TRIPP_FLAT: READING ', inputFile
    
    ; read image 
    image  = DOUBLE(READFITS( inputFile, h ))
    
    ; define/process flat field, store if accepted:
    CASE TRIPP_PROCESS_IMAGE(image,           $  ; if accepted/processed -> 
                      NOWIN=(idx NE startidx),$ ; show window only when first image
                             TITLE=imageName, $  ; input image -> title
                             UNDEF=UNDEF_VAL, $  ; and undefined pixel marked
                             SETUP=SETUP,     $  ; setup to restore values
                 minInt=minInt,maxInt=maxInt) $  
      OF
        1: BEGIN ; -> ACCEPTED

            PRINT, '% TRIPP_FLAT: ACCEPTED ' + imageName

            ;; mark defined pixel:
            def_pixel=WHERE(image NE UNDEF_VAL)
            
            ;; bias subtraction
            PRINT, '% TRIPP_FLAT: subtracting zero ' + zeroFile
            image[def_pixel] = 0 > (image[def_pixel] - zero[def_pixel])
            
            ;; normalisation
            IF NOT KEYWORD_SET(no_norm) THEN BEGIN 
                PRINT, '% TRIPP_FLAT: normalize flat, factor 1/MEDIAN(flat)'      
                med             = MEDIAN( image[def_pixel])
                image[def_pixel] = image[def_pixel] / med        
            ENDIF     
            
            ;; write result 
            PRINT, '% TRIPP_FLAT: WRITING ', outputFile
            WRITEFITS, outputFile, image
            
            ;; and store file name
            flatlist[idx] = outputFile                  
        END

        0: BEGIN ; -> REJECTED

            PRINT, '% TRIPP_FLAT: REJECTED ' + imageName

            flatlist[idx] = ""  ; mark as not accepted
        END

        -1: BEGIN ; -> BACK

            PRINT, '% TRIPP_FLAT: BACK 1 IMAGE'

            IF idx GT 0 THEN idx = idx - 2 ELSE idx = idx - 1 
        END
    ENDCASE
    
ENDFOR

;; ---------------------------------------------------------
;; --- REMOVE 1-D PLOT WINDOWS ---
;;
IF startidx LT log.nr THEN BEGIN
    WDELETE,1
    WDELETE,2
ENDIF

;;; ---------------------------------------------------------
;; --- LIST ACCEPTED IMAGES                               ---
;; --- ( IDL can't allocated more than a few bytes )      ---
;;; ---------------------------------------------------------
PRINT, '% TRIPP_FLAT: ACCEPTED IMAGES:'
PRINT, flatlist[where(flatlist NE "")]


;;; ---------------------------------------------------------
;; --- LOOP THROUGH IMAGES IN GIVEN SUBFRAMES,            ---
;; --- COMPUTE MEDIAN                                     ---
;; --- ( IDL can't allocated more than a few bytes )      ---
;;; ---------------------------------------------------------
FOR subframe=1,nr_subframes DO BEGIN

    PRINT, '% TRIPP_FLAT: PROCESSING SUBFRAME ',subframe

    ;; ---------------------------------------------------------
    ;; --- CALCULATE SUBFRAME WIDTH ---
    ;;;
    ywidth  = FIX( log.ysize / nr_subframes )
    yl      = (subframe -1) * ywidth
    yr      = subframe * ywidth - 1 

    ;; set y subframe size in case of last image and non-integer
    ;; image/subframe ratios 
    IF (subframe EQ nr_subframes) THEN yr = log.ysize-1  

    ysize   = yr - yl + 1                                ; actual y image size
    act_flatlist  = $                                    ; number/
      flatlist[where(flatlist NE "", act_flat_num )]     ; list of accepted images

    flats = FLTARR( log.xsize, ysize , act_flat_num )   ; allocate array for all flats

    ;; ---------------------------------------------------------
    ;; --- READ ALL ACCEPTED IMAGES FOR CURRENT SUBFRAME ---
    ;;;
    FOR idx = 0, act_flat_num -1 DO BEGIN ; for each image -> read in, select image
        
        ;; define input image name:
        STRPUT, imageName,                               $ ; replace in image name 
          STRING(idx + 1 + log.offset,format="(I4.4)"),  $ ; number of current index + offset
          log.nr_pos            ; at defined string position
        
        ;; define input/ file = output-path + image:
        inputFile = act_flatlist[idx]

        PRINT, ' '
        PRINT, '% READFITS: READING ', inputFile
    
        ;; read image -> frames
        image  = READFITS( inputFile)
        flats[*,*,idx] = image[*,yl:yr]

    ENDFOR          ;; each image in current subframe 

    ;; ---------------------------------------------------------
    ;; --- COMPUTE MEDIAN FOR SUBFRAME                       ---
    ;; 
    PRINT, ' '
    PRINT, '% TRIPP_FLAT: calculating median of ', $
      STRTRIM( act_flat_num, 2 ), ' Flats'
    
    FOR x = 0, log.xsize-1 DO BEGIN
        PRINT,'% TRIPP_FLAT: x-Position: ',x
        FOR y = yl, yr DO BEGIN                
            yidx = y - yl 
            ;; exclude undefined pixel
            defined_set = where(flats[x,yidx,*] NE UNDEF_VAL)

            ;; compute median for current pixel through all flats:
            IF defined_set[0] NE -1 THEN $
              flat[x,y] = MEDIAN( flats[x,yidx,defined_set] ) $
            ELSE BEGIN
                PRINT, "% TRIPP_FLAT:"
                PRINT, "% ERROR: UNDEFINED FLAT PIXEL AT:",x,y
                PRINT, "% PROCESSING ABORTED:"
                GOTO, EXIT
            ENDELSE                        
        ENDFOR  ;  terrible!! 3 loops !!!
    ENDFOR

ENDFOR ;; each subframe



;; ---------------------------------------------------------
;; --- NORMALIZATION ---
;;
PRINT, ' '
PRINT, '% TRIPP_FLAT: normalize result flat, factor 1/MEDIAN(flat)'

flat = flat / MEDIAN(flat)


;; ---------------------------------------------------------
;; --- DISPLAY RESULT ---
;;
PRINT, ' '
PRINT, '% TRIPP_FLAT: displaying result'



IF TRIPP_PROCESS_IMAGE(flat,              $  ; if accepted/processed -> 
                     TITLE="RESULT FLAT", $
                     UNDEF=UNDEF_VAL,     $ ; and undefined pixel marked
                     SETUP=SETUP)         $
  THEN BEGIN


;; ---------------------------------------------------------
;; --- SAVE RESULT IF ACCEPTED ---
;;
outputFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.result, 2 )
WRITEFITS, outputFile, flat

PRINT, ' '
PRINT, '% TRIPP_FLAT: Result saved in ', outputFile
PRINT, '%================================================================'
PRINT, ' '

ENDIF ELSE BEGIN
    PRINT, '% TRIPP_FLAT: RESULT SKIPPED'
    PRINT, '%================================================================'
ENDELSE

;; ---------------------------------------------------------
;; --- REMOVE 1-D PLOT WINDOWS ---
;;
WDELETE,1
WDELETE,2

;; ---------------------------------------------------------
;; --- END ---
EXIT:
END

;; ----------------------------------------

