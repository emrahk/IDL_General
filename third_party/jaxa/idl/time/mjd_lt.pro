;+
; PROJECT:
;  SOHO-LASCO
;
; NAME:
;  mjd_lt
;
; PURPOSE:
;  comparison (lt) of two MJD formated date (CDS_INT_TIME structure)
;
; CATEGORY:
;  time
;
; DESCRIPTION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;  a,b : the two CDS_INT_TIME structure date to compare : a lt b
;
; OUTPUTS:
;  resu : a lt b (boolean)
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
;  Revision 1.1  2002/08/20 10:16:16  arnaud
;  *** empty log message ***
; $Id: mjd_lt.pro,v 1.1 2006/09/11 21:10:01 nathan Exp $
;-
function mjd_lt,a,b
diff=submjd(a,b)

return,(diff.mjd lt 0)
end
