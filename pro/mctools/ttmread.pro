PRO ttmread, spe, filename,nsp,verbose=verb,estart=estart
   ;;
   ;; Read a TTM-spectrum (from files filename.x and filename.y)
   ;;
   IF (keyword_set(verb)) THEN print, 'Reading TTM: '+filename

   IF (n_elements(nsp) GT 0) THEN BEGIN 
       IF (keyword_set(verb) AND (nsp GT 1)) THEN BEGIN 
           print, 'TTM-Files only contain one spectrum'
           print, 'setting nsp to 1'
       ENDIF 
       nsp=1
   ENDIF 
   
   ;;
   ;; find file
   ;;
   save=filename
   paths=['','/usr/users/wilms/','/usr/users/wilms/idl/kotelpidl/']
   aa=findfile(filename+'.x',count=nfil)
   pp=0
   WHILE ((nfil EQ 0) AND (pp LT 3)) DO BEGIN 
       filename=paths(pp)+save
       aa=findfile(filename+'.x',count=nfil)
       pp=pp+1
   END 
   ;;
   IF (nfil EQ 0) THEN BEGIN 
       message,'File does not exist: '+save
   ENDIF 
   
   tmp=fltarr(200)
   openr,unit,filename+'.x',/get_lun
   num=0
   dummy=0.
   WHILE NOT eof(unit) DO BEGIN 
       readf,unit,dummy
       tmp(num)=dummy
       num=num+1
   END
   free_lun,unit
   e=tmp(0:num-1)
   f=fltarr(num)
   openr,unit,filename+'.y',/get_lun
   readf,unit,f
   free_lun,unit
   ;;
   ;; Convert photon-spectrum to spectrum data-structure
   ;;
   speclib
   spe=replicate({spectrum},1)
   spe.desc='TTM-spectrum'
   spe.len=num
   ;; Compute energy boundaries; for lowest boundary assume log-spacing
   IF (n_elements(estart) EQ 0) THEN BEGIN 
       spe.e(0)= 10.^(alog10(e(0))-0.5*alog10(e(1)/e(0)))
   END ELSE BEGIN 
       spe.e(0)=estart
   END
   IF (keyword_set(verb)) THEN print,'Estart: ',spe.e(0)
   FOR i=0, num-1 DO BEGIN 
       spe.e(i+1)=e(i)*e(i)/spe.e(i)
   ENDFOR 
   spe.f(0:num-1)=f
   spe.err(*)=0.
   spe.flux=3
END 
