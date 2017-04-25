;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  mjd_gt
;
; PURPOSE:
;  comparison (gt) of two MJD formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to compare : a gt b
;
; OUTPUTS:
;  resu : a gt b (boolean)
;
; INPUT KEYWORDS:
;
; OUTPUT KEYWORDS:
;
; HISTORY:
;  coded by A.Thernisien on 20/08/2002
;
; CVSLOG:
;  Revision 1.1  2002/08/20 10:15:59  arnaud
;  *** empty log message ***
; $Id: mjd_gt.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;-
function mjd_gt,a,b

diff=submjd(a,b)


return,(diff.mjd gt 0) or (diff.mjd eq 0 and diff.time gt 0)
end
