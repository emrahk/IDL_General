;+
; Project     : SOHO - CDS
;
; Name        : XPRINT
;
; Purpose     : print an array or file
;
; Category    : OS, Widgets
;
; Explanation : retrieves a printer queue name from a selection
;               obtained from PRINTCAPS file
;
; Syntax      : IDL> xprint,file
;
; Inputs      : FILE = filename to print
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : STATUS = 0/1 if selection aborted/continued
;               ARRAY = alternative string array to print
;               NOSEL = skip printer selection
;               PRINTER = return printer name
;               CONFIRM = prompt for file deletion
;
; Common      : None
;
; Restrictions: currently works best for UNIX
;
; Side effects: None
;
; History     : Version 1,  1-Sep-1995,  D.M. Zarro.  Written
;               Modified, 1-May-2000, Zarro (SM&A/GSFC) - added check
;               for windows
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro xprint,file,array=array,group=group,status=status,printer=printer,$
          qual=qual,delete=delete,instruct=instruct,nosel=nosel,confirm=confirm

status=0
on_error,1
err=''

sav_dev=!d.name
set_x

;-- select printer

if not keyword_set(nosel) then begin
 if datatype(instruct) ne 'STR' then pstruct='' else pstruct=instruct
 xsel_printer,printer,status=status,group=group,instruct=pstruct
endif else begin
 if datatype(printer) ne 'STR' then printer=getenv('PRINTER')
 status=trim(printer) ne ''
endelse

do_del=keyword_set(delete)
if do_del and keyword_set(confirm) then $
 do_del=xanswer('Delete file: '+file+' ?',group=group) 

if status then begin
 send_print,file,que=printer,array=array,qual=qual,err=err,delete=do_del
 if err eq '' then xtext,'   Print job sent successfully   ',/just_reg,wait=1 else $
  xack,err,group=group
endif

if do_del then rm_file,file

set_plot,sav_dev

return & end

