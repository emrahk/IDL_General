;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  mjd_ne
;
; PURPOSE:
;  comparison (ne) of two MJD formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to compare : a ne b
;
; OUTPUTS:
;  resu : a ne b (boolean)
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:
;
; HISTORY:
;  coded by A.Thernisien on 20/08/2002
;
; CVSLOG:
;  Revision 1.1  2002/08/20 10:16:57  arnaud
;  *** empty log message ***
;  $Id: mjd_ne.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;-
function mjd_ne,a,b

diff=submjd(a,b)

return,not(diff.mjd eq 0 and diff.time eq 0)
end
