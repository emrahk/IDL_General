PRO CCD_INFO, file, ALL=all
;
;+
; NAME:
;	CCD_INFO
;
; PURPOSE:   
;	Show info lines of IDL programs.
;
; CATEGORY:
;	General
;
; CALLING SEQUENCE:
;	CCD_INFO, [ file, ALL=all ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	FILE : Filename, defaulted to interactive search on
;	       current directory.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	ALL : Show listing of names of all available %CCD% programs.
;
; OUTPUTS:
;	Prints info lines on screen.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler -  %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs
on_ioerror,BAD

c=''

if not EXIST(all) then begin

   if not EXIST(file) then $
   file=pickfile(/read,path='ait321$dka400:[geckeler.idllib]', $
   filter='*.pro') else file='ait321$dka400:[geckeler.idllib]'+file

   FDECOMP,file,disk,dir,name,qual,version
   if qual eq '' then qual='pro'
   file=disk+dir+name+'.'+qual+';'+version
   openr,unit,file,/get_lun

   repeat begin
      readf,unit,c
      p=STRPOS(c,';+')
      if p ne -1 then repeat begin
      readf,unit,c 
      print,c
      m=STRPOS(c,';-')
      endrep until (EOF(1) or (m ne -1))
      m=STRPOS(c,';-')
   endrep until (EOF(1) or (m ne -1))

   free_lun,unit
   goto, DONE

endif else begin
   fi=FINDFILE('ait321$dka400:[geckeler.idllib]ccd_*.pro',count=count)
   if count eq 0 then message,'No files found'
   
   for i=0,count-1 do begin
      FDECOMP,fi(i),disk,dir,name,qual,version
      print,name+'.pro'
   endfor

   goto, DONE
endelse

BAD:message,'No info for this file available',/inf & free_lun,unit

DONE:
RETURN
END
