;+
; PROJET
;     SECCHI
;
; NAME:
;  B34TOINT
;
; PURPOSE:
;  Convert a base n number to integer
;
; CATEGORY:
;  Mathematics
;
; CALLING SEQUENCE:
;   
; DESCRIPTION:
;
; INPUTS:
;
; INPUT KEYWORD:
;
; OUTPUTS:
;
; PROCEDURE:
;  
; CALLED ROUTINES:
;
; HISTORY:
;	copied from b32toint.pro V1 A.Thernisien 10/07/2001
; CVSLOG:
;  $Log: bntoint.pro,v $
;  Revision 1.1  2007/05/03 14:32:22  mcnutt
;  copied from inttob32.pro add n for base value
;
;
;
function bntoint,in,n

in=strupcase(in)

sze=size(in)
if sze(0) eq 0 then begin
    sx=1 
    out=0L
endif else begin
    sx=sze(1)
    out=lonarr(sx)
endelse

for i=0L,sx-1 do begin
    for j=0,strlen(in(i))-1 do begin
        r=byte(strmid(in(i),j,1,/reverse))
        out(i)=out(i)+(r-48-7*(r ge 65))*long(n)^j
    endfor
endfor

return,out
end
