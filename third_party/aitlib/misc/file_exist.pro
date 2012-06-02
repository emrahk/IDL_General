FUNCTION file_exist,filename
;+
; NAME:
;          file_exist
;
;
; PURPOSE:
;          return 1 if filename exists, 0 if not
;
;
; CATEGORY:
;          file handling
;
;
; CALLING SEQUENCE:
;          file_exist(filename)
;
; 
; INPUTS:
;          filename: name of file 
;
;
; OPTIONAL INPUTS:
;          none
;
;	
; KEYWORD PARAMETERS:
;          none
;
;
; OUTPUTS:
;          1 if filename exists, 0 if not
;
;
; OPTIONAL OUTPUTS:
;          none
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          one LUN is temporarily used
;
;
; RESTRICTIONS:
;          none
;
;
; PROCEDURE:
;          an attempt to open the file with a read is undertaken, if
;          the attempt succeeds, the file exists.
;
;
; EXAMPLE:
;          if (file_exist("/etc/services")) then begin
;             print,'/etc/services exists'
;          endif
;
;
; MODIFICATION HISTORY:
;          Version 1.0, 1997/10/06, Joern Wilms
;-
   openr,unit,filename,/get_lun,error=err
   IF (err EQ 0) THEN free_lun,unit
   return,(err EQ 0)
END 
