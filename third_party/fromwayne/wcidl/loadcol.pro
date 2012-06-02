function loadcol, fl, colname,ext=extension, single=single

if (n_params() eq 0) then begin
   print,'USAGE: data = loadcol(infile,colname,[ext=extension])'
   print,' INPUTS:  infile, array of input filenames'
   print,'          colname, string name of column'
   print,'          ext, extension'
   print,' OUTPUTS: data, output array'
   return,0
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

if (keyword_set(extension) eq 0) then begin
   extension = 1
endif

;
;Read in the data
;
FOR i=0,sz(1)-1 DO BEGIN
   ;Open and read the FITS file
   hd=headfits(fl(i))
   tab=readfits(fl(i),hd,ext=extension)

   IF (i EQ 0) THEN BEGIN            ; First file only
       data=fits_get(hd,tab,colname)

   ENDIF ELSE BEGIN                  ; All other files
       if (keyword_set(single)) then begin
          data=[data,fits_get(hd,tab,colname)]
       endif else begin
          data=[[data],[fits_get(hd,tab,colname)]]
       endelse

   ENDELSE
ENDFOR


;
; And that should do it
;
print,'fin'

return,data
end

