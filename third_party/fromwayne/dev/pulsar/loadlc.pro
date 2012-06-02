pro loadlc, tfl, time, rate, bary=bary, err=error, counts=counts

if (n_params() eq 0) then begin
   print,'USAGE: loadlc,infiles,time,rate,err=error,/bary,/counts'
   print,' INPUTS:  infiles, array of input filenames'
   print,' OUTPUTS: time, array of times'
   print,'          rate, array of rates'
   print,'          error, array of errors on the rates'
   print,'          /bary, load barytime instead of time column'
   print,'          /counts, load counts instead of rates column'
   return 
endif

;
; We're probably going to be changing filenames, so
; don' touch the inputs
;
fl=tfl

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
numfiles=sz(1)-1

;Read in the data
FOR i=0,numfiles DO BEGIN
    IF (i EQ 0) THEN BEGIN            ; First file only
        ;Open and read the FITS file
        hd=headfits(fl(i))
        tab=readfits(fl(i),hd,ext=1)
            
        ;Get the times 
        IF (keyword_set(bary)) THEN BEGIN
            print,'Using BARYTIME Column for Light Curve'
            time=fits_get(hd,tab,'BARYTIME')
        ENDIF ELSE BEGIN
            print,'Using TIME Column for Light Curve'
            time=fits_get(hd,tab,'TIME')
        ENDELSE

        ;Get the rate and the error
        IF (keyword_set(counts)) THEN BEGIN
            rate=fits_get(hd,tab,'COUNTS')
        ENDIF ELSE BEGIN
            rate=fits_get(hd,tab,'RATE')
        ENDELSE

        error=fits_get(hd,tab,'ERROR')

    ENDIF ELSE BEGIN                  ; All other files
        ;Open and read the FITS file            
        hd=headfits(fl(i))
        tab=readfits(fl(i),hd,ext=1)
            
        ;Get the times
        IF (keyword_set(bary)) THEN BEGIN
            print,'Using BARYTIME Column for Light Curve'
            time=[time,fits_get(hd,tab,'BARYTIME')]
        ENDIF ELSE BEGIN
            print,'Using TIME Column for Light Curve'
            time=[time,fits_get(hd,tab,'TIME')]
        ENDELSE

        ;Get the rate and the error
        IF (keyword_set(counts)) THEN BEGIN
            rate=[rate,fits_get(hd,tab,'COUNTS')]
        ENDIF ELSE BEGIN
            rate=[rate,fits_get(hd,tab,'RATE')]
        ENDELSE

        error=[fits_get(hd,tab,'ERROR')]

    ENDELSE
ENDFOR

;
; Just in case the LC isn't in temporal order,
;    let's sort it.
;
w=sort(time)
time=time(w)
rate=rate(w)
error=error(w)

return
end

