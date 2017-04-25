function addecstimes, baset, addt, DIFF=diff, UTC=utc, CCSDS=ccsds
;+
; $Id: addecstimes.pro,v 1.1 2006/08/23 18:44:53 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : addecstimes
;               
; Purpose   : add time incr addt to baset and print result
;               
; Use       : Input time with or without day
;    
; Inputs    : baset, addt   STR ([YYYY-MM-DDT]hh:mm:ss) or INT ([[yy]yymmdd]hhmmss) format
;               
; Outputs   : string or UTC structure representing resulting time; print result
;
; Keywords  : DIFF, UTC
;
;   DIFF    Do difference instead of sum
;   UTC     Return UTC structure instead of string
;   CCSDS   REturn string in CCSDS format (No Z, /trunc)
;               
; Calls from LASCO : 
;
; Common    : 
;               
; Restrictions: 
;               
; Side effects: 
;               
; Category    : time utility string
;               
; Prev. Hist. : None.
;
; Written     : Nathan Rich, NRL/I2, Mar 05
;               
; $Log: addecstimes.pro,v $
; Revision 1.1  2006/08/23 18:44:53  nathan
; moved from ../util
;
; Revision 1.1  2005/04/21 19:26:16  nathan
; no comment
;
;-            

; ++++ define utcin ++++

IF datatype(baset) EQ 'STR' THEN BEGIN
    lenstr=strlen(baset)
    IF lenstr LT 10 THEN BEGIN
    ; is time only
        get_utc,todaystr,/date_only,/ccsds
        baset=todaystr+'T'+baset
    ENDIF
    utcin=anytim2utc(baset)
ENDIF ELSE BEGIN
    get_utc,todayutc
    utcin=todayutc
    IF baset GT 999999 THEN BEGIN
    ; is date&time 
        str0=string(baset,format="(i14.14)")
        yy=strmid(str0,0,2)
        IF yy EQ '00' THEN BEGIN
            IF fix(strmid(str0,2,2)) GT 50 THEN strput,str0,'19' ELSE strput,str0,'20'
        ENDIF
        date=strmid(str0,0,4)+'-'+strmid(str0,4,2)+'-'+strmid(str0,6,2)
        utcin=anytim2utc(date)
        str1=strmid(str0,8,6)
    ENDIF ELSE BEGIN
        str1=string(baset,format="(i6.6)")
    ENDELSE
    sec1=3600L*long(strmid(str1,0,2)) + 60*long(strmid(str1,2,2)) + long(strmid(str1,4,2))
    utcin.time = sec1*1000
ENDELSE
taiin=utc2tai(utcin)

; ++++ format number of seconds to add/subtract ++++

IF datatype(addt) EQ 'STR' THEN $
    sec2=3600*long(strmid(addt,0,2)) + 60*long(strmid(addt,3,2)) + long(strmid(addt,6,2)) $
ELSE BEGIN
    str2=string(addt,format="(i6.6)")
    sec2=3600*long(strmid(str2,0,2)) + 60*long(strmid(str2,2,2)) + long(strmid(str2,4,2))
ENDELSE


IF keyword_set(DIFF) THEN secout=taiin-sec2 ELSE secout = taiin+sec2

utcout=tai2utc(secout)
IF keyword_set(CCSDS) THEN usecs=0 ELSE usecs=1
timeout=utc2str(utcout,ecs=usecs,/truncate)

print,timeout+','+string(sec2)+' seconds'

IF keyword_set(UTC) THEN return, utcout ELSE return, timeout
end
