;
; Read spectra in the .xdr.spe format
;    spectra: array of spectra
;    filename: filename
;    nsp     : number of spectra read
;    verbose : print diagnostics
;    comment : if set: returns comment present in .spe.xdr-File
;
; There are two versions of the .spe.xdr format around:
;    version 1: Tag: spexdr,jw,1996 (the default format)
;    version 2: Tag: spexdr,v2,1996, contains an additional
;               string of 5x70 characters that describes the
;               spectrum and its parameters
;    version 3: Tag: spexdr,v3,1999: arbitrary number of comments.
;               (programmed 1999/03/17)
;
PRO xdrread, spectra, filename, nsp, verbose=verb,comment=comment
   
   IF (keyword_set(verb)) THEN print, 'Reading .spe.xdr: '+filename

   version=0
   openr, unit, filename, /get_lun, /xdr
   a='spexdr,jw,1996'
   readu,unit,a
   IF (a EQ 'spexdr,jw,1996') THEN version=1
   IF (a EQ 'spexdr,v2,1996') THEN version=2
   IF (a EQ 'spexdr,v3,1999') THEN version=3

   IF (version EQ 0) THEN warning,' File is not an .spe.xdr-File'

   ;;
   ;; Read version2 extension 
   ;;
   comment=strarr(5)
   IF (version GT 1) THEN BEGIN 
       IF (version EQ 2) THEN BEGIN 
           a=''
           FOR i=0,4 DO BEGIN 
               readu, unit, a
               comment(i)=a
           ENDFOR 
       END ELSE BEGIN 
           numcom=0
           readu,unit,numcom
           comment=strarr(numcom)
           FOR i=0,numcom-1 DO BEGIN 
               readu,unit,a
               comment(i)=a
           END 
           a=''
       END 
   END ELSE BEGIN 
       comment(0)='File does not contain comment-string'
   END
       
   ;; ... number of spectra
   nfil=0
   readu,unit,nfil
   IF (n_elements(nsp) NE 0) THEN BEGIN 
       IF (nfil GT nsp) THEN nfil=nsp
   END 
   
   ;; Initialize speclib if necessary
   speclib 
   spectra=replicate({spectrum},nfil)
   ;;
   ;; Read Spectra one at a time
   ;;
   FOR i=0,nfil-1 DO BEGIN 
       tmp=string(format='(A100)',' ')
       readu,unit,tmp & spectra(i).desc=strtrim(tmp,2)
       tmp=0       
       readu,unit,tmp & spectra(i).len=tmp
       readu,unit,tmp & spectra(i).flux=tmp
       tmp=fltarr(spectra(i).len+1)
       readu,unit,tmp & spectra(i).e(0:spectra(i).len)=tmp
       tmp=fltarr(spectra(i).len)
       readu,unit,tmp & spectra(i).f(0:spectra(i).len-1)=tmp
       readu,unit,tmp & spectra(i).err(0:spectra(i).len-1)=tmp
       tmp=0.
       readu,unit,tmp & spectra(i).sat=tmp
   ENDFOR
   ;;
   ;; That's it!
   ;;
   free_lun,unit 

   nsp=nfil

   IF (keyword_set(verb)) THEN print, '... done'
END 
