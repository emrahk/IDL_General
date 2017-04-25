;+
; Project     : HESSI
;
; Name        : obj_init
;
; Purpose     : initializes CLASS methods without creating object
;               (does this by just calling s={class})
;
; Category    : utility objects
;
; Syntax      : IDL> obj_init,class
;
; Inputs      : CLASS = class name to init
;
; Outputs     : STATUS = 1/0 if success or failed
;
; History     : Written 17 April 2001, Zarro, EITI/GSFC
;               Modified 4 November 2006, Zarro (ADNET/GSFC) 
;                - removed nasty EXECUTE
;
; Contact     : dzarro@solar.stanford.edu
;-

pro obj_init,class,status=status

status=0b & error=0
chk=(size(class,/tname) eq 'STRING')
if (not chk) then begin
 err='Input argument must be non-blank string class name'
 message,err,/cont
 return
endif

if strtrim(class,2) eq '' then return

catch,error
if error ne 0 then begin
 catch,/cancel
 status=0b
 message,'error initializing: "'+class+'"',/cont
 return
endif

;temp=obj_struct(class)

status=execute('temp={'+class+'}')

status=is_struct(temp)
if not status then message,'undefined class name: "'+class+'"',/cont

return
end
