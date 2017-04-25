;+
; Project     : SOHO - CDS
;
; Name        : XSEL_PRINTER
;
; Purpose     : select printer 
;
; Category    : Device, Widgets
;
; Explanation : retrieves a printer name from a selection
;               obtained from PRINTCAPS file
;
; Syntax      : IDL> xsel_printer,printer,err=err,status=status
;
; Inputs      : None
;
; Opt. Inputs : None
;
; Outputs     : printer = selected printer name
;
; Opt. Outputs: None
;
; Keywords    : GROUP = widget ID of calling widget
;               STATUS = 0/1 if selection aborted/completed
;               INSTRUCT = instructions for user
;               DEFAULT = default printer selection
;
; Common      : XSEL_PRINTER: holds last selected printer name
;
; Restrictions: currently works best for UNIX
;
; Side effects: None
;
; History     : Version 1, 7-Sep-1995,  D.M. Zarro.  Written
;               Version 2, 25-Feb-1997, Zarro, added printer environmentals
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


pro xsel_printer,printer,group=group,err=err,status=status,$
                default=default,instruct=instruct

err='' & printer=''
status=1

if datatype(instruct) ne 'STR' then instruct=''
list_printer,printers,descs

if printers(0) ne '' then begin
 get_def_printer,choice,default=default,desc=desc
 initial_choice=choice+' --- '+desc
 choices=printers+' --- '+descs
 temp = xsel_list(choices, group=group,$
                 title = 'Available Printers',$
                 initial=initial_choice,/index,$
                 status = status,/no_remove,subtitle=instruct)
 if status then begin 
  printer=printers(temp) 
  get_def_printer,printer,/set
 endif
endif 

if (printer eq '') and status then begin
 message,'Using default printer',/cont
 if os_family() eq 'vms' then printer='SYS$PRINT' else printer='lpr'
endif

return & end

