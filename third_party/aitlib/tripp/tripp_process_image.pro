FUNCTION TRIPP_PROCESS_IMAGE, IMAGE, $
                    TITLE=TITLE,     $
                    minInt=MININT, maxInt=MAXINT , $
                    UNDEF=UNDEF, $
                    NOWIN=NOWIN, $
                    SETUP=SETUP
;+
; NAME:
;           TRIPP_PROCESS_IMAGE
;
;
; PURPOSE:
;           Display an image (e.g. flat)
;           as well as the intensity on current pointer position.
;           Basic image processing is supported: 
;           - masking out positive disturbance found with the DAOPHOT
;             package 
;           - performing sigma filter processing
;           Also the image could be marked as being accepted/rejected.
;
;
; INPUTS:
;           image : input/ 2-dimensional array of integer/floats
;                   representing the image. May be changed when
;                   leaving this procedure.
;
;
; OPTIONAL INPUTS:   
;           TITLE  : Title text, should contain information about image.
;                    Default = "Image Processing"
;           minInt : minimal intensity --> 1D plot ranges, tv picture
;                    default = median(image( *, ysize/2))*0.8
;           maxInt : maximal intensity --> 1D plot ranges, tv picture
;                    default = median(image( *, ysize/2))*1.2
;           UNDEF  : Value (integer) undefined pixel are set at. Used
;                    when masking out stars when processing the mask
;                    (m) command. Default: -1
;           SETUP  : Setup parameter record. This record contains all
;                    parameter which are necessary for fine tuned image
;                    processing and which therefore should remain
;                    persistent for all images of a given data set. To
;                    support the persistence of these parameters this
;                    keyword delivers all relevant parameters to the
;                    caller of this function. When not defined default
;                    parameters are set. 
;                    Use this facility by calling this function with a
;                    unused variable name, and use this variable when
;                    calling again this function (for a common data set).  
;    
; KEYWORD PARAMETERS:
;           NOWIN  : Do not create new window if set. This may be used
;                    when calling this procedure in a sequence and
;                    recreation of each window becomes tedious. 
;
;
; OUTPUTS:
;           IMAGE  : Input image with user defined modifications
;                    (holes/sigma filer)
;           returns: Boolean value: 
;                     image is accepted (1) or rejected (0),
;                     or previous image should be displayed (-1)
;                     (information to caller of this function).
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 2001/01/10, Eckart Göhler: Initial version,
;                                    as being taken from procedure
;                                    tripp_display_frames.pro, version
;                                    1.0. Supports displaying of image
;                                    with cursor range checks, simple
;                                    image processing (mask
;                                    out/filtering) and accept/reject
;                                    result returning. 
;-

ON_ERROR,2                      ;Return to caller if an error occurs


; define private color table:
red   = [0,1,1,0,0,1]
green = [0,1,0,1,0,1]
blue  = [0,1,0,0,1,0]

; define image size: 
x_size=N_ELEMENTS(image[*,0])
y_size=N_ELEMENTS(image[0,*])

; define window size:
x_win_size = 500
y_win_size = 500

; define image dynamic:
image_min=MIN(image)
image_max=MAX(image)

; zoom flag; (default disabled)
zoom=0

; restore image for undoing all changes
undo_image=IMAGE

; check optional keywords:
; -> title
IF ( n_elements(TITLE)  EQ 0) THEN title  = "Image Processing"  ; -> title

; -> min int
IF ( n_elements(minInt) EQ 0) THEN BEGIN                        ; -> minInt
    minInt = MEDIAN(image[*,y_size/2])*0.8
    PRINT, '% TRIPP_PROCESS_IMAGES: using local minimal value',minInt
ENDIF

; -> max int
IF ( n_elements(maxInt) EQ 0) THEN BEGIN                        ; -> maxInt
    maxInt = MEDIAN(image[*,y_size/2])*1.2
    PRINT, '% TRIPP_PROCESS_IMAGES: using local maximal value',maxInt
ENDIF

; undefined pixel value:
IF N_ELEMENTS(UNDEF) EQ 0 THEN UNDEF = -1 

; -> setup ( all internal parameters which should remain persistent are
; stored in the setup record. Should be used when this routine is
; called more than once for a given data set. )
IF ( n_elements(SETUP)  EQ 0)                      $; setup not defined 
  OR (SIZE(SETUP))[(SIZE(SETUP))[0]+1]  NE 8 THEN  $; or not structure type (8)
  SETUP = {FWHM         : 10,  $                    ; -> define parameters for 
           DETECT_SIGMA : 3,   $                    ; tripp_cheese_flat (mask out stars) 
           GAIN         : 2.6, $                    
           RON          : 5.98,$
           REL_ERR      : 1,   $
           CUT_RAD      : 20,  $
           BOX_WIDTH    : 3,   $                    ; parameters for sigma_filter
           N_SIGMA      : 3,    $                   ; (smooth it)
           ZOOM_SIZE    : 200  $                    ; size of zoom window
          }

; ---------------------------------------------------------
;; --- INTRO ---
;;
PRINT, ' '
PRINT, '% TRIPP_PROCESS_IMAGES: displaying image'
PRINT, '% TRIPP_PROCESS_IMAGES: left   mouse button: accept   image'
PRINT, '% TRIPP_PROCESS_IMAGES: middle mouse button: reject   image'
PRINT, '% TRIPP_PROCESS_IMAGES: right mouse button : start command session'
PRINT, ' '

; open windows if not suppressed
IF NOT KEYWORD_SET(NOWIN) THEN BEGIN
    WINDOW,1, XSIZE=500,YSIZE=300, title="Intensity at Y cursor"
    WINDOW,2, XSIZE=300,YSIZE=500, title="Intensity at X cursor"
ENDIF

; incoming image window
TRIPP_TV, image, XMAX=x_win_size, YMAX=y_win_size, $
  ABSLO=minInt, ABSHI=maxInt,        $
  TITLE=TITLE

;; --- define colors:
TVLCT, 255*red,255*green,255*blue 



; preset cursor coordinates at image center:
x=x_size/2
y=y_size/2
!MOUSE.BUTTON = 0


; ---------------------------------------------------------
;; --- MAIN LOOP                                        ---
;; --- LOOP TILL ACCEPT/REJECT SELECTED                 ---
;; --- PROCESS IMAGE                                    ---
;; ---------------------------------------------------------
WHILE 1 DO BEGIN 

    
    CASE !MOUSE.BUTTON OF
        ;; ---------------------------------------------------------
        ;; ---  LEFT MOUSE BUTTON CLICKED ---> ACCEPT IMAGE      ---
        1 : BEGIN      
            WSET,1
            PLOT, IMAGE[*,Y], $  ; plot accept image
              POSITION=[0.12,0.1,0.95,0.95], $
              XSTYLE= 1,                     $ 
              YRANGE=[minint,maxint],        $            
              YTICKFORMAT="(I5.0)",          $
              COLOR = 3
            XYOUTS, 0.3, 0.15, /DEVICE, CHARSIZE=1.5, COLOR=3, $
              TITLE + " ACCEPTED                "
            RETURN, 1
        END

        ;; ---------------------------------------------------------
        ;; ---  MIDDLE MOUSE BUTTON CLICKED ---> REJECT IMAGE      ---
        2 : BEGIN    
            WSET,1
            PLOT, IMAGE[*,Y], $  ; plot reject image
              POSITION=[0.12,0.1,0.95,0.95], $
              XSTYLE= 1,                     $ 
              YRANGE=[minint,maxint],        $            
              YTICKFORMAT="(I5.0)",          $
              COLOR = 2
            XYOUTS, 0.3, 0.15, /DEVICE, CHARSIZE=1.5, COLOR=2, $
              TITLE + " REJECTED                "
            RETURN, 0        
        END

        ;; ---------------------------------------------------------
        ;; ---  RIGHT MOUSE BUTTON CLICKED ---> SPECIAL OPERATIONS -
        4  : BEGIN  
            WSET,0

            ;; loop till quit/accept/reject
            REPEAT BEGIN
                PRINT, '% TRIPP_PROCESS_IMAGES: enter image processing command:'
                PRINT, '%                       a - quit selection process, accept image'
                PRINT, '%                       b - back one image in frame list'
                PRINT, '%                       d - define/display parameters for processing'
                PRINT, '%                       m - search and mask out stars '
                PRINT, '%                       q - quit selection process, continue'
                PRINT, '%                       r - quit selection process, reject image'
                PRINT, '%                       s - perform sigma filter '
                PRINT, '%                       u - undo all changes '
                PRINT, '%                       z - zoom window (open/close it) '
            
                ;; get command:
                instr=""
                READ, instr, PROMPT="%  Enter Command: "
                CASE STRUPCASE(instr) OF 

                    ;; ---  ACCEPT  ---
                    "A" : RETURN, 1    

                    ;; ---  BACK  ---
                    "B" : RETURN, -1    

                    ;; ---  DEFINE SETUP PARAMETER  ---   
                    "D" : REPEAT BEGIN
                        PRINT, '% TRIPP_PROCESS_IMAGES'
                        PRINT, '% DEFINE PROCESSING PARAMETERS:'
                        PRINT, '% --------------------'
                        PRINT, '% STAR MASKING PARAMETER:'
                        PRINT, '%    1 - FWHM         ', SETUP.FWHM
                        PRINT, '%    2 - DETECT_SIGMA ', SETUP.DETECT_SIGMA 
                        PRINT, '%    3 - GAIN         ', SETUP.GAIN         
                        PRINT, '%    4 - RON          ', SETUP.RON          
                        PRINT, '%    5 - REL_ERR      ', SETUP.REL_ERR      
                        PRINT, '%    6 - CUT_RAD      ', SETUP.CUT_RAD      
                        PRINT, '% --------------------'
                        PRINT, '% SIGMA FILTER PARAMETER:'
                        PRINT, '%    7 - BOX_WIDTH    ', SETUP.BOX_WIDTH    
                        PRINT, '%    8 - N_SIGMA      ', SETUP.N_SIGMA      
                        PRINT, '% --------------------'
                        PRINT, '%    ZOOM WINDOW:      '
                        PRINT, '%    9 - ZOOM      ', SETUP.ZOOM_SIZE
                        PRINT, '% --------------------'
                        PRINT, '%    0 - QUIT DEFINE  '
                        PRINT, '% --------------------'
                        READ, select_id, PROMPT='% Enter choice: ' 
                        
                        CASE select_id OF 
                            0 : PRINT, '% QUIT DEFINE'
                            1 : BEGIN
                                READ, in_val, PROMPT= '% FWHM:         '
                                SETUP.FWHM = in_val
                            END
                            2 : BEGIN 
                                READ, in_val, PROMPT= '% DETECT_SIGMA: '
                                SETUP.DETECT_SIGMA = in_val
                            END
                            3 : BEGIN
                                READ, in_val, PROMPT= '% GAIN:         '
                                SETUP.GAIN = in_val
                            END
                            4 : BEGIN
                                READ, in_val, PROMPT= '% RON:          '
                                SETUP.RON = in_val
                            END
                            5 : BEGIN
                                READ, in_val, PROMPT= '% REL_ERR:      '
                                SETUP.REL_ERR = in_val
                            END
                            6 : BEGIN
                                READ, in_val, PROMPT= '% CUT_RAD:      '
                                SETUP.CUT_RAD = in_val 
                            END
                            7 : BEGIN
                                READ, in_val, PROMPT= '% BOX_WIDTH:    '
                                SETUP.BOX_WIDTH = in_val
                            END
                            8 : BEGIN
                                READ, in_val, PROMPT= '% N_SIGMA:      '
                                SETUP.N_SIGMA = in_val
                            END
                            9 : BEGIN
                                READ, in_val, PROMPT= '% ZOOM SIZE:      '
                                SETUP.ZOOM_SIZE = in_val
                            END
                            ELSE:  PRINT, "% INVALID SELECTION"
                        ENDCASE                        
                    ENDREP UNTIL select_id EQ 0

                    ;; ---  REJECT  ---   
                    "R" : RETURN, 0

                    ;; ---  QUIT (main loop)  ---   
                    "Q" : 

                    ;; ---  MASK STARS  ---   
                    "M" : BEGIN
                        PRINT, '% TRIPP_PROCESS_IMAGES:'
                        PRINT, '% PERFORM STAR MASKING:'
                        TRIPP_CHEESE_FLAT,IMAGE, $
                          FWHM=SETUP.FWHM, DETECT_SIGMA=SETUP.DETECT_SIGMA, $
                          GAIN=SETUP.GAIN, RON=SETUP.RON,                   $
                          REL_ERR=SETUP.REL_ERR, CUT_RAD=SETUP.CUT_RAD,     $
                          CUT_VAL=UNDEF
                        TRIPP_TV, image, XMAX=x_win_size, YMAX=y_win_size, $
                          ABSLO=minInt, ABSHI=maxInt,        $
                          TITLE=TITLE, /NOWIN
                    END

                    ;; ---  SIGMA FILTER  ---   
                    "S" : BEGIN
                        PRINT, "% TRIPP_PROCESS_IMAGES:"
                        PRINT, "% PERFORM SIGMA FILTERING"
                        IMAGE = SIGMA_FILTER(IMAGE,$
                                             SETUP.BOX_WIDTH,$
                                             N_SIGMA=SETUP.N_SIGMA)
                        TRIPP_TV, image, XMAX=x_win_size, YMAX=y_win_size, $
                          ABSLO=minInt, ABSHI=maxInt,        $
                          TITLE=TITLE, /NOWIN
                    END

                    ;; ---  UNDO  ---   
                    "U"  : BEGIN
                        IMAGE=undo_image
                        TRIPP_TV, image, XMAX=x_win_size, YMAX=y_win_size, $
                          ABSLO=minInt, ABSHI=maxInt,        $
                          TITLE=TITLE, /NOWIN
                    END

                    ;; ---  ZOOM  ---   
                    "Z"  : BEGIN
                        zoom=NOT zoom
                        IF zoom THEN $  ; display zoom window
                          WINDOW,3, XSIZE=SETUP.zoom_size,YSIZE=SETUP.zoom_size, $
                          title="ZOOMED VIEW" $
                        ELSE WDELETE, 3 ; delete zoom window
                          
                        
                    END

                    ;; ---  INVALID COMMAND  ---   
                    ELSE : BEGIN 
                        PRINT, '% TRIPP_PROCESS_IMAGES:'
                        PRINT, '% Invalid command: ', instr
                    ENDELSE
                ENDCASE ;; of user selected commands
                
            ENDREP UNTIL STRUPCASE(instr) EQ "Q" OR $
                         STRUPCASE(instr) EQ "Z"

            PRINT, '% TRIPP_PROCESS_IMAGES:'
            PRINT, "CONTINUE WITH MOUSE"
        END ;; --- OF SPECIAL COMMANDS ---

        ;; ---------------------------------------------------------
        ;; ---  NO MOUSE BUTTON CLICKED ---> REDRAW CUTS         ---
        ELSE : BEGIN            

            ;; draw horizontal cut plot line
            WSET, 1
            IF y GE 0 AND y LT y_size THEN   $
              PLOT, IMAGE[*,Y],              $
              COLOR = 1,                     $
              POSITION=[0.12,0.1,0.95,0.95], $
              XSTYLE= 1,                     $ 
              YRANGE=[minint,maxint],        $
              YSTYLE=1,                      $
              YTICKFORMAT="(I5.0)"
            
            ;; print out cursor title, position+ value
            XYOUTS, 0.3, 0.15, /DEVICE, CHARSIZE=1.5, COLOR=1, $
              TITLE + "  X: " + STRING(x,format="(I4.0)") $
                    + "  Y: " + STRING(x,format="(I4.0)") $
                    + "  VAL: " + STRING(image[x,y],format="(I6.0)") 
            

            ;; draw vertical cut plot line
            WSET, 2
            IF x GE 0 AND x LT x_size THEN       $
              PLOT,  IMAGE[X,*], FINDGEN(y_size),$
              COLOR = 1,                         $
              XSTYLE= 1,                         $ 
              XRANGE=[minint,maxint],            $
              YSTYLE=1,                          $
              XTICKFORMAT="(I5.0)"

            IF zoom THEN BEGIN
                WSET, 3

                ;; zoom index vectors
                ;; these vectors are used to construct a subimage-zoom-image index
                ;; array when displaying zoom window content
                x_one=lonarr(SETUP.ZOOM_SIZE) ; x/y - vector containing 1
                x_one=x_one+1
                y_one=lonarr(SETUP.ZOOM_SIZE)
                y_one=y_one+1
                x_ind=lindgen(SETUP.ZOOM_SIZE) ; x/y - vector containing increasing number
                y_ind=lindgen(SETUP.ZOOM_SIZE)

                
                ;; set offset so that center of zoom image is at cursor
                x_offset=LONG(x-SETUP.ZOOM_SIZE/2)
                y_offset=LONG(y-SETUP.ZOOM_SIZE/2)
                
                ;; compute index of image part which should be
                ;; zoomed. actually a tricky computation by combining
                ;; two matrices, one with increasing row numbers, the
                ;; other with increasing column numbers, each shifted
                ;; according offset. 
                subimage_index = (x_one # y_ind + y_offset ) * x_size + $
                  x_ind # y_one + x_offset
                  
                ;; display zoom content;
                subimage=BYTSCL(image[subimage_index],$
                                min=minInt, max=maxInt)
                TV, subimage                
                
            ENDIF
            
        ENDELSE 

    ENDCASE ;; of clicked buttons

    WSET, 0              ; in tv display ->

    ;; ---------------------------------------------------------
    ;; --- GET CURSOR (MOUSE) STATE                          ---
    CURSOR,x,y,2,/NORMAL ; get cursor info, when change occurred

    x=x * (x_size-1)            ; convert to image coordinates
    y=y * (y_size-1)            ; [0..1] -> [0..image size-1]


 ENDWHILE

END
