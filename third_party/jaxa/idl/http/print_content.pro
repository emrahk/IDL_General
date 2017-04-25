;+
; Project     : HESSI
;
; Name        : PRINT_CONTENT
;
; Purpose     : print HTML content header
;
; Category    : HTML
;
; Syntax      : IDL> print_content,type
;
; Inputs      : LUN = logical unit number to print to [def = STDIO]
;
; Opt.Inputs  : TYPE = content type (e.g. text/html [def] or image/gif, etc)
;
; Outputs     : FILE or STDIO
;
; Keywords    : None
;
; History     : 20-May-2003,  D.M. Zarro (EER/GSFC)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro print_content,lun,type

if not is_number(lun) then lun=-1
if is_blank(type) then type='text/html'

printf,lun,'Content-Type: '+type
printf,lun,''

return & end

