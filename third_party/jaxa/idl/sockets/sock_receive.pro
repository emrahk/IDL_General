;+
; Project     : VSO
;
; Name        : SOCK_RECEIVE
;
; Purpose     : return receipt from a socket request
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_receive,unit,request
;
; Inputs      : UNIT = socket unit number (must be open)
;
; Outputs     : RESPONSE = request response
;
; History     : 20-Nov-2012, Zarro (ADNET) - Written
;-

pro sock_receive,unit,response,verbose=verbose

response=''
if ~is_number(unit) then return
stat=fstat(unit)
if ~stat.open then return

on_ioerror, done
linesread=0
text='xxx'
header = strarr(256)
while text ne '' do begin
 readf,unit,text
 header[linesread]=text
 linesread=linesread+1
 if (linesread mod 256) eq 0 then header=[header, strarr(256)]
endwhile

done:on_ioerror,null
message,/reset
response=header
if keyword_set(verbose) then print,response

return & end
