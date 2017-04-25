; procedure to read/scale TRACE images, and to remove particle hits
;
; First version:  CJS - 30 April 98
; Revised:        CJS - 21 May   98
; Revised:        SLF - 5-June-1998 - add /LOUD, made default quiet
;                       (added trace_scale wrapper for 3D/SSW)
; Revised:        DMZ - 30-June-1998 - added check for divides by zero

;
; Input:  file              complete filename of the FITS file to be read
; Output: image_scaled      despiked&scaled image - bytarr
;         image_corrected   despiked image - intarr (optional)
;
; Scaling methods:
;    The code first determines the value of the CCD pedestal, and the
;    maximum value based on the specified number of saturated pixels (def.
;    500). The image is then scaled to have a contrast of a factor contrast
;    (def. = 4) between median and saturation value both measured from the
;    value of the readout pedestal. Scaling to the available number of color 
;    cells is optional (/byte); this scaling returns the image as a byte
;    array that can be used for, e.g., gif files.
;
; Examples:
;  Scaling to be determined from image:
;    tv,tracescale(image,/despike,/byte,contrast=3)
;  with enhanced contrast (def=2.5).
;  
;  Scaling prescribed, and read from fits file:
;    imout=tracescale(image,readfile=file,/despike,scaling=[p,s,g])
;  with p=pedestal/minimum, s=saturation/maximum, g=gamma
;  
;  On an O2 it takes about 6 seconds to read, despike, scale, colorize, and
;  rebin a 1024^2 image.
;
;  The scaled images can be displayed with color tables defined by 
;  tracecolor.pro
;
function tracescale2,image_raw,$
     loud=loud,$                         ; if set: print diagnostics
     despike=despike,$                   ; if set: apply despiker
     readfile=readfile,$                 ; if set: read file readfile (fits)
     contrast=contrast,$                 ; scaled range of intensities (def=3)
     exceed=exceed,$                     ; no of pixels saturated (def=500)
     scaling=scaling,$                   ; array prescribing scaling
     returnscaling=returnscaling,$       ; array specifying scaling
     fullrange=fullrange, $              ; dont leave 2 cells 
     byte=byte                           ; scale to a byte image, max: byte
;                                          scaling adjusts to available colors.
;                                          The two highest cells are not used:
;                                          available for magnetic contours.
  if keyword_set(contrast) then contrast=contrast else contrast=3.5
loud=keyword_set(loud)
;
  if keyword_set(readfile) then begin      ; backward compatible
    file=readfile                          ; (generally read outside...)
    print,'Now reading file: ',file
    image_raw=readfits(file)
  endif 
; apply despiker?
  if keyword_set(despike) then image_corrected=tracedespike(image_raw,loud=loud) $
                          else image_corrected=image_raw
  image_scaled=image_corrected
; scaling prescribed or to be determined?
  if not(keyword_set(scaling)) then begin
; determine a readout pedestal by looking at the corners of the image
    if n_elements(image_corrected) eq 1024.^2 then $
      pedestal=fix(tracepedestal(image_corrected,h=h)+0.5) else begin
        pedestal=min(image_corrected)>1
        h=histogram(image_corrected,min=0,max=1000,bin=1)
        print,'Using minimum in image as pedestal'
      endelse
; determine max scale from cumulative histogram
    hc=h & for i=n_elements(h)-2,0,-1 do hc(i)=hc(i+1)+hc(i)
; 
    if keyword_set(exceed) then threshold=float(exceed)/n_elements(image_raw) $
                           else threshold=500./n_elements(image_raw)
    dummy=min(abs(float(hc)-max(hc)*threshold),maxscale)
; how to adjust the grayscale?
    dummy=min(abs(hc-0.5*n_elements(image_scaled)),m)
; range in intensities to be displayed
    range=float(maxscale-pedestal)/float(m-pedestal)
; use range to determine gamma of the image: 
; bring back contrast to factor contrast

;-- check for divides by zero (DMZ)

    if (contrast le 0.) or (range le 0.) then gamma=1. else $
     gamma=alog(contrast)/alog(range)
  endif else begin
    pedestal=scaling(0)
    maxscale=scaling(1)
    gamma=scaling(2)
  endelse
  returnscaling=[pedestal,maxscale,gamma]
; 
  if loud then print,'Image scaled: pedestal = ',pedestal,' Imax = ',maxscale,$
    ' Gamma = ', gamma
  if keyword_set(byte) then begin 
    if byte eq 1 then byte=!d.table_size
    minimum=(((min(image_corrected)-pedestal)>1)<maxscale)^gamma
    maximum=(maxscale-pedestal)^gamma
    factor=(byte-([2,0])(keyword_set(fullrange)))/(maximum-minimum)
    ; byte scale leaves highest two color cells unused for use with magnetogram
    retval= bytscl(factor*(((image_corrected<maxscale-pedestal)>1))^gamma-minimum)
; comparison 
    endif else retval=(((image_corrected<maxscale-pedestal)>1))^gamma
 return,retval 
end
