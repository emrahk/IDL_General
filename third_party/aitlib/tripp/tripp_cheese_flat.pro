PRO TRIPP_CHEESE_FLAT, IMAGE, FWHM=FWHM, DETECT_SIGMA=DETECT_SIGMA, $
                 GAIN=GAIN, RON=RON, REL_ERR=REL_ERR, CUT_RAD=CUT_RAD, $
                 CUT_VAL=CUT_VAL
;+
; NAME:
;       TRIPP_CHEESE_FLAT
;
;
; PURPOSE:
;      Generate image excluding all stars found in input image 
;
;
; CATEGORY:
;      photometry
;
;
; CALLING SEQUENCE:
;       TRIPP_CHEESE_FLAT, IMAGE, FWHM=FWHM, DETECT_SIGMA=DETECT_SIGMA, $
;                 GAIN=GAIN, RON=RON, REL_ERR=REL_ERR, CUT_VAL=CUT_VAL
;
;
; INPUTS:
;        IMAGE - 2-dimensional array which should be checked against
;                stars etc. 
;
;
; OPTIONAL INPUTS:
;        FWHM : Full width half maximum of gauss function to be used
;               for search. Determines size of stars to be
;               excluded. Defines also circle which is cut from image
;               by CUT_RAD=2*FWHM if CUT_RAD is not defined. 
;               Default: 10
;
;        DETECT_SIGMA: Detection statistic threshold. All stars below
;               this sigma are ignored. 
;               Default: 3
;
;        GAIN:  Ratio of photons (electrons) used per ADU (i.e. value
;               stored in image). Used to determine background random
;               noise.
;               Default: 2.60 e-/ADU (CAHA instrument)
;
;        RON:   Readout noise in units of photons (electrons). Used to
;               determine background random noise. 
;               Default: 5.980 (CAHA instrument)
;
;        REL_ERR: Relative error defining background noise. The
;               noise is determined at first step for one pixel
;               only. To get the proper noise to set the detection
;               threshold the algorithm must adjust the error with
;               a relative error factor. This factor is print out by
;               the DAO-PHOT FIND routine but unfortunately could not
;               be used for automatic processing. Refer also: DAOPHOT
;               2 Manual, Annex 2, and P.R.Stetson.  
;               Default: 1
;
;        CUT_RAD: Radius of circle to cut from image. 
;               Default:  2*FWHM.
;
;        CUT_VAL: Value to set image circle at. 
;               Default = 0. 
;
;
; OUTPUTS:
;        IMAGE - input image with all found stars excluded (set at CUT_VAL)
;
;
;
; SIDE EFFECTS:
;        Destroys input image by changing pixel values for found stars.
;
;
;
; RESTRICTIONS:
;        Could not find extended star sources. 
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;        > img=readfits("flat3.fits")
;        > TRIPP_CHEESE_FLAT, img, 10, 5, 2.6, 5.98, 0.45
;        > tripp_tv, img
;     -> exclude stars from img, fwhm of 10 -> radius = 20,     
;     -> detection sigma of 5 with relative error of 0.45, 
;     -> detector properties of gain 2.6 and readout noise of 5.98
;        (e-).

; MODIFICATION HISTORY:
; 
;     created 21-09-2001, Eckart Göhler
; 
;-

; parameters to be set up:
 ; RON - read out noise in e-
IF N_ELEMENTS(RON) EQ 0 THEN RON=5.980
 ; GAIN - e-/ADU
IF N_ELEMENTS(GAIN) EQ 0 THEN GAIN=2.60
 ; relative error  (TBD from procedure FIND)
IF N_ELEMENTS(REL_ERR) EQ 0 THEN REL_ERR=1
; gaussian full width half maximum for procedure FIND
IF N_ELEMENTS(FWHM) EQ 0 THEN FWHM=10
; detection limit in sigma of background
IF N_ELEMENTS(DETECT_SIGMA) EQ 0 THEN DETECT_SIGMA=3  
; value to set cut circle at:
IF N_ELEMENTS(CUT_VAL) EQ 0 THEN CUT_VAL=0
; radius to cut circles
IF N_ELEMENTS(CUT_RAD) EQ 0 THEN CUT_RAD=2*FWHM  
 
;; get background sigma:
SKY, IMAGE, skymode,skysig

;; compute random noise in ADU (for single frame):
random_noise=SQRT(skymode/GAIN+RON^2/GAIN^2)

;; define threshold for star find selection:
hmin=REL_ERR*random_noise*DETECT_SIGMA

; search sources, with sloppy round/sharpness statistics:
FIND, IMAGE, x,y, flux, sharp, round,hmin, FWHM, [-1.0,1.0], [0.1,5.0],/SILENT



; size of image
x_size=(SIZE(image))[1]
y_size=(SIZE(image))[2]

; size of subimage
mask_size=2*CUT_RAD 

; auxilliary vectors to create subimage index
x_one=lonarr(mask_size)
x_one=x_one+1
y_one=lonarr(mask_size)
y_one=y_one+1
x_ind=lindgen(mask_size)
y_ind=lindgen(mask_size)


; create box with distance 
DIST_CIRCLE,MASK,2*CUT_RAD,CUT_RAD,CUT_RAD

; go through list of found stars (x,y) and set pixels at cut value:
FOR i=0,n_elements(x)-1 DO BEGIN
    PRINT,"Processing: ", i, X[i], Y[i]
    IF X[i] GE CUT_RAD AND X[i] + CUT_RAD LT x_size $
      AND Y[i] GE CUT_RAD AND Y[i] + CUT_RAD LT y_size THEN BEGIN
        ;; GET IMAGE INDEX FOR BOX AROUND CURRENT STAR:
        x_offset=LONG(X[i] - CUT_RAD)
        y_offset=LONG(Y[i] - CUT_RAD)

        ;; create subimage index matrix containing indices 
        ;; of image at x - cut_rad,y - cut_rad:
        ;; (this is one of the more obscure features in IDL leading to
        ;;  my private oppinion that this system is doomed - hacking 3
        ;;  lines of code which nobody, developer included, is unable
        ;;  to understand in less than the developing time.)
        ;; ok: here the matrix is combined of two submatrices, one
        ;; which increases index each row, the other each
        ;; column. Depending on the size in x direction and the y row
        ;; shift this number is adjusted. 
        subimage = (x_one # y_ind + y_offset ) * x_size + $
                    x_ind # y_one + x_offset

        ;; use subimage index matrix to get indices where we are
        ;; within the circle to be cut from image:
        ind1=WHERE(mask LT CUT_RAD/2 )

        ;; ind2 is the index to be applied for the input image for
        ;; each pixel lying within the circle:
        ind2=subimage[ind1]

        ;; set image at cut value 
        IMAGE[ind2] = CUT_VAL
    ENDIF
ENDFOR

END




















