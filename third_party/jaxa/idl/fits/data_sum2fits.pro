pro data_sum2fits, fitsfiles, $
   satthresh=satthresh, minthresh=minthresh, $
   nosat=nosat, nomin=nomin, noavg=noavg, nodev=nodev, $
   outfiles=outfiles
;+
;   Name: data_sum2fits
;
;   Purpose: add data summary fields to fits header (data not effected)
;
;   Input Parameters:
;      fitsfiles - list of FITS files to read & optionally update
;
;   Keyword Parameters:
;      satthresh - top cutoff level (ex: saturated pix level) - default=4090
;      minthresh - low cutoff level (ex: missing data)        - default=0
;      outfiles  - optional output file names (DEFAULT UPDATES INPUT FILE LIST)
;
;   FITS FIELDS CALCULATED AND ADDED:
;      IMG_AVG 	- Image Average
;      STD_DEV  - Standard Deviation
;      SAT_VAL  - hi cutoff level (ex: saturated pixels)
;      SAT_PIX  - Number Pixels >= SAT_VAL
;      MIN_VAL  - lo cutoff level (ex: missing data)
;      MIN_PIX  - Number Pixels <= MIN_VAL
;
;   Calling Sequence:
;      data_sum2fits, fitsfiles [/img_avg, /std_dev, satthresh=NN, $
;				    outfiles=outfiles
;   
;   History:
;      3-Apr-1996 - S.L.Freeland
;
;   Side Effects:
;      if OUTFILES not specified, the input FITS files are updated
;-

version='1.0'				; version of this program
comment="  (data_sum2fits " + version + ")"

if n_elements(satthresh) eq 0 and 1-keyword_set(nosat) then begin
   satthresh=4090	
   message,/info,"Setting default saturated pixel threshold to " + strtrim(satthresh,2)
endif

if n_elements(minthresh) eq 0 and 1-keyword_set(nomin) then begin
   minthresh=0
   message,/info,"Setting low/missing  pixel threshold to " + strtrim(minthresh,2)
endif

if n_elements(outfiles) ne n_elements(fitsfiles) then outfiles=fitsfiles

for i=0,n_elements(fitsfiles)-1 do begin
   if not file_exist(fitsfiles(i)) then begin
      message,/info,"Cannot find file: " + fitsfile(i)
   endif else begin
      data=readfits(fitsfiles(i),head)

;     ---------------- calulate values ----------------------------
      avg=total(data)/n_elements(data)
      dev=stdev(data,mean)                       
      sat=long(total(data ge satthresh))
      mini=long(total(data le minthresh))
;     --------------------------------------------------------------
;   
;     -------------- update FITs header ----------------------------
      fxaddpar,head,'IMG_AVG',avg," Image Average"       	    
      fxaddpar,head,'STD_DEV',dev," Standard Deviation" 	    
      fxaddpar,head,'SAT_VAL',satthresh," Saturated Pixel Threshold"  
      fxaddpar,head,'SAT_PIX',sat," Number Pixels >= SAT_VAL" 
      fxaddpar,head,'MIN_VAL',minthresh," Minimum Threshold"    
      fxaddpar,head,'MIN_PIX',mini," Number Pixels <= MIN_VAL" 
;     --------------------------------------------------------------
;
;     Write updated FITS file
      writefits,outfiles(i),data,head
   endelse
endfor

return
end
