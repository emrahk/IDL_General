PRO writersp,energy,channel,matrix,filename,telescope=telescope, $
              instrument=instrument,filter=filter,phafile=phafile, $
              threshold=thresh,origin=origin,caldb=caldb,utcday=uday, $
              utctime=utime,caldes=caldes,normalize=normalize,full=full
   ;;
   ;; Write response matrix
   ;;   (see Legacy, 2, p.51ff and OGIP memo CAL-GEN 92-002 and 002a)
   ;;   Insert all the necessary header-information
   ;;
   ;;  energy    : array defining the energy-bins of the RMF
   ;;              (consecutive energies are assumed!)
   ;;  channel   : array defining the energy-bins corresponding to
   ;;              each channel
   ;;  matrix    : matrix defining the energy to channel conversion
   ;;              Dimension is matrix(energy-1,channel-1), thus
   ;;              matrix(3,6) is the probability, that a photon with
   ;;              photon energy between energy(3) and energy(4) will
   ;;              end up in channel 7 (remember that the
   ;;              channel-number starts at 1!).
   ;;  filename  : filename of the rsp-file
   ;;  telescope : Telescope for which the rmf is given
   ;;  instrument: instrument for which the rmf is given
   ;;  filter    : filter for which the rmf is given
   ;;  phafile   : phafile for which the rmf has been computed
   ;;  origin    : origin of rsp-file
   ;;  threshold : all entries in the matrix smaller than that are set
   ;;              to zero
   ;;  normalize : if set: normalize each row to unity (i.e. pure
   ;;              redistribution) 
   ;;  full      : Matrix contains ALL energy-dependent effects of the
   ;;              whole instrument (i.e. no ARF will be needed)
   ;;  caldb     : set, if caldb-entries are to be written; implies:
   ;;  utcday    :   utc (dd/mm/yy) when this data should be first used
   ;;  utctime   :   utc (hh:mm:ss) when this data should be first used
   ;;  caldes    :   description of entry
   ;;

   ;;
   ;; Consistency check
   ;;
   nen= fix(n_elements(energy)-1)
   nch= fix(n_elements(channel)-1)

   IF (nen NE n_elements(matrix(*,0))) THEN BEGIN 
       message,'Number of energy-channels in matrix is wrong'
   ENDIF
   IF (nch NE n_elements(matrix(0,*))) THEN BEGIN 
       message,'Number of channels in matrix is wrong'
   ENDIF
   ;;
   IF (keyword_set(full) AND (keyword_set(normalize))) THEN BEGIN 
       message,'Only one of the keywords full and normalize is allowed'
   ENDIF 
   ;;
   ;; Set required keywords to default-values if not given
   ;;
   IF (n_elements(telescope) EQ 0) THEN telescope='unknown'
   IF (n_elements(instrument) EQ 0) THEN instrument='none'
   IF (n_elements(filter) EQ 0) THEN filter='none'
   ;;
   ;; Create top header
   ;;
   fxhmake,header,/initialize,/extend,/date
   fxaddpar,header,'CONTENT','RESPONSE','File contains Response-matrix'
   fxaddpar,header,'FILENAME',filename,'Name of this file'
   IF (n_elements(origin) NE 0) THEN BEGIN 
       fxaddpar,header,'ORIGIN',origin,'Organization which created this file'
   ENDIF 
   ;;
   fxwrite,filename,header
   ;;
   ;; Define PHA channels (EBOUNDS extension)
   ;;    --> There is an inconsistency in the OGIP Memo; as the RMF
   ;;    contains variable length keywords, it has to be the last
   ;;    extension in the FITS file (that is at least true for the IDL
   ;;    fits_bintable subroutines); thus, even if EBOUNDS is
   ;;    described AFTER the RMF, the extension has to go IN FRONT of
   ;;    the RMF.
   ;;
   ;; ... header
   fxbhmake,header,nch,'EBOUNDS',/initialize,/date
   ;;
   ;; Required Keywords
   ;;
   fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'FILTER', filter,'Filter used for observation'
   fxaddpar,header,'RMFVERSN','1992a',$
     'OGIP classification of FITS format style'
   fxaddpar,header,'CHANTYPE','PHA','Uncorrected detector channels'
   fxaddpar,header,'DETCHANS',nch,'Total number of detector PHA channels'
   fxaddpar,header,'HDUCLASS','OGIP','Organization which devised File-Format'
   fxaddpar,header,'HDUCLAS1','RESPONSE','Extension includes Instrument RMF'
   fxaddpar,header,'HDUVERS1','1.0.0','Version of HDUCLAS1 Format'
   fxaddpar,header,'HDUCLAS2','EBOUNDS','Type of Data'
   fxaddpar,header,'HDUVERS2','1.1.0','Version of HDUCLAS2 Format'
   ;;
   ;; Optional Keywords
   ;;
   IF (n_elements(phafile) NE 0) THEN BEGIN
       fxaddpar,header,'PHAFILE',phafile,'File for which PHA was produced'
   ENDIF 
   ;; CALDB
   IF (keyword_set(caldb)) THEN BEGIN 
       IF (n_elements(uday)*n_elements(utime)*n_elements(caldes) EQ 0) THEN  $
         BEGIN 
           message,'need utcday,utctime,caldes for caldb-entry'
           stop
       END
       fxaddpar,header,'CCLS0001','CPF','OGIP class of calibration file'
       fxaddpar,header,'CCNM0001','EBOUNDS','Energy Bounds for channels'
       fxaddpar,header,'CDTP0001','DATA','OGIP code for contents'  
       fxaddpar,header,'CVSD0001',uday,'UTC for first use of data'
       fxaddpar,header,'CVST0001',utime,'UTC for first use of data'
       fxaddpar,header,'CDES0001',caldes,'Summary of dataset'
   ENDIF 
   ;;
   ;; ... columns
   fxbaddcol,ndx,header,1,'CHANNEL','raw channel number'
   fxbaddcol,ndx,header,channel(0),'E_MIN',$
     'energy of lower boundary',tunit='keV'
   fxbaddcol,ndx,header,channel(1),'E_MAX',$
     'energy of upper boundary',tunit='keV'
   ;;
   fxbcreate,unit,filename,header
   ;;
   ;; ... now write
   ;;
   FOR i=0,nch-1 DO BEGIN 
       i1 = i+1
       fxbwrite,unit,i1,1,i1
       fxbwrite,unit,channel(i),2,i1
       fxbwrite,unit,channel(i+1),3,i1
   END 
   fxbfinish,unit
   ;;
   ;; Create Response Matrix Extension
   ;;
   ;; ... header
   ;;
   ;; Mandatory keywords
   ;;
   fxbhmake,header,nen,'MATRIX',/initialize,/date 
   fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'FILTER', filter,'Filter used for observation'
   fxaddpar,header,'RMFVERSN','1992a', $
     'OGIP classification of FITS format style'
   fxaddpar,header,'CHANTYPE','PHA','Uncorrected detector channels'
   fxaddpar,header,'DETCHANS',nch,'Total number of detector PHA channels'
   fxaddpar,header,'HDUCLASS','OGIP','Organization which devised File-Format'
   fxaddpar,header,'HDUCLAS1','RESPONSE','Extension includes Instrument RMF'
   fxaddpar,header,'HDUVERS1','1.0.0','Version of HDUCLAS1 Format'
   fxaddpar,header,'HDUCLAS2','RSP_MATRIX','Type of Data'
   fxaddpar,header,'HDUVERS2','1.1.0','Version of HDUCLAS2 Format'
   IF (keyword_set(normalize)) THEN BEGIN 
       fxaddpar,header,'HDUCLAS3','REDIST','Matrix is Redistribution Matrix'
   END ELSE BEGIN 
       IF (keyword_set(full)) THEN BEGIN 
           fxaddpar,header,'HDUCLAS3','FULL','Matrix describes full instrument'
       END ELSE BEGIN 
           fxaddpar,header,'HDUCLAS3','DETECTOR','Matrix describes detector'
       END 
   END 
   ;;
   ;; Optional Keywords
   ;;
   IF (n_elements(phafile) NE 0) THEN BEGIN
       fxaddpar,header,'PHAFILE',phafile,'File for which PHA was produced'
   ENDIF 
   IF (n_elements(thresh) NE 0) THEN BEGIN 
       fxaddpar,header,'LO_THRES',thresh,'Lower threshold of Matrix'
       IF (thresh GT max(matrix)) THEN BEGIN 
           message,'Threshold is larger than max. value of matrix'
       END 
   END ELSE BEGIN 
       ;; don't write out elements that are equal to zero
       thresh=0.
   END 
   ;; CALDB-Entry
   IF (keyword_set(caldb)) THEN BEGIN 
       fxaddpar,header,'CCLS0001','CPF','OGIP class of calibration file'
       fxaddpar,header,'CCNM0001','MATRIX','Response Matrix Extension'
       fxaddpar,header,'CDTP0001','DATA','OGIP code for contents'  
       fxaddpar,header,'CVSD0001',uday,'UTC for first use of data'
       fxaddpar,header,'CVST0001',utime,'UTC for first use of data'
       fxaddpar,header,'CDES0001',caldes,'Summary of dataset'
   END 
   ;;
   ;; ... define columns
   ;;
   fxbaddcol,ndx,header,energy(0),'ENERG_LO',  $
     'Low Energy Bound of PHA Channel',tunit='keV'
   fxbaddcol,ndx,header,energy(0),'ENERG_HI',  $
     'High Energy Bound of PHA Channel',tunit='keV'
   ;;
   ;; so far we only allow for one channel subset
   ;;
   fxbaddcol,ndx,header,[1],'N_GRP', 'no. of channel subsets'
   fxbaddcol,ndx,header,[1],'F_CHAN','no. of starting channel'
   fxbaddcol,ndx,header,[nch],'N_CHAN','no. of channels in subset'
   ;;
   ;; Determine widths of rows
   ;;
   ndstart=intarr(nen)
   ndend=intarr(nen)
   FOR i=0,nen-1 DO BEGIN 
       ;; Find part of row of matrix that is larger than thresh
       nd=fix(where(matrix(i,*) GT thresh))
       IF (nd(0) EQ -1) THEN BEGIN
           ndstart(i)=0 & ndend(i)=nch-1
       END ELSE BEGIN
           IF (n_elements(nd) GT 1) THEN BEGIN 
               ndstart(i)=min(nd) & ndend(i)=max(nd)
           END ELSE BEGIN 
               ndstart(i)=nd(0) & ndend(i)=nd(0)
           END
       END 
   ENDFOR
   width=ndend-ndstart+1
   maxwidth=max(width)
   minwidth=min(width) 
   ;;
   ;; If subsets vary by more than 10 entries in size: use variable
   ;; length entry
   ;;
   IF (maxwidth GT minwidth+10) THEN BEGIN 
       variable=1
   END ELSE BEGIN 
       variable=0
       ;; force fixed length
       ndend(*)=ndstart(*)+maxwidth-1
       width(*)=maxwidth
       nd=where(ndend(*) GE nch)
       ;; Prevent "overfloating"
       IF (nd(0) NE -1) THEN BEGIN 
           ndstart(nd)=nch-maxwidth
           ndend(nd)=nch-1
       ENDIF
   END
   fxbaddcol,ndx,header,fltarr(maxwidth),'MATRIX','Response Matrix', $
     variable=variable
   ;;
   fxbcreate,unit,filename,header
   ;;
   ;; ... now write
   ;;
   FOR i=0,nen-1 DO BEGIN 
       i1=i+1
       fxbwrite,unit,energy(i),1,i1
       fxbwrite,unit,energy(i+1),2,i1
       ;; Ngrp: only one channel subset so far 
       fxbwrite,unit,[1],3,i1
       ;; Fchan: starting channel is ndstart(i)
       fxbwrite,unit,[ndstart(i)+1],4,i1
       ;; Nchan: next width channels are o.k.
       fxbwrite,unit,[width(i)],5,i1
       ;; Select row
       row=matrix(i,ndstart(i):ndend(i))
       ;; Pad with zero where necessary
       nd=where(row LE thresh)
       IF (nd(0) NE -1) THEN row(nd)=0.
       ;; Normalize
       IF (keyword_set(normalize)) THEN row=row/total(row)
       fxbwrite,unit,row,6,i1
   ENDFOR 
   ;;
   ;; Write file to disk
   ;;
   fxbfinish,unit
END 
