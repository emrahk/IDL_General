;+
;NAME:    nospike.pro    
;
;PURPOSE: Despike an image using a median filter / dilation 
;
;Method:  spikes exceeding `threshold' percent ( default = 15% in
;         normal areas, and default = 20 % in areas brighter than 
;         avg(image)+stdev(image) ) and brighter than 'minimum' 
;         ( default = avg(image) ). 
;         Fills hits with median of neighbouring pixels that were not
;         flagged as radiation hits. If the /flare keyword is set,
;         the brightthreshold is put to 30%, so that flare kernels
;         are not flagged as radiation hits. This can also be set
;         manually by using the "brighttreshold" keyword.
;         Contrary to trace_despike, this routine often doesn't need 
;         iterations, and two iterations usually suffices.
;         
;         
;SUBROUTINES:   
;                  wv_a_trous
;
;CALLING SEQUENCE: image=nospike(image)
;
;OUTPUT: returns despiked image array
;
;EXAMPLE: 
;
;  im=nospike(readfits('file'))           simple correction
;  im=nospike(trace_nospike(im0))         double correct. for faint fields
;  im=nospike(im0,minimum=200)            corr. above I=200   
;  im=nospike(im0,thre=0.17,bright=0.25)  pixels brighter than 1.17
;                                               or 1.25 of local average
;                                               in normal or bright
;                                               regions, respectively
;                                               are flagged as hits
;  im=nospike(im0,nspikes=nspikes,imap=imap) to return the number of
;                                                  pikes removed
;                                                  and a pixel map
;  im=nospike(im0,/flare)                 to keep flare kernels
;
;CALLS:
;         avg, lable_region
;
;OPTIONAL KEYWORD INPUT:
;
;  nspikes	       number of spikes (not pixels) removed
;  imap                map of corrected pixels
;  threshold           fractional threshold for brightness
;  brightthreshold     fractional threshold for brightness in bright regions
;  minimum             do not correct pixels dimmer than minimum
;  flare               sets brightthreshold to 0.3
;  silent              doesn't print out messages
;
;Restrictions:
;   the call to RSI 'dilate' varies slightly between pre/after V5.3
;   (RSI added '/constrain' and 'background' keywords in 5.3)
;
;HISTORY:
;
; Bart De Pontieu (BDP)  27 October 2000.
;                        31-October 2000, S.L.Freeland rename Bart's
;                        'trace_nospike.pro' to 'nospike.pro' and add it
;                        to the growing SSW/gen CCD cleanup arsenal
;                        added version dependent 'dilate' call
; Zarro (EER/GSFC) 28 May 2003 - added "where" check
;
;TODO: - someone (volunteers?) needs to a review of all possible SSW 
; CCD detector/image cleanup routines and generate a 
; effectiveness/application matrix....
; clean_exposure.pro, despike_gen.pro unspike.pro ssw_unspike_cube.pro
; and many others (not to mention the ~general routines which are
; buried in trace,eit,sxt,lasco... instrument specific libraries.
;-

PRO wv_a_trous, cin,cout,wout,j_max

;; Fast version of algorithm described on p.24 and following
;; in "Image Processing and Data Analysis" by Starck et al.
;; Similar to unsharp masking

scin = size(cin)
nx = scin(1)
ny = scin(2)
cin2 = float(cin)
cout = fltarr(nx,ny,j_max+1)
cout(0,0,0) = cin2
wout = cout*0.
FOR j=1,j_max DO BEGIN 
 n = 2^(j-1)
 kernel = fltarr(2*n+1,2*n+1)*0.
 kernel(n*indgen(3),0) = [0.0625,0.125,0.0625]
 kernel(n*indgen(3),n) = [0.125,0.25,0.125]
 kernel(n*indgen(3),2*n) = [0.0625,0.125,0.0625]
 cout(0,0,j) = convol(cout(*,*,j-1),kernel,/edge_truncate)
 wout(0,0,j) = cout(*,*,j-1)-cout(*,*,j)
ENDFOR 

return 
END 


FUNCTION nospike,image,nspikes=nspikes,imap=imap,$
         threshold=threshold,brightthreshold=brightthreshold,minimum=minimum,$
         silent=silent,flare=flare


IF n_params() LT 1 THEN BEGIN
    box_message,'IDL>cleaned=trace_nospike(data[,thresh=xx] ...)'
    return,-1
ENDIF 

  ; replacement thresholds
IF keyword_set(threshold) THEN threshold=threshold ELSE threshold=0.15
IF keyword_set(flare) THEN threshold2 = 0.3
IF keyword_set(brightthreshold) THEN threshold2 = brightthreshold ELSE BEGIN 
      IF NOT(keyword_set(flare)) THEN threshold2 = 0.2
ENDELSE 
  ; minimum intensity of radiation hit
IF keyword_set(minimum) THEN minimum=(minimum > 0) ELSE minimum=avg(image)
 
ds = size(image)
nx = ds(1)
ny = ds(2)

tp = size(image,/type)

; periodic extension to deal with hits at the edge
image2 = make_array(nx+4,ny+4,type=tp)
image2(2,2) = image
image2(0,0) = image2(4,*)
image2(1,0) = image2(3,*)
image2(nx+3,0) = image2(nx-1,*)
image2(nx+2,0) = image2(nx,*)
image2(0,0) = image2(*,4)
image2(0,1) = image2(*,3)
image2(0,ny+3) = image2(*,ny-1)
image2(0,ny+2) = image2(*,ny)

th = fltarr(nx+4,ny+4)+threshold

; Dilation Kernel
ker = intarr(3,3)
ker(0,1) = 1
ker(1,*) = 1
ker(2,1) = 1

; Call `a trous algorithm for unsharp masking
wv_a_trous,image2,cim,wim,1

; Define bright mask
ci1 = smooth(image2,11,/edge_truncate)
aci1 = avg(ci1)
sci1 = stdev(ci1)

;th(where(ci1 GE aci1+sci1)) = threshold2

;-- changed by DMZ

chk=where(ci1 GE (aci1+sci1),count)
if count gt 0 then th(chk)=threshold2


; Define minimum brightness mask
wi1 = reform(wim(*,*,1))
wi1b = wi1*0.
wmin = where(image2 GE minimum,nmin1)
IF nmin1 GT 0 THEN BEGIN 
 wi1b(wmin) = wi1(wmin)/float(image2(wmin))
ENDIF

; Dilate & threshold unsharp mask

mask1 = (wi1b - th) GE 0
skl = dilate(mask1,ker)

; Label all radiation hits in dilated mask
b_curv = label_region(skl,/eight)
h_curv = histogram(b_curv,reverse_indices=r)


estring=(['b_curv2 = dilate(b_curv,ker,/gray)', $
          'b_curv2 = dilate(b_curv,ker,/gray,/ulong,/constrained)'])
estat=execute( (estring)(since_version('5.3')))


estring=(['b_curv3=dilate(b_curv2,ker,/gray)',$
          'b_curv3 = dilate(b_curv2,ker,/gray,/ulong,/constrained)'])

estat=execute( (estring)(since_version('5.3')))

h_curv3 = histogram(b_curv3-b_curv,reverse_indices=r3)
curv_tot2 = skl*0
skl_tot = skl*0.

; Fill in labeled radiation hits 

FOR kk=1L,n_elements(h_curv)-1L DO BEGIN 
    p = r(r[kk]:r[kk+1]-1)
    p3 = r3(r3[kk]:r3[kk+1]-1)
    curv_tot2[p] = 1
    skl_tot[p] = median(image2[p3])
ENDFOR


; Clean up
nspikes = long(n_elements(h_curv))
imap = curv_tot2(2:nx+1,2:ny+1)

; Messages
IF NOT(keyword_set(silent)) THEN BEGIN 
 print,'Corrected '+strcompress(string(n_elements(h_curv)),/remove_all)+$
       ' radiation hits and bad pixels (>'+$
       strcompress(string(fix(threshold*100)),/remove_all)+' %)' 
ENDIF 

; Calculate new image
skl_final = make_array(nx,ny,type=tp)
skl_final(0,0) = (skl_tot*curv_tot2+image2*(1-curv_tot2))(2:nx+1,2:ny+1)

return,skl_final
END 
