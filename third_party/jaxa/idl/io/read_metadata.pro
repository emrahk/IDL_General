;+
; Project     : VSO
;                                                                              
; Name        : READ_METADATA
;                                                                              
; Purpose     : Read metadata between <meta> and </meta> keywords in file header
;                                                                              
; Category    : utility i/i
;                                                                              
; Syntax      : IDL> read_metadata,file,metadata
;                                                                              
; Inputs      : FILE = file name to read
;                                                                              
; Outputs     : METADATA = metadata string array
;                                                                              
; Keywords    : BUFFSIZE = # of chunks to read file [min = 10]
;               ERR = error string
;                                                                              
; History     : 3-Feb-2014, Zarro (ADNET) - written
;-

pro read_metadata,file,metadata,buffsize=buffsize,err=err

struct=-1
err=''
metadata=''
if is_blank(file) then begin
 err='Missing input file name.'
 pr_syntax,'read_metadata,filename,metadata'
 return
endif

if ~file_test(file,/read) then begin
 err='Input file not found or unreadable.'
 return
endif

;-- read header in chunks and look for meta tags

on_ioerror,bail
if is_number(buffsize) then bsize=(buffsize > 10) else bsize=10
head='' & found=0b
openr,lun,file,/get_lun
repeat begin
 temp=strarr(bsize)
 readf,lun,temp
 if ~found then begin
  chk=where(stregex(temp,'<meta>',/bool,/fold),count)
  if count eq 0 then begin
   close_lun,lun
   err='Input file does not contain metadata.'
   return
  endif else found=1b
 endif
 head=[temporary(head),temp]
 chk=where(stregex(temp,'<\/meta>',/bool,/fold),count)
endrep until (count ne 0) 

bail: close_lun,lun

if is_blank(head) and is_string(temp) then head=temp
chk1=where(stregex(head,'<meta>',/bool,/fold),count1)
chk2=where(stregex(head,'</meta>',/bool,/fold),count2)

if count1*count2 eq 0l then begin
 err='Error reading input file.'
 return
endif

metadata=head[chk1[0]:chk2[0]]

return & end
