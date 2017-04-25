;+
; Project     : SOHO - CDS
;
; Name        : XMAIL
;
; Purpose     : widget mail interface
;
; Category    : OS, Widgets
;
; Explanation : prompts user for e-mail address
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
; Keywords    : STATUS = 0/1 if mail aborted/continued
;               ARRAY = alternative string array to print
;
; Common      : XMAIL - contains last address
;
; Restrictions: currently works best for UNIX
;
; Side effects: None
;
; History     : Version 1,  1-Sep-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro xmail,file,array=array,group=group,status=status

on_error,1

common xmail,last_add

err=''
status=0
file_or_string,file=file,string=array,err=err
if err ne '' then begin
 xack,err,group=group
 return
endif

;-- get address

if datatype(last_add) eq 'STR' then address=last_add else address=''
instruct=['Enter full e-mail address to send to:' ,$
          '(e.g. zarro@smmdac.nascom.nasa.gov)']
repeat begin
 xinput,address,instruct,group=group,status=status,max_len=40
endrep until ((strtrim(address,2) ne '') or (not status))

;-- send mail

if status then begin
 widget_control,/hour
 send_mail,file,array=array,err=err,address=address
 last_add=address
 if err eq '' then xtext,'   Mail sent   ',/just_reg,wait=1 else $
  xack,err,group=group
endif
 
return & end

