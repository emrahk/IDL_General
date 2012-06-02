;
; Read spectra produced by kotelp
;   spectra : array of spectra
;   filename: filename
;   nsp     : number of spectra read
;   verbose : print diagnostics if set
;
pro kotread, spectra, filename, nsp,verbose=verb
   on_error, 1

   if (keyword_set(verb)) then print, 'Reading kotelp: '+filename

   openr, unit, filename,/get_lun

   
   ;; Number of spectra
   numspec = 0
   readf, unit, FORMAT='(I8)',numspec
   IF (n_elements(nsp) GT 0) THEN BEGIN 
       IF (numspec GT nsp) THEN numspec=nsp
   ENDIF 
   
   ;; Initialize speclib if necessary
   speclib
   spectra=replicate({spectrum},numspec*3)

   ee = 0. 
   we = 0.
   ie = 0 
   typ= 0  & num = 0
   de = ''

   j=0

   for i=1,numspec do begin
       readf,unit,format='(A70)',de ; Read description
       readf,unit,format='(I3)',typ ; Read Type of spectrum

                                ; create description of spectrum
       de = strtrim(de,2)
       spectra(j).desc = de
       spectra(j).sat = -1.

       if (keyword_set(verb)) then print,de

       readf,unit,format='(I5)',num ; Read number of points
       spectra(j).len = num

       for k=0,num-1 do begin
           readf, unit, format='(F15.5,F15.5,I8)', $
            ee,we,ie
           spectra(j).e(k) = ee*512.
           spectra(j).f(k) = we
       endfor
       spectra(j).e(num) =2.*spectra(j).e(num-1)-spectra(j).e(num-2)
       spectra(j).err(*) = 0.
       idum=''
       readf,unit,idum
       j = j+1
   endfor
   close,unit
   free_lun, unit
   nsp = j
   spectra=spectra(0:nsp-1)
end
