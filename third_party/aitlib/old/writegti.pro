PRO writegti,tstart,tstop,name,mjdrefi=mjdrefi,mjdreff=mjdreff, $
             timezero=timezero,timeunit=timeunit
;+
; NAME:
;        writegti
;
;
; PURPOSE:
;        Write a "Good Times Interval" file to be used with
;        satellite extraction software
;
;
; CATEGORY:
;        RXTE tools
;
;
; CALLING SEQUENCE:
;        writegti,tstart,tstop,name,mjdrefi=mjdrefi,mjdreff=mjdreff, $
;             timezero=timezero,timeunit=timeunit
;
; 
; INPUTS:
;        tstart: starting time of the GT Interval
;        tstop : stopping time of the GTI
;        name  : filename of the GTI-File
;
;
; OPTIONAL INPUTS:
;        mjdrefi: integer part of the reference date of tstart/tstop
;        mjdreff: floating part of the reference date
;        timezero: additional offset to JD
;        timeunit: unit of tstart and tstop
;
;
;      
; KEYWORD PARAMETERS:
;        see optional inputs
;
;
; OUTPUTS:
;        none
;
;
; OPTIONAL OUTPUTS:
;        none
;
;
; COMMON BLOCKS:
;        none
;
;
; SIDE EFFECTS:
;        a GTI file gets written
;
;
; RESTRICTIONS:
;        tstart must me < tstop
;
;
; PROCEDURE:
;        straightforward, see code
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;        original Version 1997 by Ingo Kreykenbohm
;        Version 1.0 1998/08/07 Joern Wilms (IAA Tuebingen)
;-

   fxhmake,header,/extend
   fxwrite,name,header
   fxbhmake,bhead,n_elements(tstart),/initialize
   fxbaddcol,1,bhead,tstart(0),'Start','column 1 : Start-time',tunit='s'
   fxbaddcol,2,bhead,tstop(0),'Stop','column 2 : Stop-time',tunit='s'
   fxaddpar,bhead,'EXTNAME','GTI','  '
   fxaddpar,bhead,'HDUCLAS1','GTI','Test  '
   fxaddpar,bhead,'HCUCLAS2','STANDARD','test   '
   IF (n_elements(mjdrefi) NE 0) THEN BEGIN 
       fxaddpar,bhead,'MJDREFI',mjdrefi,'Refernce Time '
       fxaddpar,bhead,'MJDREFF',double(mjdreff), $
         'Frac part of Reference Time',format='(1D)',unit='sec'
       fxaddpar,bhead,'TIMEZERO',double(timezero), $
         'Clock Correction',format='(1D)',unit='sec'
       fxaddpar,bhead,'TIMEUNIT',timeunit,'Timeunit'
   ENDIF 

   fxaddpar,bhead,'TSTART',min(tstart),'Start Time',format="E20.14"
   fxaddpar,bhead,'TSTOP',max(tstop),'Stop Time',format="E20.14"

   fxbcreate,unit,name,bhead

   FOR x=1,n_elements(tstart) DO BEGIN 
       fxbwrite,unit,tstart(x-1),1,x
       fxbwrite,unit,tstop(x-1),2,x
   ENDFOR 
   fxbfinish,unit
   free_lun,unit
END 

