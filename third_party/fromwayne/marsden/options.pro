pro options,value,opt,disp,det_str,dc,fnme,typ
;***********************************************************************
; Program handles standard events for HEXTE widgets.
; Input variable are:
;         value.................event string in the widget
; Output variable is:
;           opt.................numerical option code
;          disp.................    "     display  "
;       det_str.................detector string
;            dc.................detector code
;          fnme.................filename for saving
; 8/26/94 Print statements 
; Fist do options buttons:
;**********************************************************************
if (not(ks(typ)))then typ = ''
if(value eq 'NET ON')then begin
   opt = 1
   value = 'UPDATE'
endif
if(value eq 'NET OFF')then begin
   opt = 2
   value = 'UPDATE'
endif
if(value eq 'OFF+')then begin
   opt = 3
   value = 'UPDATE'
endif
if(value eq 'OFF-')then begin
   opt = 4
   value = 'UPDATE'
endif
if(value eq 'ON SRC')then begin
   opt = 5
   value = 'UPDATE'
endif
if(value eq 'ANY')then begin
   opt = 6
   value = 'UPDATE'
endif
;**********************************************************************
; Accumulations options: 1 IDF or accum
;**********************************************************************
if(value eq '1 IDF')then begin
   disp = 0
   value = 'UPDATE'
endif
if(value eq 'ACCUM.')then begin
   disp = 1
   value = 'UPDATE'
endif
;**********************************************************************
; Prompt for filename if selected
;**********************************************************************   
if (value eq 'ASCII FILE')then begin
   fnme = 'get ascii file' & value = 'UPDATE'
endif
if (value eq 'IDL FILE')then begin
   fnme = 'get idl file' & value = 'UPDATE'
endif
if (value eq 'FITS FILE')then begin
   fnme = 'get fits file' & value = 'UPDATE'
endif
;**********************************************************************
; Get the detector code
;**********************************************************************
if (typ eq '')then det_str = ['DET1','DET2','DET3','DET4','DET SUM',$
               'SHOW ALL']
d = where(value eq det_str)
if (n_elements(det_str) eq 1)then d(0) = 0
if (d(0) ne -1) then begin
   dc = det_str(d(0))
   value = 'UPDATE'
endif 
;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
