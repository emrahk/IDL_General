;
; Read spectra produced by the mxcxx-series
;   spectra : array of spectra
;   filename: filename
;   nsp     : number of spectra read
;   verbose : print diagnostics if set
;
pro mcread, spectra, filename, nsp,verbose=verb
   on_error, 1

   if (keyword_set(verb)) then print, 'Reading MC:'+filename

   openr, unit, filename,/get_lun

   i1=0 & i2=0 & i3=0
   readf, unit, FORMAT='(3I3)',i1,i2,i3
   
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
   we = 0. & wa = 0. & wc = 0. 
   ie = 0  & ia = 0  & ic = 0
   typ= 0  & num = 0
   de = ''

   j=0

   for i=1,numspec do begin
       readf,unit,format='(A70)',de ; Read description
       readf,unit,format='(I3)',typ ; Read Type of spectrum

                                ; create description of spectrum
       de = strtrim(de,2)
       spectra(j).desc = de + ' incident'
       spectra(j+1).desc = de + ' reflected'
       spectra(j).sat = -1.
       spectra(j+1).sat = -1.

       if (keyword_set(verb)) then print,de

       readf,unit,format='(I5)',num ; Read number of points
       spectra(j).len = num
       spectra(j+1).len = num

       for k=0,num-1 do begin
           readf, unit, format='(F10.2,3(F10.2,I8))', $
            ee,we,ie,wa,ia,wc,ic
           spectra(j).e(k) = ee/1000.
           spectra(j).f(k) = we
           spectra(j+1).e(k)=ee/1000.
           spectra(j+1).f(k)=wc
       endfor
       spectra(j).e(k+1) =spectra(j).e(k)+(spectra(j).e(k)-spectra(j).e(k-1))
       spectra(j+1).e(k+1) = spectra(j).e(k+1)
       spectra(j).err(*) = 0.
       spectra(j+1).err(*) = 0.
       idum=''
       readf,unit,idum
       j = j+2
   endfor
   close,unit
   free_lun, unit
   nsp = j
   spectra=spectra(0:nsp-1)
end
