;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  mjd_ge
;
; PURPOSE:
;  comparison (ge) of two MJD formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to compare : a ge b
;
; OUTPUTS:
;  resu : a ge b (boolean)
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:
;
; HISTORY:
;  coded by A.Thernisien on 20/08/2002
;
; CVSLOG:
;  Revision 1.1  2002/08/20 10:15:27  arnaud
;  *** empty log message ***
; $Id: mjd_ge.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;-
function mjd_ge,a,b

diff=submjd(a,b)


return,(diff.mjd ge 0 and diff.time ge 0)
end
