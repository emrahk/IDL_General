;+

PRO ssw_hot_pix,  iindex,idata	 , oindex, odata, $
                    ss_start, ss_end, ss_ref, $
                    SIGMA = sigma, LOUD = loud,  $
                    clobber=clobber, reiterate=reiterate

;NAME:
;   SSW_HOT_PIX
;PURPOSE:
;   Remove "hot pixels" from a data cube. Hot pixels are those that
;   are constantly above SIGMA standard deviations from the reference
;   image average intensity. These are NOT radiation hits and this
;   routine does not remove radiation hits.
;CATEGORY:
;CALLING SEQUENCE:
;   ssw_hot_pix,iindex,idata,oindex,odata  
;INPUTS:
;   itrace, dtrace = original TRACE index and data cube. 
;OPTIONAL INPUT PARAMETERS:
;   ss_ref = index of the reference image in iindex,idata.  All other
;            images are compared to this one.  Default = 0.
;   ss_start, ss_end = If you like, you can operate on a subset of the
;                      data cube.  These give the index of the start
;                      and end images in itrace,dtrace.  Dafault =
;                      align the full data cube.  
;KEYWORD PARAMETERS:
;   sigma = the number of standard deviations above the reference
;           image average intensity that defines a "hot pixel". Default value
;           is 5.0.
;   loud = if set, prints out informational stuff; if not, is silent.
;   clobber - if set and nparams=2, then clobber the input 'index,data'
;   reiterate - if set and this routine has already run on this
;               data set, permit rerun (default inhibits correction of
;               previously run per .HISTORY
;
;OUTPUTS:
;   oindex, odata = the modified 'index' w/history & modified data cube
;COMMON BLOCKS:
;   None.
;SIDE EFFECTS: 
;   if /CLOBBER set and only two parameters, input 'index,data' are replaced
;   by modified versions
;RESTRICTIONS:
;    
;PROCEDURE:
;     Compares the first and last images in the data cube. Spikes in
;     intensity which do not move are considered to be hot pixels. 
;
;     Median values are substituted at the identified hot pixel
;     locations for all images in the data cube.
;MODIFICATION HISTORY:
;     T. Berger  2004-Sep-29 - trace_hot_pix.pro
;     S.L.Freeland 4-Oct-2004 - tweaked Tom's trace version to apply to
;                               any SSW imager - added /CLOBBER switch
;                               and function & update_history mod
;-

clobber=keyword_set(clobber)
if n_params() lt 4 and (1-clobber) then begin 
   box_message,['You did not specify output parameters...', $
                'use /CLOBBER to force overwrite of input parameters']
   return
endif

nt = N_ELEMENTS(iindex)  
if N_ELEMENTS(ss_start) LE 0 then $
   ss_start  = 0                     ; Start index in original data cube
if N_ELEMENTS(ss_end) LE 0 then $
   ss_end = nt-1                     ; Final index in original data cube
if N_ELEMENTS(ss_ref) LE 0 then $
   ss_ref = 0                        ; Reference index in original data cube
if data_chk(idata,/nimage) NE nt then $
   MESSAGE,'ERROR: the number in index records does not equal the number of images'
IF KEYWORD_SET(sigma) THEN sig = sigma ELSE sig = 5.0

;Reference image
im0 = idata[*, *, ss_ref]
nx = data_chk(im0,/nx)
ny = data_chk(im0,/ny) 
;Spike image
medim0 = im0 - MEDIAN(im0, 3)
;Define the bad ones:
std = STDEV(medim0, mavg)
im0=medim0 GT mavg+sig*std
bad0 = WHERE(im0, nbad)
if nbad eq 0 then begin 
 MESSAGE, 'No pixels identified above ', STRTRIM(sig,2), ' standard deviations: no action taken.'
 RETURN
END 

 ;last image in series
im1 = idata[*, *, ss_end]          
medim1 = im1-MEDIAN(im1, 3)
std = STDEV(medim1, mavg)
im1=medim1 GT mavg+sig*std
bad1 = WHERE(im1, nbad)
if nbad eq 0 then begin 
    MESSAGE, 'Final image has no pixels identified above ', $
             STRTRIM(sig,2), ' standard deviations: no action taken.'
    RETURN
ENDIF 

;Compare the maps
hotmap = im0 AND im1
hot = WHERE(hotmap GT 0, nhot)
IF KEYWORD_SET(loud) THEN BEGIN
   PRINT, STRTRIM(nhot, 2), ' hot pixels identified. Correcting ', STRTRIM(nt, 2), ' images...'
   WINDOW, xs=nx, ys=ny, title='TRACE hot pixel image'
   TVSCL, hotmap
END

;Correct using local median values.
if clobber then odata = temporary(idata) else $
   odata=idata
previous = get_history(iindex,caller='ssw_hot_pix',found=found) 

tagval = 'SIGMA=' + strtrim(sig,2) + '; ' +STRTRIM(nhot, 2)+' hot pixels corrected'
oindex=iindex

if (1-found) or keyword_set(reiterate) then begin 
FOR i = 0, nt-1 DO BEGIN
   IF KEYWORD_SET(lound) THEN PRINT, '   working on image ', STRTRIM(i, 2), ' of ', STRTRIM(nt, 2)
   im = odata[*, *, i]
   FOR j = 0, nhot-1 DO im[hot[j]] = MEDIAN([ im[hot[j]],im[hot[j]+1],im[hot[j]-1], $
                                              im[hot[j]-nx-1],im[hot[j]-nx],im[hot[j]-nx+1], $
                                              im[hot[j]+nx-1],im[hot[j]+nx],im[hot[j]+nx+1] ])
   odata[*, *, i] = im
   
END
update_history,oindex,tagval
endif else begin 
    box_message,['Routine run previously...',  previous(0), $ 
       'Use /REITERATE to permit additional re-executions on this index,data'] 
endelse 

if clobber then begin 
   iindex=temporary(oindex)
   idata=temporary(odata)
endif

RETURN
END
