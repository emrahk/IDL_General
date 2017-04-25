;---------------------------------------------------------------------------
; Document name: mk_timetick.pro
; Created by:    Liyun Wang, NASA/GSFC, May 8, 1996
;
; Last Modified: Thu Jun 12 17:24:11 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO mk_timetick, timemin, timemax, basetime, label=label, value=value, $
                 major=major, minor=minor, local=local, nodow=nodow
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       MK_TIMETICK
;
; PURPOSE:
;       Create time ticks to be used by AXIS
;
; CATEGORY:
;       Utilities, Graphics
;
; EXPLANATION:
;
; SYNTAX:
;       mk_timetick, tmin, tmax, basetime, label=lable, value=value
;
; INPUTS:
;       TMIN     - Beginning time of the plot, in hours
;       TMAX     - End time of the plot, in hours
;       BASETIME - Base time, in any CDS time format
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       LABEL - String array, ticknames to be used in AXIS with the
;               [XY]TICKNAME keyword
;       VALUE - Values at the major tickmarks to be used in AXIS with
;               the [XY]TICKV keyword
;       MAJOR - Number of major tickmarks, to be used with the
;               [XY]TICKS keyword in AXIS
;       MINOR - Number of minor tickmarks, to be used with the
;               [XY]MINOR keyword in AXIS
;       LOCAL - Set this keyword to make time ticks w.r.t local time
;       NODOW - Suppress day of week in date string
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, May 8, 1996, Liyun Wang, NASA/GSFC. Written
;       Version 2, May 17, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug which may occur when TMAX-TMIN is less than 3 hours
;          Added seconds in label if TMAX-TMIN is less than 3 hours
;       Version 3, June 3, 1996, Liyun Wang, NASA/GSFC
;          Changed date string to dd-MMM format
;       Version 4, June 12, 1997, Liyun Wang, NASA/GSFC
;          Added day of week in date string as default; use NODOY
;             keyword to suppress it
;          Added keyword NODOW
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   IF N_PARAMS() LT 2 THEN BEGIN
      error = 'Sytax: mk_timetick, tmin, tmax, vs, vb, KEYWORD=...'
      MESSAGE, error, /cont
      RETURN
   ENDIF

   tmin = timemin
   tmax = timemax
   btime = anytim2utc(basetime)

   tdiff = tmax-tmin

   IF KEYWORD_SET(local) THEN BEGIN
      gap = ROUND(local_diff())
      btime = anytim2utc(utc2tai(anytim2utc(btime))+3600.d0*gap)
      tmin = tmin+gap
      tmax = tmax+gap
      IF tmin LT 0.0 THEN BEGIN
         tmin = tmin+24.0
         tmax = tmax+24.0
      ENDIF
   ENDIF
   
   IF tdiff LE 0.0 THEN BEGIN
      error = 'Invalis time range!'
      MESSAGE, error, /cont
      RETURN
   ENDIF

   CASE (FIX(tdiff/24.0)) OF
      0: BEGIN
;---------------------------------------------------------------------------
;        tdiff shorter than 24 hours
;---------------------------------------------------------------------------
         IF tdiff GT 12.0 THEN BEGIN
            vb = 3.0
            vs = 0.5
         ENDIF ELSE IF tdiff GT 6.0 THEN BEGIN
            vb = 2.0
            vs = 0.333333333
         ENDIF ELSE IF tdiff GT 3.0 THEN BEGIN
            vb = 1.0
            vs = 0.166666667
         ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;           Shorter than 3 hours
;---------------------------------------------------------------------------
            nbig = 6
            minor = 4
            show_sec = 1
         ENDELSE
      END
      1: BEGIN
         vb = 6.0
         vs = 1.0
      END
      2: BEGIN
         vb = 8.0
         vs = 2.0
      END
      3: BEGIN
         vb = 12.0
         vs = 2.0
      END
      ELSE: BEGIN
;---------------------------------------------------------------------------
;        Longer than 4 days
;---------------------------------------------------------------------------
         IF tdiff LE 240.0 THEN BEGIN
            vb = 24.0
            vs = 4.0
         ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;           Longer than 10 days
;---------------------------------------------------------------------------
            nbig = 6
            minor = 4
         ENDELSE
      END
   ENDCASE

   IF N_ELEMENTS(nbig) EQ 0 THEN BEGIN
      nbig = FIX(tdiff/vb)
      minor = ROUND(vb/vs)
   ENDIF ELSE BEGIN
      vb = tdiff/FLOAT(nbig)
      vs = vb/FLOAT(minor)
   ENDELSE

   label = STRARR(nbig+1)
   
   i0 = FIX(tmin/vb)
   FOR i = i0, i0+30 DO BEGIN
      tmp = FLOAT(i)*vb
      IF (tmp GE tmin) THEN BEGIN
         value = tmp
         WHILE (1) DO BEGIN
            tmp = tmp+vb
            IF tmp LE tmax THEN $
               value = [value, tmp] $
            ELSE $
               GOTO, finish
         ENDWHILE
      ENDIF
   ENDFOR

finish:
   
   major = N_ELEMENTS(value)-1

   hours = value MOD 24

   minutes = 60*(value-FIX(value))
   
   IF N_ELEMENTS(show_sec) NE 0 THEN BEGIN 
      seconds = 60*(minutes-FIX(minutes))
      seconds = STRMID(STRING(100+FIX(seconds+0.5), FORMAT='(i3)'), 1, 2)
   ENDIF
   
   minutes = STRMID(STRING(100+FIX(minutes+0.5), FORMAT='(i3)'), 1, 2)

   label = STRMID(STRING(100+hours, FORMAT='(i3)'), 1, 2)+':'+minutes
   IF N_ELEMENTS(show_sec) NE 0 THEN label = label+':'+seconds

;---------------------------------------------------------------------------
;  Replace 00:00 mark with date string
;---------------------------------------------------------------------------
   ii = WHERE(hours EQ 0.0)
   IF ii(0) GE 0 THEN BEGIN
      time = 3600.d0*DOUBLE(value)+utc2tai(anytim2utc(btime))
      dow = ' ('+utc2dow(anytim2utc(time), /str, /abb)+')'
      IF tdiff GE 48.0 THEN $
      label(ii) = STRMID(anytim2utc(time(ii), /vms), 0, 6)+dow(ii)$
      ELSE BEGIN
         FOR j=0, N_ELEMENTS(ii)-1 DO BEGIN
            IF value(ii(j)) NE tmin THEN $
               label(ii(j))=STRMID(anytim2utc(time(ii(j)), /vms), 0, 6)+$
               dow(ii(j))
         ENDFOR
      ENDELSE
   ENDIF
   RETURN
END

;---------------------------------------------------------------------------
; End of 'mk_timetick.pro'.
;---------------------------------------------------------------------------
