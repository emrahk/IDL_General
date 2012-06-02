
PRO writelc,time,counts,error,name,telescope=telescope,  $
   instrument=instrument,tstart=tstart,tstop=tstop,object=object, $
   mjdrefi=mjdrefi,mjdreff=mjdreff

;; create a lightcurve in FITS format

;; create header + extension
   fxhmake,header,/extend      
;; add some parameters
   fxaddpar,header,'CONTENT','LIGHT CURVE','light curve file'
;; check if all parameters are given. If not, set to 'unkown'
   IF (n_elements(telescope) EQ 0) THEN telescope = 'Unkown'
   IF (n_elements(instrument) EQ 0) THEN instrument = 'Unkown'
   IF (n_elements(tstart) EQ 0) THEN tstart = 'Unkown'
   IF (n_elements(tstop) EQ 0) THEN tstop = 'Unkown'
   IF (n_elements(object) EQ 0) THEN object = 'Unkown'
   IF (n_elements(mjdrefi) EQ 0) THEN mjdrefi = 'Unkown'
   IF (n_elements(mjdreff) EQ 0) THEN mjdreff = 'Unkown'
   fxaddpar,header,'TELESCOP',telescope,'Mission name'
   fxaddpar,header,'INSTRUME',instrument,'Instrument used for observation'
   fxaddpar,header,'TSTART',string(tstart),'Observation start time'
   fxaddpar,header,'TSTOP',string(tstop),'Observation stop time'  
   fxaddpar,header,'OBJECT',object,'Object from FIRST input line'
   fxaddpar,header,'MJDREFI',mjdrefi,'Integer part of MJDREF'
   fxaddpar,header,'MJDREFF',mjdreff,'Fractional part of MJDREF'

   fxwrite,name,header          ; write header
                                ; create header for binary extension 
   fxbhmake,bhead,n_elements(time),/initialize 
                                ; add the three columns : time, rate & error
   fxbaddcol,1,bhead,time(0),'TIME','column 1 : time',tunit='s'
   fxbaddcol,2,bhead,counts(0),'RATE','column 2 : rate',tunit='counts/s'
   fxbaddcol,3,bhead,error(0),'ERROR','column 3 : error',tunit='counts/s'
                                ; define as lightcurve
   fxaddpar,bhead,'HDUCLAS1','LIGHTCURVE','Extension contains a lightcurve'
   
   
   fxbcreate,unit,name,bhead    ; write header
                                ; now write all data
   FOR x=1,n_elements(time) DO BEGIN 
       fxbwrite,unit,time(x-1),1,x
       fxbwrite,unit,counts(x-1),2,x
       fxbwrite,unit,error(x-1),3,x
   ENDFOR  
                                ; close file (important !)
   fxbfinish,unit
   free_lun,unit
END 

