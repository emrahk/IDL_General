;
; Convert kotelp ASCII .spe-files to .xdf for faster reading
;

;
; Find all files
;
a=-1
WHILE ((a NE 0) AND (a NE 1)) DO BEGIN 
    read, 'Want to translate a whole subdir (0) or one file (1)? ',a
END 
IF (a EQ 0) THEN BEGIN 
    subdir=''
    read,'Please input subdirectory (no trailing /, please): ',subdir
    filelist=findfile(subdir+'/*.spe.gz',count=nfil)
    IF (nfil EQ 0) THEN BEGIN 
        print, ' No files found, sorry'
        stop
    ENDIF 
END ELSE BEGIN 
    filelist=''
    read,'Please input Filename: ',filelist
    nfil=1
END 

FOR i=0,nfil-1 DO BEGIN 
    filesplit,filelist(i),path,fil,ext
    ;;
    ;; Read old kotelp files
    ;;
    specread,spe,filelist(i),/verbose
    ;;
    ;; Write kotelp-files as .xdr
    ;;
    specwrite,spe,fil,/verbose
END 

END
