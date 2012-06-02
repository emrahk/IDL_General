pro loadgti, tfl, start, stop, ext=ext

if (n_params() eq 0) then begin
   print,'USAGE: loadgti,infile,start,stop,ext=extension'
   print,' INPUTS:  infile, array of input filenames'
   print,' OUTPUTS: start, array of start times'
   print,'          stop, array of stop times'
   print,'          extension, FITS extension to search'
   return
endif

;
; We're probably going to be changing filenames, so
; don' touch the input
;
fl=tfl

;
; By default assume that we're looking at a gti file
;
if ( keyword_set(ext) eq 0 ) then begin
   ext=1
endif

;
; If we input a single filename instead of an array,
; convert it to an array so it will work in the routine
; that I wrote below
;
sz=size(fl)
if ( sz(0) eq 0 ) then begin
   fl=[fl]
   sz=size(fl)
endif

;
;Read in the data
;
FOR i=0,sz(1)-1 DO BEGIN
   IF (i EQ 0) THEN BEGIN            ; First file only
       ;Open and read the FITS file
       hd=headfits(fl(i))
       tab=readfits(fl(i),hd,ext=ext)
            
       start=double(fits_get(hd,tab,'START'))
       stop=double(fits_get(hd,tab,'STOP'))

   ENDIF ELSE BEGIN                  ; All other files
       ;Open and read the FITS file            
       hd=headfits(fl(i))
       tab=readfits(fl(i),hd,ext=ext)
            
       start = [[double(fits_get(hd,tab,'START'))],start]
       stop  = [[double(fits_get(hd,tab,'STOP'))],stop]

   ENDELSE
ENDFOR
 
;
; And that should do it
;
print,'fin'
return
end

