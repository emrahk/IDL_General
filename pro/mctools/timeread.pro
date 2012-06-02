;;
;; timeread.pro: Read timelag-file produced by mcxxx
;;
;; J.Wilms, 1996/12/01
;; Version 1.0
;; 1997/01/29
;; Version 1.1: Also bin number of scatterings in timelag
;; Version 1.2, JW, 2000/10/23: update to timxdr,v3 format
;;  (the old version must have been lost somewhere...)
;;
PRO timeread,time,energy,nsc,lags,filename,verbose=verbose,comment=comment
   ;;
   ;; time: 
   ;; comment: Information about the simulation
   ;;
   IF (keyword_set(verbose)) THEN print, 'Reading .tim.xdr-File: '+filename

   openr, unit, filename, /get_lun, /xdr
   
   ;;
   ;; ... check type of file
   a='timxdr,jw,1996'
   readu,unit,a
   version=-1
   IF (a EQ 'timxdr,jw,1996') THEN version=1
   IF (a EQ 'timxdr,jw,1997') THEN version=2
   IF (a EQ 'timxdr,v3,1999') THEN version=3
   IF (version EQ -1) THEN message, 'File is not a .tim.xdr-File'
   ;;
   ;; Comment in file
   ;;
   IF (version LT 3) THEN BEGIN 
       comment=strarr(5)
       a=''
       FOR i=0,4 DO BEGIN 
           readu,unit,a
           comment(i)=a
       ENDFOR 
   END ELSE BEGIN 
       numcom=0
       readu,unit,numcom
       comment=strarr(numcom)
       a=''
       FOR i=0,numcom-1 DO BEGIN 
           readu,unit,a
           comment[i]=a
       END 
   END 
   ;;
   ;; ... read energy bins
   nen=0
   readu,unit,nen
   energy=fltarr(2,nen)
   readu,unit,energy
   energy=transpose(energy)
   ;;
   ;; Number of scatterings
   ;;
   IF (version GE 2) THEN BEGIN 
       nsc=intarr(nen)
       readu,unit,nsc
   ENDIF
   ;;
   ;; ... time resolution
   ;;
   res=0.
   readu,unit,res
   ;;
   ;; ... read timing bins
   ntim=0
   readu,unit,ntim
   lags = fltarr(ntim,nen)
   readu,unit,lags
   lags=transpose(lags)
   ;;
   ;; ... done
   free_lun,unit
   ;;
   ;; ... produce time from time resolution
   time=(1+findgen(ntim))*res
END
