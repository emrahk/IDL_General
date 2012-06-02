PRO jdstr,jd,date,time,old=old,mjd=mjd
;+
; NAME:
;        jdstr
;
;
; PURPOSE:
;        Convert Julian Date into date and time strings appropriate
;        for FITS files
;
;
; CATEGORY:
;        Astronomy
;
;
; CALLING SEQUENCE:
;        jdstr,jd,date,time,old=old
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
;        date : String in yy/mm/dd form
;        time : string in hh:mm:ss form
;
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
;        trivial, needs astrolib's daycnv
;
;
; EXAMPLE:
;      
;
;
; MODIFICATION HISTORY:
;        $Log: jdstr.pro,v $
;        Revision 1.2  2003/04/08 18:56:02  wilms
;        First change since 1997!
;        Added new FITS date format, which is now the default.
;
;
;        Version 1.0, 1997/03/13 J. Wilms (wilms@astro.uni-tuebingen.de)
;-

   ;; convert to JD if required
   jdtmp=double(jd)
   IF (keyword_set(mjd)) THEN jdtmp=jdtmp+2400000.5D0

   ;;
   ;; Find ymsh
   ;;

   daycnv,jdtmp,y,m,d,hh

   ;;
   ;; String-Formatting for beginners :-)
   ;;
   IF (keyword_set(old)) THEN BEGIN 
       ;; old format for very old FITS files
       IF (y GT 2000) THEN y=y-2000. ELSE y=y-1900.
       date=string(format='(I2.2,1H/,I2.2,1H/,I2.2)',y,m,d)
       h=fix(hh)
       mm=60.*(hh-h)
       m=fix(mm)
       s=fix(60.*(mm-m))
       time=string(format='(I2.2,1H:,I2.2,1H:,I2.2)',h,m,s)
   ENDIF ELSE BEGIN 
       ;; new Y2K compatible format, "stolen" from astrolib routine
       ;; get_date, written by Wayne Landsman
       
       date =  string(y,f='(I4.4)') + '-' + string(m,f='(i2.2)') + '-' + $
         string(d,f='(I2.2)')

       ihr = fix(hh)
       mn = (hh - ihr)*60.
       imn = fix(mn)
       sec = round((mn - imn)*60.)

       time='T' + string(ihr,f='(I2.2)') + ':' + string(imn,f='(I2.2)') +  $
         ':' + string(round(sec),f='(I2.2)')
   ENDELSE 
END 
