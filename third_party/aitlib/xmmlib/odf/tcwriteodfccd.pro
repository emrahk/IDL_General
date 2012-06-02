PRO tcwriteodfccd,file,data,header,chatty=chatty
;+
; NAME:
;       TCWRITEODFCCD
;
;
; PURPOSE:
;       Write XMM-ODF data
;
;
; CATEGORY:
;       ODF, FITS
;
;
; CALLING SEQUENCE:
;       tcwriteodfccd,file,data,header,/chatty
; 
; INPUTS:
;       FILENAME: Name of ODF File to be written
;       
;
; OPTIONAL INPUTS:
;
;	
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;
; RESTRICTIONS:
;       Only works with data structs containing the element data.frame 
;       
;
; PROCEDURE: 
;
;
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
; V1.0 13.09.00 T. Clauss 
;
;-   
   
   
   openr,unit,file,ERROR=err,/get_lun
   IF (err EQ 0) THEN BEGIN 
       free_lun,unit
       print,'% TCWRITEODFCCD: File: '+file+' already exists'
       print,'% TCWRITEODFCCD: to continue type .c , else type return'
       stop
   endif
   
   IF (keyword_set(chatty)) THEN print,'% TCWRITEODFCCD: Creating file: '+file
   
   datastruct={datastruct,frame:long(0),rawx:byte(0),rawy:byte(0),energy:fix(0)}
   
   numev=n_elements(data)
   wdata=replicate(datastruct,numev)
   
   wdata.frame=data.frame
   wdata.rawx=data.column
   wdata.rawy=data.line
   wdata.energy=data.energy
      
   MWRFITS,wdata,file,header,/create
   
END 



