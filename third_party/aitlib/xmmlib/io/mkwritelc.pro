PRO mkwritelc,file,time,rate,error,outpath=outpath,$
              telescope=telescope,model=model,ccdmode=ccdmode,quadrant=quadrant,$
              campaign=campaign,filter=filter,dateobs=dateobs,dateend=dateend,$
              chatty=chatty
;+
; NAME:            mkmakelc
;
;
;
; PURPOSE:
;                  Read a rawdata stream from a HK-file and save it as a
;                  lightcurve in a fits-file
;
;
;
; CATEGORY:
;                  Data-I/O
;
;
; CALLING SEQUENCE:
;                  mkwritelc,file,/chatty
;                  
;                  
; 
; INPUTS:
;                  file    : Name of the data-file to read
;                                
;
;
; OPTIONAL INPUTS:
;                  
;                  
;                  
;
;      
; KEYWORD PARAMETERS:
;                  /chatty : Give more information on what's going
;                            on
;                  
;                  
;    
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;                  none
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  This procedure is still very slow and has to be
;                  improved !!!
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  mkwritelc,file,/chatty
;                             
;
;
; MODIFICATION HISTORY:
; V1.0 08.02.98 M. Kuster first initial version
; V1.1 19.05.99 M. Kuster tested with some simple files, seams to be
;                         ok 
;-

   IF (keyword_set(chatty)) THEN BEGIN
       chatty=1
   END ELSE BEGIN
       chatty=0
   END
   
   IF (keyword_set(outpath)) THEN BEGIN
       outpath=outpath
   END ELSE BEGIN
       outpath='./'
   END
   
   outfile=outpath+file+'.lc'
   
   IF (NOT keyword_set(telescope)) THEN telescope = 'unknown'
   IF (NOT keyword_set(instrument)) THEN instrument = 'unknown'
   IF (NOT keyword_set(filter)) THEN filter = 'unknown'
   IF (NOT keyword_set(model)) THEN model = 'unknown'
   IF (NOT keyword_set(qudrant)) THEN quadrant = 'unknown'
   IF (NOT keyword_set(filterpart)) THEN filterpart = 'unknown'
   IF (NOT keyword_set(datatype)) THEN datatype = 'Imaging'
   IF (NOT keyword_set(ccd0mode)) THEN ccd0mode = 'unknown'
   IF (NOT keyword_set(ccd1mode)) THEN ccd1mode = 'unknown'
   IF (NOT keyword_set(ccd2mode)) THEN ccd2mode = 'unknown'
   IF (NOT keyword_set(campaign)) THEN campaign = 'unknown'
   IF (NOT keyword_set(ccd)) THEN ccd = 'unknown'
   IF (NOT keyword_set(cal_energy)) THEN cal_energy = 'unknown'
   
   spawn,"date '+%d/%m/%Y'",date_str ; get system date

   fxhmake,header,/extend       ; build header and extension of fits-file
   
   fxaddpar,header,'TELESCOP',telescope
   fxaddpar,header,'INSTRUME',instrument
   fxaddpar,header,'MODEL',model
   fxaddpar,header,'Quadrant',quadrant
   fxaddpar,header,'CCDPART',ccd
   fxaddpar,header,'FILTER',filter
   fxaddpar,header,'FILPART',filterpart
   fxaddpar,header,'DATATYPE',datatype
   fxaddpar,header,'MODE',ccdmode,'Observation Mode'
   fxaddpar,header,'CCD0MODE',ccd0mode
   fxaddpar,header,'CCD1MODE',ccd1mode
   fxaddpar,header,'CCD2MODE',ccd2mode
   fxaddpar,header,'CAMPAING',campaign,'The campaign id'
   fxaddpar,header,'ENERGY',cal_energy,'The calibration energy'
   fxaddpar,header,'FILENAME',file+'.lc','The filename without the path'
   fxaddpar,header,'DATE',date_str(0),'Date the file was created'

   IF (chatty EQ 1) THEN BEGIN
       print,'% MKWRITELC: Writing lightcurve to file: '+outfile
   ENDIF
   
   fxwrite,outfile,header       ; write header to file
   
   fxbhmake,bin_header,n_elements(time),/initialize ; build header for binary extension
   fxbaddcol,1,bin_header,time(0),'TIME','Column 1: time',tunit='s'
   fxbaddcol,2,bin_header,rate(0),'RATE','Column 2: rate',tunit='counts/s'
   
   IF (n_elements(error) NE 0) THEN BEGIN 
       fxbaddcol,3,bin_header,error(0),'ERROR','Column 2: error',tunit='counts/s'
   ENDIF
   
   fxbcreate,unit,outfile,bin_header ; write header
   numti=n_elements(time)
   
   fxbwritm,unit,['TIME','RATE','ERROR'],time,rate,error
   
   fxbfinish,unit
   free_lun,unit
END




