;
; Write Arf-File
;
PRO writearf,energy,arf,arffile,origin=origin,$
              telescope=telescope,instrument=instrument,filter=filter
   ;;
   ;; Write ancilliary response file
   ;;    Format has been defined in OGIP memos CAL-GEN 92-002 and 002a
   ;;
   ;;    energy    : lower bounds of energy-channels
   ;;    arf       : "effective area" corresponding to energy channel
   ;;    arffile   : filename of ARF-File
   ;;    telescope : ID of telescope (default:fake)
   ;;    instrument: ID of instrument
   ;;    filter    : filter used (default: none)
   ;;    origin    : institution where file was created
   ;;    caldb     : set, if caldb-entries are to be written; implies:
   ;;    utcday    :   utc (dd/mm/yy) when this data should be first used
   ;;    utctime   :   utc (hh:mm:ss) when this data should be first used
   ;;    caldes    :   description of entry
   ;;
   ;; joern wilms
   ;; wilms@astro.uni-tuebingen.de
   ;; 1995/1996
   ;;
   filename=arffile
   ;;
   ;; Consistency check
   ;;
   nen=n_elements(arf)-1
   IF (nen NE n_elements(energy)-2) THEN BEGIN 
       message,'Number of energies in arf and energy do not agree'
   ENDIF 
   ;;
   ;; Default Values for mandatory keywords
   ;;
   IF (n_elements(telescope) EQ 0) THEN telescope='unknown'
   IF (n_elements(instrument) EQ 0) THEN instrument='none'
   IF (n_elements(filter) EQ 0) THEN filter='none'
   ;;
   ;; Create ARF File
   ;;
   fxhmake,header,/initialize,/extend,/date
   fxaddpar,header,'CONTENT','Ancilliary Response'
   fxaddpar,header,'FILENAME',filename,'Name of this file'
   fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'FILTER', filter,'Filter used for observation'

   IF (n_elements(origin) NE 0) THEN BEGIN 
       fxaddpar,header,'ORIGIN',origin,'Organization which created this file'
   ENDIF 
   ;;
   fxwrite,filename,header
   ;;
   ;; Create ARF extension
   ;;
   ;; ... header
   fxbhmake,header,nen+1,'SPECRESP',/initialize,/date
   fxaddpar,header,'TELESCOP',telescope,'Telescope (mission) name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'FILTER', filter,'Filter used for observation'
   fxaddpar,header,'ARFVERSN','1992a','OGIP version number of FITS format'
   fxaddpar,header,'HDUCLASS','OGIP','Organization which devised File-Format'
   fxaddpar,header,'HDUCLAS1','RESPONSE','Extension includes Instrument RMF'
   fxaddpar,header,'HDUVERS1','1.0.0','Version of HDUCLAS1 Format'
   fxaddpar,header,'HDUCLAS2','SPECRESP','Type of Data'
   fxaddpar,header,'HDUVERS2','1.1.0','Version of HDUCLAS2 Format'
   ;;
   ;; CALDB
   IF (keyword_set(caldb)) THEN BEGIN 
       IF (n_elements(uday)*n_elements(utime)*n_elements(caldes) EQ 0) THEN  $
         BEGIN 
           message,'need utcday,utctime,caldes for caldb-entry'
       END
       fxaddpar,header,'CCLS0001','CPF','OGIP class of calibration file'
       fxaddpar,header,'CCNM0001','SPECRESP','Anc. Responsefile'
       fxaddpar,header,'CDTP0001','DATA','OGIP code for contents'  
       fxaddpar,header,'CVSD0001',uday,'UTC for first use of data'
       fxaddpar,header,'CVST0001',utime,'UTC for first use of data'
       fxaddpar,header,'CDES0001',caldes,'Summary of dataset'
   ENDIF 
   ;;
   ;; ... define columns
   ;;
   fxbaddcol,ndx,header,energy(0),'ENERG_LO',  $
     'Low Energy Bound of PHA Channel',tunit='keV'
   fxbaddcol,ndx,header,energy(0),'ENERG_HI',  $
     'High Energy Bound of PHA Channel',tunit='keV'
   fxbaddcol,ndx,header,arf(0),'SPECRESP',tunit='cm2'
   ;;
   fxbcreate,unit,filename,header
   ;;
   ;; ... now write data
   FOR i=0,nen DO BEGIN
       i1=i+1
       fxbwrite,unit,energy(i),1,i1
       fxbwrite,unit,energy(i+1),2,i1
       fxbwrite,unit,arf(i),3,i1
   ENDFOR 
   ;;
   ;; Write file to disk
   ;;
   fxbfinish,unit
END 
