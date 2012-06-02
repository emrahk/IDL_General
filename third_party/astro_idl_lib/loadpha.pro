pro loadpha, tfl, cnts, err=err, expos=expos, back=tbk

if (n_params() eq 0) then begin
   print,'USAGE: loadpha,infile,cnts,err=err,expos=expos,back=backfiles'
   print,' INPUTS:  infile, array of input filenames'
   print,'          backfiles, background files (optional)'
   print,' OUTPUTS: cnts, array of counts'
   print,'          err, array of errors on the counts'
   print,'          expos, the exposure in each file'
   return
endif

;
; We're probably going to be changing filenames, so
; don' touch the inputs
;
fl=tfl
if (keyword_set(tbk)) then bk=tbk

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
; Make sure the number of background files
; makes sense
;
if ( keyword_set(bk) ) then begin
   bsz=size(bk)
   if ( bsz(0) eq 0 ) then begin
      ;
      ; Use the same background for all source files
      ;
      if ( sz(1) eq 1 ) then begin
         bk=[bk]
      endif else begin
         bk=replicate(bk,sz(1))
      endelse
      bsz=size(bk)
   endif
   if ( bsz(1) ne sz(1) ) then begin
      print,' '
      print,' Number of source and background files'
      print,' differ. Fatal Error'
      print,' '
      return
   endif
endif

;
;Read in the data
;
FOR i=0,sz(1)-1 DO BEGIN
   IF (i EQ 0) THEN BEGIN            ; First file only
       ;Open and read the FITS file
       hd=headfits(fl(i))
       tab=readfits(fl(i),hd,ext=1)
            
       cnts=fits_get(hd,tab,'COUNTS')
       err=fits_get(hd,tab,'STAT_ERR')

       expos=fxpar(hd,'EXPOSURE')

   ENDIF ELSE BEGIN                  ; All other files
       ;Open and read the FITS file            
       hd=headfits(fl(i))
       tab=readfits(fl(i),hd,ext=1)
            
       cnts=[[cnts],[fits_get(hd,tab,'COUNTS')]]
       err=[[err],[fits_get(hd,tab,'STAT_ERR')]]

       expos=[expos,fxpar(hd,'EXPOSURE')]

   ENDELSE
ENDFOR

;
; Convert all of the output arrays to doubles to
; make life easier in IDL
;
cnts=double(cnts)
err=double(err)
expos=double(expos)
 

;
; Read in the Background Files
;
if ( keyword_set(bk) ) then begin
   FOR i=0,sz(1)-1 DO BEGIN
       IF (i EQ 0) THEN BEGIN            ; First file only
           ;Open and read the FITS file
           hd=headfits(bk(i))
           tab=readfits(bk(i),hd,ext=1)

           bkcnts=fits_get(hd,tab,'COUNTS')
           bkerr=fits_get(hd,tab,'STAT_ERR')

           bkexpos=fxpar(hd,'EXPOSURE')

       ENDIF ELSE BEGIN                  ; All other files
           ;Open and read the FITS file
           hd=headfits(bk(i))
           tab=readfits(bk(i),hd,ext=1)

           bkcnts=[[bkcnts],[fits_get(hd,tab,'COUNTS')]]
           bkerr=[[bkerr],[fits_get(hd,tab,'STAT_ERR')]]

           bkexpos=[bkexpos,fxpar(hd,'EXPOSURE')]

       ENDELSE
   ENDFOR

   ;
   ; Convert the background arrays to doubles
   ;
   bkcnts=double(bkcnts)
   bkerr=double(bkerr)
   bkexpos=double(bkexpos)
 
   ;
   ; Convert to rates and subtract the background
   ;
   for i=0,sz(1)-1 do begin
          scrate=cnts(*,i)/expos(i)
          scrate_err=err(*,i)/expos(i)

          bkrate=bkcnts(*,i)/bkexpos(i)
          bkrate_err=bkerr(*,i)/bkexpos(i)

      if (i eq 0) then begin
          rate=scrate - bkrate
          rate_err=sqrt(scrate_err^2.d + bkrate_err^2.d)

      endif else begin
          temp=scrate - bkrate
          temp_err=sqrt(scrate_err^2.d + bkrate_err^2.d)

          rate=[[rate],[temp]]
          rate_err=[[rate_err],[temp_err]]

      endelse
   endfor

   ;break

   ;
   ; Output the BG subtracted rates intead of raw counts
   ; fill the exposure with zeros as a warning
   ;
   cnts=rate
   err=rate_err
   expos=dblarr(sz(0))

endif
 
;
; And that should do it
;
print,'fin'
return
end

