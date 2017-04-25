;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  mjd_le
;
; PURPOSE:
;  comparison (le) of two MJD formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to compare : a le b
;
; OUTPUTS:
;  resu : a le b (boolean)
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:
;
; HISTORY:
;  coded by A.Thernisien on 20/08/2002
;
; CVSLOG:
;  Revision 1.2  2002/08/20 15:44:19  arnaud
;  Now the first input (a) can be an array, but not the second (b)
;
;  Revision 1.1  2002/08/20 10:16:04  arnaud
;  *** empty log message ***
; $Id: mjd_le.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;-
function mjd_le,a,b

diff=submjd(a,b)

return,(diff.mjd lt 0) or (diff.mjd eq 0 and diff.time eq 0)
end
