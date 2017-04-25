;+
; Project     : HESSI
;
; Name        : PRINT_HTML
;
; Purpose     : print string in basic HTML format
;
; Category    : HTML
;
; Syntax      : IDL> print_html,message
;
; Inputs      : MESSAGE = any string
;
; Outputs     : FILE or STDIO
;
; Keywords    : FILE = optional output file
;
; History     : 11-Aug-1999,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro print_html,lun,message,ofile=ofile

@html_tags

if not exist(message) then message=''

if is_string(ofile) then openw,lun,ofile,/get_lun else begin
 if not is_number(lun) then lun=-1
endelse

printf,lun,opening+br
printf,lun,pr+message+br
printf,lun,closing

if lun gt -1 then close_lun,lun

return & end
