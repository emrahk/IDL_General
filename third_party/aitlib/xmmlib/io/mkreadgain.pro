FUNCTION mkreadgain,file,chatty=chatty
   openr,unit, file, /XDR,ERROR=err,/get_lun
   IF (err NE 0) THEN BEGIN 
       print,'% MKREADGAIN: ERROR opening Gain-File: '+file
       print,'% MKREADGAIN: '+ !ERR_STRING
       return,-1
   ENDIF ELSE BEGIN 
       readu,unit, gain
       free_lun,unit
       return,gain
   ENDELSE
END

