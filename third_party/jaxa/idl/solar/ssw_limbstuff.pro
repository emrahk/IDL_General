pro ssw_limbstuff, index, data, regions, region_info, $
		   annulus=annulus, annfact=annfact,  $
		   lowcut=lowcut, hicut=hicut, $
                   minpix=minpix,                               $
                   minsep=minsep,                               $
                   display=display, $
		   debug=debug
;
;   Name: ssw_limbstuff
;
;   Purpose: tag neat stuff over the limb 
;
;   Input Parameters:
;      index - an SSW index record (assumed SOHO pointing keywords)
;      data  - the DATA array
;  
;   Output Parameters:
;      regions - 'blobs' over the limb (blob coloring) 
;      region_info - structure - info on each region w/npix > minpix 
;  
;   Keyword Parameters:
;      lowcut  - low count rate cutoff - if not supplied, take above limb avg.
;      annulus - 2 element annulus parameters [inner,outer] + solar_r 
;      annfact - calculate LOWCUT from above limb annulus  ANNFACT*most common
;      minpix  - ignore regions with number pixels < minpix         (def=20)
;      minsep  - minimum seperation between blobs  
;      display - if set, show some results
;      hicut   - optional upper pixel value to consider (filter cosmic rays..)
;
;   Calling Sequence:
;      ssw_limbstuff, index, data, regions, region_info [,lowcut=nn   $
;                                                       [,annfact=xx, $
;                                                       [,minpix=nn,  $
;                                                       [,/display    
;   Calling Examples:
;      ssw_limbstuff, index, data, regions, region_info, lowcut=xxx  ; LOWCUT
;      ssw_limbstuff, index, data, regions, region_info              ; annulus
;      ssw_limbstuff, index, data, regions, region_info,annfact=2.0  ; annulus
;      ssw_limbstuff, index, data, reg, rinfo, minpix=50,/display    ; big  reg          
;
;      ------------ eit sample sequence ----
;      read_eit, eit304file, index, data                 ; read a 304 image
;      eit_prep, index, data=data, oindex, odata         ; clean it up
;      ssw_limbstuff, oindex, odata, regions, reg_info   ; find limb stuff
;      ----------------------------------
;
;   History:
;      4-jun-1997 - S.L.Freeland (Written, originally for EIT 304 study, but..)
;
;   Restrictions:
;      2D only for now - assume data 'cleaned' (dark, degrid, whatever)
;      MINSEP not yet implemented
;  
;   Method:
;      check data, setup call to label_region,  figure out what it all means
;
;   Notes:  
;      annulus parameters is annulus above the limb 
;      inner padding [ annulus(0) ] avoids incomplete limb removal
;      ie, dont include any of the disk in deriving LOWCUT from annulus
;-
debug=keyword_set(debug)
; ------------------------ check input -------------------------------
if (1-data_chk(index,/struct)) or n_params() lt 2 then  begin
    prstr,strjustify(['IDL> ssw_limbstuff, index, data [,/annulus]'],/box)
    return
endif    
; -------------------------------------------------------------------------

; ------------------------ some defaults ---------------------------------
display=keyword_set(display)
if n_elements(minpix) eq 0 then minpix=20
if not keyword_set(annulus) then annulus=[4,6]  ; default annulus size
; -------------------------------------------------------------------------
if display then begin
   wdef,im=data,/already
   loadct,4
   tvscl,data
   stretch,0,200,.3
endif
; ------------------------ generate disk mask -----------------------------
dmask=cir_mask(data, gt_tagval(index,/crpix1), gt_tagval(index,/crpix2), $
               gt_tagval(index,/solar_r) + annulus(0))
dabove=data & dabove(dmask) =0               ; data above the limb (mask disk)
if display then tvscl,dabove
; -------------------------------------------------------------------------
if not keyword_set(hicut)  then hicut=max(data)     ; ** better default?? ***

; ---------- if no LOWCUT, derive default from above-limb annulus ---------
if n_elements(lowcut) eq 0 then begin
   amask=cir_mask(data, gt_tagval(index,/crpix1), gt_tagval(index,/crpix2), $
                  gt_tagval(index,/solar_r) + annulus(1) ,/outside)
   dannulus=data
   dannulus(dmask)=0 & dannulus(amask)=0           ; above limb annulus
   annavg=average(dannulus,missing=0)              ; annulus average
   annhist=histogram(dannulus)
   annhist(0)=0                                        ; ignore BIN ZERO
   if n_elements(annfact) eq 0 then annfact=1.5        ; Annulus FACTOR 
   lowcut=(where(annhist eq max(annhist)))(0)*annfact  ; Most-Common*ANNFACT
endif
; -------------------------------------------------------------------------

; ---------- make a bilevel image of the neat stuff -----------------------
bilev=dabove
something=(dabove ge lowcut and data le hicut)  & nothing=1-something
bilev(where(something)) = 1 & bilev(where(nothing))  = 0
regions=label_region(bilev)                           ; <<<<< FIND THE BLOBS
if display then tvscl,bilev
; -------------------------------------------------------------------------

; --------- Tag regions and filter out the too-small ---------------------
rhist=(histogram(regions))(1:*)          ; ignore element (0) => no region
nregions=n_elements(rhist)               ; total blobs identified
which=where(rhist ge minpix, rcnt)       ; filter "too small" regions

mess=["Total number of limb regions found: " + strtrim(nregions,2), $
      "Number after MINPIX (" + strtrim(minpix,2) +") applied :" + strtrim(rcnt,2), $
      "Using LOCUT value: " + strtrim(lowcut,2)]
; -------------------------------------------------------------------------

; ----------------  exit if nothing of interest ------------------------
if rcnt eq 0 then begin
   mess=[mess,"No above-limb regions were flagged, returning"]
   prstr,strjustify(mess,/box)
   return
endif
; -------------------------------------------------------------------------

sreg=strtrim(which,2)
mess=[mess,'', strjustify('Region# ' + sreg) + $
                 ' #Pixels: ' + strtrim(rhist(which),2)]
prstr,strjustify(mess,/box)
; -------------------------------------------------------------------------
; ---------- INFO (seperate routine ??) -----------------------------------

; ------- define the info structure  --------
if not data_chk(info_temp,/struct) then    $ ;
   info_temp={rnum:0l,                     $ ; region# (=pix value in REGIONS)
              npix:0l,                     $ ; number of pixels in region
              centroid:fltarr(2),          $ ; region weighted centroid
              rtot:0.0,                    $ ; region total
              rmax:0.0,                    $ ; region maximum
              ravg:0.0                     $ ; region average
                                           } ; 
; -------------------------------------------

region_info=replicate(info_temp,rcnt)       ; one per "accepted" region
region_info.rnum=which+1                    ; fill in region# (adjust for 0)
region_info.npix=rhist(which)               ; fill in #pix/region

empty=make_array(size=size(data))           ; make a useful template image 

;---- per-region loop for additionl info ---;
if display then tvscl,dabove
for i=0,rcnt-1 do begin                     ; for each region, gather some info
   message,/info,"Region>>> " + sreg(i)     ; region status message
   tempty=empty                             ; use template
   ss=where(regions eq region_info(i).rnum) ; pixel SS for region(i)
   tempty(ss)=data(ss)                      ; get corresponding data
   region_info(i).rtot=total(data(ss))      ; total->str
   region_info(i).ravg=average(data(ss))    ; average->str
   region_info(i).rmax=max(data(ss))        ; max->str
   centroidw,tempty,xw,yw                   ; calculate centroid
   region_info(i).centroid=[xw,yw]          ; centroid->str
   if display then begin
      ocontour,(tempty gt 0) * which(i),levels=which(i),c_color=120
      xyouts2,xw,yw,sreg(i),color=200,/device,align=.5,size=1.5
   endif
endfor                                     ;
;-------------------------------------------;
if debug then stop

return
end
