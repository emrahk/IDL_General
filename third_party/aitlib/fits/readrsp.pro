PRO readrsp,energy,channel,matrix,type,filename,telescope=telescope, $
            instrument=instrument,filter=filter,phafile=phafile, $
            threshold=thresh,origin=origin,caldb=caldb,utcday=uday, $
            utctime=utime,caldes=caldes,verbose=verbose,variable=variable, $
            nomatrix=nomatrix
;+
; NAME:
;           readrsp
;
;
; PURPOSE:
;           Read a OGIP conformant response matrix
;
;
; CATEGORY:
;           High energy astrophysics
;
;
; CALLING SEQUENCE:
;           readrsp,energy,channel,matrix,type,filename
;
;
; INPUTS:
;           filename: filename of the matrix to be read
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;      caldb     : set if caldb-entries are to be read; implies:
;                    utcday,utctime,caldes as outputs
;      variable  : if set, matrix contains variable length entries
;                  (cludge, uses other version of fxbread)
;      nomatrix  : if set, no matrix is read (speeds up things)
;
; OUTPUTS:
;      energy    : array defining the energy-bins of the RMF
;                  (consecutive energies are assumed!)
;      channel   : array defining the energy-bins corresponding to
;                  each channel
;      matrix    : matrix defining the energy to channel conversion
;                  Dimension is matrix(energy-1,channel-1), thus
;                  matrix(3,6) is the probability that a photon with
;                  photon energy between energy(3) and energy(4) will
;                  end up in channel 6 (provided that the
;                  "real-life" channel numbering scheme starts in channel 0)
;
; OPTIONAL OUTPUTS:
;      telescope : Telescope for which the rmf is given
;      instrument: instrument for which the rmf is given
;      filter    : filter for which the rmf is given
;      phafile   : phafile for which the rmf has been computed
;      origin    : origin of rsp-file
;      threshold : all entries in the matrix smaller than threshold are set
;                  to zero
;      type      : 0 for pure redistribution (each row is normalized
;                    to unity)
;                  1 matrix contains all energy dependent effects,
;                    i.e. the ARF is included.
;      the following require that /caldb be set
;      utcday    :     utc (dd/mm/yy) when this data should be first used
;      utctime   :     utc (hh:mm:ss) when this data should be first used
;      caldes    :     description of entry
;
; PROCEDURE:
;   see Legacy, 2, p.51ff and OGIP memo CAL-GEN 92-002 and 002a
;
; MODIFICATION HISTORY:
;      written a long time ago (1996?) by Joern Wilms
;      Version 1.0: 2000/06/15: added documentation header
;
;-
   ;;
   ;;

   ;;
   ;; Read PHA channels (EBOUNDS extension)
   ;;
   ;; ... header
   fxbopen,unit,filename,'EBOUNDS',header
   ;;
   ;; Required Keywords
   ;;
   getpar,header,'TELESCOP',telescope
   getpar,header,'INSTRUME',instrument
   getpar,header,'FILTER', filter
   a=''
   getpar,header,'RMFVERSN',a
   IF (strtrim(a,2) NE '1992a') THEN BEGIN 
       IF (keyword_set(verbose)) THEN BEGIN 
           print,'Warning: RMF-Version not 1992a in EBOUNDS extension'
       ENDIF 
   ENDIF 
   nch=0
   getpar,header,'DETCHANS',nch
   ;;
   ;; Optional Keywords
   ;;
   getpar,header,'PHAFILE',phafile
   ;;
   ;; CALDB
   ;;
   IF (keyword_set(caldb)) THEN BEGIN 
       getpar,header,'CCLS0001','CPF'
       IF (strtrim(a,2) NE 'EBOUNDS') THEN BEGIN 
           IF (keyword_set(verbose)) THEN BEGIN 
               print,'Warning: EBOUNDS do not contain CALDB-Entries'
           END 
       END ELSE BEGIN 
           getpar,header,'CVSD0001',uday
           getpar,header,'CVST0001',utime
           getpar,header,'CDES0001',caldes
       END 
   ENDIF 
   ;;
   ;; ... now read
   ;;
   ch1=0.
   ch2=0.
   channel=fltarr(nch+1)

   FOR i=0,nch-1 DO BEGIN 
       i1 = i+1
       fxbread,unit,ch1,'E_MIN',i1
       IF (i NE 0) THEN BEGIN 
           IF (channel(i) NE ch1) THEN BEGIN
               message,'Channels in EBOUNDS have gaps or overlap'
           ENDIF 
       ENDIF 
       channel(i)=ch1
       fxbread, unit,ch2,'E_MAX',i1
       channel(i1)=ch2
   ENDFOR 
   fxbclose,unit

   IF (keyword_set(nomatrix)) THEN return 

   ;;
   ;; Read Response Matrix Extension
   ;;
   ;; ... header
   ;;
   ;; Mandatory keywords
   ;;
   errmsg=''
   fxbopen,unit,filename,'MATRIX',header,errmsg=errmsg
   IF (errmsg EQ 'Requested extension not found') THEN BEGIN 
       fxbopen,unit,filename,'SPECRESP MATRIX',header
   ENDIF 

   getpar,header,'TELESCOP',telescope
   getpar,header,'INSTRUME',instrument
   getpar,header,'FILTER', filter
   a=''
   getpar,header,'RMFVERSN',a
   IF (strtrim(a,2) NE '1992a') THEN BEGIN 
       IF (keyword_set(verbose)) THEN BEGIN 
           print,'Warning: RMF-Version not 1992a in MATRIX extension'
       ENDIF 
   ENDIF 
   nch2=0
   getpar,header,'DETCHANS',nch2
   IF (nch2 NE nch) THEN BEGIN 
       print,'Warning: channel number in EBOUNDS and MATRIX differ!'
   ENDIF 
   nen=0
   getpar,header,'NAXIS2',nen

   ;;
   ;; Start and End channel
   ;;
   tlmin4=0
   tlmax4=0
   getpar,header,'TLMIN4',tlmin4
   getpar,header,'TLMAX4',tlmax4
   ;;
   type=1
   getpar,header,'HDUCLASS',a
   IF (strtrim(a,2) NE 'OGIP') THEN BEGIN 
       print,'Warning: MATRIX extension does not contain OGIP conformant'
       print,'  keywords. Assuming that response is total response'
   END ELSE BEGIN 
       getpar,header,'HDUCLAS3',a
       IF (strtrim(a,2) EQ 'REDIST') THEN type=0
   END 
   ;;
   ;; Optional Keywords
   ;;
   getpar,header,'PHAFILE',phafile
   thresh=0.
   getpar,header,'LO_THRES',thresh
   ;; CALDB-Entry
   IF (keyword_set(caldb)) THEN BEGIN 
       getpar,header,'CCLS0001','CPF'
       IF (strtrim(a,2) NE 'EBOUNDS') THEN BEGIN 
           IF (keyword_set(verbose)) THEN BEGIN 
               print,'Warning: EBOUNDS do not contain CALDB-Entries'
           END 
       END ELSE BEGIN 
           getpar,header,'CVSD0001',uday
           getpar,header,'CVST0001',utime
           getpar,header,'CDES0001',caldes
       END 
   ENDIF 
   ;;
   ;; ... now read matrix
   ;;
   en0=0.
   en1=0.
   ngrp=0
   chstart=0
   nchan=0

   energy=fltarr(nen+1)
   matrix=fltarr(nen,nch2)

   FOR i=0,nen-1 DO BEGIN 
       i1=i+1
       fxbread,unit,en0,'ENERG_LO',i1
       fxbread,unit,en1,'ENERG_HI',i1
       IF (i NE 0) THEN BEGIN 
           IF (en0 NE energy(i)) THEN BEGIN 
               message,'Energies in MATRIX have gaps or overlap'
           ENDIF 
       ENDIF 
       energy(i)=en0
       energy(i1)=en1
       ;; Ngrp: only one channel subset so far 
       fxbread,unit,ngrp,'N_GRP',i1
       ;; Starting channels and length
       fxbread,unit,chstart,'F_CHAN',i1
       fxbread,unit,nchan,'N_CHAN',i1
       ;; Read Row
       row=0.
       IF (nchan(0) GT 0) THEN BEGIN 
           IF (keyword_set(variable)) THEN BEGIN 
               jwfxbread,unit,row,'MATRIX',i1,/variable
           END ELSE BEGIN 
               fxbread,unit,row,'MATRIX',i1,dimension=nchan(0)
           END 
           beg=0
           FOR j=0,ngrp-1 DO BEGIN 
               ;; 1st channel is always in row 0 in IDL
               chano=chstart(j)-tlmin4
               ende=beg+nchan(j)-1
               matrix(i,chano:chano+nchan(j)-1)=row(beg:ende)
               beg=ende+1
           ENDFOR 
       ENDIF 
   ENDFOR 
   fxbclose,unit
END 
