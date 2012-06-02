PRO hexeread, spe, filename,nsp,verbose=verb
   ;;
   ;; Read a HEXE-spectrum (adopted from code by MGM)
   ;;
   IF (keyword_set(verb)) THEN print, 'Reading HEXE: '+filename

   IF (n_elements(nsp) GT 0) THEN BEGIN 
       IF (keyword_set(verb) AND (nsp GT 1)) THEN BEGIN 
           print, 'HEXE-Files only contain one spectrum'
           print, 'setting nsp to 1'
       ENDIF 
       nsp=1
   ENDIF 

   zeile= strarr(1)
   npts=byte(0)
   npts1=byte(0)
   npts2=byte(0)
   icon=byte(0)
   syserr=fltarr(3)
   nfun=byte(0)
   chisqr=fltarr(1)
   eref=fltarr(1)
   nfree=byte(0)
   nparm=byte(0)
   
   ;;
   ;; find file
   ;;
   save=filename
   paths=['','/usr/users/wilms/','/usr/users/wilms/idl/kotelpidl/']
   aa=findfile(filename,count=nfil)
   pp=0
   WHILE ((nfil EQ 0) AND (pp LT 3)) DO BEGIN 
       filename=paths(pp)+save
       aa=findfile(filename,count=nfil)
       pp=pp+1
   END 
   ;;
   IF (nfil EQ 0) THEN BEGIN 
       message,'File does not exist: '+save
   ENDIF 
   
   ;;
   ;;  read the header information
   ;;
   openr,unit,filename,/get_lun
   readf,unit,icon
   readf,unit,zeile
   readf,unit,nfun,chisqr,eref,nfree,nparm

   fpar=fltarr(nparm)
   readf,unit,fpar

   readf,unit,npts,npts1
   
   ;;
   ;; read the data themselves
   ;;

   source=strmid(zeile(0),0,8)

   xa=fltarr(6,npts)
   readf,unit,xa

   IF (npts1 GT 1) THEN BEGIN
       xb=fltarr(6,npts1)
       readf,unit,xb
   ENDIF

   readf,unit,npts2
   y=fltarr(5,npts2)
   readf,unit,y

   free_lun,unit
   
   ;;
   ;; Convert photon-spectrum to spectrum data-structure
   ;;
   nd=where(y(3,*) NE 0.)
   nel=n_elements(nd)
   speclib
   spe=replicate({spectrum},1)
   spe.desc='HEXE: '+source
   spe.len=nel
   spe.e=y(0,nd)
   spe.e(nel)=y(1,nd(nel-1))
   spe.f=y(2,nd)
   spe.err=y(3,nd)
   spe.flux=3
END 
