;
; Read spectra.
; spectra : Array of spectra read
; filename: Name of file to read
; nsp     : number of spectra read
; verbose : set this keyword if you want progress-information
; type    : 0: normal, 1: mcxxx, 2: kotelp, 3: XDR
; comment : if file contains comments (currently only XDR, version2),
;           they are returned here.
;
; The subroutine attempts to guess the type of the file correctly,
; and to dispatch the correct subroutine.
;
pro specread, spectra, filen, nsp,verbose=verb,type=type,comment=comment
   on_error, 1
   ;;
   filename=strtrim(filen,2)
   save=filename
   ;;
   ;; Only proceed if file exists
   ;;
   ii=0
   pp=0
   nfil=0
   ending=['','.spe.xdr','.spe.xdr.gz','.spe','.spe.gz']
   paths=['','/usr/users/wilms/','/usr/users/wilms/idl/kotelpidl/']
   aa=findfile(filename,count=nfil)
   WHILE ((nfil EQ 0) AND (pp LT 3)) DO BEGIN
       filename=paths(pp)+save+ending(ii)
       aa=findfile(filename,count=nfil)
       ii=ii+1
       IF (ii EQ 5) THEN BEGIN 
           ii=0
           pp=pp+1
       ENDIF 
   END 
   ;;
   if (nfil EQ 0) then begin
       message, 'File does not exist: '+save
   ENDIF
   ;;
   ;; Try to get type of spectrum if type not set
   ;;
   IF (n_elements(type) EQ 0) THEN BEGIN  
      ;; Kotelp-spectra end with .spe
       stl=strlen(filename)
       IF ((strpos(filename,'.spe') EQ stl-4) AND (stl NE 4)) THEN type=2
       IF ((strpos(filename,'.spe.gz') EQ stl-7) AND (stl NE 7)) THEN type=2
       IF ((strpos(filename,'.spe.xdr') EQ stl-8) AND (stl NE 8)) THEN type=3
       IF (strpos(filename,'.spe.xdr.gz') EQ stl-11) THEN BEGIN 
           IF (stl NE 11) THEN type=3
       ENDIF
   ENDIF
   ;;
   ;; If file ends with .gz, gunzip it first
   ;;
   temp=''
   IF (strpos(filename,'.gz') EQ strlen(filename)-3) THEN BEGIN 
       temp=tmpnam('sprd')
       IF (keyword_set(verb)) THEN print, 'Uncompressing '+filename
       spawn,'zcat '+filename+' > '+temp,/sh
       filename=temp
   endif
   IF (n_elements(type) EQ 0) THEN BEGIN
       ;;
       ;; Open file, read the first few lines, there's a difference
       ;; between the Mc-output and a normal spectrum in the 1st
       ;; program-line
       ;;
       openr, unit, filename,/get_lun
       dummy=''
       readf, unit, dummy
       ;; if 1 number in 1st line: normally formatted spectrum
       type=1
       if (strmid(dummy,2,1) eq ' ') then type=0
       ;;
       close, unit
       free_lun, unit
   ENDIF 

   if (type eq 0) then begin
       if (keyword_set(verb)) then print, 'Reading normal spectrum'
       normread,spectra,filename,nsp,verbose=verb
   ENDIF
   if (type eq 1) then begin
       if (keyword_set(verb)) then print, 'Reading MCxxx spectrum'
       mcread,spectra,filename,nsp,verbose=verb
   endif
   if (type eq 2) then begin
       if (keyword_set(verb)) then print, 'Reading kotelp spectrum'
       kotread,spectra,filename,nsp,verbose=verb
   ENDIF
   if (type eq 3) then begin
       if (keyword_set(verb)) then print, 'Reading XDR spectrum'
       xdrread,spectra,filename,nsp,verbose=verb,comment=comment
   ENDIF
   IF (keyword_set(verb)) THEN BEGIN 
       IF (nsp ne 1) THEN BEGIN 
           print, nsp, ' spectra read'
       END ELSE BEGIN 
           print, '1 spectrum read'
       ENDELSE 
   END 
   IF (filename EQ temp) THEN BEGIN
       IF (keyword_set(verb)) THEN print, 'Deleting '+temp
       spawn, 'rm -f '+temp
   ENDIF 
END 

