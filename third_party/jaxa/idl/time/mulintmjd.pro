;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  addmjd
;
; PURPOSE:
;  multiplication of mjd date (CDS_INT_TIME structure) with a long
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a :  CDS_INT_TIME structure date
;  d : int or long 
;
; OUTPUTS:
;  resu : a * d
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:
;
; HISTORY:
;  A.Thernisien on 20/08/2004
;
; CVSLOG:
;  $Id: mulintmjd.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;
;-
function mulintmjd,a,d

r={CDS_INT_TIME}

; ---- use loop for more accuracy
for i=1,abs(d) do r=addmjd(r,a)    

if d lt 0 then r=negmjd(r)

return,r
end
