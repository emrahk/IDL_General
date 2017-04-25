;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  absmjd
;
; PURPOSE:
;  abs of an CDS_INT_TIME struct array
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a : input array to compute the abs
;
; OUTPUTS:
;  resu : abs(a)
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:;
;
; HISTORY:
;  coded by A.Thernisien on 13/08/2002
;
; CVSLOG:
;  $Id: absmjd.pro,v 1.1 2006/09/11 21:10:00 nathan Exp $
;
;
;-
function absmjd,a

r=a
m=where(a.mjd lt 0,cnt)
if cnt gt 0 then r(m)=negmjd(a(m))

return,r
end
