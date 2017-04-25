;+
; Project:
;     SDAC
; Name:
;     GOES_GET_CHIANTI_VERSION
;
; Usage:
;     print, goes_get_chianti_version()
;
;Purpose:
;     Return chianti version used in goes_get_chianti_temp and goes_get_chianti_em
;
;Category:
;     GOES, SPECTRA
;
;Method:
;     Anyone who updates goes_get_chianti_temp and goes_get_chianti_em to use a newer
;     version of chianti should modify this appropriately.

; MODIFICATION HISTORY:
;     Kim Tolbert, 13-Dec-2005
;     Kim, 30-Nov-2006.  Changed to 5.2 after onlining new tables from S. White
;     Kim, 02-Dec-2009.  Changed to 6.0.1 after onlining new tables from S. White
;	  7-jun-2012, richard.schwartz@nasa.gov - read the value from goes_get_chianti_temp.pro
;	  10-Sep-2012, Kim. Call chkarg with /quiet
;
;-
;-------------------------------------------------------------------------

function goes_get_chianti_version
chkarg,'goes_get_chianti_temp',proc,loc,/quiet
line = proc[where(stregex(proc[0:99],/boo,/fold,'This routine .* using chianti version'))]
version = ssw_strsplit( line,/tail, 'version ')
return, version

end