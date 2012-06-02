;
; Read normal spectra
;
pro normread, spectra, filename, nsp,verbose=verb
   on_error, 1
   openr, unit, filename,/get_lun

   if (keyword_set(verb)) then print, 'Reading '+filename
                                ; Number of spectra
   numspec = 0 & cols=0
   readf, unit, numspec
   IF (n_elements(nsp) GT 0) THEN BEGIN 
       IF (numspec GT nsp) THEN numspec=nsp
   ENDIF 
   readf, unit, cols
   if (keyword_set(verb)) then print, numspec, ' spectra'
   if (keyword_set(verb)) then print, cols, ' columns'
   
   ;; Initialize speclib if necessary
   speclib
   spectra=replicate({spectrum},numspec*cols)

   we=fltarr(cols+1)

   num = 0
   de = ''

   j=0

   for i=1,numspec do begin
       readf,unit,format='(A70)',de ; Read description

                                ; create description of spectrum
       de = strtrim(de,2)
       for k=0,cols-1 do begin
           spectra(j+k).desc = de
           if (k gt 0) then begin
               spectra(j+k).desc=spectra(j+k).desc+' '+strtrim(string(k),2)
           endif
           spectra(j+k).sat = -1.
       endfor

       readf,unit,num           ; Read number of points

       if (keyword_set(verb)) then print,de,', ',num,' data points'

       for k=0,cols-1 do spectra(j+k).len = num

       for k=0,num-1 do begin
           readf, unit,we
           for ll=0,cols-1 do begin
               spectra(j+ll).e(k) = we(0)/1000.
               spectra(j+ll).f(k) = we(1+ll)
           endfor
       endfor
       spectra(j).e(num) =spectra(j).e(k)+(spectra(j).e(k)-spectra(j).e(k-1))
       for k=1,cols-1 do spectra(j+k).e(num) = spectra(j).e(num)

       idum=''
       readf,unit,idum
       j = j+cols
   endfor
   close,unit
   free_lun, unit
   nsp = j
end
