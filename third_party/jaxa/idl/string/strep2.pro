;+
; Project     :	SOHO - CDS
;
; Name        :	STREP2
;
; Purpose     : Replaces first occurrence of given string within a string.
;
; Explanation : Within the given string the routine will replace the first
;               occurrence of the supplied substring with the requested
;               replacement.
;
;               eg. IDL> x = 'abcdefgcd'
;                        print, strep2(x,'cd','qq')  --> 'abqqefgcd'
;
;               see also REPSTR() for replacement of all occurrences.
;
; Use         : Result = output=strep(input,old,new,/all)
;
; Inputs      :
;               input=any string
;               old=old characters
;               new=new characters
;
; Outputs     : Result = new string.
;
; Keywords    : all = replace all characters
;               compress = if set, remove all spaces from output string
;               notrim = if set, don't trim spaces out of new
;               nopad = don't pad input string with blanks to match size
;               of replacement string
;
; Category    : String processing
;
; Written     :	DMZ (ARC) August 1993
;
; Modified    : Documentation header update.  CDP, 26-Sep-94
;
; Version     : Version 2, 26-Sep-94
;               Version 3, 8-Jun-98, Zarro (SAC/GSFC) - added /compress
;               1-Feb-2010, Kim Tolbert.  Added notrim keyword
;               30-Oct-2013, Zarro (ADNET) - Added NOPAD keyword
;               3-Mar-2015, Zarro (ADNET) - Renamed to STREP2
;-
;
FUNCTION strep2,input,old,new,all=all,compress=compress, notrim=notrim, nopad=nopad            
   len=STRLEN(input) & p=STRPOS(input,old) 

   if keyword_set(notrim) then tnew = new else tnew=STRTRIM(new,2) 
   IF p EQ -1 THEN RETURN,input
   leno=STRLEN(old)
   lenn=STRLEN(tnew)

;-- buffer so that new string tailors with old string

   IF ~KEYWORD_SET(nopad) THEN BEGIN
    IF lenn LT leno THEN BEGIN
     REPEAT BEGIN
        tnew=tnew+' '
     ENDREP UNTIL STRLEN(tnew) EQ leno
    ENDIF
   ENDIF

   output=STRMID(input,0,p)+tnew+STRMID(input,p+leno,len-p-leno+1)
   IF KEYWORD_SET(all) THEN output=strep2(output,old,new,/all)
   if keyword_set(compress) then output=strcompress(output,/rem)
   RETURN, output
END

