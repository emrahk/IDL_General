FUNCTION get_jdstr,jd,mjd=mjd,old=old
;+
; NAME:
;        get_jdstr
;
;
; PURPOSE:
;        Convert Julian Date into date and time strings appropriate
;        for FITS files and return string 
;
;
; CATEGORY:
;        Astronomy
;
;
; CALLING SEQUENCE:
;        str=get_jdstr(jd,old=old,mjd=mjd)
;
; 
; INPUTS:
;        jd: Julian Date to be converted
;
;
; OPTIONAL INPUTS:
;        none
;
;	
; KEYWORD PARAMETERS:
;        old: use old format for date (yy/mm/dd)
;        mjd: if set, jd is in MJD (default: jd is Julian date)
;
;
; OUTPUTS:
;        the function returns the formatted date string, exact to
;        one second.
;
; OPTIONAL OUTPUTS:
;        none
;
;
; COMMON BLOCKS:
;        none
;
;
; SIDE EFFECTS:
;        none
;
;
; RESTRICTIONS:
;        JD has to be valid and AD only
;
;
; PROCEDURE:
;        trivial, wrapper around jdstr
;
;
; EXAMPLE:
;      
;
;
; MODIFICATION HISTORY:
;        $Log: get_jdstr.pro,v $
;        Revision 1.1  2003/04/08 19:00:34  wilms
;        initial revision
;
;-

    jdstr,jd,date,time,mjd=mjd,old=old
    IF keyword_set(old) THEN BEGIN 
        return,date+' '+time
    ENDIF 
    return,date+time
END 
