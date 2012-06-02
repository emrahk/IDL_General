PRO mkwritevent,file,data,quad,outpath=outpath,$
                telescope=telescope,model=model,$
                campaign=campaign,filter=filter,$
                chatty=chatty
;+
; NAME:            mkwritevent
;
;
;
; PURPOSE:
;                  Save structure 'data' as a FITS event file
;
;
;
; CATEGORY:
;                  XMM-Data-Analysis / I/O
;
;
; CALLING SEQUENCE:
;                  mkwritevent,file,data,/chatty
;                  
;                  
; 
; INPUTS:
;                  file     : Name of the data-file to read
;                  data     : Data-structure                                 
;                  quad     : Quadrant the data is taken from
;
;
; OPTIONAL INPUTS:
;                  telescope: Telescope used for observation (default
;                             'XMM') 
;                  instrument: Instrument used for the observation
;                              (default 'EPN')
;                  campaign : The observation campaing (default
;                             'CAL/PV') 
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
;                  improved !!
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  mkwritelc,file,data,0,outpath='/home/kuster/',/chatty
;                             
;
;
; MODIFICATION HISTORY:
; V1.0 15.05.00 M. Kuster first initial version
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
   
   outfile=outpath+file+'.event'
   
   IF (NOT keyword_set(telescope)) THEN telescope = 'XMM'
   IF (NOT keyword_set(instrument)) THEN instrument = 'EPN'
   IF (NOT keyword_set(filter)) THEN filter = 'unknown'
   IF (NOT keyword_set(model)) THEN model = 'unknown'
   IF (NOT keyword_set(qudrant)) THEN quadrant = 'unknown'
   IF (NOT keyword_set(filterpart)) THEN filterpart = 'unknown'
   IF (NOT keyword_set(datatype)) THEN datatype = 'unknown'
   IF (NOT keyword_set(ccd0mode)) THEN ccd0mode = 'unknown'
   IF (NOT keyword_set(ccd1mode)) THEN ccd1mode = 'unknown'
   IF (NOT keyword_set(ccd2mode)) THEN ccd2mode = 'unknown'
   IF (NOT keyword_set(campaign)) THEN campaign = 'CAL/PV'
   IF (NOT keyword_set(ccd)) THEN ccd = 'unknown'
   IF (NOT keyword_set(cal_energy)) THEN cal_energy = 'unknown'
   
   spawn,"date '+%d/%m/%Y'",date_str ; get system date

   fxhmake,header,/extend       ; build header and extension of fits-file
   
   fxaddpar,header,'TELESCOP',telescope
   fxaddpar,header,'INSTRUME',instrument
   fxaddpar,header,'MODEL',model
   fxaddpar,header,'QUAD',quad
   fxaddpar,header,'CCDPART',ccd
   fxaddpar,header,'FILTER',filter
   fxaddpar,header,'FILPART',filterpart
   fxaddpar,header,'DATATYPE',datatype
   fxaddpar,header,'CCD0MODE',ccd0mode
   fxaddpar,header,'CCD1MODE',ccd1mode
   fxaddpar,header,'CCD2MODE',ccd2mode
   fxaddpar,header,'CAMPAIGN',campaign,'The campaign id'
   fxaddpar,header,'ENERGY',cal_energy,'The calibration energy'
   fxaddpar,header,'FILENAME',file+'.lc','The filename without the path'
   fxaddpar,header,'DATE',date_str(0),'Date the file was created'

   IF (chatty EQ 1) THEN BEGIN
       print,'% MKWRITEVENT: Writing data to file: '+outfile
   ENDIF
   
   fxwrite,outfile,header       ; write header to file
   
   fxbhmake,bin_header,n_elements(data.time),/initialize ; build header for binary extension
   fxbaddcol,1,bin_header,data(0).time,'TIME','Photon arrival time',tunit='s'
   fxbaddcol,2,bin_header,data(0).line,'LINE','Line Number',tunit='Pixel'
   fxbaddcol,3,bin_header,data(0).column,'COLUMN','Column Number',tunit='Pixel'
   fxbaddcol,4,bin_header,data(0).ccd,'CCD','CCD number',tunit='Counter'
   fxbaddcol,5,bin_header,data(0).energy,'ENERGY','Energy in ADU',tunit='Pixel'
   fxbaddcol,6,bin_header,data(0).split,'SPLIT','Is it a split event',tunit='BOOL'

   fxbcreate,unit,outfile,bin_header ; write header
   
   fxbwritm,unit,['TIME','LINE','COLUMN','CCD','ENERGY','SPLIT'],$
     data.time,data.line,data.column,data.ccd,data.energy,data.split
   
   fxbfinish,unit
   free_lun,unit
END




