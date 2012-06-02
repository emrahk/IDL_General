PRO specwrite,spe,file,verbose=verbose,comment=comment
   ;;
   ;; Write the spectra in spe in xdr-Format to file file
   ;;    This is the recommended format for files that are used
   ;;    with speclib
   ;;
   IF (keyword_set(verbose)) THEN print, 'Writing XDR '+file+'.spe.xdr...'
   
   openw,unit,file+'.spe.xdr',/get_lun,/xdr
   ;;
   ;; First goes an identification-string
   ;;
   IF (n_elements(comment) EQ 0) THEN BEGIN 
       writeu,unit,'spexdr,jw,1996'
   END ELSE BEGIN 
       writeu,unit,'spexdr,v2,1996'
   END 
   
   ;;
   ;; write comment to file
   ;;
   IF (n_elements(comment) GT 0) THEN BEGIN 
       IF (n_elements(comment) GE 5) THEN BEGIN 
           FOR i=0,4 DO BEGIN 
               writeu,unit,comment(i)
           END 
           IF (n_elements(comment) GT 5) THEN BEGIN 
               print,'Specwrite: Warning: only 5 comments written'
           END 
       END ELSE BEGIN 
           FOR i=0,n_elements(comment)-1 DO BEGIN 
               writeu,unit,string(format='(A70)',string(comment(i)))
           END 
           FOR i=n_elements(comment),4 DO BEGIN 
               writeu,unit,string(format='(A70)',' ')
           ENDFOR 
       END 
   END 
   ;;
   ;; Number of spectra
   ;;
   nfil=n_elements(spe)
   writeu,unit,nfil
   ;;
   ;; Write individual spectra
   ;;
   FOR i=0,nfil-1 DO BEGIN
       writeu,unit,string(format='(A40)',spe(i).desc)
       writeu,unit,spe(i).len
       writeu,unit,spe(i).flux
       writeu,unit,spe(i).e(0:spe(i).len)
       writeu,unit,spe(i).f(0:spe(i).len-1)
       writeu,unit,spe(i).err(0:spe(i).len-1)
       writeu,unit,spe(i).sat
   ENDFOR
   ;;
   ;; That's it
   ;;
   free_lun,unit
   ;;
   IF (keyword_set(verbose)) THEN print, '...done'
END 
